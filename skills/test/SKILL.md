---
name: test
description: >-
  Check the evolving software for both functional correctness and runtime
  qualities. Use after a change has cleared review, before an integration, or
  before a release. Use when the user says something like "test this against
  the spec", "verify this meets the acceptance criteria", or "run acceptance
  testing on this change".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/CODE_STANDARD
---

# Test

Verify a completed change against its full set of acceptance criteria (AC),
both functional and non-functional. Map each AC to evidence (eg. a test run,
observed behavior, or other measurement) and report whether passed, failed,
or blocked. Report failures as either implementation defects or specification
defects, without fixing either.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A completed change — REQUIRED.** The change has already cleared review
  (static qualities checked); this skill verifies the dynamic ones.

- **Its specification — REQUIRED.** The full set of acceptance criteria,
  functional and non-functional, supplies what to verify against.

- **Where the specification lives — REQUIRED.** Discover it rather than
  assuming it: check this session's context first, then the environment (a
  convention file such as `AGENTS.md`, a workspace manifest, a configured
  connector). If neither settles it, ask the user. It MAY be a directory in
  this repository, a separate repository, or an external service such as a
  tracker or wiki — do not assume a filesystem path, a file name, or a
  document structure.

This task otherwise runs non-interactively to completion. You MUST NOT
prompt the user about the substance of the task; if in doubt about that,
stop and print an error message. You MAY prompt solely to establish where an
artifact lives or how to access it, when context and environment do not
settle it.

## Success criteria

You will achieve the following outcomes:

- A verification report — every AC mapped to a status (PASS / FAIL / BLOCKED
  / N/A) and observable evidence, with an explicit verdict. Failures are
  classified — an implementation defect, or a wrong/missing/ambiguous AC (a
  specification defect) — and reported, not fixed.

- Nothing beyond the report was done. Diagnosing defects, editing the
  specification, and releasing were left to the caller.

- Every AC MUST have a status and evidence.

  PASS / FAIL / BLOCKED / N/A, each with a pointer to the evidence.

- Functional and non-functional ACs MUST both be covered.

  Neither MUST be skipped.

- Failures and blockers MUST NOT be downgraded.

  A FAIL reported as a defect MUST NOT be flipped to PASS without
  re-verification. A BLOCKED MUST NOT be silently dropped.

- Failures MUST be classified and reported, not fixed.

  Each FAIL MUST be reported as either an implementation defect or a
  specification defect.

- The verification environment MUST be recorded.

  Especially for NFR measurements, the environment (hardware, dataset,
  traffic profile) MUST be captured alongside the numbers.

- The verdict MUST be explicit.

  "Ready to ship", "ready for review", or "blocked on X" — not
  implied.

## Instructions

1.  Pull the acceptance criteria.

    Recover the full set of ACs the change is meant to satisfy: functional
    ACs and non-functional ACs. If ACs are missing or vague, stop and
    resolve them against the specification before testing.

2.  Run the automated suite.

    Execute, in this order:

    1. Smoke tests.
    2. Unit tests.
    3. Integration tests.
    4. System / end-to-end tests.
    5. Acceptance tests.

    Investigate any failure before continuing.

3.  Cover the gaps manually for non-automatable ACs.

    Walk each scenario from the specification end-to-end through the
    running application, and capture observable evidence: screenshot,
    screen recording, console output, log excerpt. For accessibility,
    check keyboard navigation, screen-reader pass, and contrast.

4.  Verify non-functional requirements.

    For each NFR:

    - Performance: run the load/benchmark/profiling check against the
      stated threshold and record the measured number.

    - Security: run required scans and verify auth/authz changes by
      attempting unauthorized access.

    - Reliability: verify retry, timeout, and failure-mode behavior.

    - Conformance: run the corresponding check where the NFR cites a
      standard.

5.  Do a short exploratory pass.

    Spend the allocated time-box off-script, probing areas adjacent to
    the change: inputs the specification did not anticipate, combining
    the new feature with existing features, edge cases, and a regression
    smoke test of the most-critical existing flow. Document anything
    surprising.

6.  Map ACs to evidence and report.

    Produce a summary mapping each AC or scenario to its outcome and
    evidence. Status is one of: PASS, FAIL, BLOCKED, or N/A.

7.  Report the verdict.

    Classify the outcome and report it. Do not act on it.

## Rules

- You MUST discover artifact locations and conventions; you MUST NOT assume
  them.

  This skill is used across projects that keep their artifacts in different
  places, in different formats, under different tools. A path, file name,
  template, or lifecycle state that is right in one project is wrong in the
  next. Resolve each store first, then read and follow whatever conventions
  it documents for itself.

- You MUST test against the specification, not the implementation.

  You MUST read ACs and run them as a user would. Reading the code first
  biases testing toward what the code does, not what it should do.

- You MUST verify both functional and non-functional ACs.

  Neither MUST be skipped.

- You MUST record observable evidence for every AC.

  "Manually verified" is not evidence. A test name, measurement,
  screenshot, log excerpt — something a reviewer can re-examine without
  re-running the work.

- NFRs MUST be treated as first-class.

  A solution that meets all functional ACs but misses an NFR MUST be
  treated as incomplete. Performance, security, and accessibility MUST
  get the same rigor as functional verification.

- A failure MUST pause the run.

  You MUST NOT push through reds to "see what else breaks". A
  higher-level failure usually masks lower-level ones; a lower-level
  failure invalidates higher-level results.

- You MUST NOT weaken the specification to make a test pass.

  If a test fails because the AC is wrong, that is a specification change,
  and MUST be processed through the same review path as any other change
  to requirements. Silently relaxing an AC to ship is how regressions
  arrive in production months later.

- You MUST time-box exploratory testing.

  Exploratory testing is unbounded by nature. You MUST time-box it
  (15-30 min for a typical change; longer for high-risk areas). The
  point is fresh-eyes probing, not exhaustive coverage.

- You MUST distinguish blocked from skipped.

  Blocked = could not evaluate (environment broken, dependency
  unavailable, AC undefined). Skipped = chose not to evaluate. Blockers
  MUST be resolved; skips MUST be justified.

- An NFR without an objective check MUST be flagged.

  If an NFR has no objective check, it is not really an NFR; report it.

## Edge cases

- No automated suite exists.

  Run the ACs manually with documented evidence, and queue
  test-automation work as a follow-up. Repeat-manual verification is
  acceptable once; recurring manual verification of the same ACs is a
  planning failure.

- Test environment differs materially from production.

  Flag the gap explicitly in the report. NFR measurements taken on a
  laptop are not directly comparable to production capacity; record the
  environment alongside the number.

- Flaky test in the suite.

  Do not retry-until-green. A flaky test passing on a re-run is not
  evidence. Report the flake as a defect for diagnosis before completing
  the verification.

- The change is a refactor with no specification change.

  The specification is "existing ACs continue to pass". Run the full
  existing automated suite and a short manual smoke. No new evidence is
  required unless the refactor crossed an NFR boundary (performance,
  memory).

- Pre-release verification.

  Run the full pipeline (smoke → unit → integration → system →
  acceptance) plus the NFR suite on the release candidate. Performance
  and security checks are not optional at release.

## Examples

- A compact verification report:

  ```sh
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

- A failing-AC handoff:

  ```sh
  AC-3 (same key returns same order) — FAIL

  Evidence: orders.spec.ts:89 — second POST returns 201 + new order ID
  instead of 200 + existing order ID. Reproduction is deterministic.

  Reported as an implementation defect for diagnosis. Test left in place; do
  not delete.
  ```

## References

None.
