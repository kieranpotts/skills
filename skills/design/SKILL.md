---
name: design
description: Explore architectural options and trade-offs for a feature or change. Enumerate alternatives, evaluate them against the nine software design qualities (completeness, correctness, performance, reliability, experience, habitability, cohesiveness, changeability, simplicity), then recommend one with reasoning. Use after [`specify`](../specify/SKILL.md) is agreed and before [`plan`](../plan/SKILL.md) or [`code`](../code/SKILL.md) when the change has architecturally significant decisions.
license: MIT
metadata:
  preferred_model: qwen3.5:cloud
---

# Design

Use this skill after the acceptance criteria are agreed but before any planning or coding work, whenever the change involves a non-trivial design decision - new module boundaries, a data-flow change, a new dependency, a persistence choice, a concurrency model, a public API.

Do NOT use this skill for trivial changes whose design is obvious (bug fixes, copy edits, renames - go straight to [`code`](../code/SKILL.md) or [`refactor`](../refactor/SKILL.md)).

Do NOT use this skill to write requirements (use [`specify`](../specify/SKILL.md)) or to break delivery into steps (use [`plan`](../plan/SKILL.md)).

##  Instructions

1.  **Gather the constraints.**

    Before exploring options, write down:

    - *Functional ACs* the design must satisfy (from [`specify`](../specify/SKILL.md)).
    - *Non-functional requirements*: performance targets, security/compliance, availability, scalability, data retention.
    - *Existing system shape*: relevant modules, public APIs, data stores, deployment topology.
    - *Budget*: time, complexity tolerance, team familiarity, operational headroom.

    If any constraint is unclear, ask the user before proceeding. A design built on guessed constraints will need to be redone.

2.  **Identify the decision points.**

    List the *architecturally significant* choices the design must make - the ones that would be expensive to reverse later. Typical examples:

    - Module/service boundaries.
    - Synchronous vs asynchronous communication.
    - Data ownership and consistency model.
    - Persistence technology.
    - Public API shape.
    - Concurrency / parallelism model.

    Cosmetic or easily-reversed decisions (variable names, file layout) are not decision points - defer them.

3.  **Enumerate 2-4 options per decision.**

    Always produce at least two. A single option masquerading as "the design" is not a design - it is an assumption. Include a do-nothing or simplest-possible option as one of the alternatives; sometimes the right answer is "don't build it that way".

4.  **Evaluate each option against the nine design qualities.**

    For each option, note its impact (positive, neutral, negative) on each quality. Be specific - "improves performance" is not useful; "removes the N+1 query, cutting p95 by ~40ms" is.

    - *Completeness*: does it cover all the functional ACs?
    - *Correctness*: can it maintain valid, consistent state under the expected workload?
    - *Performance*: does it meet the NFR targets?
    - *Reliability*: how does it handle and recover from failures?
    - *Experience*: how does it feel for the end user?
    - *Habitability*: how easy is it for the next developer to read, maintain, and evolve?
    - *Cohesiveness*: does it form a unified whole, or bolt on?
    - *Changeability*: how easily can it adapt to plausible future requirements?
    - *Simplicity*: does it minimize unnecessary complexity?

    Most options will trade qualities against one another. Capture the trade explicitly.

5.  **Recommend one, with reasoning.**

    State which option to pick and *why* it wins on the qualities that matter most for this domain. Name the qualities being prioritized and the qualities being sacrificed. If two options are close, say so and ask the user to break the tie.

6.  **Capture the decision.**

    For architecturally-significant decisions, write a short Architecture Decision Record (ADR) - context, options considered, decision, consequences. For smaller designs, a paragraph in the PR description or a comment on the issue is sufficient.

    Include enough that a developer six months from now can answer "why did we do it this way?" without re-running the exercise.

7.  **Hand off to [`elaborate`](../elaborate/SKILL.md) (or directly to [`plan`](../plan/SKILL.md)).**

    If the draft has soft edges - ambiguous terms, unstated assumptions, contested trade-offs - hand off to [`elaborate`](../elaborate/SKILL.md) to stress-test it one question at a time before decomposition. Once the design is decomposition-ready, [`plan`](../plan/SKILL.md) breaks it into shippable steps.

    Trivial designs may skip [`elaborate`](../elaborate/SKILL.md) and go straight to [`plan`](../plan/SKILL.md).

##  Rules

-   **Always produce alternatives.**

    A design that considers only one option is not a design. Even an obviously-best choice gets stronger when its alternatives are written down and rejected for stated reasons.

-   **Evaluate against the qualities, not against personal preference.**

    The nine qualities are universal. Personal preference and habit are not. When you reach for "I prefer X", restate it as which quality you are optimizing and why it matters here.

-   **Identify the qualities that dominate this domain.**

    Not all qualities matter equally in every domain. A financial ledger weights correctness over experience; a marketing site weights experience over performance; a long-lived internal tool weights habitability over simplicity. Name the priority ordering before evaluating options.

-   **Surface NFRs early.**

    NFRs around scalability, durability, security, and compliance often dictate the design (technology stack, database, deployment topology) and are expensive to retrofit. If the [`specify`](../specify/SKILL.md) omitted them, stop and clarify before continuing.

-   **Cost the operational tail.**

    Designs do not end at "shipped". Account for monitoring, alerting, on-call burden, backup/restore, schema migration, dependency lifecycle. Cheap to build does not mean cheap to own.

-   **Prefer the boring option when qualities are close.**

    Familiar technology, fewer moving parts, smaller blast radius. Novelty has a cost the design qualities do not fully capture.

-   **Prefer deep modules to shallow ones.**

    A module is *deep* when a small, simple interface hides a lot of useful behavior - callers benefit from leverage. A module is *shallow* when its interface is nearly as complex as its implementation - it gives callers little for the cost of learning it. When two designs satisfy the same ACs and NFRs, the one with deeper modules wins on simplicity, habitability, and changeability simultaneously.

    Signs of a shallow module: the interface is a thin wrapper around the implementation; it passes most of its arguments straight through; deleting it would not concentrate complexity. Signs of a deep module: many callers; a small, stable interface; the implementation can be rewritten without changing any caller. Aim for depth when enumerating options, not just when evaluating them.

    This rule pairs with the *deletion test* in [`refactor`](../refactor/SKILL.md): depth is the *target*, the deletion test is the *diagnostic* that tells you whether you've hit it.

-   **Document the rejected options too.**

    The "why not" is often more useful to future readers than the "why". Future requirements may reopen one of the rejected options - the prior reasoning saves a re-evaluation.

## Examples

A compact decision capture:

```
Decision: Use Postgres LISTEN/NOTIFY for job dispatch.

Context:
- Need to fan out ~50 jobs/sec from the API to workers.
- p95 dispatch latency target: <200ms.
- Team operates Postgres already; no Kafka/RabbitMQ in stack.

Options considered:
1. Postgres LISTEN/NOTIFY (CHOSEN)
   + No new infra; reuses existing operational knowledge (habitability,
     simplicity).
   + Meets latency target (measured ~30ms p95 in spike).
   - Caps at ~few-thousand jobs/sec; not future-proof past 10x growth.

2. Add Redis Streams
   + Higher throughput ceiling.
   - New operational surface; on-call team is unfamiliar (habitability -).
   - Extra failure mode (Redis unavailability) for a problem we don't
     have today.

3. Add SQS
   + Managed, durable, scalable.
   - Adds AWS coupling; cross-region latency makes p95 marginal.
   - More expensive at our volume.

Decision: Option 1. Optimizes for habitability and simplicity while
meeting the stated NFRs. Re-evaluate if sustained throughput exceeds
2000 jobs/sec, at which point Option 2 or 3 becomes worth the cost.

Consequences:
- Workers must hold a long-lived Postgres connection (connection pool
  sizing impact).
- Migration to a real queue is a known future cost; design the dispatch
  interface to make that swap straightforward.
```

##  Edge cases

-   **The design is forced by an existing constraint.**

    If there is genuinely only one viable option (eg. a regulatory requirement names the encryption standard; an existing contract fixes the API shape), state the constraint, name the option, and skip the alternatives. But verify the constraint is real before skipping - "we've always done it that way" is not a constraint.

-   **Prototype or spike.**

    If the goal is to learn whether something is feasible, skip the formal evaluation. Write the prototype, then come back and do the design for real, informed by what you learned.

-   **Mid-build pivot.**

    If a design choice is failing under implementation, stop and redo the design - do not patch around it. Sunk cost is not a quality.

-   **Two options are genuinely tied.**

    Say so. Present both with their trade-offs and ask the user to break the tie. Do not flip a coin and proceed silently.

##  Success criteria

-   **The constraints are written down.**

    Functional ACs, NFRs, existing-system shape, and budget are explicit before any option is enumerated.

-   **At least two alternatives are evaluated per decision point.**

    No decision is presented as the only option.

-   **Each option has been evaluated against the nine qualities.**

    Not every quality needs detailed treatment for every option, but the dominant qualities for the domain are explicitly weighed.

-   **The recommendation names which qualities it prioritizes.**

    "We pick X because it optimizes for Y and Z, accepting weaker W."

-   **The decision is captured durably.**

    ADR, design doc, or PR description - somewhere a future reader can find it without asking.

## References

<!--

TODO: Reinstate TS-* cross-references when those are republished.

- [TS-10: Software Design Qualities](https://github.com/kieranpotts/standards/tree/dev/ts/010): The full taxonomy of the nine qualities. Read when an evaluation needs deeper rationale on a specific quality.

- [TS-11a: Design Docs](https://github.com/kieranpotts/standards/tree/dev/ts/011a): Conventions for design documents. Read before writing an ADR or long-form design doc.

- [TS-12: Application Architecture](https://github.com/kieranpotts/standards/tree/dev/ts/012): Architectural patterns for single-node applications.

-->

- [`specify`](../specify/SKILL.md): Produces the constraints this skill consumes.

- [`elaborate`](../elaborate/SKILL.md): Stress-tests the draft design one question at a time before decomposition.

- [`plan`](../plan/SKILL.md): Consumes the (elaborated) design output.

- [`prototype`](../prototype/SKILL.md): Sidecar - when a design question cannot be answered by reasoning alone, a time-boxed prototype produces the evidence.

- [`audit`](../audit/SKILL.md): Upstream source - audit produces a prioritised list of architectural findings; each one becomes input to a new workflow iteration starting here.

- [`refactor`](../refactor/SKILL.md): Upstream feedback - a refactor that crosses module boundaries or alters interfaces escalates back into design.
