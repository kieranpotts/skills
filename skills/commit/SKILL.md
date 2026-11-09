---
name: commit
description: >-
  Commit the pending changes in a Git repository as a single commit, with a
  message derived from the changeset and formatted to a particular convention.
  Use this skill when a change is ready to be committed, or when the user says
  something like "commit this", "commit these changes", or "commit the staged
  changes". Do not use this skill to amend, rewrite, or push commits, to
  conclude a merge or squash merge that is in progress, or to write changelog
  entries.
compatibility: >-
  requires Read, Glob, Grep, Bash (git status, git diff, git add, git commit,
  git log)
license: CC0-1.0
---

# Commit

Commit the pending changes in the target repository as one commit, with a
message derived from an analysis of the changeset, and formatted to a particular
convention. You MUST NOT modify any file in the working tree, and you MUST NOT
amend, rewrite, or push anything. Merge commits, and the commit that concludes a
squash merge, are out-of-scope.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The target repository — REQUIRED.** The Git repository containing the
  current working directory. If the current working directory is not part of
  Git repository, look for a reference to a local Git repository in recent
  session context. The target repository is expected to already exist on the
  local filesystem. If it cannot be discovered, stop and alert the user.

## Success criteria

- `git log -1` MUST show exactly one new commit on the checked-out branch,
  with a message in the format described in the rules below.

- Where the project installs a commit-message hook, it MUST have accepted the
  commit message.

- The commit type MUST fit the semantics of the changeset. For example, a
  `behavior:` commit MUST capture changes to user-facing features or other
  behaviors observable externally to the software system at runtime.

- The new commit MUST NOT be a merge commit. `git rev-list --parents -n 1 HEAD`
  MUST list at most one parent.

- Existing commits MUST NOT have been amended or rewritten, and nothing MUST
  have been pushed.

## Instructions

1.  Check the repository state. Run `git status` in the target repository. Stop
    and report, without committing, if there is nothing to commit, if `HEAD` is
    detached, or if a merge, rebase, cherry-pick, or revert is in progress.

    A merge is in progress if `git rev-parse -q --verify MERGE_HEAD` succeeds.
    A squash merge is in progress if the file at
    `git rev-parse --git-path SQUASH_MSG` exists. Check both, because
    `git status` does not report a pending squash merge.

2.  Settle the changeset that will form the content of the commit object. Where
    the staging index holds changes, the changeset is the contents of the
    staging index alone. Otherwise stage everything with `git add -A`, so the
    changeset becomes every modified, deleted, and untracked file. Either way,
    `git diff --staged` now shows the whole changeset that will be the scope
    of the commit.

3.  Analyze the changeset and compose the message. Read `git diff --staged`,
    plus the surrounding code if the diff alone does not make the change's
    purpose clear. Follow the rules below to choose the commit type — this will
    become the value of the `<type>` component of the commit message. Write the
    subject line, and add an optional body and footers to the commit message,
    following the rules below.

4.  Create the commit. Pass the message through a here-document, so the body's
    blank lines and wrapping survive the shell. Example:

    ```sh
    git commit -F - <<'EOF'
    fix: prevent racing of requests

    Dismiss incoming responses other than from the latest request.
    EOF
    ```

    If a commit-message hook rejects the message and fails the commit operation,
    fix the message and try again — once only. Where any other hook rejects the
    commit, stop and report its output, leaving the changeset staged.

5.  Run `git log -1 --stat` and report the commit's hash, subject, and the
    files it touched.

## Rules

- You MUST derive the message from the changeset alone. Do not take the commit
  type, the subject line, or the message body from the user's prompt or the
  session's conversation. The message describes what the commit actually
  contains, which is knowable only from its diff.

- You MUST make exactly one commit, even where the changeset spans several
  concerns. Splitting a changeset is the user's call. You should assume they
  have already done this.

- You MUST NOT use `--no-verify`, `--amend`, or `--allow-empty`, and you
  MUST NOT push any changes.

- You MUST NOT create a merge commit, nor conclude a merge or squash merge that
  is in progress, even when every conflict is resolved and the user asks you to
  commit it. Concluding a merge belongs to the integration step, not the commit
  step.

- Every message MUST follow the below format, in which square brackets denote
  optional sections.

  ```sh
  <type>: <description>[ - <flag>]

  [<body>]

  [<footers>]
  ```

- The commit `<type>` MUST be one of the following literal strings, chosen for
  the semantics of the changeset.

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

- A flag MUST be appended where one of the following cases applies.

  - `BREAKING`. Breaking change to an external API.

  - `INCOMPAT`. Internal breaking change — eg. function signature, schema, or
    data structure. It may break parallel branches, but has no user impact.

  - `TEMPORARY`. A commit that will be reverted, eg. debug logging.

  - `WIP`. Work-in-progress that breaks the build.

  - `EXPERIMENT`. Experimental change expected to be reverted.

- The `<description>` MUST be full lowercase, in the imperative mood — "add",
  not "added" or "adds" — and MUST NOT end with a period.

- The subject line (the first line of message) SHOULD NOT exceed 50 characters
  and MUST NOT exceed 72, counting the type, description, and any optional flag.

- The subject line MUST NOT carry Conventional Commits artifacts. There is no
  scope parenthetical (`behavior(parser): …`), no `!` breaking marker, and
  nothing between the type and its colon.

- The body SHOULD explain _why_ the change was made, not _what_ changed. Write
  it in proper sentences, wrapped at 72 characters. Markdown is allowed, but
  plain text is preferred.

- Footers MUST form a contiguous block of `Key: value` lines — eg.
  `Closes: #123`, `Reviewed-by: Name <email>`. Where the project or the
  session context requires particular trailers, such as `Co-Authored-By:`,
  they MUST go in this block.

## Edge cases

- If the changeset spans several concerns, then you should still try to make one
  commit. Choose the type of the concern with the most impact, in this order:
  `behavior`, `fix`, `quality`, `maintenance`, `step`, `refactor`, `style`,
  `chore`.

- If two commit types both seem to apply to one concern, then consider the
  following differentiators.

  - `step` versus `behavior` or `quality`. `step` is for incomplete work toward
    a user-facing change. `behavior` and `quality` mark the commit at which the
    change becomes verifiable from the outside of the software system.

  - `refactor` versus `style`. `refactor` improves internal structure. `style`
    changes presentation only.

  - `maintenance` versus `chore`. `maintenance` is required upkeep of the
    software, eg. dependencies, infrastructure, CI. `chore` is insignificant
    repository housekeeping, eg. readme tweaks, typos.

## Examples

- Subject line only:

  ```sh
  behavior: add git uncommit
  fix: handle empty repository in git-amend
  refactor: simplify test repo interface
  style: apply prettier to src
  step: extract search algorithm to separate module
  maintenance: bump typescript to 5.0
  chore: fix typo in readme
  ```

- With a flag:

  ```sh
  behavior: remove legacy auth endpoint - BREAKING
  step: refactor database layer - INCOMPAT
  refactor: optimize query performance - WIP
  maintenance: test new build tool version - EXPERIMENT
  ```

- With a body and a footer:

  ```sh
  fix: prevent racing of requests

  Introduce a request id and a reference to the latest request.
  Dismiss incoming responses other than from latest request.

  Remove timeouts which were previously used to mitigate the racing
  issue but which are now obsolete.

  Closes: #123
  ```
