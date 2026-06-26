# 🤖 `branch`

`branch` = git branching strategy. It codifies a trunk-based branch model: permanent fast-forward-only trunks (`dev` → `test` → `ready`), short-lived `temp/*` branches for single-focus changes, and long-lived `epic/*` branches for large multi-contributor work, all governed by naming rules and a validation regex.

Use it when creating a new branch, naming a feature or fix branch, or checking branch names before push. It tells you which branch type fits the work, what to name it, and whether a proposed name is well-formed.

This skill instructs the agent to run non-interactively (🤖).

## How to invoke

- `/branch`, `/skill:branch` (prompts vary by harness).
- "What should I call this branch?"
- "Create a branch for this work."
- "Is this branch name valid?"
