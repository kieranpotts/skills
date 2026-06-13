# `/debug`

A disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimize → hypothesize → instrument → fix → regression-test. Use when something is broken, throwing, failing, or has regressed in performance, and the cause is not obvious from reading the code.

## What it does

`/debug` runs six phases, but the whole skill turns on the first one: **build a feedback loop** – a fast, deterministic, agent-runnable pass/fail signal for the bug. It offers a ranked menu of ways to construct one (failing test, curl script, CLI diff, headless-browser script, trace replay, throwaway harness, fuzz loop, bisection, differential run, human-driven script) and insists you don't proceed until you have a loop you believe in. With the loop in place, it reproduces the user's *actual* symptom, generates 3–5 ranked falsifiable hypotheses before testing any, instruments one variable at a time (with uniquely-tagged debug logs for clean removal), writes a regression test at a correct seam, applies the fix, then cleans up and records the correct hypothesis for the next person.

It is non-interactive, though it checkpoints its hypothesis ranking with the user when they're around.

## How to invoke

```
/debug
```

Describe the bug or regression – the symptom, where it shows up, any repro you have. No arguments. For performance work it swaps symptom-capture for a numerical baseline and threshold, and bisects rather than logs.

## Examples

For a cache returning tenant A's response to tenant B, `/debug` builds a failing integration test, ranks hypotheses (key omits tenant ID ~50%, session token consumed ~25%, worker/writer race ~15%, stale upstream ~10%), instruments the cache key with a `[DEBUG-a4f2]` log to confirm the top hypothesis, fixes `cache.ts`, locks it with a regression test, greps the tag to zero, and states the cause in the commit.

If it genuinely cannot build a loop, it stops and says so explicitly – listing what it tried and asking for a reproducing environment, a captured artifact, or permission to add production instrumentation – rather than guessing.
