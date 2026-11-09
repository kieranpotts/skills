---
name: branch
description: >-
  Name and create a Git branch for a piece of work, under a trunk-based model
  of short-lived temporary branches and long-lived epic branches cut from a
  delivery pipeline's development trunk — usually `dev` or `latest/dev`. Use
  this skill when starting a new branch, or when the user says something like
  "create a branch for this work" or "start a branch for issue 42". Do not use
  this skill to commit, merge, or release.
compatibility: >-
  requires Bash (git fetch, git switch, git symbolic-ref, git clone), Read, Glob
license: CC0-1.0
---

# Branch

Name and create a development branch for a new piece of work, following the
conventions described herein. You MUST NOT make any code or configuration
changes to the software itself. You MUST NOT stage, commit, amend, or push
anything.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The target repository — REQUIRED.** If the current working directory sits
  inside a Git repository, that repository is the target. Otherwise discover the
  target from the session context, eg. a path or URL the user has named. If the
  target is a URL that resolves to an upstream Git repository, clone it to a
  temporary local directory. If no target can be found, stop and alert the
  user.

- **Branch description — REQUIRED.** A description of the changeset the branch
  will carry.

- **The delivery pipeline — OPTIONAL.** There may be separate delivery pipelines
  for different major versions of the software that are developed and maintained
  in parallel. If not specified, assume the target is the default delivery
  pipeline, which is either named "latest" or has no name at all.

- **An issue or tracking identifier — OPTIONAL.** This will be prefixed to the
  branch name when known. If not known, omit it.

## Success criteria

- A new branch MUST exist, named in the `[<pipeline>/]temp/[<id>-]<description>`
  or `[<pipeline>/]epic/[<id>-]<description>` form, as described in the below
  rules, eg. `latest/temp/42-fix-auth-timeout`.

- The new branch MUST point at the tip of its delivery pipeline's development
  trunk and carry no unique commits of its own. Verify with
  `git rev-parse <new-branch> [<pipeline>/]dev`, eg.
  `git rev-parse latest/temp/42-fix-auth-timeout latest/dev`.

- Apart from the branch pointer, other artifacts MUST NOT have been changed
  in the repository. There MUST NOT be any new commit objects, merges, pushes,
  or edits to either tracked or untracked source files.

## Instructions

1.  Determine the name of the delivery pipeline, which will become the
    `<pipeline>` value in the branch name. The value MAY be empty.

    - List the development trunks with
      `git fetch origin && git branch --remotes --list 'origin/dev' 'origin/*/dev'`.
      Each trunk's delivery pipeline is the part between `origin/` and `/dev`.
      `origin/latest/dev` gives "latest" as the name of the delivery pipeline,
      `origin/v2.4-LTS/dev` gives "v2.4-LTS", and `origin/dev` gives no named
      delivery pipeline.

    - If the prompt names a major version number that matches the name of a
      delivery pipeline, eg. the prompt is "patch this in v2" and the branch
      `origin/v2/dev` exists, take that as the name of the target delivery
      pipeline. Else, if the checked-out branch is one of the listed trunks,
      take its named delivery pipeline as the target, eg. "latest" if the
      current branch is `latest/dev`. If the checked-out branch isn't one of
      the listed trunks, determine the default branch with
      `git symbolic-ref --short refs/remotes/origin/HEAD`, and use its
      named delivery pipeline as the target.

2.  Classify the work. Is this for a small, discrete change that could be
    implemented in just a few commits? Or is this multi-contributor work
    spanning weeks or months, and that cannot be continuously integrated into
    the trunk and toggled off using a branch-by-abstraction technique?

3.  Determine the branch type. For small, discrete changes, choose a short-lived
    "temp" branch, following the `[<pipeline>/]temp/[<id>-]<description>`
    naming convention. For longer tasks, choose an "epic" branch, named
    `[<pipeline>/]epic/[<id>-]<description>`.

4.  Form the `<description>` part of the branch name. Follow the rules below.
    Condense it to its few most distinctive words, eg. "fix the timeout in the
    auth flow" becomes `fix-auth-timeout`.

5.  Optionally, if specified by the user, add the issue number or tracking
    identifier to the `<id>` component of the branch name, eg.
    `temp/42-fix-auth-timeout`.

6.  Create the branch from the target delivery pipeline's development trunk.
    Fetch first, so the trunk is current, then create the branch from the target
    development branch, and switch to the new branch. Example:
    `git switch --create latest/temp/42-fix-auth latest/dev`.

7.  Report the branch name and its base.

## Rules

- You MUST NOT do anything else except create a new branch. Staging, committing,
   merging, cutting releases, and deleting branches are out-of-scope.

- Branch names MUST take one of two forms, where square brackets denote an
  optional part.

  ```sh
  [<pipeline>/]temp/[<id>-]<description>
  [<pipeline>/]epic/[<id>-]<description>
  ```

- You MUST cut `[<pipeline>/]temp/*` and `[<pipeline>/]epic/*` branches from
  their delivery pipeline's development trunk, which is named `[<pipeline>/]dev`.

- A branch MUST carry the same pipeline prefix as the development trunk it is
  cut from. `latest/temp/*` branches are cut from `latest/dev`, `v2/temp/*`
  from `v2/dev`, and unprefixed `temp/*` branches are cut from an unprefixed
  `dev` development trunk. The prefix informs where a branch was cut from and
  where it will be integrated back into.

- The pipeline prefix MUST be copied verbatim from the existing trunk name, eg.
  `v2.4-LTS`. Do not normalize it, and never invent one.

- The `<description>` MUST be lowercase and hyphen-delimited (kebab-case), with
  no underscores, spaces, or other punctuation. It SHOULD NOT exceed 50
  characters, and MUST NOT exceed 72.

- The `<id>` MUST match the actual identifier exactly, as the tracker displays
  it. Do not change its case or punctuation, eg. `PRD-504` MUST NOT be changed
  to `prd-504` or `prd504`.

- You MUST NOT create a new trunk or delivery pipeline.

## Edge cases

- If the resolved pipeline has no development trunk, eg. the repository has
  neither `dev` nor `latest/dev`, or the user named "v2" but there is no
  `v2/dev`, report the missing trunk and stop. Do not make assumptions about
  the target development trunk from which to cut a new branch. Proceed only
  if the target is clear.

- If the named delivery pipeline matches more than one development trunk, eg.
  the used asked for "v2" and the repository has both `v2.3/dev` and
  `v2.4-LTS/dev` branches, do not guess between them. Instead, report the
  candidate trunks and stop.

- If the default branch is not a development trunk, eg. it is `main`, stop
  and report the problem.

- If a branch already exists at the chosen name, do not reuse or reset it.
  Instead, try to choose a more specific description, or stop and report the
  clash.

## Examples

- Valid names for temporary branches:

  ```sh
  latest/temp/42-add-search-endpoint
  latest/temp/178-fix-auth-timeout
  v2/temp/TS-504-migrate-user-schema
  temp/update-dependencies
  ```

- Valid names for epic branches:

  ```sh
  latest/epic/billing-v2-rewrite
  latest/epic/PRD-187-auth-overhaul
  next/epic/infra-migrate-kubernetes
  epic/major-ui-redesign
  ```
