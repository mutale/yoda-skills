---
name: dual-platform-adapter
description: Abstracts over differences between Claude Code (CLI/local, JSONL transcripts, subagents, Bash) and Claude Cowork (web, AskUserQuestion forms, different session storage, no subagents). Triggers whenever any project-wiki skill needs to read the filesystem, read session history, prompt the user, or invoke a slash command. Single source of truth for platform-conditional behavior; workers never hard-code platform assumptions.
---

## Inheritance
**Domain:** dual-platform-adapter
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

User wants ONE plugin that works on Code and Cowork. Without an adapter, every worker would hard-code platform branches and the federation would degrade as one platform evolves. The adapter is the only place that knows "we're on Code" vs. "we're on Cowork."

### Detection

| Signal | Code | Cowork |
|---|---|---|
| Bash tool available | yes | no |
| Subagents (`Agent` tool) | yes | no (varies) |
| AskUserQuestion | deferred | native form |
| `~/.claude/projects/` accessible | yes | no |
| Web fetch as a primitive | needs tool load | yes |
| Slash command surface | yes | varies |

Detection happens once per workflow and is cached for the run.

### Capability matrix the adapter exposes to workers

| Capability | Code shim | Cowork shim |
|---|---|---|
| `read_session(slug)` | parse JSONL from `~/.claude/projects/<slug>/*.jsonl` | call Cowork session API (research) |
| `read_memory(slug)` | read `~/.claude/projects/<slug>/memory/` | read Cowork project memory |
| `write_file(path, content)` | `Write` tool | `Write` tool (same) |
| `move_file(src, dst)` | `Bash mv` | filesystem API (varies) |
| `ask_user(question, options)` | render in chat or load `AskUserQuestion` | native `AskUserQuestion` |
| `run_subagent(prompt)` | `Agent` tool | unavailable → fail gracefully |
| `dry_run_apply(diff)` | print diff, await confirm | render `AskUserQuestion` with diff |

### Domain-specific skeptical checks

1. **Don't assume current behavior is stable.** Both platforms evolve fast — detection must be runtime, not baked-in.
2. **Surface-specific operations** (subagents on Code, `AskUserQuestion` natively on Cowork) must **fail gracefully**, not crash. Return a sentinel + risk-register entry; let the caller decide.
3. **Same project → same dry-run plan on both surfaces.** A regression test (run /init dry-run on Code, then on Cowork, diff the plans) catches adapter drift.
4. **Cowork session storage is partially known.** Workers calling `read_session` on Cowork must accept degraded mode.

### Outputs (delta)

- Platform-detection result with confidence.
- Capability matrix for the current run.
- Risk register entries prefixed `R-PLAT-*` for any degraded capability.

### Risk-prefix taxonomy

`R-PLAT-*` — platform capability / version drift risks.

### Consults

Nothing — this is a leaf shim.

### Consulted by

Every Layer-1 skill that touches the filesystem, session history, or asks the user a question.

### Out of scope

Any actual workflow logic — the adapter only exposes capabilities. Decisions about *what* to do with them live in the calling skill.
