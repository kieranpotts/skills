---
name: commits
description: Commit-message format enforced by CI, and the semantics of each allowed type.
compatibility: requires git
license: MIT
---

# Commits

Use this skill when composing a commit message, validating a branch's messages before push, or troubleshooting a failed `commit-validation` CI job.

Do NOT use this skill for branch-naming conventions or PR titles.

## Instructions

1.  **Use this exact format**

    ```
    <type>: <description>

    [<body>]

    [<footers>]
    ```

    Validation regex (only the subject line is checked):

    ```
    ^((chore|feature|fix|format|maintenance|merge|performance|refactor|release|revert|step): [a-z].*)$
    ```

2.  **Follow these rules**

    - `<type>` must be one of the eleven literal strings above.

    - `<description>` must begin with a lowercase letter and use imperative mood (eg. "add", not "added").

    - No period at the end of the description.

    - Optional flag MAY be appended - `<type>: <description> - <flag>` where `<flag>` is one of: `BREAKING`, `INCOMPAT`, `WIP`, `EXPERIMENT`, `TEMPORARY`.

    - Header (type + description + flag) SHOULD NOT exceed 50 characters and MUST NOT exceed 72 characters.

    - Bodies and footers are optional but encouraged.

    - Scopes/parentheticals (`feature(parser): …`) fail validation - the regex expects the colon immediately after the type.

3.  **Pick the commit type by the semantics of the changeset**

    - `feature`: User-facing operation or behavior change (new commands, flags, endpoints, features, deprecations, removals).

    - `fix`: Resolves a defect - bug, regression, vulnerability, or incident (including silencing spurious error log entries).

    - `performance`: External runtime optimization - observable and measurable outside the system (latency, throughput, resource utilization, security, compliance).

    - `step`: Incremental change toward a larger feature or fix that is not yet user-facing. Building block in multi-commit implementation.

    - `refactor`: Improves internal structure without changing features or degrading performance (renames, helper extraction, simplifying interfaces, restructuring data flows).

    - `format`: Presentation-only code changes — whitespace, indentation, line wrapping, style. Distinct from `refactor`.

    - `maintenance`: Required upkeep - dependency bumps, test improvements, CI workflow reconfig, documentation, security patches.

    - `chore`: Small, insignificant housekeeping - typo fixes, comment tweaks, non-production artifacts. Typically no peer review needed.

    - `release`: Version bumps and release-preparation commits.

    - `merge`: Merge commits (when not fast-forwarded).

    - `revert`: Reverting a prior commit.

    **Distinction**: `step` is for incomplete work toward a user-facing change; `refactor` is for internal structural improvements; `format` is pure code presentation (non-structural); `maintenance` is infrastructure/dependencies; `chore` is small non-code tasks.

4.  **Validate locally before pushing** (there is no pre-commit hook):

    ```sh
    git log --format=%s origin/dev..HEAD | \
      grep -Ev '^(chore|feature|fix|format|maintenance|merge|performance|refactor|release|revert|step): [a-z]'
    ```

    Empty output means all commits will pass.

    Substitute `origin/dev` if the checked-out branch is different.

5.  **Body and footers - OPTIONAL**

    - **Body**: Use this to explains the _why_ of the change, not the _what_. Separate from header with a blank line. Proper English sentences. Wrap lines at 72 characters.

    - **Footers**: Key-value pairs like `Closes: #123`, `Refs: #456`, `Reviewed-by: Name <email>`. Separated from body by a blank line.

6.  **Flags for special commits - OPTIONAL**

    - `WIP`: Work-in-progress that breaks the build. SHOULD NOT be pushed to `origin/dev` or other trunks in multi-contributor repositories.

    - `BREAKING`: Breaking change to external API. Automated tools may bump major version.

    - `INCOMPAT`: Internal breaking change (function signature, schema, data structure). May break other changes being introduced in parallel branches.

    - `EXPERIMENT`: Experimental or temporary change expected to be reverted.

    - `TEMPORARY`: Temporary commit that will be reverted (eg. debug logging).

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

## House rules

- **Imperative mood**: Commit `<description>` and body must be written in the impertive mood, which usually means starting with a verb - "add" not "added" or "adds".

- **Header length**: SHOULD NOT exceed 50 characters; MUST NOT exceed 72. But don't truncate if doing so reduces clarity.

- **Atomic commits**: One logical change per commit. Large work is split into multiple `step:` commits. `feature:` work may bundle logically related changes.

- **Capital letters in the `<description>` fails validation**, but the body text should be written in proper English sentences.

- **`feature(scope): …` fails validation.** Scopes – popularized by Conventional Commits – are not supported by the commit convention described in this skill.

- **Alternative types for non-executable source.** If this repository contains documentation, specifications, or other non-code artifacts, use `add`, `edit`, `remove`, `restructure`, `format` instead of `feature`, `fix`, `step`, `refactor`.

## References

- This skill is based on [TS-3: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/003).

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commits) is used to validate commit messages against the conventions described in TS-3 and this skill.
