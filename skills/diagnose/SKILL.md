---
name: diagnose
description: >-
  Find the cause of a bug or performance regression that is not obvious from
  reading the code, by reproducing it and testing ranked hypotheses until one
  survives. Use when the user says something like "diagnose this", "debug
  this", or "why is this happening?", reports a bug, says something is broken,
  throwing, or failing, or describes a performance regression. Do not use it to
  apply the remedy, nor where a compiler, linter, or type-checker has already
  named the cause.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, Bash (test runners, profilers,
  git bisect)
license: CC0-1.0
---

# Diagnose

Find the cause of a bug or performance regression whose cause is not obvious:
build a reliable feedback loop, reproduce the failure, then test ranked
falsifiable hypotheses one variable at a time until exactly one survives. Stop
at the confirmed cause and hand over the evidence — do not apply the remedy.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message. You MAY prompt solely to establish where an artifact
lives or how to access it, when context and environment do not settle it.

- **The reported failure — REQUIRED.** The symptom, where it shows up, and any
  reproduction the user already has. For performance work, a numerical
  baseline and a threshold stand in for the symptom.

- **Handover store — OPTIONAL.** Where the diagnosis is recorded for whoever
  performs the repair. Discover it from the last prompt, then from more recent
  context, then from the environment — a convention file, a workspace
  manifest, an issue tracker, a configured connector. It MAY be a directory in
  this repository, a separate repository, or an external service, so do not
  assume a filesystem path. Absent any store, return the handover in your
  final response.

## Success criteria

- Exactly one cause MUST be confirmed, stated as a causal chain from trigger
  to symptom in which every link was observed rather than inferred.

- Each of the 3-5 ranked hypotheses MUST be recorded as confirmed or
  eliminated, alongside the observation that settled it.

- The repro command, script, or test MUST be recorded verbatim, so a later
  reader can re-run the feedback loop without rebuilding it.

- A regression test MUST fail against the unmodified code for the diagnosed
  reason and MUST be left failing — or, where no correct seam exists, the
  handover MUST say so and name the feedback loop as the verification method
  instead.

- Grepping the debug prefix across the working tree MUST return zero hits.

- The working tree MUST contain no remedy and no experimental behavior change:
  the diff MUST hold the failing test and any recorded loop, and nothing else.

- The handover MUST additionally carry a suggested remedy, so the repair can
  proceed without re-deriving the diagnosis.

## Instructions

1.  Build a feedback loop.

    A loop is a fast, deterministic, agent-runnable pass/fail signal for the
    bug. You MUST have one before forming any hypothesis. Try these
    construction methods in roughly this order, taking the first that fits:

    1. Failing test at whatever seam reaches the bug — unit, integration, e2e.

    2. Curl / HTTP script against a running dev server.

    3. CLI invocation with a fixture input, diffing stdout against a
       known-good snapshot.

    4. Headless browser script (Playwright / Puppeteer) — drives the UI,
       asserts on DOM, console, or network.

    5. Replay of a captured trace. Save a real request, payload, or event log
       to disk, then replay it through the code path in isolation.

    6. Throwaway harness. A minimal subset of the system (one service, mocked
       deps) that exercises the bug's code path in a single function call.

    7. Property or fuzz loop, where the bug is "sometimes wrong output". Run
       1000 random inputs and look for the failure mode.

    8. Bisection harness, where the bug appeared between two known states
       (commit, dataset, version). Automate "boot at state X, check, repeat"
       so `git bisect run` can drive it.

    9. Differential loop. Run one input through two versions or two configs
       and diff the outputs.

    10. Human-in-the-loop bash script. Last resort, where a human must click.
        Drive them with a structured script so the loop stays automated, and
        feed the captured output back to yourself.

    Then iterate on the loop itself. It SHOULD be fast (cache setup, skip
    unrelated init, narrow the test scope), sharp (assert on the specific
    symptom, not "didn't crash"), and deterministic (pin time, seed the RNG,
    isolate the filesystem, freeze the network).

2.  Reproduce.

    Run the loop, watch the bug appear, and confirm:

    - [ ] The loop produces the failure mode the user described — not a
      different failure that happens to be nearby.

    - [ ] The failure recurs across multiple runs, or for a non-deterministic
      bug, at a high enough rate to debug against.

    - [ ] You have captured the exact symptom — error message, wrong output,
      slow timing — so the handover can state what a remedy has to address.

3.  Hypothesize.

    Generate a ranked set of 3-5 hypotheses before testing any of them. Each
    MUST be falsifiable, so state the prediction it makes:

    > "If [X] is the cause, then [changing Y] will make the bug disappear /
    > [changing Z] will make it worse."

    Discard or sharpen any hypothesis whose prediction you cannot state.

    You MAY show the ranked list to the user as a checkpoint, but MUST NOT
    block on a response — proceed with your own ranking if nobody answers.

4.  Instrument.

    Map each probe to a specific prediction from step 3, and change one
    variable at a time. Prefer a debugger or REPL inspection where the
    environment supports it — one breakpoint beats ten logs — then targeted
    logs at the boundaries that distinguish hypotheses. Never log everything
    and grep.

    Tag every debug log with a unique prefix, eg. `[DEBUG-a4f2]`, so cleanup
    in step 7 is a single grep.

    For a performance regression, establish a baseline measurement — timing
    harness, `performance.now()`, profiler, query plan — and then bisect.
    Measure first, diagnose second.

    A probe MAY temporarily change behavior to test a prediction; that is what
    an experiment is. Revert each such change as soon as its prediction is
    settled. What survives this step is knowledge, not a diff.

5.  Converge on one cause.

    Keep testing predictions until exactly one hypothesis survives, recording
    for each of the others the observation that eliminated it — an untested
    hypothesis is not an eliminated one.

    You are done when you can state the full causal chain from trigger to
    symptom, every link of which you observed rather than inferred.

    If two hypotheses both survive, the loop is not sharp enough to
    distinguish them. Return to step 1 and sharpen it. You MUST NOT settle the
    question by picking the more plausible one.

6.  Capture a failing regression test.

    The proof of a diagnosis is a test that fails now, for the diagnosed
    reason, and will pass once the cause is removed. Write it, watch it fail,
    and leave it failing.

    Place it at a correct seam — one where the test exercises the real bug
    pattern as it occurs at the call site. A test at a seam that is too
    shallow gives false confidence, so where the only available seam is too
    shallow, treat that as a finding in its own right: record that the
    architecture is preventing the bug from being locked down, and hand over
    the step-1 loop as the verification method instead.

7.  Clean up and hand over.

    Before declaring done:

    - [ ] All `[DEBUG-...]` instrumentation removed — grep the prefix to
      confirm.

    - [ ] All experimental behavior changes from step 4 reverted, leaving the
      failing test and nothing else in the diff.

    - [ ] Throwaway prototypes deleted, or moved to a clearly-marked debug
      location.

    - [ ] The step-1 repro command recorded verbatim.

    Then write the handover into the resolved store, following whatever
    conventions that store documents for itself. It MUST carry the symptom,
    the repro command, the ranked hypotheses with the confirmed one marked and
    the rest shown as eliminated, the causal chain, the failing test or the
    documented absence of a seam, and a suggested remedy with any alternatives
    you considered.

    Finally, ask what would have prevented this bug. Where the answer involves
    architectural change — no good test seam, tangled callers, hidden coupling
    — record it as a separate recommendation, since it is not part of the
    repair.

## Rules

- You MUST treat loop construction as the primary task, not a setup step.

  Build the right loop and the bug is most of the way found; without one you
  are guessing.

- Where you genuinely cannot build a loop, you MUST stop and say so
  explicitly, rather than hypothesizing without one.

  List what you tried, and state what you need in order to proceed: access to
  an environment that reproduces the failure, a captured artifact (HAR file,
  log dump, core dump, timestamped screen recording), or permission to add
  temporary production instrumentation.

- You MUST NOT proceed to hypothesis until you have reproduced the bug. A
  hypothesis tested against a non-reproducing symptom is a guess.

- For a non-deterministic bug, you MUST raise the reproduction rate before
  debugging against it.

  The goal is not a clean repro but a higher rate. Loop the trigger 100×,
  parallelize, add stress, narrow timing windows, inject sleeps. A 50%-flake
  bug is debuggable; a 1% one is not.

- You MUST generate hypotheses as a ranked set before testing any of them.

  Generating one at a time anchors you on the first plausible idea. Produce
  alternatives, so the leading candidate is chosen by comparison rather than
  by default.

- You MUST change one variable at a time when instrumenting, and each probe
  MUST map to a specific hypothesis prediction.

  Changing two things at once turns a successful test into ambiguous
  evidence, and a probe that tests no prediction is noise.

- You MUST report a cause as confirmed only if you observed it.

  A cause you reasoned your way to but never watched happen is still a
  hypothesis. Say so, and say what observation would settle it.

- For performance work, you MUST measure before you conclude. Establish a
  baseline with a profiler, timing harness, or query plan; logs are the wrong
  tool here.

- You MUST NOT apply a fix.

  The output of this task is knowledge plus a failing test. Applying the
  remedy is separate work with its own verification: a diagnosis that arrives
  with the fix already applied cannot be reviewed as a diagnosis, and the test
  that should have proven it has already been turned green. The sole
  exception is a temporary experimental change made under step 4, which MUST
  be reverted before the handover.

## Edge cases

- A compiler, linter, or type-checker has already named the cause.

  There is nothing to diagnose — this is mechanical repair. Say so and stop,
  rather than building a loop around a known cause.

- Performance regression, not a functional bug.

  Skip "watch it crash": the bug is a measurement. Replace step 2's symptom
  capture with a numerical baseline and threshold, make the step-1 loop a
  benchmark rather than a test, and make the step-6 failing test a benchmark
  assertion against the threshold.

- Heisenbug that disappears under instrumentation.

  The probe itself is changing timing. Switch to a sampling profiler, post-hoc
  log analysis, or hardware-level tracing, rather than synchronous logging.

- The bug only reproduces in production.

  Do not skip the loop. Capture a production artifact — HAR, request log,
  database snapshot — and replay it locally. Where that is impossible, get
  explicit permission before adding production instrumentation, and tag it the
  same way (`[DEBUG-...]`) so cleanup stays deterministic.

- The user's reported symptom is not the real bug.

  In step 2, where the loop fails to reproduce the described symptom but
  reproduces something nearby, stop and report the discrepancy rather than
  chasing the wrong bug.

- The cause turns out to be trivial once reproduced.

  A one-line typo is still a diagnosis. Hand it over the same way; do not fix
  it just because it is small. The repair path exists so that every behavior
  change is verified the same way, whatever its size.

- The remedy is obvious but the cause is contested.

  Suppressing a symptom is not a diagnosis. Where you can make the symptom go
  away without being able to state why, step 5 is unfinished — report the
  intervention as evidence, not as a conclusion.

## Examples

- Hypothesis format:

  ```text
  1. Likely (~50%): The cache key omits the tenant ID, so tenant A's
     response is returned for tenant B. If true, hard-coding a tenant ID
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

- Tagged debug log, and the grep that confirms its removal:

  ```ts
  console.log(`[DEBUG-a4f2] cache key for tenant=${tenantId}: ${key}`)
  ```

  ```sh
  grep -r '\[DEBUG-a4f2\]' src/   # must return zero hits before handover
  ```

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
