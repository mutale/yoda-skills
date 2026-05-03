---
name: il-construction-feasibility-and-cost
description: Israeli construction feasibility and cost benchmarking — realizable GFA after setbacks/parking/ממ"ד/accessibility/code minima, construction cost per m² benchmarks by type and area, אגרות והיטלים (development levies, building permit fees, חיבור תשתיות), parking ratios, foundation/soil cost premium, infrastructure connection costs. Triggers on construction cost, buildability, GFA realization, אגרות, היטלים, foundation premium, soil cost, parking ratio, ממ"ד, accessibility code for IL development sites — including casual phrasings like "what does it cost to build here", "is this lot actually buildable", "how much GFA can I really get".
---

## Inheritance
**Domain:** il-construction-feasibility-and-cost
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Theoretical GFA on a תב"ע often differs from realizable GFA by 10–25% once setbacks, parking, ממ"ד, accessibility, fire egress, and code minima are applied. Cost benchmarks vary widely by area and asset type. Soil and infrastructure premiums can be 5–15% of cost. Without this skill, the valuation and financial-stress skills work with the wrong numbers.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| תב"ע envelope | T2 | from zoning skill | what's permitted | what's realizable |
| Site geometry / topography | T1 | GIS / planning maps | shape, slopes | sub-surface conditions |
| Intended product / unit mix | T2 | user / valuation | scope | actual market fit |
| Existing soil/geotech reports | T2 | user-provided | bearing-capacity baseline | unsampled areas |

### Domain-specific skeptical checks

1. Realizable GFA vs. theoretical given setbacks, parking, ממ"ד, accessibility, fire egress, code minima?
2. Soil/foundation cost premium given soil report or area benchmarks (חוף, חמרה, חרסית)? If no soil report, recommend commissioning one.
3. Infrastructure connection costs (water/sewer/power/telecom/road)? אגרות והיטלים are often 5–10% of construction cost.
4. Code revisions in flight (thermal insulation, accessibility, parking minima) that change cost basis between now and permit issuance?

### Outputs (delta)

- Realizable program (units, GFA, parking, ancillary)
- Construction cost estimate with sensitivity bands (low/base/high; e.g., ±15%)
- אגרות/היטלים estimate
- Soil/foundation premium and recommended geotech climb (if needed)
- Risk-register entries with prefixes `R-FEAS-`, `R-COST-`, `R-INFRA-`

### Quantification unit

₪ (cost), m² (program). Risk impact in ₪.

### Out of scope

Detailed architecture/engineering (this is feasibility-stage; produces inputs for an architect, not the architect's output) · Final valuation · Foreign jurisdictions.

### Consulted by

orchestrator, il-real-estate-valuation-development, il-development-financial-stress.

### Consults

il-zoning-and-planning, il-environmental-and-soil-risk, input-scrutiny-and-risk-register.
