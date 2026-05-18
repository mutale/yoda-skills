---
name: wiki-pruner
description: Actively compacts and prunes the wiki to keep it lean — finds pages that ballooned during an active investigation (verbose logs, exploration dumps, debug traces, full stack-trace pastes) and replaces them with a short summary once the issue is resolved, archiving the verbose detail to output/<date>-resolved-<issue>/. Also runs periodic bloat sweeps — collapse near-duplicates, demote stub pages to MOC rows, drop defensive padding (Wave-2 stubs, TBD placeholder tables, "to be ingested" notes). Triggers on /prune, /resolve <issue>, on "compact the wiki", "the issue is resolved clean up the wiki", "this debug data is no longer needed", "wiki feels bloated", "too many stub pages", "summarize and clean up", "we don't need this detail anymore".
---

## Inheritance
**Domain:** wiki-pruner
**Level:** CONCRETE
**Inherits From:** artifact-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/skills/skill-architect/abstracts/foundation/artifact-scrutiny.md
2. ../../../skill-architect/skills/skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Wikis grow. During an active investigation, it's right to dump logs, stack traces, exploration notes, and intermediate findings into a page so the user and future Claude have full context. But once the issue is resolved and confirmed, that verbose detail becomes bloat — it crowds the graph view, slows scans, and dilutes the signal-to-noise ratio that makes the wiki useful in the first place. This skill owns the *active maintenance* job: replace verbose detail with short summaries, archive the originals, and surface chronic bloat patterns across the vault.

Distinct from the linter (which audits and reports) and the curator (which gates new writes). The pruner *acts* — it proposes destructive transformations, gets user approval, and applies them.

### Two operating modes

**Mode A — post-resolution compaction** (`/resolve <issue>` or per-page invocation)

The user signals an issue is resolved. The pruner:
1. Identifies the wiki page(s) tied to the issue (via tag `issue/<name>`, via `wikilinks` from the closed issue's page, or via user-supplied page list).
2. Reads each page; categorizes content into KEEP (summary, decision, link to fix) vs. ARCHIVE (verbose logs, stack traces, exploration dumps, "tried X then Y" rabbit-holes).
3. Drafts a compacted summary page: what was the problem, what was the fix, link to the archived detail, link to the code/wiki ADR if one exists.
4. Proposes archive destination: `output/<date>-resolved-<issue>/` with the original content preserved.
5. Surfaces the proposal as a dry-run plan; user approves before any write.

**Mode B — periodic bloat sweep** (`/prune` over the whole vault)

The user runs `/prune` (manually or on schedule when the vault exceeds ~50 pages). The pruner walks the vault and flags:
- Pages over 150 lines (candidate for split or `## Details (optional reading)` collapse).
- Stub pages with frontmatter + "Related pages" but no real body — candidate for **demote to MOC row**.
- Defensive padding — pages whose body is mostly "TBD", "Wave 2", "to be ingested" — candidate for **delete**.
- Near-duplicate pages (heuristic: same topic tag, high content overlap) — candidate for **merge**.
- Long inline code blocks or log dumps inside otherwise-normal pages — candidate for **extract to `code/wiki/examples/` or `output/`**.

For each finding, proposes a transformation; user approves.

### Bloat signatures the pruner detects

| Signature | Transformation |
|---|---|
| Page > 150 lines | Split into MOC + children, OR move long body under `## Details (optional reading)`. |
| Page body < 30 lines AND only links/frontmatter | Demote to MOC row in the parent index/MOC page; delete file. |
| Body matches "TBD" / "Wave 2 stub" / "to be ingested" patterns | Delete; ensure parent MOC has a row noting "Not yet ingested." |
| Two pages with same primary tag and >70% content overlap | Propose merge; user picks canonical name. |
| Inline log/trace block > 50 lines | Extract to `output/<date>-logs/<page>.log`; replace with summary + link. |
| `[[wikilink]]` from page A to page B that's a one-line stub | Inline B's content into A; delete B; rewrite other links to A. |
| Page tagged `issue/<X>` where the issue's tracking page has `status: resolved` | Trigger Mode A on this page. |

### Compaction rules (Mode A)

When compacting a verbose investigation page into a short summary, **keep**:

1. The problem statement (what went wrong, why it mattered).
2. The fix (what we did; reference to the code if applicable as `[[../code/wiki/...]]` cross-vault link).
3. The decision rationale (why this fix vs. alternatives, if non-obvious).
4. The key evidence — 2–3 lines of log or trace that distill *why* the diagnosis is correct.
5. Provenance — link to the archived detail, link to the resolving session, link to the ADR if one exists.

**Archive** (move to `output/<date>-resolved-<issue>/`):

1. Full log dumps and stack traces.
2. Exploration notes ("tried X, didn't work; tried Y, found Z").
3. Intermediate hypotheses that were ruled out.
4. Screenshots of debugger states.
5. Verbose code-paste blocks longer than ~30 lines.

The summary page MUST link to the archived detail. Archival is preservation, not deletion.

### Validation checklist (specialization of artifact-scrutiny)

Before applying any transformation:

1. Every transformation has a corresponding undo step in the undo log.
2. Archived content is *preserved*, not destroyed — moved to `output/`, never `rm`'d.
3. The replacement summary cites the archive location.
4. Wikilinks pointing at deleted/demoted pages have been rewritten or the targets stub-redirected.
5. `log.md` entry appended documenting the compaction.

### Domain-specific skeptical checks

1. **Don't lose information.** Even when the issue is resolved, the detailed logs may matter for a similar future issue. Archive is the default, deletion is the exception (only for defensive padding and stubs).
2. **Resolution must be confirmed**, not just claimed. Before Mode A runs on an issue, verify the resolution is recorded — either in `decisions.md`, in a session note, or in a closed PR. Don't compact an issue someone is still working on.
3. **Cross-vault links survive transformations.** If a `code/wiki/` ADR points at the verbose investigation page, the pruner updates the ADR's link to the new summary page (not the archived detail), and adds the archive link as a secondary reference.
4. **Stub vs. intentional brevity.** Some pages are short on purpose (glossary entries, simple definitions). The pruner distinguishes by checking whether the page is referenced by ≥1 other page (intentional) or none (stub-candidate).
5. **Near-duplicate detection is heuristic.** Always propose, never auto-merge. Two pages may legitimately cover overlapping ground from different angles.

### Outputs (delta on top of inherited artifact-scrutiny)

- **Bloat report** — for `/prune`: table of findings with proposed transformation, severity, file count affected.
- **Compaction proposal** — for `/resolve`: per-page draft of compacted summary + archive plan, presented as dry-run.
- **Archive manifest** at `output/<date>-resolved-<issue>/manifest.md` — what was archived, why, where the summary lives.
- **Updated wiki pages** on approval (summaries replace verbose bodies; stubs deleted; MOC rows added).
- **`log.md` entries** for every applied transformation.
- Risk register entries prefixed `R-PRUNE-*`.

### Risk-prefix taxonomy

`R-PRUNE-*` — pruning / compaction risks (information loss, broken links, premature compaction).

### Consults

`obsidian-wiki-shape` and `code-wiki-shape` (for the lean-wiki principles + page-format rules), `wiki-linter` (read-only: the linter's findings inform the pruner's targets), `file-move-safety` (every destructive op goes through the safety layer), `obsidian-compat-validator` (the rewritten summaries must still validate).

### Consulted by

`project-wiki-orchestrator` — the `/prune` and `/resolve <issue>` commands.

### Out of scope

Auditing the vault without acting (that's `wiki-linter`) · gating new writes (that's `wiki-curator`) · writing new wiki pages from scratch (that's `wiki-updater`) · deciding when an issue is resolved (the user decides; the pruner verifies).
