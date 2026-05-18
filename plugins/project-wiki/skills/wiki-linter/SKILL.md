---
name: wiki-linter
description: Audits a wiki vault for conformance to the project-wiki rules — frontmatter schema (via obsidian-wiki-shape or code-wiki-shape), contradictions between pages, orphan pages (no inbound [[wikilinks]]), broken wikilinks (target missing), citations pointing to nonexistent raw/ files, stale git-SHA pages in code wiki, contradictory tag combinations like status/stable + coverage/untested. Conformance is the point — every check verifies that the vault still follows what the shape skills declare it should be. Triggers on /lint, when the user asks "audit the wiki", "check the wiki conforms", "are we following the rules", "check for broken links", "wiki health check", "find outdated pages", "wiki review". Report-only — never auto-fixes; emits a numbered finding list for the orchestrator or user to act on.
---

## Inheritance
**Domain:** wiki-linter
**Level:** CONCRETE
**Inherits From:** artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Wikis decay without active maintenance — old pages contradict new sources, links rot as pages get renamed, citations point at files that have moved. The updater can't catch these because they emerge over time, not at write time. Lint is the periodic forcing function. Separated from updater because of different cadence (occasional, on-demand) and different evidence base (whole vault, not one delta).

### Inputs

- Vault path (`wiki/` or `code/wiki/`).
- For code-wiki lint: current `git rev-parse HEAD`.
- The shape skill for the vault being linted (`obsidian-wiki-shape` or `code-wiki-shape`).
- `raw/` directory listing (general lint) / source tree listing (code lint).

### Audit checks

**Conformance to schema:**

1. **Frontmatter schema** — every page's YAML conforms to the shape skill's schema. Per-page pass/fail.
2. **Wikilinks resolve** — every `[[wikilink]]` targets an existing page in the same vault, or a cross-vault link with a valid target.
3. **Embeds resolve** — every `![[asset]]` references a real file in the vault.
4. **Citations resolve** — every `[^src]` footnote references a real file under `raw/` (general) or a real source range at the recorded SHA (code).
5. **Stale SHA (code wiki only)** — pages whose `source_sha` is older than current HEAD AND whose `source_files` have changed since.
6. **Tag contradictions** — `status/stable` + `coverage/untested` (code wiki). `status/wip` + `status/stable` (any wiki — multiple status tags is a bug).

**Conformance to lean-wiki principles (per `obsidian-wiki-shape`):**

7. **Long pages** — pages over 150 lines. Candidate for split into MOC + children, or `## Details (optional reading)` collapse.
8. **Stub pages** — pages with frontmatter + "Related pages" but body < 30 lines. Candidate for demote-to-MOC-row.
9. **Defensive padding** — pages whose body matches `^(TBD|Wave \d+ stub|to be ingested|placeholder|coming soon)` patterns. Candidate for delete (MOC row only).
10. **Near-duplicates** — pages with same primary topic tag and high content overlap (heuristic, ≥70%). Candidate for merge.
11. **Long inline log/trace blocks** — code blocks > 50 lines inside otherwise-normal pages. Candidate for extract to `output/` + link.
12. **Resolved-issue bloat** — pages tagged `issue/<name>` where the issue is marked resolved in `decisions.md` or in a closed PR, but the page still carries verbose logs. Candidate for `/resolve <issue>` (Mode A of `wiki-pruner`).

**Graph health:**

13. **Orphan pages** — zero inbound `[[wikilinks]]` from anywhere in the vault. Orphan ≠ delete-candidate; some pages are intentional entry points. Flag for review.
14. **Missing concept pages** — a `[[wikilink]]` to `[[concept-x]]` where no `concept-x.md` exists; should be a stub at minimum (or the link rewritten).
15. **Internal contradictions** — heuristic: two pages tagged same topic with conflicting key claims.

### Severity grading (specialization of artifact-scrutiny)

- `block` — Frontmatter doesn't parse; required fields missing.
- `warn` — Broken wikilinks; stale code-wiki SHA; tag contradictions; broken citations; resolved-issue bloat; defensive padding.
- `inform` — Orphan pages; missing concept stubs; potential contradictions; long pages; stub pages; near-duplicates; long inline log blocks.

### Domain-specific skeptical checks

1. **Don't auto-fix.** Findings are advisory. The orchestrator decides whether to route fixes back to the updater.
2. **Orphan ≠ delete-candidate.** Entry points are intentional orphans.
3. **Contradictions can be valid POVs.** Two pages may legitimately hold different views of the same topic; flag for user review, don't merge.
4. **Stale SHA on code-wiki** is informative, not error — code evolves, doc lag is expected up to a point. Flag pages whose SHA delta exceeds a configurable threshold (default: 50 commits).

### Outputs (delta)

- **Numbered audit report** with one entry per finding: `id | severity | check | page | detail | suggested-fix`.
- **Suggested fixes** are textual, never executable diffs — the user or the orchestrator decides whether to apply.
- Risk register entries prefixed `R-LINT-*` for systemic issues (e.g., 50+ broken wikilinks → pattern of rename without update).
- Validation findings list per the inherited artifact-scrutiny contract.

### Risk-prefix taxonomy

`R-LINT-*` — wiki health risks discovered at lint time.

### Consults

`obsidian-wiki-shape` and `code-wiki-shape` (for the schema and structural rules), `obsidian-compat-validator` (for the underlying frontmatter parsing).

### Consulted by

`project-wiki-orchestrator` (the `/lint` command).

### Out of scope

Making fixes (user-requested → orchestrator → updater) · proposing new content · style review beyond schema compliance.
