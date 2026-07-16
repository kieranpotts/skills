---
name: refactor
description: >-
  Improve the internal quality of existing code without changing its observable
  behavior. Tests pass before and after. Each step is small and reversible. Use
  when readability, structure, coupling, naming, or other design qualities need
  work — distinct from bug fixes and feature work — or when the user says
  "refactor this for readability", "clean up the structure of this module", or
  "reduce the coupling here without changing behavior".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programmer
---

# Refactor

**Input:** Existing, tested code and a named target quality. REQUIRED. The code to restructure plus the single design quality (readability, structure, coupling, naming, decomposition) being improved. This skill does not invent the goal from scratch; it consumes a quality to improve and a passing safety net to preserve.

**Output:** A series of small `refactor:` commits that improve the named quality
  while leaving externally observable behavior identical — tests green before and
  after every move, each commit independently revertable, the diff free of feature
  or bug-fix work. Whatever reviews, integrates, or sequences the next task is the
  orchestrator's concern, not this skill's.

**Interactivity:** Agents MUST NOT block for user input after the initial
prompt. Agents MUST follow this skill's instructions to completion, or fail
with an error message.

##  Instructions

1.  **Name the quality you are improving.**

    Refactoring without a named target produces aimless churn. Pick from the
    design qualities and state it:

    - "Improve *cohesiveness*: this module mixes order parsing with email
      rendering — split them."
    - "Improve *simplicity*: this 4-level inheritance hierarchy can collapse
      into a single function."
    - "Improve *changeability*: the price calculation is duplicated across three
      call sites — extract one helper."
    - "Improve *habitability*: the variable names obscure what the function
      does."

    If you cannot name the target quality, you are not refactoring — you are
    rearranging.

2.  **Verify a safety net exists.**

    A refactor is only safe if a fast, trustworthy test suite confirms behavior
    preservation. Before changing anything:

    - Identify the tests that cover the code being touched.
    - Run them; confirm they pass.
    - If coverage is thin, add *characterization tests* first — tests that pin
      down the current behavior, whatever it is. This is a separate prior step
      (commit as `step:` or `maintenance:`).

3.  **Plan the refactor in small reversible moves.**

    A good refactor is a sequence of *minute* changes, each of which:

    - Compiles.
    - Passes tests.
    - Could be reverted on its own.

    Typical move sizes: rename one symbol, extract one function, inline one
    variable, move one method, replace one conditional with a polymorphic
    dispatch. Not "restructure the auth subsystem".

4.  **Execute one move at a time.**

    For each move:

    1. Make the change.
    2. Run the relevant tests.
    3. Confirm green.
    4. Commit as `refactor:` using the project's commit format.
    5. Move to the next.

5.  **Watch for behavior changes.**

    Several signals indicate the refactor has crossed into "behavior change":

    - A test that passed before now fails (and the test itself was correct).
    - You feel the urge to "fix this bug while I'm here".
    - You feel the urge to "add this small feature while I'm restructuring".

    Stop. Revert to the last green state. The behavior change is a separate task
    (a bug fix or a feature step), with its own commit and its own review.

6.  **Re-evaluate against the named quality.**

    After the moves, re-read the code with the original target quality in mind.
    Did the change actually improve it? Quality improvements should be
    observable:

    - Cohesion: a module now has one responsibility instead of three.
    - Simplicity: line count dropped, branching dropped, indirections dropped.
    - Coupling: imports between modules dropped.
    - Habitability: a reader can answer "what does this do" without scrolling.

    If you can't point at the improvement, the refactor was speculative —
    consider reverting.

7.  **Commit and integrate.**

    Each move is a `refactor:` commit. A series of related moves forms the
    branch. Integrate via the project's branching conventions — typically a
    short-lived `temp/*` branch fast-forwarded into `dev`.

##  Rules

-   **A refactor MUST preserve externally observable behavior.**

    A refactor that changes externally observable behavior is mislabeled. The
    contract with reviewers and operators is that tests MUST pass before and
    after, and runtime behavior MUST be identical. If you cannot promise that, it
    is not a refactor.

-   **You MUST work in small, reversible moves.**

    Big-bang restructuring is a recipe for unreviewable diffs and unrevertable
    mistakes. Refactor in moves a reviewer can hold in their head.

-   **You MUST NOT batch multiple moves into a single `refactor:` commit.**

    Granularity is what makes refactors safe to roll back and easy to review.

-   **You MUST NOT bundle a refactor with a feature or a bug fix.**

    Mixed commits make it impossible to tell what changed behavior and what
    didn't. Refactor first as `refactor:` commits; then change behavior as
    `feature:`, `fix:`, or `step:` commits.

-   **If coverage is thin or absent, you MUST add characterization tests as a
    prior `maintenance:` or `step:` commit, or defer the refactor.**

    No tests = no safety net = no refactor. Do not press on without coverage.

-   **You MUST NOT refactor code that has no tests and where you cannot quickly
    add some.**

    Without a safety net, you are guessing.

-   **You MUST NOT continue if a behavior change is detected mid-refactor.**

    Revert to the last green state and treat the behavior change as a separate
    bug-fix or feature task.

-   **You MUST stop before adding speculative flexibility.**

    A refactor that introduces an abstraction for a future need is usually a
    guess. You SHOULD wait for the second or third use case before extracting;
    one occurrence is just code.

-   **You MUST apply the deletion test.**

    When considering removing or inlining a module, imagine deleting it
    entirely. If complexity *vanishes* — the module was a pass-through doing
    nothing the callers couldn't trivially do inline — delete it. If complexity
    *reappears spread across the callers*, the module was earning its keep
    through locality; either keep it as-is, or *deepen* it (move more behavior
    behind the interface) rather than remove it.

    The test works in reverse too: when tempted to *extract* a new module, ask
    whether deleting it from the imagined design would re-spread complexity
    across callers. If the answer is no, the extraction is premature.

    This rule pairs with the design principle "prefer deep modules to shallow
    ones": that principle is the *target*, this one is the *diagnostic*.

-   **You MUST improve one quality at a time.**

    Trying to improve cohesion, simplicity, and naming in the same commit
    produces a diff nobody can review. Pick one. The others can be follow-ups.

-   **The diff SHOULD be smaller than expected.**

    A refactor that *grows* the codebase substantially is usually disguised
    feature work or premature abstraction. Be suspicious of large positive
    diffs.

-   **If the refactor reveals a bug, you MUST stop the refactor.**

    Commit any green moves already made, then switch to fixing the bug as its own
    task. Resume the refactor afterward.

-   **If a move redraws module boundaries, changes a public interface, or alters
    the data model, it is a design change, not a refactor.**

    Send it back through design first.

-   **A pre-emptive refactor to make the next feature easier is allowed only when
    the next feature is concretely planned.**

    Refactoring for hypothetical future work is speculative and often wrong.

-   **If the target area is large legacy with many problems, you MUST pick one
    named quality per refactor session and plan a sequence of refactors over time.**

    Do not try to fix it all at once.

##  Examples

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

##  Success criteria

-   **External behavior MUST be unchanged.**

    Every test that passed before MUST pass after. Manual smoke of the affected
    paths MUST confirm no observable difference.

-   **The named quality MUST be measurably improved.**

    State which quality and how it changed (lines, dependencies,
    responsibilities, names). Vague "this is cleaner" is not enough.

-   **Each commit MUST be a single small move.**

    Reviewable in minutes. Revertable on its own.

-   **The diff MUST contain only restructuring.**

    No feature or bug-fix work MUST be mixed in. Anything else MUST be in a
    separate commit and a separate review thread.

-   **Tests MUST have passed after every move, not just at the end.**

-   **The PR description MUST name the quality being improved and the moves taken.**
