---
name: wiki-migrator
description: One-time bulk import of an existing wiki (Karpathy template, plain Obsidian vault, raw markdown notes folder, Notion export) into the project-wiki structure. Detects format by signature (presence of .obsidian/ folder → Obsidian; UUID filenames + Untitled.md → Notion; structured raw/+wiki/+log.md → Karpathy; bare *.md → plain). Produces a dry-run migration plan; on approval rewrites pages to the schema, fixes link conventions, logs every change. Triggers during /init when an existing wiki is detected, when the user says "migrate my wiki", "import this vault", "we already have a wiki here", "convert this Notion export". Distinct from project-convention-migrator (which handles governance) — this skill handles wiki CONTENT only.
---

## Inheritance
**Domain:** wiki-migrator
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

Many of the user's projects already have wikis or note collections. Bulk reshape is distinct from continuous updates — different cadence, different blast radius, different evidence base. Without a dedicated migrator, the updater would be tempted to handle import case-by-case, and conventions would diverge by source format.

### Format detection (T1 — signature-based)

| Signature | Format | Action |
|---|---|---|
| `.obsidian/` folder present | **Obsidian vault** | Direct conversion; preserve folder structure; rewrite frontmatter to schema; normalize tags. |
| Filenames like `Untitled (uuid).md` or `*.html` with `<meta name="notion-*">` | **Notion export** | Strip Notion artifacts; resolve `Notion-style` databases to a list of pages or a single index; rewrite UUIDs to kebab-case. |
| Folder structure `raw/` + `wiki/` + `wiki/log.md` | **Karpathy template** | Near-direct adoption; preserve `raw/`, `wiki/log.md`; rewrite `wiki/` pages from body-Summary-block to YAML frontmatter. |
| `*.md` files without any of the above | **Plain markdown** | Best-effort: infer title from first H1, scan for `[[wikilinks]]`, generate frontmatter stubs; mark every migrated page `status/needs-review`. |
| `*.md` plus a `_book/` or `SUMMARY.md` | **GitBook / mdBook** | Treat as plain markdown; preserve `SUMMARY.md` as `index.md` if present. |

If the format doesn't match any of the above, emit `unrecognized-format` report and ask user before proceeding.

### Migration rules

1. **`raw/` is sacred.** If source has a `raw/`-equivalent that the user declared immutable (per project-convention-migrator), copy contents to `raw/` and never modify.
2. **Non-fitting pages don't get discarded.** Pages that resist conversion (Notion databases with no obvious page-shape, broken pages, fragments) get tagged `status/needs-review` and a leftover-content report is generated for user review.
3. **Link conventions get normalized.** `./foo.md`, `[foo](foo.md)`, raw URLs, Notion `@-links` all rewrite to `[[foo]]` (target verified to exist).
4. **Every rewrite is logged** in the new vault's `log.md` and in a side `migration-log.md` so the user can see exactly what changed.
5. **Frontmatter is generated** when missing. Title from H1, summary from first paragraph, status `status/needs-review`, type `concept` by default.
6. **Citations are best-effort.** Old wikis without footnote citations get `[needs source]` markers; the linter will pick these up.

### Climb policy

- T1: signature-based format detection.
- T2: ask the user when format is ambiguous, when leftover-content is substantial, or when a destructive normalization (e.g., flattening a Notion database) would be irreversible.
- T3: N/A.

### Validation checklist (specialization of artifact-scrutiny)

Before applying the migration:

1. Dry-run plan covers 100% of source files (no silent skips).
2. Every produced page passes `obsidian-compat-validator`.
3. Every produced page conforms to `obsidian-wiki-shape`.
4. No source content is lost — items that can't migrate are surfaced in leftover-content, not dropped.
5. Link rewrites are reversible via the undo log.

### Domain-specific skeptical checks

1. **Detect by signature, not by user assertion.** A user who says "it's an Obsidian vault" but has no `.obsidian/` may be wrong.
2. **Notion exports** drop a *lot* of metadata; warn the user that block-level info will be flattened.
3. **Existing `[[wikilinks]]`** may have non-standard case or aliases; preserve the *intent* (target page) while normalizing the syntax.
4. **Old timestamps** in YAML or in Notion metadata go into `updated:` field — don't overwrite with today's date or you lose provenance.
5. **`raw/`-equivalents** can be mis-identified; if a user's `inputs/` contains Claude-generated artifacts (per classifier), warn before treating as immutable.

### Outputs (delta)

- **Dry-run migration plan** — per file: source → target → action (rewrite / copy-only / flag / skip).
- **Migration log** at `<vault>/migration-log.md` — append-only record of every change.
- **Leftover-content report** — pages that couldn't be migrated cleanly.
- **Rewritten vault** on user approval.
- Risk register entries prefixed `R-MIGRATE-W-*` (wiki migration risks).
- Validation findings per inherited artifact-scrutiny.

### Risk-prefix taxonomy

`R-MIGRATE-W-*` — wiki-content migration risks.

### Consults

`obsidian-wiki-shape`, `obsidian-compat-validator`, `file-move-safety`.

### Consulted by

`project-wiki-orchestrator` during `/init` when an existing wiki is detected.

### Out of scope

Continuous wiki updates (`wiki-updater`) · migrating code itself (the plugin doesn't touch code structure beyond placing it under `code/`) · **governance migration — CLAUDE.md, .cursorrules, project memory updates** — that's `project-convention-migrator`.
