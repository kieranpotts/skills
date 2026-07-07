# 🤖 `release`

`release` = release branching and tagging. It defines two mutually exclusive release strategies and the rules for each: a single permanent `release` trunk auto-promoted from `ready` (for continuous deployment), or `release/<version>` branches cut from `ready` (for release trains). It applies the chosen strategy — cutting from the `ready` trunk tip, tagging with annotated `v<version>` tags, and promoting the `[Unreleased]` changelog section to a versioned, dated heading.

Use it to choose a strategy, cut a release branch, or tag a version. Describe the release context and it applies the matching strategy, names the branch/tag, and handles the changelog promotion.

It is reference-and-apply. It runs non-interactively (🤖).

## How to invoke

- `/release`, `/skill:release` (prompt varies by agent harness).
- "Cut a release."
- "Tag version 2.1.0."
- "Prepare a release branch."

## Recommended models

Release branching and versioning follow a fixed convention, so a small, fast model is sufficient. This is rule application, not judgment.
