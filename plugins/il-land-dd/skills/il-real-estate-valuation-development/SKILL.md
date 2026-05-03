---
name: il-real-estate-valuation-development
description: Israeli real-estate valuation for land and development sites — residual land valuation (back into land value from finished-product market value, minus cost, profit, finance), comparable-transactions method, replacement-cost reconciliation, sensitivity to development period and absorption rate. Triggers on land valuation, residual valuation, שמאות מקרקעין, comparable sales, comp analysis, residual method, market value of land, מחיר קרקע, value of development site for IL real estate — including casual phrasings like "what's this lot worth", "am I paying too much", "what should I bid".
---

## Inheritance
**Domain:** il-real-estate-valuation-development
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Land for development is valued differently from built property — value is "residual" after backing out construction cost, developer profit margin, and finance cost from the eventual finished-product market value. Get any of those wrong and the land value swings 30%+. Valuation is a regulated profession in IL (שמאי מקרקעין מוסמך), so this skill explicitly defers to a licensed שמאי for transaction reliance.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Planning entitlements | T2 | from zoning skill | What can be built | Future entitlement changes |
| Realizable program | T2 | from feasibility skill | What will be built | Actual market reception |
| Construction cost | T2 | from feasibility skill | Development cost basis | Cost inflation |
| Finished-product comps | T1 | רשות המסים — נתוני עסקאות | Recent comparable sales | Off-market transactions |
| Rental comps (if for-rent) | T1 | מדלן/Yad2/aggregators | Asking-rent benchmark | Actual achieved rent |

### Domain-specific skeptical checks

1. End-product comps actually comparable in size, age, location quality, lease/sale structure? Most comp analyses fail here.
2. Absorption / sales velocity defensible? Stress at 70% of base — does residual hold?
3. Development period realistic given planning, permitting, construction, lease-up? Each year compounds the discount.
4. Local market saturated? How many comparable projects in delivery within catchment over next 24 months?

### Outputs (delta)

- Residual land valuation with sensitivity bands (low/base/high)
- Comp analysis with explicit comparability commentary (not just price-per-m² table)
- Replacement-cost cross-check
- Recommended price band
- Risk-register entries with prefixes `R-VAL-*`, `R-MARKET-*`
- **Disclaimer**: for transaction reliance retain a licensed שמאי מקרקעין

### Quantification unit

₪. Risk impact as % of land value or total deal value.

### Out of scope

Licensed שמאי opinion (defers) · Financing math (financial-stress) · Strategic decisions about whether to bid (orchestrator) · Foreign jurisdictions.

### Consulted by

orchestrator · il-development-financial-stress.

### Consults

il-zoning-and-planning · il-construction-feasibility-and-cost · il-tax-real-estate-development (for tax leakage) · input-scrutiny-and-risk-register.
