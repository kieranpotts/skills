---
name: code
description: >-
  Write code and tests for a single step from the plan. Default to test-driven
  development (red-green- refactor). Stay strictly within the step's scope. Use
  when implementing one numbered step from a plan, or for any small standalone
  change whose design is already obvious, or when the user says "implement step
  N of the plan", "code this up", or "build this change, test-first".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programmer
---

# Code

**Input:** One numbered plan step (or a small standalone change whose design is
already obvious) — a scoped, already-designed unit of work. REQUIRED. This skill
does not design or decompose; it consumes a step that is ready to implement.

This skill is non-interactive: agents MUST NOT block for user input after the
initial prompt, and MUST follow the instructions to completion or fail with an
error message.

**Output:** A committed, tested change for that single step — the implementation
plus its tests, scope-locked to the step, with a clean reviewable diff and a
conventional commit. Whatever reviews, tests further, or sequences the next step
is the orchestrator's concern, not this skill's.

## Instructions

1.  **Restate the step's scope.**
    You MUST quote the step from the plan, and state in one sentence what is
    in-scope and what is out-of-scope.

    If the step is ambiguous, you MUST stop and clarify before writing code.

2.  **Set up the feedback loop.**
    Before writing the implementation, you MUST confirm you can run the relevant
    tests, you know the exact command, and the test runner is wired to the editor
    or terminal for one-keystroke re-runs. If the loop is slow or missing, you
    MUST fix the loop first.

3.  **Write the failing test first (TDD default).**
    You MUST follow red → green → refactor:

    - *Red*: write the smallest test that captures the behavior to add. Run it.
      Confirm it fails for the *expected* reason (assertion mismatch, not import
      error or syntax error).
    - *Green*: write the simplest code that makes the test pass. No design
      improvements yet.
    - *Refactor*: improve the structure of code and test while all tests stay
      green.

    You MUST repeat for each piece of behavior, one cycle at a time.

4.  **Choose test doubles.**
    For each dependency, you SHOULD pick the lightest viable double, preferring
    real implementations over test doubles:

    - Real implementation > lightweight fake > stub > mock.

    You SHOULD replace dependencies with doubles only when they are slow,
    non-deterministic, or unavailable.

5.  **Apply the project's coding standards.**
    You MUST match the surrounding code's idioms — naming, file layout, error
    handling, logging. If unsure, you SHOULD read 2-3 nearby files first. New
    code SHOULD be indistinguishable in style from existing code unless the
    existing code is what the step is replacing.

6.  **Review the diff before committing.**
    You MUST read the diff as if you were the reviewer. Check:

    - Is everything in this diff in the step's scope?
    - Are there unused imports, debug logs, commented-out code, or `TODO`
      markers?
    - Does the test name describe the behavior, not the implementation?
    - Could a future reader understand the *why* without you?

    You MUST trim anything that does not pay its way.

7.  **Commit.**
    One step = one commit (or a small batch of `step:` commits if subdivision
    helps reviewers). You MUST use the project's commit type vocabulary and
    format, and SHOULD reference the issue or plan in the body or footer.

## Rules

- **You MUST implement one step per session.**
  Bundling steps multiplies review surface, hides bugs, and makes rollback
  painful. If you finish a step fast, commit, branch, and start the next one.

- **You MUST stay in scope.**
  Out-of-scope work MUST go in a follow-up step or a separate `temp/*` branch.
  "While I'm here" is how scope creep starts.

- **Tests MUST live with the code.**
  A behavior added in this step MUST be tested in this step. A step that adds
  untested behavior MUST be treated as incomplete.

- **You MUST slice vertically, not horizontally.**
  Red-green-refactor is a single-cycle discipline: one test → one
  implementation → repeat. Resist the urge to batch the reds.

  ```
  WRONG (horizontal):
    RED:   test1, test2, test3, test4, test5
    GREEN: impl1, impl2, impl3, impl4, impl5

  RIGHT (vertical):
    RED → GREEN: test1 → impl1
    RED → GREEN: test2 → impl2
    RED → GREEN: test3 → impl3
  ```

  Tests written in bulk verify *imagined* behavior, not actual behavior. They
  drift toward testing the *shape* of things (function signatures, data
  structures) rather than user-facing behavior, and they become insensitive to
  real changes — passing when behavior breaks and failing when behavior is
  fine. Each test only earns its keep by being written *after* the previous
  implementation taught you what to verify.

- **You MUST match TDD discipline to risk.**
  TDD is the default. For trivial code (a config tweak, a rename, a one-line
  copy change) it is overkill and MAY be skipped. For complex logic or anything
  with corner cases, the test-first discipline pays for itself many times over.
  If you skip TDD because the design is in genuine flux, explain the skip in
  the commit body.

- **You MUST NOT write speculative code.**
  No abstractions for hypothetical futures. No flexibility points for changes
  that aren't on the plan. Three similar lines beats a premature abstraction.
  Trim every "might need this" — if you might need it, you don't need it now.

- **You MUST NOT write defensive code at internal boundaries.**
  You MUST validate at system boundaries (user input, network, external APIs),
  and SHOULD trust internal code. Null-checking, type-guarding, and
  error-wrapping inside the system are usually code smells.

- **You SHOULD default to no comments.**
  Well-named identifiers do the explaining. You SHOULD add a comment only when
  the *why* is non-obvious — a hidden constraint, a workaround for a specific
  bug, a surprising invariant. You MUST NOT narrate what the code does.

- **You MUST stop when the step is done.**
  "Done" = test passes, diff is clean, commit message is written. Not "done
  plus a bit more". The bit more is the next step.

## Examples

A red → green → refactor cycle for a small step:

```js
// Red — write the failing test first.
test('returns 400 when idempotency-key header is missing', async () => {
  const res = await request(app).post('/orders').send(validBody);
  expect(res.status).toBe(400);
  expect(res.body.error).toBe('idempotency-key required');
});
// Run: test fails — endpoint returns 201, not 400. Expected failure.

// Green — minimal change to pass.
router.post('/orders', (req, res, next) => {
  if (!req.header('idempotency-key')) {
    return res.status(400).json({ error: 'idempotency-key required' });
  }
  next();
});
// Run: test passes.

// Refactor — extract the guard if it'll be reused; otherwise leave it
// inline. Don't abstract on the first occurrence.
```

A scoped commit at the end of the step:

```
step: validate idempotency-key header on POST /orders

The handler now rejects requests without the header with 400. The actual
idempotency lookup is the next step.

Refs: #482
```

## Edge cases

- **The step turns out to be too big.**
  Stop. Send it back for the plan to be split. Don't merge a half-step.

- **You discover a bug unrelated to the step.**
  Note it. File an issue or add a TODO with a tracking reference. Do not fix
  it in this step. Fixing unrelated bugs in scope-locked steps is how diffs
  become unreviewable.

- **You discover a refactor that would make the step easier.**
  Two options: (a) do the refactor as a separate prior `refactor:` step, then
  resume this step; (b) implement the step as-is and queue the refactor for
  after. Pick (a) when the refactor is small and obvious; (b) otherwise. Never
  bundle.

- **Tests are missing for the area being touched.**
  Add *characterization tests* first — tests that pin down the current
  behavior — before changing it. This is a separate step from the change
  itself.

- **A spike or prototype.**
  The goal is to learn, not to ship. Skip TDD, skip strict scope discipline,
  but throw the prototype away when done. Re-implement properly under this
  skill afterward.

## Success criteria

- **The diff MUST stay within the step's stated scope.**
  Re-read the diff with the step quoted next to it. Anything outside the scope
  MUST be removed or moved to its own step.

- **All new behavior MUST be tested.**
  Each piece of added behavior MUST have at least one test that fails when the
  behavior is removed.

- **The test loop MUST be fast and run clean.**
  `<10s` for the relevant suite. No skipped, pending, or flaky tests MUST be
  added.

- **The code MUST match the surrounding style.**
  Naming, layout, error handling, and comment density MUST be consistent with
  nearby files.

- **The commit MUST follow the project's commit format.**
  Correct type, lowercase imperative description, atomic scope.
