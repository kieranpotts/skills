---
name: refine
description: >-
  Revise the requirements specification in response to feedback from acceptance
  testing or use of the working software. Capture what was learned, identify
  which ACs are wrong, missing, or ambiguous, and propose precise edits back
  into the specification. Use when testing surfaces a specification gap, a
  stakeholder reports unmet need against shipped behavior, or an NFR threshold
  turns out to be wrong in practice, or when the user says "refine the spec
  based on this feedback", "the acceptance criteria are wrong — fix the
  requirements", or "update the specification to match what we learned".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/product-manager
---

# Refine

Use this skill when testing surfaces a problem with the *specification itself* —
an acceptance criterion that is wrong, missing, contradictory, or ambiguous — or
when a stakeholder reviewing the working software identifies a requirement the
specification failed to capture. The boundary is sharp: if the specification was
right and the code was wrong, you are not refining; if the specification was
wrong and the code matches it, you are. The output is a set of precise edits to
the specification, ready to flow forward into design, planning, and
implementation; it changes no code itself.

## Interface

**Input**: A feedback trigger against an existing specification — a failing
acceptance criterion, an exploratory-testing finding, a stakeholder report
against shipped behavior, or an NFR threshold proven wrong in practice.
REQUIRED.

**Interactive**: This skill is interactive. It gathers the rest of its input
from the user through prompts during the session.

**Output**: Precise edits to the requirements artifacts, conforming to the
specification conventions (Gherkin, measurable NFRs, explicit scope), each with
a recorded trigger, type, and rationale; plus a traced list of downstream
design, planning, code, and test work the refinement implies. The output is
reported and the skill stops; it changes no code itself.

##  Instructions

1.  **Name the trigger.**

    State, in one sentence, what feedback prompted the refinement. Possible
    triggers:

    - *AC failure in testing that, on inspection, reflects a specification
      error*: the test correctly verified what the specification demanded, but
      the demand was wrong.
    - *Specification gap revealed by exploratory testing*: a scenario nobody
      anticipated.
    - *Stakeholder feedback on working software*: "this is what we said, but
      it's not what we needed".
    - *NFR threshold mismatch*: the measured number is inside the threshold but
      the user experience is still unacceptable (or vice versa — the threshold
      was over-strict).
    - *Out-of-scope item turns out to be in scope* (or vice versa).
    - *Contradiction between two ACs* surfaced during implementation or testing.

    Without a named trigger, you are not refining — you are second-guessing.

2.  **Locate the specific specification artefact to change.**

    Identify exactly which document, file, or section is wrong:

    - A `.feature` file and a specific scenario.
    - An NFR bullet under a named heading.
    - An out-of-scope entry.
    - A constraint, assumption, or stakeholder note.

    If the requirement was never captured at all — a true gap — say so. The
    refinement is then an *addition*, not an *edit*.

3.  **Decide the type of change.**

    Classify before drafting:

    - *Correction*: an existing AC is wrong and MUST be rewritten. (The most
      common case.)
    - *Addition*: a missing AC MUST be added. New scenario, new NFR, new
      out-of-scope entry.
    - *Removal*: an AC was over-specified and MUST be deleted. (Rare. Be careful
      — users often *think* an AC is wrong when really the *implementation* is.)
    - *Reclassification*: an item moves between scope/out-of-scope, or between
      functional and non-functional, or between blocking and deferred.
    - *Threshold adjustment*: an NFR target is loosened or tightened with new
      justification.

    Each type has different consequences downstream; flagging the type up front
    makes the rest of the change reviewable.

4.  **Draft the edit in the specification's own form.**

    Refinements MUST land back in the requirements artefacts using the
    conventions those artefacts enforce:

    - Functional changes: Gherkin scenarios (`Feature` / `Scenario` /
      `Given`/`When`/`Then`).
    - NFR changes: measurable benchmark or named standard, never "must be fast".
    - Scope changes: explicit "Out of scope" entries with rationale.

    Show the *before* and the *after* side by side. A bare "after" without
    "before" makes review hard — the reader has to diff in their head.

5.  **Record the rationale and the trigger.**

    Every refinement carries a short justification:

    - Why the previous version was wrong.
    - What evidence convinced you (test name, conversation, measurement).
    - What ruled out alternative interpretations.

    File this with the specification edit (commit body, PR description, or an
    explicit "Refinement log" section in the specification). Silent rewrites are
    how requirements drift.

6.  **Trace downstream impact.**

    Refining a specification is rarely free. Before declaring the refinement
    done, map the ripple:

    - Which design decisions assumed the old AC?
    - Which planned delivery steps are now wrong?
    - Which code increments need to change?
    - Which test cases (automated or manual) need updating?

    For each downstream artefact, flag whether it needs adjustment,
    re-verification, or no change. The list is part of the output; refinement on
    its own does not modify code.

7.  **Report the output.**

    The refined specification is the artefact of this skill. Report it as:

    - Edits to the requirements artefacts for any new ACs introduced (full
      Gherkin / NFR treatment).
    - A flag that the change crosses module boundaries or alters NFRs, where it
      does.
    - The traced list of downstream work the refinement implies.

    Do not implement the change inside this skill. Refinement is about *what is
    required*, not *how to build it*. Report the output and stop; what consumes
    it is the caller's decision.

##  Rules

-   **You MUST refine the specification, not the code.**

    If the right response is "fix the implementation to match the existing AC",
    that is a code-defect fix, not a refinement. Refinement happens when the AC
    itself was wrong, missing, or ambiguous — not when the implementation
    drifted from a correct AC.

-   **You MUST NOT silently rewrite a passed AC.**

    An AC that previously passed — in testing or in production — is part of the
    contract with users and stakeholders. Changing it without explicit
    acknowledgment is how regressions arrive disguised as cleanups. You MUST
    always record the change, the reason, and what was previously promised.

-   **Refinement REQUIRES evidence.**

    A specification change driven by "I thought about it more" is suspect. You
    MUST tie the change to an observation: a failing test, a stakeholder quote, a
    measurement, a UX session. The evidence belongs in the rationale.

-   **You MUST make one refinement per logical change.**

    Bundling unrelated specification edits ("while we're here, also fix the
    refund timeout AC") produces a diff nobody can review. You MUST refine one AC
    per pass; queue the others.

-   **Refinements MUST conform to the specification conventions.**

    Gherkin form, testability, measurable NFRs, explicit out-of-scope. A refined
    specification that breaks the conventions is no better than the unrefined
    one.

-   **You MUST distinguish "specification was wrong" from "user changed their mind".**

    Both produce a specification edit, but the framing matters. A user who
    changes their mind is fine — record it as such. A specification that
    misrepresented what the user wanted from day one is a process failure worth
    noting; the next specification should not repeat it.

-   **Refinement MUST NOT be used to expand scope.**

    Net-new features that were never part of the original ask are not
    refinements — they are new specs. Treat them as such and capture them as a
    fresh specification in their own right; the refine path is for fixing what
    was already there.

-   **You MUST capture follow-up items, not absorb them.**

    A refinement session often surfaces other latent gaps. Note them, raise
    tracking issues, but you MUST NOT stuff them into the current refinement. One
    change at a time, traceable.

## Examples

A correction triggered by a failing AC:

```
Trigger: AC-3 (same idempotency key returns same order) — FAIL in test;
         on inspection, the specification mandates 200 OK, but the agreed
         contract with the SDK team is 200 OK + warning header.

Type:    Correction.

Locate:  features/orders/idempotent-create.feature, Scenario "same
         key returns same order".

Before:
  Then the response status is 200
   And the response body matches the original order

After:
  Then the response status is 200
   And the response body matches the original order
   And the response includes a header "X-Idempotent-Replay: true"

Rationale: Confirmed with SDK team on 2026-05-14 — the warning header
is required for their retry-logic instrumentation. Original specification
omitted this; failure was correctly caught by the integration test.

Downstream impact:
  - design: no change (header is a presentation detail)
  - code: handler in orders/create.ts needs to add the header
  - test: orders.spec.ts:89 needs an updated assertion
```

An addition triggered by exploratory testing:

```
Trigger: Exploratory pass in test found that replaying an idempotency
         key 24h later behaves inconsistently — TTL was never specified.

Type:    Addition (missing AC).

Locate:  features/orders/idempotent-create.feature — new scenario.

After (added scenario):
  Scenario: Idempotency key beyond TTL window
    Given an order was created with idempotency key "abc-123"
     And 24 hours have passed
    When a new order is submitted with the same key
    Then the response status is 201
     And a new order is created

Rationale: TTL was an unstated assumption; the design picked 24h
based on Stripe's convention. Confirmed with the product team
2026-05-15 that 24h is acceptable.

Downstream impact:
  - design: ADR-014 already records the 24h TTL choice — no change.
  - code: TTL purge job exists; add an explicit test for boundary.
  - test: new acceptance scenario above.
```

A threshold adjustment:

```
Trigger: NFR "p95 latency < 200ms" measured at 188ms in test; users
         still report slowness. UX research shows perceived slowness
         starts at 150ms for this interaction.

Type:    Threshold adjustment (NFR tightened).

Before:  p95 API latency < 200ms at 500 RPS sustained.
After:   p95 API latency < 150ms at 500 RPS sustained.

Rationale: User research session 2026-05-12, n=8 participants;
threshold of perceived slowness is 150ms for this specific
checkout interaction. Original 200ms was a guess, now disproven.

Downstream impact:
  - design: re-evaluate cache strategy (likely needs in-memory layer).
  - plan: add a "performance tightening" increment.
  - test: re-run perf suite against new threshold (currently FAIL).
```

##  Edge cases

-   **The refinement contradicts a recently-shipped feature.**

    Treat as a breaking change to a published contract. The refinement is fine
    to record, but the downstream work needs a deprecation / migration story.
    Flag the need for a design pass before assuming the change can land.

-   **Stakeholders disagree on whether the specification was wrong.**

    Don't unilaterally refine. Surface the disagreement, capture both positions,
    and route to whatever decision process the project uses. A refinement that
    one stakeholder considers "correcting an error" and another considers
    "moving the goalposts" needs explicit alignment.

-   **The "refinement" is actually scope expansion in disguise.**

    Common pattern: a stakeholder reframes a new feature as "we always wanted
    this". Push back and route the new ask through a fresh specification as a
    new requirement. Refinement should leave the *purpose* of the original
    specification intact; expansion replaces it.

-   **No specification exists in writing.**

    If the original requirement was tacit, refinement is impossible — there is
    nothing to revise. The first task is to write down the assumed
    specification, then refine *that*. Skipping the write-down produces
    undocumented drift.

-   **Refinement reveals the original AC was untestable.**

    Common when a "tested" AC was really verified by ad-hoc inspection. Rewrite
    the AC into a testable form per the specification conventions; that is
    itself the refinement.

##  Success criteria

-   **Every refinement MUST name its trigger and its type.**

    Correction / addition / removal / reclassification / threshold-adjustment,
    plus the observation that prompted it.

-   **The edit MUST be shown as before / after.**

    Reviewers see what changed without diffing in their heads. The "after" MUST
    obey the specification conventions (Gherkin, measurable NFRs, explicit scope).

-   **The rationale MUST be recorded with the edit.**

    The specification or its commit history explains *why*, not just *what*.
    Future readers can reconstruct the decision without re-litigating it.

-   **Downstream impact MUST be traced.**

    A list of affected artefacts (design, planned steps, code, tests) MUST exist,
    with status. Nothing MUST be silently invalidated.

-   **No code or test MUST have been changed inside this skill.**

    The output is a specification edit and a traced impact list. Implementation
    lives downstream.
