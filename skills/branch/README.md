# 🤖 `/branch`

Git branching strategy: a trunk model with naming rules and a validation regex. Runs non-interactively (🤖). Use when creating a new branch, naming a feature or fix branch, or checking branch names before push.

## What it does

`/branch` codifies a trunk-based branch model: permanent fast-forward-only trunks (`dev` → `test` → `ready`), short-lived `temp/*` branches for single-focus changes, and long-lived `epic/*` branches for large multi-contributor work, all governed by naming rules and a validation regex.

It is reference-and-validate, non-interactive: it tells you which branch type fits the work, what to name it, and whether a proposed name is well-formed.

## How to invoke

Invoke it when cutting a new branch or vetting names before a push. Describe the work and it picks the branch type and a conforming name; give it a name and it validates it.

- `/branch`, `/skill:branch` (prompt varies by agent harness).
- "What should I call this branch?"
- "Create a branch for this work."
- "Is this branch name valid?"
