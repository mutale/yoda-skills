# Abstract: due-diligence (domain)

**Domain:** due-diligence
**Level:** DOMAIN
**Inherits From:** orchestrator (foundation), input-scrutiny (foundation), artifact-scrutiny (foundation), risk-register-manager (foundation)

> A domain abstract. Use as the base for any skill set whose purpose is to verify and assess a subject (counterparty, asset, system, transaction) before a consequential decision.

## Purpose

Due diligence is a recognizable conceptual pattern that recurs across radically different domains: real-estate acquisitions, vendor procurement, M&A on a target company, GDPR compliance audits, code-base reviews before acquisition, candidate background checks. The pattern is the same; the substance differs. This abstract captures the pattern.

## Inheritance

- **Inherits from foundation abstracts:** `orchestrator`, `input-scrutiny`, `artifact-scrutiny`, `risk-register-manager`.
- **Specialized by sub-domain abstracts** (when added later): `buy-side-property-acquisition-dd`, `vendor-dd`, `m-and-a-dd`, `gdpr-dd`, `code-dd`, etc.
- **Concrete instances** are jurisdiction- and asset-class-tagged: `il-buy-side-land-development-dd`, `gdpr-vendor-dd-eu`, `us-pe-target-dd`, etc.

## Contract — every concrete due-diligence skill set must include

1. **An orchestrator** that conforms to `orchestrator (foundation)` and produces an audience-formatted DD report.
2. **At least one Layer-1 SME per consequential dimension.** Walk this checklist per domain — include the ones that apply:
   - Identity / ownership / authority of the subject
   - Legal status and contractual mechanics
   - Financial / economic analysis
   - Regulatory / compliance status
   - Operational / technical readiness (where relevant)
   - Domain-specific risks (environmental, security, reputational, etc.)
3. **An input-scrutiny instance** that gates the user's claims about the subject (the subject is rarely self-describing accurately).
4. **An artifact-scrutiny instance** that gates each leaf SME's output before the orchestrator aggregates it.
5. **A risk-register manager** discipline followed by every leaf.
6. **Jurisdiction tagging** on legal/tax/regulatory leaves (per the `jurisdiction-asserter` foundation abstract — coming in v0.2 of the abstract catalog).
7. **An explicit definition of "subject"** — what is being DD'd. The subject framing is what distinguishes one DD from another.
8. **An explicit definition of "decision"** — what go/no-go/conditional means in this context (sign / don't sign / sign with CPs).
9. **An explicit definition of "audience"** — who consumes the DD report and what format they need.

## Standard phases of a DD task (the orchestrator runs these)

1. **Scope-defined** — subject identified, dimensions in scope, audience for the report, decision tier.
2. **Inputs gathered** — what the user has, what's needed, what's deferred.
3. **Verifications climbed** — per `input-scrutiny`'s three-tier ladder; mandatory T3 climbs identified.
4. **Analyses by domain SMEs** — in parallel where possible.
5. **Artifacts scrutinized** — each leaf output gated through `artifact-scrutiny`.
6. **Risks aggregated** — orchestrator dedupes per `risk-register-manager`.
7. **Conflicts reconciled** — explicit cite-and-pick (or escalate); never silent average.
8. **Conclusion reached** — go / no-go / conditional, with quantified rationale.
9. **Report formatted** — audience-specific (IC / regulator / lender / counterparty / auditor).

## Skeptical checks any DD skill set must run (in addition to per-skill checks)

1. **Is the subject what we think it is?** Identity verification first; the registered entity is sometimes not the negotiating party.
2. **Who has incentives to misrepresent?** Sellers / candidates / applicants / vendors: yes. Internal monitoring: usually no.
3. **What's the cost of being wrong vs. cost of verification?** Drives T3 climb decisions.
4. **What's still unverified after all climbs?** Surface in the deliverable, not buried.
5. **Is the decision the audience actually gets to make?** A regulator-facing DD is not the same as an IC-facing DD even on identical inputs.
6. **What happens between DD and decision?** Stale-data risk for fast-moving subjects.

## Standard deliverable shape

Every concrete DD report includes:

- **Top-3 risks** (one paragraph each, quantified)
- **Executive summary**
- **Decision recommendation:** go / no-go / conditional
- **Conditions precedent** (specific, time-bounded, with owners)
- **Aggregated risk register** (deduplicated, prioritized)
- **Monitoring / post-decision watch items**
- **Surface-the-unverified summary** (top-of-page warning)
- **Citations** to leaf skill outputs and external sources

The audience determines the *style* and *depth*, not the structure. An IC memo is shorter and more directive; a regulator memo is heavier on evidence; a lender memo emphasizes financial stress.

## Specialization axes (concrete instances vary along these)

- **Subject type:** counterparty (entity / individual), asset (real estate, IP, securities), system (software, infrastructure), transaction (M&A, contract, partnership).
- **Side of decision:** buy-side, sell-side, lender, regulator, internal IC, board.
- **Asset class** (when subject is an asset): real estate, securities, IP, technology, services.
- **Jurisdiction:** per applicable law.
- **Audience:** IC, board, regulator, transaction party, auditor.
- **Time horizon:** point-in-time snapshot (true DD) vs. continuous monitoring (an agent, not a DD skill set).

## Anti-patterns

- **DD as a single skill** — guarantees shallowness across dimensions. Always decompose.
- **No subject definition** — "do DD on this" without clear subject = scope creep guaranteed.
- **No audience format spec** — orchestrator produces a generic memo nobody acts on.
- **Skipping artifact-scrutiny** — leaf outputs propagate errors.
- **Continuous DD as a "skill set"** — that's an agent, reframe.
- **DD as advocacy** — DD surfaces risks neutrally; if the team wants advocacy, that's a separate skill (deal champion, etc.).

## Required Phase-6 brief sections per concrete DD skill set

When skill-architect produces briefs for a concrete DD set, every brief must declare:

- `Conforms to: <leaf abstract or orchestrator>, due-diligence (domain)`
- The contract sections required by the concrete skill's leaf abstract
- The DD-specific specialization (subject definition, audience, jurisdiction)

The orchestrator brief specifically must declare:

- `Conforms to: orchestrator (foundation), due-diligence (domain)`
- Sequencing logic for this DD
- Audience format (IC memo / regulator / etc.)
- Mandatory-T3-climb enforcement
- Conflict resolution rules between leaves

## Versioning

When this abstract evolves, every concrete DD skill set should be reviewed against the new contract. Bump concrete plugin versions when the DD abstract bumps.
