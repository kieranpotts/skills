---
name: version
description: >-
  Determine the next semantic version number for a delivery pipeline, from the
  commits accumulated since that pipeline's last release tag. Use this skill
  before cutting a release, or when the user says something like "what's the
  next version?", "work out the next version number", or "what would the v1
  pipeline release next?". Do not use this skill to apply a version tag, edit a
  version manifest, cut a release branch, or write changelog entries.
compatibility: >-
  requires Read, Glob, Grep, Bash (git fetch, git branch, git symbolic-ref,
  git describe, git tag, git log, git merge-base, git rev-parse)
license: CC0-1.0
---

# Version

Work out the version number that a delivery pipeline's next release will take,
by reading the commit messages since the pipeline's last release tag. Report the
version and how you derived it. You MUST NOT create tags, branches, or commits,
nor edit any file.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The target repository — REQUIRED.** The Git repository containing the
  current working directory or, failing that, one named in the session
  context.

- **The delivery pipeline — REQUIRED.** The group of trunks whose next release
  is being versioned, named by the prefix those trunks share, eg. "latest" in
  `latest/dev`. A project MAY run several pipelines in parallel, eg. "latest"
  for v2 and "v1" for a maintained older version, each with its own releases.
  List the pipelines' development trunks with
  `git branch --remotes --list 'origin/dev' 'origin/*/dev'`. Each trunk's
  pipeline is the part between `origin/` and `/dev`. If the most-recent user
  prompt names a pipeline, eg. "the v1 pipeline", use that. Else, where the
  checked-out branch's name starts with a listed pipeline's prefix, eg.
  `latest/temp/42-fix-auth`, take that pipeline. Else take the pipeline of the
  repository's default branch, read with
  `git symbolic-ref --short refs/remotes/origin/HEAD`. A project with
  unprefixed trunks, or none, eg. a lone `main`, runs one unnamed pipeline.

- **The release revision — OPTIONAL.** The commit the next release would be cut
  from. Use a branch or commit named in the most-recent user prompt. Else take
  the tip of the pipeline's release-ready trunk, conventionally
  `origin/[<pipeline>/]ready`, eg. `origin/latest/ready`, because only that
  trunk holds the revisions a release is cut from. Where the pipeline has no
  release-ready trunk, take its development trunk, eg. `origin/latest/dev`,
  or a lone `main`.

- **The versioning scheme — OPTIONAL.** Where the project documents its own
  versioning rules, eg. in a convention file or contributing guide, follow
  them where they differ from the rules below. Otherwise apply the rules below,
  which are Semantic Versioning 2.0.0 with commit-type mappings.

## Success criteria

- The report MUST open with the next version on a line of its own, bare, with
  no `v` prefix, eg. `1.3.0`, so a script or orchestrator can read it.

- The report MUST name the release baseline tag, the release revision, the bump
  level, and the commit or commits that decided the bump, by short hash and
  subject.

- The next version MUST NOT already exist as a tag. Check with
  `git rev-parse -q --verify refs/tags/v<version>`, which MUST fail.

- The repository MUST be as you found it, apart from remote-tracking refs and
  tags fetched from `origin`. There MUST NOT be any new tags of your own, nor
  new branches, commits, or edits to tracked or untracked files.

## Instructions

1.  Bring the repository's view of the remote up-to-date, so the baseline is
    not taken from stale tags:

    ```sh
    git fetch origin --tags
    ```

2.  Learn the project's tagging convention from its existing tags, eg.
    `git tag --list --sort=-v:refname | head -20`. The default convention is
    `v<major>.<minor>.<patch>`, so the release tag pattern is `v[0-9]*`. Where
    the pipeline is named for a version series, eg. "v1" or "v2.4-LTS", narrow
    the pattern to that series, eg. `v1.*` or `v2.4.*`.

3.  Establish the release baseline, the most recent release tag of the
    pipeline. Each pipeline has its own releases, so you MUST take the baseline
    from the pipeline's own tags, reachable from the release revision. Do not
    take the repository's newest tag, which may belong to another pipeline.
    Exclude pre-release tags, which never serve as a baseline:

    ```sh
    git describe --tags --abbrev=0 --match '<pattern>' --exclude '*-*' <revision>
    ```

    Where no matching tag is reachable from the release revision, the release
    commits may sit on release branches that never merged back. Find the
    pipeline's most recent release tag with
    `git tag --list '<pattern>' --sort=-v:refname`, ignoring pre-release tags.
    Take that tag's version as the baseline version, and
    `git merge-base <revision> <tag>` as the commit the range starts from.

4.  Gather the commits made since the baseline, leaving out merge commits,
    which bring in commits that the range already holds:

    ```sh
    git log --no-merges --reverse --format='%h %s%n%b' <baseline>..<revision>
    ```

    You MUST work from the commit messages alone. You MUST NOT read the diffs,
    nor any uncommitted or untracked changes in the working tree. Each commit's
    author stated its type and flags in its message, and the bump rules below
    act on those, so classifying commits from their diffs would only second
    guess the author. Uncommitted work is not part of any release.

5.  Classify each commit by the bump it calls for. Read the type from the
    `<type>:` prefix of the subject line, and the flag from its
    ` - <FLAG>` suffix.

    - Major. Any commit flagged `BREAKING`, whatever its type. A breaking change
      is one that requires a consumer to take action to avoid disruption,
      including a required configuration change, even where the programmatic
      contract is unchanged.

    - Minor. Commits of type `behavior`, `fix`, or `quality`. These are the
      user-facing changes the version number communicates to consumers: new
      features, deprecations, bug fixes, and runtime-quality improvements.

    - Patch. Commits of type `maintenance`, `refactor`, `style`, or `chore`.
      These are internal changes that leave the user-visible contract alone.

    - None. Commits of type `step` or `version`, and reverts. These are
      version-neutral.

    A commit flagged `INCOMPAT` is an internal breaking change, invisible to
    consumers. It MUST NOT, on its own, call for a major bump; classify it by
    its type, as above.

6.  Take the highest bump that any commit calls for: major beats minor beats
    patch. Where no commit calls for a bump, there is nothing to version: stop
    and report the baseline tag as the current version.

7.  Apply the bump to the baseline version, by exactly 1, and reset every lower
    component to zero:

    - Major: `1.4.2` becomes `2.0.0`.

    - Minor: `1.4.2` becomes `1.5.0`.

    - Patch: `1.4.2` becomes `1.4.3`.

8.  Check the result against the pipeline's version series, and against the
    existing tags, as the success criteria require. Then report, opening with
    the bare version number. Where a call was close, eg. a commit with an
    unrecognized type, name it, so a human reviewer can overrule you.

## Rules

- You MUST derive the bump from the commit history alone. Do not take the
  version, or the bump level, from the user's prompt or the session's
  conversation. A version number is a promise to consumers about what changed,
  which only the commits since the last release can back up.

- You MUST NOT apply, move, or delete any tag. Tags are permanent once pushed,
  and tagging is the release step's job, not this skill's.

- You MUST NOT edit a version manifest, eg. `package.json` or `pyproject.toml`,
  nor the changelog, even where it disagrees with the version you derived.
  Report the disagreement instead.

- You MUST NOT version one pipeline's release from another pipeline's tags or
  commits.

## Edge cases

- If the prompt names a delivery pipeline that the repository does not have,
  then stop and report it. Do not fall back to another pipeline.

- If the bump would take the version outside the pipeline's version series,
  eg. a `BREAKING` commit on the "v1" pipeline, or a minor bump on
  "v2.4-LTS", then stop and report the commits that call for it. The next
  version belongs to another pipeline, and only a human can decide whether to
  drop the change or release it elsewhere.

- If the pipeline has no release tags at all, then this is the first release.
  Report `1.0.0`, unless the project documents a different initial version, eg.
  `0.1.0` for a prototype. Where a version manifest or the changelog says a
  version was already released, though no tag for it exists, stop and report
  the missing tag rather than treat the whole history as unreleased.

- If the baseline version is `0.x.y`, then a `BREAKING` commit calls for a
  minor bump, not a major one, and every other bump applies as usual. Version
  zero makes no compatibility promise, and moving to `1.0.0` is a human
  decision. Report that a breaking change was absorbed this way.

- If the release revision already carries a release tag, eg.
  `git describe --tags --exact-match <revision>` succeeds, then there is
  nothing new to version. Stop and report the existing tag.

- If a commit in the range reverts another commit in the range, then disregard
  both. The reverted change never reaches a consumer. Recognize a revert by
  Git's default `Revert "<subject>"` message, and its
  `This reverts commit <hash>.` line in the body.

- If the commits follow a different typed convention, eg. Conventional Commits,
  then map its types by meaning. For Conventional Commits, `feat`, `fix`, and
  `perf` call for a minor bump, a `!` after the type or a `BREAKING CHANGE:`
  footer calls for a major bump, and `revert` is version-neutral. Every other
  type calls for a patch bump.

- If a commit carries no recognizable type, then classify it from its subject
  and body by the meanings given in the instructions, and name it in your
  report. Where the message is too thin to judge, assume a minor bump, the
  safer error, and say so.

- If the prompt asks for a pre-release version, eg. "the next release
  candidate", then derive the release version as usual, and append
  `-<stage>.<n>`, eg. `1.5.0-rc.0`. Take `<n>` as one more than the highest
  existing tag for that version and stage, eg. `v1.5.0-rc.1` gives `rc.2`, or
  `0` where there is none.

- If the project's tags follow a scheme other than Semantic Versioning, eg.
  calendar versioning, then stop and report the scheme. These rules do not
  apply to it.

- If the repository has no `origin` remote, then skip the fetch, work from the
  local branches and tags, and say so in your report.

## Examples

- Commits since `v1.4.2` on `latest/ready`:

  ```text
  step: extract csv writer
  behavior: add format option to export
  refactor: simplify config loader
  fix: escape apostrophes in search query
  ```

  The `behavior` and `fix` commits call for a minor bump. The report opens:

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
  step: refactor database layer - INCOMPAT
  chore: fix typo in readme
  ```

  The `INCOMPAT` flag is internal, so it calls for no major bump. The next
  version is `1.4.3`.
