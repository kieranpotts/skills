---
name: commit
description: Commit message format and the semantics of each commit type, including optional flags. Use when composing a commit message, validating a branch's messages before push, or troubleshooting a failed commit-validation CI job.
compatibility: requires git
license: MIT
---

# Commits

Do NOT use this skill for branch-naming conventions or PR titles.

This convention is NOT compatible with Conventional Commits. Scopes/parentheticals (`feature(parser): …`) fail validation — the colon comes immediately after the type.

## Rules

-   **Use this exact format**:

    ```
    <type>: <description>

    [<body>]

    [<footers>]
    ```

    Square brackets denote optional sections.

    Validation regex (only the subject line is checked):

    ```
    ^((chore|feature|fix|format|maintenance|merge|performance|refactor|release|revert|step): [a-z].*)$
    ```

    `<type>` MUST be one of these literal strings:

    - `chore`
    - `feature`
    - `fix`
    - `format`
    - `maintenance`
    - `merge`
    - `performance`
    - `refactor`
    - `release`
    - `revert`
    - `step`

    `<description>` MUST be full lowercase and use the imperative mood (eg. "add", not "added" or "adds"). No period at the end of the description.

    An optional flag MAY be appended - `<type>: <description> - <flag>` where `<flag>` is one of:

    - `BREAKING`
    - `EXPERIMENT`
    - `INCOMPAT`
    - `TEMPORARY`
    - `WIP`

    Subject line (type + description + flag) SHOULD NOT exceed 50 characters and MUST NOT exceed 72 characters.

    Bodies and footers are OPTIONAL and do not require validation.

    - Use the body to explain the _why_ of the change, not the _what_. Separate from subject line with a single blank line. Proper English sentences. Markdown formatting allowed, but prefer plain text. Wrap lines at 72 characters.

    - The footer section is a contiguous block consisting of key-value pairs, one per line, like `Closes: #123`, `Refs: #456`, `Reviewed-by: Name <email>`. Separated from body by a single blank line.

-   **Atomic commits.**

    One logical change per commit. Split large changes into multiple commits.

    A user-facing change typically arrives as a bundle of atomic commits — `refactor:`, `format:`, `step:`, `chore:` — culminating in the `feature:` or `performance:` commit that makes the requirement verifiable through the system's UI.

-   **Pick the most appropriate commit type.**

    Choice based on the semantics of the changeset being committed:

    - `chore`: Small, insignificant housekeeping - typo fixes, comment tweaks, non-production artifacts. Typically no peer review needed.

    - `feature`: User-facing operation or behavior change (new commands, flags, endpoints, features, deprecations, removals), verifiable via the UI.

    - `fix`: Resolves a defect - bug, regression, vulnerability, or incident (including silencing spurious error log entries).

    - `format`: Presentation-only code or content changes — whitespace, indentation, line wrapping, style. Distinct from `refactor`.

    - `maintenance`: Required upkeep - dependency bumps, test improvements, CI workflow reconfig, documentation, security patches.

    - `merge`: Merge commits (when not fast-forwarded).

    - `performance`: External runtime optimization - observable and measurable outside the system (latency, throughput, resource utilization, security, compliance).

    - `refactor`: Improves internal structure without changing features or degrading performance (renames, helper extraction, simplifying interfaces, restructuring data flows).

    - `release`: Version bumps and release-preparation commits.

    - `revert`: Reverting a prior commit.

    - `step`: Incremental change toward a larger feature or fix that is not yet user-facing.

    *Subtle distinctions*:

    - `step` vs. `feature`/`performance`: `step` is incomplete work toward a user-facing change. `feature`/`performance` is the commit where the change becomes verifiable.

    - `refactor` vs. `format`: `refactor` improves internal structure; `format` improves code presentation only.

    - `maintenance` vs. `chore`: `maintenance` is upkeep that belongs in the changelog (deps, infra, CI). `chore` is repository housekeeping that doesn't (README tweaks, typos) — noise that can be omitted from the changelog.

-   **Add a flag** to the subject line in the following special cases:

    - `BREAKING`: Breaking change to external API. Automated tools may bump major version of next release in response.

    - `EXPERIMENT`: Experimental change expected to be reverted. May include experimental user-facing features.

    - `INCOMPAT`: Internal breaking change (function signature, schema, data structure). May break other changes being introduced in parallel branches, but no impact on users.

    - `TEMPORARY`: Temporary commit that will be reverted (eg. debug logging). SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor repositories.

    - `WIP`: Work-in-progress that breaks the build. SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor repositories.

## Examples

Minimal (subject line only):

```
feature: add git uncommit
fix: handle empty repository in git-amend
refactor: simplify test repo interface
format: apply prettier to src
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

## Success criteria

-   **Subject line passes the validation regex.**

    Test against `^((chore|feature|fix|format|maintenance|merge|performance|refactor|release|revert|step): [a-z].*)$` before considering the message done.

-   **Type semantics fit the changeset.**

    Re-read the type's description above. If two types feel applicable, consult the *Subtle distinctions* note — that's where the hard cases are resolved.

-   **Subject line length is within budget.**

    ≤50 characters preferred, ≤72 characters maximum. Includes the optional flag.

-   **No Conventional Commits artefacts.**

    No scope parentheticals (`feature(parser): …`), no leading `!`, no trailing `:` artefacts. The colon comes immediately after the type, nothing else.

## References

- This skill is based on [TS-3: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/003).

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commit-messages) is used to validate commit messages against the conventions described in TS-3 and this skill.
