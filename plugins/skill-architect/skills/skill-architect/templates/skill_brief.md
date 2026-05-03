# Skill brief — {{skill-name}}

> One filled copy of this brief lives inside `templates/proposal.md` (Phase 4 → Phase 5) and another, polished, is handed off to `skill-creator` in Phase 6.

**Name:** `{{kebab-case-name}}`

**Layer:** {{0 / 1 / 2 / 3}}

**Conforms to:** {{e.g., `orchestrator (foundation), due-diligence (domain)` — list every abstract the skill inherits from. Pull required contract sections from each abstract; only write the domain-specific delta below. See `abstracts/README.md`.}}

**Authored SKILL.md preamble (skill-creator must emit this at the top of the SKILL.md, after the YAML frontmatter):**

```
## Inheritance
**Domain:** {{kebab-case-name}}
**Level:** CONCRETE
**Inherits From:** {{same as Conforms to above}}

**READ FIRST (in order):**
1. abstracts/foundation/{{abstract-1}}.md
2. abstracts/foundation/{{abstract-2}}.md
3. abstracts/domain/{{domain-abstract}}.md

**THEN APPLY THE DELTA BELOW.**
```

Body of the SKILL.md should only document **domain-specific specialization** (the delta). Anything covered by an abstract is referred to by name (`(see orchestrator abstract)`) rather than re-stated.

**One-line description (with strong trigger keywords):**
{{Description that auto-fires on real-user phrasings. Be a little pushy per skill-creator's guidance — Claude tends to under-trigger skills.}}

**Why this skill exists:**
{{One paragraph. What it adds that no other skill in the set covers.}}

**Inputs (with verification tier per input):**

| Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|
| {{input}} | {{1/2/3}} | {{registry / vendor / user doc}} | {{what}} | {{what}} |

**Skeptical checks the skill must always run (≥3):**

1. {{What could be wrong about input X?}}
2. {{What could be wrong about input Y?}}
3. {{What might be missing entirely?}}

**Outputs:**

- {{Main deliverable, named explicitly.}}
- Risk register (per `templates/risk_register.md`).
- Surface-the-unverified summary (what's still uncertain after this skill ran).

**Dependencies:**

- Consults: {{other-skill-1}}, {{other-skill-2}}
- Consulted by: {{orchestrator}}, {{other-skill-3}}

**Out of scope (deliberately not covered by this skill):**

- {{thing 1}}
- {{thing 2}}

**Three example trigger prompts (for description optimization in skill-creator):**

1. {{Realistic, user-flavored prompt that should fire this skill.}}
2. {{Different phrasing of the same intent.}}
3. {{An edge case where this skill should win against a near neighbor.}}

**Two near-miss prompts (should NOT trigger this skill):**

1. {{Shares keywords but actually needs a different skill.}}
2. {{Adjacent domain.}}

**Jurisdictions / scopes (where applicable):** {{e.g., -il, -eu, -us-ny}}
