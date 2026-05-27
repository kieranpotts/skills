# Contributing

Contributions are welcome – new skills, improvements to existing ones, bug fixes, and documentation tweaks.

## Proposing a new skill

Before opening a PR for a new skill, file a `FEATURE` issue describing:

- The task or workflow the skill enables.
- The contexts in which it should trigger.
- The expected output, with a small example if helpful.

This is the place to discuss the shape of the skill, its scope and boundaries, and how it fits into the wider skills collection. See [`docs/creating-skills.md`](./docs/creating-skills.md) for the criteria a skill must meet and the authoring conventions for this repository.

There's no need to wait for maintainer approval of the issue before starting work on a PR, but do be responsive to feedback on the issue and update your PR as needed.

## Submitting changes

This repository's own skills define the conventions for branching and commits:

- [`branch`](./skills/branch/SKILL.md): Branch naming and merge model.

- [`commit`](./skills/commit/SKILL.md): Commit message format and type semantics.

In short:

1. Cut a `temp/<id>-<description>` branch from `dev`.

2. Make atomic commits.

3. Run the [validator](./skills/create-skill/scripts/validate.sh) over any new or modified skill directory.

4. Open a PR targeting `dev`, linking it to the relevant issue.

## Further reading

The [developer docs](./docs/) cover the topics below in more depth:

- [Creating skills](./docs/creating-skills.md): Criteria, authoring conventions, naming, bundled resources, and validation.

- [Publishing to skills.sh](./docs/publishing.md): How this repo is consumed by the public skills.sh directory.

- [Releasing](./docs/releasing.md): Cutting tagged releases from `dev`.

- [Acknowledgements](./docs/acknowledgements.md): Prior work this collection draws on.

## Licensing

By contributing, you agree that your contribution will be licensed under the repository's [MIT license](./LICENSE.txt).
