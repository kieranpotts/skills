---
name: merge
description: >-
  Consolidate divergence between branches. Use the appropriate merge strategy
  — eg. fast-forward, merge commit, rebase, or squash-merge — depending on the
  source and target branch types. Use any time work on one branch is being
  integrated into another, or when the user says something like "merge this
  branch into…", "integrate <source-branch-name> back into the trunk", or
  "promote <source-branch-name> to <target-branch-name>".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/WORKFLOW_STANDARD
---

# Merge

Consolidate divergence between two Git branches using the most appropriate
merge strategy.

You MUST NOT make any code or configuration changes to the software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A source branch and a target branch — REQUIRED.** Both committed (no
  uncommitted work) and up to date with their remotes.

- **The project's branching convention — REQUIRED.** Maps each branch type
  to a merge strategy and its commit-message and changelog formats.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- The target branch MUST carry the integrated work, and its history MUST
  reflect the strategy correct for the branch type: `temp/*` branches land
  via rebase-up + fast-forward, `epic/*` branches land via squash-merge,
  and trunk promotions land via fast-forward only.

- The merged result MUST build and test green before push, verified
  locally, not assumed from CI.

- Trunk history MUST be linear after a trunk merge — `git log --oneline
  --graph` MUST show no merge bubbles on `dev`, `test`, `ready`, or
  release.

- All conflicts MUST have been resolved deliberately: no `-X ours`, no
  `-X theirs`, no skipped hooks, and each resolution MUST have been
  reviewed. No conflict markers MUST remain in the merged result.

- Disposable source branches MUST be gone once landed — `temp/*` and
  `epic/*` deleted locally and remotely — while every trunk branch MUST
  remain intact.

- For `epic/*` → `dev`: the changelog MUST be updated in a pre-merge
  commit on the epic branch, where the project keeps one, and its
  unreleased section MUST contain an entry for the epic's changes,
  committed to the `epic/*` branch before the squash-merge.

## Instructions

1.  Identify source and target.

    State both branches explicitly. "Merge into main" is ambiguous when
    there are multiple trunks. Write it down:

    ```sh
    Source: temp/482-idempotency
    Target: dev
    ```

    Confirm both exist locally and are up to date with their remotes
    (`git fetch`).

2.  Identify the branch type and choose the strategy.

    Determine the strategy from the branch type, per the project's
    branching convention:

    | Source → Target              | Strategy                | Command                                  |
    | ---------------------------- | ----------------------- | ---------------------------------------- |
    | `temp/*` → `dev`             | Rebase up, then FF      | `git rebase dev && git merge --ff-only` |
    | `epic/*` → `dev`             | Squash-merge            | `git merge --squash`                     |
    | `dev` → `epic/*`             | Merge commit (no-FF)    | `git merge --no-ff dev`                  |
    | `dev` → `test` → `ready`     | Fast-forward only       | `git merge --ff-only`                    |
    | `ready` → release / `release/<v>` | Fast-forward only       | `git merge --ff-only`                    |

3.  Pre-merge: align the source.

    Before merging into the target:

    - For `temp/*` → `dev`: rebase the source onto the latest `dev`
      (`git rebase dev`). This is the "rebase-up" step. The result is a
      linear history; the FF merge that follows adds no new commit.

    - For `epic/*` → `dev`: ensure the latest `dev` has already been
      merged down into the epic (`git checkout epic/x && git merge --no-ff
      dev`). Then, still on the `epic/*` branch, add a commit that records
      the epic's changes in the project's changelog, if it keeps one, using
      that changelog's own format and unreleased section. This commit is
      squashed in with the rest of the epic's changes and is how the
      changelog entry lands on `dev`.

    - For trunk-to-trunk: verify that the upstream trunk is a direct
      ancestor of the downstream target before running the merge. If it is
      not, escalate per the Rules.

4.  Run pre-merge checks on the source.

    Before merging, confirm:

    - `git status` clean.
    - Tests green on the source branch (run the suite locally or check
      CI).
    - Commit messages valid per the project's message convention.
    - No `WIP` or `TEMPORARY` flagged commits if the target is a shared
      trunk.

    If any check fails, fix it on the source branch and re-run the
    checks.

5.  Execute the merge.

    Run the command from the table. Examples:

    ```sh
    # temp/* into dev (after rebase-up).
    git checkout dev
    git merge --ff-only temp/482-idempotency

    # epic/* into dev (after merge-down from dev into epic).
    git checkout dev
    git merge --squash epic/billing-v2-rewrite
    git commit  # author the squash-commit per the message convention

    # dev down into epic/* (sync).
    git checkout epic/billing-v2-rewrite
    git merge --no-ff dev

    # Trunk forward-promotion.
    git checkout test
    git merge --ff-only dev
    ```

6.  Resolve conflicts.

    If the merge stops with conflicts:

    - List them: `git status` shows the conflicted files.

    - Open each and resolve manually, preferring the change that
      preserves the target branch's contract over local convenience.

    - Watch for semantic conflicts: both sides apply cleanly textually
      but the combined behavior is wrong (renamed symbol still referenced
      by the other side, two new functions with the same name in different
      files, etc.). The compiler / type-checker / test suite catches most
      of these — run them after each non-trivial resolution.

    - Stage resolutions (`git add <file>`).

    - For rebase: `git rebase --continue`. For merge: `git commit`.

7.  Post-merge: verify.

    Before pushing:

    ```sh
    # Tests pass on the merged result.
    <your test command>

    # Build / type-check pass.
    <your build command>

    # Quick sanity-check the history.
    git log --oneline -10
    ```

    For trunk merges: confirm history is linear (`git log --oneline
    --graph -10` shows no merge bubbles).

    For epic merges into `dev`: confirm the squash commit is one commit
    with a meaningful message.

8.  Push, then clean up.

    Push the target, then delete disposable source branches once
    integrated:

    ```sh
    git push origin <target>

    # Delete the source branch once integrated (temp/* and epic/* are
    # disposable after integration).
    git branch -d temp/482-idempotency
    git push origin --delete temp/482-idempotency
    ```

## Rules

- You MUST choose the merge strategy from the table in step 2, based on the
  source and target branch types.

  `temp/*` → rebase-up + FF. `epic/*` → squash-merge. Trunks → FF-only.
  Picking a different strategy violates the branching conventions and
  corrupts history.

- You MUST integrate and stop there.

  Defining the branching convention and cutting releases are separate
  responsibilities; this skill lands work under whatever convention the
  project already keeps.

- If the situation does not match a row in the strategy table, you MUST
  stop and consult the branching convention before improvising.

- You MUST NOT use `--no-ff` to forward-promote trunks.

  `dev` → `test` → `ready` is fast-forward only. If `--ff-only` fails on
  a trunk merge, you MUST escalate.

- You MUST NOT squash a `temp/*` branch.

  Temporary branches preserve their atomic commit history into `dev`.
  Squashing them defeats the purpose of `step:` commits and loses the
  per-step rollback granularity.

- You MUST resolve conflicts where the work was done.

  Conflicts between `dev` and `epic/*` are resolved by merging `dev`
  down into the epic, where the epic author has context. They are not
  resolved at the moment of squash-merge into `dev`.

- You MUST NOT use `--no-verify`, `--allow-empty`, or `-X theirs`/`-X
  ours` shortcuts unless the user has explicitly asked. Skipping hooks or
  silently preferring one side hides legitimate conflicts.

- You MUST NOT merge through known-failing state.

  If pre-merge checks fail, fix the source branch first.

- For trunk-to-trunk promotion, the upstream trunk MUST be a direct
  ancestor of the downstream target.

  If `git merge --ff-only` would fail, the workflow has been violated and
  you MUST escalate.

- If a conflict reveals a real design disagreement, you MUST abort the
  merge and discuss it with the relevant author before retrying.

- When two long-running branches have deep divergence, you MUST prefer
  merging the smaller branch onto the larger and then squash-merging
  into `dev`.

- You MUST NOT rebase already-pushed commits on a shared branch.

- If a merged result that passed tests later breaks production, you MUST
  NOT bypass verification next time.

## Examples

- Reintegrating a temp branch:

  ```sh
  # On temp/482-idempotency:
  git fetch origin
  git rebase origin/dev          # rebase-up; resolve any conflicts here
  npm test                        # green
  git checkout dev
  git merge --ff-only temp/482-idempotency
  git push origin dev
  git branch -d temp/482-idempotency
  git push origin --delete temp/482-idempotency
  ```

- Reintegrating an epic branch:

  ```sh
  # Pre-condition: dev has been merged down into the epic recently.
  git checkout dev
  git pull --ff-only
  git merge --squash epic/billing-v2-rewrite
  git commit       # author per the message convention; subject reflects the epic's outcome
  npm test         # green on the squashed result
  git push origin dev
  git branch -D epic/billing-v2-rewrite   # -D because epic is not FF-merged
  git push origin --delete epic/billing-v2-rewrite
  ```

- A blocked trunk promotion:

  ```sh
  git checkout test
  git merge --ff-only dev
  # fatal: Not possible to fast-forward, aborting.

  # Diagnosis: test has a commit that is not on dev. Per the branching convention,
  # this is a workflow violation — fixes must originate on dev and flow forward.
  # Escalate; do not switch to --no-ff to "fix" it.
  ```

- A semantic conflict caught after textual merge:

  ```sh
  git rebase dev
  # Both sides applied cleanly. But:
  npm test
  # FAILS: OrderService no longer has the `parse()` method dev's caller
  # expects (it was renamed in the epic). The merge was textually clean
  # but semantically broken.

  # Resolution: edit the caller to use the new name, stage, continue.
  ```
