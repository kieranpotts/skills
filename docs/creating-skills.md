# Creating skills

This is the canonical reference for creating new skills **in this repository**. For creating skills in *other* projects that have installed this collection, use the portable [`create-skill`](../skills/create-skill/SKILL.md) skill instead – this doc is repo-internal.

To create a new skill, copy [`template/skill-name/`](../template/skill-name/) as your starting point. The template documents the required structure of `SKILL.md` and `README.md` inline – it is the source of truth for file layout, frontmatter fields, and section structure.

Before drafting, see [CONTRIBUTING.md](../CONTRIBUTING.md) for the criteria a useful skill should meet and the proposal workflow (file a `FEATURE` issue first).

## Naming

Skill names are kebab-case and SHOULD be meaningful actions or verbs — `spec`, `commit`, `release`, `review`, `create-skill`. A verb-first name makes the skill's purpose obvious both to the agent (when deciding whether to trigger) and in the skills.sh index. Prefer single verbs; use `<verb>-<noun>` only when disambiguation is needed (eg. `create-skill`).

## Validating a skill

A validator ships at [`skills/create-skill/scripts/validate.sh`](../skills/create-skill/scripts/validate.sh):

```sh
skills/create-skill/scripts/validate.sh skills/<your-skill>/
```

It wraps `skills-ref` (if installed) for the canonical [Agent Skills](https://agentskills.io/) checks, and adds this repo's stricter ones: a ~300-line cap on `SKILL.md`, presence of `## Instructions`/`## Rules`, and a `## Success criteria` section.

## References

- [Agent Skills: Best Practices](https://agentskills.io/skill-creation/best-practices)

- [Anthropic's skills](https://github.com/anthropics/skills/tree/main/skills)

- [Pi skills](https://pi.dev/docs/latest/skills)
