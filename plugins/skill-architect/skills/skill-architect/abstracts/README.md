# Abstract catalog

Two-tier catalog of abstract skills that concrete skills inherit from. Used by `skill-architect` at design time (Phases 0, 1, 4) to detect inheritance, propose decompositions that conform, and tag every produced brief with `Conforms to: <abstract>`.

## Layout

Foundation tier is flat (these abstracts don't have sub-types). Domain tier uses the **folder-and-file nesting pattern** (Olympus convention) — each abstract has a `.md` file at its level and an optional sibling folder where children live.

```
abstracts/
├── foundation/                          ← cross-cutting; used by every skill set
│   ├── orchestrator.md                  Level: FOUNDATION
│   ├── input-scrutiny.md                Level: FOUNDATION
│   ├── artifact-scrutiny.md             Level: FOUNDATION
│   └── risk-register-manager.md         Level: FOUNDATION
└── domain/                              ← recognizable conceptual patterns
    ├── due-diligence.md                 Level: DOMAIN
    └── due-diligence/
        ├── _PATTERN.md                  ← documentation of the nesting rule
        └── (sub-domain abstracts go here when 2+ concretes earn one)
```

## Header schema (every abstract file)

Right after the file's title, every abstract carries a preamble block:

```
**Domain:** <full-path-from-tier-root>     (e.g., orchestrator OR due-diligence/buy-side-property-acquisition)
**Level:** FOUNDATION | DOMAIN | SUB-DOMAIN | CONCRETE
**Inherits From:** <abstract>, <abstract>, ...   (or: none for foundation roots)
```

This makes the inheritance visible at the top of the file without needing to read the body. Adopted from Olympus SDLC's skill convention.

## Runtime preamble pattern (READ-FIRST → THEN-APPLY-DELTA)

Every concrete SKILL.md authored from a brief emits an `## Inheritance` block at the top (after the YAML frontmatter, before the body):

```
## Inheritance
**Domain:** <concrete-name>
**Level:** CONCRETE
**Inherits From:** <abstract>, <abstract>, <abstract>

**READ FIRST (in order):**
1. abstracts/foundation/<a>.md
2. abstracts/foundation/<b>.md
3. abstracts/domain/<c>.md

**THEN APPLY THE DELTA BELOW.**
```

This is composition at runtime: when Claude loads the skill, it reads the abstracts first, then applies the concrete's delta. Skill body shows only the domain-specific overrides; everything else is "see abstract X."

Adopted directly from Olympus SDLC's `command.md` convention ("READ FIRST: $HOME/.claude-agents/base/X.md, THEN READ: $HOME/.claude-agents/<name>/KNOWLEDGE.md").

## Tiers

### Foundation abstracts

Reusable across every skill set, regardless of domain. Every well-formed skill set uses all four:

- **`orchestrator`** — sequence leaves, dedupe risks, reconcile conflicts, produce audience-formatted deliverable.
- **`input-scrutiny`** — three-tier verification ladder for incoming claims.
- **`artifact-scrutiny`** — validation gate on leaf outputs before the orchestrator aggregates.
- **`risk-register-manager`** — schema + discipline for the risk register every skill emits.

Planned for v0.2 (deferred): `jurisdiction-asserter`, `stakeholder-communicator`.

### Domain abstracts

A recognizable conceptual pattern that recurs across instances. Each domain abstract declares which foundation abstracts it uses and what additional structure every concrete instance must include.

- **`due-diligence`** — v0.1. Used by `il-buy-side-land-development-dd` (in flight) and any future DD set.

Future domain abstracts to add as they earn their seat:

- `deployment` — cloud, app-store, on-prem deploys.
- `audit` — compliance audit (GDPR, SOC2, HIPAA, ISO).
- `feasibility-study` — pre-investment feasibility for a project.
- `evaluation` — candidate / proposal / vendor evaluation.
- `investigation` — incident, fraud, security investigation.
- `monitoring-design` — designing the monitoring layer for a system or domain (the agent counterpart to investigation).

A pattern earns a domain abstract when **two or more concrete skill sets** would inherit from it. Premature abstraction is worse than its absence.

## How `skill-architect` uses the catalog

**Phase 0 — Triage (catalog scan).** Before deciding fast/full path, scan the catalog for matches:
- Does the request match an existing **domain abstract**? If yes, surface it: *"This looks like a `due-diligence` instance — I'll inherit from that."*
- If no domain match, note it: *"This is a new domain pattern. After the design pass, consider promoting the result to an abstract."*

**Phase 1a — Reframe (declare inheritance).**
Output statement now includes the inheritance chain:

> This skill set is a concrete instance of `due-diligence` (domain) which uses `orchestrator`, `input-scrutiny`, `artifact-scrutiny`, `risk-register-manager` (foundation).

**Phase 4 — Refine briefs (tag and inherit).**
Every produced brief includes a `Conforms to:` line listing applicable abstracts. The brief inherits the abstract's contract sections by reference; only domain specifics are written out in full. Skill-creator then composes the abstract contract + the brief delta into the final SKILL.md.

## How to add a new abstract

1. **Confirm it earns its seat:** at least two concrete skill sets would inherit from it (current + planned).
2. **Pick the tier:** foundation (cross-cutting) or domain (a conceptual pattern). Sub-domain abstracts (e.g., `buy-side-property-acquisition-dd` under `due-diligence`) live inside the domain folder, namespaced.
3. **Write the contract** following the template in `_template.md` (write this when needed; the existing abstracts are good starting examples).
4. **Bump skill-architect version** to reflect the new contract.
5. **Update existing concretes** that should now declare conformance, on their next version bump.

## Contract template (rough — use existing files as examples)

```
# Abstract: <name> (foundation | domain | sub-domain)

## Purpose
## Inheritance
## Contract — every concrete must
## Required SKILL.md sections
## Skeptical checks every concrete must run
## Standard outputs every concrete produces
## Specialization axes
## Anti-patterns
## Versioning
```

## Versioning policy

- The catalog is versioned with `skill-architect`. Bump skill-architect's plugin version when the catalog changes.
- Concrete skills that conform to an abstract should declare which version of the abstract they last conformed to. When the abstract bumps, concretes are reviewed against the new contract on their next own-version bump.

## Anti-patterns for the catalog itself

- **Promoting to abstract too early** — wait for at least two concrete instances. Otherwise the abstract is just one-skill-with-extra-steps.
- **Abstracts that prescribe domain detail** — the abstract describes structure and discipline, not domain knowledge. Keep specifics out.
- **Cycles in inheritance** — domain abstracts inherit foundation; concretes inherit domain + foundation. Never the other way around.
- **Stale abstracts** — when an abstract has zero concretes, retire it.
