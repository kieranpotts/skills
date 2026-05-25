# Creating skills

To create a new skill, use the template in [`template/skill-name/`](../template/skill-name/) as a starting point. Alternatively, use the [`create-skill`](../skills/create-skill/SKILL.md) skill, which captures the full authoring workflow including validation.

Each skill MUST include:

- A `SKILL.md` file with:
  - YAML frontmatter. `name` and `description` are REQUIRED. Other fields like `compatibility` and `license` are OPTIONAL.
  - At least one of `## Instructions` (ordered procedural steps) or `## Rules` (unordered guidelines).
  - A `## Success criteria` section listing self-verifiable checks.
- A sibling `README.md` (human-readable documentation).

The following sections are OPTIONAL:

- `## Examples` — canonical input/output examples.
- `## Edge cases` — known pitfalls.
- `## References` — links to supporting material, each with an explicit trigger condition.

## Validating a skill

The `create-skill` skill bundles a validator that wraps `skills-ref` (if installed) and adds repo-specific checks:

```sh
skills/create-skill/scripts/validate.sh skills/<your-skill>/
```

It enforces the sibling `README.md`, a ~300-line cap on `SKILL.md`, and the presence of `## Instructions`/`## Rules` and `## Success criteria`.

## References

- [Agent Skills: Best Practices](https://agentskills.io/skill-creation/best-practices)

- [Anthropic's skills](https://github.com/anthropics/skills/tree/main/skills)

- [Pi skills](https://pi.dev/docs/latest/skills)
