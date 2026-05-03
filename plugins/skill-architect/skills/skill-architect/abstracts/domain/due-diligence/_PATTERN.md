# Folder-and-file nesting pattern (Olympus convention)

This folder is the **child container** for sub-domain abstracts that specialize the `due-diligence` parent abstract one tier above (`abstracts/domain/due-diligence.md`). The pattern matches Olympus SDLC's `skills/<domain>.md` + `skills/<domain>/` layout.

## How to use this folder

When **two or more concrete DD skill sets** would inherit from a common shape *more specific than `due-diligence`*, promote that shape to a sub-domain abstract here.

Example growth path:

```
abstracts/domain/
├── due-diligence.md                                       (Level: DOMAIN)
└── due-diligence/
    ├── _PATTERN.md                                        (this file)
    ├── buy-side-property-acquisition-dd.md                (Level: SUB-DOMAIN)
    └── buy-side-property-acquisition-dd/
        ├── il-buy-side-land-development-dd.md             (Level: CONCRETE — only if a 4th level genuinely earns its seat)
        └── us-buy-side-residential-dd.md                  (Level: CONCRETE)
```

Most concrete DD skill sets will sit at SUB-DOMAIN or directly under DOMAIN — a fourth tier (`CONCRETE` as its own file in the catalog) is rare and only earns its seat when there's an audience for inheriting from a concrete (e.g., a localization variant of an existing concrete).

## When to promote a sub-domain abstract

Only when **at least two concrete skill sets** would inherit from it. Otherwise the abstract is "one-skill-with-extra-steps."

For the IL-DD set currently in flight: there's only one concrete (`il-buy-side-land-development-dd`). No sub-domain abstract yet. When a second buy-side property acquisition DD set arrives (e.g., for the US, EU, or for built commercial vs. land), promote `buy-side-property-acquisition-dd.md` here and migrate IL-DD to inherit from it.

## Header schema for sub-domain abstracts

```
# Abstract: <name> (sub-domain)

**Domain:** <full-path-from-domain-root>     (e.g., due-diligence/buy-side-property-acquisition)
**Level:** SUB-DOMAIN
**Inherits From:** due-diligence (domain)
```

## Don't add abstracts here speculatively

If you find yourself writing a sub-domain abstract that has only one concrete and no plausible second concrete in the next 6 months, stop. The catalog's value is constraint; speculative additions dilute it.
