# 🤖 `/test`

Conduct incremental acceptance testing of the evolving software, focusing on functional correctness and runtime qualities – verifying a completed change against its full set of acceptance criteria, mapping each to evidence and reporting pass/fail/blocked. Runs non-interactively (🤖). Use after a change has cleared review, or before tagging a release. Reports failures as defects without fixing them.

## What it does

`/test` verifies the whole solution against the specification – it does not write fresh tests for new behavior (that's the implementation's job) or diagnose a failure (that's separate). It pulls the full AC set (functional and non-functional), runs the automated suite in order (smoke → unit → integration → system → acceptance), covers non-automatable ACs by hand with captured evidence (screenshots, recordings, logs), and verifies NFRs against their stated thresholds – recording the *measured number*, not just "ok". It spends a time-boxed exploratory pass probing adjacent edge cases, then maps every AC to a status (PASS / FAIL / BLOCKED / N/A) with a pointer to its evidence, and reports an explicit verdict.

It is non-interactive and tests **against the specification, not the implementation** (reading the code first biases testing toward what the code does, not what it should do). It classifies each failure as an implementation defect or a specification defect and reports it without fixing – and it never silently weakens an AC, downgrades a BLOCKED to PASS, or retries a flaky test until green.

## How to invoke

```
/test
```

Invoke it after review clears, or before a release. It takes the completed change and its ACs; it pulls the criteria itself and stops to resolve them if they're vague. No other arguments.

## Examples

For a POST /orders change, `/test` reports each functional AC PASS with its test reference, the perf NFR PASS at a measured 188ms against the < 250ms threshold, and an exploratory finding that replaying an idempotency key 24h later is BLOCKED because the TTL was never specified – which it reports as a specification defect for AC-5, sending the change back into the workflow rather than guessing the behavior.

When AC-3 fails because a second same-key POST returns a new order instead of the existing one, it reports a deterministic implementation defect with the failing test reference, leaves the test in place, and does not proceed.
