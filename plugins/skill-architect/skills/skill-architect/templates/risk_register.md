# Risk register schema

> Every skill the architect produces must emit a register in this exact format. Every Phase 5 proposal includes a top-level register for the skill set itself.

## Schema

| Field | Required | Description |
|---|---|---|
| `id` | yes | Stable ID, e.g., `R-LEGAL-01`. Prefix groups risks by domain so they're easy to filter. |
| `risk` | yes | One sentence: what could go wrong. |
| `cause` | yes | The input or assumption that introduces the risk. Be specific. |
| `likelihood` | yes | L / M / H, with one-line rationale. |
| `impact` | yes | L / M / H, with one-line rationale. |
| `mitigation` | yes | Specific action — verification climb, contractual term, insurance, escalation, or "accept and document". |
| `residual` | yes | What remains risky *after* the mitigation. Never blank. |
| `owner` | yes | Who acts: the user / the orchestrator / a specific Layer-2 skill / an external party. |

## Markdown rendering

```markdown
| id | risk | cause | L | I | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| R-LEGAL-01 | Lien on the property is not disclosed | Public-registry lag | M | H | Tier 1 lien search + Tier 3 title insurance binder | Insurer's exclusions remain | legal-il skill |
```

## Anti-patterns (reject these in produced skills)

- **Empty register.** "No risks identified" is almost never true. Push back.
- **Hand-wave mitigation.** "Be careful" is not a mitigation. Name a specific action.
- **Blank residual.** Every mitigation leaves *something* unaddressed; surface it.
- **No owner.** Risks without an owner are risks that will be ignored.
- **Likelihood/impact with no rationale.** "M" alone is not a rating.

## Aggregating up the layers

- Domain-skill registers feed up to the orchestrator unchanged.
- The orchestrator deduplicates, re-prioritizes, and may downgrade or escalate based on cross-skill context.
- The orchestrator's final register is what the user sees in the deliverable. It must include a top-of-page **"Top 3 risks the user must read before acting"** line.
