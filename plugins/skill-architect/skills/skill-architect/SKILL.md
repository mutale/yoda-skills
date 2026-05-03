---
name: skill-architect
description: Use this skill BEFORE creating any new skill, no matter where the request comes from (Claude Code, Claude.ai, or Cowork). Triggers whenever the user says "create a skill", "build a skill", "make a skill", "I need a skill for X", "design a skill", "let's build a skill", "skill for Y", "turn this into a skill", or any phrasing that implies authoring a new skill. Also triggers when the user wants to refine, split, expand, or critically review an existing skill. This skill does NOT author the skill itself — it reframes the request (skill vs. task vs. agent), applies critical-thinking to inputs, decomposes the request into a hierarchy of 5–10+ layered skills covering domain experts, cross-cutting concerns (legal, security, compliance, performance, devops), critical-thinking/verification, and an orchestrator, then presents the proposal for the user to approve before delegating each individual skill to skill-creator.
---

# Skill Architect

The first stop for any "let's create a skill" request. Sits on top of `skill-creator` and applies critical thinking before a single line of skill content is written.

## Why this skill exists

Naive skill creation produces three failure modes:

1. **Task-shaped skills** — "Deploy my app", "Do due diligence", "Onboard a customer". These are workflows, not skills. Skills are *narrow areas of expertise* that workflows compose.
2. **Monolithic skills** — One giant skill that tries to be the lawyer, the appraiser, the security reviewer, and the orchestrator at once. It triggers unreliably and gives shallow answers in every direction.
3. **Credulous skills** — Skills that accept user-provided inputs at face value, never verify against public data, never flag the gaps that need private or paid data, and never produce a risk register.

Skill Architect catches all three before they happen.

## Abstract catalog and inheritance

Skill-architect maintains an abstract catalog under `abstracts/`. Every produced decomposition checks the catalog and declares inheritance both at design time (in the brief) and at runtime (in the authored SKILL.md).

**Two tiers, with optional nesting under domain:**

- **Foundation abstracts** (`abstracts/foundation/`) — reusable everywhere: `orchestrator`, `input-scrutiny`, `artifact-scrutiny`, `risk-register-manager`. Every skill set uses all four (one of each, sometimes shared with other sets). Foundation tier stays flat — these don't have sub-types.
- **Domain abstracts** (`abstracts/domain/`) — recognizable conceptual patterns. The folder follows the **folder-and-file nesting pattern** (Olympus convention): `<name>.md` is the abstract, `<name>/` is the container for sub-domain abstracts when 2+ concretes earn one. Currently: `due-diligence.md`. Future sub-domains live inside `due-diligence/`, etc.

**Levels (controlled vocabulary):**
`FOUNDATION` → `DOMAIN` → `SUB-DOMAIN` → `CONCRETE`. A concrete may inherit from any tier above; sub-domains inherit from domain; domains inherit from one or more foundation abstracts.

**Header schema** (every abstract file's preamble, immediately after the title):

```
**Domain:** <full-path-from-its-tier-root>
**Level:** FOUNDATION | DOMAIN | SUB-DOMAIN | CONCRETE
**Inherits From:** <abstract>, <abstract>, ...   (or: none for foundation roots)
```

**Inheritance chain (typical):**
`concrete skill set` → `(optional sub-domain)` → `domain abstract` → `foundation abstracts`.

**Where the catalog plugs into the workflow:**

- **Phase 0 — Triage** scans `abstracts/domain/` (recursively, including nested sub-domain folders) for a match. If yes, surfaces the inheritance up front.
- **Phase 1a — Reframe** explicitly declares the inheritance chain in the Reframe Statement.
- **Phase 4 — Refine briefs** tags each brief with `Conforms to: <leaf abstract>, <domain abstract>` and ensures the brief covers every required section from each abstract.
- **Phase 6 — Delegate** hands skill-creator the brief plus the abstract contract files; skill-creator emits the **runtime preamble** (below) at the top of the authored SKILL.md and then writes the domain-specific delta.

### Runtime preamble pattern (Olympus READ-FIRST convention)

Every concrete SKILL.md authored by skill-creator emits an `## Inheritance` block right after its frontmatter, looking like:

```
## Inheritance
**Domain:** il-buy-side-land-development-dd
**Level:** CONCRETE
**Inherits From:** orchestrator (foundation), risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. abstracts/foundation/orchestrator.md
2. abstracts/foundation/risk-register-manager.md
3. abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**
```

This makes inheritance **visible at runtime** (when Claude loads the skill) — not buried in design-time metadata. The body of the SKILL.md is the *delta* on top of the inherited contracts: only the domain-specific specialization (jurisdiction-specific mechanics, audience format, etc.) — overlap with the abstract is replaced by `(see <abstract>)`.

When the request doesn't match any existing domain abstract, surface that explicitly: *"This is a new domain pattern. After the design pass, consider promoting the result to an abstract."* A pattern earns a domain abstract when at least **two** concrete skill sets would inherit from it.

See `abstracts/README.md` for the catalog itself, contract template, and rules for adding new abstracts.

## What counts as a skill (and what doesn't)

| Concept | Definition | Example |
|---|---|---|
| **Skill** | A narrow, bounded area of *expertise*. A specialist would charge a fee for it. Inputs and outputs are well-defined. Triggers are recognizable in user phrasing. | `commercial-real-estate-valuation`, `israeli-corporate-law`, `gcp-cloud-run`, `pii-redaction-il-and-eu` |
| **Task** | A concrete workflow with steps and a deliverable. Composes skills. | "Do due diligence on 12 Yermiyahu St., Tel Aviv" |
| **Agent** | An autonomous loop that decides what to do next. Often *uses* skills. | A property-acquisition agent that monitors listings and triggers due diligence |
| **Orchestrator** (a special skill) | A skill whose expertise is *sequencing other skills* in a domain — it knows which skill to consult when, how to merge their outputs, and how to escalate disagreements. | `due-diligence-orchestrator`, `cloud-deploy-orchestrator` |

If the user's request is shaped like a task or an agent, **say so explicitly** and propose the right shape. Do not silently force a task into skill form.

## The workflow

Every invocation of skill-architect starts with **Phase 0 — Triage**. Phase 0 picks one of two paths:

- **Fast path** — the request is genuinely a single narrow skill. Skip Phases 3–5 (decomposition + presentation). Run a streamlined Phase 1+2+6 (confirm assumptions, build a verification plan, hand off to `skill-creator`). The user must confirm the fast path before it's taken.
- **Full path** — the request implies a task, an agent, or several skills bundled together. Run all phases (1 → 6).

```
                           ┌──────────────────────┐
   "Create a skill" ──────▶│  Phase 0 — Triage    │
                           └──────────┬───────────┘
                                      │
                  ┌───────────────────┴────────────────────┐
                  ▼                                        ▼
          FAST PATH (narrow skill,                 FULL PATH (task / agent /
          user confirmed)                          multi-skill)
                  │                                        │
                  ▼                                        ▼
       Phase 1 (light): confirm assumptions    Phase 1: Reframe + assumptions
                  │                                        │
                  ▼                                        ▼
       Phase 2 (light): verification plan      Phase 2: Verification plan
                  │                                        │
                  ▼                                        ▼
                  │                            Phase 3: Decompose into ≥5 skills
                  │                                        │
                  │                                        ▼
                  │                            Phase 4: Per-skill briefs
                  │                                        │
                  │                                        ▼
                  │                            Phase 5: Present, user decides
                  │                                        │
                  ▼                                        ▼
       Phase 6: Hand off the single skill       Phase 6: Hand off approved skills
                to skill-creator                          one at a time
```

Do not skip phases inside whichever path you're on. Do not collapse Phase 5 (user approval) into Phase 6 (delegation).

### Phase 0 — Triage (skip the gate when appropriate; scan the abstract catalog)

Not every "create a skill" request needs full decomposition. Sometimes a request really is one narrow skill. Phase 0 decides which path to run.

**Before the fast/full decision, scan the abstract catalog (`abstracts/domain/`) for a match.** If the request matches an existing domain abstract (e.g., "create a DD skill" matches `due-diligence`), say so up front:

> "This looks like a `due-diligence` instance — the design will inherit from that abstract plus the four foundation abstracts."

If no domain match exists, note it explicitly:

> "This is a new domain pattern; no existing abstract fits. After we design it, if a future skill set would also fit this shape, we should promote the result to an abstract."

The catalog scan informs the fast/full decision but doesn't override it. A request that matches a domain abstract still goes fast-path if it's a single narrow leaf within that domain.

**Run the fast path when ALL of these hold:**

1. The request describes a single bounded competence with a clear name (e.g., "convert Hebrew dates to Gregorian", "validate IBAN checksums", "extract bibliography entries from arXiv PDFs").
2. The competence does not span multiple jurisdictions, platforms, or stakeholder groups.
3. There is no obvious cross-cutting concern that needs its own skill (no consequential legal exposure, no PII handling, no security boundary, no billing).
4. You can name the skill in kebab-case in five words or fewer without using "and" between unrelated terms.
5. The user explicitly says "this is just a skill" / "skip the decomposition" / "I know it's narrow" — **OR** all of (1)–(4) are clearly true and the user agrees when asked.

**Default to the full path when ANY of these hold:**

- The verb in the request is a workflow verb ("deploy", "onboard", "evaluate", "do due diligence on", "harvest").
- The domain has obvious legal/regulatory exposure (real estate, healthcare, finance, immigration, employment, insurance).
- The request has an "and" or "or" linking unrelated competencies.
- Multiple jurisdictions, platforms, or audiences could plausibly be involved and the user hasn't named one.
- You can think of three skeptical-check categories that a single skill couldn't reasonably hold all of.

**The Phase 0 output is a one-line decision and a one-sentence justification.** Then ask the user to confirm before continuing on the chosen path:

> "This looks like a narrow skill — a single bounded competence around X — so I'd like to run the **fast path** (no decomposition, just verification + handoff). OK, or do you want the full decomposition pass?"

> "This looks like a **task** (workflow verb: 'deploy'), so I'd like to run the **full path** — decompose into a layered skill set. Does that match what you wanted?"

The user is allowed to override either way. If they say "fast path, just author it", honor that — but still run Phases 1 (light) and 2 (light) so assumptions and verification aren't silently skipped.

### Phase 1 — Reframe (skill vs. task vs. agent) and surface assumptions

Phase 1 has two halves: **classify** the request, then **surface every assumption** before any decomposition or authoring happens.

#### 1a. Classify (skill vs. task vs. agent)

Ask yourself:
- Is the user describing a *bounded body of knowledge* (skill), a *workflow* (task), or an *autonomous loop* (agent)?
- If they said "skill", do they mean it in the technical sense, or are they using "skill" colloquially for "thing Claude can do"?
- Is the request actually one skill, or a federation of several?

Output a one-paragraph **Reframe Statement** that **declares the inheritance chain** when a domain abstract matches, e.g.:

> You asked for a "due-diligence skill". Due diligence is a **task** — a workflow with a deliverable (a DD report). This skill set is a concrete instance of `due-diligence` (domain) and uses `orchestrator`, `input-scrutiny`, `artifact-scrutiny`, `risk-register-manager` (foundation). The leaves it composes are: legal, corporate-records, real-estate-valuation, environmental-risk, financial-stress-testing, KYC/AML, plus an orchestrator. I propose we build the skill set, and either you run the task by invoking the orchestrator, or we wrap it in a scheduled task / agent later.

If the request is genuinely a single narrow skill (e.g., "a skill for converting Bible references between Hebrew and Latin numbering"), say so — and **still** run input-scrutiny in Phase 2, since input scrutiny is non-negotiable.

#### 1b. Surface every assumption — and ask before assuming

This is mandatory. Before decomposing or authoring, list every assumption you are about to make and either confirm them with the user or — if you have strong evidence (memory, prior conversation, the user's project context) — *suggest* the assumption and let the user confirm or correct.

Walk this checklist for every request and pick the ones that apply. If any of these is *unspecified by the user and not strongly inferable from context*, you must ask:

- **Jurisdiction** — country, state/province, regulatory regime. Especially: legal, tax, labor, privacy, real estate, healthcare, financial.
- **Language and locale** — input language, output language, scripts, calendars, number formats.
- **Platform / cloud / vendor** — AWS vs. GCP vs. Azure, iOS vs. Android, Postgres vs. MySQL, etc.
- **User type** — individual vs. corporate vs. trust; consumer vs. business; licensed professional vs. layperson; their role in the workflow.
- **Data sensitivity** — PII / PHI / PCI / financial / none. Drives the privacy/security skills you'll need.
- **Scale and frequency** — once-off vs. recurring; one user vs. team vs. enterprise; how often the skill will run.
- **Stakeholders** — who reads the output, who acts on it, who is accountable, who is liable.
- **Time horizon** — point-in-time analysis vs. continuous monitoring (the latter implies an agent, not a skill).
- **Existing skill landscape** — what skills the user already has installed that this should integrate with rather than duplicate.
- **Definition of "done"** — what artifact the user expects, in what format, at what depth.

**Rules for asking:**

- If the user gave context that lets you infer an answer with high confidence (e.g., they mentioned "my Israeli holdings", or you have memory that they live in Israel), **suggest** the assumption and ask them to confirm — don't ask blank-slate questions when you can avoid it.
- If you have no signal, **ask**. Do not silently default to US, English, AWS, or any other lazy default.
- Group questions; don't ping-pong. Use a multi-question prompt where the surface supports it (in Cowork, this is `AskUserQuestion`).
- Keep questions to the truly load-bearing assumptions. Don't ask about every detail that can be inferred from the user's first answer.

**Output of Phase 1b is an Assumptions Block** that gets carried into Phase 2 and beyond:

```
ASSUMPTIONS (confirmed with user, 2026-05-02):
- Jurisdiction: Israel (IL)
- Language: English output, Hebrew sources OK
- Account type: individual taxable brokerage
- Brokerage: Interactive Brokers Israel
- Data sensitivity: PII + financial
- Time horizon: end-of-tax-year and on-demand
- Existing skills: gcp-* installed; no legal-il yet
```

Every later phase references this block. If decomposition produces a skill named `tax-loss-harvesting-orchestrator-il`, that `-il` traces directly to the Assumptions Block.

#### 1c. When you must ask vs. when you can suggest

| Situation | Behavior |
|---|---|
| Memory contains a strong signal (user has a memory file naming their jurisdiction, role, etc.) | Suggest with confirmation: "I see you usually work on IL deals — assuming IL unless you say otherwise" |
| Current conversation contains the answer earlier | Use the answer; restate it in the Assumptions Block |
| Project files / connected workspace strongly imply the answer | Suggest with confirmation; cite the file |
| Nothing in context | Ask explicitly. Never default silently |
| Domain is so politically/legally sensitive that the wrong default does real harm (immigration, healthcare, criminal law) | Always ask, even if context implies an answer |

**Anti-pattern:** producing a long Reframe Statement that quietly assumes US/English/AWS without flagging it. That is exactly the failure mode this phase exists to prevent.

### Phase 2 — Scrutinize Inputs

For every skill in the proposed set, identify the inputs it will receive and apply the **three-tier verification ladder**:

1. **Public data verification** — what can be cross-checked for free? (company registries that are public, land records, government datasets, sanctions lists, official rates, code repos, public docs).
2. **Private data from the user** — what does the user have to provide? (internal docs, credentials, contracts, prior reports). Phrase the ask narrowly so the user knows exactly what's needed.
3. **Paid / manual data** — what requires money or human effort? (paid corporate records, KYC vendors, credit bureaus, paid land-registry extracts, on-site inspection, lawyer review). **Always name the vendor or method and a rough cost band**, even if approximate.

Produce a **Verification Plan** (template at `templates/verification_plan.md`). It must list, per critical input:
- the input,
- the tier (public / private / paid),
- the specific source,
- what is verified by it,
- what is *still unverified* even after this check.

The skill set you propose must bake these checks in — every skill that consumes a critical input must call out its tier.

### Phase 3 — Decompose into a layered skill hierarchy

Decompose the request into a set of skills that obey four properties:

**1. Narrow.** One area per skill. If a skill's description has the word "and" between two unrelated competencies, split it. `gcp-cloud-run-and-load-balancers` → split into `gcp-cloud-run` and `gcp-load-balancers`.

**2. Layered.** There are at least three layers in any non-trivial skill set:

```
                    ┌──────────────────────┐
   Layer 3:         │   Orchestrator       │   ← sequences, arbitrates
                    └──────────┬───────────┘
                               │
       ┌───────────────────────┼───────────────────────┐
   Layer 2:        Cross-cutting concerns               (security, legal,
                   (apply across the domain)             compliance, perf,
                                                         observability, ethics)
                               │
       ┌───────────────────────┼───────────────────────┐
   Layer 1:        Domain experts                        (the SMEs — e.g.
                   (one per sub-domain)                   real-estate appraisal,
                                                         corporate law, env. risk)
                               │
   Layer 0:        Critical-thinking / verification     (input scrutiny,
                   (foundation, used by every skill)     risk register)
```

**3. Abstract.** A skill should be reusable across many tasks in its domain. `tlv-yermiyahu-12-due-diligence` is not a skill — it's a task. `commercial-real-estate-valuation-il` is.

**4. Minimum five skills, target 5–10, more is fine.** If your decomposition has fewer than five skills, you have probably bundled domains that should be split. Re-read the request and look for hidden sub-domains.

#### Mandatory layers (every decomposition must include each)

These are non-negotiable. If you're tempted to skip one, write a one-line justification — usually you'll discover you actually do need it.

- **Layer 0: Critical-thinking / verification skill.** Always present. Its job is to scrutinize inputs against the three-tier ladder, surface unverified claims, and emit the risk register.
- **Layer 2: At least the cross-cutting concerns that actually apply.** Walk this checklist per request:
  - Legal & regulatory (jurisdiction-specific — name the jurisdictions)
  - Compliance & privacy (GDPR, HIPAA, PCI, sector-specific, local privacy law)
  - Security (threat model, data handling, secrets, access)
  - Performance (latency, throughput, cost-of-operation)
  - DevOps / operability (deployability, observability, rollback)
  - Ethics & fairness (when humans are affected — hiring, lending, housing, healthcare)
  - Accessibility (when there's a UI or user-facing artifact)
  - Localization (when content crosses languages or jurisdictions)
  - Procurement / vendor risk (when the skill recommends third-party services)
  - Sustainability / environmental impact (when relevant — infra, real estate, supply chain)
- **Layer 3: An orchestrator skill** — even for small sets. The orchestrator skill encodes the sequencing logic, conflict resolution between SMEs, and the format of the final deliverable.

Be agile: if the request implies a scope not on this list (export controls, IP licensing, animal welfare, OT/SCADA security, defense compliance), invent the right cross-cutting skill. Don't force the request into the checklist.

### Phase 4 — Refine each proposed skill (with abstract conformance)

For each skill in the decomposition, write a one-page brief that includes:

- **Name** (kebab-case, narrow, jurisdiction- or platform-tagged where relevant)
- **Conforms to:** explicit list of abstracts this skill conforms to (e.g., `orchestrator (foundation), due-diligence (domain)`). Pull required sections from each abstract; the brief inherits the contract by reference and only writes the domain-specific delta.
- **One-line description** with strong trigger keywords (this is what makes it auto-fire later)
- **Why this skill exists** (what it adds that no other skill in the set covers)
- **Inputs it expects** (with verification tier per input)
- **Skeptical checks** — at least three "what could be wrong about this input" questions the skill must always ask, **plus** the mandatory checks inherited from each abstract
- **Outputs it produces** — including the standard outputs from each abstract plus a mandatory **risk register** (see `abstracts/foundation/risk-register-manager.md`)
- **Dependencies** on other skills in the set (which it consults, which consult it)
- **Out of scope** — what it explicitly does *not* cover (forces narrowness)

Then audit the set as a whole:
- Any two skills with overlapping scope? → merge or sharpen the boundary.
- Any skill that's a paragraph long but adds no expertise? → it's probably a step in the orchestrator, not a skill.
- Any skill whose inputs no other skill produces and the user can't reasonably provide? → flag it.

### Phase 5 — Present and let the user decide

Present the full proposal using `templates/proposal.md`. The proposal must include:

1. The Reframe Statement from Phase 1.
2. A diagram (ASCII is fine) of the layered hierarchy.
3. The per-skill briefs from Phase 4.
4. The Verification Plan from Phase 2.
5. A draft risk register highlighting the top risks of the *proposed skill set itself* (e.g., "the orchestrator may give legal advice without a licensed reviewer in the loop").
6. An explicit menu of choices: build all, build a subset, swap a skill, change a boundary, abandon.

**Do not start authoring.** Wait for the user's selection. The user is allowed to reject the whole decomposition and ask for a different shape — that's a valid Phase 5 outcome.

### Phase 6 — Delegate to skill-creator

**Fast path:** hand off the single approved skill to `skill-creator` with the brief format below. Phases 3–5 didn't run, so the brief is built from Phase 1 (Reframe + Assumptions Block) and Phase 2 (Verification Plan).

**Full path:** once the user approves a subset, hand off **one skill at a time** to `skill-creator` (the existing anthropic-skills skill). Build the foundation skill first if it doesn't already exist, then leaves, then the orchestrator last (its instructions reference the leaf skills by name — those names need to be stable before you write the orchestrator).

For each handoff, provide a fully-specified brief:

- Name and description (already written in Phase 4)
- Inputs and outputs
- Skeptical checks the skill must encode
- Risk register format
- Three example trigger prompts (for the description-optimization step in skill-creator)
- Two example "should NOT trigger" prompts (near-misses)

Skill-creator handles the authoring, evals, and description optimization from there. Skill-architect's job is done once the brief is handed off — but stay available for the next skill in the set.

If the user asks for the orchestrator first, build the leaf skills first anyway, then the orchestrator on top. The orchestrator's instructions reference the leaf skills by name — those names need to be stable before you write the orchestrator.

## Critical-thinking principles (apply throughout)

These principles are baked into every skill the architect produces. They are also how the architect itself behaves while running Phases 1–6.

1. **Skeptical, not blocking.** Surface what's unverified; do not refuse to proceed. Always offer a "proceed-with-caveat" path with the caveats spelled out.
2. **Three-tier verification (public → private → paid)** is the default mental model for every input. Name the source at each tier.
3. **Risk register is non-optional.** Every skill output ends with a risk register: `[risk] | [likelihood: L/M/H] | [impact: L/M/H] | [mitigation] | [owner]`. Empty registers are a smell — they usually mean the skill didn't think hard enough.
4. **Jurisdictions are explicit.** Legal, tax, real-estate, employment, and privacy skills name their jurisdiction in the skill name (`-il`, `-eu`, `-us-ca`). A skill that says "advises on labor law" without a jurisdiction is wrong.
5. **Name vendors and cost bands** when paid data is involved. "Use a paid corporate records vendor" is useless. "Use Dun & Bradstreet, ~$50–200 per report" is useful.
6. **Surface the unverified.** Always end with what is *still* unverified after every check the skill performs. The user should never be surprised by a gap later.
7. **Theory of mind.** Explain *why* each constraint exists in the skill body, not just *what* the constraint is. Future Claude reading this skill will obey "must verify ownership against the land registry because user-provided ownership claims are wrong ~5% of the time" but will route around "MUST verify ownership."

## Anti-patterns (reject these)

- "A skill that does everything for [domain]" — split it.
- "A skill that automates [process]" — that's a task or an agent, not a skill.
- "A skill that helps the user with [vague verb]" — refine the verb until it's a bounded competence.
- "A skill that uses [tool]" — tools are tools; expertise is the skill.
- "A skill that knows [single fact]" — that's a memory entry or a CLAUDE.md note.

## Modes of operation

Skill Architect runs in two modes:

**Mode A — New skill request.** User wants to create a skill from scratch. Always start at Phase 0; Phase 0 picks fast path or full path.

**Mode B — Refine (existing skill).** User has an existing skill and wants it critiqued, split, or expanded. Phases adapt:
- Phase 0: triage — is the existing skill genuinely one narrow skill that just needs refinement, or is it secretly several glued together?
- Phase 1: reframe + surface assumptions (especially jurisdiction/platform tags the existing skill may have left implicit).
- Phase 2: scrutinize the existing skill's *inputs* and *verification approach*.
- Phase 3: propose a refactored decomposition (split, merge, or extract layers) — only if Phase 0 found it's not really one skill.
- Phase 4: write briefs for any new skills and a delta brief for changes to the existing one.
- Phase 5: present and let the user decide.
- Phase 6: hand off to skill-creator for each new/edited skill.

In Mode B, treat the existing skill as a draft proposal, not as ground truth.

## Surfaces (Claude Code, Claude.ai, Cowork)

Skill Architect is a portable skill folder; it works the same way across surfaces. The only differences are mechanical:

- **Claude Code**: install the folder under `~/.claude/skills/skill-architect/` (user-scope) or the project-scope equivalent. Auto-triggers via the description above.
- **Claude.ai**: upload the folder as a skill. Same auto-trigger.
- **Cowork**: install via plugin or under the local skills folder. Same auto-trigger.

See `INSTALL.md` for exact paths per surface.

When delegating in Phase 6, use the `skill-creator` that's available on the current surface — its capabilities differ slightly per surface (Claude.ai has no subagents, Cowork has no display), but the brief you hand it is the same.

## Templates and references

- `abstracts/README.md` — the abstract catalog (foundation + domain). Read this whenever Phase 0 / 1a / 4 runs.
- `abstracts/foundation/*.md` — the four foundation abstracts (orchestrator, input-scrutiny, artifact-scrutiny, risk-register-manager).
- `abstracts/domain/*.md` — domain abstracts (currently: due-diligence).
- `templates/proposal.md` — the Phase 5 proposal you present to the user.
- `templates/verification_plan.md` — the Phase 2 input verification plan.
- `templates/risk_register.md` — the standard risk register schema (also documented in `abstracts/foundation/risk-register-manager.md`).
- `templates/skill_brief.md` — the per-skill brief from Phase 4 (now includes the `Conforms to:` field).
- `examples/due_diligence.md` — worked example: real-estate due diligence decomposed into 9 skills.
- `examples/cloud_deploy.md` — worked example: "deploy to GCP" decomposed across legal, security, performance, devops, and an orchestrator.
- `REFERENCE.md` — extended methodology, edge cases, and rationale. Read when a request doesn't fit cleanly into the six phases.

## A note on length and rigor

This skill produces a *lot* of structured output (proposal, verification plan, risk register, briefs). That is the point. The rigor is what makes the difference between a skill set the user trusts and one they have to second-guess. If a request feels too small for this much rigor, say so to the user explicitly: "This is a small request — I'd normally produce X, but the lighter version would be Y. OK to go light?"

Don't skip rigor silently.
