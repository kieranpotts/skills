---
name: refactor
description: Improve the internal quality of existing code without changing its observable behavior. Tests pass before and after. Each step is small and reversible. Use when readability, structure, coupling, naming, or other design qualities need work - distinct from bug fixes ([`debug`](../debug/SKILL.md)) and feature work ([`code`](../code/SKILL.md)).
license: MIT
---

# Refactor

Use this skill when improving internal code quality - readability, structure, coupling, naming, decomposition - without changing what the code does from the outside.

Do NOT use this skill to fix a defect (use [`debug`](../debug/SKILL.md)) or to add behavior (use [`code`](../code/SKILL.md)). Do NOT use it for presentation-only changes like whitespace, indentation, or import ordering (use [`format`](../format/SKILL.md)) - those are noise that hides real refactoring intent. Bundling refactors with feature work or bug fixes obscures intent in the diff and complicates rollback.

A change that alters externally observable behavior is not a refactor. Even a "small" behavior tweak in the middle of restructuring is a separate change.

## Instructions

1.  **Name the quality you are improving.**

    Refactoring without a named target produces aimless churn. Pick from the nine design qualities (see [`design`](../design/SKILL.md)) and state it:

    - "Improve *cohesiveness*: this module mixes order parsing with email rendering - split them."
    - "Improve *simplicity*: this 4-level inheritance hierarchy can collapse into a single function."
    - "Improve *changeability*: the price calculation is duplicated across three call sites - extract one helper."
    - "Improve *habitability*: the variable names obscure what the function does."

    If you cannot name the target quality, you are not refactoring - you are rearranging.

2.  **Verify a safety net exists.**

    A refactor is only safe if a fast, trustworthy test suite confirms behavior preservation. Before changing anything:

    - Identify the tests that cover the code being touched.
    - Run them; confirm they pass.
    - If coverage is thin, add *characterization tests* first - tests that pin down the current behavior, whatever it is. This is a separate prior step (commit as `step:` or `maintenance:`).

    Never refactor code that has no tests and where you cannot quickly add some. Without a safety net, you are guessing.

3.  **Plan the refactor in small reversible moves.**

    A good refactor is a sequence of *minute* changes, each of which:

    - Compiles.
    - Passes tests.
    - Could be reverted on its own.

    Typical move sizes: rename one symbol, extract one function, inline one variable, move one method, replace one conditional with a polymorphic dispatch. Not "restructure the auth subsystem".

4.  **Execute one move at a time.**

    For each move:

    1. Make the change.
    2. Run the relevant tests.
    3. Confirm green.
    4. Commit as `refactor:` (see [`commit`](../commit/SKILL.md)).
    5. Move to the next.

    Do NOT batch moves into one commit. Granularity is what makes refactors safe to roll back and easy to review.

5.  **Watch for behavior changes.**

    Several signals indicate the refactor has crossed into "behavior change":

    - A test that passed before now fails (and the test itself was correct).
    - You feel the urge to "fix this bug while I'm here".
    - You feel the urge to "add this small feature while I'm restructuring".

    Stop. Revert to the last green state. The behavior change is a separate task (a [`debug`](../debug/SKILL.md) fix or a [`code`](../code/SKILL.md) step), with its own commit and its own review.

6.  **Re-evaluate against the named quality.**

    After the moves, re-read the code with the original target quality in mind. Did the change actually improve it? Quality improvements should be observable:

    - Cohesion: a module now has one responsibility instead of three.
    - Simplicity: line count dropped, branching dropped, indirections dropped.
    - Coupling: imports between modules dropped.
    - Habitability: a reader can answer "what does this do" without scrolling.

    If you can't point at the improvement, the refactor was speculative - consider reverting.

7.  **Commit and integrate.**

    Each move is a `refactor:` commit. A series of related moves forms the branch. Integrate via [`branch`](../branch/SKILL.md) conventions - typically a short-lived `temp/*` branch fast-forwarded into `dev`.

    The PR description names the quality being improved and the moves taken.

## Rules

-   **Behavior preservation is non-negotiable.**

    A refactor that changes externally observable behavior is mislabeled. The contract with reviewers and operators is that tests pass before and after, and runtime behavior is identical. If you cannot promise that, it is not a refactor.

-   **Small, reversible moves.**

    Big-bang restructuring is a recipe for unreviewable diffs and unrevertable mistakes. Refactor in moves a reviewer can hold in their head.

-   **Never bundle a refactor with a feature or a bug fix.**

    Mixed commits make it impossible to tell what changed behavior and what didn't. Refactor first as `refactor:` commits; then change behavior as `feature:`, `fix:`, or `step:` commits.

-   **Tests pass after every move, not just at the end.**

    "I'll fix the tests at the end" is how subtly wrong refactors ship. If a test fails mid-refactor, stop and resolve before moving on.

-   **Add characterization tests when coverage is thin.**

    No tests = no safety net = no refactor. Adding pin-down tests for current behavior is a separate prior commit, not part of the refactor itself.

-   **Stop before adding speculative flexibility.**

    A refactor that introduces an abstraction for a future need is usually a guess. Wait for the second or third use case before extracting; one occurrence is just code.

-   **Apply the deletion test.**

    When considering removing or inlining a module, imagine deleting it entirely. If complexity *vanishes* - the module was a pass-through doing nothing the callers couldn't trivially do inline - delete it. If complexity *reappears spread across the callers*, the module was earning its keep through locality; either keep it as-is, or *deepen* it (move more behavior behind the interface) rather than remove it.

    The test works in reverse too: when tempted to *extract* a new module, ask whether deleting it from the imagined design would re-spread complexity across callers. If the answer is no, the extraction is premature.

    This rule pairs with "Prefer deep modules to shallow ones" in [`design`](../design/SKILL.md): that rule is the *target*, this one is the *diagnostic*.

-   **One quality at a time.**

    Trying to improve cohesion, simplicity, and naming in the same commit produces a diff nobody can review. Pick one. The others can be follow-ups.

-   **The diff should be smaller than expected.**

    A refactor that *grows* the codebase substantially is usually disguised feature work or premature abstraction. Be suspicious of large positive diffs.

## Examples

A small, named refactor in three moves:

```
Target quality: cohesiveness — OrderService currently does parsing,
pricing, and persistence in one class.

Move 1: refactor: extract OrderParser from OrderService
  - Pure extraction; OrderService delegates.
  - All tests pass.

Move 2: refactor: extract PriceCalculator from OrderService
  - Pure extraction; OrderService delegates.
  - All tests pass.

Move 3: refactor: rename OrderService to OrderRepository
  - The remaining responsibility is persistence; the new name reflects
    it.
  - All tests pass.

Result: three modules with one responsibility each, replacing one
module with three.
```

Recognizing a behavior change mid-refactor:

```
While extracting OrderParser I noticed the original code accepted
negative quantities silently and the new code throws. That's a bug
fix, not a refactor. Reverted the throw; opened a separate fix:
commit and tracking issue. Resumed the refactor.
```

## Edge cases

-   **Coverage is absent and impossible to add quickly.**

    Refactoring without a safety net is gambling. Two options: (a) treat the missing tests as the work itself - a `maintenance:` step to add characterization tests, before any refactor; (b) defer the refactor. Do not press on without coverage.

-   **The refactor reveals a bug.**

    Common. Stop the refactor. Commit any green moves already made. Switch to [`debug`](../debug/SKILL.md) for the bug. Resume the refactor afterward.

-   **The "refactor" is actually a design change.**

    If the move you want to make redraws module boundaries, changes a public interface, or alters the data model, it is a design change, not a refactor. Loop back through [`design`](../design/SKILL.md) first.

-   **Pre-emptive refactor "to make the next feature easier".**

    Justifiable, but only when the next feature is concretely planned (you are about to start it). Refactoring for hypothetical future work is speculative and often wrong.

-   **Large legacy area, lots wrong with it.**

    Don't try to fix it all at once. Pick one named quality per refactor session. Plan a sequence of refactors over time. The whole codebase does not need to improve in one PR.

## Success criteria

-   **External behavior is unchanged.**

    Every test that passed before passes after. Manual smoke of the affected paths confirms no observable difference.

-   **The named quality is measurably improved.**

    State which quality and how it changed (lines, dependencies, responsibilities, names). Vague "this is cleaner" is not enough.

-   **Each commit is a single small move.**

    Reviewable in minutes. Revertable on its own.

-   **No feature or bug-fix work is mixed in.**

    The diff contains only restructuring. Anything else is in a separate commit and a separate review thread.

-   **Tests passed after every move, not just at the end.**

## References

- [TS-10: Software Design Qualities](https://github.com/kieranpotts/standards/tree/dev/ts/010): The nine qualities to target. Read when picking which quality this refactor improves.

- [TS-13: Code Design](https://github.com/kieranpotts/standards/tree/dev/ts/013): Decomposition, naming, dependency management. Read for the patterns most refactors apply.

- [`review`](../review/SKILL.md): Common upstream trigger - review surfaces an internal-quality finding that needs structural work.

- [`design`](../design/SKILL.md): When the change is bigger than a refactor and crosses module boundaries. Refactor escalates to design when module boundaries, interfaces, or data models would have to change.

- [`debug`](../debug/SKILL.md): When a refactor uncovers a defect.

- [`code`](../code/SKILL.md): When the work is adding behavior, not restructuring.

- [`format`](../format/SKILL.md): When the change is presentation only (whitespace, style, ordering) and does not touch structure.

- [`commit`](../commit/SKILL.md): `refactor:` type and atomic-commit rules.
