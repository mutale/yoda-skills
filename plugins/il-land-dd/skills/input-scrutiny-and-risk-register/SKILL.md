---
name: input-scrutiny-and-risk-register
description: Foundational critical-thinking skill that scrutinizes user-provided inputs before any consequential analysis. Triggers whenever Claude is given inputs that drive a decision with legal, financial, regulatory, or safety consequences — purchases, due diligence, compliance reviews, lending, hiring, deployment, audits, M&A. Walks the three-tier verification ladder (public → private from user → paid/manual), names specific sources and cost bands, and emits a standardized risk register at the end of any analysis. Make sure to use this skill whenever any other skill produces an output that informs a real-world decision, and whenever the user provides claims about ownership, identity, financial position, regulatory status, or technical configuration — including informal phrasings like "I want to verify…", "how do I check…", "is this real…", "make sure this is legit".
---

## Inheritance
**Domain:** input-scrutiny-and-risk-register
**Level:** CONCRETE
**Inherits From:** input-scrutiny (foundation), risk-register-manager (foundation)

**READ FIRST (in order):**
1. ../../../skill-architect/abstracts/foundation/input-scrutiny.md
2. ../../../skill-architect/abstracts/foundation/risk-register-manager.md

**THEN APPLY THE DELTA BELOW.**

---

## Specialization (delta from inherited contracts)

This skill is the cross-cutting foundation consulted by every other skill in any decomposed skill set. It is domain-agnostic; the *climb policy* is calibrated by the calling skill, but the discipline lives here.

### How callers invoke this skill

A calling skill says: *"Apply input-scrutiny to input X, consequence-cost <high/med/low>, default tier <T1/T2/T3>, domain <real-estate / corporate / technical / etc.>"*

This skill returns the standard outputs from the inherited contracts (verification report, risk-register entries, residuals list). No deviations from the inherited shape.

### Calibration the caller supplies

- Consequence-cost band (financial / regulatory / reputational impact of being wrong)
- Domain-specific T1 sources the caller wants used
- Whether T3 is authorized (paid vendors, expert review)

### What this skill does NOT do

- Domain-specific verification mechanics (how Tabu actually works, how OFAC structures lists, what a SOC 2 Type II report contains) — those live in domain skills.
- Recommendations on whether to proceed (orchestrator decides go/no-go).
- Any analytical opinion. Verifies; does not opine.

### Skeptical checks

Inherited from `input-scrutiny`. No domain-specific additions — calibration comes from the caller.

### Outputs

Inherited from `input-scrutiny` + `risk-register-manager`. Section order in the output: **(1) must-tell-the-user residuals at the top**, (2) per-input verification report, (3) risk-register table. Users skim — residuals must not be buried.

### Risk-prefix taxonomy (use stable IDs across skills that emit registers)

`R-LEGAL-*` · `R-FIN-*` · `R-REG-*` · `R-IDENT-*` · `R-TECH-*` · `R-ENV-*` · `R-OPS-*` · `R-INFO-*` · `R-OTHER-*` (with explanation).

### Notes

This skill is intended to be **shared across every skill set**. Future plugins can declare a dependency on it rather than each plugin shipping its own. When `critical-thinking-foundation@yoda-skills` exists as a separate plugin, this skill migrates there.
