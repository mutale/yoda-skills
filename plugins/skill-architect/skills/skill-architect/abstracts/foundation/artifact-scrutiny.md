# Abstract: artifact-scrutiny (foundation)

**Domain:** artifact-scrutiny
**Level:** FOUNDATION
**Inherits From:** none (foundation root)

> A foundation abstract. The dual of input-scrutiny — input-scrutiny verifies what comes IN, artifact-scrutiny verifies what goes OUT before another skill consumes it. Every skill set should have at least one instance.

## Purpose

A leaf skill can produce a well-intentioned but malformed output: missing sections, unsupported claims, scope leakage into another skill's territory, internal inconsistencies, or a risk register with empty residuals. If those artifacts feed downstream skills (or the orchestrator), the errors compound. Artifact-scrutiny is the gate that catches this before propagation.

## Inheritance

Foundation abstract. Symmetric with `input-scrutiny`.

## Contract — every concrete artifact-scrutiny instance must

1. **Validate format** — does the artifact include the sections its abstract requires?
2. **Validate citation completeness** — are all consequential claims sourced? Any uncited assertions are flagged.
3. **Validate risk-register well-formedness** per the `risk-register-manager` schema (no empty residuals, no missing owners, no hand-wave mitigations).
4. **Detect internal inconsistencies** — does the artifact contradict itself (e.g., "low risk" plus a high-impact unmitigated entry in its own register)?
5. **Detect scope leakage** — has the producing skill answered questions outside its declared scope? If yes, route those answers to the right skill or strip them.
6. **Surface unverified claims** that the producing skill should have surfaced but didn't.
7. **Be advisory, not blocking** — emit findings; the orchestrator decides whether to send the artifact back for rework.

## Required SKILL.md sections (in addition to standard)

- **Validation checklist** — per artifact type (DD report, IRR model, legal memo, etc.)
- **Routing rules** — when scope leakage is detected, where to send it
- **Severity grading** — which findings block, which warn, which inform

## Skeptical checks any concrete artifact-scrutiny instance must run

1. Are **all required sections** present? (Per the producing skill's abstract.)
2. Does **every quantitative claim** trace back to a cited source?
3. Is **the risk register schema-compliant**? (Per `risk-register-manager`.)
4. Does the artifact **stay within its own scope**? Or has it leaked into another skill's territory?
5. Are there **internal contradictions**?
6. Are **unverified residuals** surfaced explicitly, or hidden?

## Standard outputs every concrete must produce

- Validation report (per-section pass/fail)
- Findings list with severity (block / warn / inform)
- Suggested rework if applicable
- Routing recommendations for scope-leaked content

## Specialization axes

- Artifact type (DD report, IRR model, deployment plan, audit memo, ...)
- Domain (real estate, technical, legal, financial)
- Strictness mode (pre-publish gate vs. periodic audit)

## Anti-patterns

- **Approving artifacts without checking citations.** "Looks good" is not validation.
- **Silently rewriting.** Artifact-scrutiny finds issues; it doesn't ghost-write fixes for the producing skill.
- **Block-on-warn.** Conflating advisory findings with blocking findings degrades the gate.
- **Ignoring scope leakage.** Letting one skill answer questions outside its scope is how skill sets degrade into monoliths.
