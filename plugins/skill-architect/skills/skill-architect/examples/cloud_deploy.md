# Worked example — "Build a skill for deploying to the cloud"

This example shows that the same critical-thinking discipline applies to a domain that *feels* purely technical. The decomposition surfaces legal, privacy, and procurement skills that a naive "just write a deploy skill" would miss.

---

## Phase 1 — Reframe statement

You asked for a "skill for deploying my app to the cloud." **"Deploy" is a task**, not a skill. The skill set below is what the task composes. I also want to flag two things up front:

1. **Cloud choice matters.** "The cloud" is not a domain — AWS, GCP, Azure, and on-prem all have different operating models. I'm proposing the GCP variant since that's what you have skills for already (the `gcp-*` skills installed). If you actually deploy across multiple clouds, we either clone these skills per cloud or build a thin "multi-cloud-deploy" orchestrator on top.
2. **There's a legal/compliance layer here.** Most "deploy" requests have legal implications: licensing of dependencies, data residency, terms-of-service of services you embed, accessibility obligations if there's a UI. A deploy-skill that doesn't surface those is a foot-gun.

You already have several GCP skills installed (`gcp-platform-fundamentals`, `gcp-compute`, `gcp-networking`, `gcp-security`, `gcp-observability-cicd`, `gcp-finops-performance`, `gcp-privacy-compliance`, `gcp-terraform`). I'll **reuse those** and propose only the gaps. That's cheaper than re-creating.

---

## Phase 2 — Verification plan (highlights)

| # | Input | Tier | Source | Verifies | Still unverified |
|---|---|---|---|---|---|
| 1 | App's data classification (PII / PHI / PCI / none) | 2 | User declaration | Sensitivity tier | Whether classification is actually correct (drift) |
| 2 | List of third-party services the app calls | 2 | User-provided + scan of deps/manifests | Direct dependencies | Transitive supply-chain risk |
| 3 | Data residency requirement | 1→2 | Public regulator guidance (T1) + user contracts (T2) | Legal floor | Customer-by-customer carve-outs |
| 4 | License compliance of OSS dependencies | 1 | SPDX / public license scanners | License terms | Inbound contributor obligations |
| 5 | Threat model for the app | 2 | User collaborative session | Adversaries, assets | Insider-threat surface |
| 6 | Accessibility status (if UI) | 2 | User-provided audit results | Conformance level | Conformance under JS-disabled or screen reader |

**Climb policy.** Climb #2 to T3 (paid SCA / SBOM tooling) if the app embeds GPL/AGPL/SSPL dependencies or talks to >5 third parties. Climb #4 to T3 (legal review) for AGPL or any custom license.

---

## Phase 3 — Layered hierarchy (reusing what you have)

```
Layer 3 — Orchestrator
  └── cloud-deploy-orchestrator-gcp                 [NEW]

Layer 2 — Cross-cutting concerns
  ├── gcp-security                                  [exists — reuse]
  ├── gcp-privacy-compliance                        [exists — reuse]
  ├── gcp-finops-performance                        [exists — reuse]
  ├── gcp-observability-cicd                        [exists — reuse]
  ├── software-licensing-and-oss-compliance         [NEW — not GCP-specific]
  ├── accessibility-wcag                            [NEW — only if UI]
  └── procurement-and-vendor-risk                   [NEW]

Layer 1 — Domain experts
  ├── gcp-platform-fundamentals                     [exists — reuse]
  ├── gcp-compute                                   [exists — reuse]
  ├── gcp-networking                                [exists — reuse]
  └── gcp-terraform                                 [exists — reuse]

Layer 0 — Critical-thinking foundation
  └── input-scrutiny-and-risk-register              [shared — reuse if it was built earlier]
```

**Net new skills proposed: 4** (orchestrator + three cross-cutting). The Layer 0 foundation skill is shared with any other skill set you've built.

If `input-scrutiny-and-risk-register` doesn't exist yet, that's the *first* skill to build, since every other skill set will need it.

---

## Phase 4 — Per-skill briefs (abbreviated, only the new ones)

**software-licensing-and-oss-compliance.** Inbound license obligations (GPL/AGPL/SSPL/MPL/BSD/MIT/Apache), license compatibility, attribution duties, source-disclosure triggers, export-control overlap. Skeptical checks: do you ship modified GPL binaries to customers? do any dependencies have a license-changed-mid-stream history (e.g., MongoDB/Elastic-style relicensing)? are CLAs/DCOs of inbound contributions tracked? Out of scope: patent strategy, trademark.

**accessibility-wcag.** WCAG 2.2 conformance for web/mobile UIs. Skeptical checks: keyboard-only navigation; screen-reader semantics; color contrast under accessible-color modes; non-text content alternatives. Jurisdictions: EU EAA (2025+), US ADA case law, IL Equal Rights for Persons with Disabilities Law. Out of scope: native desktop a11y APIs.

**procurement-and-vendor-risk.** When the deploy embeds third-party services, this skill assesses: data-processing agreements, sub-processor lists, SOC 2 / ISO 27001 status, data location, exit clauses, source-code-escrow, financial viability of small vendors. Skeptical checks: is the DPA current vs. service contract; are sub-processors notifiable; can you actually leave the vendor without re-architecting. Out of scope: pricing negotiation.

**cloud-deploy-orchestrator-gcp.** Sequences the others on a specific app deploy. Resolves conflicts (e.g., security says "no public IP", performance says "need CDN" — orchestrator chooses Cloud CDN with private origin). Decides when to climb verification tiers. Produces the deploy plan, the runbook, and the top-3 risks.

---

## Phase 5 — Top-level risk register (of the skill set itself)

| id | risk | cause | L | I | mitigation | residual | owner |
|---|---|---|---|---|---|---|---|
| R-SET-01 | License obligation missed → legal exposure | OSS scanning not part of CI yet | M | H | `software-licensing-and-oss-compliance` mandates an SBOM step in CI; orchestrator refuses to deploy without an SBOM | Transitive deps changing post-deploy | orchestrator |
| R-SET-02 | Data residency violated for an EU/IL customer | Region defaulted without verifying contracts | L | H | `gcp-privacy-compliance` + `procurement-and-vendor-risk` jointly check residency; orchestrator escalates | Mid-flight customer changes their requirement | orchestrator |
| R-SET-03 | Accessibility regression after deploy | a11y not in CI gates | M | M | `accessibility-wcag` adds CI gate; orchestrator sets a11y as a release-blocker | Manual flows still need human audit | accessibility-wcag |
| R-SET-04 | Cost overrun in first month | finops not consulted | M | M | `gcp-finops-performance` runs pre-deploy estimate and post-deploy diff; orchestrator surfaces | Usage spike from launch | finops |

---

## Phase 6 — Handoff order

1. `input-scrutiny-and-risk-register` (if not already built)
2. `software-licensing-and-oss-compliance`
3. `accessibility-wcag` (only if the app has a UI)
4. `procurement-and-vendor-risk`
5. `cloud-deploy-orchestrator-gcp` (last)

---

## Why this matters

A "deploy skill" without the new Layer-2 skills will happily ship code that violates AGPL, lands customer data in the wrong region, or fails an a11y audit on the day of launch. The decomposition is what catches those before they happen. The user can decline any of the new skills — but they should decline *knowing* what's not covered.
