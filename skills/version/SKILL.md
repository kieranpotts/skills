---
name: version
description: >-
  Derive the next semantic version number from the commits made since the
  delivery pipeline's last release tag, promote the changelog's "unreleased"
  section to that version, and record both in a version commit on the
  development trunk or a work branch. Use before a release, or when the user
  says something like "bump the version" or "prepare the next version". Do
  not use it only to report what the next version would be, to apply a
  version tag, to fast-forward trunks, or to write changelog entries.
compatibility: >-
  requires Bash (git status, git rev-parse, git fetch, git describe, git tag,
  git log, git commit), Edit, Glob, Grep, Read
license: CC0-1.0
---

# Version

Work out the version number of the pipeline's next release from the commit
messages since its last release tag. Then promote the changelog's "unreleased"
section to that version, bump any version manifest, and commit the lot as
`version: <version>`.

## Parameters

Determine the following information from the session context, the current
working directory, and the local environment. You MUST NOT prompt the user for
clarification on this task's requirements. If you cannot determine the
requirements, stop and report.

- **The current worktree — REQUIRED.** The worktree to work in. If the current
  working directory sits inside a Git worktree, that is the current worktree.
  Otherwise identify the repository from the session context, eg. a path the
  user named, and use the worktree the context names, else the `default`
  worktree. The repository MUST be a bare clone in a directory named `.bare`,
  with each of its worktrees checked out in a directory beside it, eg.
  `<project>/.bare` and `<project>/default`. It MUST already exist on disk — do
  not clone an upstream repository. If no such worktree can be found, stop and
  report.

- **The delivery pipeline — OPTIONAL.** This is usually a major version number
  like "v1" or "v2", or the word "latest". It may be unnamed for
  continuously-released software that has a single perpetual delivery pipeline.
  Determine it from the branch checked out in the current worktree, which this
  task commits to. Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  If the current worktree's `HEAD` is detached, stop and report: there is no
  branch to work on.

  The name of the delivery pipeline, if any, forms the optional
  `[<pipeline>/]` component in branch names.

- **The changelog — OPTIONAL.** The file in which the project records its
  release history. Resolve it from the session context, then from the local
  environment — a convention file, a workspace manifest, an existing file such
  as `CHANGELOG.md`, `HISTORY.md`, or `CHANGES`. Do not assume a `CHANGELOG.md`
  at the repository root. Where the project keeps no changelog, skip its
  promotion.

- **Version manifests — OPTIONAL.** Files that record the project's version
  string, eg. `package.json`, `pyproject.toml`, or `Cargo.toml`. Discover them
  from the local environment. Lockfiles and generated files are not version
  manifests.

## Success criteria

- The next version MUST NOT already exist as a tag:
  `git rev-parse -q --verify refs/tags/v<version>` MUST fail.

- Exactly one new commit MUST sit on `HEAD`, with the subject
  `version: <version>`, touching the changelog and version manifests and no
  other file: check with `git show --name-only --format= HEAD`. Where there
  was nothing to edit, you MUST make no commit.

- In that commit, `git show HEAD -- <changelog>` MUST show only heading
  changes: the former "unreleased" heading renamed to the version and date,
  and a new, empty "unreleased" section above it. Every entry MUST be
  byte-for-byte unchanged.

- There MUST NOT be any new tags or branches, and the worktree MUST be clean
  after the commit: `git status --porcelain` MUST print nothing.

- Your report MUST open with the next version on a line of its own, bare, with
  no `v` prefix, eg. `1.3.0`, so a script can read it. It MUST then name the
  release baseline tag, the bump level, and the commits that decided the bump,
  by short hash and subject.

## Step-by-step instructions

1.  Run every Git command in the current worktree, unless a step names
    another. Where the working directory lies elsewhere, pass
    `-C <current-worktree>`, because a change of directory may not persist
    between commands.

    Check the repository layout before anything else. Stop and report unless
    `git rev-parse --path-format=absolute --git-common-dir` prints a path
    ending in `/.bare`, and the current worktree's top level, from
    `git rev-parse --show-toplevel`, sits directly in the directory that holds
    `.bare`.

    Then check the repository state. Stop and report if a merge, rebase,
    cherry-pick, or revert is in progress. A merge is in progress if
    `git rev-parse -q --verify MERGE_HEAD` succeeds, and a squash merge if the
    file at `git rev-parse --git-path SQUASH_MSG` exists. Check both, because
    `git status` does not report a pending squash merge.

    Stop and report if the checked-out branch is `[<pipeline>/]test`,
    `[<pipeline>/]ready`, or `[<pipeline>/]release`. Those trunks only ever
    move by fast-forward, so a commit there would strand work outside the flow
    from `dev`. Stop and report, too, if the worktree is dirty, ie. if
    `git status --porcelain` prints anything. Uncommitted changes are someone's
    work in progress, which the version commit could sweep up, and which
    makes the commit's contents harder to verify.

2.  Update the remote-tracking branches and tags with
    `git fetch origin --tags`. If the repository has no `origin` remote, skip
    the fetch, work from local refs, and say so in the report.

3.  Establish the release baseline: the pipeline's most recent release tag
    reachable from `HEAD`. Release tags take the form
    `v<major>.<minor>.<patch>`. Where the pipeline is named for a version
    series, eg. "v1" or "v2.4-LTS", narrow the pattern to that series, eg.
    `v1.*` or `v2.4.*`; otherwise match `v[0-9]*`. Exclude pre-release tags,
    which never serve as a baseline:

    ```sh
    git describe --tags --abbrev=0 --match '<pattern>' --exclude '*-*' HEAD
    ```

    If no tag matches, the pipeline has never released, and the range starts
    at the root of the history.

4.  Gather the commits made since the baseline, leaving out merge commits,
    which carry no change of their own, and commits that touch only the
    changelog, which never warrant a release on their own:

    ```sh
    git log --no-merges --reverse --format='%h %s%n%b' <baseline>..HEAD \
      -- . ':(exclude)<changelog>'
    ```

    Where there is no baseline, drop `<baseline>..`, and where there is no
    changelog, drop the pathspec. Work from the commit messages alone, not
    their diffs, nor any uncommitted or untracked changes. Each author stated
    the type and flags of their commit, and the bump rules act on those.

5.  Classify each commit by the bump it calls for. Read the type from the
    subject's `<type>:` prefix, and any flag from its ` - <FLAG>` suffix.

    | Commit                                              | Bump  |
    | --------------------------------------------------- | ----- |
    | Any type, flagged `BREAKING`                        | Major |
    | `behavior`, `fix`, `quality`                        | Minor |
    | `maintenance`, `refactor`, `style`, `chore`         | Patch |
    | `create`, `update`, `delete`                        | Patch |
    | `step`, `version`, `revert`                         | None  |

    `INCOMPAT` marks an internal breaking change, invisible to consumers, so it
    never calls for a major bump: classify the commit by its type. A
    `revert:` commit quotes the header of the commit it reverts, and names its
    hash in a `Reverts:` footer. If both commits sit in the range, disregard
    both: the change never reaches a consumer.

6.  Take the highest bump any commit calls for: major beats minor beats patch.
    Where no commit calls for a bump, stop and report the baseline tag's
    version as current, with nothing to release.

7.  Apply the bump to the baseline version by exactly 1, and reset every lower
    component to zero: a major bump takes `1.4.2` to `2.0.0`, a minor bump to
    `1.5.0`, and a patch bump to `1.4.3`. Check that no tag exists for the
    result.

8.  Promote the changelog. Rename its "unreleased" heading to the version and
    today's date, in the changelog's own heading style, eg.
    `## [1.5.0] - 2026-11-09`. Then add a new, empty "unreleased" section above
    it. Do not add, reword, reorder, regroup, or remove any entry.

9.  Set the version string in each version manifest to the new version, with no
    `v` prefix. Change that one field only.

10. Commit the changelog and manifests, and nothing else:

    ```sh
    git commit -m "version: 1.5.0" -- CHANGELOG.md package.json
    ```

    Do not bypass the project's commit hooks.
    Where a hook rejects the commit, stop and report its output, leaving the
    edits uncommitted.

11. Report. Where a call was close, eg. a commit with an unrecognized type,
    name it, so a human can overrule you.

## Rules

- You MUST derive the bump from the commit history alone, not from the user's
  prompt or the session's conversation. A version number is a promise to
  consumers about what changed, which only the commits since the last release
  can back up.

- You MUST NOT apply, move, or delete any tag. A tag marks a release, which is
  cut later, once the version commit has passed through the pipeline.

## Edge cases

- If the changelog's "unreleased" section is missing or empty, though the range
  holds commits that call for a bump, then stop and report. Do not write the
  missing entries yourself, so a human can bring the changelog up to date
  first.

- If the bump would take the version outside the pipeline's version series, eg.
  a `BREAKING` commit on the "v1" pipeline, or a minor bump on "v2.4-LTS",
  then stop and report the commits that call for it. Only a human can decide
  whether to drop the change or release it from another pipeline.

- If the pipeline has no release tags at all, then this is the first release.
  Use `1.0.0`, unless the project documents another initial version, eg.
  `0.1.0`. Where the changelog or a manifest says a version was already
  released, though no tag for it exists, stop and report the missing tag,
  rather than treat the whole history as unreleased.

- If the baseline version is `0.x.y`, then a `BREAKING` commit calls for a minor
  bump, not a major one. Version zero makes no compatibility promise, and
  moving to `1.0.0` is a human decision. Say in the report that a breaking
  change was absorbed this way.

- If a commit carries no recognizable type, then classify it from its subject
  and body by the meanings in the table, and name it in the report. Where the
  message is too thin to judge, assume a minor bump, the safer error.

- If the prompt asks for a pre-release, eg. "the next release candidate", then
  derive the release version as usual, and append `-<stage>.<n>`, eg.
  `1.5.0-rc.0`. Take `<n>` as one more than the highest existing tag for that
  version and stage, eg. `v1.5.0-rc.1` gives `rc.2`, or `0` where there is
  none. Promote and commit as for any other version.

- If the project's tags follow a scheme other than `v<major>.<minor>.<patch>`,
  eg. calendar versioning, then stop and report the scheme. These bump rules
  do not apply to it.

- If the project keeps neither a changelog nor a version manifest, then there
  is nothing to commit. Report the version, and make no commit.

## Examples

- Commits since `v1.4.2`:

  ```text
  step: extract csv writer
  behavior: add format option to export
  refactor: simplify config loader
  fix: escape apostrophes in search query
  ```

  The `behavior` and `fix` commits call for a minor bump. The changelog's
  `## [Unreleased]` heading becomes `## [1.5.0] - 2026-11-09`, under a new,
  empty `## [Unreleased]`, and the commit is `version: 1.5.0`. The report
  opens:

  ```text
  1.5.0
  ```

- Commits since `v1.4.2`, one of them breaking:

  ```text
  fix: escape apostrophes in search query
  behavior: return 429, not 503, when rate limited - BREAKING
  ```

  The next version is `2.0.0`.

- Commits since `v1.4.2`, all internal:

  ```text
  maintenance: bump typescript to 5.0
  refactor: rename user id columns - INCOMPAT
  chore: update unreleased changelog
  ```

  The changelog-only commit is left out, and `INCOMPAT` is internal. The next
  version is `1.4.3`.
