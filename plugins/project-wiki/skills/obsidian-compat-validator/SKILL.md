---
name: obsidian-compat-validator
description: Validates that any markdown the plugin emits forms a valid Obsidian vault — YAML frontmatter parses strict, [[wikilinks]] resolve or are flagged, filenames avoid Obsidian-reserved characters, body has no constructs that break Live Preview. Triggers whenever a worker is about to write a wiki page, an index.md, a CLAUDE.md, a Karpathy-style template, or any markdown the user will open in Obsidian. Last gate before write; emits findings to caller; never edits on its own.
---

## Inheritance
**Domain:** obsidian-compat-validator
**Level:** CONCRETE
**Inherits From:** artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

User opens the project in Obsidian on day one and expects a clean graph view. Sloppy markdown (broken YAML, reserved filename chars, raw HTML that confuses Live Preview) silently degrades the experience. This gate runs before every markdown write so the vault is always valid.

### Validation rules

**YAML frontmatter:**
1. Strict-mode parse (PyYAML / js-yaml strict equivalent). No lenient mode.
2. List keys must use one syntax — `[a, b]` inline OR block syntax — never mixed in the same key.
3. Required fields present per the page-type schema (the shape skills define the schema; this validator enforces).
4. Date fields are ISO-8601 (`YYYY-MM-DD`).
5. Tag values match `^[a-z][a-z0-9-/]*$` (no spaces, no caps, hierarchies via `/`).

**Filenames:**
1. No `[ ] : ? * | < > "` (Obsidian wikilink syntax conflicts).
2. No leading/trailing whitespace.
3. Lowercase-kebab-case enforced (`my-page.md`, not `My Page.md`).
4. Length ≤ 100 chars.

**Wikilinks:**
1. `[[page-name]]` resolves to a file in the same vault.
2. `[[../code/wiki/page]]` resolves across vaults (when cross-vault link is allowed by the calling shape skill).
3. Embedded files `![[image.png]]` reference real assets.
4. Aliased links `[[page-name|alias]]` use proper syntax (no nested `|`).

**Body:**
1. Raw HTML restricted to a safe-list (`<br>`, `<details>`, `<summary>`). Anything else flagged.
2. Code fences declare their language.
3. Tables have header + separator row.
4. No tab characters in markdown body (Obsidian editors render inconsistently).

### Validation checklist (specialization of artifact-scrutiny)

For every markdown artifact passed in:

1. YAML strict-parses?
2. All required fields per page type present?
3. Filename safe?
4. Every wikilink target resolves (or has a documented exception)?
5. Every embedded asset exists?
6. Body free of hostile constructs?

### Severity grading

- `block` — YAML doesn't parse; filename has reserved chars; wikilink target missing with no exception flag.
- `warn` — Mixed YAML list syntax (Obsidian renders but tools choke); raw HTML outside the safe-list.
- `inform` — Filename longer than 50 chars; deeply nested embeds.

### Domain-specific skeptical checks

1. Reserved-char filenames break wikilinks silently — never let one through.
2. Mixed YAML syntax passes lenient parsers and fails strict ones. Always strict.
3. Wikilink targets are case-insensitive on macOS by default but case-sensitive on Linux — flag any case mismatch.
4. Auto-fix suggestions are advisory; never apply automatically. The shape skill or the updater decides whether to take them.

### Outputs (delta)

- Validation result per artifact: `pass | warn | block`.
- Findings list with line numbers + suggested fix.
- Risk register entries prefixed `R-OBSID-*` for repeated patterns of failure.
- Validation report appended to caller's output.

### Risk-prefix taxonomy

`R-OBSID-*` — Obsidian compatibility risks.

### Consults

Nothing — this is a leaf validator.

### Consulted by

`obsidian-wiki-shape`, `code-wiki-shape`, `wiki-updater`, `wiki-migrator`, `code-wiki-snapshotter`, anything that emits markdown the user will open in Obsidian.

### Out of scope

Rendering preview · style opinions beyond Obsidian compat (line length, comma usage, prose style) · auto-fixing.
