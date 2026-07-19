---
name: branch
description: >-
  Git branching strategy. Use when creating a new branch, naming a feature or
  fix branch, or validating branch names before push, or when the user says
  something like "what should I call this branch?", "create a branch for this
  work", or "is this branch name valid?".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Branch

Create a new development branch in one or more Git repositories, or validate a
branch name, following the conventions described herein.

You MUST NOT make any code or configuration changes to the software itself.

**Input:** Determine the following information from the surrounding context
and environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

- The target codebase — REQUIRED.
  Look in the user's last input prompt for an explicit reference to a target
  path or URL to a code repository. If a URL, clone the repository to a
  temporary directory. Otherwise, assume the target is the code repository
  under which the current working directory (cwd) sits. If the cwd is not part
  of a code repository, check the nearest `AGENTS.md`. If the target codebase
  cannot be found, stop and alert the user.

- Branch name or description — OPTIONAL.
  If not specified by the user, you will generate a random branch name.
  Instructions are below.

**Output:** A correctly-named branch created from the right base, or a pass/fail
verdict on the supplied names with the specific rule each one violates. This
skill names and validates branches and stops; it does not merge, cut releases,
or author commit messages.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Classify the work.**

    You MUST decide whether the change belongs on a trunk branch (`dev`, `test`,
    or `ready`), a short-lived `temp/*` branch, a long-lived `epic/*` branch, or
    directly on `dev` (for a one- or two-commit change).

2.  **Form the branch name.**

    For trunk branches, the name is fixed (`dev`, `test`, or `ready`).

    For `temp/*` or `epic/*` branches, you MUST build the name from the work:

    - You MAY prefix with an issue or tracking ID.
    - You MUST append a lowercase, hyphen-delimited description of the work.
    - You MUST keep the total length within the budget.

3.  **Validate the name against the regex.**

    You MUST test the name against `^(dev|test|ready|temp/[a-z0-9]+(-[a-z0-9]+)*|epic/[a-z0-9]+(-[a-z0-9]+)*)$`.
    If it fails, you MUST rewrite the name and re-test until it passes, or report
    the specific rule that was violated.

4.  **Choose the correct base branch.**

    For `temp/*` and `epic/*` branches, you MUST base the branch on `dev`. You
    MUST NOT base them on `test`, `ready`, or a release branch.

5.  **Create or report.**

    If the request is to create a branch, you MUST create it from the chosen
    base. If the request is to validate, you MUST report a pass/fail verdict for
    each supplied name, naming the rule each failure violates.

## Rules

- **Allowed branches are limited to the trunk, temporary, and epic forms.**

  *Permanent trunks:*

  ```
  dev
  test
  ready
  ```

  *Short-lived temporary branches:*

  ```
  temp/[<id>-]<description>
  ```

  *Long-lived epic branches:*

  ```
  epic/[<id>-]<description>
  ```

  Validation regex (for all branch types):

  ```
  ^(dev|test|ready|temp/[a-z0-9]+(-[a-z0-9]+)*|epic/[a-z0-9]+(-[a-z0-9]+)*)$
  ```

- **Branch names MUST be lowercase and hyphen-delimited.**

  - Branch names MUST be full lowercase.

  - `temp/*` and `epic/*` branch names MUST use hyphen-delimited descriptions
    (kebab-case).

  - Branch names MUST NOT contain underscores or spaces.

  - The OPTIONAL `<id>` typically corresponds to an issue number or tracking
    system identifier. Include it if known.

  - Temporary and epic branch names SHOULD NOT exceed 50 characters total, and
    MUST NOT exceed 72.

- **Trunk branches are permanent and immutable.**

  Trunks are append-only and fixed-forward. There are up to three:

  - `dev`: The primary integration trunk. All work originates here. This is
    the only REQUIRED branch. Most projects SHOULD use `dev` as their default
    branch.

  - `test`: OPTIONAL QA trunk. Fast-forwarded to stable commits on `dev` to
    trigger comprehensive testing (integration tests, system tests,
    performance tests).

  - `ready`: OPTIONAL production-grade trunk. Fast-forwarded to passing
    commits on `test`. It MUST remain shippable at all times, enabling
    continuous delivery.

- **Temporary branches are short-lived and focused.**

  Temporary branches (`temp/*`) capture single-focused changes spanning a small
  number of commits. Commonly associated with an issue/bug.

  - MUST be cut from `dev`, never from `test`, `ready`, or release branches.

  - One logical change per temporary branch. Multiple orthogonal changes
    SHOULD NOT be combined into a single temporary branch.

  - MUST use the rebase-up strategy to keep synchronized with `dev`, so the
    unique commits of temporary branches stay at the tip.

  - MUST be reintegrated with `dev` using fast-forward merge.

  - MUST be deleted after integration; the commit history is preserved in
    `dev`.

- **Epic branches are long-lived and coordinated.**

  Epic branches (`epic/*`) are for multi-developer coordination on complex
  changes.

  - MUST be cut from `dev`, like temporary branches.

  - Valid use cases: large coordinated features spanning weeks/months, and
    which can't easily be continuously integrated into the `dev` trunk or
    toggled off; major refactoring and replatforming initiatives;
    cross-cutting concerns; long-running research work; other highly
    disruptive or volatile changes.

  - MUST use the merge-down strategy: synchronize by merging `dev` into the
    epic branch (never rebase). This is safer for long-lived branches with
    multiple contributors since it preserves the history of the branch.

  - MUST be reintegrated with `dev` using the squash-merge strategy. One fresh
    commit hits the trunk.

  - MUST be deleted after integration into `dev`. A fresh epic branch MAY be
    recreated if further long-running development work is required.

- **All changes MUST flow forward through the trunks.**

  Work MUST originate on `dev` and flow forward through `test` → `ready` →
  release. Trunk branches are fixed-forward only. If a problem is discovered
  downstream, the fix MUST be committed to `dev` and flow forward from there
  — no direct commits to downstream trunks.

  Stale `temp/*` and `epic/*` branches with no commits in ~90 days SHOULD be
  reviewed periodically and either deleted or revived.

## Success criteria

- **The branch name MUST validate against the model.**

  It MUST match
  `^(dev|test|ready|temp/[a-z0-9]+(-[a-z0-9]+)*|epic/[a-z0-9]+(-[a-z0-9]+)*)$`
  — one of the three trunks, or a `temp/` or `epic/` branch with a kebab-case
  description.

- **The name MUST be well-formed.**

  It MUST be full lowercase, hyphen-delimited, with no underscores or spaces,
  and within the length budget (≤50 characters RECOMMENDED, ≤72 MUST) for
  `temp/*` and `epic/*` branches.

- **The branch type MUST fit the work.**

  `temp/*` MUST be used for a short, single-focus change; `epic/*` for
  long-lived, multi-contributor work that cannot be continuously integrated. A
  change of one or two commits needs no branch beyond `dev`.

- **`temp/*` and `epic/*` branches MUST be cut from `dev`.**

  They MUST NOT be cut from `test`, `ready`, or a release branch.

- **Changes MUST flow forward only.**

  Work MUST originate on `dev` and flow through `test` → `ready`; a fix MUST
  NOT be committed directly to a downstream trunk.

## Examples

- **Trunk branches:**

  ```
  dev
  test
  ready
  ```

- **Temporary branches:**

  ```
  temp/42-add-search-endpoint
  temp/178-fix-auth-timeout
  temp/TS-504-migrate-user-schema
  temp/update-dependencies
  ```

- **Epic branches:**

  ```
  epic/billing-v2-rewrite
  epic/PRODUCT-187-auth-overhaul
  epic/infra-migrate-kubernetes
  epic/major-ui-redesign
  ```
