---
name: corporate-records-il-and-kyc-aml
description: Israeli corporate-records analysis combined with KYC / AML / sanctions screening — entity check (רשם החברות, רשם העמותות, רשם השותפויות), ultimate beneficial ownership (UBO), director/signatory authority and current authorization, share-transfer history, sanctions screening (OFAC / EU / UN / UK / IL), PEP exposure, adverse media with Hebrew↔Latin transliteration handling. Triggers on entity DD, KYC, UBO, beneficial ownership, signatory authority, sanctions screening, PEP, adverse media, רשם החברות, מורשי חתימה, ייפוי כוח, נושאי משרה for any IL counterparty (real estate or otherwise) — including informal phrasings like "is this counterparty legit", "who's actually behind this company", "are they on any sanctions list".
---

## Inheritance
**Domain:** corporate-records-il-and-kyc-aml
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Counterparty identity and signatory authority drive transaction validity. Sanctions/PEP creates regulatory exposure (Israeli Anti-Money-Laundering Authority + foreign equivalents). Hebrew↔Latin name matching is its own competence — sanctions lists are in Latin, IL counterparties register in Hebrew, and standard transliterations vary. Skipping this creates real-money risk of dealing with a sanctioned party or one whose signatory cannot bind the entity.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Entity name + ID | T1 | רשם החברות / עמותות / שותפויות (free) | Basic entity facts | Recent unrecorded changes |
| Recent corporate filings | T1→T3 | רשם החברות (T1) → paid corporate-records vendor (T3, ~₪50–500) | Directors, share transfers, signatories | Off-record nominees |
| Beneficial-ownership claim | T2→T3 | user (T2) → enhanced DD vendor (T3, $500–5,000) | UBO chain | Nominees / trustee structures |
| Sanctions / PEP / adverse media | T1→T3 | OFAC, EU, UN free lists (T1) → WorldCheck/Refinitiv (T3, $50–500/subject) | Listed status | Recent unlisted activity |
| Hebrew/Latin name variants | T1 | transliteration generation (built-in) | Name-permutation matching | Uncommon spellings |

### Domain-specific skeptical checks

1. Is **signatory authority current** (not just at incorporation)? Recent מינוי דירקטורים / שינוי מורשי חתימה can invalidate prior power-of-attorney arrangements.
2. **Nominees, trustees, fiduciaries** between registered shareholders and actual UBO?
3. Have **all reasonable Hebrew/Latin name variants** been screened? (e.g., יצחק = Yitzhak/Yizhak/Itzhak/Isaac; שלמה = Shlomo/Shlomi/Solomon.)
4. **Adverse media in Hebrew sources** (TheMarker, Calcalist, Globes, Ynet) that wouldn't show in Latin-only screen?

### Outputs (delta)

- Entity analysis (name, status, directors, recent changes)
- UBO map (with assumed-vs-verified annotations)
- Signatory authority analysis with explicit "who can sign what today"
- Sanctions/PEP/adverse-media report with sources cited
- Risk-register entries with prefixes `R-IDENT-*`, `R-SIG-*`, `R-SANCT-*`
- Recommended T3 climbs and cost bands

### Quantification unit

₪ (transaction value at risk) or qualitative regulatory-exposure tier (low/med/high).

### Out of scope

Foreign-jurisdiction entity DD (clone for `corporate-records-us-*` etc.) · Tactical KYC remediation · Financial-position / credit DD on the entity (different skill).

### Consulted by

orchestrator · il-real-estate-legal-development · il-tax-real-estate-development.

### Consults

input-scrutiny-and-risk-register.
