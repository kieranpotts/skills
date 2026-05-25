# Publishing to skills.sh

[skills.sh](https://www.skills.sh/) is a public directory and leaderboard for agent skills, backed by the [`vercel-labs/skills`](https://github.com/vercel-labs/skills) package.

There is no submission form. A repo appears on the skills.sh leaderboard as soon as someone installs from it via `npx skills add`, which sends anonymous telemetry.

## Requirements

- The repo must be public on GitHub.

- Each skill must be discoverable by the `skills` CLI. It will look for a root-level `SKILL.md`, or a `skills/` directory following the [Agent Skills](https://agentskills.io/) convention.

- Each `SKILL.md` needs YAML frontmatter with at least `name` (lowercase, hyphens) and `description`.

Verify discovery using this command:

```sh
npx skills add kieranpotts/skills --list
```

`--list` previews what would be installed without writing anything. If a skill is missing, the cause is almost always a `SKILL.md` frontmatter mismatch.
