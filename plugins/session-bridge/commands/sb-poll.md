---
description: Send the same prompt to several Claude Code sessions in parallel and collate the answers.
argument-hint: "<prompt> [--sids sid1,sid2,...] [--project SUBSTRING] [--days N] [--limit N]"
disable-model-invocation: false
---

The user wants to poll multiple Claude Code sessions with the same prompt and get all answers back together.

## Resolve the target list

1. Parse `$ARGUMENTS`. Everything before the first `--sids`, `--project`, `--days`, or `--limit` flag is the prompt body. Trim whitespace.
2. If `--sids sid1,sid2,...` was passed, use that exact list. Otherwise:

   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/list_sessions.sh" --format json \
     ${PROJECT_ARG:+--project "$PROJECT"} \
     ${DAYS_ARG:+--days "$DAYS"}
   ```

   Take the first `--limit` results (default 5, most recent first). Show the user the sid + project for each one BEFORE spawning anything, and offer to widen or filter.

## Fan out

3. In a SINGLE assistant message, spawn one `session-bridge:session-querier` subagent per sid. Pass each one a structured prompt of the form:

   ```
   sid=<full-uuid>
   mode=branch
   prompt=<the user's prompt, verbatim>
   ```

   `mode=branch` is mandatory in this command; `/sb-poll` never appends to live sessions.

4. When all subagents return, present results as one section per sid:

   ```
   ### <short-sid>  (<project basename>)
   <reply verbatim>
   ```

   If a subagent returned an error, show the error verbatim in that section. Do not retry automatically.

## Privacy rules

- Do NOT paste any other session's transcript into your reply to the user beyond what the querier subagents returned.
- Do NOT call `Read` on any file under `~/.claude/projects/`. The querier is the only allowed path.
- Do NOT widen the prompt sent to the targets beyond what the user typed. Send the user's prompt verbatim. Don't append context from your own session.
- If the user's prompt is open-ended ("what have you been doing?"), warn them once that they'll be pulling transcripts-worth of detail into THIS session and ask whether to narrow it.
