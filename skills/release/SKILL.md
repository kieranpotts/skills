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

**Input**: A request to prepare a release, plus the project's release model (a single `release` trunk for continuous deployment, or `release/<version>` branches for release trains) and its version-tagging convention. REQUIRED.

**Output**: The release branch created or advanced per the model, and the
release tagged with a correctly-formatted version. This skill applies the
release branching and tagging convention and stops; it does not author commit
messages or define the general branch model.

**Interactivity**: Agents MUST NOT block for user input after the initial
prompt. Agents MUST follow this skill's instructions to completion, or fail
with an error message.

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

    - MUST be cut from `ready` trunk tip: `git checkout -b release/<version>
      ready`.

    - Temporary; MUST be deleted after tagging and a successful deployment
      pipeline.

    - MUST contain only release-preparation commits: version bumps, changelog
      updates, release-specific config.

    - MUST be tagged with version: `git tag -a v<version> -m "<release_notes>"`.

    - Build artifacts MUST be stored in an external artifact registry, indexed by
      tag.

    - If preparation fails, you MUST abandon the branch and start over.

    - You MUST NOT commit fixes to release branches. Fixes MUST flow through
      `dev` → `ready` → new release branch.

    - The placeholder name `release/next` MAY be used if the version is not yet
      decided.

-   **General**:

    - All releases MUST be cut from `ready` trunk, the tip of which is guaranteed
      to always contain pristine, production-grade artifacts.

    - Development MAY continue unblocked during release preparation (no code
      freezes).

    - Compiled artifacts MUST be shipped to external artifact registries (Docker,
      npm, PyPI, S3, etc.), never to the Git repository.

    - Version tags are permanent, and SHOULD be referenced in external artifact
      repos for traceability.

-   **You MUST promote the `[Unreleased]` CHANGELOG section at release time.**

    Before tagging, rename the `[Unreleased]` section in `CHANGELOG.md` to the
    version and date (eg. `## [1.2.0] - 2026-05-27`), and add a new empty
    `[Unreleased]` section above it. Include this as part of the `release:`
    commit on the release branch. This ties each changelog entry to a specific
    shipped version.

-   **You SHOULD prepare release notes for end users.** *(Draft — process to be defined.)*

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

-   **A single release strategy MUST be in use.**

    Either the `release` trunk (continuous deployment) or `release/<version>`
    branches (release trains) — not both. The name MUST match
    `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

-   **The release MUST have been cut from `ready`.**

    Release branches MUST branch from the `ready` trunk tip, whose artifacts are
    production-grade — never from `dev` or `test`.

-   **The release MUST be tagged.**

    An annotated `v<version>` tag (eg. `v1.2.0`) MUST mark the release, and
    version tags are treated as permanent.

-   **The CHANGELOG MUST be promoted.**

    The `[Unreleased]` section MUST be renamed to the version and date, a fresh
    empty `[Unreleased]` MUST be added above it, and this MUST land in the
    `release:` commit.

-   **Artifacts MUST live outside Git.**

    Compiled artifacts MUST be shipped to an external registry (Docker, npm,
    PyPI, S3, …) and referenced by tag — never committed to the repository.

-   **No fix MUST have been committed to a release branch.**

    Any correction MUST flow `dev` → `ready` → a new release branch; release
    branches carry only release-preparation commits.
