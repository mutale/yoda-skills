# Abstract: risk-register-manager (foundation)

**Domain:** risk-register-manager
**Level:** FOUNDATION
**Inherits From:** none (foundation root)

> A foundation abstract. Defines the schema and discipline for the risk register that every produced artifact emits.

## Purpose

A risk register is the canonical way every skill in the system communicates "what could go wrong, how likely, how bad, what to do, what's left." Without a shared schema and discipline, risk registers become inconsistent prose that the orchestrator cannot deduplicate or prioritize. This abstract defines the schema, the dedup logic, and the prioritization rules.

## Inheritance

Foundation abstract. Used by every skill that produces an artifact (i.e., almost all of them).

## Contract — every risk register must conform to this schema

| Field | Required | Description |
|---|---|---|
| `id` | yes | Stable ID, prefixed by domain (e.g., `R-LEGAL-01`, `R-ENV-03`). |
| `risk` | yes | One sentence: what could go wrong. |
| `cause` | yes | The input or assumption that introduces the risk. |
| `likelihood` | yes | L / M / H, with one-line rationale. "M" alone is not a rating. |
| `impact` | yes | L / M / H, with one-line rationale. Quantify (₪, hours, customers, regulatory) where possible. |
| `mitigation` | yes | Specific action — verification climb, contractual term, insurance, escalation, "accept and document." |
| `residual` | yes | What remains risky **after** mitigation. Never blank. |
| `owner` | yes | Who acts: user / orchestrator / a specific skill / external party. Risks without owners get ignored. |

## Discipline rules

1. **Empty register is a smell** — almost never accurate. Push back.
2. **"Be careful" is not a mitigation** — name a specific action.
3. **Blank residual is forbidden** — every mitigation leaves something unaddressed; surface it.
4. **No owner = no risk management** — every risk has a named owner.
5. **Likelihood + impact must have rationale** — letter alone is insufficient.

## Aggregation up the layers

- Leaf-skill registers feed up to the orchestrator unchanged.
- The orchestrator deduplicates entries (same `cause` → merge), re-prioritizes by impact (typically ₪-impact), and may downgrade or escalate based on cross-skill context.
- The orchestrator's final register is what the audience sees, with a top-of-page **"Top-N risks the audience must read first"** line.

## Required SKILL.md sections (in addition to standard)

- **Risk-prefix taxonomy** — domain-specific prefix codes (e.g., R-OWN, R-TAX, R-ENV)
- **Likelihood/impact rubric** — how the skill grades L/M/H in its domain
- **Quantification rule** — what units the impact is measured in

## Skeptical checks (the manager applies; concretes inherit)

1. **Empty register?** — almost certainly missing risks. Probe each consequential decision and ask "what could go wrong here?"
2. **No quantification?** — re-grade with units.
3. **Generic mitigations?** — "be careful" is forbidden; require specific action.
4. **No owner?** — pick one; raise to orchestrator if ambiguous.
5. **Blank residual?** — false. Every mitigation has gaps; name them.

## Standard outputs

- Schema-conformant register
- Top-N line for orchestrator consumption
- Dedup map when multiple skills surface the same risk

## Specialization axes

- Risk-prefix taxonomy (domain-specific)
- Quantification units (₪ for finance/RE, hours for ops, severity for security, percentage of customers for service)
- Severity rubric calibration

## Anti-patterns

- **One register per project, not per skill.** Wrong: skills produce registers; the orchestrator dedupes.
- **Sortable spreadsheet only.** The schema must support text rationale, not just dropdowns.
- **No dedup logic.** When two skills flag the same risk, the orchestrator must merge — not duplicate in the deliverable.
