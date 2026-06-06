# Creating skills

This is the canonical reference for creating new skills in this repository. For creating skills in *other* projects that have installed this skills collection, use the portable [`create-skill`](../skills/create-skill/SKILL.md) skill instead.

**Contributors**: Before drafting a new skill, please file a `FEATURE` issue to discuss scope and fit. See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full contribution workflow.

To create a new skill, copy [`template/skill-name/`](../template/skill-name/) as your starting point. The template documents the required structure of `SKILL.md`. It is the source-of-truth for file layout, frontmatter fields, and section structure.

See also [best practices](./best-practices.md) for designing agentic workflows.

## Naming

Skill names are kebab-case and SHOULD be meaningful actions or verbs — `specify`, `commit`, `release`, `review`, `create-skill`. A verb-first name makes the skill's purpose obvious both to the agent (when deciding whether to trigger) and in the skills.sh index.

Prefer single verbs. Use `<verb>-<noun>` only when disambiguation is needed (eg. `create-skill`).

## Preferred model

A skill MAY declare a preferred model under the `metadata:` map, as `metadata.preferred_model`, to name the model it runs best under. The value is an exact model id, optionally provider-qualified (`provider/id`):

```yaml
metadata:
  preferred_model: claude-opus-4-8
```

`metadata` is the Agent Skills standard's sanctioned place for vendor data, so the key validates against the canonical schema and the skill stays portable — hosts that do not understand it simply ignore it. (It lives under `metadata` rather than as a top-level `x_`-prefixed key precisely because the canonical validator allowlists top-level fields.)

The Pi [`/realize`](https://github.com/kieranpotts/pi) pipeline is one host that reads it. When a phase loads a skill that declares `metadata.preferred_model` and that exact model is currently loaded, `/realize` runs the phase under it. If the model is not loaded — or the skill declares no preference — `/realize` falls back to its own per-phase model selection. The preference is therefore a hint, never a hard requirement, and a skill never fails for naming a model that happens to be absent.

Pin a model only when the skill genuinely depends on it (eg. a judgment-heavy review skill that needs a stronger model). Most skills should omit the field and inherit the host's default.

## Requirements levels

The following capitalized keywords, which are a subset of those defined in [IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt), MAY appear in `SKILL.md` frontmatter and body content to indicate the requirement level of a skill's criteria, instructions, rules, or success criteria. The meaning of these words are to be interpreted as described in RFC 2119.

- REQUIRED, MUST, MUST NOT
- RECOMMENDED, SHOULD, SHOULD NOT
- OPTIONAL, MAY

## Bundled resources

Each skill MAY include up to three standard subdirectories alongside `SKILL.md`:

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
