---
name: merge
description: >-
  Integrate the checked-out Git branch into another branch of the same delivery
  pipeline, in the target branch's own worktree, using the strategy — rebase
  then fast-forward, squash merge, merge commit, or fast-forward — that the two
  branch types call for. Use when work on a branch is ready to integrate, or
  when the user says something like "merge this branch", "integrate this into
  the trunk", or "promote dev to test". Do not use it to conclude a merge
  already in progress, to create branches, to author ordinary commits, or to
  cut releases.
compatibility: >-
  requires Bash (git status, git rev-parse, git worktree, git fetch, git log,
  git rebase, git merge, git commit, git diff, git reset)
license: CC0-1.0
---

# Merge

Integrate the checked-out branch into its target, using the strategy that the
pair of branch types calls for, and working on the target in its own worktree.
Where Git cannot complete the integration by itself, abort it and report the
conflicts.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and report.

- **The target repository — REQUIRED.** The Git repository containing the
  current working directory. It MUST be a bare clone in a directory named
  `.bare`, with each of its worktrees checked out in a directory beside it, eg.
  `<project>/.bare` and `<project>/default`. If the working directory sits
  outside a Git repository, or the repository is not laid out this way, stop
  and report.

- **The delivery pipeline — REQUIRED.** This is usually a major version number
  like "v1" or "v2", or the word "latest". It may be unspecified for
  continuously-released software that has a single perpetual delivery pipeline.
  Determine the name of the delivery pipeline from the branch checked out in
  the current worktree. Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  The name of the delivery pipeline, if specified, forms the optional
  `[<pipeline>/]` component in branch names.

  If the `HEAD` is detached, or the delivery pipeline can't be otherwise
  confidently determined from the current checked-out branch, stop and report.

- **The source branch — REQUIRED.** The branch checked out in the current
  worktree, which carries the work to integrate.

- **The target branch — REQUIRED.** The branch the work lands on. For a temp or
  epic source, it is `[<pipeline>/]dev`, unless the prompt names another. For
  a trunk source, the prompt MUST name it, eg. "promote dev to test" or "merge
  dev into the billing epic".

- **The target worktree — REQUIRED.** The worktree that has the target branch
  checked out. Where there is none, you will create one.

## Success criteria

- The target MUST carry the source's work. After a fast-forward,
  `git merge-base --is-ancestor <source> <target>` MUST succeed. After a squash
  merge, `git diff --quiet <source> <target>` MUST succeed.

- After integrating a temp branch, or promoting a trunk,
  `git rev-list --merges <old-target>..<target>` MUST print nothing. After
  integrating an epic, `git rev-list --count <old-target>..<target>` MUST
  print `1`.

- The source MUST still be checked out in the current worktree, and the target
  in the target worktree. Both worktrees MUST be clean:
  `git -C <path> status --porcelain` MUST print nothing for each.

- No merge MUST remain in progress in either worktree:
  `git -C <path> rev-parse -q --verify MERGE_HEAD` MUST fail, and the
  `SQUASH_MSG` file MUST NOT exist.

- No branch or worktree MUST have been deleted, and nothing MUST have been
  pushed.

- Your report MUST open with the target branch and its new short hash on a line
  of its own, eg. `latest/dev 3f9c2ab`, so a script can read it. The second
  line MUST give the path of the target worktree. The strategy used MUST
  follow.

## Step-by-step instructions

1.  Check the repository layout before anything else. Stop and report unless
    `git rev-parse --path-format=absolute --git-common-dir` prints a path
    ending in `/.bare`, and the current worktree's top level, from
    `git rev-parse --show-toplevel`, sits directly in the directory that holds
    `.bare`. Call that directory `<project>`.

    Then stop and report unless the current worktree is clean.

2.  Resolve the target worktree. In `git worktree list --porcelain`, it is the
    `worktree <path>` record with the line `branch refs/heads/<target>`. Where
    no worktree has the target checked out, create one in `<project>`, named
    after the branch with each `/` replaced by `-`:

    ```sh
    git worktree add <project>/latest-test latest/test
    ```

    Stop and report unless the target worktree is clean.

3.  Update the remote-tracking branches and tags with
    `git fetch origin --tags`. If the repository has no `origin` remote, skip
    the fetch, work from local refs, and say so in the report.

4.  Bring every shared branch involved — the trunks, and any epic — up to date,
    in the worktree that has it checked out:
    `git -C <path> merge --ff-only origin/<branch>`. This refuses anything but
    a fast-forward. If the local branch has diverged from origin, stop and
    report. Skip a branch that origin does not carry. A temp branch is
    personal, so its local copy is authoritative: leave it as it is.

5.  Choose the strategy from the branch pair. If the pair is not in this table,
    stop and report.

    | Source (current worktree) | Target                 | Strategy                  |
    | ------------------------- | ---------------------- | ------------------------- |
    | `[<pipeline>/]temp/*`     | `[<pipeline>/]dev`     | Rebase, then fast-forward |
    | `[<pipeline>/]epic/*`     | `[<pipeline>/]dev`     | Merge down, then squash   |
    | `[<pipeline>/]dev`        | `[<pipeline>/]epic/*`  | Merge commit              |
    | `[<pipeline>/]dev`        | `[<pipeline>/]test`    | Fast-forward              |
    | `[<pipeline>/]test`       | `[<pipeline>/]ready`   | Fast-forward              |
    | `[<pipeline>/]dev`        | `[<pipeline>/]ready`   | Fast-forward              |
    | `[<pipeline>/]ready`      | `[<pipeline>/]release` | Fast-forward              |

    Promote `dev` straight to `ready` only where the pipeline has no `test`
    trunk. One run moves one row: a promotion from `dev` to `release` takes
    three runs.

6.  Record the target's current tip, `<old-target>`, for the success criteria.
    Then run the strategy's commands. Commands without `-C` run in the current
    worktree, on the source.

    Temp branch into the trunk:

    ```sh
    git rebase latest/dev
    git -C <target-worktree> merge --ff-only latest/temp/482-idempotency
    ```

    Epic branch into the trunk. Merge the trunk down first, so the squash
    carries the epic's resolution of any divergence:

    ```sh
    git merge --no-ff --no-edit -m "merge: sync with latest/dev" latest/dev
    git -C <target-worktree> merge --squash latest/epic/billing-v2-rewrite
    git -C <target-worktree> commit -F - <<'EOF'
    behavior: rewrite billing engine - BREAKING

    - step: extract invoice model
    - behavior: replace legacy tax rules - BREAKING
    - fix: round line totals to the currency's minor unit
    EOF
    ```

    Trunk into an epic branch:

    ```sh
    git -C <target-worktree> merge --no-ff --no-edit \
      -m "merge: sync with latest/dev" latest/dev
    ```

    Trunk promotion:

    ```sh
    git -C <target-worktree> merge --ff-only latest/dev
    ```

7.  If Git stops on a conflict, list the conflicted paths in the worktree where
    it stopped, with `git -C <path> diff --name-only --diff-filter=U`. Then
    abort there, leaving both branches as they were: `git rebase --abort` for a
    rebase, `git merge --abort` for a merge, or `git reset --merge` for a
    squash merge. Then stop and report the conflicted paths.

8.  Report.

## Rules

- You MUST NOT resolve a conflict, however trivial it looks, eg. whitespace or
  import order. A resolution needs the authors' knowledge of what each side
  intended.

- You MUST NOT squash a temp branch. Its atomic commits carry per-step rollback
  granularity into the trunk, which squashing discards.

- You MUST only fast-forward one trunk to another, never with `--no-ff` or
  force. A failing `--ff-only` means the target carries a commit the source
  does not, which is a workflow violation to report, not to work around.

- You MAY rebase a temp branch even after it has been pushed, because temp
  branches are personal. You MUST NOT rewrite the history of a trunk or an
  epic branch, which are shared.

- The source and target MUST belong to the same delivery pipeline. Work moves
  between pipelines only by cherry-picking, which is out of scope.

- You MUST NOT switch the branch checked out in any worktree, and you MUST
  change a worktree only where you found it clean: where
  `git -C <path> status --porcelain` printed nothing,
  `git -C <path> rev-parse -q --verify MERGE_HEAD` failed, and no file existed
  at `git -C <path> rev-parse --path-format=absolute --git-path SQUASH_MSG`.
  Each worktree belongs to whoever works in it, and uncommitted changes there
  are someone's work in progress, which a merge would tangle with.

- The squash commit's message MUST follow the project's commit convention:
  `<type>: <description>[ - <flag>]`, with a subject that SHOULD NOT exceed 50
  characters and MUST NOT exceed 72. Take the type from the epic's commits
  (`git log --no-merges --format=%s <target>..<source>`), choosing the one
  with the most impact in this order: `behavior`, `fix`, `quality`,
  `maintenance`, `step`, `refactor`, `style`, `chore`. Write the description
  for the epic's outcome.

- The squash commit's subject MUST carry `BREAKING` if any of the epic's
  commits does, or else `INCOMPAT` if any does, because later tooling reads
  flags to decide version bumps. Drop `WIP`, `TEMPORARY`, and `EXPERIMENT`,
  which describe intermediate states the squash erases. The body MUST list the
  epic's commit subjects, one per line, oldest first.

- You MUST NOT use `--no-verify`, `--allow-empty`, or the `-X ours` and
  `-X theirs` strategy options. Skipping hooks, or silently preferring one
  side, hides legitimate conflicts.

- You MUST NOT run the build or tests, push, or delete any branch or worktree.
  Verifying the merged result, publishing it, and cleaning up belong to the
  caller.

## Edge cases

- If the source is already an ancestor of the target, then there is nothing to
  integrate. Stop and report.

- If a temp branch carries a commit flagged `WIP` or `TEMPORARY`, then stop and
  report it. A broken build or a commit meant for reverting must not reach the
  trunk.

- If the target is in another pipeline, eg. `latest/temp/*` into `v2/dev`, then
  this is a backport, not a merge. Stop and report.

- If `git worktree add` refuses, eg. because the directory already exists, or
  a stale worktree record still claims the branch, then stop and report its
  output. Do not remove, move, or prune any worktree.

## Examples

- A conflicted merge-down:

  ```sh
  git merge --no-ff --no-edit -m "merge: sync with latest/dev" latest/dev
  # CONFLICT (content): Merge conflict in src/billing/invoice.ts
  git diff --name-only --diff-filter=U
  git merge --abort
  ```

  The report names `src/billing/invoice.ts` as conflicted.

- A blocked trunk promotion:

  ```sh
  git -C <target-worktree> merge --ff-only latest/dev
  # fatal: Not possible to fast-forward, aborting.
  ```

  The report says that `latest/test` carries a commit missing from
  `latest/dev`, which breaks the rule that every change originates on `dev`.
