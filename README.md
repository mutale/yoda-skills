# yoda-skills

A Claude plugin marketplace for skill-building utilities.

## Plugins

- **skill-architect** — Critical-thinking decomposition skill that runs before any new skill is authored. Detects whether the request is a skill, a task, or an agent, surfaces every assumption (jurisdiction, platform, audience…), and decomposes into a layered set of 5–10+ skills (foundation / domain experts / cross-cutting concerns / orchestrator) before delegating to `skill-creator`. Includes a fast path for genuinely narrow skills so the gate is skippable when appropriate.

## Install

Add the marketplace once:

```bash
# In Claude Code or Cowork
/plugin marketplace add github:yodausername/yoda-skills
```

Install a plugin:

```bash
/plugin install skill-architect@yoda-skills
```

## Layout

```
yoda-skills/
├── .claude-plugin/
│   └── marketplace.json          ← marketplace manifest
├── plugins/
│   └── skill-architect/
│       ├── .claude-plugin/
│       │   └── plugin.json       ← plugin manifest
│       └── skills/
│           └── skill-architect/  ← the actual skill folder
└── README.md
```

## License

MIT.
