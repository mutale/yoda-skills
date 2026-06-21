#!/usr/bin/env bash
# branch_query.sh
# Query a Claude Code session and return only the model's reply.
#
# Default mode (branch):
#   1. Locate the target session JSONL under ~/.claude/projects/<slug>/<sid>.jsonl
#   2. Copy it to a fresh sid in the SAME slug folder
#   3. Run `claude --resume <copy-sid> -p "<prompt>"` headless, with cwd set to
#      the project's original cwd (read from the JSONL's first message that has a cwd field)
#   4. Print the headless reply on stdout
#   5. Delete the scratch copy (always, via EXIT trap)
#
# Append mode:
#   Skips the copy. Appends a real turn to the live target session.
#   Refuses to proceed when the target's .activity.jsonl shows in-flight work.
#
# The script prints ONLY the model's reply on stdout. Diagnostics go to stderr.
# It does not read or echo any portion of the target session's transcript.
#
# Usage:
#   branch_query.sh --sid <session-id> --prompt <text> [--mode branch|append]

set -euo pipefail

SID=""
PROMPT=""
MODE="branch"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sid)    SID="$2";    shift 2 ;;
    --prompt) PROMPT="$2"; shift 2 ;;
    --mode)   MODE="$2";   shift 2 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$SID" || -z "$PROMPT" ]]; then
  echo "usage: branch_query.sh --sid <sid> --prompt <text> [--mode branch|append]" >&2
  exit 2
fi
if [[ "$MODE" != "branch" && "$MODE" != "append" ]]; then
  echo "invalid --mode: $MODE (must be branch or append)" >&2
  exit 2
fi

PROJECTS_DIR="${HOME}/.claude/projects"

SOURCE_JSONL=$(find "$PROJECTS_DIR" -name "${SID}.jsonl" -type f -not -path "*/.trash/*" 2>/dev/null | head -1)
if [[ -z "$SOURCE_JSONL" ]]; then
  echo "session not found: $SID" >&2
  exit 3
fi
SLUG_DIR=$(dirname "$SOURCE_JSONL")

# In-flight guard for append mode.
if [[ "$MODE" == "append" ]]; then
  ACTIVITY="${SLUG_DIR}/${SID}.activity.jsonl"
  if [[ -f "$ACTIVITY" && -s "$ACTIVITY" ]]; then
    if stat -f "%m" "$ACTIVITY" >/dev/null 2>&1; then
      activity_mtime=$(stat -f "%m" "$ACTIVITY")
    else
      activity_mtime=$(stat -c "%Y" "$ACTIVITY")
    fi
    activity_age=$(( $(date +%s) - activity_mtime ))
    last_line=$(tail -n 1 "$ACTIVITY" 2>/dev/null || true)
    if (( activity_age < 120 )) && ! printf '%s' "$last_line" | grep -q '"k":"stop"'; then
      echo "refusing to append: session ${SID} has in-flight work (activity log fresh, no stop marker)" >&2
      exit 4
    fi
  fi
fi

# Reconstruct the cwd from the session JSONL itself. The slug-to-path mapping
# is lossy when path components contain dashes, so we read the cwd field from
# the first JSONL line that has one.
CWD=$(python3 - "$SOURCE_JSONL" <<'PY' 2>/dev/null || true
import json, sys
path = sys.argv[1]
with open(path, 'r', errors='replace') as fh:
    for line in fh:
        try:
            obj = json.loads(line)
        except Exception:
            continue
        cwd = obj.get('cwd')
        if cwd:
            print(cwd)
            break
PY
)
if [[ -z "${CWD:-}" || ! -d "$CWD" ]]; then
  CWD="$PWD"
fi

TARGET_SID="$SID"
TARGET_JSONL=""
SIDECAR_DIR=""
MARKER_FILE=""
DID_BRANCH=0

cleanup() {
  if (( DID_BRANCH == 1 )); then
    [[ -n "$TARGET_JSONL" && -f "$TARGET_JSONL" ]] && rm -f "$TARGET_JSONL"
    [[ -n "$SIDECAR_DIR"  && -d "$SIDECAR_DIR"  ]] && rm -rf "$SIDECAR_DIR"
    [[ -n "$MARKER_FILE"  && -f "$MARKER_FILE"  ]] && rm -f "$MARKER_FILE"
  fi
}
trap cleanup EXIT INT TERM

if [[ "$MODE" == "branch" ]]; then
  if command -v uuidgen >/dev/null 2>&1; then
    NEW_SID=$(uuidgen | tr 'A-Z' 'a-z')
  else
    NEW_SID=$(python3 -c 'import uuid; print(uuid.uuid4())')
  fi
  # Write the marker BEFORE copying the JSONL so /sb-list --audit can find a
  # half-created branch even if we get killed mid-copy.
  MARKER_FILE="${SLUG_DIR}/${NEW_SID}.bridge-scratch"
  printf '{"source_sid":"%s","created_at":%s,"pid":%s}\n' \
    "$SID" "$(date +%s)" "$$" > "$MARKER_FILE"
  TARGET_JSONL="${SLUG_DIR}/${NEW_SID}.jsonl"
  cp "$SOURCE_JSONL" "$TARGET_JSONL"
  if [[ -d "${SLUG_DIR}/${SID}" ]]; then
    cp -R "${SLUG_DIR}/${SID}" "${SLUG_DIR}/${NEW_SID}"
    SIDECAR_DIR="${SLUG_DIR}/${NEW_SID}"
  fi
  TARGET_SID="$NEW_SID"
  DID_BRANCH=1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found on PATH" >&2
  exit 5
fi

(
  cd "$CWD"
  claude --resume "$TARGET_SID" -p "$PROMPT"
)
