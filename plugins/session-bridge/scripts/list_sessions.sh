#!/usr/bin/env bash
# list_sessions.sh
# Lists Claude Code sessions on this machine, filtered to recent activity.
# Default: last 7 days, .trash/ excluded, empty JSONLs skipped.
#
# Usage:
#   list_sessions.sh [--days N] [--project SUBSTRING] [--format table|json]
#   list_sessions.sh --audit [--clean]
#
# Output columns (table): SID  PROJECT  LAST-ACTIVE  MSGS
# Sorted by last-active, newest first.
#
# Audit mode scans for stray scratch JSONLs left by branch_query.sh (identified
# by a sibling `.bridge-scratch` marker file). With --clean, removes them.

set -euo pipefail

DAYS=7
PROJECT_FILTER=""
FORMAT="table"
AUDIT=0
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)    DAYS="$2";           shift 2 ;;
    --project) PROJECT_FILTER="$2"; shift 2 ;;
    --format)  FORMAT="$2";         shift 2 ;;
    --audit)   AUDIT=1;             shift   ;;
    --clean)   CLEAN=1;             shift   ;;
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0
      ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

if (( AUDIT == 1 )); then
  PROJECTS_DIR="${HOME}/.claude/projects"
  [[ -d "$PROJECTS_DIR" ]] || { echo "no projects dir at $PROJECTS_DIR" >&2; exit 1; }

  stray=()
  while IFS= read -r marker; do
    [[ "$marker" == *"/.trash/"* ]] && continue
    stray+=("$marker")
  done < <(find "$PROJECTS_DIR" -name "*.bridge-scratch" -type f 2>/dev/null)

  if [[ ${#stray[@]} -eq 0 ]]; then
    echo "no stray session-bridge scratch files found"
    exit 0
  fi

  printf "Found %d stray scratch file(s):\n" "${#stray[@]}"
  for marker in "${stray[@]}"; do
    sid=$(basename "$marker" .bridge-scratch)
    slug=$(basename "$(dirname "$marker")")
    src=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('source_sid','?'))" "$marker" 2>/dev/null || echo "?")
    printf "  %s  (project=%s, branched-from=%s)\n" "$sid" "$slug" "$src"
  done

  if (( CLEAN == 1 )); then
    echo
    echo "Cleaning up..."
    for marker in "${stray[@]}"; do
      sid=$(basename "$marker" .bridge-scratch)
      dir=$(dirname "$marker")
      rm -f "${dir}/${sid}.jsonl" "$marker"
      [[ -d "${dir}/${sid}" ]] && rm -rf "${dir}/${sid}"
      printf "  removed %s\n" "$sid"
    done
    echo "done"
  else
    echo
    echo "Re-run with --clean to remove them."
  fi
  exit 0
fi

PROJECTS_DIR="${HOME}/.claude/projects"
[[ -d "$PROJECTS_DIR" ]] || { echo "no projects dir at $PROJECTS_DIR" >&2; exit 1; }

NOW=$(date +%s)
CUTOFF=$(( NOW - DAYS * 86400 ))

# Collect rows. Format: mtime|sid|slug|last_active|msg_count
rows=()
while IFS= read -r jsonl; do
  [[ "$jsonl" == *"/.trash/"* ]] && continue
  [[ "$jsonl" == *.activity.jsonl ]] && continue
  [[ -s "$jsonl" ]] || continue

  if stat -f "%m" "$jsonl" >/dev/null 2>&1; then
    mtime=$(stat -f "%m" "$jsonl")
  else
    mtime=$(stat -c "%Y" "$jsonl")
  fi
  (( mtime < CUTOFF )) && continue

  slug=$(basename "$(dirname "$jsonl")")
  sid=$(basename "$jsonl" .jsonl)

  if [[ -n "$PROJECT_FILTER" && "$slug" != *"$PROJECT_FILTER"* ]]; then
    continue
  fi

  msg_count=$(awk 'END { print NR }' "$jsonl")

  if date -r "$mtime" "+%Y-%m-%d %H:%M" >/dev/null 2>&1; then
    last_active=$(date -r "$mtime" "+%Y-%m-%d %H:%M")
  else
    last_active=$(date -d "@$mtime" "+%Y-%m-%d %H:%M")
  fi

  rows+=("${mtime}|${sid}|${slug}|${last_active}|${msg_count}")
done < <(find "$PROJECTS_DIR" -name "*.jsonl" -type f 2>/dev/null)

if [[ ${#rows[@]} -eq 0 ]]; then
  if [[ "$FORMAT" == "json" ]]; then echo "[]"; else echo "no sessions found in the last $DAYS days"; fi
  exit 0
fi

# Sort by mtime, newest first
IFS=$'\n' sorted=($(printf "%s\n" "${rows[@]}" | sort -t'|' -k1 -nr))
unset IFS

if [[ "$FORMAT" == "json" ]]; then
  printf '['
  first=1
  for row in "${sorted[@]}"; do
    IFS='|' read -r mtime sid slug last_active msg_count <<<"$row"
    [[ $first -eq 0 ]] && printf ','
    first=0
    printf '{"sid":"%s","project":"%s","last_active":"%s","msg_count":%s,"mtime":%s}' \
      "$sid" "$slug" "$last_active" "$msg_count" "$mtime"
  done
  printf ']\n'
else
  printf "%-36s  %-46s  %-16s  %6s\n" "SID" "PROJECT" "LAST ACTIVE" "MSGS"
  printf "%-36s  %-46s  %-16s  %6s\n" "------------------------------------" "----------------------------------------------" "----------------" "------"
  for row in "${sorted[@]}"; do
    IFS='|' read -r mtime sid slug last_active msg_count <<<"$row"
    short_slug="${slug:0:46}"
    printf "%-36s  %-46s  %-16s  %6s\n" "$sid" "$short_slug" "$last_active" "$msg_count"
  done
fi
