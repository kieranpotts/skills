# 🤖 `/commit`

Commit message conventions: the message format and the semantics of each commit type. Runs non-interactively (🤖). Use when composing a commit message, validating a branch's messages before push, or troubleshooting a failed commit-validation CI job.

## What it does

`/commit` defines a fixed subject-line format – `<type>: <description>` with an optional ` - <flag>` suffix, optional body and footers – and a validation regex that checks the subject. It enumerates the allowed types (`chore`, `feature`, `fix`, `format`, `maintenance`, `merge`, `refactor`, `release`, `revert`, `runtime`, `step`) with the precise semantics of each, and the flags (`BREAKING`, `EXPERIMENT`, `INCOMPAT`, `TEMPORARY`, `WIP`). It enforces atomic commits, lowercase imperative descriptions, a length budget, and – for direct commits to `dev` or `temp/*` – a matching `CHANGELOG.md` entry under `[Unreleased]`.

It is reference-and-validate, non-interactive. Note: this convention is deliberately **not** Conventional Commits – scopes like `feature(parser):` fail validation; the colon comes immediately after the type.

## How to invoke

```
/commit
```

Invoke it to author a message, to vet a branch's messages before push, or to understand a commit-validation CI failure. Describe the change and it picks the type (resolving close calls via the skill's "subtle distinctions" notes) and drafts the message; give it a message and it validates against the regex.

## Examples

For a defect fix it produces `fix: handle empty repository in git-amend`; for incremental non-user-facing work, `step: extract search algorithm to separate module`; for a breaking removal, `feature: remove legacy auth endpoint - BREAKING`. Faced with `feature(parser): add support`, it rejects the scope parenthetical and rewrites it as `feature: add parser support`. For a commit to `dev`, it also adds the matching `[Unreleased]` changelog bullet.
