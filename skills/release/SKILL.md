---
name: release
description: >-
  Release branching strategy — either a single `release` trunk for continuous
  deployment, or `release/<version>` branches for release trains — and
  version-tagging conventions. Use when preparing a release, creating a release
  branch, or tagging a release version, or when the user says "cut a release",
  "tag version X", or "prepare a release branch".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Release

Use this skill when preparing releases, creating release branches, or tagging
release versions.

## Interface

**Input**: A request to prepare a release, plus the project's release model (a
single `release` trunk for continuous deployment, or `release/<version>`
branches for release trains) and its version-tagging convention. REQUIRED.

**Interactive**: TODO -  Whether the skill runs non-interactively to completion,
or is necessarily interactive — blocking to ask questions, present options, and
wait for answers.

**Output**: The release branch created or advanced per the model, and the
release tagged with a correctly-formatted version. This skill applies the
release branching and tagging convention and stops; it does not author commit
messages or define the general branch model.

## Instructions

Choose one release strategy:

-   A single **release trunk**:

    For continuous deployment. Naming convention:

    ```
    release
    ```

-   Multiple **release branches**:

    For release trains and big-bang releases. Naming convention:

    ```
    release/<version>
    ```

Validation regex (for both):

```
^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$
```

##  Rules

-   **Release trunk** (`release`):

    - Permanent trunk, auto-promoted from `ready` when verified.

    - The tip commit is always a candidate for production deployment.

    - References pre-built artifacts in external artifact registries.

-   **Release branches** (`release/<version>`):

    - Cut from `ready` trunk tip: `git checkout -b release/<version> ready`.

    - Temporary. Deleted after tagging and successful deployment pipeline.

    - Contains only release-preparation commits: version bumps, changelog
      updates, release-specific config.

    - Tag with version: `git tag -a v<version> -m "<release_notes>"`.

    - Build artifacts stored in external artifact registry, indexed by tag.

    - If preparation fails, abandon branch and start over.

    - Never commit fixes to release branches. Fixes MUST flow through `dev` →
      `ready` → new release branch.

    - Placeholder name `release/next` allowed if version not yet decided.

-   **General**:

    - All releases cut from `ready` trunk, the tip of which is guaranteed to
      always contain pristine, production-grade artifacts.

    - Development continues unblocked during release preparation (no code
      freezes).

    - Compiled artifacts are shipped to external artifact registries (Docker,
      npm, PyPI, S3, etc.), never to the Git repository.

    - Version tags are permanent. Reference them in external artifact repos for
      traceability.

-   **Promote the `[Unreleased]` CHANGELOG section at release time.**

    Before tagging, rename the `[Unreleased]` section in `CHANGELOG.md` to the
    version and date (eg. `## [1.2.0] - 2026-05-27`), and add a new empty
    `[Unreleased]` section above it. Include this as part of the `release:`
    commit on the release branch. This ties each changelog entry to a specific
    shipped version.

-   **Prepare release notes for end users.** *(Draft — process to be defined.)*

    Release notes are distinct from the CHANGELOG. Where the CHANGELOG records
    all changes for contributors and developers, release notes are curated for
    end users: user-facing features, bug fixes, and breaking changes, written in
    plain non-technical language. Derive them from the newly-promoted versioned
    section of `CHANGELOG.md`, filtering out internal changes (`refactor:`,
    `style:`, `step:`, `maintenance:`). The format and publication channel are
    project-specific.

## Examples

Release trunk:

```
release
```

Release branches:

```
release/1.2.0
release/2.0.0
release/next
```

Version tags:

```
v1.2.0
v2.0.0
```

##  Success criteria

-   **A single release strategy is in use.**

    Either the `release` trunk (continuous deployment) or `release/<version>`
    branches (release trains) — not both. The name matches
    `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

-   **The release was cut from `ready`.**

    Release branches branch from the `ready` trunk tip, whose artifacts are
    production-grade — never from `dev` or `test`.

-   **The release is tagged.**

    An annotated `v<version>` tag (eg. `v1.2.0`) marks the release, and version
    tags are treated as permanent.

-   **The CHANGELOG is promoted.**

    The `[Unreleased]` section is renamed to the version and date, a fresh empty
    `[Unreleased]` is added above it, and this lands in the `release:` commit.

-   **Artifacts live outside Git.**

    Compiled artifacts are shipped to an external registry (Docker, npm, PyPI,
    S3, …) and referenced by tag — never committed to the repository.

-   **No fix was committed to a release branch.**

    Any correction flows `dev` → `ready` → a new release branch; release
    branches carry only release-preparation commits.
