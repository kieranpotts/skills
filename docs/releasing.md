# Releasing

Releases are cut directly from the `dev` trunk and tagged with a semantic
version number.

Releases are for the maintainer's benefit only — to mark significant milestones
in the project's history. They have no effect on installation behavior.

## Steps

1.  **Determine the version number.**

    Use [Semantic Versioning](https://semver.org/) –
    `MAJOR.MINOR.PATCH`:

    - `PATCH`: Backwards-compatible bug fixes.
    - `MINOR`: New skills or backwards-compatible additions.
    - `MAJOR`: Breaking changes to existing skill interfaces or conventions.

2.  **Update `CHANGELOG.md`.**

    Add a new section at the top of the file for the release.

    ```md
    ## [0.0.0] - YYYY-MM-DD

    - step: increment toward new feature - EXPERIMENT
    - maintenance: update dependencies
    - fix: fix a bug - INCOMPAT
    - chore: update README
    - refactor: refactor code
    - runtime: cut p95 latency on the search endpoint
    ```

    Commit the changelog update:

    ```sh
    git add CHANGELOG.md
    git commit -m "release: v<version>"
    ```

3.  **Tag the release.**

    ```sh
    git tag -a v<version> -m "v<version>"
    ```

4.  **Push the commit and its tag to the remote.**

    ```sh
    git push --follow-tags
    ```
