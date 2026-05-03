---
name: il-land-registry-and-rmi
description: Israeli land registry mechanics — Tabu (לשכת רישום מקרקעין), RMI (רשות מקרקעי ישראל) lease analysis, חכירה vs. בעלות, היוון status, registry abstracts (נסח טאבו), הערות אזהרה, encumbrances, pre-emption rights, registration history. Triggers on Tabu, נסח, gush/chelka, גוש, חלקה, חכירה, RMI, רמ"י, מינהל מקרקעי ישראל, היוון, הערת אזהרה, registry, ownership history, leasehold for any IL real-estate question — including informal phrasings like "who owns this lot", "what's the Tabu say", "is this freehold or state-leased". Make sure to use this whenever a user is dealing with IL real estate and needs to understand the registered status of a parcel.
---

## Inheritance
**Domain:** il-land-registry-and-rmi
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists in the IL-DD set

~93% of Israeli land is state-owned and leased (חכירה) rather than freehold (בעלות). חכירה terms vary widely: 49 vs. 98 years; היוון done or not; capitalization payments outstanding; pre-emption rights; exit rights. Tabu mechanics (gush/chelka, sub-parcels, חלקות עזר, הערות אזהרה) don't translate to common-law analogues. Getting this wrong materially mis-prices a deal and creates legal exposure.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Address or gush/חלקה | T1 | Public Tabu viewer / GIS-N | Site identifiers | Recent unrecorded changes |
| Recorded ownership / lease | T1 → T3 | Public Tabu (T1) → paid נסח טאבו מהותי + RMI חוזה חכירה (T3, ~₪40–₪500) | Ownership of record, lease terms | Off-record nominees, side letters |
| Specific encumbrance question | T2 | User-provided context | What user is concerned about | Encumbrances user didn't think to ask |

### Domain-specific skeptical checks (in addition to inherited DD checks)

1. בעלות or חכירה? If חכירה: remaining term, היוון done, renewal/exit terms — most surprises live here.
2. Pre-emption rights, options, recorded הערות אזהרה? Conflicting registrations?
3. Seller of record same as negotiating party? (Common issue when corporate sellers haven't registered transfers internally.)
4. Off-record encumbrances — RMI side letters, municipal liens, agricultural restrictions, unregistered security interests?

### Outputs (delta on top of standard register output)

- Registry analysis (current status + history)
- Encumbrance summary
- Lease analysis if חכירה (remaining term, היוון, renewal, exit, restrictions)
- Risk-register entries with prefixes `R-REG-*`, `R-OWN-*`, `R-RMI-*`, `R-LIEN-*`

### Risk taxonomy

- `R-REG-*` registry-mechanics · `R-OWN-*` ownership-clarity · `R-RMI-*` RMI-lease-specific · `R-LIEN-*` encumbrance.

### Quantification unit

₪. Risk impact stated as effect on deal value or liability exposure.

### Mandatory T3 climb policy

Always climb input #2 to T3 — recorded liens have legal effect; never rely on T1 abstract alone for a transaction.

### Out of scope

Physical site condition (env-and-soil) · Contract drafting/interpretation (legal-development) · Valuation logic · Foreign-jurisdiction registries.

### Consulted by

orchestrator · il-real-estate-legal-development · il-real-estate-valuation-development · il-tax-real-estate-development · insurance-and-risk-transfer-development.

### Consults

input-scrutiny-and-risk-register.
