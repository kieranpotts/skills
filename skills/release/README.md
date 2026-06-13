# `/release`

Release branching strategy – a single `release` trunk for continuous deployment, or `release/<version>` branches for release trains – plus version-tagging conventions. Use when preparing a release, creating a release branch, or tagging a release version.

## What it does

`/release` defines two mutually exclusive release strategies and the rules for each. A single permanent `release` trunk, auto-promoted from `ready`, suits continuous deployment; `release/<version>` branches cut from `ready` suit release trains and big-bang releases. Both validate against one regex. The rules pin down where releases are cut from (always the `ready` trunk tip, whose artifacts are production-grade), how they're tagged (annotated `v<version>` tags, treated as permanent), and the hard constraints: never commit a fix to a release branch (fixes flow `dev` → `ready` → a fresh release branch), and ship compiled artifacts to an external registry (Docker, npm, PyPI, S3), never to Git. At release time it promotes the `[Unreleased]` changelog section to a versioned, dated heading and opens a fresh empty one.

It is reference-and-apply, non-interactive.

## How to invoke

```
/release
```

Invoke it to choose a strategy, cut a release branch, or tag a version. Describe the release context and it applies the matching strategy, names the branch/tag, and handles the changelog promotion. No other arguments.

## Examples

For a release train, `/release` cuts `release/1.2.0` from the `ready` tip, lands a `release:` commit that renames `[Unreleased]` to `## [1.2.0] - 2026-05-27` (adding a new empty `[Unreleased]` above it), tags `v1.2.0` annotated with the release notes, and notes that artifacts go to the external registry indexed by tag – with the branch deleted after a successful pipeline.

Asked to patch a release branch directly, it refuses: the fix must originate on `dev` and flow forward through `ready` into a new release branch, because release branches carry only release-preparation commits.
