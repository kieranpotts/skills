# Creating skills

This is the canonical reference for creating new skills **in this repository**. For creating skills in *other* projects that have installed this collection, use the portable [`create-skill`](../skills/create-skill/SKILL.md) skill instead – this doc is repo-internal.

To create a new skill, copy [`template/skill-name/`](../template/skill-name/) as your starting point. The template documents the required structure of `SKILL.md` and `README.md` inline – it is the source of truth for file layout, frontmatter fields, and section structure.

Before drafting, file a `FEATURE` issue to discuss scope and fit — see [CONTRIBUTING.md](../CONTRIBUTING.md) for the full proposal and PR workflow.

## When to create a skill

A skill is worth adding when it:

- **Encodes judgement, interpretation, or context-sensitivity.** Skills are for recurring work that can't be reduced to a deterministic rule.

- **Has no deterministic substitute.** If a linter, formatter, validator, Git hook, build script, or CI job already does (or could do) the job, prefer that. Skills are for the parts of the SDLC that resist automation by conventional tools.

- **Covers a single concern** with a clear trigger condition.

- **Is technology-agnostic and domain-agnostic**, and so useful across diverse projects.

- **Is opinionated.** Skills should describe one clear path for achieving a goal, not offer a menu of options.

- **Fits the existing workflow** with explicit hand-offs to and from adjacent skills.

Do _not_ create a skill when:

- A deterministic tool already handles the task. Deployment of release artifacts, for example, belongs in a CI pipeline, not a skill.

- An existing skill already covers the concern. (Instead, propose to extend or refine the existing skill.)

- The shape is one-off, with no reusable form across projects.

- The content would primarily restate language-specific or framework-specific conventions.

## Naming

Skill names are kebab-case and SHOULD be meaningful actions or verbs — `spec`, `commit`, `release`, `review`, `create-skill`. A verb-first name makes the skill's purpose obvious both to the agent (when deciding whether to trigger) and in the skills.sh index. Prefer single verbs; use `<verb>-<noun>` only when disambiguation is needed (eg. `create-skill`).

## Bundled resources

Each skill may include up to three standard subdirectories alongside `SKILL.md`:

- `assets/`: Static files used in output: templates, example content, icons, etc.

- `references/`: Detailed documentation loaded into context on demand.  Link from `SKILL.md` with an explicit trigger condition so the agent progressively loads them into context when needed.

- `scripts/`: Executable scripts for deterministic or repetitive sub-tasks. Reference from `SKILL.md` with instructions for when and how to run them.

**Only these three subdirectories are propagated by the custom installer.** Any other directories present in a skill folder are silently ignored for all agent targets.

### Collision safety

For Claude Code and Pi, each skill installs as its own self-contained directory, so subdirectory contents never interact across skills. But for Copilot and Cursor, skills compile to flat instruction/rules files and the installer merges all `assets/`, `references/`, and `scripts/` directories into a single shared directory at the target. Thus, two skills that both write `assets/foo.md` will collide — the second silently overwrites the first.

To avoid this, pay careful attention to the naming of static assets, reference docs, and scripts. Use a namespacing convention to ensure uniqueness across the entire collection of skills.

```
skills/
└── my-skill/
    ├── assets/
    │   └── my-skill/          ← Asset namespaced by a subdirectory
    │       └── template.md      named after the skill.
    └── references/
        └── my-skill-api-errors.md    ← Namespaced by filename prefix.
```

## Style

- Start from the [skill template](../template/skill-name/SKILL.md). Do NOT use the [`create-skill`](../skills/create-skill/SKILL.md) skill to add skills here – it is packaged for downstream projects, not for this repo's contribution workflow.

- Write for token-efficiency. Trim anything that does not pull its weight. But balance context window management with the need for skills to be readable and editable by humans, too.

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
