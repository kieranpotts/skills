---
name: fix
description: >-
  Repair something whose cause is already established — a failing build,
  compile, lint, or type-check, or a bug that a completed diagnosis has already
  explained — and prove the repair worked. Use when a deterministic gate is
  failing, when a confirmed cause and a failing regression test have been handed
  over, when asked to audit an area for breakage, or when the user says "fix the
  build", "fix the lint errors", "make the type-checker pass", or "implement the
  fix for this known bug". Do not use it when the cause is still unknown and
  hypotheses would have to be formed and tested.
compatibility: >-
  requires Read, Edit, Grep, Bash (build, lint, and type-check commands, git)
license: CC0-1.0
---

# Fix

Repair something whose cause is already established, and prove the repair
worked. A cause counts as established when a tool named it precisely, or when a
completed diagnosis confirmed it; if any hypothesis remains to be formed and
tested, stop and hand the work back for systematic diagnosis instead.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message. You MAY prompt solely to establish where an artifact
lives or how to access it, when context and environment do not settle it.

- **The breakage — REQUIRED.** Either a specific failing command with its
  output, a bug that a diagnosis has already reproduced, or an instruction to
  audit an area of the codebase for whatever is broken there.

- **The established cause — REQUIRED.** Where a check is failing, the tool's
  own error, rule name, and location are the cause and the spec for the fix.
  Where a diagnosis was handed over, its confirmed causal chain is. Discover
  the diagnosis from the surrounding context first, then from wherever this
  project files investigation write-ups — do not assume a location or format.

- **A failing regression test — OPTIONAL.** Where a diagnosis handed one over,
  it is the acceptance criterion for the repair. Where a diagnosis documented
  that no correct seam existed for one, the repro command it handed over stands
  in.

## Success criteria

- Re-running the exact command that originally failed MUST now exit zero, with
  no remaining violations.

- The project's other checks MUST also pass after the change, since narrowing a
  type or moving a dependency can surface failures elsewhere.

- Where a failing regression test was handed over, it MUST pass with the change
  applied and fail again with it reverted. Where none was, the handed-over
  repro MUST no longer reproduce.

- Every suppression directive introduced by the change MUST carry an inline
  justification: grep the diff for suppression directives and check each one.

- The diff MUST contain nothing beyond the repair — no refactor, rename,
  feature, or presentation change riding along, and no test weakened to make it
  green.

- Where the cause came from a diagnosis, the change description MUST restate
  it, so future readers learn what the real cause was and not just what the
  change touched.

## Instructions

1.  Establish which kind of repair this is.

    If a diagnosis has handed over a confirmed cause, go to step 5. Otherwise
    the cause comes from a tool, and steps 2-4 apply.

2.  Run the check and read its output literally.

    Do not guess at what a build, compiler, linter, or type-checker wants. Run
    it, and read the exact error, rule name, message, and location it reports.
    Most tools name the problem precisely — eg. `no-unused-vars`, a missing
    import, a type mismatch, an undefined symbol — and that message is the
    spec for the fix.

3.  If auditing rather than responding to a named failure, run every available
    check first.

    Run the project's build, compiler, linter, type-checker, and any other
    static gate, in turn. Compile a list of distinct issues before fixing any,
    because fixing one can resolve or mask another.

    A check that fails without naming its cause is out of scope. Set it aside
    for systematic diagnosis and carry on with the rest.

4.  Prefer automated fixes where they exist.

    Many linters support `--fix`; some build failures resolve by reinstalling
    dependencies or regenerating a lockfile; some deprecations ship a codemod.
    Run these first, then re-check: automated fixes rarely resolve everything.

5.  Confirm a handed-over diagnosis before acting on it.

    Run the handed-over repro or regression test and watch it fail. Read the
    stated causal chain against the code it names.

    If the test passes, or fails for a different reason, or the code no longer
    matches what the diagnosis describes, the diagnosis is stale. Stop and
    report that — do not re-derive it here.

6.  Fix at the established location.

    Make the minimal change that resolves the specific error or removes the
    diagnosed cause, not a broader rewrite. A type error usually wants a
    narrower type, a missing null check, or a corrected signature; a build
    failure usually wants a missing dependency, a broken import path, a stale
    generated file, or a config correction.

    Where a diagnosis suggested a remedy, treat it as a suggestion rather than
    an instruction. Prefer it unless the code gives you a reason not to, and
    where you depart from it, say why in the change description.

7.  Where a check is genuinely wrong for this case, suppress it explicitly —
    never silently.

    Use an inline directive that names the rule and states why it does not
    apply here, eg. `// eslint-disable-next-line <rule> -- <reason>` or
    `# type: ignore[<code>] -- <reason>`. An unexplained suppression is worse
    than the violation, because the next reader cannot tell a judgment call
    from laziness.

8.  Verify, including in reverse.

    Re-run after each fix and again after all fixes, confirming each reported
    issue is resolved and no new ones appeared.

    Where a regression test was handed over, watch it go green, then revert the
    change and watch it go red again before restoring it. A test that passes
    either way proves nothing about the fix.

9.  Record the change following whatever convention this project uses.

    Discover the commit-message convention from the repository — its own
    convention files, or recent history — rather than assuming one. Where the
    convention distinguishes a corrective change from a broader maintenance
    sweep, classify accordingly: a small, localized fix to make CI green is
    corrective; clearing a backlog of deprecations or fixing many type errors
    after a dependency bump is maintenance.

    Where the cause came from a diagnosis, carry it into the message.

## Rules

- If the cause is not already established, you MUST NOT continue under this
  skill.

  This task repairs breakage that a tool or a completed diagnosis has already
  explained. If you would have to form and test hypotheses about why something
  is failing, stop and report that systematic diagnosis is needed first.

- You MUST make the minimal change that resolves the reported issue, and MUST
  keep it in its own commit.

  Do not refactor, rename, or restructure while fixing, and do not bundle
  feature or presentation work alongside. A diff that mixes a repair with
  unrelated change is hard to review and risky to revert, and obscures which
  change introduced any regression.

- You MUST fix the problem, not relocate it.

  Suppressing a rule project-wide, or widening a type to `any`/`unknown` to make
  an error disappear, hides the signal the tool exists to give. You SHOULD
  prefer the narrowest fix that genuinely satisfies the rule's intent.

- You MUST NOT weaken a handed-over regression test to make it pass.

  The test encodes the diagnosed bug. Relaxing its assertion, widening its
  tolerance, skipping it, or moving it to a shallower seam turns the acceptance
  criterion into a formality. If the test looks wrong, that is a finding to
  report, not an edit to make.

## Edge cases

- The rule or check itself is wrong for the project.

  If a rule is consistently wrong across many call sites, that is not a one-off
  fix. Treat it as a deliberate, reviewable change to the lint or build config,
  rather than papering over it one suppression at a time.

- Fixing one type or build error cascades into many more.

  Common after narrowing a shared type, upgrading a type-checker, or bumping a
  dependency. Work outward from the original error; each downstream error
  usually resolves once its upstream cause does. If the cascade is large, treat
  it as a maintenance sweep rather than a targeted fix.

- The check is flaky, not actually failing on the code.

  If re-running the identical command sometimes passes and sometimes fails with
  no code changes, the problem is the check's environment — caching, ordering,
  concurrency, network. That is a task on the tooling, not a code fix.

- The original error disappears but a new, unrelated one appears in its place.

  That is a sign the change addressed the wrong thing. Re-read the original
  error message and reconcile it against what you changed before declaring
  done.

- The handed-over diagnosis turns out to be wrong.

  If the minimal change the diagnosis implies does not turn the regression test
  green, the causal chain has a broken link. Report that back with what you
  observed. Do not start forming hypotheses of your own — that belongs to the
  diagnosis task, and restarting it here loses the evidence trail.

- No regression test came with the diagnosis.

  Where a diagnosis documented that no correct seam existed for one, verify
  against its repro command instead, and surface the missing seam as a finding
  — not as licence to add a shallow test that would pass either way.

- The breakage turns out to have an unclear cause after all.

  If the error message points nowhere conclusive, or the obvious fix does not
  resolve it, stop and hand the work over for systematic diagnosis rather than
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

- Autofix resolves most of it, leaving the rest to fix by hand:

  ```sh
  $ eslint src/ --fix
  3 problems fixed, 2 remaining.

  $ eslint src/handlers/auth.ts
    42:7  error  'token' is possibly undefined  strict-boolean-expressions
  ```

- Fix at the reported location — narrow the type, do not suppress:

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
