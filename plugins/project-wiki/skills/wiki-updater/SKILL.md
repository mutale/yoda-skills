---
name: wiki-updater
description: Translates conversation deltas, ingested sources, and code changes into wiki pages (general wiki/ or code/wiki/), respecting the appropriate shape skill. Appends to log.md, updates index.md, captures git SHA on code-wiki writes. Triggers when the user adds a file to raw/, asks "add this to the wiki", "document this", "ingest this PDF", "capture this decision", "open question: X", "log this", "update the wiki", or any phrasing implying knowledge or artifacts should be filed. Also triggers after /go-to-code when code-side documentation begins.
---

## Inheritance
**Domain:** wiki-updater
**Level:** CONCRETE
**Inherits From:** input-scrutiny (foundation), artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/input-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
3. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Ingest is the daily operation of the plugin. Centralizing every write through one skill means every page goes through the same provenance, citation, and validation pipeline. If updater branches per page-type or per vault, the conventions drift.

### Default target policy (mandatory)

- **`output/` is the default write target** for any artifact Claude generates. Drafts, analyses, brainstorms, code snippets, exported tables, anything ad-hoc — all go to `output/<date>-<session>/`. The updater can write here freely.
- **`wiki/` writes are NEVER direct.** A page enters `wiki/` only via the orchestrator's `/promote` flow, which runs `wiki-curator` first to produce a candidate, then waits for explicit user approval, and only then calls back into `wiki-updater` to commit the approved candidate.
- **Migration is the one exception** — content imported from an existing wiki via `wiki-migrator` is by assumption already wiki-shaped and gets tagged `status/needs-review` for follow-up curation.

This policy is what curation buys: every `wiki/` page has been deliberately picked, named, tagged, sourced, and approved. The wiki is curated knowledge, not a chat-log dump.

### Inputs

| Input | Tier | Source |
|---|---|---|
| New source file | T1 | `raw/<file>` (uploaded by user) |
| Conversation delta | T1 | Current chat turn(s) |
| Changed code file | T1 | `git diff` against last snapshot SHA |
| Vault target | Caller-provided | `general` or `code` |

### The ingest workflow (Karpathy-derived)

1. **Read** the source / chat delta / code diff in full.
2. **Discuss** key takeaways with the user *before writing anything*. (One round of confirmation prevents bad pages.)
3. **Search existing pages** for the topic. If a page exists → update it, not create a duplicate.
4. **Create or update** the page(s) following the shape skill for the target vault.
5. **Add `[[wikilinks]]`** to related concepts. New concepts that don't yet have pages → add to `questions.md` for later promotion, or create stub pages with `status/wip`.
6. **Update `index.md`** with new pages and one-line descriptions.
7. **Append `log.md`** with date, source, pages touched, session id.

A single source may touch 10–15 pages. That is normal.

### Code-side specifics

- On every code-wiki write, capture the current git SHA into the page's `source_sha` field.
- Cited `src/foo.py:42` ranges must exist at that SHA. Validator catches before write.
- Use `[[../wiki/concept-x]]` cross-vault links liberally; the general wiki tracks the *why*, code wiki tracks the *what*.
- Append a back-link to the corresponding `wiki/` concept page on its next update.

### Climb policy (specialization of input-scrutiny)

- T2 (user): always discuss before writing. The "before writing anything" rule from step 2.
- T3: N/A.

### Validation checklist (specialization of artifact-scrutiny)

Before any write commits:

1. YAML frontmatter strict-parses (via `obsidian-compat-validator`).
2. All required fields per page type are present (per shape skill).
3. Every factual claim has a citation OR is marked `[needs source]`.
4. `[[wikilinks]]` either resolve or have a `status/wip` stub created for the target.
5. Status tag is single, controlled vocab.

### Domain-specific skeptical checks

1. **Duplicate check first.** Searching for topic before writing prevents fragmentation.
2. **Cite or mark.** Every factual claim cites a source or carries `[needs source]` — never silently unsourced.
3. **Two sources disagree** → write both, add a `Contradiction:` block, surface to user. Don't pick.
4. **No `output/` blessed without `/promote`.** Updater can write to `output/` freely (drafts), but moving to `wiki/` is a separate user action via the orchestrator.
5. **Stub pages** are real pages with `status/wip` and at least the frontmatter; they're not empty files.

### Outputs (delta)

- New/updated wiki pages.
- `log.md` entry appended.
- `index.md` updated.
- Risk register entries prefixed `R-INGEST-*` for unsourced claims, contradictions, etc.
- For code-wiki writes: snapshot manifest update.

### Risk-prefix taxonomy

`R-INGEST-*` — ingest-time risks (unsourced claims, contradictions, missing fields).

### Consults

`obsidian-wiki-shape` (general writes), `code-wiki-shape` (code writes), `obsidian-compat-validator`, `file-move-safety` (when creating/moving files).

### Consulted by

`project-wiki-orchestrator` for `/sync`, `/promote`, and routine ingest.

### Out of scope

Choosing target vault (orchestrator decides per command) · lint (separate skill, separate cadence) · migration of existing wikis (`wiki-migrator`) · taking over existing project conventions (`project-convention-migrator`).
