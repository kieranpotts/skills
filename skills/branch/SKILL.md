---
name: branch
description: Branching conventions. Branch naming format.
compatibility: requires git
license: MIT
---

# Branches

Use this skill when creating a new branch, or validating branch names before push.

Do NOT use this skill for commit message conventions or PR titles.

Do NOT use this skill for preparing or tagging releases.

## Instructions

1.  **Use one of these formats:**

    *Permanent trunks:*

    ```
    dev
    test
    ready
    ```

    *Short-lived temporary branches:*

    ```
    temp/[<id>-]<description>
    ```

    *Long-lived epic branches:*

    ```
    epic/[<id>-]<description>
    ```

    Validation regex (for all branch types):

    ```
    ^(dev|test|ready|temp/[a-z0-9]+(-[a-z0-9]+)*|epic/[a-z0-9]+(-[a-z0-9]+)*)$
    ```

2.  **Follow these rules:**

    - Branch names MUST be lowercase.

    - For `temp/*` and `epic/*` branches, use hyphen-delimited descriptions (kebab-case) - REQUIRED.

    - No underscores or spaces in branch names.

    - The OPTIONAL `<id>` typically corresponds to an issue number or tracking system identifier.

    - Temporary and epic branches SHOULD NOT exceed 50 characters total, and MUST NOT exceed 72.

## Rules

-   **Trunk branches:**

    Trunks are permanent, append-only, and immutable. There are up to three trunks:

    - `dev`: The primary integration trunk. All work originates here. This is the only REQUIRED branch. Most projects should use `dev` as their default branch.

    - `test`: OPTIONAL QA trunk. Fast-forwarded to stable commits on `dev` for comprehensive testing (integration tests, system tests, performance tests).

    - `ready`: OPTIONAL production-grade trunk. Fast-forwarded to passing commits on `test`. Always shippable, enabling continuous delivery.

-   **Temporary branches:**

    Temporary branches (`temp/*`) are short-lived and capture single-focused changes spanning a small number of commits. Commonly associated with an issue/bug. Follow these rules:

    - Cut from `dev`, never from `test`, `ready`, or release branches.

    - Valid use cases: bugs and other issues that span multiple atomic commits; experiments, proofs-of-concept, and technical spikes; backup of in-progress work.

    - One logical change per temporary branch. Multiple orthogonal changes SHOULD NOT be combined into a single temporary branch.

    - Use rebase-up strategy to keep synchronized with `dev`.

    - Reintegrate with `dev` using fast-forward merge.

    - Delete after integration. The commit history is preserved in `dev`.

-   **Epic branches:**

    Epic branches (`epic/*`) are long-lived branches for multi-developer coordination on complex changes. Rules:

    - Cut from `dev`, like temporary branches.

    - Valid use cases: large coordinated features spanning weeks/months, and which can't easily be continuously integrated into the `dev` trunk but toggled off; major refactoring and replatforming initiatives; cross-cutting concerns; long-running research work; other highly disruptive or volatile changes.

    - Use merge-down strategy: synchronize by merging `dev` into the epic branch (never rebase). This is safer for long-lived branches with multiple contributors since it preserves the history of the branch.

    - Reintegrate with `dev` using squash-merge strategy.

    - Delete after integration into `dev`.

-   **General practices:**

    - All changes originate on `dev` and flow forward through `test` → `ready` → release.

    - Trunk branches are fixed-forward only. If a problem is discovered downstream, the fix must be committed to `dev` and flow forward from there - no direct commits to downstream trunks.

    - Periodically review stale `temp/*` and `epic/*` branches with no commits in ~90 days and delete or revive them.

## Examples

Trunk branches:

```
dev
test
ready
```

Temporary branches:

```
temp/42-add-search-endpoint
temp/178-fix-auth-timeout
temp/TS-504-migrate-user-schema
temp/update-dependencies
```

Epic branches:

```
epic/billing-v2-rewrite
epic/PRODUCT-187-auth-overhaul
epic/infra-migrate-kubernetes
epic/major-ui-redesign
```

## References

- This skill is based on [TS-3: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/003), specifically the "Branches" section.
