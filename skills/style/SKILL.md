---
name: style
description: >-
  Apply presentation-only code or content changes — whitespace, indentation,
  line wrapping, quotes, trailing commas, import ordering — without altering
  behavior or structure. Prefer automated formatters configured at the project
  level. Use when normalizing style after a feature, fixing CI lint failures, or
  aligning a file to project conventions — distinct from structural improvements
  to the code — or when the user says "format this file", "fix the formatting /
  lint errors", or "tidy up the whitespace and style here".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programmer
---

# Style

Apply presentation-only code or content changes — whitespace, indentation, line
wrapping, quotes, trailing commas, import ordering — without altering behavior
or structure.

**Input:**

- **The code or content to normalize. REQUIRED.** A set of files, a diff, or
  the working tree.

- **The configured formatter and style conventions. REQUIRED.** The project's
  formatter and style conventions, where they exist.

You MUST complete this task non-interactively. You MUST NOT block for user input
after this initial prompt. You MUST follow the instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

**Output:**

The same files with presentation-only edits applied (whitespace,
indentation, wrapping, quotes, ordering), behavior and structure provably
unchanged, ideally via the project's automated formatter, ready to commit under
a `style:` commit. This skill normalizes presentation and stops; it makes no
structural or behavioral change.

## Instructions

1.  **Confirm the change is presentation only.**

    Before reformatting, you MUST identify exactly what is changing: whitespace,
    indentation, line wrapping, trailing newlines, quote style, trailing commas,
    semicolons, import ordering or grouping, casing of literals, line endings,
    final newline, BOM, and encoding. If you cannot describe the change in those
    terms, you MUST stop and re-classify as a structural refactor.

2.  **Prefer the project's configured formatter.**

    You SHOULD run the project's formatter rather than hand-editing. You SHOULD
    look for, in order, a formatter config file, a formatter script in
    `package.json`, `Makefile`, `justfile`, etc., or a pre-commit hook that
    configures the formatter. You MUST use the configured tool with the
    configured options.

3.  **Scope the run deliberately.**

    You MUST decide what to format: the file or files just touched, a single
    directory, or the whole repo. Wider scope means a noisier diff.

4.  **Verify behavior is unchanged.**

    You MUST run the test suite after the formatting pass. You MUST be especially
    careful with significant-whitespace languages (Python, YAML, Make, Haskell),
    auto-removal of side-effect imports, quote-style changes inside strings, and
    generated files.

5.  **Commit as `style:`.**

    You MUST make one formatting commit per scope using the `style:` commit type.

6.  **Consider automation for next time.**

    If you formatted by hand, you SHOULD open a follow-up `maintenance:` task to
    add or fix the formatter config, wire it into a pre-commit hook, and wire it
    into CI as a check that fails on unformatted code.

## Rules

- **Behavior preservation MUST be non-negotiable.**

  A formatting change that alters runtime behavior is mislabeled. Tests MUST
  pass before and after; observable output MUST be byte-identical for any
  given input. If you cannot promise that, it is not a style change.

- **Presentation only — there MUST be no structural edits.**

  Renaming a variable, extracting a function, reordering parameters,
  simplifying a conditional — all are structural refactors, not style. Even
  renames that "look like" formatting (eg. casing a constant from `myConst` to
  `MY_CONST`) change identifier resolution.

- **You MUST NOT bundle formatting with feature, fix, or refactor work.**

  Mixed commits hide the substantive change inside formatting noise and make
  `git blame` useless. You MUST keep formatting separate.

- **You SHOULD prefer automated formatters over hand-edits.**

  A formatter applies the same rule everywhere and is reproducible. Hand-edits
  drift, vary by author, and re-emerge in the next diff. If the project has no
  formatter, that is the bug to fix — via a `maintenance:` commit — before the
  next manual style pass.

- **You MUST NOT change formatter configuration in a style commit.**

  Changing `.prettierrc` then re-running the formatter changes two things at
  once. You MUST split: one `maintenance:` commit changes the config; one
  `style:` commit applies the new style.

- **You MUST respect generated and vendored files.**

  Generated code (codegen output, transpiled bundles, vendored third-party
  files) MUST NOT be reformatted — the generator owns the format. You MUST add
  such paths to the formatter's ignore list.

- **You MUST watch significant-whitespace languages.**

  In Python, YAML, Make, and similar, indentation is syntax. A "harmless"
  re-indent can change meaning. You MUST always run the test suite; for
  YAML/config files, you MUST run a parser/loader after the change.

- **You MUST reformat in its own scope.**

  A formatting commit that touches a hundred unrelated files because the
  formatter happened to find them is harder to review than one that names a
  directory and stops there. You MUST pick a scope and stick to it.

- **The diff SHOULD be visually large but semantically empty.**

  A reviewer MUST be able to run `git diff --ignore-all-space` (or `git diff
  -w`) and see an empty diff. If `-w` still shows changes, the commit is not
  pure formatting.

## Edge cases

- **The formatter wants to rewrite a file your change just touched.**

  Common when joining a project mid-flight. Format the file *first* in a
  `style:` commit on the same branch, then make your behavior change against
  the now-canonical baseline. Reviewers see two clean diffs instead of one
  noisy one.

- **The formatter and a linter disagree.**

  Pick one as authoritative (usually the formatter for whitespace and the
  linter for everything else) and configure the linter to ignore overlapping
  rules. Document the decision via a `maintenance:` commit.

- **The style change is enormous because the codebase was never formatted.**

  A one-off "big bang" reformat is acceptable when adopting or upgrading a
  formatter. Land it as a single `style:` commit, ideally on its own merge, so
  `git blame` can be navigated with `git blame --ignore-rev`. Record the
  commit SHA in `.git-blame-ignore-revs`.

- **Formatting "fixes" a CI failure.**

  If CI fails because of formatting, fix the formatting. But also check
  whether the formatter check is missing as a local pre-commit hook — if it
  is, file a `maintenance:` task. Catching format issues at push time is
  friction.

- **Significant-whitespace breakage.**

  A Python re-indent turned a method into a nested function. The test suite
  caught it. Lesson: never run an auto-formatter on a significant-whitespace
  language without test coverage.

## Success criteria

- **External behavior MUST be unchanged.**

  Tests MUST pass after the style pass. `git diff -w` between pre and post
  MUST show no changes.

- **The diff MUST contain only presentation changes.**

  There MUST be no renames, no logic edits, no structural moves.

- **The commit MUST be a single `style:` commit per scope.**

  There MUST be no bundled feature, fix, refactor, or config changes.

- **The formatter, if any, MUST have been used as configured.**

  It MUST NOT be hand-edited around the formatter. It MUST NOT be run with
  non-standard options.

- **Tooling gap, if any, MUST be captured.**

  If hand-formatting was necessary, a follow-up `maintenance:` task MUST exist
  to add or fix the automation.

## References

<!--

TODO: Reinstate TS-* cross-references when those are republished.

- [TS-9: Version
  Control](https://github.com/kieranpotts/standards/tree/dev/ts/009): Defines
  the `style:` commit type used here.

-->

## Examples

- **A clean formatting commit after a feature:**

  ```
  Sequence:
    feature: add bulk export endpoint     # the change
    style:   apply prettier to handlers/  # normalize style

  The feature commit shows the actual logic. The style commit shows
  the style normalization separately, reviewable in seconds.
  ```

- **Catching a behavior change pretending to be style:**

  ```
  While "formatting" auth.py I noticed the function `_normalize_token`
  was renamed to `normalize_token` (removing the underscore). That is
  a refactor, not a formatting change — it alters the public surface
  of the module. Reverted the rename; recorded a refactor: follow-up.
  ```

- **A repo-wide normalization, scoped:**

  ```
  style: convert tab indentation to spaces across src/

  Applied via .editorconfig + `npm run format`. No source files
  outside src/ changed. Tests pass.
  ```
