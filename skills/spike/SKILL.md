---
name: spike
description: >-
  Write throwaway code to answer one falsifiable design question, then record
  the answer and dispose of the code. Use when a feasibility, performance,
  ergonomics, or integration-risk question cannot be settled by reasoning
  alone, or when the user says something like "do a spike on whether X is
  feasible", "prototype this to answer the open question", or "time-box an
  experiment on X". Do not use it to build production code, or to prototype
  something that is intended to ship.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, Bash (running the spike code)
license: CC0-1.0
---

# Spike

Answer one falsifiable question — feasibility, performance, ergonomics, or
integration risk — with the smallest experiment that produces evidence, then
record the answer and throw the code away. The work is time-boxed and
scope-collapsed. Research only: you MUST NOT change the production software,
and nothing you write here is ever promoted to it.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message.

- **One falsifiable question — REQUIRED.** A single feasibility, performance,
  ergonomics, or integration-risk question that reasoning alone cannot close.
  If the context offers a topic or an area to explore rather than a question,
  the design work is not finished; stop and say so.

- **The time-box — OPTIONAL.** The budget, in hours or days. Where none is
  given, set one proportionate to the question and state it before starting.

- **The store that owns the answer — REQUIRED.** Where this class of question
  is recorded: the decision store for an architectural question, the
  specification for a requirements question, the design documentation for a
  structural one. Discover it — check this session's context first, then the
  environment: a convention file, a workspace manifest, an existing directory,
  a configured connector.

- **Where spike code may live — OPTIONAL.** An isolated location outside the
  production paths. Default to a scratch directory or an unmergeable branch
  where the project has no convention of its own.

A store MAY be a directory in this repository, a separate repository, or an
external service such as a tracker or a wiki, so you MUST NOT assume a
filesystem path, a file name, or a document structure. If context and
environment settle it, proceed; if not, stop and ask the user to name the
store before writing any code.

## Success criteria

- The write-up MUST fix three things before the first line of spike code: the
  question in one sentence, the evidence that would close it, and the
  time-box. Evidence means a numerical threshold, an observable behavior, or
  a working integration.

- The findings MUST be reproducible from the notes alone — the exact commands,
  the inputs, the environment, and the measured results — so that a reader can
  re-run the experiment without the spike code in hand.

- The write-up MUST land on a verdict of yes, no, or inconclusive. A spike
  that reaches its time-box without an answer MUST still report what the
  budget bought and what remains unknown; "needs more work" alone is not a
  finished spike.

- The answer MUST be filed in the store that owns that class of question,
  using that store's own form, and that store MUST trace to session context,
  to the environment, or to an answer from the user — never to an assumed
  path.

- The spike code MUST be gone from every production path: deleted, or left in
  a clearly-marked throwaway location carrying a README naming the question,
  the answer, and the date.

- The production codebase MUST be unchanged. No source, configuration,
  dependency, or build change outside the spike's isolated location, and
  nothing merged to the trunk.

## Instructions

1.  Frame one question.

    State it in one sentence, and make it falsifiable:

    - ❌ "See if Postgres works for this." (Not a question.)

    - ✅ "Can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95
      < 50ms on c7g.large?"

    - ❌ "Try out the new SDK." (No question.)

    - ✅ "Does the new SDK's streaming API surface errors mid-stream, or
      only at stream close?"

2.  Define the answer that ends the spike.

    Before writing any code, write down what evidence would close the
    question: a measured number against a threshold, a reproducible behavior,
    or a working integration. If no such evidence is definable, the question
    is still too vague — refine it.

3.  State the time-box in hours or days, and record it alongside the question.

4.  Take the shortest path.

    Skip everything that does not contribute to the answer: abstraction,
    interfaces, configuration, auth, logging, monitoring, documentation, and
    error handling beyond observing the failure mode. Hardcode values, use
    fixture inputs, and cover the single happy path. One file is often enough.

5.  Isolate and mark the spike.

    Keep the code out of the production paths — a scratch directory outside
    any tracked path, a dedicated subdirectory, or a branch that will not be
    merged, in a separate worktree or clone where the tooling allows. Name
    the location and the branch for what it is, and head the entry-point file
    with a comment marking it a spike. The next reader MUST NOT have to ask.

6.  Run the experiment and capture the findings.

    Record the exact commands, the observed result against the evidence
    defined in step 2, measurements with their environment, and any surprise
    that matters even though the question did not ask about it. "Felt fast"
    is not evidence; a measurement with its command, dataset, and environment
    is.

7.  Land on a verdict.

    - Positive — the design question is closed, and the production version
      will be re-implemented from scratch.

    - Negative — the option is ruled out, and the design work resumes with
      the alternatives.

    - Mixed or inconclusive — either propose another time-boxed spike that
      would disambiguate, or hand the decision back to the caller. You MUST
      NOT start that second spike on your own initiative.

8.  File the answer, then dispose of the code.

    Update the artifact in whichever store owns the question, following that
    store's own conventions for form and lifecycle. Once the answer is
    captured, delete the spike code, or move it to a clearly-marked throwaway
    location with a README naming the question, the answer, and the date.

## Rules

- You MUST pursue exactly one question per spike.

  Two questions are two spikes. Bundling them inflates the time-box, blurs
  the findings, and invites scope creep.

- Spike code MUST NOT be promoted to production, however close to working it
  looks.

  What makes spike code cheap to write is precisely everything it omits.
  Shipping it keeps the omissions. If the capability must ship, it is
  re-implemented cleanly using what the spike taught.

- The time-box MUST be enforced rather than aspirational, and a single
  spike's box SHOULD NOT exceed three to five days.

  When the budget is gone, stop and report. Extending is the caller's
  decision and MUST be explicit; it MUST NOT be absorbed quietly into the
  work. A question needing longer than a week is either several spikes or
  project work.

- Production concerns MUST be absent from spike code.

  Error handling, auth, monitoring, accessibility, configuration, and
  documentation MUST NOT appear. Including them is how a spike drifts into
  production-track work on a production-track schedule.

- You MUST NOT write tests for a spike.

  Tests anchor a design. A spike exists to discover the design, so tests
  written up front turn it into a small project carrying all the costs that
  follow. The only assertion worth making is the one that answers the
  question.

- You MUST surface the state.

  After every action for a logic or state-machine spike, and on every variant
  switch for a UI spike, print or render the full relevant state. This is the
  one production-style discipline a spike keeps: a spike that needs a debugger
  to learn from produces no usable evidence.

- You MUST answer the question and stop there.

  Resuming the design, revising the specification, and any production
  re-implementation belong to the caller. The spike buys a decision; the
  decision is spent elsewhere.

- Negative answers SHOULD be treated as valuable, and captured with the same
  care as positive ones.

  A spike that rules an option out has done its job just as well as one that
  confirms an option.

## Edge cases

- The prototype "almost works" and the user wants to keep it.

  Resist. Keeping it skips the specification, design, and implementation
  discipline that the spike was meant to inform rather than replace. The
  spike MAY stay as a reference for the clean re-implementation.

- The spike reveals the question was wrong.

  Common, and not a failure. Capture what was learned, restate the real
  question, and hand back the choice of whether to spend another time-box
  on the corrected question.

- The question genuinely requires a real production system, eg. measuring
  behavior under real customer load.

  Get explicit permission first and observe the project's production-safety
  rules. The throwaway discipline does not extend to ignoring production
  guardrails.

- Old spikes have accumulated in the throwaway location.

  Prune them. Their findings should already live in the stores that own
  them, and a spike whose findings were never filed is a gap to report, not
  a file to keep.

- The user asks for "just a quick proof of concept" with no time-box.

  Push back, and propose a half-day or one-day box. An unbounded proof of
  concept is the most common path to a production system built with no
  specification, design, or plan behind it.

## Examples

- A spike that returns a positive answer:

  ```text
  Question: Can the ImageMagick 7 API process our largest customer asset
  (~120MB TIFF) in under 30s on the current worker hardware, without
  exceeding 4GB RSS?

  Evidence to close: a measurement on the actual asset, on a c7g.large,
  showing wall-clock and peak RSS.

  Time-box: half a day.

  Path: build IM7 from source, write a 20-line wrapper that loads the
  fixture asset and applies the resize and format pipeline used in
  production, instrument with /usr/bin/time -v.

  Result: wall-clock 18.4s, peak RSS 3.1GB.

  Verdict: yes, within budget. Question closed; the production version
  will be implemented from scratch, applying our error handling,
  telemetry, and configuration conventions.

  Disposal: spike retained in the throwaway location with a README
  naming the question, the answer, and the date. Not merged.
  ```

- A spike that returns a negative answer:

  ```text
  Question: Does the candidate vector DB's Rust client support cancellable
  queries through tonic interceptors?

  Evidence to close: a query that interrupts cleanly when the caller's
  context is canceled, releasing the connection.

  Time-box: 4 hours.

  Result: interceptors fire, but the server-side query runs to completion
  and the client merely stops awaiting the response. The connection is
  released only on response. Verified against server-side logs.

  Verdict: no. This rules the candidate out for our cancellable-search
  workload. The design work resumes with the other two candidates.

  Disposal: spike code deleted; finding filed in the decision store.
  ```
