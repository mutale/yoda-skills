---
name: code-wiki-snapshotter
description: On /go-to-code (or /start-coding), snapshots the current state of the outer wiki/ (concepts, decisions, resolved questions) into code/wiki/ as the implementation-time baseline. One-way sync (outer → inner). Conflict policy — if code/wiki/ has local edits not present in outer, halt and write a conflict file; never silent overwrite. Triggers on the /go-to-code or /start-coding slash commands, on "go to code", "start coding", "we're ready to build", "snapshot the wiki for code", "freeze the wiki for implementation".
---

## Inheritance
**Domain:** code-wiki-snapshotter
**Level:** CONCRETE
**Inherits From:** artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Cowork-side ideation and Code-side implementation evolve on different cadences. The outer `wiki/` is the source of truth for *what we're building and why* — it churns as ideas evolve. The inner `code/wiki/` is the source of truth for *what we've built* — it should be stable per snapshot, not constantly mutating. Snapshots give a clean "now we're building" moment without forcing every wiki edit to ripple into the code tree.

### Inputs

- Outer `wiki/` vault contents.
- Existing `code/wiki/` (may be absent — first snapshot).
- Last snapshot manifest at `code/wiki/snapshot-manifest.md` (may be absent).

### Snapshot algorithm

1. **Compute delta** between outer `wiki/` and the last snapshot manifest.
   - New pages → import.
   - Modified pages (frontmatter `updated:` newer than manifest entry) → import overwriting *only if no local edits in code/wiki/ on that page* (see step 3).
   - Removed pages → DO NOT remove from `code/wiki/`; the snapshot is import-only. Code-side history is preserved.
   - `wiki/questions.md` entries with `status: resolved` → import the resolution as a `concept` page; leave `open` entries behind.
   - `wiki/decisions.md` entries → import each as an `adr` page under `code/wiki/adrs/`.

2. **Adapt format on import.** A `wiki/concept-x.md` becomes `code/wiki/concept-x.md` with frontmatter rewritten to match `code-wiki-shape` (add `source_sha: <current-HEAD>`, add `coverage/untested` by default, set `status/needs-review`).

3. **Detect local edits.** For every page that exists in both vaults:
   - Compare `code/wiki/<page>.md` content vs. the last-snapshot version of `wiki/<page>.md`.
   - If `code/wiki/` version was modified locally → **conflict**.
   - On conflict: halt the entire snapshot, write `code/wiki/CONFLICT-<timestamp>.md` listing every conflicting page with both versions, and emit a risk register entry. The user resolves manually.

4. **First snapshot** (no manifest exists): import everything from outer `wiki/`, mark every imported page `status/needs-review` and `coverage/untested`. Write the first manifest.

5. **Update manifest** — `code/wiki/snapshot-manifest.md` is rewritten with the new timestamp, current HEAD SHA, and per-page hash of the imported version. This is what the next snapshot will diff against.

### Validation checklist (specialization of artifact-scrutiny)

Before applying the snapshot:

1. Every page to be written validates against `code-wiki-shape`.
2. Every page passes `obsidian-compat-validator`.
3. Conflict detection ran on every page that exists in both vaults.
4. `snapshot-manifest.md` will reflect the new state accurately.
5. The undo log captures the inverse op for every file written.

### Domain-specific skeptical checks

1. **One-way sync.** This skill never writes back to outer `wiki/`. If the user expects round-trip, warn explicitly. Round-trip (code → outer wiki) is a separate, deferred feature.
2. **Local edits in `code/wiki/` always halt.** Never overwrite, no matter how "obvious" the merge looks. The conflict file is the deliverable.
3. **First snapshot is baseline, not diff.** Treat every page as new.
4. **Status tags get downgraded on import.** A `status/stable` general-wiki page becomes `status/needs-review` in code wiki — because the code side hasn't validated the page against actual implementation yet.
5. **Don't import `output/`-style transient artifacts** — only pages that exist in `wiki/`. The output bucket stays out of code wiki.

### Outputs (delta)

- **Refreshed `code/wiki/` pages.**
- **Updated `snapshot-manifest.md`** (timestamps, SHAs, per-page hashes).
- **Conflict file** at `code/wiki/CONFLICT-<timestamp>.md` if any conflicts detected; the snapshot is otherwise aborted.
- Risk register entries prefixed `R-SYNC-*`.
- Validation findings per inherited artifact-scrutiny.

### Risk-prefix taxonomy

`R-SYNC-*` — snapshot / sync risks.

### Consults

`code-wiki-shape` (frontmatter rewrite, page type mapping), `obsidian-compat-validator`, `file-move-safety` (every write goes through the safety layer).

### Consulted by

`project-wiki-orchestrator` — the `/go-to-code` and `/start-coding` commands.

### Out of scope

Writing new code-wiki content from chat or code (`wiki-updater`) · merging code-wiki changes back to outer wiki (deferred; one-way only in 0.1) · running tests or extracting documentation from code (separate concern).
