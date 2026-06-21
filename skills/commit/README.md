# 🤖 `/commit`

`/commit` = commit message conventions. It defines a fixed subject-line format – `<type>: <description>` with an optional ` - <flag>` suffix – a set of allowed commit types and flags with precise semantics for each, and a validation regex. It enforces atomic commits and, for direct commits to `dev` or `temp/*`, a matching `CHANGELOG.md` entry under `[Unreleased]`.

Use it when composing a commit message, validating a branch's messages before push, or troubleshooting a failed commit-validation CI job. Note: this convention is deliberately **not** Conventional Commits – scopes like `feature(parser):` fail validation; the colon comes immediately after the type.

This skill instructs the agent to run non-interactively (🤖).

## How to invoke

- `/commit`, `/skill:commit` (prompts vary by harness).
- "Write a commit message for this."
- "Is this commit message valid?"
- "Why did commit validation fail in CI?"

## References

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commit-messages) is used to validate commit messages against the conventions described in TS-9 and this skill.
