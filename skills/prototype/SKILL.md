---
name: prototype
description: Build throwaway code to answer a specific question - feasibility, performance characteristics, API ergonomics, integration risk. Time-boxed, scope-collapsed, never promoted to production. Use when [`design`](../design/SKILL.md) hits a question that cannot be answered by reasoning alone, or when a [`specify`](../specify/SKILL.md) is too speculative to commit to without evidence.
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: gemma4:31b
---

# Prototype

Use this skill when a question must be answered with running code rather than analysis: feasibility of a library, performance of an algorithm, ergonomics of an API, behavior of an external dependency, viability of an architectural option.

Do NOT use this skill to build something you intend to keep (use [`code`](../code/SKILL.md)). Do NOT use it to fix a bug (use [`debug`](../debug/SKILL.md)).

A prototype is a *byproduct*. The product is the *answer*. The code is thrown away.

##  Instructions

1.  **Frame one question.**

    State the question in one sentence. It MUST be falsifiable:

    - ❌ "See if Postgres works for this." (Not a question.)
    - ✅ "Can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95 < 50ms on c7g.large?"
    - ❌ "Try out the new SDK." (No question.)
    - ✅ "Does the new SDK's streaming API surface errors mid-stream, or only at stream close?"

    If you cannot phrase the question this way, you are not ready to prototype - you are still exploring. Loop back to [`design`](../design/SKILL.md) first.

2.  **Define the answer that ends the prototype.**

    Before writing any code, write down what evidence would close the question. Examples:

    - A measured number against a threshold (passes / does not pass).
    - A reproducible behavior (errors observable at this point; not observable at that point).
    - A working integration (the call returns a real response from a real service).

    If no such evidence is definable, the question is still vague. Refine it.

3.  **Time-box.**

    State the budget in hours or, at most, days. A prototype that grows past the time-box is no longer a prototype - it is unmanaged work. Common budgets:

    - Half-day: API ergonomics, single integration check.
    - 1-2 days: performance characterization, multi-component spike.
    - 3-5 days: hard ceiling for any one prototype. Anything bigger is multiple prototypes or actual project work.

    When the time-box expires, *stop*. Capture what you learned even if the question is not fully answered. Decide whether to invest another time-box or take a different path.

4.  **Take the shortest path.**

    Skip everything that does not contribute to answering the question:

    - No tests beyond the one assertion that answers the question.
    - No error handling beyond what is needed to observe the failure mode.
    - No abstraction, no interfaces, no configuration.
    - No auth, no logging, no monitoring, no documentation.
    - Hardcoded values, fixture inputs, single happy path.
    - One file is often enough.

    Quality code costs time; the prototype is buying *information*, not code.

5.  **Isolate the prototype.**

    Keep prototype code out of the production codebase. Use one of:

    - A separate repo or `prototypes/` subdirectory clearly marked as throwaway.
    - A branch named `temp/spike-<question>` (see [`branch`](../branch/SKILL.md)) that will not be merged.
    - A scratch directory outside any tracked path.

    Mark the entry point file with a comment naming it as a spike. Future readers should not be able to mistake it for production code.

6.  **Run the experiment, capture findings.**

    Run the prototype. Record:

    - The exact command(s) used.
    - The observed result against the expected evidence.
    - Numerical measurements with environment details (hardware, dataset, traffic).
    - Surprises - anything observed that the question did not ask about but matters.

    "It worked" is not a finding. A finding is reproducible by someone else from the notes alone.

7.  **Decide.**

    Based on the findings:

    - *Answer is positive* → close the design question. Move to [`plan`](../plan/SKILL.md) or back to [`design`](../design/SKILL.md) with the answer. Re-implement properly under [`code`](../code/SKILL.md) - do not promote the prototype.
    - *Answer is negative* → close the option being prototyped. Loop back to [`design`](../design/SKILL.md) for alternatives.
    - *Answer is mixed or inconclusive* → either run another time-boxed prototype to disambiguate, or escalate the decision to the user. Do not silently extend.

8.  **Document the answer, then throw the code away.**

    Update the relevant artifact:

    - For an architectural question → ADR or design-doc update (see [`design`](../design/SKILL.md)).
    - For a specification question → revise the ACs in [`specify`](../specify/SKILL.md).
    - For a tooling/library question → a short note in the repo's decision log.

    Once the answer is captured, delete the prototype - or, at minimum, move it somewhere unambiguous (`prototypes/<date>-<question>/`) with a README naming the question, the answer, and the date.

##  Rules

-   **The code is throwaway. The answer is the deliverable.**

    Promoting prototype code to production removes the very property that made it cheap to write. If it must ship, re-implement it cleanly under [`code`](../code/SKILL.md) using what was learned.

-   **One question per prototype.**

    Two questions = two prototypes. Bundling them inflates the time-box, blurs the findings, and tempts scope creep.

-   **Time-box is enforced, not aspirational.**

    When the budget is gone, stop. The decision to extend is explicit and made with the user, not absorbed quietly into the work.

-   **Production concerns are explicitly skipped.**

    Tests, error handling, auth, monitoring, accessibility, configuration, documentation - none of these belong in a prototype. Including them is how prototypes drift into production-track work.

-   **Surface the state.**

    After every action (for a logic / state-machine prototype) or on every variant switch (for a UI prototype), print or render the full relevant state so the user can see what changed. A prototype that requires a debugger to learn from isn't doing its job - the whole point is fast, legible feedback on the question being answered. This is the one production-style discipline a prototype keeps, because without it the prototype produces no usable evidence.

-   **Findings MUST be reproducible from notes.**

    "Felt fast" is not evidence. A measurement with the command, dataset, and environment recorded is.

-   **Mark prototype code so it cannot be mistaken for production.**

    Directory location, branch name, file header comment. All three if possible. The next reader should not have to ask.

-   **Negative answers are valuable.**

    A prototype that rules out an option is as useful as one that confirms one. Capture the negative finding with the same care.

-   **Do not write tests for a prototype.**

    Tests anchor design. The whole point of a prototype is to discover the design. Writing tests first turns a prototype into a small project with all the costs that follow.

## Examples

A well-framed prototype:

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

Re-evaluate: yes — IM7 is viable on current hardware. Move to plan;
production version will be implemented from scratch under code,
applying our error handling, telemetry, and config conventions.

Code disposal: prototypes/2026-05-im7-spike/ retained with README
noting question, answer, and date. Not merged.
```

A prototype that returns a negative answer:

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
Loop back to design and evaluate the other two candidates.
```

##  Edge cases

-   **The prototype "almost works" and the user wants to keep it.**

    Resist. Keeping prototype code skips the [`specify`](../specify/SKILL.md), [`design`](../design/SKILL.md), and [`code`](../code/SKILL.md) discipline that the prototype was meant to *inform*, not *replace*. Re-implement cleanly. The prototype itself can stay as a reference for the re-implementation.

-   **The prototype reveals the question was wrong.**

    Common. Capture what was learned, restate the real question, then decide whether to spend another time-box on the corrected question.

-   **The prototype crosses into integration territory.**

    If the question genuinely requires talking to a real production system (eg. measuring real-customer load), get explicit permission and observe production-safety rules. The "throwaway" discipline does not extend to ignoring production guardrails.

-   **Multiple prototypes stack up over time.**

    Periodically review the `prototypes/` directory and prune. Old prototypes that have served their purpose should be deleted; their findings should already live in design docs, ADRs, or specs.

-   **The user asks for "just a quick proof of concept" with no time-box.**

    Push back. Propose a half-day or one-day box. An unbounded PoC is the most common path to a production system written without [`specify`](../specify/SKILL.md), [`design`](../design/SKILL.md), or [`plan`](../plan/SKILL.md).

##  Success criteria

-   **A single falsifiable question is stated up front.**

    Not a topic, not an area to explore.

-   **The closing evidence is defined before any code is written.**

    Numerical threshold, observable behavior, working integration.

-   **A time-box is set and respected.**

    Hours or days. Reaching the box ends the prototype, even if the answer is incomplete.

-   **Production concerns are absent from the code.**

    No tests, no error handling, no auth, no abstractions beyond what the question requires.

-   **The findings are captured durably.**

    ADR, design doc, specification update, or decision log - somewhere the answer survives after the code is gone.

-   **The code is disposed of or quarantined.**

    Deleted, or moved to a clearly-marked throwaway location with a README. Never merged into production paths.

## References

- [`design`](../design/SKILL.md): Where the question usually originates and where the answer usually lands.

- [`specify`](../specify/SKILL.md): Where prototype findings may force AC changes.

- [`plan`](../plan/SKILL.md): Where work continues once the prototype has answered its question.

- [`code`](../code/SKILL.md): Where the production re-implementation happens - the prototype itself is never promoted.

- [`branch`](../branch/SKILL.md): `temp/spike-*` naming convention for prototype branches.
