---
name: test
description: Verify a completed change against its full set of acceptance criteria – functional and non-functional. Map each AC to evidence (test run, observed behavior, measurement) and report pass/fail/blocked. Use after the change has cleared review, or before tagging a release. Reports failures as either implementation defects or specification defects, without fixing them.
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: gemma4:31b
---

# Test

Use this skill after the change has cleared review, or before tagging a release. The job is to *verify the whole solution against the specification* – not to write new tests for individual steps, and not to chase a defect.

Do NOT use this skill to write fresh test cases for newly-added behavior – that belongs with the implementation work. Do NOT use it to investigate a failing test – diagnosing a defect is a separate responsibility. Do NOT use it to revise the specification when an AC turns out to be wrong – editing requirements is a separate responsibility.

##  Instructions

1.  **Pull the acceptance criteria.**

    Recover the full set of ACs the change is meant to satisfy: functional ACs (from the specification) and non-functional ACs (performance, security, accessibility, compliance). Both MUST be verified.

    If ACs are missing or vague, stop and resolve them against the specification before testing. Testing against an ambiguous specification produces ambiguous results.

2.  **Run the automated suite.**

    Execute, in this order:

    1. *Smoke tests* (if any) – fail-fast on a broken build.
    2. *Unit tests* – localize defects.
    3. *Integration tests* – exercise boundaries between components.
    4. *System / end-to-end tests* – verify whole-system flows.
    5. *Acceptance tests* – the Gherkin scenarios from the specification, if automated.

    Any failure at any level pauses the run: investigate before continuing. Do not interpret a green higher-level suite as cancellation of a red lower-level one.

3.  **Cover the gaps manually for non-automatable ACs.**

    Some ACs cannot be automated – visual layout, copy, UX feel, animation, accessibility under a screen reader. Run them by hand:

    - Walk each scenario from the specification end-to-end through the running application.
    - Capture observable evidence: screenshot, screen recording, console output, log excerpt.
    - For accessibility: keyboard navigation, screen-reader pass, contrast check.

    Record what was checked and what was observed – "checked it works" is not evidence.

4.  **Verify non-functional requirements.**

    For each NFR in the specification:

    - *Performance*: run the load/benchmark/profiling check against the stated threshold (eg. p95 < 250ms at 500 RPS). Record the measured number, not just "ok".
    - *Security*: run any required scans (SAST, dependency CVE check, secret scan). Verify auth/authz changes by attempting unauthorized access.
    - *Reliability*: verify retry, timeout, and failure-mode behavior – kill a dependency, throttle a network, confirm graceful degradation.
    - *Conformance*: where the NFR cites a standard (WCAG, GDPR, PCI), run the corresponding check.

    If an NFR has no objective check, flag it – it is not really an NFR, it is a hope.

5.  **Do a short exploratory pass.**

    Spend 15-30 minutes off-script, probing areas adjacent to the change:

    - Try inputs the specification did not anticipate.
    - Combine the new feature with existing features.
    - Stress edge cases (empty, max, malformed, concurrent).
    - Re-run the most-critical existing flow as a regression smoke test.

    Document anything surprising, even if it is not a clear bug.

6.  **Map ACs to evidence and report.**

    Produce a short summary mapping each AC (or scenario) to its outcome:

    ```
    AC-1 (refund full order)          PASS  test: orders.refund.spec.ts:42
    AC-2 (refund partial)             PASS  test: orders.refund.spec.ts:78
    AC-3 (refund denied if expired)   PASS  manual, see recording link
    NFR-perf p95 < 250ms              PASS  measured 188ms @ 500 RPS
    NFR-a11y WCAG 2.2 AA              FAIL  contrast 3.1:1 on refund button
    Exploratory: refund of $0         BLOCKED — undefined behavior, flagged
    ```

    Status is one of: PASS, FAIL, BLOCKED (cannot evaluate), or N/A (with reason).

7.  **Report the verdict.**

    Classify the outcome and report it; do not act on it – what runs next is the orchestrator's concern.

    - All PASS, more increments remain → the change is verified for this increment; the implement-review-verify cycle continues per remaining step.
    - All PASS, work complete → verified and ready to release.
    - Any FAIL caused by an implementation defect → report it as a defect for diagnosis. Do not proceed.
    - Any FAIL caused by a wrong, missing, or ambiguous AC → report it as a specification defect. Do not silently rewrite the AC.
    - Any BLOCKED → resolve the blocker before declaring done; do not silently downgrade to PASS.

##  Rules

-   **Test against the specification, not the implementation.**

    Read ACs and run them as a user would. Reading the code first biases testing toward what the code does, not what it should do. Specification-first testing is how you catch features that pass their own tests but miss the requirement.

-   **Record observable evidence for every AC.**

    "Manually verified" is not evidence. A test name, a measurement, a screenshot, a log excerpt – something a reviewer can re-examine without re-running the work.

-   **NFRs are first-class.**

    A solution that meets all functional ACs but misses an NFR is incomplete. Performance, security, and accessibility get the same rigor as functional verification.

-   **A failure pauses the run.**

    Do not push through reds to "see what else breaks". A higher-level failure usually masks lower-level ones; a lower-level failure invalidates higher-level results.

-   **Do not weaken the specification to make a test pass.**

    If a test fails because the AC is wrong, that is a specification change, processed through the same review path as any other change to requirements. Silently relaxing an AC to ship is how regressions arrive in production months later.

-   **Time-box exploratory testing.**

    Exploratory testing is unbounded by nature. Time-box it (15-30 min for a typical change; longer for high-risk areas). The point is fresh-eyes probing, not exhaustive coverage.

-   **Distinguish blocked from skipped.**

    Blocked = could not evaluate (environment broken, dependency unavailable, AC undefined). Skipped = chose not to evaluate. Blockers need resolving; skips need justifying.

## Examples

A compact verification report:

```
Change: POST /orders with idempotency (refs #482)

Functional:
  AC-1 create order with valid body            PASS  test orders.spec.ts:41
  AC-2 reject without idempotency-key          PASS  test orders.spec.ts:67
  AC-3 same key returns same order             PASS  test orders.spec.ts:89
  AC-4 different key creates new order         PASS  test orders.spec.ts:104

Non-functional:
  perf  p95 < 250ms @ 500 RPS                  PASS  measured 188ms
  sec   no auth bypass with crafted header     PASS  manual, see notes
  a11y  N/A (no UI in this change)

Exploratory (20 min):
  - Idempotency key of 10kB rejected cleanly   PASS
  - Concurrent same-key requests               PASS  (one wins, second
    returns the same record without insert)
  - Replaying an idempotency key 24h later     BLOCKED — TTL not in
    specification; raised as specification gap.

Verdict: 1 blocked, 0 failed. Reported as a specification defect for AC-5
(TTL); the change re-enters the workflow once the specification is corrected.
```

A failing-AC handoff:

```
AC-3 (same key returns same order) — FAIL

Evidence: orders.spec.ts:89 — second POST returns 201 + new order ID
instead of 200 + existing order ID. Reproduction is deterministic.

Reported as an implementation defect for diagnosis. Test left in place; do
not delete.
```

##  Edge cases

-   **No automated suite exists.**

    Run the ACs manually with documented evidence, and queue test-automation work as a follow-up. Repeat-manual verification is acceptable once; recurring manual verification of the same ACs is a planning failure.

-   **Test environment differs materially from production.**

    Flag the gap explicitly in the report. NFR measurements taken on a laptop are not directly comparable to production capacity; record the environment alongside the number.

-   **Flaky test in the suite.**

    Do not retry-until-green. A flaky test passing on a re-run is not evidence. Report the flake as a defect for diagnosis before completing the verification.

-   **The change is a refactor with no specification change.**

    The specification is "existing ACs continue to pass". Run the full existing automated suite and a short manual smoke. No new evidence is required unless the refactor crossed an NFR boundary (performance, memory).

-   **Pre-release verification.**

    Run the full pipeline (smoke → unit → integration → system → acceptance) plus the NFR suite on the release candidate. Performance and security checks are not optional at release.

##  Success criteria

-   **Every AC has a status and evidence.**

    PASS / FAIL / BLOCKED / N/A, each with a pointer to the evidence (test, measurement, recording, log).

-   **Functional and non-functional ACs are both covered.**

    Neither is silently skipped.

-   **Failures and blockers are not downgraded.**

    A FAIL reported as a defect is not flipped to PASS without re-verification. A BLOCKED is not silently dropped.

-   **The verification environment is recorded.**

    Especially for NFR measurements, the environment (hardware, dataset, traffic profile) is captured alongside the numbers.

-   **The verdict is explicit.**

    "Ready to ship", "ready for review", or "blocked on X" – not implied.

## Inputs and outputs

- **Input — a completed change and its specification.** The change has already cleared review (static qualities checked); this skill verifies the dynamic ones. The full set of acceptance criteria, functional and non-functional, supplies what to verify against.

- **Output — a verification report.** Every AC mapped to a status (PASS / FAIL / BLOCKED / N/A) and observable evidence, with an explicit verdict. Failures are classified – an implementation defect, or a wrong/missing/ambiguous AC (a specification defect) – and reported, not fixed. Whatever consumes the report – diagnosing a defect, editing the specification, releasing – is the orchestrator's concern, not this skill's.
