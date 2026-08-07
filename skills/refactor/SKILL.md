---
name: refactor
description: >-
  Restructure existing code to improve one named design quality, without
  changing any externally observable behavior. Use when readability,
  cohesion, coupling, naming, or decomposition needs improving, or when the
  user says something like "refactor this for readability", "clean up the
  structure of this module", or "reduce the coupling here without changing
  behavior". Do not use it to fix a bug or to add a feature.
compatibility: >-
  requires Read, Edit, Glob, Grep, Bash (test runner, git)
license: CC0-1.0
---

# Refactor

Improve the internal quality of existing code without changing its observable
behavior, working in small reversible moves that keep the tests green
throughout. Restructure and stop there: fixing bugs, adding features, and
integrating the result are someone else's job.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Target code — REQUIRED.** The existing code to restructure. Take it from
  the user's prompt, the current diff, or the files under discussion. This
  skill does not choose for itself what to work on.

- **Target quality — REQUIRED.** The single design quality being improved —
  readability, cohesion, coupling, naming, decomposition. If the user names
  none and the surrounding context implies none, stop rather than guess: a
  refactor with no named target is aimless churn.

- **Safety net — REQUIRED.** The tests that cover the target code and
  currently pass. Discover them from the project's own test layout and
  runner configuration rather than assuming a path or a command.

## Success criteria

- Every test that passed before MUST pass after, run with the project's own
  test command.

- The test files MUST be absent from the diff. Editing the safety net to
  accommodate the change destroys the only evidence that behavior held.

- Each commit MUST hold exactly one move, small enough to review in minutes
  and to revert on its own.

- The tests MUST have been green at every commit, not only at the end, so
  that any commit is a safe point to stop or roll back to.

- The improvement MUST be reported as a concrete measurement — lines,
  branches, imports, or responsibilities before and after. "This is cleaner"
  is not a result.

- The work MUST stop at a series of committed refactoring moves. Reviewing
  them, integrating the branch, and carrying out any behavior change the
  refactor surfaced MUST be left to the caller.

## Instructions

1.  State the quality you are improving, in one sentence naming the code and
    the defect.

    For example: "Improve cohesion: this module mixes order parsing with
    email rendering — split them." Or "Improve changeability: the price
    calculation is duplicated across three call sites — extract one helper."

2.  Verify the safety net before changing anything.

    Identify the tests covering the target code, run them, and confirm they
    pass. A refactor is only safe if a fast, trustworthy suite can confirm
    that behavior was preserved.

    If coverage is thin, you MUST first add characterization tests — tests
    that pin down current behavior, whatever it happens to be — and commit
    them as their own maintenance change, separate from any refactoring
    commit.

3.  Plan the work as a sequence of small reversible moves.

    Each move MUST compile, pass the tests, and be revertible on its own.
    Size them like this: rename one symbol, extract one function, inline one
    variable, move one method, replace one conditional with a polymorphic
    dispatch. Not "restructure the auth subsystem".

4.  Execute one move at a time.

    Make the change, run the covering tests, confirm green, then commit that
    single move following whatever commit conventions the project documents,
    marked as a refactoring change. Only then start the next move.

    If the tests go red and the test itself was correct, revert to the last
    green state rather than adjusting the test.

5.  Watch for the refactor turning into a behavior change.

    The signals are: a previously passing test now fails, or you feel the
    urge to fix a bug or add a small feature while you are in here. In every
    case, revert to the last green state and leave the behavior change as a
    separate task.

6.  Re-evaluate against the named quality.

    Re-read the result with the original target in mind and point at the
    improvement: one responsibility where there were three, fewer branches,
    fewer imports across the boundary, a function a reader can grasp without
    scrolling. If you cannot point at it, the refactor was speculative and
    you SHOULD revert it.

## Rules

- A refactor MUST preserve externally observable behavior.

  The contract with reviewers and operators is that the tests pass before
  and after and the runtime behavior is identical. If you cannot promise
  that, what you are doing is not a refactor and MUST NOT be labeled as one.

- You MUST NOT bundle a refactor with a feature or a bug fix, and MUST NOT
  batch several moves into one commit.

  Mixed or oversized commits make it impossible to tell what changed
  behavior and what did not, and they remove the ability to roll back one
  move without losing the rest.

- You MUST NOT refactor code that has no tests and where you cannot quickly
  add characterization tests.

  Without a safety net you are guessing about behavior preservation, and
  nothing downstream can catch the mistake.

- You MUST improve one quality at a time.

  Improving cohesion, simplicity, and naming in the same pass produces a
  diff nobody can review. The others make good follow-ups.

- You SHOULD apply the deletion test before extracting or removing a module.

  Imagine the module deleted entirely. If complexity vanishes, it was a
  pass-through doing nothing the callers could not do inline, so remove it.
  If complexity reappears spread across the callers, it was earning its keep
  through locality, so keep it or deepen it — move more behavior behind the
  interface — rather than remove it. Run the test in reverse when tempted to
  extract something new: if deleting the proposed module from the imagined
  design would not re-spread complexity, the extraction is premature.

- You SHOULD NOT introduce an abstraction for a need that has not arrived.

  Wait for the second or third use case before extracting. One occurrence is
  just code.

- The diff SHOULD come out smaller than expected.

  A refactor that grows the codebase substantially is usually disguised
  feature work or premature abstraction, so treat a large positive diff as a
  signal to re-check the previous rules.

## Edge cases

- A move would redraw module boundaries, change a public interface, or alter
  the data model.

  This is a design change, not a refactor. Stop, keep whatever green moves
  you already committed, and report that the change needs to go through the
  project's design process first.

- The refactor reveals a bug.

  Stop. Commit the green moves already made, then report the bug so it can
  be fixed as its own task. Do not fix it inside the refactor, however small
  it looks, because the fix would be invisible among the restructuring.

- The target area is large legacy code with many problems at once.

  Pick one named quality for this session and sketch the remaining qualities
  as a sequence of later refactors. Attempting them all at once produces an
  unreviewable diff and loses the ability to revert selectively.

- The refactor is pre-emptive, meant to make an upcoming feature easier.

  Do this only where that feature is concretely planned. Restructuring for
  hypothetical future work is speculative and usually guesses wrong.

## Examples

- A small, named refactor in three moves:

  ```text
  Target quality: cohesion — OrderService does parsing, pricing, and
  persistence in one class.

  Move 1: extract OrderParser from OrderService.
    Pure extraction; OrderService delegates. All tests pass.

  Move 2: extract PriceCalculator from OrderService.
    Pure extraction; OrderService delegates. All tests pass.

  Move 3: rename OrderService to OrderRepository.
    The remaining responsibility is persistence; the name now says so.
    All tests pass.

  Result: three modules with one responsibility each, 210 lines down to
  three files of 60-80 lines, no test file touched.
  ```

- Recognizing a behavior change mid-refactor:

  ```text
  While extracting OrderParser, the original code accepted negative
  quantities silently and the extracted version throws. That is a bug fix,
  not a refactor. Reverted the throw, kept the extraction, and reported the
  negative-quantity handling as a separate defect to be fixed on its own.
  ```
