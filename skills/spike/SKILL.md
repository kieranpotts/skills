---
name: spike
description: >-
  Build throwaway code to answer a specific question — feasibility, performance
  characteristics, API ergonomics, integration risk. Time-boxed,
  scope-collapsed, never promoted to production. Use when a design question
  cannot be answered by reasoning alone, or when a specification is too
  speculative to commit to without evidence, or when the user says "spike on
  whether X is feasible" or "prototype this to answer the open question".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programmer
---

# Spike

Build throwaway code to answer a specific question — feasibility, performance
characteristics, API ergonomics, integration risk.

**Input:**

- **One falsifiable question. REQUIRED.** A specific feasibility, performance,
  ergonomics, or integration-risk question that cannot be answered by reasoning
  alone, with the evidence that would close it defined up front.

You MUST complete this task non-interactively. You MUST NOT block for user input
after this initial prompt. You MUST follow the instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

**Output:**

The answer, durably captured — a measurement, observable behavior,
or working integration, recorded so it is reproducible from the notes alone, and
landed in the appropriate artifact (an ADR or design-doc update, a revision to
acceptance criteria, or a decision-log note). The spike code is thrown away or
quarantined in a clearly-marked throwaway location, never promoted. Whatever
consumes the answer — resuming design, revising the specification, the
production re-implementation — is the orchestrator's concern, not this skill's.

## Instructions

1.  **Frame one question.**

    You MUST state the question in one sentence. It MUST be falsifiable:

    - ❌ "See if Postgres works for this." (Not a question.)

    - ✅ "Can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95 < 50ms on
      c7g.large?"

    - ❌ "Try out the new SDK." (No question.)

    - ✅ "Does the new SDK's streaming API surface errors mid-stream, or only at
      stream close?"

    If you cannot phrase the question this way, you MUST return to the design
    work first.

2.  **Define the answer that ends the spike.**

    Before writing any code, you MUST write down what evidence would close the
    question: a measured number against a threshold, a reproducible behavior, or
    a working integration. If no such evidence is definable, you MUST refine the
    question.

3.  **Time-box.**

    You MUST state the budget in hours or days. When the time-box expires, you
    MUST stop and capture what you learned even if the question is not fully
    answered, then decide whether to invest another time-box or take a different
    path.

4.  **Take the shortest path.**

    You MUST skip everything that does not contribute to answering the question:
    tests beyond the assertion that answers the question, error handling beyond
    observing the failure mode, abstraction, interfaces, configuration, auth,
    logging, monitoring, documentation, hardcoded values, fixture inputs, and a
    single happy path. One file is often enough.

5.  **Isolate the spike.**

    You MUST keep spike code out of the production codebase. You SHOULD use a
    separate repo or `spikes/` subdirectory, a branch named
    `spike/spike-<question>` that will not be merged, or a scratch directory
    outside any tracked path. You MUST mark the entry point file with a comment
    naming it as a spike.

6.  **Run the experiment, capture findings.**

    You MUST run the spike, and MUST record the exact commands, the observed
    result against the expected evidence, numerical measurements with environment
    details, and any surprises that matter even though the question did not ask
    about them.

7.  **Decide.**

    Based on the findings, you MUST take one of these paths:

    - *Answer is positive* → the design question is closed. The production
      version is re-implemented from scratch.

    - *Answer is negative* → the option being spiked is closed; the design work
      resumes with the alternatives.

    - *Answer is mixed or inconclusive* → either run another time-boxed spike to
      disambiguate, or escalate the decision to the user.

8.  **Document the answer, then throw the code away.**

    You MUST update the relevant artifact (ADR or design-doc update for an
    architectural question, revision to acceptance criteria for a specification
    question, or a short note in the repo's decision log for a tooling/library
    question). Once the answer is captured, you MUST delete the spike code, or
    move it to a clearly-marked throwaway location with a README naming the
    question, the answer, and the date.

## Rules

- **The spike code MUST be throwaway. The answer is the deliverable.**

  Promoting spike code to production removes the very property that made it
  cheap to write. If it MUST ship, re-implement it cleanly using what was
  learned.

- **You MUST pursue one question per spike.**

  Two questions = two spikes. Bundling them inflates the time-box, blurs the
  findings, and tempts scope creep.

- **The time-box MUST be enforced, not aspirational.**

  When the budget is gone, you MUST stop. The decision to extend MUST be
  explicit and made with the user, not absorbed quietly into the work. A
  single spike's time-box MUST NOT exceed 3–5 days; anything larger MUST be
  split into multiple spikes or treated as project work.

- **Production concerns MUST be explicitly skipped.**

  Tests, error handling, auth, monitoring, accessibility, configuration,
  documentation — these MUST NOT appear in a spike. Including them is how
  spikes drift into production-track work.

- **You MUST surface the state.**

  After every action (for a logic / state-machine spike) or on every variant
  switch (for a UI spike), you MUST print or render the full relevant state so
  the user can see what changed. A spike that requires a debugger to learn
  from isn't doing its job — the whole point is fast, legible feedback on the
  question being answered. This is the one production-style discipline a
  spike keeps, because without it the spike produces no usable evidence.

- **Findings MUST be reproducible from notes.**

  "Felt fast" is not evidence. A measurement with the command, dataset, and
  environment recorded is.

- **You MUST mark spike code so it cannot be mistaken for production.**

  Directory location, branch name, and file header comment SHOULD all be used if
  possible. The next reader MUST NOT have to ask.

- **Negative answers SHOULD be treated as valuable.**

  A spike that rules out an option is as useful as one that confirms one.
  You MUST capture the negative finding with the same care.

- **You MUST NOT write tests for a spike.**

  Tests anchor design. The whole point of a spike is to discover the design.
  Writing tests first turns a spike into a small project with all the costs
  that follow.

## Edge cases

- **The prototype "almost works" and the user wants to keep it.**

  Resist. Keeping spike code skips the specification, design, and
  implementation discipline that the spike was meant to *inform*, not
  *replace*. Re-implement cleanly. The spike itself can stay as a reference
  for the re-implementation.

- **The spike reveals the question was wrong.**

  Common. Capture what was learned, restate the real question, then decide
  whether to spend another time-box on the corrected question.

- **The spike crosses into integration territory.**

  If the question genuinely requires talking to a real production system (eg.
  measuring real-customer load), get explicit permission and observe
  production-safety rules. The "throwaway" discipline does not extend to
  ignoring production guardrails.

- **Multiple spikes stack up over time.**

  Periodically review the `spikes/` directory and prune. Old spikes that have
  served their purpose should be deleted; their findings should already live
  in design docs, ADRs, or specs.

- **The user asks for "just a quick proof of concept" with no time-box.**

  Push back. Propose a half-day or one-day box. An unbounded PoC is the most
  common path to a production system written without specification, design, or
  planning.

## Success criteria

- **A single falsifiable question MUST be stated up front.**

  Not a topic, not an area to explore.

- **The closing evidence MUST be defined before any code is written.**

  Numerical threshold, observable behavior, working integration.

- **A time-box MUST be set and respected.**

  Hours or days. Reaching the box MUST end the spike, even if the answer is
  incomplete.

- **Production concerns MUST be absent from the code.**

  There MUST be no tests, no error handling, no auth, no abstractions beyond
  what the question requires.

- **The findings MUST be captured durably.**

  ADR, design doc, specification update, or decision log — somewhere the
  answer survives after the code is gone.

- **The code MUST be disposed of or quarantined.**

  Deleted, or moved to a clearly-marked throwaway location with a README.
  It MUST NOT be merged into production paths.

## Examples

- **A well-framed spike:**

  ```
  Question: Can the new ImageMagick 7 API process our largest customer
  asset (~120MB TIFF) in under 30s on the current worker hardware,
  without exceeding 4GB RSS?

  Evidence to close: a measurement on the actual asset, on a c7g.large,
  showing wall-clock and peak RSS.

  Time-box: half a day.

  Path: clone IM7 from source, build, write a 20-line wrapper that
  loads the fixture asset and applies the resize+format pipeline used in
  production, instrument with /usr/bin/time -v.

  Result: wall-clock 18.4s, peak RSS 3.1GB. Answer: yes, within budget.

  Re-evaluate: yes — IM7 is viable on current hardware. Question closed;
  production version will be implemented from scratch, applying our error
  handling, telemetry, and config conventions.

  Code disposal: spikes/2026-05-im7-spike/ retained with README
  noting question, answer, and date. Not merged.
  ```

- **A spike that returns a negative answer:**

  ```
  Question: Does the candidate vector DB's Rust client support cancellable
  queries through tonic interceptors?

  Evidence to close: a query that interrupts cleanly when the caller's
  context is cancelled, releasing the connection.

  Time-box: 4 hours.

  Result: interceptors fire but the server-side query continues running
  to completion; the client just stops awaiting the response. Connection
  is released only on response. Verified with server-side logs.

  Answer: no.

  Decision: rules out this vector DB for our cancellable-search workload.
  The design work resumes, evaluating the other two candidates.
  ```
