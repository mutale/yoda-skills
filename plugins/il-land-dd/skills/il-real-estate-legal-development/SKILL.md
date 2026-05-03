---
name: il-real-estate-legal-development
description: Israeli real-estate contract and legal mechanics for land and development deals — purchase contract structure (חוזה מכר), contingencies (התניית רישוי, התניית מימון, התניית תכנון), encumbrances cleanup, registration timeline, side-letters, special clauses, deposit and forfeiture mechanics, escrow/נאמנות, special conditions for חכירה transfers. Triggers on land contract, חוזה מכר, real-estate contract, contingencies, התניות, registration timeline, side-letter, נאמנות, deposit forfeiture, encumbrances cleanup, IL real-estate law for development deals — including casual phrasings like "what should I put in the contract", "what protects me if rezoning fails", "is this contract actually safe".
---

## Inheritance
**Domain:** il-real-estate-legal-development
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

IL land deals have unique mechanics (חוזה מותנה ברישוי, התניות מכר, התניות תכנון) that don't translate cleanly to common-law analogues. Getting contingency triggers and consequences wrong can leave the buyer holding a non-refundable deposit on a deal that fails for reasons outside their control. Side letters often contain the real economic deal, separate from the registered contract.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Draft purchase contract | T2 | user-provided | Proposed terms | Terms not yet drafted |
| Title status | T2 | from registry-rmi skill | Clean-title path | Off-record encumbrances |
| Planning status | T2 | from zoning skill | What's permitted | Future planning changes |
| Counterparty status | T2 | from corporate-records skill | Who's signing | Nominees / undisclosed UBOs |

### Domain-specific skeptical checks

1. Which contingencies actually **protect the buyer financially** if rezoning, permitting, or financing fails? Vague language ("subject to obtaining permits") is worthless without trigger conditions and remedies.
2. Side letters between parties that change the economics of the registered contract? Common in IL deals.
3. Title clean enough to transfer on closing, or does cleanup happen pre-/post-closing? Registration timeline + delay risk?
4. Deposit and forfeiture mechanics calibrated to actual risk allocation? Deposit held in נאמנות by neutral party?

### Outputs (delta)

- Contract analysis (clause-by-clause, attention to contingencies and remedies)
- Contingency map: trigger → consequence → who bears risk
- Encumbrances cleanup plan
- Registration timeline + risks
- Side-letter detection / questions to ask the seller
- Risk-register entries with prefixes `R-CONT-*`, `R-CLAUSE-*`, `R-REG-DELAY-*`
- **Disclaimer**: for transaction execution retain a licensed עו"ד מקרקעין

### Quantification unit

₪. Risk impact as deposit-at-risk, total exposure, or remedies value.

### Out of scope

Litigation strategy · Foreign-law counsel · Drafting of final, signature-ready clauses (defers to licensed עו"ד) · Foreign jurisdictions.

### Consulted by

orchestrator · insurance-and-risk-transfer-development.

### Consults

il-land-registry-and-rmi · il-zoning-and-planning · il-tax-real-estate-development · corporate-records-il-and-kyc-aml · input-scrutiny-and-risk-register.
