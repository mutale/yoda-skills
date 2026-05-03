---
name: insurance-and-risk-transfer-development
description: Insurance and risk-transfer products for real-estate development — title insurance, builder's all-risk (CAR/EAR — Contractor's All Risks / Erection All Risks), environmental impairment liability, latent-defect / decennial liability (אחריות לקויים, IL חוק המכר דירות), professional liability of consultants, owner-controlled (OCIP) vs. contractor-controlled (CCIP) insurance programs. Triggers on title insurance, builder's risk, CAR insurance, environmental insurance, environmental impairment liability, latent-defect, אחריות לקויים, OCIP, CCIP, decennial, professional indemnity for real-estate development — including casual phrasings like "what insurance do I need", "can we insure around this risk".
---

## Inheritance
**Domain:** insurance-and-risk-transfer-development
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Many residual risks surfaced by other skills are best mitigated through insurance products, not contract clauses. Understanding what insurance actually covers (and excludes) is its own competence — title insurers exclude government expropriation; environmental impairment policies usually exclude pre-existing contamination unless specifically endorsed; builder's risk has gaps around testing/commissioning. Naive contract drafting that pushes risk to a counterparty often runs into "unenforceable" or "uninsured anyway" — the insurance lens reframes that.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Residual risks from all other skills | T2 | the orchestrator + each leaf | What's left unaddressed | Risks not yet identified |
| Project type, cost, schedule | T2 | feasibility + financial-stress | Scope of cover needed | Scope creep |
| Buyer / developer profile | T2 | user | Insurer appetite | Reputational issues |
| Existing insurer relationships | T2 | user | Available wordings | Non-standard exclusions |

### Domain-specific skeptical checks

1. What does the **title insurer specifically exclude**? IL title insurance is uncommon and many policies have broad exclusions; gov-expropriation, hidden encumbrances, rights-of-way are common gaps.
2. Does **environmental impairment liability** policy exclude **pre-existing contamination**? If yes, it doesn't transfer the risk you actually have.
3. Is the **insurer financially rated** and IL-licensed? Unrated/non-licensed insurers create their own counterparty risk.
4. **OCIP vs. CCIP** — who carries the program, does the project's risk profile fit? Multiple-tier subcontracting often makes CCIP messy.

### Outputs (delta)

- Recommended insurance program by risk
- Mapping: residual risk → recommended product → typical exclusions to negotiate
- Premium estimate band per product
- Insurer-rating and licensing flags
- Risk-register entries with prefixes `R-INSGAP-*`, `R-INSCOUNTERPARTY-*` (gaps that *can't* be insured economically)

### Quantification unit

₪ (premium estimates) and ₪ (residual gaps not insurable).

### Out of scope

Actual insurance broking or placement (defers to licensed broker) · Claim handling · Captive-insurance structuring · Foreign jurisdictions (decennial / latent-defect mechanics differ in EU vs. IL).

### Consulted by

orchestrator.

### Consults

All Layer-1 skills (for residual risks each surfaces) · input-scrutiny-and-risk-register.
