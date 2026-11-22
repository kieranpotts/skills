---
name: branch
description: >-
  Name and create a Git branch for a piece of work, cut from the tip of the
  development trunk of its delivery pipeline and checked out in a worktree of
  its own, under the trunk-based model of short-lived temp branches and
  long-lived epic branches. Use when starting a new branch, or when the user
  says something like "create a branch for this work" or "start a branch for
  issue 42". Do not use it to commit, merge, or release.
compatibility: >-
  requires Bash (git status, git rev-parse, git worktree, git fetch, git merge)
license: CC0-1.0
---

# Branch

Name and create a branch for a new piece of work, cut from the tip of the
current delivery pipeline's development trunk, and check it out in a new
worktree. Do not change any file, and do not commit or push anything.

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
  Take it from the session context where it names one, eg. "branch from v1".
  Otherwise determine it from the branch checked out in the current worktree.
  Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  Where the current worktree's `HEAD` is detached, use the pipeline of the
  branch checked out in the `default` worktree.

  The name of the delivery pipeline, if any, forms the optional
  `[<pipeline>/]` component in branch names.

- **Branch description — REQUIRED.** A description of the changeset the branch
  will carry.

- **Branch type — OPTIONAL.** You will create a short-lived "temp" branch,
  unless the user explicitly asks for an "epic" branch that is long-lived
  and/or has multiple collaborators.

- **Tracking identifier — OPTIONAL.** An issue number or other identifier.
  If specified, you will include this is the branch name.

## Success criteria

- A new branch MUST exist, named `[<pipeline>/]<type>/[<id>-]<description>`,
  eg. `latest/temp/42-fix-auth-timeout`.

- The new branch MUST be checked out in a new, clean worktree in `<project>`,
  named after the branch with each `/` replaced by `-`, eg.
  `<project>/latest-temp-42-fix-auth-timeout`.

- The new branch MUST point at the tip of the development trunk, with no
  commits of its own. `git rev-parse <new-branch> [<pipeline>/]dev` MUST print
  the same hash twice, and where `origin` exists, so MUST
  `git rev-parse [<pipeline>/]dev origin/[<pipeline>/]dev`.

- There MUST NOT be any new commits, merges, or pushes. No worktree other than
  the new one MUST change, except by the trunk's fast-forward.

- Your report MUST open with the new branch name on the first line, so an
  orchestrating script can read it. The second line MUST give the path of the
  new worktree. This MUST be followed by the commit hash that the branch
  starts from.

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

2.  Update the remote-tracking branches and tags with `git fetch origin --tags`.
    If the repository has no `origin` remote, skip the fetch, work from local
    refs, and say so in your report.

3.  Bring the local development trunk up to date. Find whether a worktree has
    it checked out: in `git worktree list --porcelain`, that is the
    `worktree <path>` record with the line
    `branch refs/heads/[<pipeline>/]dev`.

    - Where one does, stop and report unless that worktree is clean. Then
      fast-forward the trunk there, with
      `git -C <path> merge --ff-only origin/[<pipeline>/]dev`.

    - Where none does, fast-forward it with
      `git fetch origin [<pipeline>/]dev:[<pipeline>/]dev`.

    Both commands refuse every type of integration except a clean
    fast-forward. If the local branch has diverged from origin, stop and
    report.

4.  Compose the new branch name from the form `[<pipeline>/]<type>/[<id>-]<description>`.
    Condense the description to its few most distinctive words, eg. "fix the
    timeout in the auth flow" becomes `fix-auth-timeout`, and prefix the
    tracking identifier where there is one, eg. `42-fix-auth-timeout`.

5.  Check that the name is free, ie. that both
    `git rev-parse -q --verify refs/heads/[<pipeline>/]<type>/[<id>-]<description>` and
    `git rev-parse -q --verify refs/remotes/origin/[<pipeline>/]<type>/[<id>-]<description>` fail,
    and that nothing exists yet at the new worktree's path in `<project>`.

6.  Create the branch from the development trunk, checked out in a new
    worktree. Example:

    ```sh
    git worktree add -b latest/temp/42-fix-auth-timeout \
      <project>/latest-temp-42-fix-auth-timeout latest/dev
    ```

7.  Report.

## Rules

- You MUST cut the branch from the development trunk of the delivery
  pipeline. Thus, if the current worktree has `v1/temp/42-fix-auth-timeout`
  checked out, and the session context names no other pipeline, then the
  delivery pipeline is "v1" and its development trunk is `v1/dev`. You will
  cut the new branch from `v1/dev`, and the new branch will take `v1/` for the
  `<pipeline>/` component of its name. This component records where a branch
  was cut from, and where it integrates back.

- You MUST copy the delivery pipeline prefix verbatim, eg. `v2.4-LTS`. Do not
  normalize it, and never invent one.

- The `<description>` component MUST use lowercase letters, digits, and hyphens
  only. It SHOULD NOT exceed 50 characters, and MUST NOT exceed 72.

- The `<id>` component is optional, but if included it MUST match the identifier
  exactly as specified by the user, including its letter case, eg. `PRD-504`.

- You MUST NOT create a trunk or a delivery pipeline.

- You MUST NOT switch the branch checked out in any worktree, and you MUST move
  the trunk in its worktree only where you found that worktree clean: where
  `git -C <path> status --porcelain` printed nothing,
  `git -C <path> rev-parse -q --verify MERGE_HEAD` failed, and no file existed
  at `git -C <path> rev-parse --path-format=absolute --git-path SQUASH_MSG`.
  Each worktree belongs to whoever works in it, and a fast-forward under
  someone's uncommitted changes can tangle with their work in progress.

## Edge cases

- If the pipeline has no development trunk, eg. the checked-out branch is
  `v2/temp/fix-auth-timeout` but there is no `v2/dev`, then stop and report the
  missing trunk.

- If the chosen branch name is taken, then choose a more specific description.
  Never reuse or reset an existing branch.

- If `git worktree add` refuses, eg. because the directory already exists,
  then stop and report its output. Do not remove, move, or prune any worktree.

## Examples

- Temp branches:

  ```text
  latest/temp/42-add-search-endpoint
  v2/temp/TS-504-migrate-user-schema
  temp/update-dependencies
  ```

- Epic branches:

  ```text
  latest/epic/billing-v2-rewrite
  v1/epic/PRD-187-auth-overhaul
  epic/major-ui-redesign
  ```

- A report:

  ```text
  latest/temp/42-fix-auth-timeout
  /home/me/dev/acme/latest-temp-42-fix-auth-timeout
  Cut from latest/dev at 3f9c2ab.
  ```
