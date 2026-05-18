---
name: project-artifact-classifier
description: Classifies every file in a project folder as raw input, Claude-generated output, wiki content, code, or root-meta, using session transcripts, git history, and any declared semantics from project memory or CLAUDE.md. Triggers when initializing a project with project-wiki, when reclassifying after a folder restructure, or when the user asks "is this file an input or output", "did Claude generate this", "what bucket does this belong in", "what is this file", "where should this go". Underpins every move the /init flow makes — heuristics on filename alone are not safe.
---

## Inheritance
**Domain:** project-artifact-classifier
**Level:** CONCRETE
**Inherits From:** input-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/input-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Every `/init` move depends on knowing which bucket a file belongs to. Filename-pattern heuristics are not safe — a `report.md` could be a user-uploaded brief (raw) or a Claude-generated draft (output) or a wiki page. Misclassification corrupts the layout permanently. This skill produces a reasoned classification with evidence and confidence, and refuses to assume.

### Subject

Every file in the project root tree, recursively. For each file: which canonical bucket does it belong to, with what evidence, at what confidence.

### Buckets

- `raw/` — user-supplied input. Existed before Claude touched it, or user uploaded mid-session.
- `output/` — Claude-generated artifact. First appeared in a Claude tool call.
- `wiki/` — knowledge-base content. Either an existing wiki page (Karpathy/Obsidian/plain/Notion) or content earmarked by the user as "wiki material."
- `code/` — implementation source (under an existing code dir, package manifest, or src/ tree).
- `root-meta` — canonical root files: `CLAUDE.md`, `README.md`, `.gitignore`, `.git/`. These stay at root.
- `unknown` — insufficient evidence; flagged to user.

### Evidence sources (T1 — public from local data)

1. **Session timeline** (via `session-history-reader`) — when did this file first appear in a Claude turn, and was it produced by a tool call (output) or referenced by the user (raw)?
2. **Git history** — `git log --diff-filter=A` first-commit timestamp + author; pre-Claude history → user, post-Claude with Claude-author → output, ambiguous → flag.
3. **Declared semantics** (via `session-history-reader` reading project memory + CLAUDE.md) — explicit past instructions like "inputs is immutable" or "outputs go here." Beats inferred evidence.
4. **Existing folder location** — soft signal only; a file in `inputs/` is *probably* raw but verify against the other sources.

### Climb policy (specialization of input-scrutiny)

- T2 (ask user) when: confidence < 0.7 after T1, or two T1 sources disagree.
- T3 (paid) — N/A. All evidence is local.

### Domain-specific skeptical checks

1. Did the file's first-appearance-in-chat agree with its first-commit author? If not, why?
2. Was the file *referenced* by the user before Claude wrote it? Then it's raw (input) even if Claude wrote the bytes (transcription / cleanup case).
3. Are there pre-session files (predate any session in the timeline)? Default to `raw` but mark low-confidence.
4. Does a declared semantic (project memory or CLAUDE.md) override the inferred classification? Trust the declaration.
5. Is this file inside a vendored / cloned subtree (e.g., `node_modules/`, a submodule)? Skip — not the plugin's concern.

### Outputs (delta on top of inherited input-scrutiny outputs)

- **Classification report** — one row per file: `path | bucket | confidence | evidence (sources) | proposed-move (path)`. Sorted by confidence ascending so low-confidence files float to the top.
- **Risk register** entries per low-confidence file using `R-CLASS-*` prefix.
- **Unknown-bucket list** — files the skill cannot classify, with rationale.

### Risk-prefix taxonomy

`R-CLASS-*` for classification confidence risks.

### Consults

`session-history-reader` (timeline + declared semantics) · `dual-platform-adapter` (different evidence per platform).

### Consulted by

`project-wiki-orchestrator` (`/init`, `/status`), `wiki-migrator`, `project-convention-migrator`.

### Out of scope

Actually moving files (that's `file-move-safety`) · writing wiki entries about the artifacts (that's `wiki-updater`) · rewriting governance (that's `project-convention-migrator`).
