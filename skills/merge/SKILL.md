---
name: merge
description: >-
  Integrates work between two Git branches, choosing the merge strategy —
  rebase-then-fast-forward, squash merge, merge commit, or fast-forward — that
  the source and target branch types call for. Use when work on one branch is
  being integrated into another, or when the user says "merge this branch
  into ...", "integrate this branch back into the trunk", or "promote one
  branch to another". Do not use it to create branches, author ordinary
  commits, or cut releases.
compatibility: >-
  requires Bash (git, project build and test commands), Read, Edit, Glob, Grep
license: CC0-1.0
---

# Merge

Consolidate divergence between two Git branches using the merge strategy
appropriate to their branch types. You MUST NOT change the software itself
beyond what conflict resolution and the project's own changelog convention
require.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where a repository or
artifact lives, or how to access it, when context and environment do not
settle it.

- **The source branch — REQUIRED.** The branch carrying the work to be
  integrated. It MUST be fully committed and current with its remote.

- **The target branch — REQUIRED.** The branch the work lands on. Never
  infer it from a bare "merge this"; a repository may have several trunks.

- **The project's branching convention — OPTIONAL.** Where the project
  documents one, in a convention file or contributing guide, follow it and
  map its branch types onto the strategies in the rules below. Absent one,
  default to the trunk-based model those rules describe.

- **The project's build and test commands — OPTIONAL.** Discover them from
  the environment, eg. a task runner, package manifest, or CI configuration.
  If the project has none, say so in the final report rather than declaring
  the merge verified.

- **The changelog store — OPTIONAL.** Only relevant when a long-lived branch
  is squashed onto a trunk. Discover whether the project keeps a changelog,
  and where, from context and then the environment. Follow whatever format
  and unreleased-section convention that store documents for itself.

This task runs non-interactively to completion. It does not block for user
input.

## Success criteria

- The target branch MUST carry the source's work, with a history shaped by
  the strategy its branch pair calls for: a linear extension for a rebased
  short-lived branch, a single new commit for a squashed long-lived branch,
  and no new commit at all for a trunk promotion.

- Trunk history MUST be linear after a merge onto a trunk. Check with
  `git log --oneline --graph -10` and confirm there are no merge bubbles.

- The merged result MUST pass the project's build and test commands, run
  locally on the merge result before the push. CI passing on the source
  branch beforehand is not the same evidence, because it never saw the
  combination.

- No conflict markers MUST remain. `git grep -nE '^(<<<<<<<|=======|>>>>>>>)'`
  on the merged tree MUST return nothing.

- Disposable source branches MUST be gone once landed, deleted both locally
  and on the remote, while every trunk MUST remain intact.

- Where a squash onto a trunk lands a long-lived branch and the project keeps
  a changelog, that changelog's unreleased section MUST describe the work,
  in a commit made on the source branch before the squash.

- Nothing outside integration MUST have happened: no new branch created, no
  release cut, no version bumped, and no edit to tracked files other than
  conflict resolutions and the changelog entry.

## Instructions

1.  State the source and target explicitly.

    Write both down before doing anything else, eg. "source
    `temp/482-idempotency`, target `dev`". Confirm both exist locally and
    are current with their remotes (`git fetch`), and that `git status` is
    clean.

2.  Classify the branch pair and choose the strategy.

    | Source → Target                   | Strategy             | Command                                 |
    | --------------------------------- | -------------------- | --------------------------------------- |
    | `temp/*` → `dev`                  | Rebase up, then FF   | `git rebase dev && git merge --ff-only` |
    | `epic/*` → `dev`                  | Squash merge         | `git merge --squash`                    |
    | `dev` → `epic/*`                  | Merge commit (no-FF) | `git merge --no-ff dev`                 |
    | `dev` → `test` → `ready`          | Fast-forward only    | `git merge --ff-only`                   |
    | `ready` → release / `release/<v>` | Fast-forward only    | `git merge --ff-only`                   |

3.  Align the source branch before merging.

    For a short-lived branch, rebase it onto the latest target
    (`git rebase dev`), so the fast-forward that follows adds no commit.

    For a long-lived branch, first merge the target down into it
    (`git merge --no-ff dev`), resolving conflicts there. Then, still on the
    source branch, commit the changelog entry, if the project keeps a
    changelog. That commit is folded into the squash, and is how the entry
    reaches the trunk.

    For a trunk promotion, verify the upstream trunk is a direct ancestor of
    the target (`git merge-base --is-ancestor dev test`). If it is not, stop
    and escalate.

4.  Run pre-merge checks on the source.

    Confirm the tree is clean, the test suite is green, commit messages
    satisfy the project's message convention, and no commit is flagged as
    work-in-progress or temporary when the target is a shared trunk. Fix any
    failure on the source branch and re-run the checks.

5.  Execute the merge with the command from the table.

    ```sh
    # Short-lived branch into the trunk, after the rebase-up.
    git checkout dev
    git merge --ff-only temp/482-idempotency

    # Long-lived branch into the trunk, after the merge-down.
    git checkout dev
    git merge --squash epic/billing-v2-rewrite
    git commit  # Author per the project's message convention.

    # Trunk forward-promotion.
    git checkout test
    git merge --ff-only dev
    ```

6.  Resolve any conflicts deliberately.

    List them with `git status`, then open and resolve each by hand,
    preferring the change that preserves the target branch's contract over
    local convenience. Stage resolutions with `git add`, then continue
    (`git rebase --continue`, or `git commit` for a merge).

    Watch for semantic conflicts: both sides apply cleanly but the combined
    behavior is wrong, eg. a symbol renamed on one side and still called from
    the other. Run the type-checker and tests after each non-trivial
    resolution, since they are what catch these.

7.  Verify the merged result before pushing.

    Run the project's build and test commands on the merge result. Then
    sanity-check the history with `git log --oneline --graph -10`: linear for
    a trunk merge, and a single well-described commit for a squash.

8.  Push the target, then delete the disposable source branch.

    ```sh
    git push origin <target>
    git branch -d temp/482-idempotency
    git push origin --delete temp/482-idempotency
    ```

    Report the strategy used, the resulting commit or commits, the
    verification that ran, and any branch deleted.

## Rules

- You MUST select the strategy from the branch pair, not from convenience.

  Short-lived branches rebase up and fast-forward; long-lived branches squash;
  trunks fast-forward only. Each strategy encodes what the branch type
  promises about its history, so substituting another corrupts that promise.

- If the situation matches no row in the strategy table, you MUST stop and
  consult the project's branching convention rather than improvise.

- You MUST integrate and stop there.

  Defining the branching convention, creating branches, and cutting releases
  are separate responsibilities. This skill lands work under whatever
  convention the project already keeps.

- You MUST NOT use `--no-ff` to forward-promote a trunk.

  Trunk promotion is fast-forward only. A failing `--ff-only` means the
  target carries a commit the upstream trunk does not, which is a workflow
  violation to escalate, not a merge to force.

- You MUST NOT squash a short-lived branch.

  Its atomic commits are the point: they carry per-step rollback granularity
  into the trunk, which squashing discards.

- You MUST resolve conflicts where the work was done.

  Divergence between a trunk and a long-lived branch is resolved by merging
  the trunk down into that branch, where its author has the context — not at
  the moment of the squash onto the trunk.

- You MUST NOT use `--no-verify`, `--allow-empty`, or the `-X ours` and
  `-X theirs` strategy options unless the user explicitly asks. Skipping
  hooks or silently preferring one side hides legitimate conflicts.

- You MUST NOT rebase commits already pushed to a shared branch, because
  rewriting shared history breaks every other contributor's clone.

- You MUST NOT merge through a known-failing state. Fix the source branch
  first, then restart the procedure.

## Edge cases

- A conflict reveals a genuine design disagreement rather than a textual
  clash.

  Abort the merge (`git merge --abort` or `git rebase --abort`), leaving both
  branches as they were, and report the disagreement for the authors to
  settle. Do not encode a guess at the intended design into the resolution.

- Two long-lived branches have diverged deeply and both need to land.

  Merge the smaller branch into the larger one first, resolve there, then
  squash the combined result onto the trunk. This keeps conflict resolution
  in one place, with the trunk seeing a single reviewed commit.

- The source branch is already an ancestor of the target.

  There is nothing to integrate. Report that, delete the source branch if it
  is disposable, and stop.

## Examples

- Reintegrating a short-lived branch:

  ```sh
  # On temp/482-idempotency:
  git fetch origin
  git rebase origin/dev  # Rebase up; resolve any conflicts here.
  npm test               # Green.
  git checkout dev
  git merge --ff-only temp/482-idempotency
  git push origin dev
  git branch -d temp/482-idempotency
  git push origin --delete temp/482-idempotency
  ```

- Reintegrating a long-lived branch:

  ```sh
  # Pre-condition: dev has been merged down into the epic recently, and the
  # changelog entry is committed on the epic.
  git checkout dev
  git pull --ff-only
  git merge --squash epic/billing-v2-rewrite
  git commit             # Subject reflects the epic's outcome.
  npm test               # Green on the squashed result.
  git push origin dev
  git branch -D epic/billing-v2-rewrite  # -D: it was never FF-merged.
  git push origin --delete epic/billing-v2-rewrite
  ```

- A blocked trunk promotion:

  ```sh
  git checkout test
  git merge --ff-only dev
  # fatal: Not possible to fast-forward, aborting.

  # Diagnosis: test carries a commit that is not on dev. Fixes must
  # originate upstream and flow forward, so this is a workflow violation.
  # Escalate; do not reach for --no-ff to "fix" it.
  ```

- A semantic conflict caught after a textually clean merge:

  ```sh
  git rebase dev
  # Both sides applied cleanly. But:
  npm test
  # FAILS: OrderService no longer has the parse() method that dev's caller
  # expects — it was renamed on the other side.

  # Resolution: update the caller to the new name, stage, continue.
  ```
