---
name: release
description: >-
  Cut a software release from the release-ready trunk, promote the changelog,
  and apply the version tag. Use this skill when the user says something like
  "cut a release", "tag version 1.2.0", or "prepare a release branch". Do not
  use this skill to write or revise changelog entries, to build, publish, or
  deploy artifacts, to write release notes, or to author ordinary commits.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (git branch, git switch,
  git merge, git add, git commit, git tag, git describe, git symbolic-ref, git config)
license: CC0-1.0
---

# Release

Cut a new software release. Cut a new release branch or advance the existing
release trunk. Promote "unreleased" changes to "released" in the changelog, if
there is one. Commit those changes and apply an annotated tag, marking the
release point. Push the commit and its tag — this is expected to trigger an
upstream deployment pipeline.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Delivery pipeline — REQUIRED.** The group of trunks the release is cut
  from, named by the prefix those trunks share, eg. "latest" in
  `latest/ready`. If the name of the delivery pipeline is specified in the
  most-recent user prompt, eg. "the v2 pipeline", use that. Else take it from
  the repository's default branch, read with the command
  `git symbolic-ref --short refs/remotes/origin/HEAD`. A branch named
  `origin/latest/dev` gives "latest" as the name of the default delivery
  pipeline, while `origin/dev` gives an unnamed default pipeline.

- **Release model — REQUIRED.** The project is expected to use either a single
  permanent `[<pipeline>/]release` trunk (for continuous deployment) or
  temporary `[<pipeline>/]release/<version>` branches (for release trains), eg.
  `latest/release` or `latest/release/1.2.0`. Discover which one the pipeline
  uses from its existing branches and the project's documented version-control
  conventions.

- **Version — REQUIRED.** The version being released. Derive it from the
  project's versioning scheme and the changes accumulated since the pipeline's
  last release tag, read with `git describe --tags --abbrev=0 <ready-trunk>`.
  Do not assume a linear increment from the repository's newest tag, since this
  may belong to another delivery pipeline.

- **Release-ready trunk — REQUIRED.** The trunk whose tip is guaranteed to hold
  production-grade revisions, and from which releases are cut. Discover its
  name from the project's branch model. It is conventionally
  `[<pipeline>/]ready`, eg. `latest/ready`.

- **Changelog location — OPTIONAL.** Resolve it from the session context, then
  from the local environment. Look for a convention file or a workspace manifest
  — not not assume a `CHANGELOG.md` file at the repository root. Skip changelog
  promotion where the project keeps no changelog.

## Success criteria

- The release branch MUST have been created or advanced from the tip of the
  release-ready trunk.

- Where the project keeps a changelog, its "unreleased" section MUST have been
  promoted to the released version and date, in a release commit on the
  release branch.

- An annotated version tag MUST mark the tip of the release branch. Check with
  `git describe --exact-match`.

- The software's own source code and configuration MUST be unchanged. The
  release commit SHOULD touch only the changelog, version manifests, and
  release-specific configuration.

## Instructions

1.  Cut or advance the release branch from the release-ready trunk. For a
    release trunk, fast-forward it to the current tip of the release-ready
    trunk. For a versioned release branch:

    ```sh
    git switch --create latest/release/<version> latest/ready
    ```

2.  If the project keeps a changelog, promote the changelog's "unreleased"
    section to a "released" one. Rename the unreleased section's heading to
    the version and date being released, eg. `## [1.2.0] - 2026-05-27`. Start a
    fresh, empty "unreleased" section above it, ready to record changes in the
    next release after this one. Match the heading styles to the existing
    formatting. Leave the existing changelog entries as they stand.

3.  Commit these changes, with any version-manifest bump, as a single release
    commit on the release branch. Stage only the changelog, version manifests,
    and release-specific configuration, by path.

    Write the message header as a `version` commit, giving the bare version
    number as the description, with no `v` prefix. Example:

    ```sh
    git commit -m "version: 1.2.0"
    ```

    The `version` commit type marks that a version has been cut, not that it
    has been deployed.

4.  Tag the tip of the release branch with an annotated tag.

    ```sh
    git tag -a v<version> -m "<summary of the release>"
    ```

    Where the project signs its commits, sign the tag too, using `-s` in place
    of `-a`. Read `git config --get commit.gpgSign` and
    `git config --get tag.gpgSign`, and treat either one set to `true` as
    signing being in use. Check the signature with `git tag -v v<version>`.

5.  Push the version commit and release tag upstream: `git push --follow-tags`.

6.  Report the release branch, the release commit, and the tag.

## Rules

- You MUST NOT add, reword, reorder, regroup, or remove changelog entries when
  promoting the "unreleased" section. The "unreleased" section is written and
  reviewed before the release is cut.

- Releases MUST be cut from the release-ready trunk, and MUST NOT be cut from an
  integration or test trunk. Only the release-ready trunk is guaranteed to hold
  production-grade revisions.

- The release trunk or branch MUST carry the same pipeline prefix as the
  release-ready trunk it is cut from, eg. `v2/release/2.3.1` from `v2/ready`.
  You MUST NOT cut a release for one pipeline from another pipeline's trunk.

- A release MUST be recorded in exactly one release commit, with a `version`
  type subject line.

- A release branch MUST carry only release-preparation commits: version bumps,
  changelog promotion, and release-specific configuration.

- You MUST NOT commit a fix to a release branch. Fixes flow through the
  integration trunk and out to the release-ready trunk, so a fix made under
  release pressure is never stranded off the mainline.

- If release preparation fails, you SHOULD abandon the branch and start over,
  rather than repairing it in place, so the branch's history stays a clean
  record of one release attempt.

- Version tags MUST be treated as permanent. You MUST NOT move or delete an
  existing tag.

## Edge cases

- If the version is not yet decided, then you MAY cut the branch as
  `[<pipeline>/]release/next`, eg. `latest/release/next`, and rename it once
  the version is settled. Do not apply a version tag until the version is known.

- If the tip of the release-ready trunk already carries a release tag, then
  there is nothing new to release. Stop and report the existing tag rather than
  cutting an empty release.

- If the changelog's "unreleased" section is missing or empty, though the
  release-ready trunk carries commits since the last release tag, then do not
  write the missing entries yourself. Stop and report it, so the caller
  can bring the changelog up-to-date before the release is cut.

- If the resolved delivery pipeline has no release-ready trunk, eg. the user
  asked for a v2 patch release and there is no `v2/ready`, then do not fall
  back to another pipeline's trunk. Stop and report the missing trunk.

- If the project has no release trunk or release branches yet, then this is the
  first release. Create the branch according to the release model you
  established, cutting from the release-ready trunk as usual.

## Examples

- Release trunk:

  ```sh
  latest/release
  release  # Single unprefixed pipeline.
  ```

- Release branches:

  ```sh
  latest/release/1.2.0
  latest/release/next
  v2/release/2.3.1  # Patch to a maintained older version.
  release/2.0.0     # Single unprefixed pipeline.
  ```

- Version tags:

  ```sh
  v1.2.0
  v2.0.0
  ```
