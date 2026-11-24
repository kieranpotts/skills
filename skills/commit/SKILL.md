---
name: commit
description: >-
  Commit the pending changes in a Git repository as a single commit, with a
  message derived from the changeset and its context, and formatted to a fixed
  convention. Use when a change is ready to be committed, or when the user says
  something like "commit this", "commit these changes", or "commit the staged
  changes". Do not use it to amend, rewrite, or push commits, to conclude a
  merge or revert in progress, or to write changelog entries.
compatibility: >-
  requires Bash (git status, git diff, git add, git commit, git log), Glob,
  Grep, Read
license: CC0-1.0
---

# Commit

Commit the pending changes in the target codebase as one commit, with a message
derived from an analysis of the changeset. Do not modify any file in the
working tree.

## Parameters

Determine the following information from the session context, the current
working directory, and the local environment. You MUST NOT prompt the user for
clarification on this task's requirements. If you cannot determine the
requirements, stop and report.

- **Target codebase — REQUIRED.** The repository to commit in. If the current
  working directory sits inside a Git worktree, that worktree is the target.
  Otherwise identify the target repository from the session context, eg. a path
  the user named. In a bare repository with worktrees, the target is the
  worktree the context names, else the `default` worktree. In a plain
  repository, the target is its checked-out branch. The target MUST already
  exist on disk — do not clone an upstream repository.

- **Context — OPTIONAL.** Anything in the user's prompt or the session's
  conversation that bears on the changeset, eg. the problem it solves, why it
  was made, or that it is temporary, experimental, or breaks the build.

## Success criteria

- `git log -1` MUST show exactly one new commit on the checked-out branch, with
  at most one parent, and a message in the format the rules below define that
  the project's commit-message hook, if any, accepted.

- The commit type MUST fit the semantics of the changeset. A `behavior` commit,
  for example, MUST change something observable from outside the system.

- Your report MUST open with the new commit's short hash on a line of its own,
  so a script can read it, followed by its subject and the files it touched.

## Step-by-step instructions

1.  Run `git status` in the target codebase. Stop and report if `HEAD` is
    detached, if a merge, rebase, cherry-pick, or revert is in progress, or if
    the checked-out branch is one the rules forbid committing on. `git commit`
    would conclude an operation in progress, rather than refuse it.

2.  If the index is empty, stage everything, including untracked files, with
    `git add -A`. Otherwise, the changeset is the index alone. Stop and report
    if there is still nothing to commit.

3.  Read `git diff --staged`, and weigh it against the session's conversation,
    recent commits from `git log`, and the surrounding code. Prior commits show
    whether this change completes work that earlier `step` commits began. Then
    write the message, following the rules below.

4.  Commit, passing the message through a here-document so its blank lines and
    wrapping survive the shell.

    ```sh
    git commit -F - <<'EOF'
    fix: prevent racing of requests

    Dismiss incoming responses other than from the latest request.
    EOF
    ```

    If the commit-message hook rejects the message, fix it and retry, once
    only. If any other hook rejects the commit, stop and report its output,
    leaving the changeset staged.

5.  Run `git log -1 --stat`, and report.

## Rules

- You MAY draw on any available context to write the message, but it MUST
  describe only what the changeset contains.

- You MUST make exactly one commit, even where the changeset spans several
  concerns. Only the user decides how to split a changeset, by staging.

- You MUST NOT commit on a branch named `test`, `ready`, or `release`, with or
  without a pipeline prefix such as `latest/`. Those trunks only ever move by
  fast-forward, so every commit in them originates on a development trunk.

- You MUST NOT use `--no-verify`, `--amend`, or `--allow-empty`, and you MUST
  NOT push.

- Every message MUST follow this format, in which square brackets denote
  OPTIONAL parts.

  ```text
  <type>: <description>[ - <flag>]

  [<body>]
  ```

- The `<type>` MUST be one of the following, chosen for the semantics of the
  changeset. You MUST NOT use `version`, `merge`, or `revert`, which record
  specific operations, such as release preparations and branch integrations.

  | Type                         | Meaning                                                                                                                                                                |
  | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `behavior`                   | A change to a user-facing operation, observable through the system's UI or API — eg. a new command or endpoint, a deprecation, a removal.                              |
  | `quality`                    | A change to a dynamic quality attribute, measurable from outside at runtime — eg. latency, throughput, availability, hardening against attack.                         |
  | `fix`                        | Resolves a defect — eg. a bug, regression, vulnerability, or incident, or silences error log entries that are not errors.                                              |
  | `step`                       | Progress toward a `behavior`, `quality`, or `fix` change that is not yet observable from outside the system.                                                           |
  | `refactor`                   | Improves internal structure without changing behavior or degrading runtime quality — eg. renames, extracted helpers, restructured data flows, tests, or build scripts. |
  | `style`                      | Presentation only — eg. whitespace, indentation, line wrapping, a formatter run.                                                                                       |
  | `maintenance`                | Required upkeep — eg. dependency bumps, test improvements, CI reconfiguration, documentation.                                                                          |
  | `chore`                      | Insignificant housekeeping that touches no code or configuration — eg. a typo in a readme, a comment tweak.                                                            |
  | `create`, `update`, `delete` | New, edited, or removed content, in a repository of non-executable content. Use only where the repository's history already does.                                      |

- You MUST append a flag where the changeset or the context establishes that
  it applies.

  | Flag         | Meaning                                                                                                                                        |
  | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
  | `BREAKING`   | A breaking change to an external API or contract, which will require consumers to act.                                                         |
  | `INCOMPAT`   | An internal breaking change — eg. a function signature, schema, or data structure — that may break parallel branches, with no consumer impact. |
  | `WIP`        | Work in progress that breaks the build.                                                                                                        |
  | `TEMPORARY`  | A commit that will certainly be reverted, eg. debug logging.                                                                                   |
  | `EXPERIMENT` | A trial that may be kept or reverted, depending on its outcome, eg. a new library.                                                             |

- The `<description>` MUST use lowercase ASCII letters, digits, and spaces
  only, MUST be in the imperative mood — "add", not "added" or "adds" — and
  MUST NOT end with a period.

- The subject line SHOULD NOT exceed 50 characters, and MUST NOT exceed 72.

- The body is OPTIONAL. If included, it SHOULD explain _why_ the change was
  made, not _what_ changed, in plain-text sentences wrapped at 72 characters.

- The message MUST NOT carry Conventional Commits artifacts — no scope
  parenthetical (`behavior(parser): …`), no `!` breaking marker — and MUST NOT
  carry footers or trailers, eg. `Closes: #123` or `Co-Authored-By: …`.

## Edge cases

- If the changeset spans several concerns, then type it for the concern with
  the most impact, in this order: `behavior`, `fix`, `quality`, `maintenance`,
  `step`, `refactor`, `style`, `chore`.

- If two types both seem to fit one concern, then `step` is incomplete work
  toward an observable change, while `behavior` and `quality` mark the commit
  at which it becomes observable. `refactor` restructures, while `style`
  changes presentation only. `maintenance` is upkeep of the software, while
  `chore` touches no code or configuration.

- If the change concerns security, then type it by what it does. A fix for a
  vulnerability is `fix`, a dependency bump that patches one is `maintenance`,
  and new hardening, eg. rate limiting, is `quality`.

## Examples

```text
behavior: add git uncommit
fix: handle empty repository in git-amend
quality: cache search results for 60 seconds
refactor: simplify test repo interface
style: apply prettier to src
step: extract search algorithm to separate module
maintenance: bump typescript to 5.0
chore: fix typo in readme
behavior: remove legacy auth endpoint - BREAKING
refactor: rename user id columns - INCOMPAT
step: wire parser into cli - WIP
maintenance: add request logging - TEMPORARY
maintenance: test new build tool version - EXPERIMENT
```

```text
fix: prevent racing of requests

Introduce a request id and a reference to the latest request.
Dismiss incoming responses other than from latest request.

Remove timeouts which were previously used to mitigate the racing
issue but which are now obsolete.
```
