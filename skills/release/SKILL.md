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

**Input:** A request to prepare a release, plus the project's release model (a single **release** trunk for continuous deployment, or `release/<version>` branches for release trains) and its version-tagging convention. REQUIRED. This skill is non-interactive: agents MUST NOT block for user input after the initial prompt, and MUST follow the instructions to completion or fail with an error message.

**Output:** The release branch created or advanced per the model, and the
  release tagged with a correctly-formatted version. This skill applies the
  release branching and tagging convention and stops; it does not author commit
  messages or define the general branch model.

## Instructions

1.  **Determine the release model and naming convention.**

    You MUST choose one release strategy per the Rules section:

    -   A single **release trunk**.

    -   Multiple **release branches**.

2.  **Cut or advance the release branch from `ready`.**

    - For the **release** trunk: you MUST fast-forward it to the current `ready` tip.
    - For a `release/<version>` branch: you MUST run `git checkout -b release/<version> ready`.

3.  **Promote the `[Unreleased]` CHANGELOG section.**

    Before tagging, you MUST rename the `[Unreleased]` section in `CHANGELOG.md`
    to the version and date (eg. `## [1.2.0] - 2026-05-27`), and add a new empty
    `[Unreleased]` section above it. You MUST include this as part of the
    `release:` commit on the release branch.

4.  **Tag the release.**

    You MUST create an annotated version tag on the release branch:

    ```sh
    git tag -a v<version> -m "<release_notes>"
    ```

5.  **Build and ship artifacts.**

    You MUST build production artifacts and ship them to the project's external
    artifact registry (Docker, npm, PyPI, S3, etc.), indexed by the version tag.

6.  **Clean up the release branch, if used.**

    For `release/<version>` branches, you MUST delete the branch after a
    successful deployment pipeline. The **release** trunk is permanent and is
    never deleted.

7.  **Prepare release notes for end users.**

    Where the project expects them, you SHOULD derive release notes from the
    newly promoted versioned section of `CHANGELOG.md`. You SHOULD filter out
    internal changes (`refactor:`, `style:`, `step:`, `maintenance:`) and write
    the remainder in plain, non-technical language. The format and publication
    channel are project-specific.

## Rules

-   **A single release strategy MUST be in use.**

    Either the **release** trunk (continuous deployment) or `release/<version>`
    branches (release trains) — not both. The name MUST match
    `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

-   **All releases MUST be cut from `ready`.**

    The tip of `ready` is guaranteed to contain pristine, production-grade
    artifacts. Releases MUST NOT be cut from `dev` or `test`.

-   **The **release** trunk rules.**

    - The **release** trunk MUST be permanent.
    - Its tip commit MUST always be a candidate for production deployment.
    - It MUST reference pre-built artifacts in external artifact registries.

-   **`release/<version>` branch rules.**

    - A release branch MUST be cut from the `ready` trunk tip:
      `git checkout -b release/<version> ready`.
    - It MUST be temporary; it MUST be deleted after tagging and a successful
      deployment pipeline.
    - It MUST contain only release-preparation commits: version bumps, changelog
      updates, release-specific config.
    - It MUST be tagged with version: `git tag -a v<version> -m "<release_notes>"`.
    - Build artifacts MUST be stored in an external artifact registry, indexed by
      tag.
    - If preparation fails, you MUST abandon the branch and start over.
    - You MUST NOT commit fixes to release branches. Fixes MUST flow through
      `dev` → `ready` → a new release branch.
    - The placeholder name `release/next` MAY be used if the version is not yet
      decided.

-   **Development MAY continue unblocked during release preparation.**

    No code freezes are required.

-   **Build artifacts MUST live outside Git.**

    Compiled artifacts MUST be shipped to external artifact registries (Docker,
    npm, PyPI, S3, etc.) and referenced by tag — never committed to the
    repository.

-   **Version tags are permanent.**

    They SHOULD be referenced in external artifact repos for traceability.

-   **The `[Unreleased]` CHANGELOG section MUST be promoted at release time.**

    Before tagging, rename it to the version and date and add a fresh empty
    `[Unreleased]` section above it. This MUST land in the `release:` commit.

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

## Success criteria

-   **The release branch exists and follows the chosen naming convention.**

    Either a permanent **release** trunk or a temporary `release/<version>` branch,
    matching `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

-   **The release branch points to the `ready` tip from which it was cut.**

    Releases MUST NOT originate from `dev` or `test`.

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

-   **A `release/<version>` branch, if used, MUST be deleted after tagging and
    a successful deployment pipeline.**

    The **release** trunk MUST remain intact.
