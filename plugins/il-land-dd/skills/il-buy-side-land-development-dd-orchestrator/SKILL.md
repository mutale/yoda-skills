---
name: il-buy-side-land-development-dd-orchestrator
description: Israeli buy-side land/development real-estate due-diligence orchestrator — sequences the 11 leaf skills on a specific deal, deduplicates and re-prioritizes risk-register entries, reconciles conflicts between skills (e.g., when valuation says ₪10M and stress-test says ₪8M), produces the final IC-format DD report (top-3 risks at top, summary, go/no-go/conditional recommendation, conditions precedent, monitoring plan, fees breakdown). Triggers on do due diligence, run DD, evaluate this property, IC memo, investment committee report, ועדת השקעות, DD report, full DD, integrated DD on an Israeli development site / land deal — including informal phrasings like "should we buy this", "look at this deal end-to-end", "give me the IC memo".
---

## Inheritance
**Domain:** il-buy-side-land-development-dd-orchestrator
**Level:** CONCRETE
**Inherits From:** orchestrator (foundation), risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/orchestrator.md
2. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
3. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Without an orchestrator, the user manually sequences 11 leaves, dedupes risk registers, reconciles conflicting outputs, and assembles the IC report. The orchestrator is itself an expertise — sequencing, conflict resolution, producing a deliverable in the IC-memo format. It is the only skill that decides go/no-go/conditional — leaves surface, this skill decides.

### Subject definition

A specific Israeli land / development site under buy-side acquisition. Inputs identify the parcel (gush/חלקה), the seller, the transaction structure, and the intended development.

### Audience definition

Internal investment committee (IC). Output style: short and directive, top-3 risks at the top, ₪-quantified, with go/no-go/conditional explicit.

### Decision definition

`go` = approve transaction at proposed terms. `conditional` = approve with explicit, time-bounded CPs. `no-go` = decline; CPs would not bridge the gap.

### Sequencing logic

```
[T1 inputs gathered]
   │
   ▼
input-scrutiny-and-risk-register  (foundation gate)
   │
   ├─→ il-land-registry-and-rmi          ┐
   ├─→ il-zoning-and-planning            │ Layer-1 SMEs in parallel
   ├─→ il-environmental-and-soil-risk    │ (each consults input-scrutiny)
   │                                     │
   ▼                                     │
il-construction-feasibility-and-cost  (consults zoning + env)
   │
   ▼
il-real-estate-valuation-development  (consults zoning + feasibility + tax)
   │
   ▼
il-development-financial-stress  (consults feasibility + valuation + tax)
   │
   ├─→ corporate-records-il-and-kyc-aml  ┐
   ├─→ il-real-estate-legal-development  │ Layer-2 cross-cutting
   ├─→ il-tax-real-estate-development    │
   ├─→ insurance-and-risk-transfer-development
   │
   ▼
ORCHESTRATOR (this skill): dedupe, reconcile, format
   │
   ▼
[IC-format DD report]
```

### Conflict resolution rules

- **Valuation disagreement** (e.g., residual valuation says ₪10M, financial-stress IRR-equivalent price says ₪8M): cite both, surface the assumptions that differ, pick the lower for the IC's go/no-go recommendation, escalate to user if the gap exceeds 25%.
- **Risk register duplicates**: same `cause` from multiple skills → merge; sum quantified impact when independent, take max when overlapping.
- **Skipped mandatory T3 climbs**: refuse to publish the final report. List the missing climbs and their cost bands.
- **Audience mismatch**: if a leaf produces output styled for a regulator instead of IC, route back to the leaf with format note. Do not ghost-write the fix.

### Domain-specific skeptical checks

1. Are top-3 risks ranked by **₪-impact**, not by which leaf produced the most output?
2. Did all mandatory T3 climbs complete (Tabu T3, Phase I ESA if triggered, KYC T3 above ₪5M deal size)?
3. Are CPs realistic — both for seller to deliver and buyer to verify?
4. Where leaves disagree — surfaced, not averaged?
5. Is the deliverable formatted for **IC**, not generic memo?

### Outputs (delta on top of inherited orchestrator outputs)

- IC-format DD report:
  - **Top-3 risks** (one paragraph each, ₪-quantified)
  - **Executive summary**
  - **Decision**: go / no-go / conditional with rationale
  - **Conditions precedent** (specific, time-bounded, with owners)
  - **Aggregated risk register** (deduplicated, prioritized)
  - **Monitoring / post-closing watch items**
  - **Fees & verification spend incurred** (so IC sees the cost-of-DD vs. deal size)
- Surface-the-unverified summary at top
- Citations across all leaf skill outputs

### Mandatory T3 climb enforcement

Refuse to publish if any of these were skipped:
- Tabu T3 (paid נסח טאבו מהותי) — always, regardless of deal size
- Phase I ESA — if any adjacent prior industrial use found in T1
- KYC T3 (WorldCheck or equivalent) — if deal size > ₪5M or counterparty is non-individual

### Quantification unit

₪. Risk impact in ₪. Decision threshold in ₪ delta from base case.

### Out of scope

Post-acquisition asset management · Portfolio-level analysis · Negotiation strategy beyond DD findings · Foreign jurisdictions · Non-development assets.

### Consulted by

User directly, or higher-level workflows that batch DD across multiple deals.

### Consults

All 11 leaf skills above.
