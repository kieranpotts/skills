---
name: design
description: >-
  Explore architectural options and trade-offs for a feature or change.
  Enumerate alternatives, evaluate them against the nine software design
  qualities (completeness, correctness, performance, reliability, experience,
  habitability, cohesiveness, changeability, simplicity), then recommend one
  with reasoning. Gated on an approved specification — do not begin until the
  upstream specification proposal is approved (ACCEPTED), not merely proposed.
  Use when the change has architecturally significant decisions, before planning
  or implementation, or when the user says "design this feature", "what are the
  options for building this?", or "work out the architecture for this change".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/software-architect
---

# Design

**Input:**

- **An approved specification. REQUIRED.** Functional acceptance criteria and
  non-functional requirements, already reviewed and approved (`ACCEPTED`). This
  skill consumes that specification; it does not write it, and its entry gate
  refuses to begin until the approval is in place.

This skill is non-interactive: agents MUST NOT block for user input after the
initial prompt, and MUST follow the instructions to completion or fail with an
error message.

**Output:** A recommended design — the chosen option with its evaluation against
the nine qualities, the rejected alternatives and why, and a durable decision
record (ADR, design doc, or PR description). Where a design question cannot be
answered by reasoning alone, a time-boxed prototype produces the evidence that
feeds back into the evaluation. Whatever consumes the design — decomposition
into steps, implementation — is the orchestrator's concern, not this skill's.

## Instructions

1.  **Check the entry gate.**
    You MUST confirm the relevant specification proposal is `ACCEPTED`. If it is
    `DRAFT`, `PROPOSED`, or missing, you MUST stop, tell the user the design
    phase is gated on an approved specification, and direct them to approve or
    write one first.

2.  **Gather the constraints.**
    Before exploring options, you MUST write down:

    - *Functional ACs* the design must satisfy (from the approved
      specification).
    - *Non-functional requirements*: performance targets, security/compliance,
      availability, scalability, data retention.
    - *Existing system shape*: relevant modules, public APIs, data stores,
      deployment topology.
    - *Budget*: time, complexity tolerance, team familiarity, operational
      headroom.

    If any constraint is unclear, you MUST ask the user before proceeding.

3.  **Identify the decision points.**
    You MUST list the *architecturally significant* choices the design must
    make — the ones that would be expensive to reverse later. Typical examples:

    - Module/service boundaries.
    - Synchronous vs asynchronous communication.
    - Data ownership and consistency model.
    - Persistence technology.
    - Public API shape.
    - Concurrency / parallelism model.

    Cosmetic or easily-reversed decisions (variable names, file layout) are not
    decision points — you SHOULD defer them.

4.  **Enumerate alternatives per decision point.**
    You MUST produce at least two options for each decision point, including a
    do-nothing or simplest-possible alternative. A single option masquerading as
    "the design" is an assumption, not a design.

5.  **Evaluate each option against the nine design qualities.**
    For each option, you MUST note its impact (positive, neutral, negative) on
    each quality. You MUST be specific — "improves performance" is not useful;
    "removes the N+1 query, cutting p95 by ~40ms" is.

    - *Completeness*: does it cover all the functional ACs?
    - *Correctness*: can it maintain valid, consistent state under the expected
      workload?
    - *Performance*: does it meet the NFR targets?
    - *Reliability*: how does it handle and recover from failures?
    - *Experience*: how does it feel for the end user?
    - *Habitability*: how easy is it for the next developer to read, maintain,
      and evolve?
    - *Cohesiveness*: does it form a unified whole, or bolt on?
    - *Changeability*: how easily can it adapt to plausible future requirements?
    - *Simplicity*: does it minimize unnecessary complexity?

    Most options will trade qualities against one another. You MUST capture the
    trade explicitly.

6.  **Recommend one, with reasoning.**
    You MUST state which option to pick and *why* it wins on the qualities that
    matter most for this domain. You MUST name the qualities being prioritized
    and the qualities being sacrificed. If two options are close, you MUST say so
    and ask the user to break the tie.

7.  **Capture the decision.**
    For architecturally-significant decisions, you MUST write a short
    Architecture Decision Record (ADR) — context, options considered, decision,
    consequences. For smaller designs, a paragraph in the PR description or a
    comment on the issue MAY suffice.

    You MUST include enough that a developer six months from now can answer "why
    did we do it this way?" without re-running the exercise.

8.  **Report the design and stop.**
    You MUST flag any soft edges that remain — ambiguous terms, unstated
    assumptions, contested trade-offs — so they can be stress-tested before
    decomposition. You MUST report the design and stop; what consumes it is the
    orchestrator's concern.

## Rules

- **You MUST NOT design against an unapproved specification.**
  The specification is the design's contract. Until the user has approved it
  (`ACCEPTED`), its acceptance criteria can still change in review — designing
  against a moving target wastes the work. If the specification is unapproved,
  missing, or still `PROPOSED`, you MUST stop and send the user back to approve
  it (or to write one, clarifying the requirements first, if it does not yet
  exist). This is the SDLC phase gate.

- **You MUST always produce alternatives.**
  A design that considers only one option is not a design. Even an
  obviously-best choice gets stronger when its alternatives are written down
  and rejected for stated reasons.

- **You MUST evaluate against the qualities, not against personal preference.**
  The nine qualities are universal. Personal preference and habit are not.
  When you reach for "I prefer X", restate it as which quality you are
  optimizing and why it matters here.

- **You MUST identify the qualities that dominate this domain.**
  Not all qualities matter equally in every domain. A financial ledger weights
  correctness over experience; a marketing site weights experience over
  performance; a long-lived internal tool weights habitability over
  simplicity. You MUST name the priority ordering before evaluating options.

- **You MUST surface NFRs early.**
  NFRs around scalability, durability, security, and compliance often dictate
  the design (technology stack, database, deployment topology) and are
  expensive to retrofit. If the specification omitted them, you MUST stop and
  clarify before continuing.

- **You MUST cost the operational tail.**
  Designs do not end at "shipped". Account for monitoring, alerting, on-call
  burden, backup/restore, schema migration, dependency lifecycle. Cheap to
  build does not mean cheap to own.

- **You SHOULD prefer the boring option when qualities are close.**
  Familiar technology, fewer moving parts, smaller blast radius. Novelty has a
  cost the design qualities do not fully capture.

- **You SHOULD prefer deep modules to shallow ones.**
  A module is *deep* when a small, simple interface hides a lot of useful
  behavior — callers benefit from leverage. A module is *shallow* when its
  interface is nearly as complex as its implementation. When two designs
  satisfy the same ACs and NFRs, the one with deeper modules wins on simplicity,
  habitability, and changeability simultaneously.

- **You MUST document the rejected options too.**
  The "why not" is often more useful to future readers than the "why". Future
  requirements may reopen one of the rejected options — the prior reasoning
  saves a re-evaluation.

## Edge cases

- **The design is forced by an existing constraint.**
  If there is genuinely only one viable option (eg. a regulatory requirement
  names the encryption standard; an existing contract fixes the API shape),
  state the constraint, name the option, and skip the alternatives. But verify
  the constraint is real before skipping — "we've always done it that way" is
  not a constraint.

- **Prototype or spike.**
  If the goal is to learn whether something is feasible, skip the formal
  evaluation. Write the prototype, then come back and do the design for real,
  informed by what you learned.

- **Mid-build pivot.**
  If a design choice is failing under implementation, stop and redo the design
  — do not patch around it. Sunk cost is not a quality.

- **Two options are genuinely tied.**
  Say so. Present both with their trade-offs and ask the user to break the
  tie. Do not flip a coin and proceed silently.

## Success criteria

- **The entry gate MUST have been checked: the specification is approved.**
  Design MUST proceed only against an approved (`ACCEPTED`) specification. If
  the specification was unapproved or merely proposed, the skill MUST have
  stopped and sent the user to approve it first.

- **The constraints MUST be written down.**
  Functional ACs, NFRs, existing-system shape, and budget MUST be explicit
  before any option is enumerated.

- **Each decision point MUST have 2-4 evaluated alternatives.**
  No decision MUST be presented as the only option.

- **Each option MUST have been evaluated against the nine qualities.**
  Not every quality needs detailed treatment for every option, but the
  dominant qualities for the domain MUST be explicitly weighed.

- **The recommendation MUST name which qualities it prioritizes.**
  "We pick X because it optimizes for Y and Z, accepting weaker W."

- **The decision MUST be captured durably.**
  ADR, design doc, or PR description — somewhere a future reader can find it
  without asking.

## Examples

- **A compact decision capture:**

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
