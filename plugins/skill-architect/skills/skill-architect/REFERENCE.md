# Skill Architect — Extended Reference

Read this when the workflow in `SKILL.md` doesn't quite fit the request, or when you need the rationale behind a rule before bending it.

## Table of contents

1. Skill vs. task vs. agent — deeper distinctions
2. Phase 0 — fast-path criteria in detail
3. Phase 1b — the assumption-surfacing discipline
4. The layered hierarchy in detail
5. The three-tier verification ladder in detail
6. The cross-cutting concerns checklist (full)
7. Risk register schema and worked examples
8. How to size a decomposition (when 5 isn't enough, when 10 is too many)
9. Common decomposition smells
10. Handoff to skill-creator — exact brief format
11. Mode B (refine existing skill) — patterns
12. Edge cases

---

## 1. Skill vs. task vs. agent — deeper distinctions

The colloquial use of "skill" in user requests covers all three. Always classify before decomposing.

### Skill

- A bounded body of expertise that a specialist holds.
- **Test:** could a human with this expertise charge a fee for it on an hourly basis, on an open market? If yes, it's plausibly a skill.
- **Test:** can you describe the skill's scope in one sentence without using "and" between unrelated competencies? If no, split.
- **Test:** is the skill's expertise stable over weeks/months/years? Skills should not encode this-quarter's project state — that's a memory.

### Task

- A workflow with steps that produces a deliverable.
- Composes one or more skills.
- Tasks are often the right answer when the user says "create a skill for [verb-phrase]". The verb-phrase is a workflow.
- In Cowork and Claude Code, tasks can be persisted as scheduled tasks (`mcp__scheduled-tasks__create_scheduled_task`) or as commands.

### Agent

- An autonomous loop that decides what to do next, often using tools and skills.
- Agents are the right answer when the request involves *monitoring*, *reacting to events*, or *making decisions over time*.
- Agents are usually defined as subagent definitions (Claude Code) or as long-running scheduled tasks.

### Cross-cutting question: which artifact?

Ask the user — but lead with a recommendation. Don't ping-pong an undecided question back to them. The recommendation is part of Phase 1's Reframe Statement.

---

## 2. Phase 0 — fast-path criteria in detail

The fast path exists because not every "create a skill" request needs full decomposition. Forcing the gate every time creates friction the user is right to resent.

### Hard gates (all must hold to recommend the fast path)

1. **Single bounded competence.** The skill name is kebab-case, ≤5 words, no "and" between unrelated competencies.
2. **No multi-jurisdiction / multi-platform / multi-stakeholder shape.**
3. **No consequential cross-cutting concern requires its own skill.** Specifically: no PII at scale, no licensed-practice exposure (legal/medical/financial advice), no security boundary the skill is responsible for, no money movement, no irreversible action.
4. **The skeptical-checks list for the proposed skill fits comfortably under 5 entries.** If you can think of three categories of "what could be wrong" (legal validity, technical correctness, identity/ownership), that's a sign the request decomposes.
5. **The user is not making a *task* phrasing** — verbs like "deploy", "onboard", "evaluate", "investigate", "harvest", "audit", "review" usually imply a workflow.

### Soft signals that the fast path is right

- The user explicitly says "this is just a small skill" or "skip decomposition" or "I know it's narrow".
- The competence has an obvious deterministic implementation (date conversions, format conversions, validators, parsers, fixed transformations).
- The user has previously gone through the full path with you and is now adding a small adjacent skill.

### Fast-path examples (run the fast path)

- "A skill that converts Hebrew calendar dates to Gregorian and back."
- "A skill that validates IBAN checksums."
- "A skill that extracts citations from arXiv PDFs in BibTeX format."
- "A skill that converts Markdown tables to CSV."
- "A skill that knows the IL income-tax brackets for the current year." (jurisdiction tagged, single competence — borderline; ask if "current year" implies an update mechanism, which would make it an agent)

### Definitely-NOT-fast-path examples (run the full path)

- "A skill for due diligence on commercial real estate."
- "A skill that helps me deploy my app to GCP."
- "A skill for evaluating startup pitches."
- "A skill that audits my GDPR posture."
- "A skill for tax-loss harvesting in my brokerage account."
- Anything involving the verbs deploy / onboard / audit / evaluate / investigate / harvest / review / monitor.

### Fast-path is still rigorous

Even on the fast path, you must:
- Run **Phase 1b** (assumption surfacing). Lazily defaulting to US/English/AWS without asking is the failure mode this exists to prevent.
- Run **Phase 2** at minimum lightly (verification plan for the inputs of this one skill).
- Emit a **risk register** as part of the skill output spec.
- Include **at least one skeptical check** in the skill brief.

The fast path skips the *decomposition* and *presentation* phases (3, 4, 5). It does not skip critical thinking.

---

## 3. Phase 1b — the assumption-surfacing discipline

The architect's worst failure mode is producing a beautiful decomposition that quietly assumes the wrong jurisdiction, platform, or audience. Phase 1b is what prevents that.

### Why this is its own discipline

LLMs (including Claude) have strong default associations: legal → US, currency → USD, date format → MM/DD/YYYY, brokerage → Schwab/Fidelity, cloud → AWS, language → English. Skill names tagged with the wrong default propagate that default through every downstream skill. Renaming after the fact is expensive.

### Assumptions to walk for every request

Walk this every time. Strike out the irrelevant ones, but walk them.

| Category | Examples of assumptions to surface |
|---|---|
| Jurisdiction | Country, state/province, regulator. Critical for legal, tax, labor, privacy, real estate, healthcare, finance, immigration. |
| Language / locale | Input language, output language, scripts (Latin/Hebrew/Arabic/CJK), calendar (Gregorian/Hebrew/Hijri), number/date formats, currencies. |
| Platform / vendor | Cloud provider, OS, database engine, framework, brokerage, CRM, accounting system, etc. |
| User type | Individual / corporate / trust / government; consumer / business; licensed professional / layperson; their role in the workflow. |
| Data sensitivity | None / PII / PHI / PCI / financial / classified. Drives required Layer-2 skills. |
| Scale | Once-off / recurring; single user / team / enterprise; volume; latency expectations. |
| Stakeholders | Who reads the output, who acts, who is accountable, who is liable. |
| Time horizon | Point-in-time / recurring / continuous monitoring. (Continuous → agent, not skill.) |
| Existing skill landscape | Skills the user already has installed; skills already in flight in their org. |
| Definition of done | Format, depth, length, audience-appropriate language. |
| Adversarial context | Is anyone incentivized to lie about inputs? (Buyers/sellers, candidates, applicants — yes. Internal monitoring — usually no.) |

### Suggest vs. ask: a decision rule

- **Suggest with confirmation** when you have a strong signal: a memory file naming the jurisdiction, the user's email TLD, an explicit statement earlier in the conversation, the contents of files in the connected workspace.
- **Ask explicitly** when there is no signal, or when getting it wrong does material harm (immigration, healthcare, criminal law, anything regulator-licensed).
- Even when suggesting, give the user one concrete alternative so confirming is one click, not a typing exercise.

Bad: "I'll assume Israel — sound right?" with no alternative offered.
Better: "I'll assume Israel based on your other skills — or did you mean US / EU / UK / something else?"

### How to ask without ping-ponging

- Group all assumptions into one structured prompt; never ask one question, get an answer, then ask another.
- Use the surface's structured-question tool when available (`AskUserQuestion` in Cowork). On Claude Code or Claude.ai chat, present a numbered list with your suggested defaults marked.
- Cap at 3–5 questions; bundle the obvious-sub-questions with the parent.
- Mark each question as "(my guess: X)" if you have a guess, so the user can confirm by saying "yes" or just correct the wrong ones.

### Examples in action

**Tax-loss harvesting (the user's example).** No jurisdiction in the request → ask:

> Before I decompose this, a few assumptions I'd want to nail down:
> 1. Jurisdiction (drives the tax law skill): US / IL / UK / EU / other?
> 2. Account type: individual taxable / corporate / trust / retirement-equivalent?
> 3. Brokerage(s) involved (drives the integration skill): IBKR / Schwab / Fidelity / Israeli broker (Meitav/Psagot/etc.) / multiple?
> 4. Time horizon: end-of-tax-year batch only, or continuous monitoring (the latter would make this an agent, not a skill set)?
> 5. Existing skill overlap: any tax or portfolio skills already installed I should integrate with?

**Hebrew-to-Gregorian date converter (genuinely narrow).** Inputs are bounded by the domain itself, but you still ask:

> Two assumptions to confirm:
> 1. Direction: bidirectional (Hebrew↔Gregorian) or one-way?
> 2. Sources: just the standard rabbinic calendar, or also support Karaite / observational variants? (Most people want standard rabbinic.)

Then run the fast path.

---

## 4. The layered hierarchy in detail

The default four-layer structure:

| Layer | Role | Triggered by |
|---|---|---|
| 0 — Foundation | Critical-thinking / verification / risk register | Always; consulted by every other skill |
| 1 — Domain experts | One per sub-domain (legal, valuation, env. risk, ...) | Domain-specific user phrasings |
| 2 — Cross-cutting | Concerns that apply across the domain (security, compliance, perf, ...) | Cross-cutting phrasings |
| 3 — Orchestrator | Sequencing, conflict resolution, deliverable shape | The high-level task/workflow phrasing |

Two further layers occasionally appear:

- **Layer -1 — Tools / utilities** (e.g., a "land-registry-extract" skill that just knows how to pull data from a registry). These are sometimes better as scripts in another skill, but if multiple skills need them, extract.
- **Layer 4 — Meta** (e.g., this very skill, `skill-architect`, sits at Layer 4 above the whole stack). Rarely needed in user-facing skill sets.

Hierarchies don't have to be strict trees — a Layer 1 skill can consult a Layer 2 skill mid-flow and that's fine. The hierarchy is a *priority* and *abstraction* ordering, not a call graph.

---

## 5. The three-tier verification ladder in detail

For every critical input, climb the ladder until you have enough confidence — or surface what's still unverified.

### Tier 1 — Public data

Free, no user action needed.

Examples:
- **Identity / corporate**: public corporate registries (Israel: רשם החברות; UK: Companies House; US: state SoS), beneficial-ownership registers where public.
- **Property**: public land-registry abstracts where available, municipal property tax records, zoning maps.
- **Sanctions / AML**: OFAC SDN, UN, EU sanctions lists, PEP indicators where free.
- **Financial**: public filings (SEC EDGAR, equivalent), credit-rating agency public commentary.
- **Legal**: public court records, published opinions, regulator enforcement actions.
- **Technical**: package vulnerability databases (NVD, OSV), DNS, certificate transparency, public source code, archived web pages.

Always cite the source. "Verified against Companies House (UK), record retrieved 2026-05-02." Not "verified online."

### Tier 2 — Private data from the user

Requires user effort but no money.

Examples:
- Internal documents (contracts, prior reports, audit trails).
- Credentials to private systems (must be handled per the security skill).
- Identity documents the user already holds.
- Internal data the user has rights to share.

Phrase the ask narrowly: "Please provide the signed Sale Agreement (PDF), and the most recent property tax invoice." Not "send relevant docs."

### Tier 3 — Paid / manual data

Costs money or human effort.

Examples by domain:
- **Corporate**: Dun & Bradstreet, Bureau van Dijk Orbis, Crunchbase Pro (~$50–500 per record/month).
- **Real estate**: paid land-registry extracts, professional appraisal (~$300–3,000), environmental site assessments (Phase I ESA: ~$1,500–4,000), title insurance.
- **People / KYC**: paid identity-verification vendors (Onfido, Jumio, Persona; ~$1–5 per check), enhanced due diligence vendors (~$500–5,000 per subject).
- **Credit**: bureau pulls (Experian, TransUnion, BDI in IL).
- **Legal**: hiring counsel for a memo (~$300–1,000+ per hour).
- **Technical**: paid vulnerability scanners, professional penetration test (~$5,000–50,000+).

Always name the vendor or method and a rough cost band. Always state what is verified and what remains unverified after the paid check.

### When to climb

A reasonable default policy:
- Tier 1 by default for any consequential input.
- Tier 2 for inputs where Tier 1 left meaningful uncertainty.
- Tier 3 only when the cost of being wrong materially exceeds the cost of the verification, *or* when a regulator/buyer/insurer requires it.

The skill always explains the tradeoff to the user — never silently demands Tier 3.

---

## 6. Cross-cutting concerns checklist (full)

Walk this on every decomposition. Cross out the ones that don't apply, but don't skip the walk.

- **Legal & regulatory** (per jurisdiction)
- **Privacy & data protection** (GDPR, CCPA, IL Privacy Law, sectoral regs)
- **Security** (threat model, secrets, access control, supply chain)
- **Compliance** (HIPAA, PCI-DSS, SOX, sector-specific, ISO 27001, SOC 2)
- **Performance** (latency, throughput, cost-of-operation)
- **DevOps / SRE** (deployability, CI/CD, observability, rollback, runbooks)
- **Reliability** (SLOs, error budgets, incident response)
- **Cost / FinOps** (unit economics, budget alerts)
- **Ethics & fairness** (when humans are affected — hiring, lending, housing, healthcare, criminal justice, education, insurance)
- **Accessibility** (WCAG, when there's a UI or output a person reads)
- **Localization & internationalization**
- **Procurement / vendor risk / third-party security**
- **Intellectual property** (licensing, attribution, derivative works)
- **Export controls / sanctions**
- **Sustainability / environmental impact**
- **Animal welfare / occupational safety / specialized domain ethics**
- **Insurance & risk transfer** (often the right mitigation for a residual risk)

When in doubt, include rather than exclude — a Layer 2 skill that turns out not to fire on a particular task costs nothing.

---

## 7. Risk register schema

Every skill the architect produces must emit a risk register. The schema:

| Field | Description |
|---|---|
| `id` | Stable ID (e.g., `R-LEGAL-01`) |
| `risk` | One sentence describing what could go wrong |
| `cause` | What input or assumption produces the risk |
| `likelihood` | L / M / H (with a one-line rationale) |
| `impact` | L / M / H (with a one-line rationale) |
| `mitigation` | Specific action — verification climb, contractual term, insurance, escalation |
| `residual` | What's still risky after mitigation |
| `owner` | Who acts: user / orchestrator / a specific Layer-2 skill / an external party |

A risk that maps cleanly to "user must verify against [Tier-N source]" is a good risk-register entry. A risk that says "things could go wrong" is not.

### Worked example (real-estate due diligence)

| id | risk | cause | L | I | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| R-OWN-01 | Seller is not the actual owner | User-provided ownership claim only | M | H | Climb to Tier 1: pull land-registry abstract; if unclear, climb to Tier 3 paid extract | Beneficial owner behind a holding co. still possible | corporate-records skill |
| R-LIEN-01 | Undisclosed lien on the property | Public registry lag or off-registry encumbrance | M | H | Tier 1 lien search + Tier 3 title insurance binder | Insurer's exclusions remain | legal-il skill |
| R-ENV-01 | Soil contamination | Adjacent prior industrial use | L | H | Tier 3 Phase I ESA | Phase I doesn't sample soil; Phase II if flagged | env-risk skill |
| R-VAL-01 | Comparable transactions stale | Thin market in the area | M | M | Triangulate with rental yield and replacement cost | Market may shift before close | valuation skill |

This is what "good" looks like.

---

## 8. Sizing a decomposition

### Why minimum five

Below five, you almost certainly bundled a cross-cutting concern into a domain skill (e.g., "real-estate-and-its-legal-aspects"), or you skipped the orchestrator. Both are smells.

### When fewer than five is actually right

Single-skill requests that are genuinely narrow:
- "Convert citations from Bluebook to APA"
- "Generate Hebrew niqqud for a given text"
- "Compute the Hebrew calendar date for a given Gregorian date"

Even here, propose a critical-thinking partner: "I'd pair this with a `citation-input-validator` skill so a malformed Bluebook entry doesn't silently produce a malformed APA entry."

### When more than ten is right

Complex, multi-jurisdictional, multi-stakeholder domains:
- Cross-border M&A: easily 15+ (legal in N jurisdictions, tax in N, antitrust in N, IP, employment, real estate, environmental, IT integration, comms, ...)
- Healthcare deployment: clinical, regulatory (FDA / EMA / MoH), HIPAA, privacy by jurisdiction, security, observability, billing, accessibility, ethics, post-market surveillance.

Don't compress these for the sake of a tidy number.

### How to know when you're over-decomposing

- Two skills' descriptions read interchangeably to a non-expert → merge.
- A skill has only one "skeptical check" and it's identical to the one in another skill → merge.
- A skill has no inputs the user can plausibly produce → it's a sub-routine of another skill, not a skill.

---

## 9. Common decomposition smells

- **The "and" smell.** Skill name has "and" between two unrelated terms. Split.
- **The "manager" smell.** Skill is named `[domain]-manager` or `[domain]-helper`. Probably a task or an agent. Reframe.
- **The "AI" smell.** Skill is named `ai-[adjective]-assistant`. Almost always too broad.
- **The "everything" smell.** Skill description starts "Comprehensive expertise on..." Comprehensive is not narrow.
- **The "no jurisdiction" smell.** A legal/tax/labor/privacy skill without a jurisdiction. Add `-il`, `-eu`, `-us-ny`, etc.
- **The "no skeptical check" smell.** Skill brief has zero "what could be wrong" questions. Either you didn't think hard, or it's not a real skill.
- **The "missing orchestrator" smell.** Decomposition has SMEs but no skill that knows how to combine them.

---

## 10. Handoff to skill-creator — exact brief format

When Phase 6 hands off, the brief sent to skill-creator must include:

```
SKILL TO BUILD: <name>

ONE-LINE DESCRIPTION:
<description with strong trigger keywords; pushy phrasing per skill-creator's guidance>

WHY THIS SKILL EXISTS:
<one paragraph from Phase 4 brief>

INPUTS (with verification tier):
- <input 1>: Tier <1/2/3>, source: <where>, verifies: <what>, leaves unverified: <what>
- ...

SKEPTICAL CHECKS (the skill must always run):
1. ...
2. ...
3. ...

OUTPUTS:
- <main output>
- Risk register (per templates/risk_register.md)

DEPENDENCIES:
- Consults: <other skills it calls into>
- Consulted by: <skills that call it>

OUT OF SCOPE:
- <what this skill explicitly does not cover>

EXAMPLE TRIGGER PROMPTS (should-trigger):
1. <realistic, user-flavored prompt>
2. ...
3. ...

NEAR-MISS PROMPTS (should-NOT-trigger):
1. <prompt that shares keywords but needs a different skill>
2. ...
```

This is what skill-creator needs to author the skill, write evals, and run description optimization.

---

## 11. Mode B — refine existing skill

Patterns:

- **Split** — existing skill covers two domains. Propose two skills + retire the original. Migrate references.
- **Sharpen** — existing skill is too broad in description. Tighten the description; identify what the trimmed scope leaves uncovered and propose a sibling skill.
- **Layer-up** — existing skill is implicitly an orchestrator for several sub-skills. Extract the sub-skills.
- **Verify-up** — existing skill accepts inputs without scrutiny. Add a critical-thinking partner skill, or fold the three-tier ladder into the existing skill.
- **Jurisdictionalize** — existing skill assumes a jurisdiction without naming it. Rename and create siblings for other jurisdictions if relevant.

In every case, present the change as a Phase 5 proposal and let the user accept or reject.

---

## 12. Edge cases

### "I just want a quick skill, don't decompose"

Honor the user. But still:
- State explicitly which mandatory layers you're skipping and what risk that creates.
- At minimum produce the verification plan and the risk register for the single skill.
- Note that you're available to revisit the decomposition later.

### "The user wants something that should not be a skill"

E.g., "create a skill that scrapes my competitors' pricing daily." That's an agent + a scheduled task, not a skill. Reframe in Phase 1 and offer the agent/task shape.

### "The user wants something potentially harmful"

E.g., a skill to evade a regulator, or to do unlicensed legal practice, or to make medical decisions without a clinician. Reframe in Phase 1 and decline to decompose. Offer a compliant alternative if one exists.

### "The user wants a skill in a domain you're uncertain about"

Be honest in the Reframe Statement: "I'm not confident about the cross-cutting concerns specific to maritime law / nuclear safety / veterinary practice in your jurisdiction. I'll propose a starting decomposition and flag what needs an expert review before the orchestrator goes live." Then proceed.

### "The user already started authoring with skill-creator"

That's fine — Mode B applies. Treat their draft as a Phase 5 proposal of one skill and audit it. The user can choose to keep going with skill-creator alone or accept a decomposition.
