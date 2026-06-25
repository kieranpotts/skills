# 🤖 `/merge`

`/merge` = branch integration. It applies the project's branching conventions to integrate a source branch into a target, choosing the merge strategy by branch type rather than preference — fast-forward, merge commit, rebase, or squash-merge. It runs pre-merge checks, executes the merge, resolves conflicts deliberately (watching for *semantic* conflicts that apply cleanly but break behavior), verifies the merged result builds and tests green, pushes, and deletes the disposable source branch.

Use it any time work on one branch is being integrated into another. Tell it the source and target branches. It assumes a clean working tree (stash or commit first) and picks the strategy from the branch types.

It runs non-interactively and escalates rather than improvises: if a trunk fast-forward fails, that signals a workflow violation, and it stops rather than papering over it (🤖).

This skill instructs the agent to run non-interactively (🤖).

## How to invoke

- `/merge`, `/skill:merge` (prompts vary by harness).
- "Merge this branch into `dev`."
- "Integrate `temp/...` back into the trunk."
- "Promote `dev` to `test`."
