# Risk register schema

> Every invocation of `input-scrutiny-and-risk-register` must emit a register in this exact format. Other skills in the set aggregate registers up to the orchestrator unchanged; the orchestrator deduplicates and re-prioritizes.

## Schema

| Field | Required | Description |
|---|---|---|
| `id` | yes | Stable ID, e.g. `R-LEGAL-01`. Prefix groups risks by domain so they're easy to filter when registers from multiple skills are aggregated. |
| `risk` | yes | One sentence: what could go wrong. |
| `cause` | yes | The input or assumption that introduces the risk. Be specific — name the document, claim, or source. |
| `likelihood` | yes | L / M / H, with a one-line rationale. The rating without the rationale is not a rating. |
| `impact` | yes | L / M / H, with a one-line rationale. |
| `mitigation` | yes | Specific action — a verification climb (T1/T2/T3 with vendor + cost band), a contractual term, insurance, escalation, or "accept and document". "Be careful" is not a mitigation. |
| `residual` | yes | What remains risky *after* the mitigation. Never blank — every mitigation leaves something unaddressed. |
| `owner` | yes | Who acts: the user / the orchestrator / a named domain skill / an external party (vendor, lawyer, insurer). Risks without an owner get ignored. |

## ID prefixes

Use a stable, domain-prefixed ID so the orchestrator can filter and deduplicate:

| Prefix | Domain |
|---|---|
| `R-LEGAL-XX` | title, encumbrances, contract risk |
| `R-FIN-XX` | financial position, liquidity, credit |
| `R-REG-XX` | regulatory, sanctions, licensing |
| `R-IDENT-XX` | identity, KYC, beneficial ownership |
| `R-TECH-XX` | technical configuration, security, certifications |
| `R-ENV-XX` | environmental, soil, contamination |
| `R-OPS-XX` | operational, counterparty performance |
| `R-INFO-XX` | information quality, source credibility, missing data |
| `R-OTHER-XX` | none of the above — explain in the risk row |

## Markdown rendering

Render the register as a single markdown table. Likelihood and impact each carry the L/M/H letter followed by a one-line rationale in the same cell.

```markdown
| id | risk | cause | likelihood | impact | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| R-LEGAL-01 | Undisclosed lien on the property | Seller-supplied "free of encumbrances" letter; public-registry lag of up to several weeks | M — registries lag | H — clouds title and may force renegotiation or rescission | T1 nesach tabu + Registrar of Pledges search; T3 title-insurance binder (~0.1–0.5% of value) | Insurer's exclusions remain (e.g. recently filed liens, defects in chain of title beyond the search period) | user (purchase title insurance); legal-il skill (interpret nesach) |
| R-ENV-01 | Latent soil contamination not on the public registry | "No environmental issues" claim is unverified; absence of registry record ≠ absence of contamination | M — site is in an industrial-adjacent area | H — remediation cost can exceed land value | T1 Ministry of Environmental Protection contaminated-soil registry; T3 Phase I ESA (~₪15k–₪40k) | Phase I reviews records and walks the site; only a Phase II with sampling actually quantifies contamination | user (commission Phase I); environmental-il skill |
| R-INFO-01 | Seller's other representations are unverified | All material claims came from a party with a strong incentive to misrepresent | H — incentive is structural | M — varies by claim | Cross-check every material claim against an independent T1 or T3 source before signing | Some claims (e.g. neighbour relations, anecdotal history) are not independently verifiable; price for that risk in the contract or accept | user; orchestrator |
```

## Anti-patterns

The skill should reject these in its own output and reject them when reviewing other skills' registers:

- **Empty register** — "No risks identified" is almost never true for a real decision. If the input is genuinely low-risk, still emit the table with the residuals you *can* name.
- **Hand-wave mitigation** — "be careful", "do due diligence", "consult a lawyer" without a named action are not mitigations.
- **Blank residual** — every mitigation leaves something unaddressed (vendor exclusions, time lag, single point of failure, unknown unknowns).
- **No owner** — risks without an owner get ignored.
- **L / M / H without rationale** — the rating without the one-line reason is not a rating.

## Aggregation up the layers

- Domain-skill registers feed up to the orchestrator unchanged.
- The orchestrator deduplicates by `id`-prefix + cause-similarity, re-prioritizes given cross-skill context, and may downgrade or escalate.
- The orchestrator's final register is what the user sees in the deliverable. It must include a top-of-page **"Top 3 residuals the user must read before acting"** line.
