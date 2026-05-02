# Worked example — "Create a skill for real-estate due diligence"

This example shows skill-architect running all six phases on a request the user actually mentioned. It also demonstrates the right reframe: due diligence is a **task**, not a skill — but it composes a clean set of skills.

---

## Phase 1 — Reframe statement

You asked for a "due-diligence skill" for real estate. **Due diligence is a task** — a workflow with a deliverable (a DD report). I propose we build the underlying skill set, plus an orchestrator that *runs* the DD task by sequencing those skills. The user (or a future agent) invokes the orchestrator on a specific property.

The skills below are scoped for **commercial real estate in Israel**. I tagged jurisdictions explicitly because legal, tax, and registry mechanics are jurisdiction-bound. We can clone the legal/tax skills for other jurisdictions later.

---

## Phase 2 — Verification plan

| # | Input | Consumed by | Tier | Source | Verifies | Still unverified | Cost band |
|---|---|---|---|---|---|---|---|
| 1 | Property address & block/parcel (גוש/חלקה) | every Layer-1 skill | 1 | Public Tabu / רשות מקרקעי ישראל basic abstract | Existence and basic identifiers | Recent unrecorded changes | — |
| 2 | Recorded ownership & encumbrances | corporate-records-il, legal-il | 1→3 | Public Tabu (T1) → paid Nesach Tabu mehutsa (T3) | Owner of record + recorded liens | Beneficial owner behind a holding co. | ~₪40 (T3) |
| 3 | Beneficial ownership of seller (if entity) | corporate-records-il, kyc-aml | 1→3 | רשם החברות public extract (T1) → paid corporate-records vendor (T3) | Directors, shareholders | Off-record nominees | ~₪50–500 |
| 4 | Sanctions / PEP / adverse media on principals | kyc-aml | 1→3 | OFAC/EU/UN free lists (T1) → WorldCheck/Refinitiv (T3) | Listed sanctions and PEP status | Recent unlisted activity | $50–500 per subject |
| 5 | Zoning, planning, building permits | re-valuation-il, legal-il | 1 | מינהל התכנון, מערכת רישוי זמין | Permitted use, open files | Verbal approvals not yet filed | — |
| 6 | Environmental status | env-risk-il | 1→3 | המשרד להגנת הסביבה public DB (T1) → Phase I ESA (T3) | Listed contamination, adjacent uses | Sub-surface contamination | ₪5,000–15,000 (Phase I) |
| 7 | Comparable transactions / market rents | re-valuation-il | 1 | רשות המסים — נתוני עסקאות (T1) | Recent comps | Off-market deals | — |
| 8 | Tenant rent roll and leases | financial-stress-il | 2 | User-provided lease pack | Stated rents and terms | Side letters, oral promises | — |
| 9 | Property tax (ארנונה) and outstanding municipal debts | legal-il | 1→2 | Municipality online (T1), with user account number (T2) | Outstanding amounts | Unbilled assessments | — |

**Climb policy:** Climb #2 to T3 always (recorded liens have legal effect — never rely on T1 abstract alone). Climb #3 to T3 when transaction value > ₪5M. Climb #6 to T3 if any adjacent prior industrial use is found in T1.

**Residuals to surface in the final report:** beneficial owner uncertainty, oral tenant agreements, any off-registry encumbrance, sub-surface env. risk if Phase I not done.

---

## Phase 3 — Layered hierarchy

```
Layer 3 — Orchestrator
  └── re-due-diligence-orchestrator-il

Layer 2 — Cross-cutting concerns
  ├── legal-il                       (real estate, contract, registry mechanics)
  ├── tax-il-real-estate             (mas shevach, mas rechisha, VAT, betterment)
  ├── kyc-aml                        (sanctions, PEP, adverse media on principals)
  └── insurance-and-risk-transfer    (title insurance, builder's risk, etc.)

Layer 1 — Domain experts
  ├── re-valuation-il                (income, comps, replacement-cost approaches)
  ├── env-risk-il                    (contamination, ESA tiers)
  ├── corporate-records-il           (entity structure, UBOs, signatories)
  └── financial-stress-il            (rent roll, vacancy, debt service, sensitivities)

Layer 0 — Critical-thinking foundation
  └── input-scrutiny-and-risk-register
```

That's **10 skills**. Within target.

---

## Phase 4 — Per-skill briefs (abbreviated)

> In a real proposal each brief is a full filled `templates/skill_brief.md`. Abbreviated here for length.

**input-scrutiny-and-risk-register (Layer 0).** Foundation. Every skill above consults it. Job: walk the three-tier ladder for any input, emit a risk-register row, surface unverified residuals.

**re-valuation-il (Layer 1).** Commercial real-estate valuation in Israel. Three approaches (income / comps / replacement). Skeptical checks: are comps actually comparable (size, age, lease structure); is the cap rate consistent with bond yields; is the rent roll stress-tested. Out of scope: residential, agricultural, raw land development feasibility.

**env-risk-il (Layer 1).** Environmental risk for Israeli commercial property. Skeptical checks: prior industrial use within 250m; presence in המשרד להגנת הסביבה contaminated-sites DB; floodplain. Recommends Phase I ESA when triggered. Out of scope: full Phase II/III remediation design.

**corporate-records-il (Layer 1).** Israeli corporate-records analysis. Skeptical checks: nominee directors, recent share transfers, conflicting addresses. Out of scope: foreign entities (delegate to a sibling skill per jurisdiction).

**financial-stress-il (Layer 1).** Stress-tests rent rolls and debt service. Skeptical checks: vacancy assumptions vs. submarket reality, lease rollover concentration, FX exposure on dollar-denominated rents. Out of scope: corporate-finance modeling beyond the property.

**legal-il (Layer 2).** Israeli real-estate and contract law specifically — registry mechanics, חוזה מכר, encumbrances. Skeptical checks: missing הערות אזהרה, conflicting registrations, side letters in the file. Out of scope: litigation strategy, foreign counsel.

**tax-il-real-estate (Layer 2).** מס שבח, מס רכישה, VAT, היטל השבחה. Skeptical checks: prior transactions on the same parcel that affect the basis; חוק מיסוי דירת מגורים יחידה assumptions; betterment assessment status.

**kyc-aml (Layer 2).** Sanctions, PEP, adverse media — *not* jurisdiction-specific in the same way. Skeptical checks: name-permutation matching, transliteration variants (Hebrew↔Latin), corporate ownership chains.

**insurance-and-risk-transfer (Layer 2).** Translates residual risks into insurance products: title insurance, builder's risk, environmental liability. Skeptical checks: standard exclusions, prior-knowledge clauses.

**re-due-diligence-orchestrator-il (Layer 3).** Sequences the above on a specific property, deduplicates risks, produces the final DD report and the top-of-page "top 3 risks" line. Resolves conflicts (e.g., when valuation says 10M and stress-test implies 8M). Decides when to climb verification tiers.

---

## Phase 5 — Top-level risk register (of the skill set itself)

| id | risk | cause | L | I | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| R-SET-01 | Skill set gives advice that crosses into licensed practice (legal opinion, valuation cert) | Layer-2 skills can sound authoritative | M | H | Orchestrator emits a "for transaction reliance, retain a licensed [lawyer/appraiser]" footer; legal-il refuses to opine where a licensed שמאי or עו"ד is needed | Users may ignore the disclaimer | orchestrator + legal-il |
| R-SET-02 | Jurisdiction creep — used outside IL by accident | The user might not realize the `-il` tag | L | H | Skills assert the jurisdiction at start of every output; refuse to run on non-IL inputs | Hybrid deals (IL entity holding non-IL asset) still ambiguous | each Layer-2 skill |
| R-SET-03 | Decomposition overlaps with skills the user already has | Existing GCP skills, etc. | M | L | At Phase 5 we ask the user about existing skills and merge namespaces | New skills may shadow old ones | user |

---

## Phase 6 — Handoff order

If you approve the set, I'd hand off in this order to `skill-creator`:

1. `input-scrutiny-and-risk-register` (foundation; everything else cites it)
2. `re-valuation-il`, `env-risk-il`, `corporate-records-il`, `financial-stress-il` (Layer 1, in parallel)
3. `legal-il`, `tax-il-real-estate`, `kyc-aml`, `insurance-and-risk-transfer` (Layer 2, in parallel)
4. `re-due-diligence-orchestrator-il` (last; references the others by name)

The orchestrator goes last because its instructions name the leaf skills; those names need to be stable.

---

## What this set does NOT cover

- Residential housing law (חוק הגנת הדייר, etc.)
- Agricultural land or kibbutz/moshav holdings
- Cross-border tax structuring
- Litigation
- Construction-defect technical inspection (out of scope of `env-risk-il`; that's a different skill)

If any of those is in scope for your actual work, say so and we'll add a sibling skill.
