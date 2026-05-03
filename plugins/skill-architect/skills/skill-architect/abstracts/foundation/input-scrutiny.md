# Abstract: input-scrutiny (foundation)

**Domain:** input-scrutiny
**Level:** FOUNDATION
**Inherits From:** none (foundation root)

> A foundation abstract. Every skill set has at least one input-scrutiny instance — usually shared across sets via a common foundation skill.

## Purpose

Inputs (user-provided claims, third-party data, prior reports) drive every downstream analysis. Without an input-scrutiny gate, errors in the inputs propagate and amplify. Input-scrutiny verifies inputs against the **three-tier ladder** (public → private from user → paid/manual), surfaces what's still unverified, and emits risk-register entries for unresolved gaps.

## Inheritance

Foundation abstract. Conforms to nothing; everything that gates inputs inherits from it.

## Contract — every concrete input-scrutiny instance must

1. **Walk the three-tier ladder for every consequential input:**
   - **T1 — Public:** free, no user action. Must cite the source.
   - **T2 — Private from user:** user effort, no money. Must phrase the ask narrowly.
   - **T3 — Paid / manual:** money or expert time. Must name the vendor / method and a cost band.
2. **State the climb policy** — when to escalate from T1 to T2, and from T2 to T3, including the consequence-cost vs. verification-cost tradeoff.
3. **Surface what is still unverified** after the climb. Never claim "fully verified."
4. **Emit a risk-register entry** for every unresolved gap.
5. **Be skeptical without being blocking.** Always offer a "proceed-with-caveat" path with caveats spelled out.
6. **Identify adversarial incentives:** does any party have an incentive to misrepresent this input?

## Required SKILL.md sections (in addition to standard)

- **Tier ladder** — explicit T1/T2/T3 sources for every input the skill expects
- **Climb policy** — when to escalate
- **Surface-the-unverified summary** — top-of-page residuals list

## Skeptical checks any concrete input-scrutiny instance must run

1. Does any party have an **incentive to misrepresent** this input?
2. Is there a **publicly verifiable equivalent (T1)**? If yes, climb T1 before accepting.
3. Is the **cost of being wrong materially higher** than the verification cost? If yes, climb to T3.
4. After all climbs, **what is still unverified?** Surface explicitly.

## Standard outputs every concrete must produce

- Verification report per input (tier reached, source cited, what verified, what unverified)
- Risk-register entries scoped to verification gaps
- "Must-tell-the-user" residuals list at top

## Specialization axes

- Domain (real-estate inputs vs. corporate inputs vs. technical inputs)
- Jurisdiction (T1 sources are jurisdiction-specific)
- Risk tolerance (tighter for regulated industries)

## Anti-patterns

- **"Trust the user."** Even a sincere user can be wrong about ownership, encumbrances, status.
- **"Fully verified."** Always something residual; never claim total verification.
- **Hand-wave T3** — "use a paid vendor" without naming one is useless. Name vendor + cost band.
- **Blocking on unverified inputs** — surface and proceed with caveats, don't refuse to analyze.
