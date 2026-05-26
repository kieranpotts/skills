# Contributing

Contributions are welcome – new skills, improvements to existing ones, bug fixes, and documentation tweaks.

## Suggesting a new skill

Before opening a PR for a new skill, file a `FEATURE` issue describing:

- The task or workflow the skill enables.
- The contexts in which it should trigger.
- The expected output, with a small example if helpful.

Discuss the shape of the skill, its scope and boundaries, and how its fits into the wider skills collection.

## Submitting changes

This repository's own skills define the conventions for contributing:

- [`branch`](./skills/branch/SKILL.md): Branch naming and merge model.
- [`commit`](./skills/commit/SKILL.md): Commit message format and type semantics.
- [`create-skill`](./skills/create-skill/SKILL.md): Authoring a new skill, including required structure and validation.

In short:

1. Cut a `temp/<id>-<description>` branch from `dev`.
2. Make atomic commits using the project's `<type>: <description>` format.
3. Run the [validator](./skills/create-skill/scripts/validate.sh) over any new or modified skill directory.
4. Open a PR targeting `dev`.

## Style

- All skills use the [skill template](./template/skill-name/SKILL.md) as a starting point.
- Skill names are kebab-case verbs (eg. `commit`, `release`, `create-skill`).
- SKILL.md files stay under ~300 lines. Deeper detail belongs in `references/`.
- Write for token-efficiency. Trim anything that does not pull its weight. But balance the need to manage the contex window with the need for skills to be understandable and easily-editable by humans, too.

## Licensing

By contributing, you agree that your contribution will be licensed under the repository's [MIT license](./LICENSE.txt).
