---
name: wiki-curator
description: Refines a draft artifact from output/ into a candidate wiki page suitable for promotion — strips first-draft cruft, resolves [needs source] markers (or escalates), adds [[wikilinks]] to related concepts, picks a meaningful page name, picks tags, writes a good summary, ensures frontmatter is complete and validates against the shape skill. Never writes directly to wiki/; produces a candidate that the user reviews via /promote. Enforces the project-wiki policy — nothing enters wiki/ without going through curation. Triggers on /promote, on "curate this for the wiki", "turn this draft into a wiki page", "make this wiki-ready", "polish this for promotion", "promote this artifact".
---

## Inheritance
**Domain:** wiki-curator
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

The plugin's core policy is: **Claude writes freely to `output/` (drafts, analyses, ad-hoc artifacts), but `wiki/` is curated — every entry has gone through deliberate refinement and user approval.** Without a curator skill, "curation" lives as a scattered policy in `wiki-updater` and the `/promote` command; in practice that means it gets short-circuited. This skill owns the actual *work* of curation as a discrete expertise — taking a draft and producing a wiki-ready candidate.

The curator is the gate. The orchestrator's `/promote` flow runs curator first, presents the candidate, and only then does `wiki-updater` commit it.

### Subject

A single artifact at a path inside `output/`. The artifact can be a chat-generated analysis, an ingested source's draft summary, a brainstorm doc, an exported table — anything Claude has written into `output/`.

### Curation workflow

1. **Read the draft in full** — including frontmatter if any, plus surrounding context (sibling files in the same `output/<date>-<session>/` directory).
2. **Check against `wiki/` for duplication.** If a similar page exists, propose merge into existing rather than new page; surface the existing page to the user.
3. **Strip first-draft cruft:**
   - Chat-style preambles ("Sure, here's...", "Let me think about that...").
   - Hedge language that doesn't add information ("It seems that", "It might be the case that").
   - Restatements of the user's question.
   - Speculative parentheticals that aren't sourced.
4. **Resolve citations:**
   - Every factual claim must cite a source under `raw/` via `[^src]` footnote.
   - Unsourced claims: try to find a source in `raw/`, in conversation history, or in `output/`'s sibling artifacts. If found, add the footnote.
   - If genuinely unresolvable, escalate to the user: "I cannot source this claim — strip, mark `[needs source]`, or abandon promotion?" — never silently promote an unsourced claim.
5. **Add `[[wikilinks]]`** to related existing pages. New concepts referenced but with no page → add to `questions.md` for later or create stub pages with `status/wip`.
6. **Pick a meaningful page name:**
   - Kebab-case, lowercase, no reserved chars.
   - Conceptual, not file-derived (`japanese-tea-ceremony.md`, not `output-2026-05-18-draft-3.md`).
   - Length ≤ 60 chars.
7. **Pick tags** from the controlled vocabulary: one `status/*` (default `status/wip` unless the user marks it stable), topic tags, type-mirror tag.
8. **Write a good summary** — one or two sentences that capture the *takeaway*, not a description of the page. ("Buddhist temple etiquette: bow at the gate, wash at the chōzuya, no shoes in the hall." — not "This page is about Buddhist temple etiquette.")
9. **Validate against the shape skill** (`obsidian-wiki-shape` or `code-wiki-shape` depending on target vault) — strict.
10. **Emit a candidate page** to `<project>/.project-wiki/candidates/<page-name>.md` for user review. Never write to `wiki/` directly.

### Climb policy (specialization of input-scrutiny)

- T1: search `raw/`, search sibling `output/` artifacts, search conversation history for citation sources.
- T2: ask the user to provide a missing source, or confirm a contested merge with an existing page.
- T3: N/A.

### Validation checklist (specialization of artifact-scrutiny)

Before emitting a candidate:

1. Page name picked deliberately (not the output filename).
2. Frontmatter complete per `obsidian-wiki-shape` (or `code-wiki-shape`).
3. Every factual claim cites a source OR has been explicitly marked `[needs source]` with user confirmation.
4. Every `[[wikilink]]` either targets an existing page or has a stub planned.
5. Tags are from the controlled vocabulary, single status tag.
6. Summary is a takeaway, not a description.
7. No first-draft cruft remaining.

### Domain-specific skeptical checks

1. **Duplication first.** Always search `wiki/` before creating a new page. Fragmentation is the slow death of a knowledge graph.
2. **Don't promote unsourced claims silently.** Either find the source, mark explicitly, or escalate. Never let "the model said it during a chat" become a wiki-blessed fact.
3. **Don't auto-rename without thought.** The page name is a contract — once it's in the graph, every wikilink depends on it. Get it right the first time.
4. **First-draft cruft varies by source.** A draft summary of an ingested PDF has different cruft than a brainstorm doc; calibrate the strip to the artifact type.
5. **Curation is judgment, not mechanism.** If the artifact isn't ready for promotion (still half-formed, still arguing with itself, still missing key sources), surface that to the user — don't try to polish what shouldn't be promoted yet.

### Outputs (delta)

- **Candidate wiki page** at `<project>/.project-wiki/candidates/<page-name>.md`.
- **Curation report** — one entry per change: what was stripped, what was added, what was renamed, what was sourced, what was escalated.
- **Duplication report** — if existing pages cover similar ground, the curator surfaces them and proposes merge-vs-new.
- **User-decision points** — list of items the user must rule on before promotion (unresolved sources, contested names, merge candidates).
- Risk register entries prefixed `R-CURATE-*`.
- Findings per inherited artifact-scrutiny.

### Risk-prefix taxonomy

`R-CURATE-*` — curation-time risks (silent unsourced claim, drift from shape, etc.).

### Consults

`obsidian-wiki-shape` and `code-wiki-shape` (target schema), `obsidian-compat-validator` (final format gate), `wiki-linter` (light pass on candidate before user review).

### Consulted by

`project-wiki-orchestrator` — the `/promote` command runs curator FIRST, before `wiki-updater` writes anything to `wiki/`.

### Out of scope

Writing the final blessed page to `wiki/` — that's `wiki-updater` after user approval · ingesting new sources into `wiki/` directly (also `wiki-updater`) · auditing existing wiki content (`wiki-linter`) · moving the original artifact out of `output/` (promotion is copy + curate; the original stays in `output/` as historical record).
