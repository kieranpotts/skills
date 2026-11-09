---
name: chronicle
description: >-
  Write or update the "unreleased" section of the project's changelog, so that
  it summarizes the headline changes committed since the last release tag, in
  sentences written for the software's end users. Use this skill when notable
  changes have been committed and are ready to integrate, before cutting a
  release, or when the user says something like "update the changelog",
  "write the changelog entries", or "bring the changelog up-to-date". Do not
  use this skill to promote the "unreleased" section to a released version, to
  edit released sections, or to commit any file other than the changelog.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (git status, git branch,
  git symbolic-ref, git describe, git log, git diff, git tag, git merge-base,
  git commit)
license: CC0-1.0
---

# Chronicle

Reconcile the changelog's "unreleased" section with the commits made since the
last release, until it gives end users a true account of the headline changes
in the next release. Work from the commit history alone: uncommitted work is
not part of any release yet.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The target repository — REQUIRED.** The Git repository containing the
  current working directory or, failing that, one named in the session
  context.

- **The delivery pipeline — REQUIRED.** The group of trunks whose releases the
  changelog records, named by the prefix those trunks share, eg. "latest" in
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

- **The changelog — REQUIRED.** The file in which the project records its
  release history. Resolve it from the session context, then from the local
  environment — a convention file, a workspace manifest, an existing file such
  as `CHANGELOG.md`, `HISTORY.md`, or `CHANGES`. Do not assume a `CHANGELOG.md`
  at the repository root. Where the project keeps no changelog, stop and report
  that there is nothing to do.

## Success criteria

- The "unreleased" section MUST describe every headline change committed between
  the delivery pipeline's release baseline and `HEAD`, and no change that falls
  short of a headline change. Any entry that no commit in that range accounts
  for MUST be named in your report.

- Where the changelog needed edits, exactly one new commit MUST sit on `HEAD`,
  with the message `chore: update unreleased changelog`, touching the changelog
  and no other file. Where it needed none, you MUST make no commit.

- `git show HEAD -- <changelog>` MUST show hunks inside the "unreleased" section
  only, and no new version heading. Every released section MUST be
  byte-for-byte unchanged.

- Every other file's state in the working tree and the index MUST be as you
  found it.

## Instructions

1.  Read the whole changelog, and learn its conventions before writing
    anything. The changelog is loosely based on Keep a Changelog: the newest
    release first, an "unreleased" section above it, and entries grouped under
    Added, Changed, Deprecated, Removed, Fixed, and Security. Treat that as a
    starting point, not a contract. Where the changelog documents a format of
    its own, or its released sections depart from Keep a Changelog — in their
    headings, in listing entries flat, in the tense and voice of entries, in
    how they mark breaking changes, or in whether entries cite issues, pull
    requests, or commits — you MUST follow the changelog. You SHOULD leave out
    any category heading that would hold no entries.

2.  Establish the release baseline, the commit at which the delivery pipeline's
    last release was cut. Each pipeline has its own releases, so you MUST take
    the baseline from the pipeline's own release tags. Do not take the
    repository's newest tag, which may belong to another pipeline.

    Match the pipeline's release tags with a pattern from the project's
    tagging convention, eg. `v*`. Where the pipeline is named for a version
    series, eg. "v1" or "v2.4-LTS", narrow the pattern to that series, eg.
    `v1.*` or `v2.4.*`. Then take the most recent matching tag reachable from
    `HEAD`:

    ```sh
    git describe --tags --abbrev=0 --match '<pattern>' HEAD
    ```

    Where no matching tag is reachable from `HEAD`, the changelog decides:

    - If the changelog lists no released versions, the project has never
      released, and the baseline is the root of the history.

    - If it lists released versions, the release commits may sit on release
      branches that never merged back. Find the pipeline's most recent release
      tag, eg. with `git tag --list '<pattern>' --sort=-v:refname`, and take
      `git merge-base HEAD <tag>` as the baseline.

    - If no tag exists for a version the changelog says was released, you MUST
      stop and report the missing tag, rather than treat the whole history as
      unreleased.

3.  Gather the commits since the baseline:

    ```sh
    git log --reverse --format='%h %s%n%b' <baseline>..HEAD
    ```

    Where the baseline is the root of the history, drop `<baseline>..` and log
    from `HEAD`.

    The range holds the delivery pipeline's own history only. A fix
    cherry-picked in from another pipeline is part of it, and you MUST treat it
    like any other commit in the range: this pipeline's end users have not yet
    had it.

    You MUST work from the commit messages alone. You MUST NOT read the diffs
    of those commits, nor any uncommitted or untracked changes in the working
    tree. Uncommitted work may never ship, so it has no place in the account of
    a release. And the changelog needs what each change means for end users,
    which the commit message states in its author's words; a diff shows only
    how the code moved. Where a message is too thin to tell what a commit
    changed for end users, leave it out and report it, rather than guess.

4.  Pick out the headline changes. A change is a headline change where end
    users would notice it and want to read about it: a new capability, a
    change in behavior, a deprecation, a removal, a fix to a defect end users
    met in a released version, a security fix, or a marked shift in
    performance, compatibility, or supported platforms.

    You SHOULD be selective. A changelog that lists every small tweak buries
    the changes that matter. Leave out minor adjustments and small fixes that
    few end users would notice, along with refactors, reformatting, test and CI
    changes, internal tooling, and contributor documentation. Breaking
    changes, deprecations, removals, and security fixes MUST always get an
    entry, however small, because end users may need to act on them.

    You MUST describe the net effect of the range, not its history. One change
    MAY span many commits — a run of incremental steps, then the commit that
    makes it usable — and SHOULD become one entry, describing its final form.
    A defect introduced and fixed within the range gets no entry, because no
    end user ever saw it. Nor does a change reverted within the range.

    Where the commits follow a typed convention, use the types to help sort and
    categorize the changes. The types are hints, and each commit's subject and
    body MUST decide. For example:

    - `behavior` usually marks something Added, Changed, Deprecated, or
      Removed.

    - `fix` usually marks something Fixed, or a Security fix for a
      vulnerability.

    - `quality` usually marks something Changed, or a Security improvement.

    - `maintenance` is usually not a headline change, except for a security
      patch or a dependency change that end users can see.

    - `step`, `refactor`, `style`, and `chore` are usually not headline
      changes.

    - A `BREAKING` flag marks a breaking change. `INCOMPAT` marks an internal
      one, which end users cannot see.

5.  Reconcile the "unreleased" section with the headline changes.

    - Keep an entry that is still accurate. You SHOULD preserve its wording: a
      human may have written or moderated it, and rewording it would churn the
      diff and override their judgment for no gain in accuracy.

    - Revise an entry whose change has since grown or been altered.

    - Merge entries that turn out to describe one change.

    - Remove an entry whose change was reverted within the range, or has
      already been released.

    - Keep and report an entry that no commit in the range accounts for, for
      any other reason. You SHOULD NOT delete it on the strength of the commit
      history alone: a human may have written it ahead of the work, and only
      they can say whether it belongs.

    - Add an entry for each headline change that no entry yet covers. Where the
      changelog has no "unreleased" section, create one directly above the most
      recent released section, in the changelog's own heading style, eg.
      `## [Unreleased]`.

    You MUST write each new or revised entry as a complete sentence, from the
    end user's side of the change, in the changelog's conventions. Say what end
    users can now do, what behaves differently, or what they must change —
    "the API now returns 429 when a client exceeds its rate limit", not "add
    rate limiting middleware". An entry MUST NOT carry a commit type, a commit
    flag, or a commit subject copied verbatim: a changelog that restates
    `git log` adds nothing a reader could not get from Git.

    Where a change is breaking, the entry MUST say so plainly, using the
    changelog's own marker where it has one, and say what end users must do in
    response.

    The "unreleased" section is promoted word for word when a release is cut, so
    it MUST read as finished release history after every run.

6.  Where the changelog now differs from `HEAD`, commit it, and only it:

    ```sh
    git commit -m "chore: update unreleased changelog" -- <changelog>
    ```

    Naming the changelog as the commit's only path leaves anything else that
    was already staged out of the commit, and still staged. You MUST use this
    message exactly, with no body. You MUST NOT bypass the project's commit
    hooks or signing configuration; where a hook rejects the commit, stop and
    report its output, leaving the changelog edits uncommitted.

7.  Report each entry you added, revised, merged, removed, or kept without a
    matching commit, with the commits it covers. You SHOULD also list any
    commit you left out where the call was close, and any whose message was
    too thin to judge, so a human reviewer can overrule you.

    Where you find an error in a released section, you MUST report it rather
    than correct it. Released sections are the permanent record of what
    shipped, so their correction is a human's call.

    Report the commit you made, if any, by its short hash.

## Edge cases

- If the prompt names a delivery pipeline that the checked-out branch does not
  belong to, eg. "the v1 pipeline" while `HEAD` is on `latest/dev`, or one the
  repository does not have, then stop and report the mismatch. Do not switch
  branches, and do not reconcile one pipeline's changelog with another's
  commits.

- If the changelog's most recent released version falls outside the
  pipeline's version series, eg. it lists 2.0.0 on `v1/dev`, then stop and
  report it. The changelog and the pipeline disagree on which releases this
  branch carries, and only a human can say which is right.

- If the changelog already carries uncommitted edits, then treat them as
  existing entries, someone's work in progress, and reconcile them like any
  other. Do not revert them. They go into the commit with your own edits, so
  name them in your report.

- If the repository holds several changelogs, and more than one needs edits,
  then commit them together in the one commit, naming each as a path.

- If the repository holds several changelogs, one per package, then reconcile
  each changelog against its own package: limit the log to the package's
  directory, eg. `git log <baseline>..HEAD -- <package-dir>`, and take its
  baseline from the package's own tags, eg. `parser@1.2.0`. Reconcile only the
  changelogs for the packages the session context names; otherwise, every
  changelog whose package has new commits.

## Examples

- Commits since the baseline, in a changelog whose released sections group
  entries under Keep a Changelog headings:

  ```text
  step: extract csv writer
  step: add json writer
  behavior: add format option to export
  fix: keep header row in json export
  behavior: return 429, not 503, when rate limited - BREAKING
  fix: escape apostrophes in search query
  fix: align columns in --help output
  refactor: simplify config loader
  ```

  The "unreleased" section they become. The steps fold into the export entry.
  The header-row fix gets no entry, because that defect never shipped. The
  help-text fix is too minor to make the headlines, and the refactor is
  invisible to end users.

  ```md
  ## [Unreleased]

  ### Added

  - The `export` command accepts a `--format` option, which writes CSV or
    JSON.

  ### Changed

  - Breaking: the API now returns 429 Too Many Requests, not 503, when a
    client exceeds its rate limit. Clients that retry on 503 should also retry
    on 429.

  ### Fixed

  - Searching for a term that contains an apostrophe no longer returns no
    results.
  ```
