---
name: fix
description: >-
  Fix anything broken whose cause is already known — failing builds, lint,
  type-checks, or a bug that systematic diagnosis has already explained. Use
  when a build, compile, lint, type-check, or other deterministic gate is
  failing, or when a diagnosis has handed over a confirmed cause and a failing
  regression test. Or use when the user says something like "fix the build",
  "fix the lint errors", "make the type-checker pass", or "implement the fix to
  resolve this known bug".
compatibility: requires Read, Edit, Bash
license: CC0-1.0
---

# Fix

Repair something whose cause is already established, and prove the repair
worked. There are two ways a cause becomes established, and this skill handles
both:

- A tool named it. A failing build, compile, lint, or type-check reports the
  problem precisely; the fix is mechanical.

- A diagnosis named it. Systematic investigation has already reproduced the
  bug, confirmed the causal chain, and left behind a failing regression test.

What the two share is that no hypothesis remains to be formed. If you would
have to investigate why something is failing, this is the wrong task — stop
and switch to systematic diagnosis instead.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **The broken thing, and what already explains it — REQUIRED.** Either a
  failing build/compile/lint/type-check command with its error message, or a
  diagnosis stating a confirmed cause. Or an instruction to audit a part of
  the codebase for things that are broken.

- **A failing regression test — OPTIONAL.** Where a diagnosis handed one
  over, it is the acceptance criterion for the repair. Where a diagnosis
  documented that no correct seam existed for one, the repro command it
  handed over stands in.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

- The reported breakage MUST be resolved at its source, or explicitly
  suppressed with a recorded justification.

- The commit MUST be scoped to the fix: no unrelated behavior change, and no
  feature or `style:` work bundled in.

- The check MUST exit zero: re-running the exact command that originally
  failed MUST now pass, with no remaining violations.

- Where a failing regression test was handed over, it MUST now pass, and it
  MUST fail again when the change is reverted. Where none was, the handed-over
  repro MUST no longer reproduce.

- No new issues MUST have been introduced — the full set of checks, not
  just the one that originally failed, MUST pass after the change.

- Every suppression MUST state a reason: `grep` for suppression directives
  in the diff, and each one MUST have an inline justification.

- Where the cause came from a diagnosis, it MUST be restated in the commit or
  PR message, so future readers learn what the real cause was, not just what
  the change touched.

## Instructions

1.  Establish which kind of repair this is.

    If a diagnosis has handed over a confirmed cause, go to step 5. Otherwise
    the cause comes from a tool, and steps 2-4 apply.

2.  Run the check and read its output literally.

    Do not guess at what a build, compiler, linter, or type-checker wants.
    Run it, and read the exact error, rule name, message, and location it
    reports. Most tools name the problem precisely (eg. `no-unused-vars`, a
    missing import, a type mismatch, an undefined symbol) — that message is
    the spec for the fix.

3.  If auditing rather than responding to a specific failure, run every
    available check.

    When asked to find what's broken rather than fix a named failure, run
    the project's build, compiler, linter, type-checker, and any other
    static gate, in turn. Compile a list of distinct issues before fixing
    any — fixing one can sometimes resolve or mask another.

    A check that fails without naming its cause is not in scope here. Set it
    aside for systematic diagnosis and carry on with the rest.

4.  Prefer automated fixes where they exist.

    Many linters support `--fix`; some build/compile errors are resolved by
    `npm install`/dependency updates or regenerating lockfiles; some
    deprecation warnings have an automated migration codemod. Run these
    first, then re-check — automated fixes rarely resolve everything.

5.  Confirm the handed-over diagnosis before acting on it.

    Where the cause came from a diagnosis rather than a tool, run the
    handed-over repro or regression test first and watch it fail. Read the
    stated causal chain against the code it names.

    If the test passes, or fails for a different reason, or the code no
    longer matches what the diagnosis describes, the diagnosis is stale.
    Stop and report that — do not re-derive it here.

6.  Fix at the established location.

    Make the minimal change that resolves the specific error or removes the
    diagnosed cause — not a broader rewrite. A type error usually wants a
    narrower type, a missing null check, or a corrected signature; a build or
    compile failure usually wants a missing dependency, a broken import path,
    a stale generated file, or a config correction.

    Where a diagnosis suggested a remedy, it is a suggestion, not an
    instruction. Prefer it unless the code gives you a reason not to; where
    you depart from it, say why in the commit message.

7.  If a check is wrong for this case, suppress it explicitly — never
    silently.

    Some violations are false positives for the specific context. Suppress
    with an inline directive (`// eslint-disable-next-line <rule> --
    <reason>`, `# type: ignore[<code>] -- <reason>`) that names the rule and
    states why it doesn't apply here. An unexplained suppression is worse
    than the violation — the next reader can't tell if it was a judgment
    call or laziness.

8.  Verify, including in reverse.

    Re-run after each fix and again after all fixes. Confirm each reported
    issue is resolved and no new ones were introduced. Fixes can shift
    errors elsewhere — especially type narrowing or dependency changes,
    which can surface or hide other errors.

    Where a regression test was handed over, watch it go green, then revert
    the change and watch it go red again before restoring it. A test that
    passes either way proves nothing about the fix.

9.  Commit as `fix:` or `maintenance:` depending on scope.

    A small, localized fix to make CI green is typically `fix:`. A larger
    sweep — clearing a backlog of deprecation warnings, fixing many type
    errors after a dependency bump — is `maintenance:`.

    Where the cause came from a diagnosis, carry it into the message. The
    next person working this area benefits from knowing what the real cause
    was, not just what the change touched.

## Rules

- If the cause isn't already established, you MUST NOT use this skill.

  This task repairs breakage that a tool or a completed diagnosis has already
  explained. If you need to form and test hypotheses about why something is
  failing, you MUST stop and switch to systematic diagnosis instead.

- You MUST make the minimal change that resolves the reported issue.

  Do not refactor, rename, or restructure while fixing. A fix that also
  changes unrelated behavior or presentation makes the diff hard to review
  and risky to revert.

- You MUST fix the problem, not relocate it.

  Suppressing a rule project-wide, or widening a type to `any`/`unknown`
  to make an error disappear, doesn't fix anything — it hides the signal
  the tool exists to give. You SHOULD prefer the narrowest fix that
  genuinely resolves the rule's intent.

- You MUST NOT weaken a handed-over regression test to make it pass.

  The test encodes the diagnosed bug. Relaxing its assertion, widening its
  tolerance, skipping it, or moving it to a shallower seam turns the
  acceptance criterion into a formality. If the test looks wrong, that is a
  finding to report, not an edit to make.

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

- The handed-over diagnosis turns out to be wrong.

  If the minimal change the diagnosis implies does not turn the regression
  test green, the causal chain has a broken link. Report that back with what
  you observed. Do not start forming hypotheses of your own — that is the
  diagnosis task's job, and restarting it here loses the evidence trail.

- No regression test came with the diagnosis.

  Where a diagnosis documented that no correct seam existed for one, verify
  against its repro command instead, and treat the missing seam as a finding
  worth surfacing — not as licence to add a shallow test that would pass
  either way.

- The breakage turns out to have an unclear cause after all.

  If investigation reveals there's no evident fix — the error message
  doesn't point anywhere conclusive, or the "obvious" fix doesn't
  resolve it — stop and switch to systematic diagnosis rather than
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

- Verifying a repair against a handed-over regression test:

  ```sh
  $ npm test -- cache.tenant-isolation   # before: red, as handed over
  FAIL  expected totals for tenant B, received tenant A

  # Apply the diagnosed fix: include tenant ID in the key at cache.ts:42.
  $ npm test -- cache.tenant-isolation
  PASS

  $ git stash && npm test -- cache.tenant-isolation
  FAIL                                    # the test is testing the fix
  $ git stash pop
  ```
