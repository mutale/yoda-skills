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
| `/init` | Detect existing conventions and artifacts, classify every file, migrate any existing wiki, write a project-specific `CLAUDE.md` with the lean-wiki doctrine baked in. Dry-run by default. |
| `/sync` | Refresh `index.md` and `log.md` against the vault. Lint passes here. |
| `/go-to-code` | Snapshot outer `wiki/` into `code/wiki/`. Conflict file on collision. |
| `/lint` | Audit a vault for conformance — schema, broken links, orphans, contradictions, stale SHA, plus lean-wiki bloat (long pages, stubs, defensive padding, near-duplicates). Report-only. |
| `/promote` | Refine an `output/` artifact into a wiki candidate via `wiki-curator`, then commit on user approval. |
| `/prune` | Periodic bloat sweep — propose compactions per finding, apply on approval. Run when the vault exceeds ~50 pages. |
| `/resolve <issue>` | Post-resolution compaction — find pages bloated during the investigation, replace verbose body with a short summary, archive detail to `output/<date>-resolved-<issue>/`. |
| `/status` | Show project state — root uniformity, classification confidence, last sync, open conflicts. |

## Concept

Borrowed and extended from Andrej Karpathy's LLM Wiki pattern:

- **`raw/` is immutable** — sources never get rewritten.
- **`wiki/` is the curated knowledge graph** — Obsidian vault with YAML frontmatter, footnote citations, status tags, `[[wikilinks]]`.
- **`log.md` is append-only** — every operation logged for provenance.
- **`output/` separates production from curation** — Claude generates into `output/`; the user blesses what gets promoted to `wiki/`.
- **`code/wiki/` is a snapshot vault** — implementation-time baseline; outer `wiki/` keeps churning, code-side wiki is stable per snapshot.

## Skills (15)

```
Layer 3 (orchestrator):
    project-wiki-orchestrator               /init, /sync, /go-to-code, /status, /lint,
                                            /promote, /prune, /resolve

Layer 2 (cross-cutting):
    dual-platform-adapter                   Cowork ↔ Code differences
    file-move-safety                        dry-run + undo log
    obsidian-compat-validator               YAML, [[links]], filename rules

Layer 1 (domain experts):
    obsidian-wiki-shape                     general vault spec; includes lean-wiki doctrine
    code-wiki-shape                         code vault spec
    wiki-updater                            chat → vault (default target: output/; wiki/ only via curator)
    wiki-curator                            refines a draft into a wiki-ready candidate — applies
                                            lean-wiki principles at write time; mandatory gate
    wiki-linter                             conformance audit, incl. bloat detection
    wiki-pruner                             active compaction — post-resolution + periodic sweep
    wiki-migrator                           existing wiki content → this structure
    project-convention-migrator             existing governance → this structure
    code-wiki-snapshotter                   outer wiki → code/wiki on /go-to-code
    session-history-reader                  transcripts + project memory

Layer 0 (foundation):
    project-artifact-classifier             input / output / wiki / code (with evidence + confidence)
```

### Three policies that make `wiki/` worth opening in Obsidian

1. **Default-to-output** — Everything Claude generates lands in `output/` first. No promiscuous writes to `wiki/`.
2. **Curate-to-wiki** — Entries reach `wiki/` only through `wiki-curator`: strip cruft, resolve citations, add `[[wikilinks]]`, pick a name and tags, write a real summary. User reviews the candidate. No path around the curator.
3. **Keep the wiki lean** — codified as the lean-wiki doctrine in `obsidian-wiki-shape` and enforced by curator, linter, and pruner:
   - MOC tables beat stub pages.
   - Pages stay under ~150 lines.
   - No defensive padding ("Wave 2 stub", "TBD").
   - Citations point at `raw/`, not at internal repetition.
   - One page per CONCEPT, not per ARTIFACT.
   - During an active investigation, verbose detail (logs, traces, exploration notes) is OK; **once the issue is resolved**, `/resolve <issue>` compacts the page to a short summary and archives the detail to `output/<date>-resolved-<issue>/`.

The plugin's `/init` writes a `CLAUDE.md` that bakes these policies in — at the plugin level, not invented per-project. Every new project starts coherent.

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
