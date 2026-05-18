# project-wiki

Karpathy-style LLM Wiki applied across every Claude Code and Claude Cowork project. One canonical layout, one Obsidian-compatible knowledge base, clean takeover of existing conventions, optional snapshot to a code-side wiki when ideation transitions to implementation.

## Canonical project layout

```
<project-root>/
├── raw/          immutable user inputs (PDFs, notes, screenshots, briefs)
├── output/       every Claude-generated artifact, organized by date+session
├── wiki/         Obsidian vault — concepts, decisions, open questions
│   ├── index.md
│   ├── log.md          (append-only operation log)
│   ├── questions.md    (open-questions backlog)
│   ├── decisions.md    (ADR-lite)
│   └── <concept>.md
├── code/         implementation tree (when you /go-to-code)
│   └── wiki/     snapshotted wiki + code-specific docs (modules, APIs, examples, ADRs)
├── CLAUDE.md     per-project instructions, written from a template on /init
└── README.md
```

Nothing else at the project root. Floating files get bucketed or flagged.

## Slash commands

| Command | What it does |
|---|---|
| `/init` | Detect existing conventions and artifacts, classify every file, migrate any existing wiki, write a project-specific `CLAUDE.md`. Dry-run by default. |
| `/sync` | Refresh `index.md` and `log.md` against the vault. Lint passes here. |
| `/go-to-code` | Snapshot outer `wiki/` into `code/wiki/`. Conflict file on collision. |
| `/lint` | Audit a vault — broken links, orphans, contradictions, stale SHA, schema violations. Report-only. |
| `/promote` | Move a vetted artifact from `output/` to `wiki/`. Per-artifact user blessing required. |
| `/status` | Show project state — root uniformity, classification confidence, last sync, open conflicts. |

## Concept

Borrowed and extended from Andrej Karpathy's LLM Wiki pattern:

- **`raw/` is immutable** — sources never get rewritten.
- **`wiki/` is the curated knowledge graph** — Obsidian vault with YAML frontmatter, footnote citations, status tags, `[[wikilinks]]`.
- **`log.md` is append-only** — every operation logged for provenance.
- **`output/` separates production from curation** — Claude generates into `output/`; the user blesses what gets promoted to `wiki/`.
- **`code/wiki/` is a snapshot vault** — implementation-time baseline; outer `wiki/` keeps churning, code-side wiki is stable per snapshot.

## Skills (14)

```
Layer 3 (orchestrator):
    project-wiki-orchestrator               /init, /sync, /go-to-code, /status, /lint, /promote

Layer 2 (cross-cutting):
    dual-platform-adapter                   Cowork ↔ Code differences
    file-move-safety                        dry-run + undo log
    obsidian-compat-validator               YAML, [[links]], filename rules

Layer 1 (domain experts):
    obsidian-wiki-shape                     general vault spec
    code-wiki-shape                         code vault spec
    wiki-updater                            chat → vault (default target: output/; wiki/ only via curator)
    wiki-curator                            refines a draft into a wiki-ready candidate — the mandatory
                                            gate between output/ and wiki/; no writes to wiki/ bypass this
    wiki-linter                             conformance audit
    wiki-migrator                           existing wiki content → this structure
    project-convention-migrator             existing governance → this structure
    code-wiki-snapshotter                   outer wiki → code/wiki on /go-to-code
    session-history-reader                  transcripts + project memory

Layer 0 (foundation):
    project-artifact-classifier             input / output / wiki / code (with evidence + confidence)
```

### Default-to-output, curate-to-wiki

Two operating policies make `wiki/` worth opening in Obsidian:

1. **Everything Claude generates defaults to `output/`** — drafts, analyses, ad-hoc artifacts. No promiscuous writes to `wiki/`.
2. **`wiki/` entries go through `wiki-curator` first** — strip cruft, resolve citations, add `[[wikilinks]]`, pick a name and tags, write a real summary. User reviews the candidate before it commits. The curator is the gate; no path around it.

`wiki-linter` is the conformance check that runs against the vault on demand or as part of `/sync` — it verifies the vault still follows the rules the shape skills declare.

All inherit from `skill-architect`'s foundation abstracts (`input-scrutiny`, `artifact-scrutiny`, `orchestrator`, `risk-register-manager`). This is a **new domain pattern** (project-knowledge-management) — once a second concrete instance exists, the pattern should be promoted to a domain abstract in skill-architect.

## Install

```
/plugin marketplace add github:mutale/yoda-skills
/plugin install project-wiki@yoda-skills
/reload-plugins
```

Requires `skill-architect@>=0.3.0` (installed automatically as a dependency).

## Status

- 0.1 — Claude Code support. Cowork support is partial; session storage location on Cowork is the open research item (see `session-history-reader` SKILL).
- Designed but not yet promoted to a skill-architect domain abstract. Will earn its seat when a second project-knowledge-management instance ships.
