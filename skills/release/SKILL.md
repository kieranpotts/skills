---
name: release
description: >-
  Cut and tag a software release, following the project's release branching
  and version-tagging conventions. Use when the user says something like
  "cut a release", "tag version 1.2.0", "prepare a release branch", or "ship
  the release". Do not use it to author commit messages or to define the
  project's general branch model.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (git branch, git checkout, git tag)
license: CC0-1.0
---

# Release

Prepare a new software release: cut or advance the release branch, promote the
changelog, apply the version tag, and ship the build artifacts. You MUST NOT
change the software's own source code or configuration.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Release model — REQUIRED.** Either a single permanent release trunk
  (continuous deployment) or temporary `release/<version>` branches (release
  trains). Discover which one the project uses from its existing branches and
  its documented version-control conventions.

- **Version-tagging convention — REQUIRED.** The tag format that names a
  release. Discover it from the project's existing tags. Where the project has
  none, default to an annotated `v<version>` tag, eg. `v1.2.0`.

- **Version — REQUIRED.** The version being released. Derive it from the
  project's versioning scheme and the changes accumulated since the last
  release tag.

- **Release-ready trunk — REQUIRED.** The trunk whose tip is guaranteed to
  hold pristine, production-grade revisions, and from which releases are cut.
  Discover its name from the project's branch model; it is conventionally
  `ready`.

- **Changelog store — OPTIONAL.** Where the project records its release
  history, if it keeps one. Resolve it from context, then from the
  environment — a convention file, a workspace manifest, an existing
  directory. Do not assume a `CHANGELOG.md` at the repository root. Skip
  changelog promotion where the project keeps no changelog.

- **Artifact registry — OPTIONAL.** The external registry that receives the
  build, eg. Docker, npm, PyPI, S3. Discover it from the project's build and
  deployment configuration. Skip the shipping step where the project
  publishes nothing.

## Success criteria

- The release branch MUST have been created or advanced from the tip of the
  release-ready trunk, and its name MUST match
  `^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$`.

- An annotated version tag following the project's tagging convention MUST
  mark the tip of the release branch.

- Where the project keeps a changelog, its unreleased section MUST have been
  promoted to the released version and date, with a fresh empty unreleased
  section above it — both landing in the release commit.

- Where the project publishes a build, the artifacts MUST be retrievable from
  its registry under the released version, and `git status` MUST show no
  compiled artifact added to the repository.

- The software's own source code and configuration MUST be unchanged: the
  release commit SHOULD touch only the changelog, version manifests, and
  release-specific configuration.

- A temporary `release/<version>` branch MUST NOT survive a successful tagging
  and deployment run, whereas a permanent release trunk MUST still exist
  afterwards.

## Instructions

1.  Establish the release model, the tagging convention, and the version, as
    described under Parameters. Stop with an error if the project does not
    settle them.

2.  Cut or advance the release branch from the release-ready trunk.

    For a release trunk, fast-forward it to the current tip of the
    release-ready trunk. For a versioned release branch:

    ```sh
    git checkout -b release/<version> <ready-trunk>
    ```

3.  Promote the changelog's unreleased section, where the project keeps a
    changelog.

    Rename the unreleased section to the version and date being released,
    eg. `## [1.2.0] - 2026-05-27`, and open a fresh empty unreleased section
    above it. Follow whatever format that changelog documents for itself.
    Land this in the release commit on the release branch.

4.  Tag the release with an annotated tag on the release branch. An annotated
    tag carries the tagger, date, and message that a lightweight tag does not,
    and release provenance depends on them.

    ```sh
    git tag -a v<version> -m "<release_notes>"
    ```

5.  Build the production artifacts and ship them to the project's artifact
    registry, indexed by the version tag. Skip this where the project
    publishes nothing.

6.  Delete a temporary `release/<version>` branch once tagging and the
    deployment pipeline have both succeeded. Leave a permanent release trunk
    in place.

7.  Prepare release notes for end users, where the project expects them.

    Derive them from the newly promoted changelog section. Filter out changes
    that are internal to the codebase — refactors, formatting, tooling, and
    maintenance — and rewrite the remainder in plain, non-technical language.
    The format and publication channel are project-specific.

## Rules

- Exactly one release strategy MUST be in use: either the release trunk or
  `release/<version>` branches, never both.

  Running both leaves two competing answers to the question of what is
  deployable now.

- Releases MUST be cut from the release-ready trunk, and MUST NOT be cut from
  an integration or test trunk.

  Only the release-ready trunk is guaranteed to hold production-grade
  revisions.

- A release branch MUST carry only release-preparation commits: version bumps,
  changelog promotion, and release-specific configuration.

- You MUST NOT commit a fix to a release branch.

  Fixes flow back through the integration trunk and out to the release-ready
  trunk, so a fix made under release pressure is never stranded off the
  mainline.

- If release preparation fails, you SHOULD abandon the branch and start over
  rather than repairing it in place, so the branch's history stays a clean
  record of one release attempt.

- A release trunk, where used, MUST be permanent, and its tip commit MUST
  always be a candidate for production deployment.

- Version tags MUST be treated as permanent, and SHOULD be recorded against
  the corresponding entry in the artifact registry for traceability.

- Development MAY continue unblocked during release preparation. No code
  freeze is REQUIRED.

- This task MUST stop at applying the release branching and tagging
  convention. Authoring commit messages and defining the project's general
  branch model are separate responsibilities, left to the caller.

## Edge cases

- The version is not yet decided.

  You MAY cut the branch as `release/next`, and rename it once the version is
  settled. Do not apply a version tag until the version is known.

- The tip of the release-ready trunk already carries a release tag.

  There is nothing new to release. Stop and report the existing tag rather
  than cutting an empty release.

- The project has no release trunk or release branches yet.

  This is its first release. Create the branch according to the release model
  you established, cutting from the release-ready trunk as usual.

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

## References

- [TS-9: Version Control](https://kieranpotts.com/standards/009) \
  Read when the project documents no release model or tagging convention of
  its own, for the conventions these instructions assume.
