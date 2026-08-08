---
name: commit
description: >-
  Compose a Git commit message in a fixed `<type>: <description>` format, or
  validate existing messages against that format. Use when writing a commit
  message, checking a branch's messages before push, or troubleshooting a
  failed commit-message validation job, or when the user says "write a commit
  message for this", "is this commit message valid?", or "why did commit
  validation fail in CI?". Do not use it to stage, commit, amend, or push.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (git diff, git log)
license: CC0-1.0
---

# Commit

Compose a commit message that conforms to the convention defined below, or
validate existing messages against it, and write the matching changelog entry
where the project keeps a changelog. You MUST NOT stage, commit, amend, or
push anything.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message.

- **A change to describe, or messages to validate — REQUIRED.** Either a
  changeset to compose a message for — read it with `git diff` where the
  working tree holds it — or one or more existing messages to check, such as
  a branch's history read with `git log`.

- **The target branch — OPTIONAL.** Whether the commit lands on an
  integration trunk or short-lived branch, which is what makes a changelog
  entry due. Assume the current branch if the user does not say.

- **The project's changelog — OPTIONAL.** Where the project records
  unreleased changes. Discover it rather than assuming: check this session's
  context first, then the environment — a convention file, a changelog file
  at the project root, a release-notes tool. Where the project keeps no
  changelog, skip the changelog work and say so; do not create one uninvited.

## Success criteria

- The outcome MUST be either a proposed message in `<type>: <description>`
  form with any flag, body, and footers, or a pass/fail verdict for each
  message checked, naming the rule that each failure violates.

- The subject line MUST pass both deterministic checks: it matches the
  validation regex below, and it fits within 72 characters, any flag
  included.

- The chosen type MUST fit the semantics of the changeset, not merely be a
  legal string. A `behavior:` message on a changeset that ships nothing
  user-facing is a failure even though it validates.

- Where the project keeps a changelog and the commit lands on a trunk or
  short-lived branch, that changelog's unreleased section MUST carry a
  matching entry, unless the type is `chore`.

- Nothing MUST have been staged, committed, amended, or pushed, and no file
  other than the changelog MUST have been modified. The user keeps the final
  say over what enters history.

## Instructions

1.  Read the change.

    Read the diff, or the description of the change, and decide whether it is
    one logical change or must be split into several atomic commits. Compose
    a separate message for each.

2.  Choose the commit type.

    Map the change to the most fitting type from the vocabulary in the rules
    below. Where two types both seem to apply, resolve it using the edge
    cases section.

3.  Compose the subject line.

    Write `<type>: <description>` in lowercase, imperative mood, with no
    trailing period. Append a flag where the change is breaking,
    experimental, internally incompatible, temporary, or work-in-progress.

4.  Add a body and footers where they earn their place.

    Where the why is not obvious from the subject, add a body after a single
    blank line, wrapped at 72 characters. Add footers, such as `Closes: #123`
    or `Refs: #456`, after a further blank line.

5.  Update the changelog, where one is due.

    Where the project keeps a changelog and the commit lands on a trunk or
    short-lived branch, add an entry in whatever section that changelog uses
    for unreleased work, in the same `type: description` form as the subject
    line, flag included. Skip this step for `chore:` commits, and where the
    project keeps no changelog.

6.  Validate before handing back.

    Check each subject line against the regex and the length budget. When
    validating supplied messages, report a pass/fail verdict for each, naming
    the rule that each failure violates.

## Rules

- Every message MUST use this exact format, in which square brackets denote
  optional sections:

  ```sh
  <type>: <description>

  [<body>]

  [<footers>]
  ```

  Only the subject line is validated, against this regex:

  ```sh
  ^((behavior|chore|fix|maintenance|merge|quality|refactor|release|revert|step|style): [a-z].*)$
  ```

- The subject line MUST NOT carry Conventional Commits artifacts.

  There is no scope parenthetical (`behavior(parser): …`), no `!` breaking
  marker, and nothing between the type and its colon. This convention looks
  close enough to Conventional Commits that the habit slips in, so check for
  it explicitly.

- The `<description>` MUST be full lowercase, in the imperative mood — "add",
  not "added" or "adds" — and MUST NOT end with a period.

- The subject line SHOULD NOT exceed 50 characters and MUST NOT exceed 72,
  counting the type, description, and any flag.

- The body SHOULD explain why the change was made, not what changed.

  It is separated from the subject by a single blank line, written in
  sentences, and wrapped at 72 characters. Markdown is allowed; plain text is
  preferred. Footers form a contiguous block of `Key: value` lines — eg.
  `Closes: #123`, `Reviewed-by: Name <email>` — separated from the body by a
  single blank line. Bodies and footers are OPTIONAL and are not validated.

- Commits MUST be atomic — one logical change each, with large changes split.

  A user-facing change typically arrives as a bundle of atomic commits
  (`refactor:`, `style:`, `step:`, `chore:`) culminating in the `behavior:` or
  `quality:` commit that makes the requirement verifiable through the
  system's UI.

- The `<type>` MUST be one of these literal strings, chosen for the semantics
  of the changeset:

  - `behavior`: user-facing operation or behavior change — new commands,
    flags, endpoints, deprecations, removals — verifiable through the UI.

  - `chore`: small, insignificant housekeeping — typo fixes, comment tweaks,
    non-production artifacts. Typically needs no peer review.

  - `fix`: resolves a defect — bug, regression, vulnerability, or incident,
    including silencing spurious error log entries.

  - `maintenance`: required upkeep — dependency bumps, test improvements, CI
    reconfiguration, documentation, security patches.

  - `merge`: a merge commit, where the merge was not fast-forwarded.

  - `quality`: implements a dynamic quality attribute, observable and
    measurable outside the system — latency, throughput, resource
    utilization, availability, security, compliance. Named for the
    externally-observable nature of these changes; it covers the quality
    attributes as a whole, not speed alone.

  - `refactor`: improves internal structure without changing behavior or
    degrading runtime quality — renames, helper extraction, simplifying
    interfaces, restructuring data flows.

  - `release`: version bumps and release-preparation commits.

  - `revert`: reverts a prior commit.

  - `step`: incremental progress toward a larger behavior change or fix that
    is not yet user-facing.

  - `style`: presentation-only changes to code or content — whitespace,
    indentation, line wrapping.

- A flag MAY be appended as `<type>: <description> - <flag>`, and MUST be
  appended where one of these cases applies:

  - `BREAKING`: breaking change to an external API. Automated tools MAY bump
    the next release's major version in response.

  - `EXPERIMENT`: experimental change expected to be reverted. It MAY include
    experimental user-facing features.

  - `INCOMPAT`: internal breaking change — function signature, schema, data
    structure. It may break parallel branches, but has no user impact.

  - `TEMPORARY`: a commit that will be reverted, eg. debug logging.

  - `WIP`: work-in-progress that breaks the build.

  `TEMPORARY` and `WIP` commits SHOULD NOT be pushed to an integration trunk
  in a multi-contributor repository, because they break the trunk for
  everyone else.

- All commit types SHOULD be recorded in the changelog, `style:` and
  `refactor:` included. The sole exception is `chore:`, too minor to warrant
  an entry.

  A changelog serves contributors and developers, whereas release notes — a
  separate artifact — serve end users. Internal changes such as refactorings
  and reformattings therefore belong in the changelog.

- Changelog entries are bullet points in the same `type: description` form as
  the subject line, flag included, and newest entries SHOULD go at the top.

## Edge cases

- Two commit types both seem to apply.

  `step` versus `behavior` or `quality`: `step` is incomplete work toward a
  user-facing change; `behavior` and `quality` mark the commit at which the
  change becomes verifiable.

  `refactor` versus `style`: `refactor` improves internal structure; `style`
  changes presentation only.

  `maintenance` versus `chore`: `maintenance` is upkeep that belongs in the
  changelog — dependencies, infrastructure, CI. `chore` is repository
  housekeeping that does not — readme tweaks, typos.

- A single changeset spans several logical changes.

  Do not stretch one message to cover it. Propose a sequence of atomic
  messages, and state which files or hunks belong to each, so the user can
  stage them separately.

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

- With an optional flag:

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
