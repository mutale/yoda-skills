---
name: project-convention-migrator
description: One-time takeover of an existing project's conventions — folder semantics (inputs/, outputs/, artifacts/, notes/, etc.) and the governing instructions that describe them in CLAUDE.md, .cursorrules, .windsurfrules, AGENTS.md, STRUCTURE.md, and project long-term memory. Detects, maps semantically (inputs/ → raw/, outputs/ → output/, notes/ → wiki/ or legacy bucket), and rewrites every governing reference to point at the new structure. Triggers during /init on any project with past Claude history, agent-rule files, or convention docs. Produces a takeover report BEFORE applying anything; never overrides past instructions silently. Distinct from wiki-migrator (which handles wiki content) — this skill handles GOVERNANCE.
---

## Inheritance
**Domain:** project-convention-migrator
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

The user has projects where they've previously told Claude things like "inputs is immutable, all artifacts go to outputs, wiki updates after output." Those instructions live in different places per project — sometimes in `CLAUDE.md`, sometimes in project long-term memory, sometimes only in old session transcripts. If `/init` ignores them, the takeover silently overrides past commitments and the user is surprised later when old patterns reappear.

This skill differs from `wiki-migrator`:

| | wiki-migrator | project-convention-migrator |
|---|---|---|
| Moves | Wiki *content* | Governance (folder semantics + their declarations) |
| Reads | Existing wiki pages | CLAUDE.md, rule files, project memory, convention docs |
| Writes | New wiki pages | Updated CLAUDE.md, updated memory, deprecated old rule files |
| Failure mode | Ugly wiki | Future sessions misled by stale instructions |

### Detection sources (T1)

1. **`CLAUDE.md` at project root** — always read first, the canonical place for project-specific instructions.
2. **Agent rule files** — `.cursorrules`, `.windsurfrules`, `AGENTS.md`, `.aider.conf.yml`. Each is a source-of-truth for a different tool; harmonize.
3. **Project long-term memory** — via `session-history-reader`, read `~/.claude/projects/<slug>/memory/` (Code) and the Cowork equivalent. Extract recorded instructions about structure.
4. **Convention documents** — top-level `STRUCTURE.md`, `CONVENTIONS.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`. Mine for folder-semantic declarations.
5. **Folder names that imply convention** — `inputs/`, `outputs/`, `artifacts/`, `notes/`, `journal/`, `docs/`, `wiki/`, `_drafts/`. The existence is evidence; the *semantics* needs declaration to confirm.

### Semantic mapping rules (defaults; user can override)

| Old declared semantic | Map to | Notes |
|---|---|---|
| `inputs/` declared immutable | `raw/` | Hard map. |
| `outputs/` or `artifacts/` | `output/` | Hard map. |
| `notes/` or `journal/` (free-form prose) | `wiki/` if Obsidian-shaped, else `output/<date>-legacy-notes/` | Soft; verify with user. |
| Old `wiki/` (non-Karpathy) | `output/<date>-legacy-wiki/` + import into new `wiki/` via `wiki-migrator` | The user explicitly endorsed this fallback. |
| `docs/` | Leave in place if `code/` exists and `docs/` lives under it; otherwise `wiki/` | Project-specific. |
| `src/`, `lib/`, `pkg/`, package manifests | Move under `code/` | Code is code; the plugin doesn't restructure it internally. |

When old semantics don't match any rule, surface to user via takeover report; never guess.

### Takeover report (produced BEFORE any move)

```markdown
# Takeover report — <project-name> — <date>

## Detected conventions

| Source | Convention | Confidence |
|---|---|---|
| CLAUDE.md:23 | "inputs/ is immutable, never modify" | high |
| ~/.claude/projects/<slug>/memory/structure.md | "outputs go to outputs/, wiki updates after each output" | high |
| folder presence | `notes/` exists | medium |
| .cursorrules:5 | "use docs/ for all documentation" | high |

## Proposed mapping

| From | To | Action |
|---|---|---|
| inputs/ | raw/ | Rename folder + rewrite references in CLAUDE.md, .cursorrules |
| outputs/ | output/ | Rename folder + rewrite references |
| notes/ | wiki/ (if Obsidian-shaped) or output/2026-05-18-legacy-notes/ | Pending wiki-migrator format check |
| docs/ (per .cursorrules) | wiki/ (decommission .cursorrules rule) | Replace agent-rule reference |

## Files that will be rewritten

- CLAUDE.md (5 references to old folder names)
- .cursorrules (1 reference to docs/)
- project memory: structure.md (will be archived; replaced by project-wiki canonical layout)

## Apply? [yes / no / partial / ask]
```

### Climb policy (specialization of input-scrutiny)

- T2 (user): mandatory before any apply. Takeover report is never auto-approved.
- T3: N/A.

### Validation checklist (specialization of artifact-scrutiny)

Before applying:

1. Every detected convention is in the report. No silent skips.
2. Every rewrite target is identified (which file gets which edit).
3. The new CLAUDE.md is well-formed and consistent with the canonical layout.
4. Project-memory updates are explicit and reversible.
5. Agent rule files have a deprecation note added rather than being deleted (preserve evidence of past intent).

### Domain-specific skeptical checks

1. **Don't assume "inputs/" means raw without a declared semantic.** Just because the folder is named "inputs" doesn't mean the user declared it immutable. Read the declaration.
2. **Two sources disagree** (CLAUDE.md says X, memory says Y) → surface the conflict, don't pick.
3. **Some "conventions" are actually project-specific code** — a `scripts/` folder containing build tooling is genuinely code, not a convention. Flag, don't bucket.
4. **Stale memory** — memory may record an old convention the user no longer follows; cross-check against current CLAUDE.md and current folder state.
5. **Multi-tool projects** with both `.cursorrules` and `.windsurfrules` may have conflicting rules; surface, don't silently harmonize.

### Outputs (delta)

- **Takeover report** (above format).
- **Rewritten files** on user approval: updated `CLAUDE.md`, updated agent rule files (with deprecation notes for replaced rules), updated project memory entries.
- **Undo log** entry per rewrite.
- **Deprecation archive** at `<project>/.project-wiki/legacy-instructions/` — copies of original rule files / memory entries before rewrite.
- Risk register entries prefixed `R-CONV-*` (convention takeover risks).

### Risk-prefix taxonomy

`R-CONV-*` — convention / governance takeover risks.

### Consults

`session-history-reader` (project memory + transcripts), `file-move-safety` (for any folder renames triggered by the mapping), `wiki-migrator` (when an old wiki is part of the takeover).

### Consulted by

`project-wiki-orchestrator` — runs FIRST in the `/init` flow, before the classifier, because declared semantics inform the classifier's bucketing.

### Out of scope

Wiki content (`wiki-migrator`) · root layout enforcement (orchestrator's job) · classifying individual files (`project-artifact-classifier`).
