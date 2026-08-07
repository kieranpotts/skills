---
name: code
description: >-
  Implement one small, already-designed step of work, test-first, and commit
  it as a single reviewable diff. Use when implementing one numbered step of a
  delivery plan, or any small standalone change whose design is already
  settled, or when the user says something like "implement step N", "code this
  up", or "build this change, test-first". Do not use it to design, decompose,
  or estimate work that has not yet been broken down.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, Bash (test runner, git)
license: CC0-1.0
---

# Code

Write the code and the tests for one small, already-designed step of work,
then commit it. Do not design the work, and do not carry on past the commit
into review, release, or the next step.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message. You MAY prompt solely to establish where an
artifact lives or how to reach it, when context and environment do not
settle it.

- **The step to implement — REQUIRED.** One scoped unit of work whose design
  is already settled: a numbered step of a delivery plan, or a small
  standalone change. If what you are given still needs designing or
  decomposing, it is not a valid input to this task.

- **The store holding the step — OPTIONAL.** Where the plan, issue, or ticket
  the step comes from is kept. Resolve it from this session's context first,
  then from the environment — a convention file, a workspace manifest, a
  configured connector. It MAY be a directory in this repository, a separate
  repository, or an external service, so do not assume a filesystem path or a
  document structure. Absent any such store, the step as stated in the prompt
  is the whole specification.

- **The project's coding, testing, and commit conventions — OPTIONAL.**
  Discover these the same way, then read and follow whatever the project
  documents for itself. Where nothing is documented, infer the conventions
  from the surrounding code and from recent commit history.

## Success criteria

- An implementation and its tests MUST exist for exactly one step, committed
  together as a single reviewable diff.

- Each behavior added MUST have at least one test that fails when that
  behavior is removed. A test that passes either way is verifying nothing.

- The relevant test suite MUST pass with no tests skipped, pending, or newly
  flaky, and SHOULD run fast enough to re-run on every edit — a few seconds,
  not minutes.

- The diff MUST contain nothing the step did not call for: no unrelated
  fixes, no speculative abstractions, no debug residue, no commented-out
  code.

- New code SHOULD be indistinguishable in style from the files around it,
  unless the existing style is precisely what the step replaces.

- The commit message MUST follow whatever format the project documents, or
  the format evident in its recent history where nothing is documented.

- Work MUST stop at that commit. Pushing, opening a review, releasing, and
  starting the next step are the caller's, not yours.

## Instructions

1.  Restate the step's scope.

    Quote the step as written, then state in one sentence what is in scope
    and what is out of scope. This quote is the yardstick you will measure
    the finished diff against in step 6, so capture it verbatim.

    If the step is ambiguous or larger than a single reviewable diff, stop
    and report that rather than guessing.

2.  Set up the feedback loop before writing any implementation.

    Establish the exact command that runs the tests covering the area you
    are about to change, and run it once to confirm a clean baseline. If the
    loop is slow, broken, or missing, you SHOULD fix the loop first — every
    later step depends on it being trustworthy.

3.  Work test-first, in single cycles.

    - Red: write the smallest test that captures one piece of the behavior
      to add. Run it. Confirm it fails for the expected reason — an
      assertion mismatch, not an import or syntax error.

    - Green: write the simplest code that makes it pass. No design
      improvements yet.

    - Refactor: improve the structure of both code and test while
      everything stays green.

    Repeat one cycle per piece of behavior. See the rule on vertical slicing
    below for why the cycles MUST NOT be batched.

4.  Choose the lightest viable test double for each dependency.

    Prefer, in order: the real implementation, a lightweight fake, a stub, a
    mock. Substitute a double only where the real thing is slow,
    non-deterministic, or unavailable in the test environment.

5.  Match the surrounding code.

    Read two or three nearby files before you commit to naming, file layout,
    error handling, and logging idioms. Where the project documents coding
    standards, those win over local habit.

6.  Review the diff as if you were the reviewer.

    Put the quoted step beside the diff and check: is everything here in
    scope; are there unused imports, debug logs, or leftover markers; does
    each test name describe the behavior rather than the implementation;
    could a future reader understand the why without you? Remove or re-home
    anything that fails those checks.

7.  Commit.

    One step is one commit, unless subdividing genuinely helps a reviewer.
    Use the project's commit type vocabulary and format, and reference the
    originating issue or plan where the project's convention calls for it.

## Rules

- You MUST discover artifact locations and conventions rather than assuming
  them.

  This skill runs across projects that keep their artifacts in different
  places, in different formats, under different tools. A path, file name,
  template, or lifecycle state that is right in one project is wrong in the
  next.

- You MUST implement one step per session.

  Bundling steps multiplies review surface, hides bugs, and makes rollback
  painful. Finishing early is not a reason to start the next step; commit and
  stop.

- Out-of-scope work MUST be deferred to a follow-up step or its own throwaway
  branch, never folded into this diff. "While I'm here" is how scope creep
  starts.

- A behavior added in this step MUST be tested in this step. A step that
  leaves new behavior untested is incomplete, whatever else it achieved.

- You MUST slice vertically, not horizontally.

  ```text
  WRONG (horizontal):
  RED:   test1, test2, test3
  GREEN: impl1, impl2, impl3

  RIGHT (vertical):
  RED → GREEN: test1 → impl1
  RED → GREEN: test2 → impl2
  ```

  Tests written in bulk verify imagined behavior rather than actual
  behavior. They drift toward asserting the shape of things — signatures,
  data structures — and become insensitive to real change, passing when
  behavior breaks and failing when it is fine. Each test earns its keep by
  being written after the previous implementation taught you what to verify.

- You SHOULD match test-first discipline to risk.

  Test-first is the default. For trivial changes — a config tweak, a rename,
  a copy edit — it is overkill and MAY be skipped. For logic with corner
  cases it pays for itself many times over. If you skip it because the design
  is in genuine flux, say so in the commit body.

- You MUST NOT write speculative code.

  No abstractions for hypothetical futures, no flexibility points for changes
  nobody has asked for. Three similar lines beat a premature abstraction. If
  you might need it, you do not need it yet.

- You MUST validate at system boundaries — user input, network, external
  APIs — and SHOULD trust internal code. Null-checking, type-guarding, and
  error-wrapping between your own modules are usually smells rather than
  safety.

- You SHOULD default to writing no comments.

  Well-named identifiers do the explaining. Add a comment only where the why
  is non-obvious: a hidden constraint, a workaround for a specific bug, a
  surprising invariant. You MUST NOT narrate what the code does.

## Edge cases

- The step turns out to be too big for one reviewable diff.

  Stop and report it for the step to be split. Do not commit a half-step.

- You discover a bug unrelated to the step.

  Record it wherever the project tracks issues, and leave it. Fixing
  unrelated bugs inside a scope-locked step is how diffs become
  unreviewable.

- You discover a refactor that would make the step easier.

  Either do the refactor as a separate, prior commit and then resume, or
  implement the step as-is and queue the refactor behind it. Choose the
  former when the refactor is small and obvious, the latter otherwise. Never
  bundle the two into one commit.

- The area you are touching has no tests at all.

  Add characterization tests that pin down the current behavior before
  changing it. That is its own step, and SHOULD be committed separately from
  the change.

- The work is an explicit spike or prototype.

  The goal is learning, not shipping. Skip the test-first discipline and the
  scope locking, but throw the prototype away afterward and re-implement it
  properly under this task.

## Examples

- One red → green → refactor cycle:

  ```js
  // Red — write the failing test first.
  test('returns 400 when idempotency-key header is missing', async () => {
    const res = await request(app).post('/orders').send(validBody);
    expect(res.status).toBe(400);
    expect(res.body.error).toBe('idempotency-key required');
  });
  // Run: fails — endpoint returns 201, not 400. Expected failure.

  // Green — minimal change to pass.
  router.post('/orders', (req, res, next) => {
    if (!req.header('idempotency-key')) {
      return res.status(400).json({ error: 'idempotency-key required' });
    }
    next();
  });
  // Run: passes.

  // Refactor — extract the guard only if it will be reused. Don't abstract
  // on the first occurrence.
  ```

- A scoped commit closing the step, in a project whose convention is
  Conventional-Commits-style types with an issue reference in the footer:

  ```text
  feat: validate idempotency-key header on POST /orders

  The handler now rejects requests without the header with a 400. The
  idempotency lookup itself is the next step.

  Refs: #482
  ```
