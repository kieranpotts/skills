---
name: commit
description: >-
  Commit message format and the semantics of each commit type, including
  optional flags. Use when composing a commit message, validating a branch's
  messages before push, or troubleshooting a failed commit-validation CI job, or
  when the user says "write a commit message for this", "is this commit message
  valid?", or "why did commit validation fail in CI?".
compatibility: requires git
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Commit

**Input:** A description of a change to compose a message for, or one or more
existing commit messages to validate (a branch's history before push). REQUIRED.
For direct commits to `dev` or `temp/*`, the `CHANGELOG.md` is also in scope.

**Output:** A conforming commit message in the `<type>: <description>` format
(with any optional flag, body, and footers), or a pass/fail verdict on the
supplied messages naming the rule each one violates. Where required, the
matching `[Unreleased]` changelog entry is produced too. This skill composes and
validates messages and stops; it neither stages nor commits.

**Interactivity:** Agents MUST NOT block for user input after the initial
prompt. Agents MUST follow this skill's instructions to completion, or fail
with an error message.

<!-- TODO: Allow direct commits to dev? -->

##  Instructions

1.  **Identify the change type and scope.**

    Read the diff or the description of the change. Determine whether the
    change is a single logical change or must be split into multiple atomic
    commits.

2.  **Choose the commit type.**

    Map the change to the most appropriate type from the allowed vocabulary,
    using the semantics in the Rules. If two types feel applicable, consult the
    *Subtle distinctions* note.

3.  **Compose the subject line.**

    Write the subject as `<type>: <description>`, using lowercase, imperative
    mood, with no trailing period. If the change is breaking, experimental,
    incompatible, temporary, or work-in-progress, append the corresponding flag.

4.  **Add body and footers as needed.**

    If the *why* is not obvious from the subject, add a body separated by a
    single blank line. Wrap body lines at 72 characters. Add footers (eg.
    `Closes: #123`, `Refs: #456`) separated from the body by a single blank line.

5.  **Update the CHANGELOG for direct commits to `dev` and `temp/*`.**

    When committing directly to `dev` or a `temp/*` branch, add a bullet to the
    `[Unreleased]` section of the project's `CHANGELOG.md` (or equivalent) as
    part of the same commit. Use the same `type: description` format as the
    subject line, including any flag. Do not add a bullet for `chore:` commits.

6.  **Validate the message.**

    Check that the subject line matches the validation regex and is within the
    length budget. If validating existing messages, report a pass/fail verdict
    for each, naming the rule each failure violates.

##  Rules

-   **You MUST use this exact format:**

    ```
    <type>: <description>

    [<body>]

    [<footers>]
    ```

    Square brackets denote optional sections.

    Validation regex (only the subject line is checked):

    ```
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

    Subject line (type + description + flag) SHOULD NOT exceed 50 characters and
    MUST NOT exceed 72 characters.

    Bodies and footers are OPTIONAL and do not require validation.

    - The body SHOULD explain the _why_ of the change, not the _what_. It MUST
      be separated from the subject line with a single blank line, use proper
      English sentences, and wrap lines at 72 characters. Markdown formatting is
      allowed, but plain text is preferred.

    - The footer section is a contiguous block consisting of key-value pairs,
      one per line, like `Closes: #123`, `Refs: #456`, `Reviewed-by: Name
      <email>`. Separated from body by a single blank line.

-   **Commits MUST be atomic.**

    One logical change per commit. Large changes MUST be split into multiple
    commits.

    A user-facing change typically arrives as a bundle of atomic commits —
    `refactor:`, `style:`, `step:`, `chore:` — culminating in the `feature:` or
    `runtime:` commit that makes the requirement verifiable through the system's
    UI.

-   **You MUST pick the most appropriate commit type.**

    Choice based on the semantics of the changeset being committed:

    - `chore`: Small, insignificant housekeeping — typo fixes, comment tweaks,
      non-production artifacts. Typically no peer review needed.

    - `feature`: User-facing operation or behavior change (new commands, flags,
      endpoints, features, deprecations, removals), verifiable via the UI.

    - `fix`: Resolves a defect — bug, regression, vulnerability, or incident
      (including silencing spurious error log entries).

    - `maintenance`: Required upkeep — dependency bumps, test improvements, CI
      workflow reconfig, documentation, security patches.

    - `merge`: Merge commits (when not fast-forwarded).

    - `refactor`: Improves internal structure without changing features or
      degrading runtime quality (renames, helper extraction, simplifying
      interfaces, restructuring data flows).

    - `release`: Version bumps and release-preparation commits.

    - `revert`: Reverting a prior commit.

    - `runtime`: Implements a dynamic quality attribute — observable and
      measurable outside the system (latency, throughput, resource utilization,
      availability, security, compliance). Named for the runtime,
      externally-observable nature of these changes; covers the quality
      attributes as a whole, not speed alone.

    - `step`: Incremental change toward a larger feature or fix that is not yet
      user-facing.

    - `style`: Presentation-only code or content changes — whitespace,
      indentation, line wrapping, style. Distinct from `refactor`.

    *Subtle distinctions*:

    - `step` vs. `feature`/`runtime`: `step` is incomplete work toward a
      user-facing change. `feature`/`runtime` is the commit where the change
      becomes verifiable.

    - `refactor` vs. `style`: `refactor` improves internal structure; `style`
      improves code presentation only.

    - `maintenance` vs. `chore`: `maintenance` is upkeep that belongs in the
      changelog (deps, infra, CI). `chore` is repository housekeeping that
      doesn't (README tweaks, typos) — noise that can be omitted from the
      changelog.

-   **You MUST add a flag** to the subject line in the following special cases:

    - `BREAKING`: Breaking change to external API. Automated tools MAY bump
      major version of next release in response.

    - `EXPERIMENT`: Experimental change expected to be reverted. MAY include
      experimental user-facing features.

    - `INCOMPAT`: Internal breaking change (function signature, schema, data
      structure). May break other changes being introduced in parallel branches,
      but no impact on users.

    - `TEMPORARY`: Temporary commit that will be reverted (eg. debug logging).
      SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor
      repositories.

    - `WIP`: Work-in-progress that breaks the build. SHOULD NOT be pushed to
      `origin/dev` or other trunks in multi-contributor repositories.

-   **You MUST update the CHANGELOG for commits to `dev` and `temp/*`.**

    When committing directly to `dev` or a `temp/*` branch, update the project's
    `CHANGELOG.md` (or equivalent) as part of the same commit. Document the
    change under an `[Unreleased]` section at the top of the file.

    All commit types SHOULD be recorded — including `style:` and `refactor:`.
    The only exception is `chore:`, which is housekeeping too minor to warrant a
    changelog entry.

    Each entry is a bullet point using the same `type: description` format as
    the commit subject line, including any flag. Newest entries are at the top.

    A changelog is for contributors and developers. Release notes — a separate
    artifact — is for end users. So we _are_ interested in recording in the
    changelog internal changes like refactorings and reformattings.

## Examples

Minimal (subject line only):

```
feature: add git uncommit
fix: handle empty repository in git-amend
refactor: simplify test repo interface
style: apply prettier to src
step: extract search algorithm to separate module
maintenance: bump typescript to 5.0
chore: fix typo in readme
```

With optional flag:

```
feature: remove legacy auth endpoint - BREAKING
step: refactor database layer - INCOMPAT
refactor: optimize query performance - WIP
maintenance: test new build tool version - EXPERIMENT
```

With body and footer:

```
fix: prevent racing of requests

Introduce a request id and a reference to the latest request.
Dismiss incoming responses other than from latest request.

Remove timeouts which were previously used to mitigate the racing
issue but which are now obsolete.

Closes: #123
```

##  Success criteria

-   **The subject line MUST pass the validation regex.**

    It MUST match the format defined in the Rules.

-   **The type semantics MUST fit the changeset.**

    Re-read the type's description. If two types feel applicable, consult the
    *Subtle distinctions* note — that's where the hard cases are resolved.

-   **The subject line length MUST be within budget.**

    ≤50 characters RECOMMENDED, ≤72 characters maximum. Includes the optional
    flag.

-   **There MUST be no Conventional Commits artefacts.**

    No scope parentheticals (`feature(parser): …`), no leading `!`, no trailing
    `:` artefacts. The colon MUST come immediately after the type, nothing else.

-   **The CHANGELOG MUST be updated for direct commits to `dev` and `temp/*`
    branches, unless the type is `chore:`.**

    The `[Unreleased]` section MUST exist and MUST contain a bullet for this
    commit, using the same `type: description` format as the subject line.
