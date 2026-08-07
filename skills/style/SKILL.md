---
name: style
description: >-
  Normalize the presentation of code or content — whitespace, wrapping,
  quoting, ordering — without changing structure or behavior. Use when
  normalizing style after implementing a feature, fixing a formatting-related
  CI failure, or aligning files to project conventions, or when the user says
  something like "format this file", "fix the formatting errors", or "tidy up
  the whitespace and style here". Do not use it to restructure code, rename
  anything, or edit the language of prose.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (formatter, test runner, git)
license: CC0-1.0
---

# Style

Apply presentation-only changes — whitespace, indentation, line wrapping,
quotes, trailing commas, import ordering — to code or to any other text
content, leaving behavior, structure, and meaning untouched. Normalize the
presentation and stop there: reviewing the result and integrating it are
someone else's job.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Target content — REQUIRED.** The files to normalize. Take them from the
  user's prompt, a named directory, or the current diff. Where the request
  names no set, default to the files changed in the version control working
  tree.

- **Formatter and style conventions — OPTIONAL.** The tool and settings that
  define what "formatted" means here. Discover them from the project rather
  than assuming: a formatter config file, a format script in the project's
  task runner, or a commit hook that invokes one. Where the project configures
  none, fall back to the conventions the surrounding files already follow.

- **Scope — OPTIONAL.** How wide to run: the files just touched, one
  directory, or the whole repository. Default to the narrowest scope that
  covers the target content, because a wider scope buys a noisier diff.

## Success criteria

- Every edited file MUST parse, compile, or load as it did before, and the
  project's own test command MUST pass afterwards.

- Where the pass changed only whitespace, `git diff -w` MUST report an empty
  diff. Where it also changed quoting, punctuation, or ordering, that check no
  longer applies and the test suite is the evidence.

- The diff MUST show no rename, no logic edit, no reordered parameter, and no
  moved declaration.

- Formatter configuration, lint configuration, and ignore files MUST be
  byte-identical to their prior state, so that the pass demonstrably applied
  the existing rules rather than new ones.

- Generated, transpiled, and vendored files MUST be absent from the diff.

- The result MUST be filable as a single style-typed commit per scope, with no
  feature, fix, refactor, or configuration change bundled in.

- Where any file had to be hand-formatted, a follow-up maintenance task MUST
  have been recorded in whatever issue store the project uses.

## Instructions

1.  Confirm the change is presentation only.

    Name exactly what will change: whitespace, indentation, line wrapping,
    trailing newlines, quote style, trailing commas, semicolons, import
    ordering or grouping, casing of literals, line endings, final newline,
    BOM, encoding. If you cannot describe the intended change in those terms,
    you MUST stop and re-classify the work as a structural refactor.

2.  Discover the project's formatter and run it as configured.

    Search for a formatter config file, a format script in the task runner, or
    a commit hook that invokes one. You MUST use the configured tool with its
    configured options, rather than hand-editing or passing overrides —
    otherwise the next person to run the formatter reverts your work.

3.  Fix the scope before running.

    Decide which files the run covers and hold it there. You MUST NOT let the
    formatter widen the diff into files unrelated to the target content.

4.  Verify behavior is unchanged.

    Run the project's test command after the pass. You MUST take extra care
    with significant-whitespace languages, auto-removal of side-effect
    imports, quote-style changes that fall inside string literals, and files
    a generator owns.

5.  File the change as a style-typed commit, one per scope.

    Follow whatever commit conventions the project documents. Then stop:
    reviewing the diff and integrating the branch MUST be left to the caller.

6.  Record the tooling gap, if there was one.

    Where you formatted anything by hand, you SHOULD record a follow-up
    maintenance task to add or fix the formatter config, wire it into a commit
    hook, and add a CI check that fails on unformatted content.

## Rules

- You MUST preserve behavior exactly.

  Tests MUST pass before and after, and observable output MUST be identical
  for any given input. A change that fails this test is mislabeled and does
  not belong in a style pass.

- You MUST NOT make structural edits.

  Renaming a variable, extracting a function, reordering parameters, and
  simplifying a conditional are refactors. This includes renames that look
  cosmetic: recasing `myConst` to `MY_CONST` changes identifier resolution.

- You MUST NOT edit the language of prose — spelling, grammar, wording, or
  terminology. Line wrapping and whitespace in a prose file are in scope; the
  words are not.

- You MUST NOT bundle formatting with feature, fix, or refactor work.

  Mixed commits hide the substantive change inside formatting noise and make
  history hard to read.

- You MUST NOT change formatter or lint configuration during a style pass.

  Editing the config and re-running the formatter changes two things at once.
  Split them: one maintenance change to the config, one style change applying
  it.

- You SHOULD prefer an automated formatter over hand-edits.

  A formatter applies the same rule everywhere and is reproducible, while
  hand-edits drift by author and re-emerge in the next diff. Where the project
  has no formatter, that absence is the real defect, and fixing it is
  maintenance work rather than part of this pass.

- You MUST NOT reformat generated, transpiled, or vendored files, and you
  SHOULD get such paths added to the formatter's ignore list.

  The generator or the upstream project owns their format, so any edit here is
  lost or diverges on the next update.

- You MUST run the test suite when reformatting a significant-whitespace
  language, and you MUST additionally parse or load any reformatted
  configuration file.

  Where indentation is syntax — Python, YAML, Make, and similar — even a
  re-indent that looks harmless can change meaning.

- The diff SHOULD be visually large but semantically empty. A reviewer
  skimming it SHOULD find nothing that changes what the code does.

## Edge cases

- The formatter wants to rewrite a file your change just touched.

  Format the file first, as its own style change on the branch, then make the
  behavior change against the now-canonical baseline. Reviewers get two clean
  diffs instead of one noisy one.

- The formatter and a linter disagree.

  Pick one as authoritative — usually the formatter for whitespace and the
  linter for everything else — and configure the linter to drop the
  overlapping rules. That configuration change is maintenance work, so it MUST
  NOT ride along in the style change.

- The change is enormous because the content was never formatted.

  A one-off big-bang reformat is acceptable when adopting or upgrading a
  formatter. Land it as a single style change on its own, and record its
  commit identifier in the repository's blame-ignore file so history stays
  navigable.

- Formatting would fix a CI failure.

  Fix the formatting, then check whether the same check runs locally as a
  commit hook. Where it does not, record that gap as maintenance work:
  discovering formatting errors at push time is avoidable friction.

## Examples

- A clean formatting change following a feature:

  ```text
  feature: add bulk export endpoint     # the behavior change
  style:   apply the formatter to the handlers directory
  ```

  The first shows the logic. The second is reviewable in seconds.

- Catching a behavior change pretending to be style:

  ```text
  While formatting the auth module, `_normalize_token` had been renamed to
  `normalize_token`. That alters the module's public surface, so it is a
  refactor. Reverted the rename and recorded it as follow-up refactor work.
  ```

## References

- [TS-9: Version control](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/009/AGENTS.md) \
  Read before filing the change, for the commit types and message conventions
  this skill relies on.

- [TS-27: Markdown](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/027/AGENTS.md) \
  Read when normalizing Markdown content and the project configures no
  formatter for it.
