---
name: obsidian-wiki-shape
description: Defines the canonical shape of the general wiki/ vault — YAML frontmatter schema (title, summary, sources, updated, tags, type, session_id), page types (concept, decision, question), citation rules (footnote [^src] resolving to a file in raw/), tag taxonomy (status/wip, status/stable, topic/*, type/*), file-naming conventions, standard vault files (index.md, log.md, questions.md, decisions.md). Triggers when authoring or auditing a wiki/ page, when wiki-updater needs to know which fields are required, when migrating an existing wiki to this format, or when the user asks "what should a wiki page look like", "what fields do I need", "show me the schema".
---

## Inheritance
**Domain:** obsidian-wiki-shape
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

One source of truth for what a general-wiki page looks like. The updater, linter, and migrator all consult this skill; without it, each would invent its own conventions and the vault would drift.

### Frontmatter schema (every wiki/ page)

```yaml
---
title: <Human-readable page title>           # required
summary: <1-2 sentences>                      # required
sources: [raw/file-a.pdf, raw/file-b.md]      # required (may be empty list if no external source)
updated: 2026-05-18                           # required, ISO-8601
type: concept | decision | question           # required, controlled vocab
tags: [topic/foo, status/wip]                 # required, must include status tag
session_id: <claude-session-id>               # required, provenance
---
```

### Page types

| Type | Purpose | Additional required fields |
|---|---|---|
| `concept` | A topic, idea, entity, or component in the project's knowledge graph. | — |
| `decision` | A decision made by the user, ADR-lite. Filed into `decisions.md` *and* a standalone page if substantial. | `decided_on` (date), `alternatives_considered` (list) |
| `question` | An open question. Filed into `questions.md` *and* a standalone page if it has analysis. | `status: open | resolved | abandoned` (override of default `status/wip`) |

### Citation rules

- Every factual claim cites a source as a footnote: `Claim text.[^src1]`
- The footnote definition at the bottom references a file in `raw/`: `[^src1]: raw/japan-guidebook.pdf, p. 42.`
- Two sources disagree → cite both, add a `Contradiction:` block explaining; don't pick silently.
- Unsourced claims are marked `[needs source]` inline AND added to the risk register.

### Tag taxonomy (controlled vocabulary)

- **Status:** `status/wip`, `status/stable`, `status/needs-review`, `status/deprecated`. Every page has exactly one status tag.
- **Topic:** `topic/<slug>` — free-form but kebab-case. Used for Obsidian's graph view clustering.
- **Type-mirror:** the `type` frontmatter field doubles as a `type/<value>` tag for graph filtering.

### File naming

- Lowercase kebab-case: `machine-learning.md`, not `Machine Learning.md`.
- No reserved chars (see `obsidian-compat-validator`).
- Length ≤ 100 chars.

### Standard vault files

| File | Purpose | Append-only? |
|---|---|---|
| `index.md` | Table of contents; one line per page with one-line description. | No (regenerated). |
| `log.md` | Operation log: `date \| op \| source \| pages_touched \| session_id`. | **Yes**. |
| `questions.md` | Open-questions backlog. Each open question is one block. Resolved → promoted to a standalone page and removed here. | No. |
| `decisions.md` | ADR-lite, one block per decision: date, decision, rationale, alternatives. | Append-only for the entries; pages can be added but never edited. |
| MOC pages (`<topic>-moc.md`) | Map-of-content tables for whole categories — one table row per item with name + one-line description + status. Used INSTEAD of dedicated stub pages. | No (regenerated as items earn dedicated pages). |

### Lean-wiki principles (mandatory)

The wiki is meant to be small enough to scan, dense enough to be useful, and durable across sessions. To prevent bloat, every write (via `wiki-updater` or `wiki-curator`) and every audit (via `wiki-linter`) consults these principles:

1. **Don't auto-ingest in bulk.** When a domain has many similar items (e.g., 26 connectors, 81 PDF rules, 11 DLLs), build an MOC table — one row per item — and only promote a row to its own dedicated page when that item is *cited* (referenced from an incident, a decision, or another page). Stubs without content are bloat.
2. **Pages should be short.** Aim for under 150 lines per page. If a page goes longer, split into MOC + child pages OR move the long body into a `## Details (optional reading)` section.
3. **MOC tables beat stub pages.** A row with name + one-line description + status is faster to read than a dedicated empty page. Only create a dedicated page when there's real content (verified evidence, code refs, decision rationale).
4. **No defensive padding.** Drop "Wave 2 stub" placeholders, "TBD" tables, "to be ingested" notes. Empty future is expressed once in the MOC ("Not yet ingested"), not in stub pages.
5. **Citations point at `raw/`** — don't paste source passages into the wiki unless you're annotating them. The page contains the *takeaway* and a footnote citation; the raw passage stays in `raw/`.
6. **One page per CONCEPT, not per ARTIFACT.** N artifacts that share M scaffolding shapes give you M concept pages, not N stubs.
7. **The MOC is the index.** If a topic can't be found via the MOC, add a row to the MOC — don't invent a new page.

**Issue-resolution compaction:** During an active investigation, pages may legitimately grow with logs, traces, exploration notes, and intermediate hypotheses — that's part of solving the issue. **Once the issue is resolved and confirmed**, those pages get compacted by `wiki-pruner`: a short summary replaces the verbose body, the detailed content is archived to `output/<date>-resolved-<issue>/`, and the summary links to the archive. The wiki stays lean; the detail stays preserved.

**When to prune:** any time the vault exceeds ~50 pages, on a user-issued `/prune` command, or when an issue is closed via `/resolve <issue>`. `wiki-linter` surfaces bloat candidates as part of its audit even when no prune is requested.

### Template page

```markdown
---
title: <Title>
summary: <1-2 sentences>
sources: []
updated: 2026-05-18
type: concept
tags: [topic/example, status/wip]
session_id: <session-id>
---

## Summary

<Expansion of the summary.>

## Body

<Main content. Use `[[wikilinks]]` to connect to related pages. Cite claims with `[^src1]` footnotes.>

## Related pages

- [[related-concept-1]]
- [[related-concept-2]]

## Sources

[^src1]: raw/<file>, p. <n>.

---
_From session: <session-id>_
```

### Domain-specific skeptical checks

1. Page type must be in `{concept, decision, question}`. Reject `note`, `random-thought`, `todo`, etc. — those go to `questions.md` or `output/`.
2. `sources: []` is valid (no external source) but the page body must not contain `[^src...]` footnotes — those imply sources exist.
3. Status tag is single — `[status/wip, status/stable]` is a bug (pick one).
4. `[[wikilinks]]` to non-existent pages create graph orphans; the linter catches but this skill warns at authoring time.

### Outputs (delta)

- Schema artifact (`schemas/page.frontmatter.json`) — JSON Schema for the YAML frontmatter.
- Template page (above) for the updater to copy from.
- Tag taxonomy doc (above).
- Risk register entries prefixed `R-SHAPE-G-*` for schema violations.

### Risk-prefix taxonomy

`R-SHAPE-G-*` — general-wiki shape violations.

### Consults

`obsidian-compat-validator` for the underlying validation primitives.

### Consulted by

`wiki-updater`, `wiki-linter`, `wiki-migrator`, `project-wiki-orchestrator`.

### Out of scope

Code wiki shape (`code-wiki-shape`) · writing actual content (`wiki-updater`) · checking citation validity at lint time (the linter consults this skill for the schema but performs the resolve itself).
