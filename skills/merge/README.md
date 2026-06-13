# `/merge`

Consolidate divergence between two git branches using the right strategy for the branch type – fast-forward, merge commit, rebase, or squash-merge – then verify, resolve conflicts, run tests, and push. Use any time work on one branch is being integrated into another.

## What it does

`/merge` applies the project's branching conventions to integrate a source branch into a target. The strategy is determined by branch type, not preference: `temp/*` → `dev` rebases up then fast-forwards; `epic/*` → `dev` squash-merges (after `dev` has been merged *down* into the epic, where conflicts are resolved); `dev` → `test` → `ready` is fast-forward only. It identifies source and target explicitly, picks the matching strategy, runs pre-merge checks (clean tree, green tests, valid commit messages, no `WIP`/`TEMPORARY` on a shared trunk), executes the merge, resolves conflicts deliberately – watching for *semantic* conflicts that apply cleanly but break behavior – verifies the merged result builds and tests green, pushes, and deletes the disposable source branch.

It is non-interactive and escalates rather than improvises: if a trunk fast-forward fails, that signals a workflow violation, and it stops rather than papering over it with `--no-ff`. No `-X ours/theirs`, no `--no-verify` shortcuts.

## How to invoke

```
/merge
```

Tell it the source and target branches. It assumes a clean working tree (stash or commit first). It picks the strategy from the branch types, so no strategy flag is needed.

## Examples

Reintegrating `temp/482-idempotency` into `dev`, `/merge` rebases the temp branch onto the latest `dev`, runs the tests green, fast-forward-merges into `dev`, pushes, and deletes the temp branch locally and remotely – preserving the per-step commit history.

Promoting `dev` to `test`, a `--ff-only` merge fails because `test` has a commit not on `dev`. `/merge` diagnoses this as a workflow violation (fixes must originate on `dev` and flow forward), and escalates rather than switching to a merge commit.
