# Verification plan — {{skill-set-name}}

> Phase 2 deliverable. One row per critical input across the whole skill set. The skills that consume each input must reference this plan and climb the tier ladder until satisfied (or surface the unverified).

## How to use

1. List every input the skill set consumes — from the user, from public sources, from paid sources.
2. For each, state which tier currently verifies it (the *minimum* tier needed for the consequences of being wrong).
3. State *what is still unverified* even after that tier — never claim "fully verified."
4. If the user is uncomfortable with a residual unverified item, climb a tier.

## Tiers (recap)

- **Tier 1 — Public** — free, no user effort. Cite source.
- **Tier 2 — Private from the user** — user effort, no money. Phrase the ask narrowly.
- **Tier 3 — Paid / manual** — money or human expert time. Name vendor/method and a cost band.

## Plan

| # | Input | Consumed by | Default tier | Source | Verifies | Still unverified | Cost band (if T3) |
|---|---|---|---|---|---|---|---|
| 1 | {{e.g., property address}} | {{valuation, legal, env-risk}} | {{1}} | {{municipal land registry}} | {{ownership of record}} | {{beneficial ownership behind a holding co.}} | — |
| 2 | {{e.g., seller identity}} | {{kyc-aml, legal}} | {{2}} | {{user-provided ID + proof of address}} | {{the seller exists and matches the contract}} | {{whether they are a sanctioned PEP}} | — |
| 3 | {{e.g., enhanced KYC on UBO}} | {{kyc-aml}} | {{3}} | {{Onfido / WorldCheck}} | {{sanctions, PEP, adverse media}} | {{recent unrecorded changes}} | $1–5 / $50–500 |

## Climb policy

State, per input, when to climb:

- {{Input 1}}: climb to T2 if {{condition}}; climb to T3 if {{condition}}.
- {{Input 2}}: …

## Unverified residuals (the must-tell-the-user list)

After every climb, these gaps remain. The orchestrator must surface these in the final deliverable:

- {{residual 1}}
- {{residual 2}}
