---
name: commit
description: >-
  Commit message conventions. Use when composing a commit message, validating
  a branch's messages before push, or troubleshooting a failed commit-
  validation CI job, or when the user says "write a commit message for this",
  "is this commit message valid?", or "why did commit validation fail in CI?".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-reasoning
---

# Commit

Compose a commit message that conforms to the project's convention, or
validate existing messages against it, and produce the matching changelog
entry where the project keeps one.

## Parameters

Determine the following information from the surrounding context and
environment.

- **A change to describe, or messages to validate — REQUIRED.** A
  description of a change to compose a message for, or one or more existing
  commit messages to validate (a branch's history before push).

- **The project's changelog, if it keeps one — REQUIRED for direct commits
  to an integration trunk or a short-lived branch.** Discover it rather than
  assuming it: check this session's context first, then the environment (a
  convention file such as `AGENTS.md`, a changelog file at the project root,
  a release-notes tool). If the project keeps no changelog, skip the
  changelog steps and say so. Do not create one uninvited.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- A conforming commit message in the `<type>: <description>` format (with
  any optional flag, body, and footers), or a pass/fail verdict on the
  supplied messages naming the rule each one violates.

- Where required, the matching changelog entry is produced too. This skill
  composes and validates messages and stops; it neither stages nor commits.
  <!-- TODO: Allow direct commits to dev? -->

- The subject line MUST pass the validation regex.

  It MUST match the format defined in the Rules.

- The type semantics MUST fit the changeset.

  Re-read the type's description. If two types feel applicable, consult the
  Subtle distinctions note — that's where the hard cases are resolved.

- The subject line length MUST be within budget.

  ≤50 characters RECOMMENDED, ≤72 characters maximum. Includes the
  optional flag.

- There MUST be no Conventional Commits artifacts.

  No scope parentheticals (`feature(parser): …`), no leading `!`, no
  trailing `:` artifacts. The colon MUST come immediately after the type,
  nothing else.

- The changelog MUST be updated for direct commits to a trunk or short-lived
  branch, unless the type is `chore:` or the project keeps no changelog.

  Its unreleased section MUST contain an entry for this commit, using the
  same `type: description` format as the subject line.

## Instructions

1.  Identify the change type and scope.

    Read the diff or the description of the change, and determine whether the
    change is a single logical change or must be split into multiple atomic
    commits.

2.  Choose the commit type.

    Map the change to the most appropriate type from the allowed vocabulary,
    using the semantics in the Rules. If two types feel applicable, consult
    the Subtle distinctions note.

3.  Compose the subject line.

    Write the subject as `<type>: <description>`, using lowercase, imperative
    mood, with no trailing period. If the change is breaking, experimental,
    incompatible, temporary, or work-in-progress, append the corresponding
    flag.

4.  Add body and footers as needed.

    If the why is not obvious from the subject, add a body separated by a
    single blank line. Wrap body lines at 72 characters. Optionally add
    footers (eg. `Closes: #123`, `Refs: #456`) separated from the body by a
    single blank line.

5.  Update the changelog for direct commits to a trunk or short-lived
    branch.

    Where the project keeps a changelog (see Input), add an entry for this
    change as part of the same commit, in whatever section that changelog
    uses for unreleased work. Use the same `type: description` format as the
    subject line, including any flag. Do not add an entry for `chore:`
    commits. Where the project keeps no changelog, skip this step.

6.  Validate the message.

    Check that the subject line matches the validation regex and is within
    the length budget. If validating existing messages, report a pass/fail
    verdict for each, naming the rule each failure violates.

## Rules

- You MUST use this exact format:

  ```sh
  <type>: <description>

  [<body>]

  [<footers>]
  ```

  Square brackets denote optional sections.

  Validation regex (only the subject line is checked):

  ```sh
  ^((chore|feature|fix|maintenance|merge|refactor|release|revert|runtime|step|style): [a-z].*)$
  ```

  `<type>` MUST be one of these literal strings:

  - `chore`
  - `feature`
  - `fix`
  - `maintenance`
  - `merge`
  - `refactor`
  - `release`
  - `revert`
  - `runtime`
  - `step`
  - `style`

    `<description>` MUST be full lowercase and use the imperative mood (eg.
    "add", not "added" or "adds"). The description MUST NOT end with a period.

    An optional flag MAY be appended — `<type>: <description> - <flag>` where
    `<flag>` is one of:

  - `BREAKING`
  - `EXPERIMENT`
  - `INCOMPAT`
  - `TEMPORARY`
  - `WIP`

    Subject line (type + description + flag) SHOULD NOT exceed 50 characters
    and MUST NOT exceed 72 characters.

    Bodies and footers are OPTIONAL and do not require validation.

  - The body SHOULD explain the why of the change, not the what. It MUST be
    separated from the subject line with a single blank line, use proper
    English sentences, and wrap lines at 72 characters. Markdown formatting
    is allowed, but plain text is preferred.

  - The footer section is a contiguous block consisting of key-value pairs,
    one per line, like `Closes: #123`, `Refs: #456`, `Reviewed-by: Name
    <email>`. Separated from body by a single blank line.

- Commits MUST be atomic.

  One logical change per commit. Large changes MUST be split into multiple
  commits.

  A user-facing change typically arrives as a bundle of atomic commits —
  `refactor:`, `style:`, `step:`, `chore:` — culminating in the `feature:` or
  `runtime:` commit that makes the requirement verifiable through the
  system's UI.

- You MUST pick the most appropriate commit type.

  Choice based on the semantics of the changeset being committed:

  - `chore`: Small, insignificant housekeeping — typo fixes, comment
    tweaks, non-production artifacts. Typically no peer review needed.

  - `feature`: User-facing operation or behavior change (new commands,
    flags, endpoints, features, deprecations, removals), verifiable via
    the UI.

  - `fix`: Resolves a defect — bug, regression, vulnerability, or incident
    (including silencing spurious error log entries).

  - `maintenance`: Required upkeep — dependency bumps, test improvements,
    CI workflow reconfig, documentation, security patches.

  - `merge`: Merge commits (when not fast-forwarded).

  - `refactor`: Improves internal structure without changing features or
    degrading runtime quality (renames, helper extraction, simplifying
    interfaces, restructuring data flows).

  - `release`: Version bumps and release-preparation commits.

  - `revert`: Reverting a prior commit.

  - `runtime`: Implements a dynamic quality attribute — observable and
    measurable outside the system (latency, throughput, resource
    utilization, availability, security, compliance). Named for the
    runtime, externally-observable nature of these changes; covers the
    quality attributes as a whole, not speed alone.

  - `step`: Incremental change toward a larger feature or fix that is not
    yet user-facing.

  - `style`: Presentation-only code or content changes — whitespace,
    indentation, line wrapping, style. Distinct from refactor.

    Subtle distinctions:

  - `step` vs. `feature`/`runtime`: `step` is incomplete work toward a
    user-facing change. `feature`/`runtime` is the commit where the change
    becomes verifiable.

  - refactor vs. `style`: refactor improves internal structure; `style`
    improves code presentation only.

  - `maintenance` vs. `chore`: `maintenance` is upkeep that belongs in the
    changelog (deps, infra, CI). `chore` is repository housekeeping that
    doesn't (README tweaks, typos) — noise that can be omitted from the
    changelog.

- You MUST add a flag to the subject line in the following special cases:

  - `BREAKING`: Breaking change to external API. Automated tools MAY bump
    major version of next release in response.

  - `EXPERIMENT`: Experimental change expected to be reverted. MAY include
    experimental user-facing features.

  - `INCOMPAT`: Internal breaking change (function signature, schema, data
    structure). May break other changes being introduced in parallel
    branches, but no impact on users.

  - `TEMPORARY`: Temporary commit that will be reverted (eg. debug
    logging). SHOULD NOT be pushed to `origin/dev` or other trunks in
    multi-contributor repositories.

  - `WIP`: Work-in-progress that breaks the build. SHOULD NOT be pushed
    to `origin/dev` or other trunks in multi-contributor repositories.

- You MUST update the changelog for commits to a trunk or short-lived
  branch, where the project keeps one.

  Update it as part of the same commit, recording the change in whatever
  section that changelog uses for unreleased work. Discover the changelog's
  location and format rather than assuming `CHANGELOG.md` — and where the
  project keeps none, say so rather than creating one uninvited.

  All commit types SHOULD be recorded — including `style:` and `refactor:`.
  The only exception is `chore:`, which is housekeeping too minor to warrant
  a changelog entry.

  Each entry is a bullet point using the same `type: description` format as
  the commit subject line, including any flag. Newest entries are at the
  top.

  A changelog is for contributors and developers. Release notes — a
  separate artifact — is for end users. So we are interested in recording
  in the changelog internal changes like refactorings and reformattings.

## Examples

- Minimal (subject line only):

  ```sh
  feature: add git uncommit
  fix: handle empty repository in git-amend
  refactor: simplify test repo interface
  style: apply prettier to src
  step: extract search algorithm to separate module
  maintenance: bump typescript to 5.0
  chore: fix typo in readme
  ```

- With optional flag:

  ```sh
  feature: remove legacy auth endpoint - BREAKING
  step: refactor database layer - INCOMPAT
  refactor: optimize query performance - WIP
  maintenance: test new build tool version - EXPERIMENT
  ```

- With body and footer:

  ```sh
  fix: prevent racing of requests

  Introduce a request id and a reference to the latest request.
  Dismiss incoming responses other than from latest request.

  Remove timeouts which were previously used to mitigate the racing
  issue but which are now obsolete.

  Closes: #123
  ```

## References

None.
