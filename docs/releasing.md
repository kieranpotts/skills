# Releasing

These skills are continuously released. The `HEAD` commit of the `latest/dev`
branch is always the current production-ready release.

Version tags are used only to mark important milestones in this project's
history.

## Steps

1.  **Determine the version number.**

    Use [Semantic Versioning](https://semver.org/) – `MAJOR.MINOR.PATCH`.

    - `PATCH`: Backwards-compatible bug fixes.
    - `MINOR`: New skills or extensions to existing ones.
    - `MAJOR`: Removal of existing skills.

    For the purpose of this skills collection, changes to an existing skill
    that are expected to change the behavior of agents are NOT considered to be
    breaking changes. The `MAJOR` version number should be bumped only when
    skills are removed from the collection.

2.  **Update `CHANGELOG.md`.**

    Add a new section at the top of the file for the release. Example:

    ```md
    ## [0.0.0] - YYYY-MM-DD

    - step: increment toward new feature - EXPERIMENT
    - maintenance: update dependencies
    - fix: fix a bug - INCOMPAT
    - chore: update README
    - refactor: refactor code
    - quality: cut p95 latency on the search endpoint
    ```

    Commit the changelog update:

    ```sh
    git add CHANGELOG.md
    git commit -m "release: v<version>"
    ```

3.  **Tag the release.**

    ```sh
    git tag -a v<version>
    ```

4.  **Write a release message.**

    ```
    v0.0.0

    - step: increment toward new feature - EXPERIMENT
    - maintenance: update dependencies
    - fix: fix a bug - INCOMPAT
    - chore: update README
    - refactor: refactor code
    - quality: cut p95 latency on the search endpoint
    ```

5.  **Push the commit and its tag to the remote.**

    ```sh
    git push --follow-tags
    ```

The release workflow in GitHub Actions will automatically generate a new
GitHub release from the version tag.
