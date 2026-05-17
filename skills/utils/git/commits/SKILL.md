---
name: commits
description: Commit message format. Semantics of commit types.
compatibility: requires git
license: MIT
---

# Commits

Use this skill when composing a commit message, validating a branch's messages before push, or troubleshooting a failed `commit-validation` CI job.

Do NOT use this skill for branch-naming conventions or PR titles.

## Instructions

1.  **Use this exact format**:

    ```
    <type>: <description>

    [<body>]

    [<footers>]
    ```

    Validation regex (only the subject line is checked):

    ```
    ^((chore|feature|fix|format|maintenance|merge|performance|refactor|release|revert|step): [a-z].*)$
    ```

    For repositories that contain only documentation, specifications, or other non-source/non-executable artifacts, use this regex to validate the subject line:

    ```
    ^((add|edit|fix|remove|restructure|format|chore|release|merge|revert): [a-z].*)$
    ```

2.  **Follow these rules**:

    - `<type>` MUST be one of these literal strings:

        - `add`
        - `chore`
        - `edit`
        - `feature`
        - `fix`
        - `format`
        - `maintenance`
        - `merge`
        - `performance`
        - `refactor`
        - `release`
        - `remove`
        - `revert`
        - `step`

    - `<description>` MUST be full lowercase and use the imperative mood (eg. "add", not "added" or "adds").

    - No period at the end of the description.

    - Optional flag MAY be appended - `<type>: <description> - <flag>` where `<flag>` is one of:

        - `BREAKING`
        - `EXPERIMENT`
        - `INCOMPAT`
        - `TEMPORARY`
        - `WIP`

    - Header (type + description + flag) SHOULD NOT exceed 50 characters and MUST NOT exceed 72 characters.

    - Commit message convention is NOT compatible with Conventional Commits. Scopes/parentheticals (`feature(parser): …`) fail validation. The regex expects the colon immediately after the type.

    - Bodies and footers are OPTIONAL and do not require validation.

        - Use the body to explain the _why_ of the change, not the _what_. Separate from header with a single blank line. Proper English sentences. Markdown formatting allowed, but prefer plain text. Wrap lines at 72 characters.

        - The footer section is a contiguous block consisting of key-value pairs, one per line, like `Closes: #123`, `Refs: #456`, `Reviewed-by: Name <email>`. Separated from body by a single blank line.

## Rules

-   **Atomic commits.**

    One logical change per commit. Split large changes into multiple `step:` commits.

    `feature:` and `performance:` work may bundle logically related changes.

-   **Pick the most appropriate commit type.**

    Choice based on the semantics of the changeset being committed:

    - `add`: Use only for documentation/specifications repositories. Add new content.

    - `chore`: Small, insignificant housekeeping - typo fixes, comment tweaks, non-production artifacts. Typically no peer review needed.

    - `edit`: Use only for documentation/specifications repositories. Change existing content.

    - `feature`: User-facing operation or behavior change (new commands, flags, endpoints, features, deprecations, removals).

    - `fix`: Resolves a defect - bug, regression, vulnerability, or incident (including silencing spurious error log entries).

    - `format`: Presentation-only code or content changes — whitespace, indentation, line wrapping, style. Distinct from `refactor`.

    - `maintenance`: Required upkeep - dependency bumps, test improvements, CI workflow reconfig, documentation, security patches.

    - `merge`: Merge commits (when not fast-forwarded).

    - `performance`: External runtime optimization - observable and measurable outside the system (latency, throughput, resource utilization, security, compliance).

    - `refactor`: Improves internal structure without changing features or degrading performance (renames, helper extraction, simplifying interfaces, restructuring data flows).

    - `release`: Version bumps and release-preparation commits.

    - `remove`: Use only for documentation/specifications repositories. Delete existing content.

    - `revert`: Reverting a prior commit.

    - `step`: Incremental change toward a larger feature or fix that is not yet user-facing. Building block in multi-commit implementation.

    *Subtle diistinctions*: `step` is for incomplete work toward a user-facing `feature` or `performance` change. `refactor` is for higher-level internal structural improvements, while`format` is for lower-level code presentation improvements. `maintenance` is for updating things like infrastructure configuration and dependencies, while `chore` is general repository housekeeping that does not touch any code or configuration, eg. edits to READMEs and other documentation.

-   **Add a flag** to the subject line in the following special cases:

    - `BREAKING`: Breaking change to external API. Automated tools may bump major version of next release in response.

    - `EXPERIMENT`: Experimental change expected to be reverted. May include experimental user-facing features.

    - `INCOMPAT`: Internal breaking change (function signature, schema, data structure). May break other changes being introduced in parallel branches, but no impact on users.

    - `TEMPORARY`: Temporary commit that will be reverted (eg. debug logging). SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor repositories.

    - `WIP`: Work-in-progress that breaks the build. SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor repositories.

## Examples

Minimal (header only):

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

## References

- This skill is based on [TS-3: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/003).

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commits) is used to validate commit messages against the conventions described in TS-3 and this skill.
