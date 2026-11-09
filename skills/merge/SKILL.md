---
name: merge
description: >-
  Integrate work from one Git branch into another, using the merge strategy —
  rebase-then-fast-forward, squash merge, merge commit, or fast-forward — that
  the source and target branch types call for. Use this skill when work on one
  branch is ready to be integrated into another, or when the user says
  something like "merge this branch into ...", "integrate this branch back into
  the trunk", or "promote one branch to another". Do not use this skill to
  conclude a merge already in progress, create branches, author ordinary
  commits, or cut releases.
compatibility: >-
  requires Bash (git, project build and test commands), Read, Edit, Glob, Grep
license: CC0-1.0
---

# Merge

Integrate one Git branch into another using the merge strategy appropriate to
their branch types. You MUST NOT change the software itself, resolve merge
conflicts, or conclude a merge already in progress. Where Git cannot complete a
merge by itself, abort and alert the user. Do not run the build or tests to
verify the merge, and do not push any new commits that capture the integration.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The source branch — REQUIRED.** The branch carrying the work to be
  integrated.

- **The target branch — REQUIRED.** The branch the work lands on. Never infer it
  — a repository may have several trunks, any one of which could be the
  integration target. The user MUST specify it.

- **The delivery pipeline — REQUIRED.** Extract this from the branch name prefix,
  which is expected to be the same for both the source and target branches.
  For example, in the branch names `latest/temp/482-idempotency` (source) and
  `latest/dev` (target), the delivery pipeline is named "latest". A project that
  runs a single unprefixed delivery pipeline (a bare `dev` trunk) has no prefix.

## Success criteria

- The target branch MUST carry the source's work.

- Where the source is a short-lived "temp" branch, the target branch MUST have
  a clean, linear extension to its commit history. It MAY inherit multiple
  commits from the source branch. Where the source branch is a long-lived "epic"
  branch, the target branch MUST have a single new commit, capturing a squashed
  diff of all the unique commits on the source branch. Check with
  `git log --oneline --graph -10`.

- Merge conflicts MUST NOT be resolved by the agent. Where Git stops on a
  conflict, the rebase or merge MUST be aborted and the conflicted paths
  reported to the user.

- A merge MUST NOT remain in progress. `git rev-parse -q --verify MERGE_HEAD`
  MUST fail, and the `SQUASH_MSG` file MUST NOT exist. There MUST NOT be any
  conflict markers in the source code. The command
  `git grep -nE '^(<<<<<<<|=======|>>>>>>>)'`, run on the merged tree,
  MUST return nothing.

- The source branch MUST endure. No branches should have been deleted.

## Instructions

1.  State the source and target branches. Check first whether a merge is already
    in progress. `git rev-parse -q --verify MERGE_HEAD` succeeds during a merge,
    and the file at `git rev-parse --git-path SQUASH_MSG` exists during a squash
    merge. Check both, because `git status` does not report a pending squash
    merge. If either holds, stop and alert the user, leaving the merge exactly
    as you found it. Otherwise, confirm both the source and target branches
    exist are are current with their remotes, and confirm there are no dirty
    working changes — `git status` MUST be clean before proceeding.

2.  Classify the branch pair and choose the integration strategy.

    | Source → Target                                           | Integration strategy | Integration command                                |
    | --------------------------------------------------------- | -------------------- | -------------------------------------------------- |
    | `<pipeline>/temp/*` → `<pipeline>/dev`                    | Rebase up, then FF   | `git rebase <pipeline>/dev && git merge --ff-only` |
    | `<pipeline>/epic/*` → `<pipeline>/dev`                    | Squash merge         | `git merge --squash`                               |
    | `<pipeline>/dev` → `<pipeline>/epic/*`                    | Merge commit (no-FF) | `git merge --no-ff <pipeline>/dev`                 |
    | `<pipeline>/dev` → `<pipeline>/test` → `<pipeline>/ready` | Fast-forward only    | `git merge --ff-only`                              |
    | `<pipeline>/ready` → `<pipeline>/release(/*)`             | Fast-forward only    | `git merge --ff-only`                              |

    NOTE: `<pipeline>` stands for the delivery pipeline prefix, and it may be
    empty where the project's trunks are unprefixed.

    If you cannot determine the integration strategy, stop and alert the user.

3.  Align the source branch with the target. For a short-lived "temp" branch,
    rebase it onto the latest target (`git rebase latest/dev`), so the
    fast-forward that follows adds no commit. For a long-lived "epic" branch,
    first merge the target down into it (`git merge --no-ff latest/dev`). For
    a trunk promotion, verify the upstream trunk is a direct descendant of the
    target (`git merge-base --is-ancestor latest/test latest/dev`). If it is
    not, stop and report it.

4.  Execute the merge with the integration command mapped from the table.

    ```sh
    # Short-lived "temp" branch into the trunk, after the rebase-up.
    git switch latest/dev
    git merge --ff-only latest/temp/482-idempotency

    # Long-lived "epic" branch into the trunk, after the merge-down.
    git switch latest/dev
    git merge --squash latest/epic/billing-v2-rewrite
    git commit -m "<type>: <description>" # See commit message rules below.

    # Development trunk into a long-lived "epic" branch.
    git switch latest/epic/billing-v2-rewrite
    git merge --no-ff latest/dev
    git commit -m "merge: capture latest development trunk changes"

    # Trunk forward-promotion.
    git switch latest/test
    git merge --ff-only latest/dev
    ```

5.  Abort on any conflict Git cannot resolve by itself. If a rebase or merge
    causes conflicts, do not attempt to resolve them. Instead, list the
    conflicted paths (`git diff --name-only --diff-filter=U`), then abort,
    leaving both branches as they were. Use `git rebase --abort` to abort a
    rebase, `git merge --abort` to abort a merge, or `git reset --merge` to
    abort a squash merge. Stop, and alert the user with the conflicted paths.

## Rules

- You MUST select the strategy from the branch pair, not from convenience.
  Short-lived "temp" branches are rebased up then fast-forwarded. Long-lived
  "epic" branches are squashed. Trunks are only fast-forwarded.

- You MUST NOT squash a short-lived "temp" branch. Its atomic commits carry
  per-step rollback granularity into the trunk, which squashing discards.

- You MUST resolve divergence between a trunk and a long-lived "epic" branch by
  first merging the trunk down into that branch.

- You MUST NOT use `--no-ff` to forward-promote a trunk. A failing `--ff-only`
  means the target carries a commit the upstream trunk does not. This is a
  workflow violation to report. In this scenario, you MUST NOT try to force
  the merge.

- You MUST NOT do anything more except attempt the integration. Creating
  branches, authoring ordinary commits, concluding merges already in progress,
  fixing failing code, and cutting releases are out-of-scope.

- The source and target MUST belong to the same delivery pipeline. Each delivery
  pipeline is a separate line of trunks, and work leaves one pipeline for
  another only through cherry-picking, never by merging. You MUST NOT merge
  `latest/dev` into `v2/dev`, for example.

- You MUST NOT resolve merge conflicts, however trivial they look. A resolution
  needs the authors' knowledge of what each side intended. Abort, and leave the
  resolution to the user.

- You MUST NOT commit, continue, or abort a merge already in progress. The
  merge, and any conflict resolution in it, belongs to whoever started it.
  Aborting it would discard their resolutions. Committing it would land an
  integration this skill neither chose the strategy for nor produced.

- You MUST NOT use `--no-verify`, `--allow-empty`, or the `-X ours` and
  `-X theirs` strategy options. Skipping hooks or silently preferring one side
  hides legitimate conflicts.

- You MUST NOT rebase commits already pushed to a shared branch. Rewriting
  shared history breaks every other contributor's clone.

- To commit a squash merge, write a commit message in the following format:
  `<type>: <description>`. The `<description>` part described the changes. It
  MUST be full lowercase, and written in the imperative mood — "add", not
  "added" or "adds". It MUST NOT end with a period and MUST NOT be longer than
  60 characters in length. The `<type>` value MUST be derived from the following
  map — choose the type with the closest semantics to the changeset:

  - `behavior`. User-facing operation or behavior change — eg. new commands,
    endpoints, deprecations, removals — verifiable through the UI.

  - `chore`. Small, insignificant housekeeping — eg. typo fixes, comment tweaks,
    or edits to other non-production artifacts. Typically needs no peer review
    nor changelog entry.

  - `fix`. Resolves a defect — eg. a bug, regression, vulnerability, incident,
    or silencing of spurious error log entries.

  - `maintenance`. Required upkeep — eg. dependency bumps, test improvements, CI
    reconfiguration, documentation, and security patches.

  - `quality`. Implements a dynamic quality attribute, observable and measurable
    outside the system — eg. latency, throughput, resource utilization,
    availability, security, compliance.

  - `refactor`. Improves internal structure without changing behavior or
    degrading runtime quality — eg. renames, helper extraction, simplifying
    interfaces, and restructuring of data flows.

  - `step`. Incremental progress toward a larger behavior change or fix that is
    not yet user-facing.

  - `style`. Presentation-only changes to code or content — eg. whitespace,
    indentation, line wrapping.

## Edge cases

- If a merge is in progress, and every conflict is resolved, and the user asks
  you to commit it, stop and alert the user all the same. Concluding an in-flight
  merge is out-of-scope.

- Never attempt to resolve merge conflicts. Even if a conflict looks trivial,
  eg. whitespace or the order of imports, abort and alert the user.

- If both sides apply cleanly but the combined behavior is wrong, this is a
  semantic conflict, eg. a symbol renamed on one side is still called from the
  other. Only the build and tests will catch this type of merge issues. Do not
  attempt to fix it, even where the fix looks mechanical. Stop and report the
  issue.

- If the source and target sit in different pipelines, eg. `latest/temp/*` into
  `v2/dev`, this is a backport, not a merge. Stop and report it.

- If the source branch is already an ancestor of the target, there is nothing
  to integrate, so stop and report.

## Examples

- Reintegrating a short-lived "temp" branch:

  ```sh
  # On latest/temp/482-idempotency:
  git fetch origin
  git rebase origin/latest/dev  # Rebase up; abort on any conflict.
  git switch latest/dev
  git merge --ff-only latest/temp/482-idempotency
  npm test                      # Green on the merged result.
  git push origin latest/dev
  git branch -d latest/temp/482-idempotency
  git push origin --delete latest/temp/482-idempotency
  ```

- Reintegrating a long-lived "epic" branch:

  ```sh
  # Pre-condition: latest/dev has been merged down into the epic.
  git switch latest/dev
  git pull --ff-only
  git merge --squash latest/epic/billing-v2-rewrite
  git commit             # Subject reflects the epic's outcome.
  npm test               # Green on the squashed result.
  git push origin latest/dev
  git branch -D latest/epic/billing-v2-rewrite  # -D: never FF-merged.
  git push origin --delete latest/epic/billing-v2-rewrite
  ```

- A conflicted merge-down:

  ```sh
  git switch latest/epic/billing-v2-rewrite
  git merge --no-ff latest/dev
  # CONFLICT (content): Merge conflict in src/billing/invoice.ts
  git diff --name-only --diff-filter=U  # Record the conflicted paths.
  git merge --abort

  # Alert the user that src/billing/invoice.ts conflicts. Do not resolve it.
  ```

- A blocked trunk promotion:

  ```sh
  git switch latest/test
  git merge --ff-only latest/dev
  # fatal: Not possible to fast-forward, aborting.

  # latest/test carries a commit that is not on latest/dev. Fixes must
  # originate upstream and flow forward, so this is a workflow violation.
  # Report it; do not reach for --no-ff to "fix" it.
  ```
