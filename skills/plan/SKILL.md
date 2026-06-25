---
name: plan
description: Break delivery of a designed change into a sequence of small, independently mergeable steps. Each step is shippable, testable, and reversible on its own. Use after the design is agreed and before any implementation begins. Use whenever a change is bigger than a single commit or touches multiple seams, or when the user says "break this design into steps", "plan the implementation", or "how should we sequence this work?".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: qwen3.5:9b
---

# `/plan`

Use this skill after the design is captured (and, where needed, sharpened) and before writing any code, whenever the change is larger than one atomic commit or touches multiple seams of the system. It decomposes an already-agreed design into a sequence of deliverable steps, consumed one at a time by the downstream build loop; it writes no code itself.

**Input**: An agreed design (the chosen option) and the acceptance criteria it must deliver, for a change larger than one atomic commit or touching multiple seams. REQUIRED. The project's commit-type vocabulary and branch model inform how steps are labeled and integrated.

**Output**: A numbered checklist of small steps, each independently mergeable, testable, and reversible, ordered riskiest-first, with a mode tag (`HITL`/`AFK`), a stated pass/fail signal, any prior-step dependency, and any flag, fixture, or migration named where used. The plan is reported as the artefact and the skill stops; it writes no code itself.

##  Instructions

1.  **Restate the goal and constraints.**

    Pull the acceptance criteria from the specification and the chosen option from the design. State in one or two sentences what is being built and what the user-visible end state is. If this can't be stated cleanly, the specification or design is not ready — go back.

2.  **Find the thinnest first slice.**

    Identify the smallest end-to-end change that delivers user-visible value OR materially de-risks the rest of the work. Examples:

    - A walking skeleton: a request flows from the UI through every new layer to a stubbed response, with no real logic.
    - The riskiest integration done first against a real dependency.
    - A feature-flagged path that exercises the new code without exposing it.

    The first slice anchors the plan. Everything afterward extends it.

3.  **Decompose into steps.**

    Each step MUST satisfy all of:

    - *Independently mergeable*: can be integrated into `dev` on its own without breaking the build.
    - *Independently testable*: has a clear pass/fail signal (test, manual check, or measurable behavior).
    - *Reversible*: can be reverted without leaving the system in a worse state than before the step.
    - *Small*: ideally reviewable in under 30 minutes; certainly under one working day.

    If a step fails any of these, split it further.

4.  **Order by risk, not by ease.**

    Schedule the *riskiest* steps first — the integrations you are unsure about, the assumptions that might not hold, the components you don't fully understand. Discovering a flaw early costs one step's worth of rework; discovering it after eight steps costs eight.

    Easy and decorative work (polish, copy, secondary error paths) goes last.

5.  **Name the seams for parallel or deferred work.**

    Identify expansion points where:

    - A feature flag will hide incomplete work in `dev`.
    - A stub or fixture stands in for a dependency that lands later.
    - A schema migration is reversible and ships separately from the code that uses it.

    Naming these explicitly prevents accidental coupling between steps.

6.  **Write the plan.**

    Output a numbered checklist. For each step include:

    - A short imperative title (eg. "Step 3: add `/orders` POST endpoint, stubbed response").
    - A *mode tag*: `HITL` (human-in-the-loop — requires synchronous human input such as an architectural call, design review, or UI/UX sign-off) or `AFK` (away-from-keyboard — can be implemented and merged without further human input).
    - The pass/fail signal (test name, behavior to verify, metric to check).
    - Any dependency on a prior step.
    - Any flag, fixture, or migration involved.

    Keep step descriptions tight. The plan is a checklist, not a design doc — the design lives elsewhere.

7.  **Pressure-test the plan.**

    Before reporting the plan as ready, ask:

    - If step N fails review or test, can step N+1 still merge? (It should.)
    - If we stop after step K, is the system in a coherent state? (It should be.)
    - Does the user-visible behavior change only at the steps where it is meant to? (Hidden behavior changes are a smell.)

    If any answer is no, re-split or re-order.

##  Rules

-   **Each step ships independently.**

    "Step 5 of 8 is half-done in `dev`" is a planning failure. Either step 5 is mergeable on its own, or it is not a step.

-   **Risky first, easy last.**

    A plan that front-loads polish and back-loads the unknown maximizes the cost of being wrong. Reverse it.

-   **One concern per step.**

    Mixing a schema migration, a new endpoint, and a UI change into a single step turns a small problem into a tangled rollback. Split on concerns.

-   **Plans are revisable, not sacred.**

    The plan made before step 1 is the plan with the least information. Update it after each step as you learn. Re-order, split, drop steps — and note why.

-   **Feature flags are tools, not asks.**

    Use a flag when it lets you ship a step independently without exposing it. Don't add a flag to support a hypothetical future toggle. Remove the flag after the feature lands (track the cleanup as a final step).

-   **Prefer AFK over HITL.**

    Steps an agent can complete and merge without human input are cheaper, faster, and parallelizable. When a step truly requires a human (architectural call, design or UI review, manual verification, security sign-off), tag it `HITL` explicitly so the dependency on human time is visible up front — and so the plan can be re-ordered to cluster or front-load those steps when synchronous time is scarce.

-   **No step is "do everything else".**

    A vague final step ("polish and tests") hides scope. Enumerate what's in it, even briefly.

-   **Match commit type to step type.**

    Use the project's commit-type vocabulary. Most plan steps are `step:` commits (building blocks toward a user-facing change), with the final user-visible step typically `feature:`. Split refactor work into separate `refactor:` steps.

## Examples

A plan for "add an /orders POST endpoint with idempotency":

```
1. step: scaffold /orders route with stubbed 501 response and route test  [AFK]
   Pass: `curl -X POST /orders` returns 501; route test passes.

2. step: add Orders table migration (reversible)                          [AFK]
   Pass: `migrate up && migrate down` both succeed; no schema drift.

3. step: implement Order creation handler, no idempotency yet             [AFK]
   Pass: integration test posts an order, sees it in the DB.

4. step: add idempotency-key header handling                              [AFK]
   Pass: integration test posts the same order twice with the same key,
   sees one row.

5. feature: enable POST /orders behind ORDERS_API_V2 flag                 [HITL]
   Pass: flag on -> endpoint live; flag off -> 404.
   HITL because: requires SRE sign-off on the rollout plan.

6. chore: remove ORDERS_API_V2 flag (after rollout, scheduled separately) [AFK]
```

Risk-ordering example:

```
A change has three steps:
- (a) wire a new third-party billing SDK,
- (b) add a settings UI to display the new billing data,
- (c) update copy on the existing checkout page.

Correct order: a, b, c.
Wrong order: c, b, a.

The SDK integration carries unknown risk. Discovering an SDK
incompatibility on day 1 lets the team replan. Discovering it on day
3, after the UI and copy work are merged, wastes that work.
```

##  Edge cases

-   **The plan is a single step.**

    Fine. Skip the planning artifact and go straight to implementation. Don't manufacture three steps to justify the skill.

-   **A step turns out to be too big mid-implementation.**

    Pause coding, split the step in the plan, then resume on the first sub-step. Don't merge a half-step.

-   **A step uncovers a design flaw.**

    Stop. Loop back to the design with what you learned. Replan the remaining steps once the design is settled. Sunk cost is not a reason to push forward.

-   **Long-lived parallel work.**

    If steps will be done across weeks by multiple contributors and don't fit on `temp/*`, use an `epic/*` branch per the project's branching convention. The plan still applies; the integration target changes.

##  Success criteria

-   **Every step is independently mergeable, testable, and reversible.**

    Re-read each step with that filter. Anything that fails the filter is split.

-   **The first step is the thinnest plausible end-to-end slice.**

    Not the easiest. Not the most polished. The thinnest.

-   **Riskier steps come before easier ones.**

    Front-loaded risk is a feature of a good plan, not a flaw.

-   **Each step has a stated pass/fail signal.**

    A test name, a curl command, a metric threshold — something observable.

-   **Feature flags, fixtures, and migrations are named where used.**

    Implicit coupling between steps is called out.
