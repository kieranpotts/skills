---
name: code
description: Write code and tests for a single step from the plan. Default to test-driven development (red-green-refactor). Stay strictly within the step's scope. Use when implementing one numbered step from [`plan`](../plan/SKILL.md), or for any small standalone change whose design is already obvious.
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: kimi-k2.6:cloud
---

# Code

Use this skill when implementing one numbered step from [`plan`](../plan/SKILL.md), or any small standalone change whose design is already obvious. The workflow re-enters this skill once per plan step: after [`test`](../test/SKILL.md) passes for the current step, return here to start the next one.

Do NOT use this skill to specify requirements (use [`specify`](../specify/SKILL.md)), evaluate design options (use [`design`](../design/SKILL.md)), decompose work (use [`plan`](../plan/SKILL.md)), or diagnose a failure (use [`debug`](../debug/SKILL.md)).

Do NOT bundle multiple plan steps into one coding session. One step per session keeps the diff reviewable and the rollback clean.

##  Instructions

1.  **Restate the step's scope.**

    Quote the step from the plan. Say in one sentence what is in-scope and, more importantly, what is out-of-scope. Anything not in the step is for a future step - including refactors, error handling for unreached paths, and "while I'm here" cleanups.

    If the step is ambiguous, clarify before coding. Mid-implementation scope drift is the most common cause of unmergeable PRs.

2.  **Set up the feedback loop.**

    The fastest path to working code is a fast pass/fail signal. Before writing the implementation, confirm:

    - You can run the relevant tests (unit, integration) in under ~10 seconds.
    - You know the exact command.
    - The test runner is wired to the editor or terminal for one-keystroke re-runs.

    If the loop is slow or missing, fix it first. Slow loops produce sloppy code.

3.  **Write the failing test first (TDD default).**

    Follow red → green → refactor:

    - *Red*: write the smallest test that captures the behavior to add. Run it. Confirm it fails for the *expected* reason (assertion mismatch, not import error or syntax error).
    - *Green*: write the simplest code that makes the test pass. No design improvements yet.
    - *Refactor*: improve the structure of code and test while all tests stay green.

    Repeat for each piece of behavior, one cycle at a time - never batch the reds (see "Slice vertically, not horizontally" below). Each cycle is a few minutes, not hours.

    Skip TDD only when the design is in genuine flux (early exploration, spikes). Explain the skip in the commit body if so.

4.  **Use real dependencies where practical.**

    Replace dependencies with test doubles only when they are slow, non-deterministic, or unavailable. Prefer real implementations. Excessive mocking produces tests that pass while production breaks.

    For each dependency, pick the lightest viable double:

    - Real implementation > lightweight fake > stub > mock.

5.  **Apply the project's coding standards.**

    Match the surrounding code's idioms - naming, file layout, error handling, logging. If unsure, read 2-3 nearby files first. New code should be indistinguishable in style from existing code unless the existing code is what the step is replacing.

    Adhere to the broader TS-13 principles: meaningful names, low coupling, explicit error handling at boundaries (not interior), comments only where the *why* is non-obvious.

6.  **Review the diff before committing.**

    Read the diff as if you were the reviewer. Check:

    - Is everything in this diff in the step's scope?
    - Are there unused imports, debug logs, commented-out code, or `TODO` markers?
    - Does the test name describe the behavior, not the implementation?
    - Could a future reader understand the *why* without you?

    Remove anything that does not pay its way.

7.  **Commit.**

    One step = one commit (or a small batch of `step:` commits if subdivision helps reviewers). Follow [`commit`](../commit/SKILL.md) for the type vocabulary and format. Reference the issue or plan in the body or footer.

##  Rules

-   **One step per session.**

    Bundling steps multiplies review surface, hides bugs, and makes rollback painful. If you finish a step fast, commit, branch, start the next one.

-   **In-scope only.**

    Out-of-scope work goes in a follow-up step or a separate `temp/*` branch. "While I'm here" is how scope creep starts.

-   **Tests live with the code.**

    A behavior added in this step is tested in this step. A step that adds untested behavior is incomplete.

-   **Slice vertically, not horizontally.**

    Red-green-refactor is a single-cycle discipline: one test → one implementation → repeat. Resist the urge to batch the reds.

    ```
    WRONG (horizontal):
      RED:   test1, test2, test3, test4, test5
      GREEN: impl1, impl2, impl3, impl4, impl5

    RIGHT (vertical):
      RED → GREEN: test1 → impl1
      RED → GREEN: test2 → impl2
      RED → GREEN: test3 → impl3
    ```

    Tests written in bulk verify *imagined* behavior, not actual behavior. They drift toward testing the *shape* of things (function signatures, data structures) rather than user-facing behavior, and they become insensitive to real changes - passing when behavior breaks and failing when behavior is fine. Each test only earns its keep by being written *after* the previous implementation taught you what to verify.

-   **Don't write speculative code.**

    No abstractions for hypothetical futures. No flexibility points for changes that aren't on the plan. Three similar lines beats a premature abstraction. Trim every "might need this" - if you might need it, you don't need it now.

-   **Don't write defensive code at internal boundaries.**

    Validate at system boundaries (user input, network, external APIs). Trust internal code. Null-checking, type-guarding, and error-wrapping inside the system are usually code smells.

-   **Default to no comments.**

    Well-named identifiers do the explaining. Add a comment only when the *why* is non-obvious - a hidden constraint, a workaround for a specific bug, a surprising invariant. Don't narrate what the code does.

-   **Match TDD discipline to risk.**

    TDD is the default. For trivial code (a config tweak, a rename, a one-line copy change) it's overkill - skip it. For complex logic or anything with corner cases, the test-first discipline pays for itself many times over.

-   **Stop when the step is done.**

    "Done" = test passes, diff is clean, commit message is written. Not "done plus a bit more". The bit more is the next step.

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

##  Edge cases

-   **The step turns out to be too big.**

    Stop. Loop back to [`plan`](../plan/SKILL.md) and split it. Don't merge a half-step.

-   **You discover a bug unrelated to the step.**

    Note it. File an issue or add a TODO with a tracking reference. Do not fix it in this step. Fixing unrelated bugs in scope-locked steps is how diffs become unreviewable.

-   **You discover a refactor that would make the step easier.**

    Two options: (a) do the refactor as a separate prior `refactor:` step, then resume this step; (b) implement the step as-is and queue the refactor for after. Pick (a) when the refactor is small and obvious; (b) otherwise. Never bundle.

-   **Tests are missing for the area being touched.**

    Add *characterization tests* first - tests that pin down the current behavior - before changing it. This is a separate step from the change itself.

-   **A spike or prototype.**

    The goal is to learn, not to ship. Skip TDD, skip strict scope discipline, but throw the prototype away when done. Re-implement properly under this skill afterward.

##  Success criteria

-   **The diff stays within the step's stated scope.**

    Re-read the diff with the step quoted next to it. Anything outside the scope is removed or moved to its own step.

-   **All new behavior is tested.**

    Each piece of added behavior has at least one test that fails when the behavior is removed.

-   **The test loop is fast and runs clean.**

    `<10s` for the relevant suite. No skipped, pending, or flaky tests added.

-   **The code matches the surrounding style.**

    Naming, layout, error handling, and comment density are consistent with nearby files.

-   **The commit follows the [`commit`](../commit/SKILL.md) format.**

    Correct type, lowercase imperative description, atomic scope.

## References

- [`plan`](../plan/SKILL.md): Source of the step being implemented. The workflow cycles through the plan one step at a time via `code → review → test → code`.

- [`review`](../review/SKILL.md): The next step after coding is complete. Self-review the diff against [`review`](../review/SKILL.md)'s criteria before opening a PR.

- [`test`](../test/SKILL.md): Runs after [`review`](../review/SKILL.md) clears the change, to verify dynamic qualities and full-AC coverage. On pass, the workflow returns to this skill for the next plan step.

- [`commit`](../commit/SKILL.md): Required for the final commit format.

- [`debug`](../debug/SKILL.md): When a test fails for unexpected reasons.

- [`refactor`](../refactor/SKILL.md): When the cleanup discovered mid-step needs its own dedicated session.

- [`handoff`](../handoff/SKILL.md): If you need to pause mid-step (context limit, end of day, switching agents), write a handoff so the next session can resume cleanly inside the same step.
