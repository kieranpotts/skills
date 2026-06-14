# 🤖 `/release`

Release trunks and branches, plus version tags – a single `release` trunk for continuous deployment, or `release/<version>` branches for release trains, with version-tagging conventions. Runs non-interactively (🤖). Use when preparing a release, creating a release branch, or tagging a release version.

## What it does

`/release` defines two mutually exclusive release strategies and the rules for each: a single permanent `release` trunk auto-promoted from `ready` (for continuous deployment), or `release/<version>` branches cut from `ready` (for release trains). It applies the chosen strategy – cutting from the `ready` trunk tip, tagging with annotated `v<version>` tags, and promoting the `[Unreleased]` changelog section to a versioned, dated heading.

It is reference-and-apply, non-interactive.

## How to invoke

Invoke it to choose a strategy, cut a release branch, or tag a version. Describe the release context and it applies the matching strategy, names the branch/tag, and handles the changelog promotion.

- `/release`, `/skill:release` (prompt varies by agent harness).
- "Cut a release."
- "Tag version 2.1.0."
- "Prepare a release branch."
