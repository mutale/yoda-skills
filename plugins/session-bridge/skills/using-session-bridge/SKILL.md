---
name: using-session-bridge
description: Use when you need to query, consult, or fan out a question across OTHER Claude Code sessions on this machine, treating them as tools (RAG-like read sources) rather than peers. Covers discovery (`/sb-list`), branch-and-query (safe default, never mutates the target), parallel fanout (`/sb-poll` or spawning multiple session-querier subagents in one message), the rare append mode (only when the user explicitly asks to drive a live session), and the privacy contract that keeps the umbrella session clean.
---

# Using Session Bridge

You can talk to other Claude Code sessions on this machine as if they were tools. They are not peers, they are not RAG indexes, they are running (or recently-active) Claude Code sessions whose context you can query through a strict interface.

This skill defines that interface and the privacy boundary that keeps it safe.

## Mental model

- Target sessions are **read sources**. You ask them scoped questions. They answer. You do not pull their transcripts into your own context.
- The session-querier subagent is the **boundary**. All cross-session traffic goes through it. Reading a target's `.jsonl` directly with `Read` or `cat` is a contract violation.
- Default behavior is **non-mutating**: the target's JSONL is copied to a scratch sid, the copy is queried, then the copy is deleted. The original is untouched.
- The umbrella (current) session stays clean: it accumulates only the answers it asked for, not the targets' raw conversation history.

## When to use this skill

- The user references work happening in a Claude Code session that is NOT the one you're in ("ask the connector-builder session ...", "what did the X session decide ...").
- The user wants to fan out the same question across several sessions.
- The user wants to use another session's accumulated context (its tool runs, its files read, its decisions) to answer a scoped question.

## When NOT to use this skill

- The user wants to start fresh work. Use a normal subagent.
- The user wants to merge two sessions' state. There is no merge; only ask and answer.
- The user wants you to "see" everything another session did. That breaks the privacy contract. Push back and ask for a scoped question.

## The three modes

### 1. Discovery (read-only listing, no per-session content)

`/sb-list` runs `scripts/list_sessions.sh`. You get one row per recent session: full sid, project slug, last-active timestamp, message count. Nothing from inside the JSONL is exposed.

### 2. Branch-and-query (default, safe)

Spawn the `session-bridge:session-querier` subagent with:

```
sid=<full-uuid>
mode=branch
prompt=<your scoped question>
```

The querier copies the target's JSONL to a fresh sid in the same project slug, runs `claude --resume <copy-sid> -p "<prompt>"` headless from the target's original cwd, returns the model's reply, then the script deletes the copy. The original session is untouched. This is what you should do 95% of the time.

For parallel fanout, spawn several querier subagents in the same assistant message, each with a different sid. Or use `/sb-poll <prompt>`, which handles discovery + fanout for you.

### 3. Append (rare, mutating)

Pass `mode=append` ONLY when the user explicitly asks to drive or steer the live target session. The querier appends a real turn to the target. The script refuses to append when the target's `.activity.jsonl` shows in-flight work (last entry less than 120 seconds old and no stop marker). Respect that refusal. Do not retry, do not work around.

## Privacy contract (the load-bearing part)

This is what makes the "tool, not peer" mental model real. Hold to it.

1. **Targets are read sources.** You never paste a target's transcript into your reply, never echo lines from its JSONL, never enumerate "everything it did." You ask narrow questions and pass on the narrow answers.
2. **Only the querier touches other sessions.** Do not use `Read`, `Bash(cat ...)`, `Grep`, or any other tool against `~/.claude/projects/`. If you find yourself wanting to, that's the signal to formulate a scoped question for the querier instead.
3. **No mode promotion.** `branch` never silently becomes `append`. Mode is set by the user's intent, full stop.
4. **No prompt smuggling.** When `/sb-poll` fans out, send the user's prompt verbatim. Don't prepend "By the way, here is the context I have so far ..." That would leak THIS session's content into target sessions.
5. **Scoped questions only.** If the user asks something open-ended ("what have you been doing in the other session"), ask them to narrow it before sending. A transcript dump pulls everything the target has done into your context.
6. **Branched copies are ephemeral.** The bridge script deletes scratch JSONLs via an EXIT trap. If a query fails halfway, the copy is still removed. Verify periodically by listing `~/.claude/projects/*/` for stray UUIDs you do not recognize.
7. **No cross-project credential transfer.** Each target's `claude --resume` runs under its own project's settings and CLAUDE.md. Permissions do not flow from the umbrella to the target. If the target needs creds the umbrella has, the user has to grant them in the target's project.

## Common shapes

**"Ask the X session whether Y is done."**

1. `/sb-list --project X` to find the right sid.
2. Spawn one `session-querier` with that sid, `mode=branch`, and the scoped question.
3. Show the reply verbatim.

**"Poll all my recent sessions: did anyone hit error Z today?"**

1. `/sb-poll did anyone hit error Z today? --days 1 --limit 10`
2. Show one section per sid.

**"Drive the Y session to run /verify."**

1. Confirm with the user that this writes to the live session.
2. Spawn one `session-querier` with `mode=append`.
3. If the querier refuses (in-flight work), surface the refusal verbatim and let the user decide.

## What to do if you slip

If you realize you accessed a target's JSONL directly, or you accidentally pulled a transcript dump into the umbrella, tell the user. Do not paper over it. The whole point of this skill is that the umbrella stays clean, and the user is the one who decides whether contamination is acceptable.
