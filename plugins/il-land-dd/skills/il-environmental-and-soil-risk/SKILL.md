---
name: il-environmental-and-soil-risk
description: Israeli environmental and soil risk for real estate — recorded contamination history, prior industrial use, המשרד להגנת הסביבה DB, hydrology and flood risk, soil-bearing capacity, asbestos in adjacent demolitions, ESA tiering (Phase I → Phase II → remediation design recommendation). Triggers on environmental DD, soil contamination, Phase I ESA, Phase II ESA, hydrology, geotech, flood risk, asbestos, contaminated land, prior industrial use, גז סולר, מתחת לקרקע, dry cleaning for any IL real-estate site — including casual phrasings like "is this site clean", "could there be contamination", "anything weird in the soil".
---

## Inheritance
**Domain:** il-environmental-and-soil-risk
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Sub-surface contamination can be 10–50% of project cost to remediate — some sites are economically un-developable. Israeli regulators have shifted significantly over the last decade; "clean" 15 years ago may be flagged today. Hydrology, flood, and soil-bearing data are usually unknown until tested. Without this skill, the orchestrator cannot price environmental risk or recommend the right ESA tier.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Site location | T1 | המשרד להגנת הסביבה DB, GIS hydrology layers | Listed contamination, flood/hydrology | Sub-surface anomalies |
| Prior use history | T1→T2 | Aerial photo archives + יישום ישן records (T1), user-provided history (T2) | Known prior uses on/near site | Unrecorded uses |
| Existing soil/env reports | T2 | User-provided | Reported findings baseline | What wasn't sampled |
| Adjacent uses ≤250m | T1 | Municipal records, GIS | Recorded uses | Informal/unrecorded operations |

### Domain-specific skeptical checks

1. Has this or any **adjacent site (≤250m)** ever held fuel, chemicals, dry-cleaning, printing, manufacturing, auto-service? Classic contamination signals.
2. Groundwater status — depth, flow direction, protected aquifer? Hydrology spreads contamination from off-site.
3. Soil-bearing capacity (גידי, חמרה, חרסית) and seismic risk for region?
4. Asbestos exposure from adjacent demolitions or existing structures?

### Outputs (delta)

- ESA tier recommendation (Phase I / Phase II / remediation design)
- Contamination risk summary with cited sources
- Hydrology and flood flags
- Geotech recommendation if no current report
- Cost-band estimate for recommended ESA work (Phase I ~₪5,000–15,000; Phase II ~₪15,000–₪50,000+)
- Risk-register entries with prefix `R-ENV-*`

### Quantification unit

₪. Risk impact often as estimated remediation cost or value-at-risk if contamination materializes.

### Mandatory T3 climb policy

Climb to commissioned Phase I ESA if any adjacent prior industrial use is found in T1.

### Out of scope

Actual remediation design (separate, more specialized skill) · Structural engineering (feasibility's job to surface, then licensed engineer) · Environmental permitting · Foreign jurisdictions.

### Consulted by

orchestrator · il-construction-feasibility-and-cost · il-real-estate-valuation-development · insurance-and-risk-transfer-development.

### Consults

input-scrutiny-and-risk-register.
