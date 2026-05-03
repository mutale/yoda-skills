---
name: il-zoning-and-planning
description: Israeli zoning, planning, and entitlements — תב"ע (תכנית בניין עיר) status (existing/in-process/none), permitted use, GFA/density/height entitlements, public-facility allocations (שצ"פ, שב"צ), הפקעות (expropriation) risk, building permits (היתרי בנייה), ועדה מקומית and ועדה מחוזית processes, פינוי-בינוי / תמ"א 38 / תמ"א 70 implications. Triggers on תב"ע, planning, zoning, entitlements, GFA, height limits, היתר בנייה, ועדה מקומית/מחוזית, הפקעה, פינוי בינוי, תמ"א, מינהל התכנון, רישוי זמין for any IL real-estate-development question — including casual phrasings like "what can I build here", "what's allowed on this lot", "is the תב"ע final".
---

## Inheritance
**Domain:** il-zoning-and-planning
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

For development sites, the תב"ע determines value. An in-process תב"ע has a huge value gap from an approved one (often 30–60%). הפקעות risk (planned roads, parks) can wipe value. Recent committee minutes affect everything. Without a planning specialist in the skill set, the orchestrator can't price entitlement risk, and the legal/valuation skills don't have stable inputs.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Block/parcel | T1 | מינהל התכנון GIS-N / עיריות | תב"ע status, current entitlements | In-process modifications not yet published |
| Intended use | T2 | User context | Which entitlements matter | Whether intended use will pass committee |
| Specific planning questions | T2 | User context | What user is concerned about | Adjacent planning that affects this parcel |

### Domain-specific skeptical checks

1. Is the תב"ע **final**, **in-process**, or **none**? What's the value gap if in-process — and the realistic timeline / probability of approval?
2. Planned הפקעות (highway, רכבת, public facilities)? Public-facility allocations (שצ"פ/שב"צ) inside the parcel?
3. Recent committee modifications, התנגדויות, pending עררים?
4. Sectoral planning regime — תמ"א 38, תמ"א 70, פינוי-בינוי, מתחם פינוי-בינוי?

### Outputs (delta)

- Planning summary (status, current entitlements, trajectory)
- GFA/density/height/use envelope
- הפקעות risk assessment
- Planning timeline + scenario tree (if in-process)
- Risk-register entries with prefixes `R-ZONE-`, `R-PLAN-`, `R-EXPROP-`

### Quantification unit

₪. Often expressed as "value gap if approval slips by N months" or "value at risk from expropriation."

### Out of scope

Physical buildability (feasibility skill) · Legal contract clauses (legal-development) · Tax consequences (tax-development) · Foreign jurisdictions.

### Consulted by

orchestrator, il-real-estate-valuation-development, il-construction-feasibility-and-cost, il-real-estate-legal-development, il-tax-real-estate-development.

### Consults

il-land-registry-and-rmi (for parcel identifiers), input-scrutiny-and-risk-register.
