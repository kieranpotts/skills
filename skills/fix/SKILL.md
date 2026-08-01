---
name: fix
description: >-
  Fix anything generally broken — failing builds, lint, type-checks, etc. Use
  this where the cause is already known, eg. debugging has already taken place
  to identify the cause, or the cause is evident from a tool's own output. Use
  when a build, compile, lint, type-check, or other deterministic gate is
  failing. Or use when the user says something like "fix the build", "fix the
  lint errors", "make the type-checker pass", or "implement the fix to resolve
  this known bug".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programming
---

# Fix

Fix anything in a codebase that is broken in an obvious, mechanical way, eg.
failing builds, lint or type-check violations, deprecation warnings, or
broken tool configs.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **The broken thing — REQUIRED.** A failing build/compile/lint/type-check
  command, an error message, or an instruction to audit a part of the
  codebase for things that are broken.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- The build, compile, lint, or type-check passes; the reported breakage is
  resolved at its source, or explicitly suppressed with a recorded
  justification.

- No unrelated behavior change.

- The check MUST exit zero.

  Re-running the exact command that originally failed MUST now pass,
  with no remaining violations.

- No new issues MUST have been introduced.

  The full set of checks — not just the one that originally failed — MUST
  pass after the change.

- Every suppression MUST state a reason.

  `grep` for suppression directives in the diff; each one MUST have an
  inline justification.

- The commit MUST be scoped to the fix.

  No unrelated feature or `style:` changes MUST be bundled in.

## Instructions

1.  Run the check and read its output literally.

    Do not guess at what a build, compiler, linter, or type-checker wants.
    Run it, and read the exact error, rule name, message, and location it
    reports. Most tools name the problem precisely (eg. `no-unused-vars`, a
    missing import, a type mismatch, an undefined symbol) — that message is
    the spec for the fix.

2.  If auditing rather than responding to a specific failure, run every
    available check.

    When asked to find what's broken rather than fix a named failure, run
    the project's build, compiler, linter, type-checker, and any other
    static gate, in turn. Compile a list of distinct issues before fixing
    any — fixing one can sometimes resolve or mask another.

3.  Prefer automated fixes where they exist.

    Many linters support `--fix`; some build/compile errors are resolved by
    `npm install`/dependency updates or regenerating lockfiles; some
    deprecation warnings have an automated migration codemod. Run these
    first, then re-check — automated fixes rarely resolve everything.

4.  Fix remaining issues at their reported location.

    Make the minimal change that resolves the specific error — not a
    broader rewrite. A type error usually wants a narrower type, a missing
    null check, or a corrected signature; a build or compile failure usually
    wants a missing dependency, a broken import path, a stale generated
    file, or a config correction.

5.  If a check is wrong for this case, suppress it explicitly — never
    silently.

    Some violations are false positives for the specific context. Suppress
    with an inline directive (`// eslint-disable-next-line <rule> --
    <reason>`, `# type: ignore[<code>] -- <reason>`) that names the rule and
    states why it doesn't apply here. An unexplained suppression is worse
    than the violation — the next reader can't tell if it was a judgment
    call or laziness.

6.  Re-run every check that was failing.

    Re-run after each fix and again after all fixes. Confirm each reported
    issue is resolved and no new ones were introduced. Fixes can shift
    errors elsewhere — especially type narrowing or dependency changes,
    which can surface or hide other errors.

7.  Commit as `fix:` or `maintenance:` depending on scope.

    A small, localized fix to make CI green is typically `fix:`. A larger
    sweep — clearing a backlog of deprecation warnings, fixing many type
    errors after a dependency bump — is `maintenance:`.

## Rules

- If the cause isn't already evident, you MUST NOT use this skill.

  fix resolves breakage a tool has already diagnosed. If you need to form
  and test hypotheses about why something is failing, you MUST switch to
  [debug](../debug/SKILL.md).

- You MUST make the minimal change that resolves the reported issue.

  Do not refactor, rename, or restructure while fixing. A fix that also
  changes unrelated behavior or presentation makes the diff hard to review
  and risky to revert.

- You MUST fix the problem, not relocate it.

  Suppressing a rule project-wide, or widening a type to `any`/`unknown`
  to make an error disappear, doesn't fix anything — it hides the signal
  the tool exists to give. You SHOULD prefer the narrowest fix that
  genuinely resolves the rule's intent.

- You MUST NOT bundle with feature or style work.

  A diff that fixes build/lint/type errors alongside unrelated logic or
  presentation changes makes it hard to tell which change introduced a
  regression. These fixes MUST land in their own commit.

- Suppressions MUST carry a stated reason, every time.

  `// eslint-disable-next-line` with no comment MUST NOT appear. You MUST
  state which case the rule doesn't apply to and why.

## Edge cases

- The rule or check itself is wrong for the project.

  If a rule is consistently wrong across many call sites, that's not a
  one-off fix — it's a `maintenance:` change to the lint/build config,
  made deliberately and reviewed, not papered over one suppression at a
  time.

- Fixing one type or build error cascades into many more.

  Common after narrowing a shared type, upgrading a type-checker, or
  bumping a dependency. Work outward from the original error; each
  downstream error usually resolves once its upstream cause does. If the
  cascade is large, treat it as a `maintenance:` sweep.

- The check is flaky, not actually failing on the code.

  If re-running the identical command sometimes passes and sometimes
  fails with no code changes, the problem is the check's environment
  (caching, ordering, concurrency, network) — that's a `maintenance:`
  task on the tooling itself, not a code fix.

- The "fix" doesn't actually resolve the reported error — it just changes
  the symptom.

  If after a change the original error is gone but a new, unrelated error
  appears in its place, that's a sign the change addressed the wrong
  thing. Re-read the original error message before declaring done.

- The breakage turns out to have an unclear cause after all.

  If investigation reveals there's no evident fix — the error message
  doesn't point anywhere conclusive, or the "obvious" fix doesn't
  resolve it — stop and switch to [debug](../debug/SKILL.md) rather than
  guessing repeatedly.

## Examples

- A broken build with an evident cause:

  ```sh
  $ npm run build
  Error: Cannot find module 'lodash.debounce'

  # package.json lists it as a dependency, but node_modules is stale.
  $ npm install
  $ npm run build
  Build succeeded.
  ```

- Autofix resolves most of it:

  ```sh
  $ eslint src/ --fix
  3 problems fixed, 2 remaining.

  $ eslint src/handlers/auth.ts
    42:7  error  'token' is possibly undefined  strict-boolean-expressions
  ```

- Fix at the reported location — narrow the type, don't suppress:

  ```ts
  // Before
  if (token) { ... }

  // After
  if (token !== undefined && token.length > 0) { ... }
  ```

- A justified suppression:

  ```ts
  // eslint-disable-next-line no-explicit-any -- third-party SDK has no types; tracked in #482
  const client: any = createLegacyClient()
  ```

## References

None.
