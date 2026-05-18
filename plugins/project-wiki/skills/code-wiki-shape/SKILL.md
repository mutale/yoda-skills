---
name: code-wiki-shape
description: Defines the canonical shape of the code/wiki/ vault — page types (module, api, adr, example, architecture), code-citation format (src/foo.py:42-58 with clickable links), git-SHA provenance per page, cross-vault link convention [[../wiki/concept-x]] back to the general wiki, examples manifest at code/wiki/examples/manifest.md, code-block-paired-with-file:line pattern. Distinct from general-wiki shape because code wiki has a living link to the codebase that the general wiki doesn't. Triggers when authoring or auditing a code/wiki/ page, when code-wiki-snapshotter creates the initial vault, or when the user asks "how do I document this module", "add this to the code wiki", "API doc for X", "ADR for Y".
---

## Inheritance
**Domain:** code-wiki-shape
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Code wiki has a **living link to the codebase** — every page is tied to source files at a git SHA. The general wiki doesn't have this; it cites raw documents that don't change shape. Folding both into one shape skill lets one set of conventions dominate the other, so this skill is a peer of `obsidian-wiki-shape` rather than a subclass.

### Frontmatter schema (every code/wiki/ page)

```yaml
---
title: <Human-readable name>                  # required
summary: <1-2 sentences>                      # required
type: module | api | adr | example | architecture  # required, controlled
source_files: [src/foo.py, src/bar.py]        # required for module/api/example; optional for adr/architecture
source_sha: <git-sha-at-page-creation>        # required (7+ char)
updated: 2026-05-18                           # required, ISO-8601
tags: [layer/service, status/stable, coverage/tested]   # required; status + layer + optional coverage
related_concepts: [[../wiki/concept-x]]       # cross-vault link to general wiki (list, may be empty)
session_id: <claude-session-id>               # required
---
```

### Page types

| Type | Purpose | Required additional fields |
|---|---|---|
| `module` | A module/package/component — public API, internal layout, examples. | `source_files` (≥1). |
| `api` | One endpoint or one public function: contract, request/response, errors. | `source_files` (1), `signature` (string). |
| `adr` | Architecture Decision Record. | `decided_on` (date), `alternatives_considered` (list). |
| `example` | Runnable usage example tied to a file in `code/wiki/examples/`. | `example_file` (path). |
| `architecture` | System-level diagram (mermaid) + narrative. | `diagram_format` (e.g., `mermaid`). |

### Code citation format

- Inline: `[src/foo.py:42-58](../../src/foo.py#L42-L58)` — clickable in Obsidian and renders as a normal link in other markdown viewers.
- For a single line: `src/foo.py:42`.
- For a vendor / dep file: `vendor/<pkg>/foo.py:42` or `node_modules/<pkg>/index.js:42`.
- The cited range must exist at the recorded `source_sha`. The linter verifies.

### Code blocks

- Fenced with language: ` ```python ` (not bare ` ``` `).
- Above OR below the block, the file:line pair as an HTML comment: `<!-- src/foo.py:42 -->`.
- Tests cross-referenced as the executable spec: `Test: tests/test_foo.py::test_bar`.

### Cross-vault links

- Code → concept: `[[../wiki/concept-x]]` (general wiki page).
- Concept → code: `[[../code/wiki/module-x]]` (general wiki side adds this back-link when implementation begins).
- This bidirectional pattern is how the two wikis stay coherent. Either side may be the source of truth depending on which moved last; the linter flags mismatches.

### Examples manifest

`code/wiki/examples/manifest.md` lists every example with its target file, run command, expected output. An example page references its manifest entry by id.

### Tags

- **Layer:** `layer/service`, `layer/data`, `layer/ui`, etc. (project-specific.)
- **Status:** `status/wip`, `status/stable`, `status/deprecated` (same vocab as general wiki).
- **Coverage:** `coverage/tested` or `coverage/untested` (code-wiki-only; the linter flags `status/stable` + `coverage/untested` as a contradiction).

### Standard vault files

| File | Purpose |
|---|---|
| `code/wiki/index.md` | Module index grouped by layer. |
| `code/wiki/snapshot-manifest.md` | Last snapshot from outer wiki: timestamp, git SHA, list of imported pages. Maintained by `code-wiki-snapshotter`. |
| `code/wiki/examples/manifest.md` | Examples registry. |
| `code/wiki/adrs/` | Subfolder for ADRs (one file per decision). |

### Domain-specific skeptical checks

1. Cited `src/foo.py:42-58` must exist at `source_sha`. Stale pages → linter flags.
2. Code block declares its language; bare ` ``` ` is rejected.
3. Cross-vault link target exists in the corresponding vault.
4. `status/stable` + `coverage/untested` is a contradiction — code-wiki-linter flags.
5. ADR pages must list ≥2 alternatives considered; "no alternatives" usually means the decision wasn't really made.

### Outputs (delta)

- Schema artifact (`schemas/code-page.frontmatter.json`).
- Per-type template page (5 templates: module, api, adr, example, architecture).
- Examples manifest spec.
- Cross-vault link convention doc.
- Risk register entries prefixed `R-SHAPE-C-*` for shape violations.

### Risk-prefix taxonomy

`R-SHAPE-C-*` — code-wiki shape violations.

### Consults

`obsidian-compat-validator` for underlying validation.

### Consulted by

`wiki-updater` (code-side writes), `wiki-linter`, `code-wiki-snapshotter`, `project-wiki-orchestrator`.

### Out of scope

General wiki shape (`obsidian-wiki-shape`) · capturing git SHA at write time (`wiki-updater` does that) · running code examples (the manifest is the spec; execution is a separate concern).
