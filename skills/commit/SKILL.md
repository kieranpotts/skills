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
  requires Bash (git status, git rev-parse, git diff, git add, git commit,
  git log), Glob, Grep, Read
license: CC0-1.0
---

# Commit

Commit the pending changes in the target repository as one commit, with a
message derived from an analysis of the changeset. Do not modify any file in
the working tree.

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
  Determine the name of the delivery pipeline from the current checked-out
  branch. Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  The name of the delivery pipeline, if specified, forms the optional
  `[<pipeline>/]` component in branch names.

  If the `HEAD` is detached, or the delivery pipeline can't be otherwise
  confidently determined from the current checked-out branch, stop and report.

- **Context — OPTIONAL.** Anything in the user's prompt or the session's
  conversation that bears on the changeset, eg. the problem it solves, why it
  was made, or that it is temporary, experimental, or breaks the build.

## Success criteria

- `git log -1` MUST show exactly one new commit on the checked-out branch,
  with a message in the format the rules below define.

- The new commit MUST NOT be a merge commit.
  `git rev-list --parents -n 1 HEAD` MUST list at most one parent.

- Where the project installs a commit-message hook, it MUST have accepted the
  new commit message.

- The commit type MUST fit the semantics of the changeset. A `behavior` commit,
  for example, MUST change something observable from outside the software
  system at runtime.

- Your report MUST open with the new commit's short hash on a line of its own,
  so a script can read it, followed by its subject and the files it touched.

## Step-by-step instructions

1.  Check the repository layout before anything else. Stop and report unless
    `git rev-parse --path-format=absolute --git-common-dir` prints a path
    ending in `/.bare`, and the current worktree's top level, from
    `git rev-parse --show-toplevel`, sits directly in the directory that holds
    `.bare`.

    Then check the repository state. Stop and report if a merge, rebase,
    cherry-pick, or revert is in progress. A merge is in progress if
    `git rev-parse -q --verify MERGE_HEAD` succeeds, and a squash merge if the
    file at `git rev-parse --git-path SQUASH_MSG` exists. Check both, because
    `git status` does not report a pending squash merge.

    Stop and report if there is nothing to commit, or if the checked-out
    branch is `[<pipeline>/]test`, `[<pipeline>/]ready`, or
    `[<pipeline>/]release` — those trunks only ever move by being fast-forward
    to other trunks, so that all commits flowing through the trunks originate
    on the development trunk, `[<pipeline>/]dev`.

2.  Determine the scope of the changeset. Where the index holds staged changes,
    the changeset is the index alone. Otherwise, stage everything, including
    untracked files, with `git add -A`. Either way, `git diff --staged` now
    shows the whole changeset that will be captured in the commit.

3.  Compose the message. Read `git diff --staged`, and weigh it against the
    session's conversation, recent commits from `git log`, and the surrounding
    code. The conversation often explains why a change was made, and prior
    commits show the repository's conventions and whether this change completes
    work earlier `step` commits began. Choose the commit type, then write the
    description and, where needed, a body, following the commit message
    formation rules below.

4.  Create the commit. Pass the message through a here-document, so the
    body's blank lines and wrapping survive the shell.

    ```sh
    git commit -F - <<'EOF'
    fix: prevent racing of requests

    Dismiss incoming responses other than from the latest request.
    EOF
    ```

    If a commit-message hook rejects the message, fix the message and try
    again, once only. Where any other hook rejects the commit, stop and report
    its output, leaving the changeset staged.

5.  Run `git log -1 --stat`, and report.

## Rules

- You MAY draw on any available context to compose the commit message — the
  changeset, the user's prompt, the session's conversation, prior commits, and
  the surrounding code. But the commit message MUST describe only what the
  changeset contains.

- You MUST make exactly one commit, even where the changeset spans several
  concerns. Splitting a changeset is the user's call, made by staging.

- You MUST NOT use `--no-verify`, `--amend`, or `--allow-empty`, and you MUST
  NOT push.

- Every message MUST follow this format, in which square brackets denote
  OPTIONAL parts.

  ```text
  <type>: <description>[ - <flag>]

  [<body>]
  ```

- The `<type>` MUST be one of the following, chosen for the semantics of the
  changeset.

  - `behavior`. A change to a user-facing operation, observable from outside
    the system through its UI or API — eg. a new command or endpoint, a
    deprecation, a removal.

  - `quality`. A change to a dynamic quality attribute, observable and
    measurable from outside the system at runtime — eg. latency, throughput,
    availability, hardening against attack.

  - `fix`. Resolves a defect — eg. a bug, regression, vulnerability, or
    incident, or silences error log entries that are not errors.

  - `step`. Incremental progress toward a `behavior`, `quality`, or `fix`
    change that is not yet observable from outside the system.

  - `refactor`. Improves internal structure without changing behavior or
    degrading runtime quality — eg. renames, extracted helpers, restructured
    data flows, test and build-script restructuring.

  - `style`. Presentation-only changes — eg. whitespace, indentation, line
    wrapping, a formatter run.

  - `maintenance`. Required upkeep — eg. dependency bumps, test improvements,
    CI reconfiguration, documentation.

  - `chore`. Small, insignificant housekeeping that touches no code or
    configuration — eg. a typo in a readme, a comment tweak.

  - `create`, `update`, `delete`. New, edited, or removed content, in a
    repository of non-executable content such as documentation or
    specifications. Use these only where the repository's history already
    does.

- You MUST NOT choose `version`, `merge`, or `revert` for the commit `<type>`.
  These commit types record specific operations, such as release preparations
  and branch integrations.

- A flag MUST be appended where the changeset diff or session context
  establishes that one of the following flags is applicable to the changeset.

  - `BREAKING`. The changeset includes a breaking change to an external API or
    contract, which will require consumers to act.

  - `INCOMPAT`. An internal breaking change — eg. a function signature,
    schema, or data structure — that may break parallel branches, with no
    consumer impact.

  - `WIP`. Work-in-progress that breaks the build.

  - `TEMPORARY`. A commit that will certainly be reverted, eg. debug logging.

  - `EXPERIMENT`. A trial that may be kept or reverted, depending on its
    outcome, eg. a new library.

- The `<description>` MUST be written with lowercase ASCII letters, digits, and
  spaces only. It MUST be written in the imperative mood — "add", not "added"
  or "adds" — and MUST NOT end with a period.

- The subject line — type, description, and any flag — SHOULD NOT exceed 50
  characters, and MUST NOT exceed 72.

- The subject line MUST NOT carry Conventional Commits artifacts — no scope
  parenthetical (`behavior(parser): …`), and no `!` breaking marker.

- The body is OPTIONAL. If included, it SHOULD explain _why_ the change was
  made, not _what_ changed, in plain-text sentences wrapped at 72 characters.

- The message MUST NOT carry footers or trailers, eg. `Closes: #123` or
  `Co-Authored-By: Name <email>`.

## Edge cases

- If the changeset spans several concerns, then make one commit all the same,
  typed for the concern with the most impact, in this order: `behavior`,
  `fix`, `quality`, `maintenance`, `step`, `refactor`, `style`, `chore`.

- If two commit types both seem to fit one concern, then use the
  following differentiators to determine which commit type is most appropriate.

  - `step` is incomplete work toward an observable change, while `behavior` and
    `quality` mark the commit at which it becomes observable.

  - `refactor` restructures, while `style` changes presentation only.

  - `maintenance` is upkeep of the software, while `chore` is insignificant
    housekeeping that touches no code or configuration.

- If the change concerns security, then type it by what it does. A fix for a
  vulnerability is `fix`. A dependency bump that patches one is
  `maintenance`. New hardening, eg. rate limiting or stricter headers, is
  `quality`.

## Examples

- Subject line only:

  ```text
  behavior: add git uncommit
  fix: handle empty repository in git-amend
  quality: cache search results for 60 seconds
  refactor: simplify test repo interface
  style: apply prettier to src
  step: extract search algorithm to separate module
  maintenance: bump typescript to 5.0
  chore: fix typo in readme
  ```

- With a flag:

  ```text
  behavior: remove legacy auth endpoint - BREAKING
  refactor: rename user id columns - INCOMPAT
  step: wire parser into cli - WIP
  maintenance: add request logging - TEMPORARY
  maintenance: test new build tool version - EXPERIMENT
  ```

- With a body:

  ```text
  fix: prevent racing of requests

  Introduce a request id and a reference to the latest request.
  Dismiss incoming responses other than from latest request.

  Remove timeouts which were previously used to mitigate the racing
  issue but which are now obsolete.
  ```
