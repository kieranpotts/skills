---
name: spike
description: Build throwaway code to answer a specific question — feasibility, performance characteristics, API ergonomics, integration risk. Time-boxed, scope-collapsed, never promoted to production. Use when a design question cannot be answered by reasoning alone, or when a specification is too speculative to commit to without evidence, or when the user says "spike on whether X is feasible" or "prototype this to answer the open question".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: gemma4:31b
---

# `spike`

Use this skill when a question must be answered with running code rather than analysis: feasibility of a library, performance of an algorithm, ergonomics of an API, behavior of an external dependency, viability of an architectural option. The spike is a *byproduct* and the *answer* is the deliverable — the code is time-boxed, scope-collapsed, and thrown away, never promoted to production.

**Input**: One falsifiable question — a specific feasibility, performance, ergonomics, or integration-risk question that cannot be answered by reasoning alone, with the evidence that would close it defined up front. REQUIRED.

**Output**: The answer, durably captured — a measurement, observable behavior, or working integration, recorded so it is reproducible from the notes alone, and landed in the appropriate artifact (an ADR or design-doc update, a revision to acceptance criteria, or a decision-log note). The spike code is thrown away or quarantined in a clearly-marked throwaway location, never promoted. Whatever consumes the answer — resuming design, revising the specification, the production re-implementation — is the orchestrator's concern, not this skill's.

##  Instructions

1.  **Frame one question.**

    State the question in one sentence. It MUST be falsifiable:

    - ❌ "See if Postgres works for this." (Not a question.)
    - ✅ "Can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95 < 50ms on c7g.large?"
    - ❌ "Try out the new SDK." (No question.)
    - ✅ "Does the new SDK's streaming API surface errors mid-stream, or only at stream close?"

    If you cannot phrase the question this way, you are not ready for the technical spike — you are still exploring. Return to the design work first.

2.  **Define the answer that ends the spike.**

    Before writing any code, write down what evidence would close the question. Examples:

    - A measured number against a threshold (passes / does not pass).
    - A reproducible behavior (errors observable at this point; not observable at that point).
    - A working integration (the call returns a real response from a real service).

    If no such evidence is definable, the question is still vague. Refine it.

3.  **Time-box.**

    State the budget in hours or, at most, days. A spike or prototype that grows past the time-box is no longer a spike — it is unmanaged work. Common budgets:

    - Half-day: API ergonomics, single integration check.
    - 1-2 days: performance characterization, multi-component spike.
    - 3-5 days: hard ceiling for any one spike. Anything bigger is multiple spikes or actual project work.

    When the time-box expires, *stop*. Capture what you learned even if the question is not fully answered. Decide whether to invest another time-box or take a different path.

4.  **Take the shortest path.**

    Skip everything that does not contribute to answering the question:

    - No tests beyond the one assertion that answers the question.
    - No error handling beyond what is needed to observe the failure mode.
    - No abstraction, no interfaces, no configuration.
    - No auth, no logging, no monitoring, no documentation.
    - Hardcoded values, fixture inputs, single happy path.
    - One file is often enough.

    Quality code costs time; the spike is buying *information*, not code.

5.  **Isolate the spike.**

    Keep spike code out of the production codebase. Use one of:

    - A separate repo or `spikes/` subdirectory clearly marked as throwaway.
    - A branch named `spike/spike-<question>` that will not be merged.
    - A scratch directory outside any tracked path.

    Mark the entry point file with a comment naming it as a spike. Future readers should not be able to mistake it for production code.

6.  **Run the experiment, capture findings.**

    Run the spike. Record:

    - The exact command(s) used.
    - The observed result against the expected evidence.
    - Numerical measurements with environment details (hardware, dataset, traffic).
    - Surprises — anything observed that the question did not ask about but matters.

    "It worked" is not a finding. A finding is reproducible by someone else from the notes alone.

7.  **Decide.**

    Based on the findings:

    - *Answer is positive* → the design question is closed. The production version is re-implemented properly from scratch — do not promote the spike.
    - *Answer is negative* → the option being spiked is closed; the design work resumes with the alternatives.
    - *Answer is mixed or inconclusive* → either run another time-boxed spike to disambiguate, or escalate the decision to the user. Do not silently extend.

8.  **Document the answer, then throw the code away.**

    Update the relevant artifact:

    - For an architectural question → an ADR or design-doc update.
    - For a specification question → a revision to the affected acceptance criteria.
    - For a tooling/library question → a short note in the repo's decision log.

    Once the answer is captured, delete the spike code — or, at minimum, move it somewhere unambiguous (`spikes/<date>-<question>/`) with a README naming the question, the answer, and the date.

##  Rules

-   **The code is throwaway. The answer is the deliverable.**

    Promoting spike code to production removes the very property that made it cheap to write. If it must ship, re-implement it cleanly using what was learned.

-   **One question per spike.**

    Two questions = two spikes. Bundling them inflates the time-box, blurs the findings, and tempts scope creep.

-   **Time-box is enforced, not aspirational.**

    When the budget is gone, stop. The decision to extend is explicit and made with the user, not absorbed quietly into the work.

-   **Production concerns are explicitly skipped.**

    Tests, error handling, auth, monitoring, accessibility, configuration, documentation — none of these belong in a spike. Including them is how spikes drift into production-track work.

-   **Surface the state.**

    After every action (for a logic / state-machine spike) or on every variant switch (for a UI spike), print or render the full relevant state so the user can see what changed. A spike that requires a debugger to learn from isn't doing its job — the whole point is fast, legible feedback on the question being answered. This is the one production-style discipline a spike keeps, because without it the spike produces no usable evidence.

-   **Findings MUST be reproducible from notes.**

    "Felt fast" is not evidence. A measurement with the command, dataset, and environment recorded is.

-   **Mark spike code so it cannot be mistaken for production.**

    Directory location, branch name, file header comment. All three if possible. The next reader should not have to ask.

-   **Negative answers are valuable.**

    A spike that rules out an option is as useful as one that confirms one. Capture the negative finding with the same care.

-   **Do not write tests for a spike.**

    Tests anchor design. The whole point of a spike is to discover the design. Writing tests first turns a spike into a small project with all the costs that follow.

## Examples

A well-framed spike:

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

A spike that returns a negative answer:

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

##  Edge cases

-   **The prototype "almost works" and the user wants to keep it.**

    Resist. Keeping spike code skips the specification, design, and implementation discipline that the spike was meant to *inform*, not *replace*. Re-implement cleanly. The spike itself can stay as a reference for the re-implementation.

-   **The spike reveals the question was wrong.**

    Common. Capture what was learned, restate the real question, then decide whether to spend another time-box on the corrected question.

-   **The spike crosses into integration territory.**

    If the question genuinely requires talking to a real production system (eg. measuring real-customer load), get explicit permission and observe production-safety rules. The "throwaway" discipline does not extend to ignoring production guardrails.

-   **Multiple spikes stack up over time.**

    Periodically review the `spikes/` directory and prune. Old spikes that have served their purpose should be deleted; their findings should already live in design docs, ADRs, or specs.

-   **The user asks for "just a quick proof of concept" with no time-box.**

    Push back. Propose a half-day or one-day box. An unbounded PoC is the most common path to a production system written without specification, design, or planning.

##  Success criteria

-   **A single falsifiable question is stated up front.**

    Not a topic, not an area to explore.

-   **The closing evidence is defined before any code is written.**

    Numerical threshold, observable behavior, working integration.

-   **A time-box is set and respected.**

    Hours or days. Reaching the box ends the spike, even if the answer is incomplete.

-   **Production concerns are absent from the code.**

    No tests, no error handling, no auth, no abstractions beyond what the question requires.

-   **The findings are captured durably.**

    ADR, design doc, specification update, or decision log — somewhere the answer survives after the code is gone.

-   **The code is disposed of or quarantined.**

    Deleted, or moved to a clearly-marked throwaway location with a README. Never merged into production paths.
