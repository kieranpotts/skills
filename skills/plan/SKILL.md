---
name: plan
description: >-
  Decompose an agreed design into a sequence of small, independently shippable
  delivery steps, ordered so the riskiest work lands first. Use after a design
  has been agreed and before implementation begins, whenever a change is larger
  than a single commit or touches multiple seams, or when the user says
  something like "break this design into steps", "plan the implementation", or
  "how should we sequence this work?". Do not use it to make architectural
  decisions, to write requirements, or to implement any of the steps.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep
license: CC0-1.0
---

# Plan

Break delivery of an agreed design into a sequence of steps, each one
independently mergeable, testable, and reversible, ordered so that the
unknowns are resolved first. This is planning only: you MUST NOT change the
software's code or configuration.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on the substance
of the task; if you cannot determine it, stop and alert the user with an error
message. You MAY prompt solely to establish where an artifact lives or how to
access it, when context and environment do not settle that.

- **An agreed design and its acceptance criteria — REQUIRED.** The chosen
  option and the acceptance criteria it must deliver, for a change larger than
  one atomic commit or touching multiple seams.

- **The project's commit-type vocabulary — REQUIRED.** The set of change types
  the project labels its commits with, which determines how each step is
  labeled. Discover it from the environment rather than inventing one.

- **The project's branch model — REQUIRED.** How work is integrated, which
  determines what each step merges into. Discover it the same way.

- **The design, specification, and plan stores — REQUIRED.** Where each lives
  and how to read or write it. Discover them: check this session's context
  first, then the environment — a convention file, a workspace manifest, an
  existing directory, a configured connector. Each MAY be a directory in this
  repository, a separate repository, or an external service such as a tracker
  or a wiki, so you MUST NOT assume a filesystem path, a file name, or a
  document structure. If neither context nor environment settles a store, ask
  the user to name it before going further.

## Success criteria

- The plan MUST be a numbered checklist of steps with tight descriptions, and
  MUST NOT restate or stand in for the design document.

- Every step MUST be independently mergeable, testable, and reversible.

- The first step MUST be the thinnest plausible end-to-end slice — not the
  easiest, not the most polished, the thinnest.

- Steps carrying unknowns MUST be scheduled ahead of steps that are merely
  laborious.

- Each step MUST carry an observable pass/fail signal: a test name, a command,
  a metric threshold — something a reader could run.

- Each step MUST carry a mode tag, any prior-step dependency, and any flag,
  fixture, or migration it involves.

- Each step SHOULD be reviewable in under 30 minutes, and MUST be reviewable
  in under one working day.

- The plan MUST be recorded in the project's own plan store, in that store's
  own form, with no second copy of it elsewhere.

- The software itself MUST be unchanged: no source file, configuration file,
  schema, or dependency manifest may have been written by this task.

## Instructions

1.  Restate the goal and constraints.

    Pull the acceptance criteria from the specification and the chosen option
    from the design, then state in one or two sentences what is being built
    and what the user-visible end state is. If this cannot be stated cleanly,
    the specification or design is not ready, and you MUST stop and send the
    user back rather than planning against a guess.

2.  Find the thinnest first slice.

    Identify the smallest end-to-end change that delivers user-visible value
    or materially de-risks the rest of the work. It MAY be:

    - A walking skeleton: a request flows from the UI through every new layer
      to a stubbed response, with no real logic.

    - The riskiest integration done first against a real dependency.

    - A flagged path that exercises the new code without exposing it.

    The first slice anchors the plan; everything afterward extends it.

3.  Decompose into steps.

    Split the work into the smallest steps that can be integrated, tested,
    and reverted independently.

4.  Order by risk, not by ease.

    Schedule the riskiest steps first — the integrations you are unsure
    about, the assumptions that might not hold, the components you do not
    fully understand. Discovering a flaw early costs one step's worth of
    rework; discovering it after eight steps costs eight. Easy and decorative
    work — polish, copy, secondary error paths — MUST go last.

5.  Name the seams for parallel or deferred work.

    Identify the expansion points where a feature flag will hide incomplete
    work, a stub or fixture stands in for a dependency that lands later, or a
    reversible schema migration ships separately from the code that uses it.
    You MUST name each flag, fixture, and migration on the step where it is
    used, so the dependency is visible to whoever picks that step up.

6.  Write the plan into the plan store.

    Output a numbered checklist of the steps, following whatever template,
    lifecycle, and format that store documents for itself.

7.  Pressure-test the plan before reporting it.

    Re-read each step against the mergeable, testable, reversible filter and
    split anything that fails. Then ask:

    - If step N fails review or test, can step N+1 still merge? It should.

    - If we stop after step K, is the system in a coherent state? It should
      be.

    - Does user-visible behavior change only at the steps where it is meant
      to? Hidden behavior changes are a smell.

    If any answer is no, you MUST re-split or re-order before reporting.

## Rules

- You MUST discover artifact locations and conventions; you MUST NOT assume
  them.

  This skill is used across projects that keep their artifacts in different
  places, in different formats, under different tools. A path, file name,
  template, or lifecycle state that is right in one project is wrong in the
  next. Resolve each store first, then follow whatever conventions it
  documents for itself.

- You MUST produce the plan and stop there.

  Implementing it is a separate act, done against the plan once someone has
  agreed to it. A plan written and executed in one breath never gets
  challenged.

- Each step MUST address one concern.

  Mixing a schema migration, a new endpoint, and a UI change into a single
  step turns a small problem into a tangled rollback. Split on concerns.

- A step MUST NOT be a catch-all.

  A vague final step ("polish and tests") hides scope, so enumerate what is
  in it, even briefly.

- You MUST label each step with the project's own commit-type vocabulary.

  Most steps are building blocks toward a user-facing change and take
  whichever type the project reserves for that; the step that finally exposes
  the change to users takes its user-facing type. Keep refactoring in its own
  steps under its own type, so a behavior-preserving change is never mixed
  with a behavioral one.

- You SHOULD treat the plan as revisable rather than sacred.

  The plan made before step 1 is the plan with the least information. Update
  it as the work teaches you things — re-order, split, drop steps — and note
  why.

- You SHOULD use a feature flag where it lets a step ship independently
  without exposing incomplete work, but MUST NOT add one to support a
  hypothetical future toggle.

  Every live flag is a branch in the runtime that someone has to reason
  about. Where a flag is used, the plan MUST carry a final step that removes
  it once the feature has landed.

- You SHOULD prefer steps an agent can complete unattended over steps that
  block on a human.

  Unattended steps are cheaper, faster, and parallelizable. Where a step
  truly needs a human — an architectural call, a design or UI review, manual
  verification, security sign-off — you MUST tag it as such, so the
  dependency on scarce human time is visible up front and the plan can be
  re-ordered to cluster or front-load those steps.

## Edge cases

- The work is genuinely a single step.

  Say so explicitly and direct the caller to proceed with implementation.
  Splitting an atomic change into ceremonial sub-steps costs review time and
  buys nothing.

- A step turns out to be too big once implementation starts.

  Pause the coding, split the step in the plan, then resume on the first
  sub-step. Do not merge a half-step.

- A step uncovers a flaw in the design.

  Stop and loop back to the design, then replan the remaining steps once it
  is settled. Sunk cost is not a reason to push forward.

- The plan will run for weeks across multiple contributors.

  The steps will outlive any short-lived branch, so integrate them on
  whichever shared branch the project's branch model provides for
  long-running work. The plan itself does not change; only the integration
  target does.

## Examples

- A plan for "add an /orders POST endpoint with idempotency":

  ```text
  1. step: scaffold /orders route, stubbed 501 response, route test  [AFK]
     Pass: `curl -X POST /orders` returns 501; route test passes.

  2. step: add Orders table migration (reversible)                   [AFK]
     Pass: `migrate up && migrate down` both succeed; no schema drift.

  3. step: implement Order creation handler, no idempotency yet      [AFK]
     Pass: integration test posts an order, sees it in the DB.

  4. step: add idempotency-key header handling                       [AFK]
     Pass: integration test posts the same order twice with the same
     key, sees one row.

  5. behavior: enable POST /orders behind ORDERS_API_V2 flag         [HITL]
     Pass: flag on -> endpoint live; flag off -> 404.
     HITL because: requires SRE sign-off on the rollout plan.

  6. chore: remove ORDERS_API_V2 flag, after rollout                 [AFK]
  ```

- Ordering three steps by risk: (a) wire a new third-party billing SDK,
  (b) add a settings UI to display the new billing data, (c) update copy on
  the existing checkout page.

  The correct order is a, b, c — not c, b, a. The SDK integration carries
  the unknown. Discovering an incompatibility on day 1 lets the team
  replan; discovering it on day 3, after the UI and copy work have merged,
  wastes that work.
