---
name: il-tax-real-estate-development
description: Israeli real-estate development taxation — מס רכישה (purchase tax with brackets for residence vs. non-residence vs. investment), היטל השבחה (betterment levy — often 50% of value uplift), מס שבח / מס שבח חברה, מע"מ on land transactions and developer status (עוסק במקרקעין), חוק מיסוי מקרקעין benefits, sectoral incentives (חוק עידוד), purchase structure optimization (corporate vs. individual). Triggers on Israeli real-estate tax, מס רכישה, היטל השבחה, betterment, מס שבח, VAT on land, מע"מ נדל"ן, פטור עידוד, חוק מיסוי מקרקעין, after-tax return for IL real-estate development — including casual phrasings like "what's the tax bill", "should I buy through a company", "what's the betterment hit".
---

## Inheritance
**Domain:** il-tax-real-estate-development
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

היטל השבחה alone can be 50% of value uplift after planning approval. VAT on land transactions is non-trivial and depends on seller status. חוק עידוד benefits can swing economics by 20%+. Tax leakage kills IRRs that look healthy pre-tax. Purchase-structure choice (individual / corporate / trust) materially affects total tax burden and can't be reversed cheaply post-closing.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Transaction price | T2 | user / contract | Base for purchase tax | Adjustments under consideration |
| Seller status (individual / עוסק / corporate / foreign) | T2 | from corporate-records | VAT treatment | Recent status changes |
| Planning trajectory | T2 | from zoning skill | Future betterment trigger | Planning timing risk |
| Prior transactions on parcel | T1 | רשות המסים — נתוני עסקאות | Basis tracking | Unrecorded historical transactions |
| Buyer's tax status | T2 | user-provided | Bracket / corporate rate | Unrelated tax issues |

### Domain-specific skeptical checks

1. **היטל השבחה** triggered but not yet assessed? Common surprise — a planning decision years ago can produce an unassessed levy that hits the buyer post-closing if not allocated in the contract.
2. Will planned development trigger fresh השבחה? Who bears it (seller via deduction from price, or buyer)?
3. Is the seller a "**עוסק במקרקעין**" for VAT purposes? Changes whether VAT is added on the price and whether the buyer can recover input VAT.
4. **חוק עידוד** benefits available (e.g., דיור להשכרה)?

### Outputs (delta)

- Tax model: purchase tax + השבחה + VAT path + ongoing tax during development + מס שבח at exit
- Tax leakage estimate as % of equity
- Recommended purchase structure (individual / corporate / trust / partnership)
- Trigger map for future levies (when does fresh השבחה hit?)
- Risk-register entries with prefixes `R-TAX-*`, `R-VAT-*`, `R-BETTER-*`
- **Disclaimer**: for transaction reliance retain a licensed יועץ מס or רו"ח

### Quantification unit

₪. Risk impact as tax leakage in absolute terms or % of equity.

### Out of scope

Licensed CPA opinion (defers) · Corporate tax planning beyond the parcel transaction · Personal tax strategy unrelated to the deal · Foreign jurisdictions.

### Consulted by

orchestrator · il-real-estate-valuation-development · il-development-financial-stress · il-real-estate-legal-development.

### Consults

il-zoning-and-planning · il-land-registry-and-rmi · corporate-records-il-and-kyc-aml · input-scrutiny-and-risk-register.
