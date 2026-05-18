---
name: file-move-safety
description: Wraps every destructive filesystem operation (move, rename, copy-over, delete, overwrite) in dry-run preview, explicit user confirmation, and append-only undo log. Hard rule — no destructive op proceeds without (1) written diff, (2) explicit user yes, (3) recorded undo step. Triggers whenever a project-wiki worker proposes to move, rename, or delete files in the user's project, or when the user asks "preview before applying", "show me what would change", "give me an undo log".
---

## Inheritance
**Domain:** file-move-safety
**Level:** CONCRETE
**Inherits From:** artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

`/init` may propose dozens of moves on a messy project. One bad move can lose user data with no recovery path. Safety must be a separate, audited concern — not a flag a worker can disable.

### Operations supported

- `move` (default for reorganization within a filesystem)
- `rename`
- `copy` (default for cross-filesystem)
- `symlink` (only on explicit caller request)
- `delete` (only with `--allow-delete` from caller; never default)
- `overwrite` (only with explicit per-file user confirmation)

### Hard rules

1. **No destructive op proceeds without all three:** (a) dry-run diff written to disk + shown to user, (b) explicit user "yes" (typed or option-selected via `AskUserQuestion`), (c) undo log entry recorded *before* the op runs.
2. **Never overwrite implicitly.** Target exists → halt and ask.
3. **Cross-filesystem ops** = copy + verify hash + delete source. Never bare rename (renames silently fail across filesystems on some platforms).
4. **Symlink loops** are detected and refused.
5. **Bulk operations** are atomic from the user's perspective — all succeed or all roll back via undo log.

### Validation checklist (specialization of artifact-scrutiny)

When a caller hands me a proposed operation set:

1. Every op has source + target.
2. No two ops target the same destination.
3. No op moves a file out of the project root unless explicitly authorized.
4. No op touches `.git/` or `.claude/` internals.
5. No op deletes without `--allow-delete`.
6. Cross-filesystem ops are flagged for copy+verify+delete substitution.

### Domain-specific skeptical checks

1. Does the target path already exist? Bulk ops can mask this.
2. Is the source under a vendored subtree (`node_modules/`, submodule)? Refuse — out of scope.
3. Are there hard-link or symlink relationships that the op would break?
4. Is the proposed move idempotent if rerun? (After successful apply, re-running should be a no-op, not a duplicate.)

### Outputs (delta)

- **Dry-run diff** — table of ops with status (ok / warn / block).
- **Confirmation prompt** — exactly what will change, in plain language.
- **Undo log** — append-only file at `<project>/.project-wiki/undo-log.jsonl` recording every applied op with timestamp + reverse-op.
- **Post-apply verification** — hash check or stat check that the move actually completed as intended.
- Findings with severity (`block` / `warn` / `inform`) per the inherited artifact-scrutiny contract.
- Risk-register entries prefixed `R-MOVE-*`.

### Risk-prefix taxonomy

`R-MOVE-*` — destructive-operation safety risks.

### Consults

Nothing — this is a leaf safety primitive.

### Consulted by

`project-artifact-classifier` (apply phase), `wiki-migrator`, `project-convention-migrator`, `code-wiki-snapshotter`, `project-wiki-orchestrator`.

### Out of scope

Deciding *what* to move — that's the caller's job. This skill never proposes moves itself, only audits and applies what's handed to it.
