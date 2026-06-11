---
name: format
description: Apply presentation-only code or content changes - whitespace, indentation, line wrapping, quotes, trailing commas, import ordering - without altering behavior or structure. Prefer automated formatters configured at the project level. Use when normalizing style after a feature, fixing CI lint failures, or aligning a file to project conventions - distinct from structural improvements ([`refactor`](../refactor/SKILL.md)).
license: CC0-1.0
metadata:
  preferred_model: kimi-k2.6:cloud
---

# Format

Use this skill when applying presentation-only changes to code or content - whitespace, indentation, line breaks, quote style, trailing commas, import ordering, casing of literals, file encoding, line endings. The semantics of the code MUST be unchanged.

Do NOT use this skill to alter logic, data structures, names, module boundaries, or any other internal structure (use [`refactor`](../refactor/SKILL.md)). Do NOT use it to fix defects ([`debug`](../debug/SKILL.md)) or add behavior ([`code`](../code/SKILL.md)).

A formatting pass that "while we're here" renames a variable, splits a function, or tweaks a conditional is no longer a formatting pass. It is a refactor, and belongs in a separate commit under [`refactor`](../refactor/SKILL.md) conventions.

##  Instructions

1.  **Confirm the change is presentation only.**

    Before reformatting, identify exactly what is changing:

    - Whitespace, indentation, line wrapping, trailing newlines.
    - Quote style (single vs double), trailing commas, semicolons.
    - Import ordering or grouping.
    - Casing of literals (eg. hex `0xFF` vs `0xff`) where the language treats them as equivalent.
    - File-level concerns: line endings (LF/CRLF), final newline, BOM, encoding.

    If you cannot describe the change in those terms, you are not formatting. Stop and re-classify - most likely [`refactor`](../refactor/SKILL.md).

2.  **Prefer the project's configured formatter.**

    Run the project's formatter rather than hand-editing. Look for, in order:

    - A formatter config file: `.prettierrc`, `.editorconfig`, `pyproject.toml` (`[tool.black]`, `[tool.ruff]`), `rustfmt.toml`, `.clang-format`, `gofmt`, `.stylelintrc`, etc.
    - A formatter script in `package.json`, `Makefile`, `justfile`, or similar (`npm run format`, `make fmt`).
    - A pre-commit hook (`.pre-commit-config.yaml`) that already configures the formatter.

    Use the configured tool with the configured options. Do not introduce a new formatter or change config inside a formatting commit - that is a `maintenance:` change (see [`commit`](../commit/SKILL.md)).

3.  **Scope the run deliberately.**

    Decide what to format:

    - *The file or files I just touched* (most common - normalize before commit).
    - *A single directory* being brought into line with project conventions.
    - *The whole repo* (rare - a one-off normalization, usually justified by adopting or upgrading a formatter).

    Wider scope means a noisier diff. Reviewers cannot distinguish behavior changes from formatting noise when they are mixed. Format in its own commit, on its own scope.

4.  **Verify behavior is unchanged.**

    Even pure formatting can break things:

    - Significant-whitespace languages (Python, YAML, Make, Haskell) can change semantics on bad re-indents.
    - Auto-removal of "unused" imports by some formatters can break code that uses side-effect imports.
    - Quote-style changes inside strings that contain the other quote can break string content.
    - Reformatting generated files breaks the generator's round-trip.

    Run the test suite after the formatting pass. Tests passing is the proof, not the assumption.

5.  **Commit as `format:`.**

    One formatting commit per scope. See [`commit`](../commit/SKILL.md):

    ```
    format: apply prettier to src/
    format: normalize line endings to LF
    format: sort imports in api/handlers
    ```

    Do not bundle formatting changes with `feature:`, `fix:`, `refactor:`, or `step:` commits. A mixed diff hides the real change inside the noise.

6.  **Consider automation for next time.**

    If you formatted by hand, the project is missing automation. Open a follow-up `maintenance:` task to:

    - Add or fix the formatter config.
    - Wire it into a pre-commit hook (`pre-commit`, `husky`, `lefthook`).
    - Wire it into CI as a check that fails on unformatted code.

    Hand-formatting is a smell. The skill exists for the cases where it is necessary, not as the default.

##  Rules

-   **Behavior preservation is non-negotiable.**

    A formatting change that alters runtime behavior is mislabeled. Tests pass before and after; observable output is byte-identical for any given input. If you cannot promise that, it is not a format change.

-   **Presentation only - no structural edits.**

    Renaming a variable, extracting a function, reordering parameters, simplifying a conditional - all are [`refactor`](../refactor/SKILL.md), not format. Even renames that "look like" formatting (eg. casing a constant from `myConst` to `MY_CONST`) change identifier resolution and are structural.

-   **Never bundle with feature, fix, or refactor work.**

    Mixed commits hide the substantive change inside formatting noise and make `git blame` useless. Format first as `format:` commits; then change behavior as `feature:`, `fix:`, `refactor:`, or `step:` commits. Or, more commonly: format *after* the change is complete, as a follow-up commit.

-   **Prefer automated formatters over hand-edits.**

    A formatter applies the same rule everywhere and is reproducible. Hand-edits drift, vary by author, and re-emerge in the next diff. If the project has no formatter, that is the bug to fix - via a `maintenance:` commit - before the next manual format pass.

-   **Do not change formatter configuration in a format commit.**

    Changing `.prettierrc` then re-running the formatter changes two things at once. Split: one `maintenance:` commit changes the config; one `format:` commit applies the new style.

-   **Respect generated and vendored files.**

    Generated code (codegen output, transpiled bundles, vendored third-party files) should not be reformatted - the generator owns the format. Add such paths to the formatter's ignore list.

-   **Watch significant-whitespace languages.**

    In Python, YAML, Make, and similar, indentation is syntax. A "harmless" re-indent can change meaning. Always run the test suite; for YAML/config files, run a parser/loader after the change.

-   **Reformat in its own scope.**

    A formatting commit that touches a hundred unrelated files because the formatter happened to find them is harder to review than one that names a directory and stops there. Pick a scope and stick to it.

-   **The diff should be visually large but semantically empty.**

    A reviewer should be able to run `git diff --ignore-all-space` (or `git diff -w`) and see an empty diff. If `-w` still shows changes, the commit is not pure formatting.

## Examples

A clean formatting commit after a feature:

```
Sequence:
  feature: add bulk export endpoint     # the change
  format:  apply prettier to handlers/  # normalize style

The feature commit shows the actual logic. The format commit shows
the style normalization separately, reviewable in seconds.
```

Catching a behavior change pretending to be format:

```
While "formatting" auth.py I noticed the function `_normalize_token`
was renamed to `normalize_token` (removing the underscore). That is
a refactor, not a formatting change - it alters the public surface
of the module. Reverted the rename; recorded a refactor: follow-up.
```

A repo-wide normalization, scoped:

```
format: convert tab indentation to spaces across src/

  Applied via .editorconfig + `npm run format`. No source files
  outside src/ changed. Tests pass.
```

##  Edge cases

-   **The formatter wants to rewrite a file your change just touched.**

    Common when joining a project mid-flight. Format the file *first* in a `format:` commit on the same branch, then make your behavior change against the now-canonical baseline. Reviewers see two clean diffs instead of one noisy one.

-   **The formatter and a linter disagree.**

    Pick one as authoritative (usually the formatter for whitespace and the linter for everything else) and configure the linter to ignore overlapping rules. Document the decision via a `maintenance:` commit.

-   **The format change is enormous because the codebase was never formatted.**

    A one-off "big bang" reformat is acceptable when adopting or upgrading a formatter. Land it as a single `format:` commit, ideally on its own merge, so `git blame` can be navigated with `git blame --ignore-rev`. Record the commit SHA in `.git-blame-ignore-revs`.

-   **Formatting "fixes" a CI failure.**

    If CI fails because of formatting, fix the formatting. But also check whether the formatter check is missing as a local pre-commit hook - if it is, file a `maintenance:` task. Catching format issues at push time is friction.

-   **Significant-whitespace breakage.**

    A Python re-indent turned a method into a nested function. The test suite caught it. Lesson: never run an auto-formatter on a significant-whitespace language without test coverage.

##  Success criteria

-   **External behavior is unchanged.**

    Tests pass after the format pass. `git diff -w` between pre and post shows no changes.

-   **The diff contains only presentation changes.**

    No renames, no logic edits, no structural moves. A reviewer can scan it in seconds and approve without close reading.

-   **The commit is a single `format:` commit per scope.**

    No bundled feature, fix, refactor, or config changes.

-   **The formatter, if any, was used as configured.**

    Not hand-edited around the formatter. Not run with non-standard options.

-   **Tooling gap, if any, is captured.**

    If hand-formatting was necessary, a follow-up `maintenance:` task exists to add or fix the automation.

## References

<!--

TODO: Reinstate TS-* cross-references when those are republished.

- [TS-9: Version Control](https://github.com/kieranpotts/standards/tree/dev/ts/009): Defines the `format:` commit type used here.

-->

- [`refactor`](../refactor/SKILL.md): When the change is structural rather than presentational. Format is presentation only; refactor is structure.

- [`commit`](../commit/SKILL.md): The `format:` commit type and atomic-commit rules.

- [`review`](../review/SKILL.md): How reviewers should treat a `format:` diff - usually scanned, not read line-by-line.

- [`commit`](../commit/SKILL.md): Defines the `maintenance:` commit type used for changes to formatter configuration, pre-commit hooks, or CI lint checks.
