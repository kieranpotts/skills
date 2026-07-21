# Publishing to skills.sh

[skills.sh](https://www.skills.sh/) is a public directory and leaderboard for
agent skills, backed by the
[`vercel-labs/skills`](https://github.com/vercel-labs/skills) package.

There is no submission form. A repo appears on the skills.sh leaderboard as soon
as someone installs from it via `npx skills add`, which sends anonymous
telemetry.

## Requirements

- The repo must be public on GitHub.

- Each skill must be discoverable by the `skills` CLI. It will look for a
  root-level `SKILL.md`, or a `skills/` directory following the
  [Agent Skills](https://agentskills.io/) conventions.

- Each `SKILL.md` needs YAML front-matter with at least `name` (lowercase,
  hyphens) and `description`.

Verify discovery using this command:

```sh
npx skills add kieranpotts/skills --list
```

`--list` previews what would be installed. If a skill is missing, the cause is
almost always a `SKILL.md` front-matter mismatch.

## skills.sh.json

The optional `skills.sh.json` file in the repo root controls how the skills are
grouped and ordered on its skills.sh directory page. Without it, all skills are
listed ungrouped.

```json
{
  "$schema": "https://skills.sh/schemas/skills.sh.schema.json",
  "notGrouped": "bottom",
  "groupings": [
    {
      "title": "Group title",
      "description": "Group description.",
      "skills": ["skill-a", "skill-b"]
    }
  ]
}
```

- `notGrouped`: Where skills not assigned to any group appear. The value
  `"bottom"` pushes them below the defined groups.

- `groupings`: Ordered list of display groups, each with a `title`,
  `description`, and array of skill `name` values matching the `name` field in
  each `SKILL.md` front-matter.
