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
  preferred_model: ollama/WORKFLOW_STANDARD
---

# Release

Prepare a new software release.

You MUST NOT make any code or configuration changes to the software itself.
However, changes to other artifacts such as the project CHANGELOG may be made,
as instructed herein.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A request to prepare a release — REQUIRED.**

- **The project's release model and version-tagging convention — REQUIRED.**
  Either a single release trunk for continuous deployment, or
  `release/<version>` branches for release trains, plus the version-tagging
  convention that names the release.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

- The release branch MUST have been created or advanced, and MUST follow the
  chosen naming
  convention: it MUST be either a permanent release trunk or a temporary
  `release/<version>` branch, matching
  `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

- The release branch MUST point to the `ready` tip from which it was cut,
  and releases MUST NOT originate from `dev` or `test`.

- The release MUST be tagged: an annotated `v<version>` tag (eg. `v1.2.0`)
  MUST mark the release, and version tags are treated as permanent.

- The changelog MUST be promoted, where the project keeps one: its
  unreleased section MUST be promoted to the version and date, a fresh
  empty unreleased section MUST be opened above it, and this MUST land in
  the `release:` commit.

- Artifacts MUST live outside Git: compiled artifacts MUST be shipped to
  an external registry (Docker, npm, PyPI, S3, …) and referenced by tag —
  never committed to the repository.

- No fix MUST have been committed to a release branch: any correction MUST
  flow `dev` → `ready` → a new release branch, and release branches carry
  only release-preparation commits.

- A `release/<version>` branch, if used, MUST be deleted after tagging and
  a successful deployment pipeline, and the release trunk MUST remain
  intact.

## Instructions

1.  Determine the release model and naming convention.

    Choose one release strategy per the Rules section:

    - A single release trunk.

    - Multiple release branches.

2.  Cut or advance the release branch from `ready`.

    - For the release trunk: fast-forward it to the current `ready` tip.

    - For a `release/<version>` branch: run
      `git checkout -b release/<version> ready`.

3.  Promote the changelog's unreleased section.

    Where the project keeps a changelog, promote its unreleased section to
    the version and date being released (eg. `## [1.2.0] - 2026-05-27`), and
    open a fresh empty unreleased section above it. Follow that changelog's
    own format. Include this as part of the `release:` commit on the release
    branch. Where the project keeps no changelog, skip this step.

4.  Tag the release.

    Create an annotated version tag on the release branch:

    ```sh
    git tag -a v<version> -m "<release_notes>"
    ```

5.  Build and ship artifacts.

    Build production artifacts and ship them to the project's external
    artifact registry (Docker, npm, PyPI, S3, etc.), indexed by the version
    tag.

6.  Clean up the release branch, if used.

    For `release/<version>` branches, delete the branch after a successful
    deployment pipeline. The release trunk is permanent and is never
    deleted.

7.  Prepare release notes for end users.

    Where the project expects them, derive release notes from the newly
    promoted versioned section of the changelog. Filter out internal changes
    (`refactor:`, `style:`, `step:`, `maintenance:`) and write the remainder
    in plain, non-technical language. The format and publication channel are
    project-specific.

## Rules

- You MUST apply the release branching and tagging convention, and stop
  there.

  Authoring commit messages and defining the general branch model are
  separate responsibilities.

- A single release strategy MUST be in use.

  Either the release trunk (continuous deployment) or
  `release/<version>` branches (release trains) — not both. The name MUST
  match `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

- All releases MUST be cut from `ready`.

  The tip of `ready` is guaranteed to contain pristine, production-grade
  artifacts. Releases MUST NOT be cut from `dev` or `test`.

- The release trunk rules.

  - The release trunk MUST be permanent.

  - Its tip commit MUST always be a candidate for production deployment.

  - It MUST reference pre-built artifacts in external artifact
    registries.

- `release/<version>` branch rules.

  - A release branch MUST be cut from the `ready` trunk tip:
    `git checkout -b release/<version> ready`.

  - It MUST be temporary; it MUST be deleted after tagging and a
    successful deployment pipeline.

  - It MUST contain only release-preparation commits: version bumps,
    changelog updates, release-specific config.

  - It MUST be tagged with version:
    `git tag -a v<version> -m "<release_notes>"`.

  - Build artifacts MUST be stored in an external artifact registry,
    indexed by tag.

  - If preparation fails, you MUST abandon the branch and start over.

  - You MUST NOT commit fixes to release branches. Fixes MUST flow
    through `dev` → `ready` → a new release branch.

  - The placeholder name `release/next` MAY be used if the version is not
    yet decided.

- Development MAY continue unblocked during release preparation.

  No code freezes are required.

- Build artifacts MUST live outside Git.

  Compiled artifacts MUST be shipped to external artifact registries
  (Docker, npm, PyPI, S3, etc.) and referenced by tag — never committed
  to the repository.

- Version tags are permanent.

  They SHOULD be referenced in external artifact repos for
  traceability.

- The changelog's unreleased section MUST be promoted at release time,
  where the project keeps a changelog.

  Before tagging, promote it to the version and date and open a fresh empty
  unreleased section above it. This MUST land in the `release:` commit.
  Discover the changelog rather than assuming `CHANGELOG.md`.

## Examples

- Release trunk:

  ```sh
  release
  ```

- Release branches:

  ```sh
  release/1.2.0
  release/2.0.0
  release/next
  ```

- Version tags:

  ```sh
  v1.2.0
  v2.0.0
  ```
