# Skill Set Proposal — {{request_summary}}

> Fill this template at the end of Phase 4 and present it to the user as the Phase 5 deliverable. Replace every `{{placeholder}}`. Delete sections that are genuinely not applicable (and say why).

---

## 1. Reframe statement

{{One paragraph: skill vs. task vs. agent classification, what shape you actually recommend, and why. Be explicit when the user said "skill" but the right shape is a task or agent.}}

## 2. Layered hierarchy (overview)

```
Layer 3 — Orchestrator
  └── {{orchestrator-skill-name}}

Layer 2 — Cross-cutting concerns
  ├── {{xc-skill-1}}
  ├── {{xc-skill-2}}
  └── {{xc-skill-3}}

Layer 1 — Domain experts
  ├── {{domain-skill-1}}
  ├── {{domain-skill-2}}
  └── {{domain-skill-3}}

Layer 0 — Critical-thinking foundation
  └── {{verification-skill-name}}
```

Total: {{N}} skills (minimum 5; this proposal has {{N}}).

## 3. Per-skill briefs

Below, one block per skill. Use `templates/skill_brief.md` as the per-skill schema.

### 3.1 {{skill-1-name}}
{{paste filled skill_brief.md}}

### 3.2 {{skill-2-name}}
{{paste filled skill_brief.md}}

{{...repeat for every skill in the set...}}

## 4. Verification plan

(See `templates/verification_plan.md` for the schema.)

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| {{input}} | {{1/2/3}} | {{vendor or registry}} | {{what}} | {{what}} |

## 5. Top-level risk register (of the skill set itself)

(See `templates/risk_register.md` for the schema. These are risks of the *proposed skill set*, not risks the orchestrator will surface to the user later.)

| id | risk | cause | L | I | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| {{R-01}} | {{risk}} | {{cause}} | {{L/M/H}} | {{L/M/H}} | {{mitigation}} | {{residual}} | {{owner}} |

## 6. Cross-cutting concerns walkthrough

I walked the cross-cutting checklist (REFERENCE.md §4). The concerns I included are above. The ones I considered and excluded:

- **{{Concern}}** — excluded because {{reason}}.
- **{{Concern}}** — excluded because {{reason}}.

If any of those was wrong to exclude, say so and I'll add it.

## 7. What this set does NOT cover

{{Explicit list of things in the user's likely mental model that this skill set will not handle. Important for managing expectations.}}

## 8. Your choices

Please pick one (or describe your own):

- **A. Build all {{N}} skills as proposed.**
- **B. Build a subset.** Tell me which.
- **C. Swap a skill.** Tell me which to remove and what to replace it with.
- **D. Change a boundary.** Tell me which two skills to merge or which one to split.
- **E. Reshape entirely.** This isn't the right decomposition; let's rethink.
- **F. Build only the foundation + orchestrator now**, and add SME skills as needed later.

Once you pick, I'll hand each approved skill off to `skill-creator`, one at a time.
