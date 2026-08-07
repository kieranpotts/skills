---
name: refine
description: >-
  Revise a requirements specification in response to acceptance testing
  feedback or to real-world use of shipped software. Use when a failing
  acceptance criterion turns out to reflect a specification error, when
  exploratory testing exposes a specification gap, when a stakeholder
  reports an unmet need against shipped behavior, when an NFR threshold
  proves wrong in practice, or when the user says "refine the spec based on
  this feedback", "the acceptance criteria are wrong — fix the requirements",
  or "update the specification to match what we learned". Do not use it to
  correct code that drifted from a criterion that was already right, nor to
  specify a net-new feature.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep
license: CC0-1.0
---

# Refine

Revise the requirements specification in response to feedback from acceptance
testing, or from real-world use of working software. Capture what was learned,
and refine the acceptance criteria it disproved. Do not change code or tests.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification. Ask one question at a time, and wait for
the answer before continuing.

- **A feedback trigger — REQUIRED.** The event that prompted the refinement:
  a failing acceptance criterion, an exploratory-testing finding, a
  stakeholder report against shipped behavior, an NFR threshold proven wrong
  in practice, or a contradiction between two criteria.

- **Evidence for the trigger — REQUIRED.** The observation that makes the
  change defensible: a test name, a measurement, a stakeholder quote, a UX
  session. Ask for it if the trigger arrives without one.

- **The specification store — REQUIRED.** Where the requirements live, and
  how to edit them. Discover it rather than assuming it: check this session's
  context first, then the environment (a convention file, a workspace
  manifest, a configured connector). If neither settles it, ask. The store
  MAY be a directory in this repository, a separate repository, or an
  external service, so do not assume a filesystem path, a file name, or a
  document structure.

- **Where the rationale is filed — OPTIONAL.** A commit body, a pull request
  description, or a refinement log the store keeps for itself. Follow the
  store's own convention where it has one; otherwise present the rationale
  alongside the edit.

## Success criteria

- Edits to the requirements artifacts MUST exist in the resolved store,
  expressed in that store's own conventions for acceptance criteria,
  measurable NFRs, and the explicit scope boundary.

- Each edit MUST be presented as before and after, so a reviewer sees what
  changed without diffing it in their head. For an addition, the "before"
  MUST state plainly that nothing was specified.

- A rationale MUST be filed with the edit, naming the trigger, the type of
  change, and the evidence — why, not just what, so a future reader can
  reconstruct the decision without re-litigating it.

- Every acceptance criterion the refinement touches MUST end up in testable
  form, including one that was untestable before the pass.

- A downstream impact list MUST accompany the edit, naming each affected
  design decision, delivery step, code increment, and test case, and marking
  each as needing adjustment, re-verification, or no change. Nothing MUST be
  left silently invalidated.

- Any further gaps noticed during the pass MUST be recorded as follow-up
  items outside this refinement's edit.

- Application code and test code MUST be unchanged. This skill produces a
  specification change and stops there.

## Instructions

1.  Name the trigger in one sentence, and state the evidence behind it.

    Without a named trigger you are not refining, you are second-guessing.
    Typical triggers are a test failure that on inspection reflects a
    specification error rather than a code defect; a scenario nobody
    anticipated, surfaced by exploratory testing; stakeholder feedback that
    "this is what we said, but not what we needed"; a measured NFR that sits
    inside its threshold while the experience is still unacceptable, or the
    reverse; an item that turns out to be in scope after being excluded; or
    a contradiction between two criteria.

2.  Resolve the specification store, then locate the exact artifact to
    change — the scenario, the NFR bullet under its heading, the
    out-of-scope entry, the constraint or assumption. You SHOULD read the
    surrounding material too, since a wrong criterion often has neighbors
    that assume it.

    If the requirement was never captured at all, say so. The refinement is
    then an addition rather than an edit.

3.  Classify the change before drafting it, because each type carries
    different consequences downstream:

    - Correction — an existing criterion is wrong and needs rewriting. The
      most common case.

    - Addition — a missing criterion needs adding: a new scenario, a new
      NFR, a new out-of-scope entry.

    - Removal — a criterion was over-specified and should go. Rare, and
      worth resisting: people often judge a criterion wrong when it is the
      implementation that is wrong.

    - Reclassification — an item moves between scope and out-of-scope,
      between functional and non-functional, or between blocking and
      deferred.

    - Threshold adjustment — an NFR target is loosened or tightened, with
      new justification.

4.  Draft the edit in the store's own form, and present it as before and
    after.

5.  Record the rationale: why the previous version was wrong, what evidence
    convinced you, and what ruled out the alternative readings. File it
    wherever the store keeps such records.

6.  Trace the downstream impact before declaring the refinement done.
    Refining a specification is rarely free. Ask which design decisions
    assumed the old criterion, which planned delivery steps are now wrong,
    which code increments must change, and which test cases need updating.
    Mark each as adjust, re-verify, or no change.

7.  Report the refined specification, the rationale, the downstream impact
    list, and any follow-up items you deliberately left out of this pass.
    Confine the report to what is required, not how to build it.

## Rules

- You MUST refine the specification, not the code.

  If the right response is to fix the implementation to match an existing
  criterion, that is a defect fix and outside this skill. Refinement applies
  when the criterion itself was wrong, missing, or ambiguous.

- You MUST NOT silently rewrite a criterion that previously passed.

  A criterion that passed, in testing or in production, is part of the
  contract with users and stakeholders. Changing it without explicit
  acknowledgment is how regressions arrive disguised as cleanups. Record
  the change, the reason, and what was previously promised.

- Evidence for the change is REQUIRED.

  A change driven by "I thought about it more" is suspect. Tie it to an
  observation, and put that observation in the rationale.

- You MUST make one refinement per logical change, and queue the rest.

  Bundling unrelated specification edits produces a diff nobody can review.
  A pass often surfaces other latent gaps: note them and raise tracking
  items, but do not absorb them into the current edit.

- Refinements MUST conform to the store's own specification conventions.

  Read those conventions from the store and follow them; you MUST NOT
  impose a format of your own. A refinement that breaks the store's
  conventions is no better than the criterion it replaced.

- You MUST discover the specification store rather than assume it, because
  this skill runs against projects that keep requirements in different
  places and formats.

- You SHOULD distinguish a specification that was wrong from a stakeholder
  who changed their mind.

  Both produce an edit, but the framing matters. A change of mind is
  unremarkable and should be recorded as such. A specification that
  misrepresented the need from day one is a process failure worth naming,
  so the next specification does not repeat it.

- Refinement MUST NOT be used to expand scope.

  Net-new capability that was never part of the original ask is a new
  specification, not a refinement. Capture it separately.

## Edge cases

- Nothing was ever written down: the requirement exists only as shared
  assumption.

  Write the assumed specification first, in the store's conventions, and
  mark it as reconstructed. Then apply the refinement to it, so the record
  shows both the assumption that was operating and the correction to it.

- Stakeholders disagree over whether the specification was wrong.

  You MUST NOT refine unilaterally. Surface the disagreement, capture both
  positions with their evidence, and route it to whatever decision process
  the project uses.

- The refinement contradicts a feature that has already shipped.

  Flag the need for a deprecation or migration story, and a design pass,
  before assuming the change can land. Existing users are relying on the
  behavior the old criterion described.

- A stakeholder reframes a new feature as something "we always wanted".

  Push back and route the ask through a fresh specification. Refinement
  leaves the purpose of the original specification intact; expansion
  replaces it.

## Examples

- A correction triggered by a failing acceptance criterion:

  ```text
  Trigger: AC-3 (same idempotency key returns same order) — FAIL in test;
           on inspection the specification mandates 200 OK, but the agreed
           contract with the SDK team is 200 OK plus a warning header.

  Type:    Correction.

  Locate:  features/orders/idempotent-create.feature, scenario "same key
           returns same order".

  Before:
    Then the response status is 200
    And the response body matches the original order

  After:
    Then the response status is 200
    And the response body matches the original order
    And the response includes a header "X-Idempotent-Replay: true"

  Rationale: Confirmed with the SDK team on 2026-05-14 — the header is
  required for their retry-logic instrumentation. The original
  specification omitted it; the integration test correctly caught the gap.

  Downstream impact:
    - design: no change (the header is a presentation detail)
    - code: adjust — handler in orders/create.ts must add the header
    - test: adjust — orders.spec.ts:89 assertion
  ```

- An addition triggered by exploratory testing:

  ```text
  Trigger: Exploratory pass found that replaying an idempotency key 24h
           later behaves inconsistently — the TTL was never specified.

  Type:    Addition (missing criterion).

  Locate:  features/orders/idempotent-create.feature — new scenario.

  Before:  Nothing specified for expiry of an idempotency key.

  After (added scenario):
    Scenario: Idempotency key beyond TTL window
      Given an order was created with idempotency key "abc-123"
      And 24 hours have passed
      When a new order is submitted with the same key
      Then the response status is 201
      And a new order is created

  Rationale: The TTL was an unstated assumption; the design picked 24h
  following Stripe's convention. Product team confirmed 24h on 2026-05-15.

  Downstream impact:
    - design: no change — ADR-014 already records the 24h TTL choice
    - code: adjust — the TTL purge job needs a boundary test
    - test: adjust — new acceptance scenario above
  ```

- A threshold adjustment:

  ```text
  Trigger: NFR "p95 latency < 200ms" measured at 188ms in test; users
           still report slowness. UX research shows perceived slowness
           starts at 150ms for this interaction.

  Type:    Threshold adjustment (tightened).

  Before:  p95 API latency < 200ms at 500 RPS sustained.
  After:   p95 API latency < 150ms at 500 RPS sustained.

  Rationale: User research session 2026-05-12, n=8 — the threshold of
  perceived slowness is 150ms for this checkout interaction. The original
  200ms was a guess, now disproven.

  Downstream impact:
    - design: adjust — re-evaluate the cache strategy
    - plan: adjust — add a performance-tightening increment
    - test: re-verify — perf suite against the new threshold (now FAIL)
  ```
