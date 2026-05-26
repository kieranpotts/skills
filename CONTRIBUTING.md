# Contributing

Contributions are welcome – new skills, improvements to existing ones, bug fixes, and documentation tweaks.

## Suggesting a new skill

Before proposing a new skill, check it against these criteria. A skill is worth adding when it:

- **Encodes judgement, interpretation, or context-sensitivity.** Skills are for recurring work that can't be reduced to a deterministic rule.

- **Has no deterministic substitute.** If a linter, formatter, validator, Git hook, build script, or CI job already does (or could do) the job, prefer that. Skills are for the parts of the SDLC that resist automation by conventional tools.

- **Covers a single concern** with a clear trigger condition.

- **Is technology- and domain-agnostic**, and so useful across diverse projects.

- **Is opinionated.** Skills should enforce one way of doing something, not a menu of options.

- **Fits the existing workflow** with explicit hand-offs to and from adjacent skills.

Do _not_ create a skill when:

- A deterministic tool already handles the task. Deployment of release artifacts, for example, belongs in a CI pipeline, not a skill.

- An existing skill already covers the concern. (Instead, propose to extend or refine the existing skill.)

- The shape is one-off, with no reusable form across projects.

- The content would primarily restate language- or framework-specific conventions.

Before opening a PR requesting to merge a new skill, file a `FEATURE` issue describing:

- The task or workflow the skill enables.
- The contexts in which it should trigger.
- The expected output, with a small example if helpful.

Discuss the shape of the skill, its scope and boundaries, and how it fits into the wider skills collection.

Then go ahead and open your PR, which should link to the issue. There's no need to wait for maintainer approval of the issue before starting work on the PR, but do be responsive to feedback on the issue and update your PR as needed.

## Submitting changes

This repository's own skills define the conventions for contributing:

- [`branch`](./skills/branch/SKILL.md): Branch naming and merge model.

- [`commit`](./skills/commit/SKILL.md): Commit message format and type semantics.

- [`create-skill`](./skills/create-skill/SKILL.md): Authoring a new skill, including required structure and validation.

In short:

1. Cut a `temp/<id>-<description>` branch from `dev`.

2. Make atomic commits.

3. Run the [validator](./skills/create-skill/scripts/validate.sh) over any new or modified skill directory.

4. Open a PR targeting `dev`.

## Style

- Start from the [skill template](./template/skill-name/SKILL.md). The [`create-skill`](./skills/create-skill/SKILL.md) skill covers required structure, naming, the 300-line cap, and validation.

- Write for token-efficiency. Trim anything that does not pull its weight. But balance context window management with the need for skills to be readable and editable by humans, too.

## Further reading

The [developer docs](./docs/) cover the topics below in more depth:

- [Creating skills](./docs/creating-skills.md) – required structure, naming conventions, and how to run the validator.

- [Publishing to skills.sh](./docs/publishing.md) – how this repo is consumed by the public skills.sh directory.

- [Releasing](./docs/releasing.md) – cutting tagged releases from `dev`.

- [Acknowledgements](./docs/acknowledgements.md) – prior work this collection draws on.

## Licensing

By contributing, you agree that your contribution will be licensed under the repository's [MIT license](./LICENSE.txt).
