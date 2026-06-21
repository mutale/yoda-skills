---
description: List recent Claude Code sessions on this machine (last 7 days, .trash/ excluded).
argument-hint: "[--days N] [--project SUBSTRING] [--format table|json]"
disable-model-invocation: false
---

Run the discovery script and show the user the result.

1. Execute:

   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/list_sessions.sh" $ARGUMENTS
   ```

2. Show the stdout verbatim as a table (it is already formatted for monospace display). Do not paraphrase or add commentary.

3. If the user asks "older" or "more", re-run with `--days 30` or `--days 90`. If they name a project ("the connector builder ones"), re-run with `--project <substring>`.

## Flags accepted by the script

- `--days N`: change the recency cutoff (default 7).
- `--project SUBSTRING`: filter to sessions whose project slug contains SUBSTRING (case-sensitive).
- `--format json`: emit machine-readable JSON instead of a table.
- `--audit`: scan for stray scratch JSONLs left behind by `branch_query.sh` (identified by a sibling `.bridge-scratch` marker). Lists them only.
- `--audit --clean`: same as `--audit`, plus delete the matching JSONLs, sidecar dirs, and marker files. Confirm with the user before running with `--clean`.

## What NOT to do

- Do not `cat` or `Read` any JSONL file under `~/.claude/projects/` to enrich the output. The script's columns (sid, project, last-active, msg-count) are intentionally the full surface area.
- Do not call the `session-bridge:session-querier` agent unless the user asks you to actually query one of the sessions.
