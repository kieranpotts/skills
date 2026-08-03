---
name: diagnose
description: >-
  Find the cause of unexpected behaviors and runtime issues. Evaluation only —
  no fix is applied. Use when the user says something like "diagnose this",
  "debug this", or "why is this happening?", reports a bug, says something is
  broken/throwing/failing, or describes a performance regression.
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/CODE_STANDARD
---

# Diagnose

Find the cause of a bug or performance regression whose cause is not obvious.
Build a reliable feedback loop first, reproduce the failure, form ranked
falsifiable hypotheses, then instrument to test them one variable at a time
until one hypothesis survives and the rest are ruled out.

The feedback loop is the skill: without one you are guessing. Where the cause
is already evident — a compiler, linter, or type-checker has named it — this
is the wrong skill; that is mechanical repair, not diagnosis.

This skill does not apply the remedy. It stops at a confirmed cause, and hands
over the evidence that lets someone else — a downstream agent or a human —
apply and verify a fix.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A bug or performance regression whose cause is not obvious — REQUIRED.**
  A reported bug or performance regression whose cause is not obvious from
  reading the code — the symptom, where it shows up, and any reproduction
  the user already has. For performance work, a numerical baseline and
  threshold stand in for the symptom.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

- A single confirmed cause MUST be stated, with the evidence that confirmed
  it and the evidence that ruled out the alternatives.

- No production behavior MUST have changed, and the working tree MUST
  contain no attempted remedy.

- A feedback loop MUST exist and MUST be recorded: the exact command,
  script, or test that reproduces the bug MUST be committed or written into
  the handover, so a future reader can re-run it.

- A failing regression test MUST exist at a correct seam, or the absence of
  such a seam MUST be documented. The test MUST fail against the unmodified
  code, for the diagnosed reason, and MUST be left failing.

- The hypothesis set MUST be ranked and falsifiable: the output MUST
  include 3-5 ranked hypotheses, each with a stated prediction that could
  disprove it, and each MUST be recorded as confirmed or eliminated.

- All tagged instrumentation MUST have been removed — `grep` for the debug
  prefix MUST return zero hits in the working tree.

- The handover MUST carry all of the above, plus any suggested remedy, so
  the repair can proceed without re-deriving the diagnosis.

## Instructions

1.  Build a feedback loop.

    Try construction methods in roughly this order:

    1. Failing test at whatever seam reaches the bug — unit, integration, e2e.

    2. Curl / HTTP script against a running dev server.

    3. CLI invocation with a fixture input, diffing stdout against a
       known-good snapshot.

    4. Headless browser script (Playwright / Puppeteer) — drives the UI,
       asserts on DOM/console/network.

    5. Replay a captured trace. Save a real network request / payload / event
       log to disk; replay it through the code path in isolation.

    6. Throwaway harness. Spin up a minimal subset of the system (one
       service, mocked deps) that exercises the bug code path with a single
       function call.

    7. Property / fuzz loop. If the bug is "sometimes wrong output", run
       1000 random inputs and look for the failure mode.

    8. Bisection harness. If the bug appeared between two known states
       (commit, dataset, version), automate "boot at state X, check,
       repeat" so you can `git bisect run` it.

    9. Differential loop. Run the same input through old-version vs
       new-version (or two configs) and diff outputs.

    10. Human-in-the-loop bash script. Last resort. If a human must click,
        drive them with a structured script so the loop is still automated.
        Captured output feeds back to you.

    Then iterate on the loop itself:

    - Can it be faster? (Cache setup, skip unrelated init, narrow test
      scope.)

    - Can the signal be sharper? (Assert on the specific symptom, not
      "didn't crash".)

    - Can it be more deterministic? (Pin time, seed RNG, isolate
      filesystem, freeze network.)

2.  Reproduce.

    Run the loop, watch the bug appear, and confirm:

    - [ ] The loop produces the failure mode the user described — not a
      different failure that happens to be nearby.

    - [ ] The failure is reproducible across multiple runs (or, for
      non-deterministic bugs, at a high enough rate to debug against).

    - [ ] You have captured the exact symptom (error message, wrong
      output, slow timing) so the handover can state precisely what a
      remedy has to address.

3.  Hypothesize.

    Generate ranked hypotheses before testing any of them. Each hypothesis
    needs to be falsifiable. State the prediction it makes:

    > "If <X> is the cause, then <changing Y> will make the bug disappear /
    <changing Z> will make it worse."

    If you cannot state the prediction, discard or sharpen the hypothesis.

    Optionally show the ranked list to the user as a checkpoint, but do not
    block on a response — proceed with your ranking if the user is AFK.

4.  Instrument.

    Map each probe to a specific prediction from step 3. Change one
    variable at a time.

    Tool preference:

    1. Debugger / REPL inspection if the environment supports it. One
       breakpoint beats ten logs.

    2. Targeted logs at the boundaries that distinguish hypotheses.

    3. Never "log everything and grep".

    Tag every debug log with a unique prefix, eg. `[DEBUG-a4f2]`. Cleanup at
    the end becomes a single grep.

    For performance regressions, establish a baseline measurement (timing
    harness, `performance.now()`, profiler, query plan), then bisect.
    Measure first, diagnose second.

    A probe MAY temporarily change behavior to test a prediction — that is
    what an experiment is. Revert every such change once the prediction has
    been settled. What survives this step is knowledge, not a diff.

5.  Converge on one cause.

    Keep testing predictions until exactly one hypothesis survives. Record,
    for each of the others, the observation that eliminated it — an
    untested hypothesis is not an eliminated one.

    You are done when you can state the full causal chain from trigger to
    symptom, and every link is something you observed rather than inferred.

    If two hypotheses both survive, the loop is not sharp enough to
    distinguish them. Go back to step 1 and sharpen it. Do not pick the more
    plausible one.

6.  Capture a failing regression test.

    The proof of a diagnosis is a test that fails now, for the diagnosed
    reason, and will pass once the cause is removed. Write it, watch it
    fail, and leave it failing.

    Write it at a correct seam — one where the test exercises the real bug
    pattern as it occurs at the call site. If the only available seam is too
    shallow, a test there gives false confidence.

    If no correct seam exists, that itself is a finding. Record it — the
    codebase architecture is preventing the bug from being locked down — and
    hand over the step-1 loop as the verification method instead.

7.  Clean up and hand over.

    Before declaring done:

    - [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix to
      confirm).

    - [ ] All experimental behavior changes from step 4 reverted; the diff
      contains the failing test and nothing else.

    - [ ] Throwaway prototypes deleted (or moved to a clearly-marked
      debug location).

    - [ ] The step-1 repro command recorded verbatim.

    Then write the handover, following whatever convention the project's
    issue or handover store prescribes: the symptom, the repro command, the
    ranked hypotheses with the confirmed one marked and the rest shown as
    eliminated, the causal chain, the failing test (or the documented
    absence of a seam), and a suggested remedy with any alternatives you
    considered.

    Finally, ask: what would have prevented this bug? If the answer involves
    architectural change (no good test seam, tangled callers, hidden
    coupling), record it as a separate recommendation — it is not part of
    the repair.

## Rules

- The feedback loop is the skill.

  Build the right loop and the bug is 90% found. Without one, you are
  guessing. You MUST treat loop construction as the primary task, not a
  setup step. You MUST NOT proceed past step 1 until you have a loop you
  believe in.

- You MUST NOT apply a fix.

  This task's output is knowledge plus a failing test. Applying the remedy
  is separate work with its own verification. A diagnosis that arrives with
  the fix already applied cannot be reviewed as a diagnosis, and the test
  that should have proven it has already been turned green.

  The one exception is a temporary experimental change made under step 4 to
  test a prediction, which MUST be reverted before the handover.

- For non-deterministic bugs, you MUST raise the reproduction rate.

  The goal is not a clean repro but a higher reproduction rate. Loop the
  trigger 100×, parallelize, add stress, narrow timing windows, inject
  sleeps. A 50%-flake bug is debuggable; 1% is not — keep raising the rate
  until it is.

- If you genuinely cannot build a loop, you MUST stop and say so
  explicitly.

  List what you tried, and state what you need in order to proceed:

  - Access to an environment that reproduces it.

  - A captured artifact (HAR file, log dump, core dump, screen recording
    with timestamps).

  - Permission to add temporary production instrumentation.

  You MUST NOT proceed to hypothesize without a loop.

- You MUST NOT proceed to hypothesis until you have reproduced the bug.

  A hypothesis tested against a non-reproducing symptom is a guess.

- You MUST generate hypotheses in a ranked set before testing any of them.

  Single-hypothesis generation anchors on the first plausible idea.
  Produce alternatives so the leading candidate is chosen by comparison,
  not by default.

- You MUST change one variable at a time when instrumenting.

  Changing two things at once turns a successful test into ambiguous
  evidence.

- Each instrumenting probe MUST map to a specific hypothesis prediction.

  A probe that does not test a prediction is noise.

- You MUST tag all debug instrumentation with a unique prefix.

  eg. `[DEBUG-a4f2]`. Makes cleanup deterministic — a single grep finds
  every probe to remove.

- You MUST report a cause as confirmed only if you observed it.

  A cause you reasoned your way to but never watched happen is still a
  hypothesis. Say so, and say what observation would settle it.

- For performance work, you MUST measure before you conclude.

  Establish a baseline with a profiler, timing harness, query plan, or
  `performance.now()`. Then bisect. Logs are the wrong tool for
  performance.

## Edge cases

- Performance regression, not a functional bug.

  Skip "watch it crash" — the bug is a measurement. Replace step 2's
  symptom capture with a numerical baseline + threshold, and the step-1
  loop becomes a benchmark, not a test. The step-6 failing test is then a
  benchmark assertion against the threshold.

- Heisenbug that disappears under instrumentation.

  The probe itself is changing timing. Switch to a sampling profiler,
  post-hoc log analysis, or hardware-level tracing rather than
  synchronous logging.

- Bug only reproduces in production.

  Do not skip the loop. Capture a production artifact (HAR, request log,
  db snapshot) and replay it locally. If that is impossible, get explicit
  permission before adding production instrumentation, and tag it the same
  way (`[DEBUG-...]`) for guaranteed cleanup.

- The user's reported symptom is not the real bug.

  In step 2, if the loop fails to reproduce the user's described symptom
  but reproduces something nearby, stop and report the discrepancy rather
  than chasing the wrong bug.

- The cause turns out to be trivial once reproduced.

  A one-line typo is still a diagnosis. Hand it over the same way — do not
  fix it just because it is small. The repair path exists so that every
  behavior change is verified the same way, whatever its size.

- The remedy is obvious but the cause is contested.

  Suppressing a symptom is not a diagnosis. If you can make the symptom go
  away without being able to state why, you have not finished step 5 —
  report the intervention as evidence, not as a conclusion.

## Examples

- Hypothesis format:

  ```sh
  1. Likely (~50%): The cache key omits the tenant ID, so tenant A's
    response is returned for tenant B. If true, hard-coding tenant ID
    into the key in `cache.ts:42` will fix the symptom.

  2. Possible (~25%): The auth middleware is short-circuiting on the
    second request because the session token has already been consumed.
    If true, replaying with a fresh token each iteration of the loop
    will make the bug disappear.

  3. Possible (~15%): A race between the worker and the writer. If true,
    inserting a 50ms sleep in the worker should suppress the bug.

  4. Unlikely (~10%): Upstream API is returning stale data. If true,
    bypassing the upstream call and feeding a fixture should still
    reproduce the bug (it should NOT, if this is the cause).
  ```

- Tagged debug log:

  ```ts
  console.log(`[DEBUG-a4f2] cache key for tenant=${tenantId}: ${key}`)
  ```

  Cleanup: `grep -r '\[DEBUG-a4f2\]' src/` returns zero hits before
  handover.

- Handover of a confirmed cause:

  ```md
  Symptom: tenant B intermittently sees tenant A's dashboard totals.
  Repro:   `npm test -- cache.tenant-isolation` (added, currently failing)

  Cause (confirmed, hypothesis 1): `buildKey()` in `cache.ts:42` composes
  the key from route and query string only. Two tenants hitting the same
  route share a key, so whichever request populates the cache first wins
  for the TTL. Observed directly: `[DEBUG-a4f2]` logged an identical key
  for two distinct tenant IDs, and the second request never reached the
  loader.

  Eliminated: 2 (fresh token per iteration still reproduces), 3 (50ms
  worker sleep changes nothing), 4 (fixture upstream still reproduces).

  Suggested remedy: include the tenant ID in the key at `cache.ts:42`.
  Alternative considered: per-tenant cache namespaces — a larger change,
  but would prevent the whole class of bug.
  ```
