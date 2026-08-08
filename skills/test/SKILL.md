---
name: test
description: >-
  Verify a completed change against its full set of acceptance criteria,
  functional and non-functional, and report each one as passed, failed, or
  blocked with evidence. Use after a change has cleared review, before an
  integration, or before a release, or when the user says something like "test
  this against the spec", "verify this meets the acceptance criteria", or "run
  acceptance testing on this change". Do not use it to fix the defects it
  finds, to amend the specification, or to release the change.
compatibility: >-
  requires Read, Write, Glob, Grep, WebFetch, Bash (test runners, scanners,
  benchmarks)
license: CC0-1.0
---

# Test

Verify a completed change against its acceptance criteria (AC), functional and
non-functional, mapping each AC to observable evidence. Report every failure as
either an implementation defect or a specification defect, and fix neither.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user about the substance of the task; if
you cannot determine it, stop and alert the user with an error message. You MAY
prompt solely to establish where an artifact lives or how to reach it, when
context and environment do not settle it.

- **A completed change — REQUIRED.** The change under test. It has already
  cleared review, so its static qualities are settled; this task covers the
  dynamic ones. Take it from the session context, else from the working tree's
  diff against its integration branch.

- **The specification — REQUIRED.** The full set of acceptance criteria the
  change is meant to satisfy. Discover where it lives rather than assuming:
  check this session's context first, then the environment (a convention file,
  a workspace manifest, a configured connector, an existing directory), then
  ask. It MAY be a directory in this repository, a separate repository, or an
  external service such as a tracker or wiki, so do not assume a filesystem
  path, a file name, or a document structure.

- **Exploratory time-box — OPTIONAL.** How long to spend probing off-script.
  Default to 15-30 minutes of work for a typical change, and longer where the
  change touches a high-risk area.

- **Report store — OPTIONAL.** Where the verification report is persisted, if
  it is to outlive this session. Resolve it the same way as the
  specification's store. Where nothing settles it, return the report to the
  caller instead of writing it anywhere.

## Success criteria

- A verification report MUST exist that maps every AC in the specification to
  exactly one status — PASS, FAIL, BLOCKED, or N/A — each carrying a pointer
  to evidence a reviewer can re-examine without repeating the work: a test
  name and line, a measured number, a log excerpt, a screenshot.

- Where a report store is resolved, the report MUST be written there,
  following whatever conventions that store documents for itself. Where none
  is resolved, the report MUST still be returned in full to the caller.

- Each FAIL in the report MUST carry a classification, either an implementation
  defect or a specification defect, so the caller knows which artifact to take
  it to.

- The report MUST record the environment the checks ran in — build under test,
  hardware, dataset, traffic profile — because an NFR measurement is
  uninterpretable without the conditions that produced it.

- The report MUST end with one explicit verdict: ready to ship, ready for
  review, or blocked on a named item. A reader MUST NOT have to infer it.

- The working tree MUST hold no edit made by this task to production source,
  test code, or the specification. Verification that alters its subject cannot
  say whether the thing verified is the thing that ships. The one exception is
  the verification report itself, written to a resolved report store.

## Instructions

1.  Recover the acceptance criteria.

    Read the specification and extract the full set of ACs, functional and
    non-functional. Where the specification is hosted externally, fetch it.
    Work from the ACs before reading the implementation: reading the code
    first biases testing toward what the code does rather than what it should
    do.

2.  Run the automated suite, in this order:

    1. Smoke tests.
    2. Unit tests.
    3. Integration tests.
    4. System / end-to-end tests.
    5. Acceptance tests.

    You MUST investigate a failure before continuing to the next tier. A
    higher-level failure usually masks lower-level ones, and a lower-level
    failure invalidates the higher-level results above it.

3.  Cover the non-automatable ACs by hand.

    Walk each such scenario end-to-end through the running application and
    capture evidence: console output, log excerpt, screenshot, screen
    recording. For accessibility ACs, check keyboard navigation, a
    screen-reader pass, and contrast.

4.  Verify the non-functional requirements against their stated thresholds.

    Run the load, benchmark, or profiling check for performance and record the
    measured number, not a verdict. Run the required scans for security, and
    verify auth and authz changes by attempting unauthorized access. Exercise
    retry, timeout, and failure-mode behavior for reliability. Where an NFR
    cites a standard, run that standard's own conformance check.

5.  Probe off-script, within the time-box.

    Try inputs the specification did not anticipate, combine the change with
    existing features, push at edge cases, and smoke-test the single most
    critical existing flow for regressions. Record anything surprising, even
    where it maps to no AC.

6.  Assemble the report and state the verdict.

    Map each AC to its status and evidence, note the environment, classify
    every FAIL, and close with the verdict. Resolve the report store; if one
    resolves, write the report there, following whatever conventions it
    documents for itself. Otherwise return the report in full. Stop there —
    do not act on it.

## Rules

- You MUST report and stop at that boundary.

  Diagnosing the defects, editing the specification, and releasing the change
  are the caller's work. Keeping them out of this task is what lets the report
  be trusted as a statement about the change as it stands.

- You MUST NOT weaken the specification to make a test pass.

  Where a test fails because the AC is wrong, that is a change to
  requirements, and it belongs on whatever review path the specification's own
  store prescribes. Silently relaxing an AC is how a regression reaches
  production months later.

- You MUST NOT downgrade a result. A FAIL stays a FAIL until it is
  re-verified, and a BLOCKED is reported rather than dropped.

- You MUST NOT retry a flaky test until it goes green. A test that passes on
  the second run is evidence of a flake, not of a working change; report the
  flake itself as a defect.

- You MUST treat NFRs as first-class. A change that meets every functional AC
  but misses a performance, security, or accessibility threshold is
  incomplete, and gets the same rigor as the functional checks.

- You MUST distinguish blocked from skipped. Blocked means you could not
  evaluate the AC — environment broken, dependency unavailable, AC undefined.
  Skipped means you chose not to. Blockers need resolving; skips need a stated
  reason.

- You SHOULD flag any NFR that has no objective check attached. An NFR that
  cannot be measured is not yet an NFR, and the gap belongs in the report as a
  specification defect.

- You MUST discover each artifact store rather than assuming it, then follow
  whatever conventions that store documents for itself.

  This task runs across projects that keep specifications and test suites in
  different places, formats, and tools. The store owns its template, its
  lifecycle, and its format; this task owns only the method.

- You SHOULD report the volume of evidence proportionally: a pointer per AC in
  the summary, with the raw output kept available rather than pasted in full.

## Edge cases

- No automated suite exists.

  Run the ACs manually with documented evidence, and note test automation as
  follow-up work. Manual verification is acceptable once; recurring manual
  verification of the same ACs is a planning failure worth flagging.

- The test environment differs materially from production.

  Flag the gap explicitly. NFR numbers taken on a laptop are not comparable to
  production capacity, so record the environment beside every measurement and
  say plainly which thresholds could not be fairly tested.

- The change is a refactor with no specification change.

  Read the specification as "the existing ACs continue to hold". Run the full
  existing suite plus a short manual smoke. No new evidence is required unless
  the refactor crossed an NFR boundary such as performance or memory.

- The task is pre-release verification rather than per-change.

  Run the whole pipeline plus the NFR suite against the release candidate.
  Performance and security checks are not optional at a release boundary.

- ACs are missing or too vague to test.

  Do not invent them, and do not infer them from the implementation. Report
  the gap as a specification defect and mark the affected scenarios BLOCKED.

## Examples

- A compact verification report:

  ```text
  Change: POST /orders with idempotency (refs #482)
  Environment: CI runner, 4 vCPU, seeded fixture dataset, build 3f2a1c9

  Functional:
    AC-1 create order with valid body            PASS  orders.spec.ts:41
    AC-2 reject without idempotency-key          PASS  orders.spec.ts:67
    AC-3 same key returns same order             PASS  orders.spec.ts:89
    AC-4 different key creates new order         PASS  orders.spec.ts:104

  Non-functional:
    perf  p95 < 250ms @ 500 RPS                  PASS  measured 188ms
    sec   no auth bypass with crafted header     PASS  manual, see notes
    a11y  N/A (no UI in this change)

  Exploratory (20 min):
    - Idempotency key of 10kB rejected cleanly   PASS
    - Concurrent same-key requests               PASS  (one wins, second
      returns the same record without insert)
    - Replaying an idempotency key 24h later     BLOCKED  TTL absent from
      the specification

  Verdict: blocked on the missing TTL criterion — a specification defect.
  ```

- A failing AC handed back:

  ```text
  AC-3 (same key returns same order) — FAIL, implementation defect

  Evidence: orders.spec.ts:89 — the second POST returns 201 and a new order
  ID, where the AC requires 200 and the existing ID. Reproduces every run.

  Test left in place; not deleted, not skipped.
  ```
