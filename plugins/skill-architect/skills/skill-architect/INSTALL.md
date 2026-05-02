# Installing and publishing skill-architect

Two parts: **(1) install for yourself** on each surface, **(2) publish to other users**. The skill is a single self-contained folder; everything below is just plumbing.

---

## Folder layout (what you're shipping)

```
skill-architect/
├── SKILL.md                            (required — the entry point)
├── REFERENCE.md                        (extended methodology)
├── INSTALL.md                          (this file)
├── templates/
│   ├── proposal.md
│   ├── skill_brief.md
│   ├── verification_plan.md
│   └── risk_register.md
└── examples/
    ├── due_diligence.md
    └── cloud_deploy.md
```

The folder must contain a valid `SKILL.md` with frontmatter (`name`, `description`). Everything else is referenced from `SKILL.md` and loaded on demand.

---

## Part 1 — Installing for yourself

### Claude Code

User-scope (every Claude Code session, all projects):

```bash
mkdir -p ~/.claude/skills
cp -r "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect" ~/.claude/skills/
```

Project-scope (only inside one repo):

```bash
mkdir -p .claude/skills
cp -r "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect" .claude/skills/
```

### Cowork

Cowork loads skills from the same plugin/skills mechanism as Claude Code. The cleanest install for Cowork is to **package as a plugin** (see Part 2 below) and place the plugin under your user-level Claude plugins directory:

```bash
mkdir -p ~/.claude/plugins
# After packaging the plugin folder:
cp -r skill-architect-plugin ~/.claude/plugins/
```

Restart Cowork after installing so the plugin is picked up.

### Claude.ai (web / desktop chat)

Claude.ai accepts skills as `.skill` packages or as a zipped folder via the skills upload UI:

```bash
cd "/Users/yoda2/Documents/Claude/Projects/Skill Building"
zip -r skill-architect.zip skill-architect/
```

Open Claude.ai → Skills → Upload → select `skill-architect.zip`. The skill auto-triggers in any future conversation on the same account.

If Claude.ai requires a `.skill` package specifically, use skill-creator's packager:

```bash
# from a checkout of the existing skill-creator skill:
python -m scripts.package_skill "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect"
```

### Verifying the trigger

After installing, on each surface, try:

- "I want to create a skill for my law firm's internal research process." → **should trigger**
- "Let's build a skill that helps me evaluate startup pitches." → **should trigger**
- "Make me a due-diligence skill for buying a coffee shop." → **should trigger**
- "Turn this conversation into a skill." → **should trigger**

And confirm it does NOT fire on:

- "What is a skill, exactly?"
- "Show me the skills I have installed."
- "Run the pdf skill on this file."

If trigger behavior is wrong, run skill-creator's description optimizer (see "Tuning the description" at the bottom of this doc).

---

## Part 2 — Publishing to other users

There are four practical distribution paths. Pick based on the audience.

### 2a. Plugin bundle (best for teams using Claude Code or Cowork)

Wrap the skill in a plugin so teammates install with one command. Minimum plugin layout:

```
skill-architect-plugin/
├── plugin.json
└── skills/
    └── skill-architect/                (the entire folder above)
```

`plugin.json`:

```json
{
  "name": "skill-architect",
  "version": "0.1.0",
  "description": "Critical-thinking decomposition skill that runs before any new skill is authored. Sits on top of skill-creator. Decides between fast-path (single narrow skill) and full path (decomposition into 5–10+ layered skills) and surfaces every assumption before authoring.",
  "author": "Yoda <yehuda.ab@gmail.com>",
  "skills": ["skills/skill-architect"]
}
```

Build steps:

```bash
mkdir -p skill-architect-plugin/skills
cp -r "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect" \
      skill-architect-plugin/skills/
# write plugin.json (above)
```

Distribute the resulting `skill-architect-plugin` directory by zipping it or by pushing to a git repo (see 2c below). Recipients install with:

```bash
mkdir -p ~/.claude/plugins
cp -r skill-architect-plugin ~/.claude/plugins/
```

### 2b. Plugin marketplace (recommended for wider distribution)

A marketplace is a git repo that contains a `marketplace.json` listing one or more plugins. Users add the marketplace once, then install plugins from it by name.

**Repo strategy: marketplace-monorepo vs. repo-per-plugin.** This is the question most often asked, and the honest answer is "depends on scale". Here's how to choose:

| Pattern | What it looks like | Best when |
|---|---|---|
| **Marketplace-monorepo** | One repo (e.g., `yoda-skills`) that *is* the marketplace and *contains* all plugins as subfolders. `marketplace.json` lives in `.claude-plugin/` at the repo root; plugins live under `plugins/<name>/`. | You're shipping 1–5 plugins, all your own, all related. Less overhead. Cohesive releases. One CI, one issues tab. **Start here.** |
| **Repo-per-plugin + thin marketplace repo** | Each plugin is its own repo (e.g., `skill-architect`). A separate `yoda-skills` marketplace repo's `marketplace.json` references each plugin via its git URL or as a submodule. | 6+ plugins, mixed audiences/licenses, external contributors per plugin, independent versioning matters, you want to deprecate or transfer ownership of one plugin without touching others. |

**My recommendation for you, right now: marketplace-monorepo.** You have one plugin. The monorepo gives you the smallest amount of plumbing to maintain and you can split per-plugin later by extracting the subfolder with `git filter-repo`. The path of least regret. Your colleague's repo-per-plugin pattern is *also* fine — it's just heavier than you need today.

**The structure that's already built for you** (in `/Users/yoda2/Documents/Claude/Projects/Skill Building/yoda-skills/`):

```
yoda-skills/                              ← the marketplace repo (push to GitHub)
├── README.md
├── .claude-plugin/
│   └── marketplace.json                  ← the marketplace manifest
└── plugins/
    └── skill-architect/                  ← one plugin
        ├── .claude-plugin/
        │   └── plugin.json               ← the plugin manifest
        └── skills/
            └── skill-architect/          ← the actual skill folder (SKILL.md etc.)
```

`marketplace.json` (already created):

```json
{
  "name": "yoda-skills",
  "owner": { "name": "Yoda", "email": "yehuda.ab@gmail.com" },
  "metadata": {
    "description": "Skill-building utilities by Yoda — meta-skills, decomposition tools, and critical-thinking helpers.",
    "version": "0.1.0"
  },
  "plugins": [
    {
      "name": "skill-architect",
      "source": "./plugins/skill-architect",
      "description": "Critical-thinking decomposition skill that runs before any new skill is authored...",
      "version": "0.1.0",
      "tags": ["meta", "skill-creation", "critical-thinking", "decomposition", "verification"]
    }
  ]
}
```

**To publish:**

```bash
cd "/Users/yoda2/Documents/Claude/Projects/Skill Building/yoda-skills"
git init
git add .
git commit -m "Initial release: skill-architect 0.1.0"
gh repo create yodausername/yoda-skills --public --source=. --push
# (or: create on GitHub manually, then: git remote add origin ... && git push -u origin main)
```

**Recipients install with:**

```bash
# In Claude Code or Cowork
/plugin marketplace add github:yodausername/yoda-skills
/plugin install skill-architect@yoda-skills
```

(Exact slash-command syntax may vary by Claude Code/Cowork version — check `/plugin --help`. If those exact commands don't exist on the recipient's version, they can clone the repo and copy the plugin folder into `~/.claude/plugins/`.)

**Adding a second plugin to the same marketplace later:**

```bash
cd yoda-skills/plugins
mkdir my-second-plugin
# add .claude-plugin/plugin.json and skills/ inside
# then add an entry to ../.claude-plugin/marketplace.json
git add . && git commit -m "Add my-second-plugin 0.1.0" && git push
```

That's the whole monorepo workflow. If a plugin grows past the point where it deserves its own repo (independent contributors, separate license, separate release cadence), extract it with `git filter-repo --subdirectory-filter plugins/that-plugin` into a new repo and update `marketplace.json` to reference the external git URL.

### 2c. Git repository (lightweight, no marketplace)

For a small team or open distribution without a marketplace:

```bash
cd "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect"
git init
git add .
git commit -m "skill-architect v0.1.0"
git remote add origin git@github.com:yodausername/skill-architect.git
git push -u origin main
```

Recipients clone into their skills folder:

```bash
git clone git@github.com:yodausername/skill-architect.git ~/.claude/skills/skill-architect
```

For Claude.ai users in the same audience, attach a download of the zipped folder to a release on the same repo so they can upload it to the Claude.ai skills UI.

### 2d. `.skill` package (best for one-off sharing or Claude.ai users)

A `.skill` file is a single-file portable package. Build with skill-creator's packager:

```bash
python -m scripts.package_skill "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect"
```

Send the resulting `skill-architect.skill` file by email, Slack, or attach to a release. Recipients drop it into Claude.ai's skill uploader, or unpack into `~/.claude/skills/` for Code/Cowork.

### Distribution decision table

| Audience | Best path |
|---|---|
| Just yourself across your machines | 2c (git clone) |
| Your team, all on Claude Code or Cowork | 2a (plugin) hosted on an internal git repo |
| Public users, you ship updates regularly | 2b (marketplace) |
| One-off share with a colleague | 2d (`.skill` file) or zip |
| Claude.ai-only users | 2d (`.skill` file) or zipped folder |

### Versioning, updates, and breaking changes

- Bump the `version` field in `plugin.json` for every distribution. Use semver: bump minor for additive changes, major for backward-incompatible workflow changes (e.g., changing the phases).
- Note breaking changes in a `CHANGELOG.md` at the top of the skill folder (create on first breaking change).
- For marketplace distribution (2b), recipients can pin to a version: `/plugin install skill-architect@0.1.0`.

### Licensing

Decide before publishing. Common choices:
- **MIT** if you want the broadest reuse.
- **Apache-2.0** if you want patent protection language.
- **Proprietary / internal-only** if it encodes IP you don't want shared (state this in `LICENSE` and the plugin description).

Add a `LICENSE` file at the top of the skill folder.

### Privacy / safety review before publishing

Before sharing widely, walk these:
- **No secrets.** Confirm there are no API keys, internal URLs, or personal identifiers in any file.
- **No client-confidential examples.** The worked examples in `examples/` should be illustrative, not from real client work.
- **Jurisdiction tags are explicit.** Other users in other jurisdictions should not silently inherit your defaults.
- **The skill respects skill-creator's "Principle of Lack of Surprise"** (see skill-creator/SKILL.md): no surprising or harmful behavior hidden in templates or scripts.

---

## Tuning the description (after install)

Skills auto-trigger based on their description in the SKILL.md frontmatter. After install, run skill-creator's description optimizer to tune triggering accuracy on the surface you're publishing for:

```bash
# from inside the existing skill-creator skill
python -m scripts.run_loop \
  --skill-path "/Users/yoda2/Documents/Claude/Projects/Skill Building/skill-architect" \
  --eval-set <path-to-trigger-eval.json> \
  --max-iterations 5 \
  --verbose
```

The eval set should include realistic should-trigger and should-NOT-trigger prompts. See `skill-creator/SKILL.md` "Description Optimization" for the full procedure (eval generation, train/test split, iteration loop). Re-publish the updated skill after the description converges.
