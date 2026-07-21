---
name: release
description: >-
  Manage release branches, apply version tags. Use when the user says
  something like "cut a release", "tag version X", or "prepare a release
  branch".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Release

Prepare a new software release.

You MUST NOT make any code or configuration changes to the software itself.
However, changes to other artifacts such as the project CHANGELOG may be made,
as instructed herein.

**Input:** Determine the following information from the surrounding context
and environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

<!--
- The target codebase — REQUIRED.
  Look in the user's last input prompt for an explicit reference to a target
  path or URL to a code repository. If a URL, clone the repository to a
  temporary directory. Otherwise, assume the target is the code repository
  under which the current working directory (cwd) sits. If the cwd is not part
  of a code repository, check the nearest `AGENTS.md` for paths to all the
  projects in the current workspace, else find all code repositories in nested
  subdirectories — assume they are all components of the target codebase. If the
  target codebase cannot be found, stop and alert the user.

- Where to write the report — REQUIRED.
  If not specified by the user, check the nearest `AGENTS.md` file for the path
  or URL to the audit reports. If not found, check if the current working
  directory has an `audits/` subdirectory that contains audit reports. If the
  path to the audit reports cannot be found, stop and alert the user.
-->

- A request to prepare a release — REQUIRED.

- The project's release model and version-tagging convention — REQUIRED.
  Either a single release trunk for continuous deployment, or
  `release/<version>` branches for release trains, plus the version-tagging
  convention that names the release.

**Output:** The release branch created or advanced per the model, and the
release tagged with a correctly-formatted version. This skill applies the
release branching and tagging convention and stops; it does not author commit
messages or define the general branch model.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Determine the release model and naming convention.**

    Choose one release strategy per the Rules section:

    - A single **release trunk**.

    - Multiple **release branches**.

2.  **Cut or advance the release branch from `ready`.**

    - For the **release** trunk: fast-forward it to the current `ready` tip.

    - For a `release/<version>` branch: run `git checkout -b release/<version> ready`.

3.  **Promote the `[Unreleased]` CHANGELOG section.**

    Before tagging, rename the `[Unreleased]` section in `CHANGELOG.md`
    to the version and date (eg. `## [1.2.0] - 2026-05-27`), and add a new empty
    `[Unreleased]` section above it. Include this as part of the
    `release:` commit on the release branch.

4.  **Tag the release.**

    Create an annotated version tag on the release branch:

    ```sh
    git tag -a v<version> -m "<release_notes>"
    ```

5.  **Build and ship artifacts.**

    Build production artifacts and ship them to the project's external
    artifact registry (Docker, npm, PyPI, S3, etc.), indexed by the version tag.

6.  **Clean up the release branch, if used.**

    For `release/<version>` branches, delete the branch after a
    successful deployment pipeline. The **release** trunk is permanent and is
    never deleted.

7.  **Prepare release notes for end users.**

    Where the project expects them, derive release notes from the
    newly promoted versioned section of `CHANGELOG.md`. Filter out
    internal changes (`refactor:`, `style:`, `step:`, `maintenance:`) and write
    the remainder in plain, non-technical language. The format and publication
    channel are project-specific.

## Rules

- **A single release strategy MUST be in use.**

  Either the **release** trunk (continuous deployment) or `release/<version>`
  branches (release trains) — not both. The name MUST match
  `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

- **All releases MUST be cut from `ready`.**

  The tip of `ready` is guaranteed to contain pristine, production-grade
  artifacts. Releases MUST NOT be cut from `dev` or `test`.

- **The **release** trunk rules.**

  - The **release** trunk MUST be permanent.

  - Its tip commit MUST always be a candidate for production deployment.

  - It MUST reference pre-built artifacts in external artifact registries.

- **`release/<version>` branch rules.**

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

- **Development MAY continue unblocked during release preparation.**

  No code freezes are required.

- **Build artifacts MUST live outside Git.**

  Compiled artifacts MUST be shipped to external artifact registries (Docker,
  npm, PyPI, S3, etc.) and referenced by tag — never committed to the
  repository.

- **Version tags are permanent.**

  They SHOULD be referenced in external artifact repos for traceability.

- **The `[Unreleased]` CHANGELOG section MUST be promoted at release time.**

  Before tagging, rename it to the version and date and add a fresh empty
  `[Unreleased]` section above it. This MUST land in the `release:` commit.

## Success criteria

- **The release branch exists and follows the chosen naming convention.**

  Either a permanent **release** trunk or a temporary `release/<version>` branch,
  matching `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

- **The release branch points to the `ready` tip from which it was cut.**

  Releases MUST NOT originate from `dev` or `test`.

- **The release MUST be tagged.**

  An annotated `v<version>` tag (eg. `v1.2.0`) MUST mark the release, and
  version tags are treated as permanent.

- **The CHANGELOG MUST be promoted.**

  The `[Unreleased]` section MUST be renamed to the version and date, a fresh
  empty `[Unreleased]` MUST be added above it, and this MUST land in the
  `release:` commit.

- **Artifacts MUST live outside Git.**

  Compiled artifacts MUST be shipped to an external registry (Docker, npm,
  PyPI, S3, …) and referenced by tag — never committed to the repository.

- **No fix MUST have been committed to a release branch.**

  Any correction MUST flow `dev` → `ready` → a new release branch; release
  branches carry only release-preparation commits.

- **A `release/<version>` branch, if used, MUST be deleted after tagging and
  a successful deployment pipeline.**

  The **release** trunk MUST remain intact.

## Examples

- **Release trunk:**

  ```
  release
  ```

- **Release branches:**

  ```
  release/1.2.0
  release/2.0.0
  release/next
  ```

- **Version tags:**

  ```
  v1.2.0
  v2.0.0
  ```
