---
name: chronicle
description: >-
  Write or update the "unreleased" section of the project's changelog, so that
  it summarizes the headline changes committed since the delivery pipeline's
  last release tag, in sentences written for the software's end users. Use
  when notable changes have been committed, before preparing a release, or when
  the user says something like "update the changelog", "write the changelog
  entries", or "bring the changelog up to date". Do not use it to promote the
  "unreleased" section to a released version, to edit released sections, or to
  commit the changelog.
compatibility: >-
  requires Bash (git status, git rev-parse, git worktree, git fetch,
  git describe, git log, git diff), Edit, Glob, Grep, Read
license: CC0-1.0
---

# Chronicle

Reconcile the changelog's "unreleased" section with the commits made since the
delivery pipeline's last release, until it gives end users a true account of the
headline changes in the next release. Edit the changelog, and nothing else, and
leave the edits uncommitted in the development trunk's worktree.

## Parameters

Determine the following information from the session context, the current
working directory, and the local environment. You MUST NOT prompt the user for
clarification on this task's requirements. If you cannot determine the
requirements, stop and report.

Assume every Git repository is laid out as a bare clone in a `.bare` directory,
with each of its worktrees checked out in a directory beside it, eg.
`<project>/.bare`, `<project>/default`, and `<project>/latest-temp-41-auth-fixes`.
If this structure does not exist, stop and report.
Every repository this task needs MUST already be checked out on disk in this
layout. Never clone, download, or copy one to a new location. If one is missing,
stop and report.

If the current working directory sits inside a worktree, that is the target
worktree that you will work in. Otherwise try to identify the target worktree
from the session context, perhaps a path the user named. Else fallback to using
the `default` worktree, which is used to check out the repository's default branch.
If the `default` worktree does not exist, stop and report.
Artifact stores, such as specifications, designs, decision records, and audit
reports, are Git repositories too, or directories inside one. Where a store is a
separate repository, work in its `default` worktree unless the session context
names another, and follow whatever conventions the store documents for itself.

- **The current worktree — REQUIRED.** The target worktree, as resolved above.
  If there is no target worktree, or its repository is not laid out as above,
  stop and report.

- **The delivery pipeline — OPTIONAL.** This is usually a major version number
  like "v1" or "v2", or the word "latest". It may be unnamed for
  continuously-released software that has a single perpetual delivery pipeline.
  Take it from the session context where it names one, eg. "update the v1
  changelog". Otherwise determine it from the branch checked out in the current
  worktree. Examples:

  - `latest/dev` → "latest"
  - `v1/temp/42-fix-auth` → "v1"
  - `dev` → unnamed pipeline

  Where the current worktree's `HEAD` is detached, use the pipeline of the
  branch checked out in the `default` worktree.

  The name of the delivery pipeline, if any, forms the optional
  `[<pipeline>/]` component in branch names.

- **The development trunk — REQUIRED.** The branch `[<pipeline>/]dev`. The
  changelog edits land on it, in its own worktree, whichever branch the
  current worktree has checked out.

- **The changelog — REQUIRED.** The `CHANGELOG.md` file is expected to be at the
  root of the trunk's worktree. Look for it there. If there is no such file,
  stop and report.

## Success criteria

- The "unreleased" section MUST describe every headline change committed
  between the release baseline and `HEAD`.

- The `HEAD` of every worktree MUST NOT move. You MUST NOT commit anything.

- Your edits MUST sit unstaged in the trunk's worktree, in the changelog only:
  `git -C <trunk-worktree> status --porcelain` MUST print nothing but
  ` M CHANGELOG.md`. Compared with its state before your run, the changelog
  MUST differ inside the "unreleased" section only. Every "released" section
  of the changelog MUST be byte-for-byte unchanged.

- Every other worktree MUST be as you found it.

- Your report MUST open with `updated` or `no changes`, on a line of its own,
  so an orchestrating script can read it. The second line MUST give the path
  of the trunk's worktree. After that, your report MUST list each entry added,
  revised, merged, removed, or kept in the changelog.

## Step-by-step instructions

1.  Run every Git command in the current worktree, unless a step names
    another. Where the working directory lies elsewhere, pass
    `-C <current-worktree>`, because a change of directory may not persist
    between commands.

    Check the repository layout before anything else. Stop and report unless
    `git rev-parse --path-format=absolute --git-common-dir` prints a path
    ending in `/.bare`, and the current worktree's top level, from
    `git rev-parse --show-toplevel`, sits directly in the directory that holds
    `.bare`. Call that directory `<project>`.

2.  Resolve the development trunk's worktree. In
    `git worktree list --porcelain`, it is the `worktree <path>` record with
    the line `branch refs/heads/[<pipeline>/]dev`. Where no worktree has the
    trunk checked out, create one in `<project>`, named after the branch with
    each `/` replaced by `-`:

    ```sh
    git worktree add <project>/latest-dev latest/dev
    ```

    Stop and report if the trunk's worktree is not clean. Then run every later
    command from inside it, so that `HEAD` means the trunk.

3.  Update the remote-tracking branches and tags with `git fetch origin --tags`.
    If the repository has no `origin` remote, skip the fetch, work from local
    refs, and say so in your report.

4.  Read the whole changelog, and learn its conventions and formatting before
    writing anything. The newest releases are expected to be listed first, with
    an "unreleased" section at the very top. Under each release, changelog
    entries MAY be grouped under "Added", "Changed", "Deprecated", "Removed",
    "Fixed", and "Security". For smaller releases, changelog entries may form
    a single contiguous list.

5.  Establish the release baseline. This is the delivery pipeline's most recent
    release tag reachable from `HEAD`. Release tags take the form
    `v<major>.<minor>.<patch>`. Where the pipeline is named for a version
    series, eg. "v1" or "v2.4-LTS", narrow the pattern to that series, eg.
    `v1.*` or `v2.4.*`. Otherwise match `v[0-9]*`. Exclude pre-release tags,
    which never serve as a baseline.

    ```sh
    git describe --tags --abbrev=0 --match '<pattern>' --exclude '*-*' HEAD
    ```

    If no tag matches, the delivery pipeline has not had a release yet, so
    the commit range starts at the root of its history.

6.  Gather the commits made since the baseline, leaving out merge commits,
    which carry no changes of their own.

    ```sh
    git log --no-merges --reverse --format='%h %s%n%b' <baseline>..HEAD
    ```

    Where there is no baseline, drop `<baseline>..`. Work from the commit
    messages alone, not their diffs, nor any uncommitted or untracked changes.
    Uncommitted work may never ship, and the commit message states what a
    change means in its author's words. Where a message is too thin to tell
    what changed for end users, leave the commit out and report it.

7.  Pick out the headline changes — those that end users would notice and want
    to read about. These are new capabilities, changes in behavior, deprecations,
    removals, fixes to defects in a released version, security fixes, and
    marked shifts in performance, compatibility, or supported platforms.

    Be selective, because a changelog that lists every tweak buries the
    changes that matter. Leave out minor adjustments, small fixes few end users
    would notice, and internal work such as refactoring. Always give breaking
    changes, deprecations, removals, and security fixes an entry, because end
    users may need to act on them.

    Describe the net effect of the range. Fold many commits toward one change
    into one entry, describing its final form. A defect introduced and fixed
    within the range gets no entry, and nor does a change reverted within it:
    a `revert:` commit quotes the header of the commit it reverts, and names
    its hash in a `Reverts:` footer.

    Use the commit types as hints for sorting, letting each commit's subject
    and body decide:

    | Commit                                          | Usual category                      |
    | ----------------------------------------------- | ----------------------------------- |
    | `behavior`                                      | Added, Changed, Deprecated, Removed |
    | `fix`                                           | Fixed, or Security                  |
    | `quality`                                       | Changed, or Security                |
    | `maintenance`                                   | None, unless end users see it       |
    | `step`, `refactor`, `style`, `chore`, `version` | None                                |
    | Flagged `BREAKING`                              | A breaking change                   |
    | Flagged `INCOMPAT`                              | None: internal only                 |

8.  Reconcile the "unreleased" section with the headline changes:

    - Keep an entry that is still accurate, and keep its wording too. A human
      may have written or moderated it.

    - Revise an entry whose change has since grown or been altered, and merge
      entries that turn out to describe one change.

    - Remove an entry whose change was reverted within the range, or released
      before the baseline.

    - Keep, and report, an entry that no commit in the range accounts for, for
      any other reason. A human may have written it ahead of the work.

    - Add an entry for each headline change no entry yet covers. Where there is
      no "unreleased" section, create one above the most recent released
      section, in the changelog's heading style, eg. `## [Unreleased]`.

9.  Leave the edits in the trunk's worktree. Do not stage or commit the
    changelog: committing it is a separate task, for a human or another tool to
    take on. Check `git diff -- CHANGELOG.md` to confirm that your edits fall
    inside the "unreleased" section only.

10. Report. Open with `updated` where you edited the changelog, or
    `no changes` where it was already true, then give the trunk's worktree
    path, so the caller knows where to commit. Also list any commit you left
    out where the call was close, so a human can overrule you.

## Rules

- You MUST edit the changelog only on the development trunk, so that every
  branch cut from the trunk afterwards inherits one account of the next
  release, rather than each branch carrying its own conflicting version of it.

- You MUST NOT switch the branch checked out in any worktree, and you MUST
  edit the trunk's worktree only where you found it clean: where
  `git -C <path> status --porcelain` printed nothing,
  `git -C <path> rev-parse -q --verify MERGE_HEAD` failed, and no file existed
  at `git -C <path> rev-parse --path-format=absolute --git-path SQUASH_MSG`.
  Each worktree belongs to whoever works in it, and uncommitted changes there
  are someone's work in progress, which your edits would tangle with.

- You MUST write each new or revised entry as a complete sentence, from the end
  user's side of the change: what they can now do, what behaves differently,
  or what they must change — "the API now returns 429 when a client exceeds
  its rate limit", not "add rate limiting middleware".

- An entry MUST NOT carry a commit type, a commit flag, or a commit subject
  copied verbatim. A changelog that restates `git log` adds nothing.

- An entry for a breaking change MUST say so plainly, with the changelog's own
  marker where it has one, and say what end users must do in response.

- The "unreleased" section MUST read as finished release history after every
  run, because it is promoted word for word when a version is prepared.

- You MUST NOT edit a released section. Where you find an error in one, report
  it: released sections are the permanent record of what shipped.

## Edge cases

- If the pipeline has no development trunk, ie. neither
  `refs/heads/[<pipeline>/]dev` nor `refs/remotes/origin/[<pipeline>/]dev`
  exists, then stop and report the missing trunk. Do not create one.

- If `git worktree add` refuses, eg. because the directory already exists, or
  a stale worktree record still claims the branch, then stop and report its
  output. Do not remove, move, or prune any worktree.

- If the changelog's most recent released version falls outside the
  pipeline's version series, eg. it lists 2.0.0 on `v1/dev`, then stop and
  report. The changelog and the pipeline disagree on which releases this
  branch carries.

- If the changelog lists a released version that has no tag, then stop and
  report the missing tag, rather than treat the whole history as unreleased.

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

  The steps fold into the export entry. The header-row fix gets no entry,
  because that defect never shipped. The help-text fix is too minor, and the
  refactor is invisible to end users.

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
