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
