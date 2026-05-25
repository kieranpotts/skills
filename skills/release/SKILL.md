---
name: release
description: Release branching and tagging conventions.
compatibility: requires git
license: MIT
---

# Releases

Use this skill when preparing releases, creating release branches, or tagging release versions.

Do NOT use this skill for commit message conventions or general branch naming.

## Instructions

Choose one release strategy:

-   A single **release trunk**:

    For continuous deployment. Naming convention:

    ```
    release
    ```

-   Multiple **release branches**:

    For release trains and big-bang releases. Naming convention:

    ```
    release/<version>
    ```

Validation regex (for both):

```
^release(\/[0-9]+\.[0-9]+\.[0-9]+)?$
```

## Rules

-   **Release trunk** (`release`):

    - Permanent trunk, auto-promoted from `ready` when verified.

    - The tip commit is always a candidate for production deployment.

    - References pre-built artifacts in external artifact registries.

-   **Release branches** (`release/<version>`):

    - Cut from `ready` trunk tip: `git checkout -b release/<version> ready`.

    - Temporary. Deleted after tagging and successful deployment pipeline.

    - Contains only release-preparation commits: version bumps, changelog updates, release-specific config.

    - Tag with version: `git tag -a v<version> -m "<release_notes>"`.

    - Build artifacts stored in external artifact registry, indexed by tag.

    - If preparation fails, abandon branch and start over.

    - Never commit fixes to release branches. Fixes MUST flow through `dev` → `ready` → new release branch.

    - Placeholder name `release/next` allowed if version not yet decided.

-   **General**:

    - All releases cut from `ready` trunk, the tip of which is guaranteed to always contain pristine, production-grade artifacts.

    - Development continues unblocked during release preparation (no code freezes).

    - Compiled artifacts are shipped to external artifact registries (Docker, npm, PyPI, S3, etc.), never to the Git repository.

    - Version tags are permanent. Reference them in external artifact repos for traceability.

## Examples

Release trunk:

```
release
```

Release branches:

```
release/1.2.0
release/2.0.0
release/next
```

Version tags:

```
v1.2.0
v2.0.0
```

## References

- This skill is based on [TS-3: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/003), specifically the "Releases" section.
