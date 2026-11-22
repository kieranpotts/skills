---
name: release
description: >-
  Cut a software release by tagging the delivery pipeline's version commit,
  fast-forwarding the release-ready trunk to the new tag, and fast-forwarding
  the release trunk to match, each in its own worktree. Use when a version
  commit has passed through the pipeline and is ready to ship, or when the user
  says something like "cut a release", "release 1.2.0", or "tag version
  1.2.0". Do not use it to decide the version number, to edit the changelog,
  to push, or to build, publish, or deploy artifacts.
compatibility: >-
  requires Bash (git status, git rev-parse, git worktree, git fetch, git log,
  git merge-base, git config, git tag, git merge)
license: CC0-1.0
---

# Release

Release a version by tagging its version commit, then fast-forward
`[<pipeline>/]ready` to the tag and `[<pipeline>/]release` to `ready`, each in
its own worktree, so all three mark the same commit. Make no commits, and push
nothing.

## Parameters

Determine the following information from the session context, the current
working directory, and the local environment. You MUST NOT prompt the user for
clarification on this task's requirements. If you cannot determine the
requirements, stop and report.

Assume every Git repository is laid out as a bare clone in a `.bare` directory,
with each of its worktrees checked out in a directory beside it, eg.
`<project>/.bare` and `<project>/default`. The `default` worktree has the
repository's default branch checked out. If the current working directory sits
inside a worktree, that is the target worktree, the one to work in. Otherwise
take the target worktree from the session context, eg. a path the user has
named. Wherever a repository is identified but none of its worktrees is, use its
`default` worktree.

- **The current worktree — REQUIRED.** The target worktree, as resolved above.
  If there is no target worktree, or its repository is not laid out as above,
  stop and report.

- **The delivery pipeline — OPTIONAL.** This is usually a major version number
  like "v1" or "v2", or the word "latest". It may be unnamed for
  continuously-released software that has a single perpetual delivery pipeline.
  Take it from the session context where it names one, eg. "release 1.2.0 on
  v1". Otherwise determine it from the branch checked out in the current
  worktree. Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  Where the current worktree's `HEAD` is detached, use the pipeline of the
  branch checked out in the `default` worktree.

  The name of the delivery pipeline, if any, forms the optional
  `[<pipeline>/]` component in branch names.

- **The version — REQUIRED.** The semantic version being released, from the
  prompt or the session context, eg. `1.2.0` or `1.3.0-rc.0`. Drop any leading
  `v`. Never derive it yourself: if no version is given, stop and report.

- **The source trunk — REQUIRED.** The trunk that feeds `[<pipeline>/]ready`:
  `[<pipeline>/]test` where it exists, or else `[<pipeline>/]dev`.

## Success criteria

- An annotated tag `v<version>` MUST exist, on the commit whose subject is
  `version: <version>`: `git cat-file -t v<version>` MUST print `tag`, and
  `git log -1 --format=%s v<version>` MUST print `version: <version>`.

- `git rev-parse v<version>^{commit} [<pipeline>/]ready [<pipeline>/]release`
  MUST print the same hash three times, except for a pre-release.

- There MUST NOT be any new commits, and nothing MUST have been pushed. The
  branch checked out in each worktree MUST NOT change, and the worktrees of
  `[<pipeline>/]ready` and `[<pipeline>/]release` MUST be clean:
  `git -C <path> status --porcelain` MUST print nothing for each.

- Your report MUST open with the tag on a line of its own, eg. `v1.2.0`, so a
  script can read it, followed by the tagged commit, the worktrees you moved
  or created, and the refs still to push.

## Step-by-step instructions

1.  Run every Git command in the current worktree, unless a step names
    another. Where the working directory lies elsewhere, pass
    `-C <current-worktree>`, because a change of directory may not persist
    between commands.

    Check the repository layout before anything else. Stop and report unless
    `git rev-parse --path-format=absolute --git-common-dir` prints a path
    ending in `/.bare`, and the current worktree's top level, from
    `git rev-parse --show-toplevel`, sits directly in the directory that holds
    `.bare`. Call that directory `<project>`.

    The current worktree may be dirty. Nothing you do touches it.

2.  Update the remote-tracking branches and tags with
    `git fetch origin --tags`. If the repository has no `origin` remote, skip
    the fetch, work from local refs, and say so in the report.

3.  Unless the version is a pre-release, resolve the worktrees of
    `[<pipeline>/]ready` and, where the branch exists, `[<pipeline>/]release`.
    In `git worktree list --porcelain`, a branch's worktree is the
    `worktree <path>` record with the line `branch refs/heads/<branch>`. Where
    no worktree has the branch checked out, create one in `<project>`, named
    after the branch with each `/` replaced by `-`:

    ```sh
    git worktree add <project>/latest-ready latest/ready
    ```

    Stop and report unless each worktree is clean. Where
    `[<pipeline>/]release` does not exist yet, check that nothing exists at
    `<project>/latest-release`, for its worktree in step 8.

4.  Bring the local source trunk, `[<pipeline>/]ready`, and
    `[<pipeline>/]release` up to date. Where a worktree has the branch checked
    out, stop and report unless that worktree is clean, then fast-forward the
    branch there, with `git -C <path> merge --ff-only origin/<branch>`. Where
    none does, use `git fetch origin <branch>:<branch>`. Both refuse anything
    but a fast-forward. If the local branch has diverged from origin, stop and
    report.

5.  Find the version commit on the source trunk. List the candidates, and keep
    only those whose subject is exactly `version: <version>`:

    ```sh
    git log --format='%H %s' -F --grep='version: <version>' latest/test
    ```

    Stop and report unless exactly one commit remains.

6.  Validate the release before moving any ref. Stop and report unless every
    one of these holds:

    - `[<pipeline>/]ready` is at or behind the version commit:
      `git merge-base --is-ancestor latest/ready <commit>`.

    - `[<pipeline>/]release`, where it exists, is at or behind the version
      commit: `git merge-base --is-ancestor latest/release <commit>`.

    - The tag `v<version>` does not exist, or already points at the version
      commit, as when resuming an interrupted release.

7.  Tag the version commit, unless the tag already points at it:

    ```sh
    git tag -a v1.2.0 -m "Release 1.2.0" <commit>
    ```

    Where `git config --get tag.gpgSign` or `git config --get commit.gpgSign`
    prints `true`, sign the tag with `-s` in place of `-a`.

8.  Fast-forward `[<pipeline>/]ready` to the tag, then `[<pipeline>/]release` to
    `[<pipeline>/]ready`, each in its worktree. Where the pipeline has no
    release trunk yet, this is its first release: create the trunk at
    `[<pipeline>/]ready`, checked out in a new worktree.

    ```sh
    git -C <ready-worktree> merge --ff-only v1.2.0
    git -C <release-worktree> merge --ff-only latest/ready
    # or, for a first release:
    git worktree add -b latest/release <project>/latest-release latest/ready
    ```

9.  Report. Name the refs to push, eg.
    `git push origin v1.2.0 latest/ready latest/release`, without running the
    push.

## Rules

- You MUST only fast-forward `[<pipeline>/]ready` and `[<pipeline>/]release`,
  never merge, reset, or force them. Every trunk shares one linear history,
  and fixes flow forward from `dev`, never backward.

- You MUST NOT fast-forward `[<pipeline>/]ready` past the version commit. The
  commits after it on the source trunk belong to a later release.

- You MUST treat tags as permanent. Never move, delete, or recreate an existing
  tag.

- You MUST NOT switch the branch checked out in any worktree, and you MUST move
  a branch in its worktree only where you found that worktree clean: where
  `git -C <path> status --porcelain` printed nothing,
  `git -C <path> rev-parse -q --verify MERGE_HEAD` failed, and no file existed
  at `git -C <path> rev-parse --path-format=absolute --git-path SQUASH_MSG`.
  Each worktree belongs to whoever works in it, and a fast-forward under
  someone's uncommitted changes can tangle with their work in progress.

- You MUST NOT push. Publishing the tag and trunks, which typically triggers
  deployment, is the caller's decision.

## Edge cases

- If no version commit matches on the source trunk, then it has not been
  promoted that far yet, or was never made. Stop and report.

- If `[<pipeline>/]ready` has already moved past the version commit, then the
  release trunk could no longer match the tag. Stop and report.

- If the pipeline has no `[<pipeline>/]ready` trunk, then stop and report.
  Releases are cut only from a trunk guaranteed to hold production-grade
  revisions.

- If the version is not of the form `<major>.<minor>.<patch>`, with an OPTIONAL
  `-<stage>.<n>` pre-release suffix, then stop and report. Release tags are
  `v` followed by a semantic version.

- If the version is a pre-release, eg. `1.3.0-rc.0`, then tag the version
  commit, but leave `[<pipeline>/]ready` and `[<pipeline>/]release` where they
  are. A pre-release is for testing, not for production.

- If `git worktree add` refuses, eg. because the directory already exists, or
  a stale worktree record still claims the branch, then stop and report its
  output. Do not remove, move, or prune any worktree.

## Examples

- Releasing `1.2.0` on the "latest" pipeline, where `latest/test` holds the
  `version: 1.2.0` commit at `4b1e9d0`:

  ```text
  v1.2.0
  Tagged 4b1e9d0 (version: 1.2.0).
  latest/ready and latest/release now point at 4b1e9d0, in the worktrees
  <project>/latest-ready and <project>/latest-release.
  To publish: git push origin v1.2.0 latest/ready latest/release
  ```
