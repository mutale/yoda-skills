# il-land-dd plugin (in flight)

Israeli buy-side land/development real-estate due diligence skill set. Twelve layered skills authored one at a time from briefs at `../il-land-dd/briefs/`.

## Status

Pre-release. Authoring with `skill-creator` in Claude Code, one skill at a time, with review between each. Briefs at `../il-land-dd/briefs/` are stable and complete.

## Authoring order

1. `input-scrutiny-and-risk-register` (foundation)
2. `il-land-registry-and-rmi`
3. `il-zoning-and-planning`
4. `il-construction-feasibility-and-cost`
5. `il-environmental-and-soil-risk`
6. `il-real-estate-valuation-development`
7. `il-development-financial-stress`
8. `il-real-estate-legal-development`
9. `il-tax-real-estate-development`
10. `corporate-records-il-and-kyc-aml`
11. `insurance-and-risk-transfer-development`
12. `il-buy-side-land-development-dd-orchestrator` (last — references all leaf names)

When all 12 are authored and tested, this plugin gets added to `yoda-skills/.claude-plugin/marketplace.json` alongside `skill-architect`, version bumps to 0.1.0, and gets committed + pushed to the marketplace repo.

## Note on the foundation skill

`input-scrutiny-and-risk-register` is intended to be reusable across all of Yoda's future skill sets. After authoring, consider promoting it into a separate plugin (e.g., `critical-thinking-foundation@yoda-skills`) so future sets can depend on it without pulling in the IL real-estate skills.
