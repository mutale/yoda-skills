---
name: project-wiki-orchestrator
description: User-facing command surface for the project-wiki plugin. Sequences worker skills and merges outputs for slash commands /init, /sync, /go-to-code, /status, /lint, /promote. Enforces root uniformity (only raw/, output/, wiki/, code/, plus canonical files at project root). On /init, runs project-convention-migrator BEFORE project-artifact-classifier so declared semantics inform bucketing. Triggers on the slash commands; on phrases like "initialize this project for wiki", "set up project-wiki here", "add this project to my second-brain", "organize this folder for wiki", "reorganize this", "let's apply project-wiki", "go to code", "start coding", "snapshot for code", "audit the wiki", "promote this to wiki", "what's the wiki status".
---

## Inheritance
**Domain:** project-wiki-orchestrator
**Level:** CONCRETE
**Inherits From:** orchestrator (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/orchestrator.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Without the orchestrator, each slash command would have to know every worker, the federation would collapse to spaghetti, and the user would have to remember which skill to fire for which task. The orchestrator is the single entry point that owns the command surface and sequencing rules.

### Subject

A user's project folder — either a Claude Code working directory or a Claude Cowork workspace. The orchestrator operates on one project at a time.

### Audience

The user, who is developing the project. Outputs are pragmatic — diffs, reports, prompts — not stakeholder memos. Audience-format is "developer in their own workflow."

### Commands and their sequencing

#### `/init` (the takeover flow)

```
1. dual-platform-adapter            detect Code vs Cowork; cache capabilities
2. project-convention-migrator      [RUN FIRST — declared semantics inform classification]
                                    read CLAUDE.md, .cursorrules, AGENTS.md, project memory, STRUCTURE.md
                                    produce takeover report
3. session-history-reader           build per-file timeline + instruction list
4. project-artifact-classifier      per-file bucket with evidence + confidence
                                    (consults convention-migrator's mapping for declared semantics)
5. [detect existing wiki?]          if yes → wiki-migrator (dry-run plan)
6. [USER REVIEW + APPROVAL]         takeover report + classification + wiki migration plan
7. file-move-safety                 apply approved moves + folder renames + content migration
8. obsidian-wiki-shape              install schemas/templates + write project-specific CLAUDE.md
9. (if code/ present)               code-wiki-shape stub for code/wiki/
10. [final status report]
```

The user can `--dry-run` (default) to stop at step 6, or `--apply` to proceed.

#### `/sync`

```
1. wiki-updater (sync mode)         regenerate index.md from current pages
                                    re-validate log.md append-only invariant
2. wiki-linter                      health audit
3. [report]                         what was updated, lint findings inline
```

#### `/go-to-code`

```
1. dual-platform-adapter            check Code platform (Cowork has no local code/ tree)
2. code-wiki-snapshotter            compute delta vs last manifest
3. [conflict?]                      if yes → write conflict file, halt
4. file-move-safety                 apply snapshot writes
5. code-wiki-shape                  validate every imported page against the code schema
6. [report]                         pages imported, manifest updated, conflicts (if any)
```

#### `/lint`

```
1. wiki-linter (general wiki/)
2. wiki-linter (code/wiki/ if present)
3. [merged audit report]
```

#### `/promote <path>`

```
1. project-artifact-classifier      verify <path> is in output/
2. wiki-curator                     refine draft into a candidate wiki page
                                    (strip cruft, resolve citations, add wikilinks,
                                    pick name + tags, write summary)
                                    emit to .project-wiki/candidates/<name>.md
3. [USER REVIEW + APPROVAL]         user reads candidate, may edit, then approves;
                                    may also escalate unresolved sources or rename
4. wiki-updater                     commit the approved candidate to wiki/
5. file-move-safety                 leave original in output/ (promotion is copy + curate, not move)
6. [report]
```

**Curation is mandatory.** No path commits content to `wiki/` without going through `wiki-curator` first. The orchestrator refuses to call `wiki-updater` for a `wiki/` write unless a corresponding `.project-wiki/candidates/<name>.md` exists and has been user-approved. The one exception is `/init`'s migration phase, where existing wiki content imported via `wiki-migrator` is by assumption already wiki-shaped (and gets tagged `status/needs-review`).

#### `/status`

```
1. project-artifact-classifier (status mode — quick scan, no apply)
2. dual-platform-adapter            current capabilities
3. session-history-reader           last 5 instructions, any conflicts with current state
4. wiki-linter (quick mode)         broken-link count, orphan count, stale SHA count (code wiki)
5. [dashboard]                      root uniformity OK?  pending moves?  last sync?  open conflicts?
```

### Root uniformity rule (mandatory enforcement)

After `/init` applies, the project root contains **only** these entries:

- `raw/`
- `output/`
- `wiki/`
- `code/` (if implementation has begun)
- `CLAUDE.md`
- `README.md` (if present originally; never deleted)
- `.git/`, `.gitignore` (preserved)
- `.project-wiki/` (plugin's metadata — undo log, legacy archive)

**Anything else at root is either bucketed (per classifier) or flagged for user decision.** No exceptions. The user can override per-project via CLAUDE.md, but the default is strict.

### Conflict resolution rules

1. **Convention-migrator vs. classifier disagree on a file's bucket.** Trust convention-migrator — an explicit user declaration (in CLAUDE.md or memory) beats inferred history.
2. **Wiki-migrator vs. convention-migrator disagree on whether old `wiki/` is "wiki content" or "legacy notes."** Surface to user; default to wiki content if format detection succeeded, legacy notes otherwise.
3. **Classifier confidence < 0.7 on a destructive move.** Halt the move; ask the user.
4. **Snapshotter detects local code-wiki edits.** Halt the entire snapshot; never overwrite. Conflict file is the deliverable.
5. **Lint findings disagree with shape-skill validation.** Trust the shape skill (the linter consults it).

Never silently average or pick — surface every disagreement.

### Mandatory pre-publish enforcement (specialization of orchestrator abstract)

`/init --apply` refuses to proceed if any of these are pending:

- Takeover report not user-approved.
- Classifier confidence threshold (default 0.7) not met on a destructive move.
- Pending `/sync` from a prior run.
- `code/wiki/` has unresolved conflict files.

### Domain-specific skeptical checks

1. Are top-N risks ranked by **user-impact** (data loss, governance override, broken wikilink count), not by which worker produced the most output?
2. Did the takeover report fully cover every detected source of convention (CLAUDE.md, rule files, memory, convention docs)?
3. Is the new CLAUDE.md consistent with the canonical layout AND with any preserved user-specific instructions?
4. Where workers disagreed — was the disagreement surfaced, not silently picked?
5. Is the deliverable formatted for the user (terse, actionable), not as a generic skill output?

### Outputs (delta on top of inherited orchestrator outputs)

Per command, with format calibrated for "developer in their own workflow":

- **`/init`** — Takeover report → classification table → migration plan → final status (root uniformity check, files moved, files flagged).
- **`/sync`** — Update summary → lint findings inline.
- **`/go-to-code`** — Snapshot delta → conflict file (if any) → manifest update confirmation.
- **`/lint`** — Numbered audit report with severity.
- **`/promote <path>`** — Promotion confirmation → new wiki page reference.
- **`/status`** — One-screen dashboard.

Always: aggregated risk register (deduplicated, prioritized), surface-the-unverified summary, citations across worker outputs.

### Quantification unit

- For move risks: **count of files** affected.
- For governance risks: **count of declarations** rewritten.
- For lint findings: **count by severity** (block / warn / inform).

### Risk-prefix taxonomy

The orchestrator aggregates and may add `R-ORCH-*` for cross-skill issues (e.g., classifier + convention-migrator persistently disagreeing on the same files).

### Consults

Every Layer-1 skill: `project-convention-migrator`, `project-artifact-classifier`, `session-history-reader`, `wiki-migrator`, `wiki-curator`, `wiki-updater`, `wiki-linter`, `code-wiki-snapshotter`, `obsidian-wiki-shape`, `code-wiki-shape`. Plus Layer-2 cross-cutters: `dual-platform-adapter`, `file-move-safety`, `obsidian-compat-validator`.

### Consulted by

The user directly via the slash commands above.

### Out of scope

Doing any worker's job itself — the orchestrator only sequences. Auto-fixing lint findings (advisory only; user routes back to updater via `/promote` or manual edit). Round-trip sync from code-wiki back to outer wiki (deferred to a future version).
