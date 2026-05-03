# Abstract: orchestrator (foundation)

**Domain:** orchestrator
**Level:** FOUNDATION
**Inherits From:** none (foundation root)

> A foundation abstract. Every skill set with more than one Layer-1 SME has exactly one orchestrator that conforms to this abstract.

## Purpose

An orchestrator's job is to **sequence** other skills, **deduplicate and reconcile** their outputs, and **produce a stakeholder-ready deliverable** that no leaf skill could produce alone. The orchestrator is the only skill in a set that decides go / no-go / conditional — leaf skills surface, the orchestrator decides.

## Inheritance

This is a foundation abstract. It does not inherit from anything; everything inherits from it (any skill that sequences others).

## Contract — every concrete orchestrator must

1. **Sequence the leaf skills** in a documented order. The order can branch on inputs but must be explicit.
2. **Deduplicate and re-prioritize the aggregated risk register** by ₪- (or otherwise quantified) impact. Empty registers are a smell; redundant entries are a smell.
3. **Reconcile conflicts between leaves explicitly.** When two leaves disagree (e.g., valuation says ₪10M, stress-test implies ₪8M), the orchestrator must cite both, explain the disagreement, and pick one *or* escalate to the user. Never silently average.
4. **Produce a deliverable in a stakeholder-specific format.** The audience (IC / regulator / lender / auditor / customer) determines the shape. Bake the format in as an asset (template).
5. **Surface "Top-N risks" at the top of every deliverable.** N is usually 3; calibrated by domain.
6. **Refuse to publish if mandatory T3 climbs were skipped** per the leaf skills' climb policies. The orchestrator is the gatekeeper for verification rigor.
7. **Surface unverified residuals.** Every deliverable ends with what's still uncertain.
8. **Cite sources** across all leaf outputs. Untraceable claims are not allowed.

## Required SKILL.md sections (in addition to the standard skill-creator sections)

- **Sequencing logic** — order, branches, parallelization
- **Conflict resolution rules** — how to decide when leaves disagree
- **Deliverable format** — explicit, with a template asset
- **Mandatory climbs enforcement** — pre-publish checklist
- **Top-N risks rule** — what counts as a top risk in this domain (₪-impact, regulatory exposure, reputational, etc.)

## Skeptical checks any concrete orchestrator must run

1. Are the **top-N risks** the audience sees ranked by **impact**, not by which skill produced the most output?
2. Did **all mandatory T3 climbs** complete? Is there a leaf flagging a skipped climb?
3. Are **conditions precedent** realistic — both for the producer to satisfy and the consumer to verify?
4. **Where do leaves disagree**, and was the disagreement surfaced (not averaged away)?
5. Is the deliverable formatted for **this** audience, not a generic template?

## Standard outputs every orchestrator produces

- Top-N risks (one paragraph each, quantified)
- Executive summary
- Decision recommendation (go / no-go / conditional)
- Conditions precedent (specific, time-bounded)
- Aggregated risk register (deduplicated, prioritized)
- Monitoring / post-decision watch items
- Surface-the-unverified summary
- Citations to leaf outputs

## Specialization axes (concrete instances vary along these)

- Domain (DD, deployment, audit, feasibility)
- Audience (IC, regulator, lender, customer)
- Jurisdiction (when relevant)
- Subject type (counterparty, asset, system, decision)
- Decision tier (recommendation only / authorization to proceed)

## Anti-patterns (reject in concrete orchestrators)

- **Silent averaging** of conflicting leaf outputs
- **No top-N rule** — every risk gets equal weight
- **No format spec** for the deliverable
- **No CP timing** — "complete title cleanup" without a deadline
- **Empty risk register** — usually means the orchestrator didn't do its job

## Versioning note

When this abstract evolves, every concrete orchestrator should be reviewed against the new contract. Bump concrete versions when their abstract bumps.
