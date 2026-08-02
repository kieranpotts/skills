---
name: spike
description: >-
  Develop throwaway code to answer design questions. Use when a design
  question cannot be answered by reasoning alone, or when a specification is
  too speculative to commit to without evidence, or when the user says
  something like "do a spike on whether X is feasible" or "prototype this to
  answer the open question".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/CODE_STANDARD
---

# Spike

Build throwaway code to answer a specific question — eg. feasibility,
performance characteristics, API ergonomics, integration risks, etc. Your work
is time-boxed and scope-collapsed, and the artifacts you produce will never be
promoted to production.

Research and development only. You MUST NOT make any code or configuration
changes to the production software itself. Keep spikes in branches off the
main trunk, in separate worktrees if possible, or separately-cloned
repositories.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **One falsifiable question — REQUIRED.** A specific feasibility,
  performance, ergonomics, or integration-risk question that cannot be
  answered by reasoning alone, with the evidence that would close it defined
  up front.

- **Where the answer should be recorded — REQUIRED.** The project's decision
  store, design documentation, or specification, depending on what kind of
  question this is. Discover it rather than assuming it: check this
  session's context first, then the environment (a convention file such as
  `AGENTS.md`, a workspace manifest, a configured connector). If neither
  settles it, ask the user. Do not assume a filesystem path or a document
  structure.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- A single falsifiable question MUST be stated up front, not a topic and not
  an area to explore.

- The closing evidence MUST be defined before any code is written: a
  numerical threshold, observable behavior, or working integration.

- A time-box MUST be set and respected — hours or days — and reaching the
  box MUST end the spike, even if the answer is incomplete.

- Production concerns MUST be absent from the code: there MUST be no tests,
  no error handling, no auth, and no abstractions beyond what the question
  requires.

- The answer MUST be captured durably — a measurement, observable behavior,
  or working integration, recorded so it is reproducible from the notes
  alone — in whichever of the project's own stores owns that kind of answer,
  whether an ADR or design-doc update, a revision to acceptance criteria, or
  a decision-log note. That store MUST have been discovered, not assumed.

- The spike code MUST have been disposed of: deleted, or quarantined in a
  clearly-marked throwaway location with a README, and never merged into
  production paths.

## Instructions

1.  Frame one question.

    State the question in one sentence. It must be falsifiable:

    - ❌ "See if Postgres works for this." (Not a question.)

    - ✅ "Can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95
      < 50ms on c7g.large?"

    - ❌ "Try out the new SDK." (No question.)

    - ✅ "Does the new SDK's streaming API surface errors mid-stream, or
      only at stream close?"

    If you cannot phrase the question this way, return to the design work
    first.

2.  Define the answer that ends the spike.

    Before writing any code, write down what evidence would close the
    question: a measured number against a threshold, a reproducible
    behavior, or a working integration. If no such evidence is definable,
    refine the question.

3.  Time-box.

    State the budget in hours or days. When the time-box expires, stop
    and capture what you learned even if the question is not fully
    answered, then decide whether to invest another time-box or take a
    different path.

4.  Take the shortest path.

    Skip everything that does not contribute to answering the question:
    tests beyond the assertion that answers the question, error handling
    beyond observing the failure mode, abstraction, interfaces,
    configuration, auth, logging, monitoring, documentation, hardcoded
    values, fixture inputs, and a single happy path. One file is often
    enough.

5.  Isolate the spike.

    Keep spike code out of the production codebase. Use a separate repo
    or `spikes/` subdirectory, a branch named
    `spike/spike-<question>` that will not be merged, or a scratch
    directory outside any tracked path. Mark the entry point file with
    a comment naming it as a spike.

6.  Run the experiment, capture findings.

    Run the spike, and record the exact commands, the observed result
    against the expected evidence, numerical measurements with
    environment details, and any surprises that matter even though the
    question did not ask about them.

7.  Decide.

    Based on the findings, take one of these paths:

    - Answer is positive → the design question is closed. The
      production version is re-implemented from scratch.

    - Answer is negative → the option being spiked is closed; the
      design work resumes with the alternatives.

    - Answer is mixed or inconclusive → either run another time-boxed
      spike to disambiguate, or escalate the decision to the user.

8.  Document the answer, then throw the code away.

    Update the relevant artifact in whichever store owns it: the decision
    store for an architectural question, the specification for a requirements
    question, the design documentation for a structural one. Use that store's
    own form. Once the answer is captured, delete the spike code, or move it
    to a clearly-marked throwaway location with a README naming the question,
    the answer, and the date.

## Rules

- The spike code MUST be throwaway. The answer is the deliverable.

  Promoting spike code to production removes the very property that made
  it cheap to write. If it MUST ship, re-implement it cleanly using what
  was learned.

- You MUST answer the question and stop there.

  Resuming the design, revising the specification, and any production
  re-implementation are the caller's. The spike buys a decision, and the
  decision is spent elsewhere.

- You MUST pursue one question per spike.

  Two questions = two spikes. Bundling them inflates the time-box,
  blurs the findings, and tempts scope creep.

- The time-box MUST be enforced, not aspirational.

  When the budget is gone, you MUST stop and report what the budget bought
  and what is still unknown. A decision to extend MUST be explicit and
  belongs to the caller; it MUST NOT be absorbed quietly into the work. A single spike's time-box MUST NOT exceed 3–5 days; anything
  larger MUST be split into multiple spikes or treated as project work.

- Production concerns MUST be explicitly skipped.

  Tests, error handling, auth, monitoring, accessibility,
  configuration, documentation — these MUST NOT appear in a spike.
  Including them is how spikes drift into production-track work.

- You MUST surface the state.

  After every action (for a logic / state-machine spike) or on every
  variant switch (for a UI spike), you MUST print or render the full
  relevant state so the user can see what changed. A spike that
  requires a debugger to learn from isn't doing its job — the whole
  point is fast, legible feedback on the question being answered. This
  is the one production-style discipline a spike keeps, because without
  it the spike produces no usable evidence.

- Findings MUST be reproducible from notes.

  "Felt fast" is not evidence. A measurement with the command,
  dataset, and environment recorded is.

- You MUST mark spike code so it cannot be mistaken for production.

  Directory location, branch name, and file header comment SHOULD all
  be used if possible. The next reader MUST NOT have to ask.

- Negative answers SHOULD be treated as valuable.

  A spike that rules out an option is as useful as one that confirms
  one. You MUST capture the negative finding with the same care.

- You MUST NOT write tests for a spike.

  Tests anchor design. The whole point of a spike is to discover the
  design. Writing tests first turns a spike into a small project with
  all the costs that follow.

## Edge cases

- The prototype "almost works" and the user wants to keep it.

  Resist. Keeping spike code skips the specification, design, and
  implementation discipline that the spike was meant to inform, not
  replace. Re-implement cleanly. The spike itself can stay as a
  reference for the re-implementation.

- The spike reveals the question was wrong.

  Common. Capture what was learned, restate the real question, then
  decide whether to spend another time-box on the corrected question.

- The spike crosses into integration territory.

  If the question genuinely requires talking to a real production
  system (eg. measuring real-customer load), get explicit permission
  and observe production-safety rules. The "throwaway" discipline does
  not extend to ignoring production guardrails.

- Multiple spikes stack up over time.

  Periodically review the `spikes/` directory and prune. Old spikes
  that have served their purpose should be deleted; their findings
  should already live in design docs, ADRs, or specs.

- The user asks for "just a quick proof of concept" with no time-box.

  Push back. Propose a half-day or one-day box. An unbounded PoC is
  the most common path to a production system written without
  specification, design, or planning.

## Examples

- A well-framed spike:

  ```sh
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

- A spike that returns a negative answer:

  ```sh
  Question: Does the candidate vector DB's Rust client support cancellable
  queries through tonic interceptors?

  Evidence to close: a query that interrupts cleanly when the caller's
  context is canceled, releasing the connection.

  Time-box: 4 hours.

  Result: interceptors fire but the server-side query continues running
  to completion; the client just stops awaiting the response. Connection
  is released only on response. Verified with server-side logs.

  Answer: no.

  Decision: rules out this vector DB for our cancellable-search workload.
  The design work resumes, evaluating the other two candidates.
  ```
