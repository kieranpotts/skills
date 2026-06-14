# 🤖 `/commit`

Commit message conventions: the message format and the semantics of each commit type. Runs non-interactively (🤖). Use when composing a commit message, validating a branch's messages before push, or troubleshooting a failed commit-validation CI job.

## What it does

`/commit` defines a fixed subject-line format – `<type>: <description>` with an optional ` - <flag>` suffix – a set of allowed commit types and flags with precise semantics for each, and a validation regex. It enforces atomic commits and, for direct commits to `dev` or `temp/*`, a matching `CHANGELOG.md` entry under `[Unreleased]`.

It is reference-and-validate, non-interactive. Note: this convention is deliberately **not** Conventional Commits – scopes like `feature(parser):` fail validation; the colon comes immediately after the type.

## How to invoke

Invoke it to author a message, to vet a branch's messages before push, or to understand a commit-validation CI failure. Describe the change and it drafts the message; give it a message and it validates it.

- `/commit`, `/skill:commit` (prompt varies by agent harness).
- "Write a commit message for this."
- "Is this commit message valid?"
- "Why did commit validation fail in CI?"

## References

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commit-messages) is used to validate commit messages against the conventions described in TS-9 and this skill.
