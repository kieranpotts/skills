# `/branch`

Git branching conventions: a trunk model with naming rules and a validation regex. Use when creating a new branch, naming a feature or fix branch, or checking branch names before push.

## What it does

`/branch` codifies a trunk-based branch model. There are up to three permanent, fast-forward-only trunks – `dev` (the required integration trunk, where all work originates), then optional `test` and `ready` trunks that changes flow forward into. Off `dev` it allows two kinds of working branch: short-lived `temp/*` branches for single-focus changes, and long-lived `epic/*` branches for large multi-contributor work that can't be continuously integrated. Each carries naming rules – lowercase, kebab-case, an optional leading `<id>`, length budgets – all captured in one validation regex.

It is reference-and-validate, non-interactive: it tells you which branch type fits the work, what to name it, and whether a proposed name is well-formed.

## How to invoke

```
/branch
```

Invoke it when cutting a new branch or vetting names before a push. Describe the work and it picks the branch type (`temp/*` vs `epic/*`, or just `dev`) and a conforming name; give it a name and it validates against the regex.

## Examples

For a short bug fix tracked as issue 178, `/branch` recommends `temp/178-fix-auth-timeout` – cut from `dev`, reintegrated by fast-forward, deleted after. For a months-long, multi-developer billing rewrite it recommends `epic/billing-v2-rewrite`, synchronized by merging `dev` down (never rebasing) and reintegrated by squash-merge. Given a malformed name like `temp/Fix_Auth`, it rejects it – uppercase and underscore – and suggests `temp/fix-auth`.
