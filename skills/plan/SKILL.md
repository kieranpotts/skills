---
name: plan
description: >-
  Break delivery of a designed change into a sequence of small, independently
  mergeable steps. Each step is shippable, testable, and reversible on its own.
  Use after the design is agreed and before any implementation begins. Use
  whenever a change is bigger than a single commit or touches multiple seams, or
  when the user says "break this design into steps", "plan the implementation",
  or "how should we sequence this work?".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Plan

Break delivery of a designed change into a sequence of small, independently
mergeable steps.

**Input:**

- **An agreed design and its acceptance criteria. REQUIRED.** The chosen option
  and the acceptance criteria it must deliver, for a change larger than one
  atomic commit or touching multiple seams.

- **The project's commit-type vocabulary and branch model. REQUIRED.** These
  inform how steps are labeled and integrated.

This skill is non-interactive: agents MUST NOT block for user input after the
initial prompt, and MUST follow the instructions to completion or fail with an
error message.

**Output:**

A numbered checklist of small steps, each independently mergeable,
testable, and reversible, ordered riskiest-first, with a mode tag
(`HITL`/`AFK`), a stated pass/fail signal, any prior-step dependency, and any
flag, fixture, or migration named where used. The plan is reported as the
artifact and the skill stops; it writes no code itself.

## Instructions

1.  **Restate the goal and constraints.**

    You MUST pull the acceptance criteria from the specification and the chosen
    option from the design, and state in one or two sentences what is being built
    and what the user-visible end state is. If this can't be stated cleanly, the
    specification or design is not ready — you MUST go back.

2.  **Find the thinnest first slice.**

    You MUST identify the smallest end-to-end change that delivers user-visible
    value OR materially de-risks the rest of the work. Examples:

    - A walking skeleton: a request flows from the UI through every new layer to
      a stubbed response, with no real logic.

    - The riskiest integration done first against a real dependency.

    - A feature-flagged path that exercises the new code without exposing it.

    The first slice anchors the plan. Everything afterward extends it.

3.  **Decompose into steps.**

    You MUST split the work into the smallest steps that can be integrated,
    tested, and reverted independently.

4.  **Order by risk, not by ease.**

    You MUST schedule the *riskiest* steps first — the integrations you are unsure
    about, the assumptions that might not hold, the components you don't fully
    understand. Discovering a flaw early costs one step's worth of rework;
    discovering it after eight steps costs eight.

    Easy and decorative work (polish, copy, secondary error paths) SHOULD go last.

5.  **Name the seams for parallel or deferred work.**

    You SHOULD identify expansion points where:

    - A feature flag will hide incomplete work in `dev`.
    - A stub or fixture stands in for a dependency that lands later.
    - A schema migration is reversible and ships separately from the code that
      uses it.

    You MUST name any feature flag, fixture, or migration on the step where it is
    used.

6.  **Write the plan.**

    You MUST output a numbered checklist of the steps.

7.  **Pressure-test the plan.**

    Before reporting the plan as ready, you MUST ask:

    - If step N fails review or test, can step N+1 still merge? (It should.)

    - If we stop after step K, is the system in a coherent state? (It should
      be.)

    - Does the user-visible behavior change only at the steps where it is meant
      to? (Hidden behavior changes are a smell.)

    If any answer is no, you MUST re-split or re-order.

## Rules

- **Each step MUST address one concern.**

  Mixing a schema migration, a new endpoint, and a UI change into a single
  step turns a small problem into a tangled rollback. Split on concerns.

- **A step MUST NOT be a catch-all.**

  A vague final step ("polish and tests") hides scope. You MUST enumerate
  what's in it, even briefly.

- **Plans are revisable, not sacred.**

  The plan made before step 1 is the plan with the least information. You SHOULD
  update it after each step as you learn: re-order, split, drop steps — and
  note why.

- **Feature flags are tools, not asks.**

  You SHOULD use a flag when it lets you ship a step independently without
  exposing it. You MUST NOT add a flag to support a hypothetical future toggle.
  You MUST remove the flag after the feature lands (track the cleanup as a final
  step).

- **You SHOULD prefer AFK over HITL.**

  Steps an agent can complete and merge without human input are cheaper,
  faster, and parallelizable. When a step truly requires a human
  (architectural call, design or UI review, manual verification, security
  sign-off), you MUST tag it `HITL` explicitly so the dependency on human time
  is visible up front — and so the plan can be re-ordered to cluster or
  front-load those steps when synchronous time is scarce.

- **You MUST match commit type to step type.**

  Use the project's commit-type vocabulary. Most plan steps are `step:`
  commits (building blocks toward a user-facing change), with the final
  user-visible step typically `feature:`. Split refactor work into separate
  `refactor:` steps.

- **If a step turns out to be too big mid-implementation, you MUST pause coding,
  split the step in the plan, then resume on the first sub-step.**

  Don't merge a half-step.

- **If a step uncovers a design flaw, you MUST stop and loop back to the design.**

  Replan the remaining steps once the design is settled. Sunk cost is not a
  reason to push forward.

- **If steps will be done across weeks by multiple contributors and don't fit on
  `temp/*`, you MUST use an `epic/*` branch per the project's branching
  convention.**

  The plan still applies; the integration target changes.

## Success criteria

- **The plan MUST be a numbered checklist of steps.**

- **Every step MUST be independently mergeable, testable, and reversible.**

  Re-read each step with that filter. Anything that fails the filter MUST be
  split.

- **Each step SHOULD be reviewable in under 30 minutes, and certainly under one
  working day.**

- **The first step MUST be the thinnest plausible end-to-end slice.**

  Not the easiest. Not the most polished. The thinnest.

- **Riskier steps MUST come before easier ones.**

  Front-loaded risk is a feature of a good plan, not a flaw.

- **Each step MUST have a stated pass/fail signal.**

  A test name, a curl command, a metric threshold — something observable.

- **Each step MUST include a mode tag (`HITL` or `AFK`), any prior-step
  dependency, and any flag, fixture, or migration involved.**

- **Step descriptions MUST be tight.**

  The plan MUST NOT substitute for the design document.

- **If the plan is a single step, the output MUST say so explicitly and direct
  the caller to proceed with implementation rather than returning a plan
  artifact.**

## Examples

- **A plan for "add an /orders POST endpoint with idempotency":**

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

- **Risk-ordering example:**

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
