---
name: branch
description: >-
  Names, validates, and creates Git branches under a trunk-based model of
  fast-forwarded trunks, short-lived temporary branches, and long-lived epic
  branches. Use when starting a branch, naming a feature or fix branch, or
  checking branch names before a push, or when the user says "what should I
  call this branch?", "create a branch for this work", or "is this branch
  name valid?". Do not use it to commit, merge, delete, or release branches.
compatibility: >-
  requires Bash (git switch, git branch, git clone), Read, Glob
license: CC0-1.0
---

# Branch

Create a development branch in one or more Git repositories, or validate
branch names, following the conventions described herein. You MUST NOT make
any code or configuration change to the software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where a repository lives or
how to access it, when context and environment do not settle it.

- **The target repository — REQUIRED.** Look in the user's last prompt for an
  explicit path or URL. Clone a URL to a temporary directory. Otherwise take
  the repository containing the current working directory; if the working
  directory sits outside a repository, check the nearest convention file, eg.
  an `AGENTS.md`. If no target can be found, stop and alert the user.

- **The work to be branched, or names to validate — REQUIRED.** Either a
  description of the change the branch will carry, or one or more existing
  branch names to check.

- **An issue or tracking identifier — OPTIONAL.** Prefixed to the branch
  description when known. Omit it rather than inventing one.

This task runs non-interactively to completion. It does not block for user
input.

## Success criteria

- Either a branch MUST exist at the chosen name, or a pass/fail verdict MUST
  have been reported for every name supplied for checking, naming the
  specific rule each failure violates.

- Every name MUST match the validation regex given in the rules below. This
  is the deterministic check; run the name through it rather than eyeballing
  it.

- A `temp/*` or `epic/*` name MUST be within the length budget: 50 characters
  RECOMMENDED, 72 maximum.

- The branch type SHOULD fit the shape of the work, so the reintegration
  strategy it implies is the right one: `temp/*` for a single-focus change of
  a few commits, `epic/*` for long-lived multi-contributor work that cannot
  be continuously integrated, and no branch at all for a change of one or two
  commits.

- A newly created `temp/*` or `epic/*` branch MUST point at the tip of `dev`.
  Verify with `git merge-base --is-ancestor dev <branch>` and by confirming
  the branch carries no commits of its own yet.

- Nothing beyond the new branch pointer MUST have changed: no commits, no
  merges, no deletions, no pushes, and no edits to tracked files.

## Instructions

1.  Classify the work.

    Decide whether the change belongs on a trunk (`dev`, `test`, `ready`), a
    short-lived `temp/*` branch, a long-lived `epic/*` branch, or directly on
    `dev` for a one- or two-commit change. Prefer the smallest option that
    fits; every branch is integration debt until it lands.

2.  Form the branch name.

    Trunk names are fixed. For `temp/*` or `epic/*`, optionally prefix an
    issue or tracking identifier, then append a lowercase, hyphen-delimited
    description of the work, keeping the whole name within budget.

    Lowercase the identifier too, even where the tracker displays it
    uppercase (`TS-504` becomes `ts-504`). The regex admits no exception for
    it, and Git branch names carry the same case-sensitivity hazards as any
    other path component.

3.  Validate the name against the regex.

    If it fails, rewrite and re-test until it passes. When the task was to
    check supplied names, report the specific rule each failing name violates
    rather than silently correcting it.

4.  Choose the base branch.

    Cut `temp/*` and `epic/*` branches from `dev` only. Fetch first so `dev`
    is current, then create the branch, eg.
    `git switch --create temp/42-fix-auth dev`.

5.  Report what was done.

    State the branch name, its base, and — for a validation request — the
    verdict on each name.

## Rules

- You MUST name, validate, and create branches, and stop there.

  Committing, merging, cutting releases, and deleting integrated branches
  are separate responsibilities, even when the same conventions govern them.

- Every branch MUST be one of three forms: a permanent trunk (`dev`, `test`,
  `ready`), a short-lived `temp/[<id>-]<description>`, or a long-lived
  `epic/[<id>-]<description>`.

  All three validate against a single regex:

  ```sh
  ^(dev|test|ready|temp/[a-z0-9]+(-[a-z0-9]+)*|epic/[a-z0-9]+(-[a-z0-9]+)*)$
  ```

- Branch names MUST be lowercase and hyphen-delimited (kebab-case), and MUST
  NOT contain underscores or spaces. They SHOULD NOT exceed 50 characters,
  and MUST NOT exceed 72.

- Trunks are permanent, append-only, and fixed-forward.

  - `dev` is the primary integration trunk, where all work originates. It is
    the only REQUIRED branch, and SHOULD be the repository's default branch.

  - `test` is an OPTIONAL QA trunk, fast-forwarded to stable commits on `dev`
    to trigger integration, system, and performance testing.

  - `ready` is an OPTIONAL production-grade trunk, fast-forwarded to passing
    commits on `test`. It MUST remain shippable at all times, so that
    continuous delivery stays possible.

- Temporary branches MUST be short-lived and single-focus.

  They carry one logical change over a small number of commits, commonly
  tied to an issue. Orthogonal changes SHOULD NOT be combined into one
  `temp/*` branch. They MUST be cut from `dev`, kept in sync by rebasing up
  onto `dev` so their unique commits stay at the tip, reintegrated by
  fast-forward merge, and deleted afterwards — the history survives in `dev`.

- Epic branches MUST be reserved for long-lived, coordinated work.

  Valid cases: features spanning weeks or months that cannot be continuously
  integrated or toggled off; major refactoring and replatforming; cross-
  cutting concerns; long-running research; other highly disruptive or
  volatile changes.

  They MUST be cut from `dev` and synchronized by merging `dev` down into the
  epic, never by rebasing, because rewriting shared history breaks other
  contributors. They MUST be reintegrated by squash merge, so one fresh
  commit hits the trunk, then deleted; a fresh epic MAY be cut if more
  long-running work follows.

- All changes MUST flow forward through the trunks.

  Work originates on `dev` and flows through `test` → `ready` → release. A
  problem found downstream MUST be fixed on `dev` and flow forward from
  there; a fix MUST NOT be committed directly to a downstream trunk, where
  it would be lost at the next fast-forward.

## Edge cases

- The repository has no `dev` branch.

  Do not cut a `temp/*` or `epic/*` branch from whatever trunk happens to
  exist. Report that the model's required trunk is missing and stop, so the
  user can decide whether to establish `dev` or work outside this model.

- A `temp/*` or `epic/*` branch has no commits for roughly 90 days.

  Flag it as stale when it surfaces during naming or validation. Such
  branches SHOULD be reviewed and either revived or deleted, but deletion is
  outside this skill's remit.

## Examples

- Trunk branches:

  ```sh
  dev
  test
  ready
  ```

- Temporary branches:

  ```sh
  temp/42-add-search-endpoint
  temp/178-fix-auth-timeout
  temp/ts-504-migrate-user-schema
  temp/update-dependencies
  ```

- Epic branches:

  ```sh
  epic/billing-v2-rewrite
  epic/product-187-auth-overhaul
  epic/infra-migrate-kubernetes
  epic/major-ui-redesign
  ```
