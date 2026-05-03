---
name: il-development-financial-stress
description: Israeli real-estate development financial modeling and stress-testing — project IRR, equity IRR, NPV, sensitivity to cost overruns, sales velocity, debt service coverage, covenant analysis, lease-up assumptions for rental product, after-tax IRR. Triggers on IRR, NPV, project finance, equity IRR, debt service, DSCR, financial model, sensitivity analysis, stress-test, covenant compliance, after-tax return, מימון פרויקט for IL real-estate development — including casual phrasings like "does this deal pencil", "what's the return", "what if costs go up".
---

## Inheritance
**Domain:** il-development-financial-stress
**Level:** CONCRETE
**Inherits From:** risk-register-manager (foundation), due-diligence (domain)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/risk-register-manager.md
2. ../../../skill-architect/abstracts/domain/due-diligence.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

### Why this skill exists

Pretty IRRs at base case mean nothing. IC decisions hinge on stress-test outputs (cost overrun + sales delay + covenant breach scenarios). Israeli development has idiosyncratic financing structures (חשבון ליווי, financing-bank monitoring, presale gating) that change cash-flow shape. Without this skill, the orchestrator cannot recommend go/no-go/conditional with confidence.

### Inputs

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| Construction cost + timing | T2 | from feasibility skill | Base-case cost | Actual cost realization |
| End-product value + timing | T2 | from valuation skill | Base-case revenue | Actual sales velocity |
| Debt terms | T2 | user-provided term sheet | Financing assumptions | Covenant operationality |
| Tax leakage | T2 | from tax skill | After-tax basis | Future tax law changes |

### Domain-specific skeptical checks

1. Construction-cost contingency adequate? IL development typically runs **+10% to +20% over baseline** — model both.
2. Absorption / sales velocity realistic? Equity IRR at **70% of base velocity** with **+15% cost overrun** simultaneously?
3. Debt covenants (LTV, LTC, DSCR, presale percentage) breach in any plausible scenario? Covenant breach can be a default event even at positive IRR.
4. Financing-bank's חשבון ליווי schedule modeled correctly — held-back disbursements, presale gating?

### Outputs (delta)

- Project IRR + equity IRR (base case)
- Sensitivity matrix (cost vs. velocity at minimum)
- Stress scenarios (combined adverse, covenant breach)
- Recommended pricing — IRR-equivalent land price at acceptable risk
- After-tax IRR (consulting tax skill)
- Risk-register entries with prefixes `R-FIN-*`, `R-COV-*`, `R-LIQ-*`

### Quantification unit

₪ (cash-flow), % (IRR / DSCR / LTV). Risk impact in equity IRR delta or covenant-headroom delta.

### Out of scope

Capital-raise logistics (LP/GP economics) · Bank loan negotiation · Treasury/hedging strategy · Foreign jurisdictions.

### Consulted by

orchestrator.

### Consults

il-construction-feasibility-and-cost · il-real-estate-valuation-development · il-tax-real-estate-development · input-scrutiny-and-risk-register.
