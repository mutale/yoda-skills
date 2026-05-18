---
name: session-history-reader
description: Reads Claude session transcripts and project long-term memory to produce two evidence streams — per-file first-appearance timeline (which Claude turn first touched each file) and recorded user instructions about project structure (what past you told Claude about folder semantics, immutability, conventions). On Claude Code reads ~/.claude/projects/<slug>/*.jsonl plus the memory/ folder; on Cowork the storage location is partially known (research-in-progress). Triggers when classifying project artifacts, when checking what past Claude sessions said about a project, or when the user asks "what did Claude do last time", "what did I tell Claude before", "check the session history", "where are the chat logs".
---

## Inheritance
**Domain:** session-history-reader
**Level:** CONCRETE
**Inherits From:** input-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/input-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Two downstream skills need this evidence base: the classifier (per-file timeline) and the convention-migrator (declared instructions). Centralizing keeps platform-specific quirks (JSONL parsing, memory folder structure, Cowork API differences) in one place instead of duplicated.

### Storage locations

| Platform | Transcripts | Project memory |
|---|---|---|
| Claude Code | `~/.claude/projects/<project-slug>/*.jsonl` | `~/.claude/projects/<project-slug>/memory/` (MEMORY.md index + per-memory files) |
| Cowork | TBD — current best guess: web export only | Cowork project memory (location confirmed; format under investigation) |

The slug for Code is the cwd path with `/` replaced by `-` (e.g., `/Users/yoda2/Documents/Claude/Projects/Skill Building/yoda-skills` → `-Users-yoda2-Documents-Claude-Projects-Skill-Building-yoda-skills`).

### Evidence streams produced

1. **First-appearance timeline** — for every file ever mentioned in a transcript, the earliest event: `file | first-seen-timestamp | session-id | producing-tool-call (Write/Edit/Bash) | author (user-reference vs claude-tool)`.
2. **Recorded instructions** — every user statement that declares semantics about the project: folder names, immutability, conventions, scope. Each entry: `quote | session-id | timestamp | confidence (verbatim / paraphrased)`.

### Climb policy (specialization of input-scrutiny)

- T1 (free): transcript + memory parsing on local disk.
- T2 (user): ask user to confirm a contested or ambiguous instruction.
- T3: N/A.

### Domain-specific skeptical checks

1. Sessions can be **compacted** — the file may have first-appeared in a window that's been summarized away. Flag as low-confidence.
2. **Multiple sessions** can touch the same file; always pick the *earliest* first-appearance, not the latest.
3. **Memory entries can be stale** — flag any memory record older than the latest contradictory state in the current project (e.g., memory says "inputs/ is immutable" but inputs/ no longer exists on disk).
4. **Slug collisions** are rare but possible if the user has cwd path collisions; verify slug matches actual cwd, not just name.
5. On Cowork: if transcripts aren't available, **explicitly flag missing-evidence** rather than silently producing partial output.

### Outputs (delta on top of inherited)

- Timeline JSON: `[{file, first_seen, session_id, producing_tool, author}, ...]`
- Instructions list: `[{quote, session_id, timestamp, confidence}, ...]`
- Unknown-provenance list: files referenced but with no detectable first-appearance.
- Risk register entries prefixed `R-HIST-*` for compacted sessions or Cowork-missing-transcripts.

### Risk-prefix taxonomy

`R-HIST-*` — session-history evidence gaps.

### Consults

`dual-platform-adapter` (storage locations differ per platform).

### Consulted by

`project-artifact-classifier`, `project-convention-migrator`, `project-wiki-orchestrator`.

### Out of scope

Classification (the classifier's job) · convention rewriting (the migrator's job) · session summarization or transcript editing.

### Open issue (tracked as R-HIST-COWORK-01)

Cowork session storage location and format need confirmation before Cowork support is production-ready. 0.1 ships with full Code support and best-effort Cowork support that explicitly degrades when transcripts can't be located.
