---
name: design
description: >-
  Explore architectural options for a change and recommend one, with the
  trade-offs made explicit. Use when a change involves architecturally
  significant decisions, or when the user says something like "design this
  feature", "what are the options for building this?", or "work out the
  architecture for this change". Do not use it to write requirements, to
  decompose a design into delivery steps, or to implement anything.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep
license: CC0-1.0
---

# Design

Explore architectural options for a feature or other change in requirements,
evaluate each against the nine design qualities, and recommend one with clear
reasoning for why its trade-offs are the right ones here. This is design work
only: you MUST NOT change the software's code or configuration.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message.

- **An approved specification — REQUIRED.** The functional acceptance
  criteria and non-functional requirements the design must satisfy, already
  reviewed and approved. This skill consumes that specification; it does not
  write it.

- **The specification store — REQUIRED.** Where the specification lives and
  how to read it. Discover it: check this session's context first, then the
  environment — a convention file, a workspace manifest, an existing
  directory, a configured connector.

- **The decision store — REQUIRED.** Where the project records
  architecturally significant decisions and their rationale. Discover it the
  same way. Projects call it an RFC archive, a decision log, or an ADR
  directory; they are the same role.

Either store MAY be a directory in this repository, a separate repository, or
an external service such as a tracker or a wiki, so you MUST NOT assume a
filesystem path, a file name, or a document structure. If context and
environment settle neither, stop and ask the user to name the store before
going further.

## Success criteria

- Exactly one option per decision point MUST be recommended, naming both the
  qualities it prioritizes and the qualities it sacrifices — "we pick X
  because it optimizes for Y and Z, accepting weaker W".

- The constraints — functional acceptance criteria, non-functional
  requirements, the shape of the existing system, and the budget — MUST have
  been written down before the first option was enumerated.

- The qualities that dominate this domain MUST have been named and ranked
  before any option was compared against them.

- Each decision point MUST carry between two and four evaluated alternatives,
  and each rejected alternative MUST be recorded with the reason it lost.

- The rationale MUST be recorded exactly once, in the project's own decision
  store and in that store's own form, with no second copy of it elsewhere.

- The software itself MUST be unchanged: no source file, configuration file,
  schema, or dependency manifest may have been written by this task.

- The design MUST stop short of a delivery plan: no decomposition into tasks,
  estimates, or sequencing.

## Instructions

1.  Check the entry gate.

    Resolve the specification store, then confirm the relevant requirements
    are approved — whatever state that store uses to mean "agreed and ready
    to build". If they are still draft, still under review, or missing
    entirely, stop, tell the user the design phase is gated on an approved
    specification, and direct them to approve or write one first.

2.  Gather the constraints.

    Before exploring options, write down:

    - Functional acceptance criteria the design must satisfy, from the
      approved specification.

    - Non-functional requirements: performance targets, security and
      compliance, availability, scalability, data retention.

    - Existing system shape: relevant modules, public APIs, data stores,
      deployment topology.

    - Budget: time, complexity tolerance, team familiarity, operational
      headroom.

    If any constraint is unclear, stop and report what is missing rather
    than designing against a guess.

3.  Rank the qualities for this domain.

    Name which of the nine qualities dominate here, and in what order, before
    you start comparing options. The ranking is what makes a trade-off
    arguable rather than a matter of taste.

4.  Identify the decision points.

    List the architecturally significant choices the design must make — the
    ones that would be expensive to reverse later. Typical examples:

    - Module and service boundaries.
    - Synchronous vs. asynchronous communication.
    - Data ownership and consistency model.
    - Persistence technology.
    - Public API shape.
    - Concurrency and parallelism model.

    Cosmetic or easily reversed decisions, such as variable names and file
    layout, are not decision points. Defer them.

5.  Enumerate alternatives per decision point.

    Produce at least two options for each, including a do-nothing or
    simplest-possible alternative. A single option masquerading as "the
    design" is an assumption, not a design.

6.  Evaluate each option against the nine design qualities.

    Note each option's impact — positive, neutral, negative — on each
    quality. Be specific: "improves performance" is not useful, whereas
    "removes the N+1 query, cutting p95 by ~40ms" is.

    - Completeness: does it cover all the functional acceptance criteria?
    - Correctness: can it hold valid, consistent state under the expected
      workload?
    - Performance: does it meet the non-functional targets?
    - Reliability: how does it handle and recover from failures?
    - Experience: how does it feel for the end user?
    - Habitability: how easily can the next developer read, maintain, and
      evolve it?
    - Cohesiveness: does it form a unified whole, or bolt on?
    - Changeability: how easily can it adapt to plausible future
      requirements?
    - Simplicity: does it minimize unnecessary complexity?

    Most options trade qualities against one another. Capture the trade
    explicitly.

7.  Recommend one option per decision point, with reasoning.

    State which option to pick and why it wins on the qualities ranked
    highest in step 3. Name the qualities being prioritized and those being
    sacrificed.

8.  Capture the decision.

    Write a decision record into the project's decision store — context,
    options considered, decision, consequences — using whatever template and
    lifecycle that store defines. For a small design, a paragraph in the
    change description or a comment on the issue may suffice.

    Descriptive design documentation, which says what the architecture *is*,
    is a different artifact from the record of *why*. Keep the rationale in
    the decision store and let the design documentation link to it, so there
    is one place to correct when the reasoning is revisited.

9.  Report the design and stop.

    Flag any soft edges that remain — ambiguous terms, unstated assumptions,
    contested trade-offs — so they can be stress-tested before decomposition.
    What consumes the design is the caller's concern.

## Rules

- You MUST NOT design against an unapproved specification.

  The specification is the design's contract. Until it is approved, its
  acceptance criteria can still change in review, and designing against a
  moving target wastes the work. This is the phase gate: if the
  specification is missing, draft, or still under review, stop and send the
  user back to approve or write one.

- You MUST discover artifact locations and conventions rather than assuming
  them.

  This skill runs across projects that keep requirements and decisions in
  different places, in different formats, under different tools. A path,
  file name, template, or lifecycle state that is right in one project is
  wrong in the next. Resolve each store first, then follow whatever
  conventions it documents for itself.

- You MUST produce the design and stop there.

  Decomposing it into steps and implementing it belong to the caller, so
  that the design can be argued with before anyone has built against it.

- You MUST always produce alternatives, and MUST record the rejected ones
  with the reason each lost.

  Even an obviously best choice gets stronger when its alternatives are
  written down. The "why not" often outlives the "why": future requirements
  may reopen a rejected option, and the prior reasoning saves re-evaluating
  it from scratch.

- You MUST evaluate against the qualities rather than personal preference.

  The nine qualities are universal; habit is not. When you reach for "I
  prefer X", restate it as which quality you are optimizing and why that
  quality matters here.

- You MUST stop and clarify when the specification omits a non-functional
  requirement the design turns on.

  Requirements around scalability, durability, security, and compliance
  often dictate the technology stack, the database, and the deployment
  topology, and are expensive to retrofit.

- You SHOULD cost the operational tail.

  Designs do not end at "shipped". Account for monitoring, alerting, on-call
  burden, backup and restore, schema migration, and dependency lifecycle.
  Cheap to build does not mean cheap to own.

- You SHOULD prefer the boring option when the qualities are close.

  Familiar technology, fewer moving parts, smaller blast radius. Novelty has
  a cost the design qualities do not fully capture.

- You SHOULD prefer deep modules to shallow ones.

  A module is deep when a small, simple interface hides a lot of useful
  behavior; it is shallow when its interface is nearly as complex as its
  implementation. Where two designs satisfy the same criteria, the one with
  deeper modules wins on simplicity, habitability, and changeability at
  once.

## Edge cases

- The design is forced by an existing constraint.

  If there is genuinely only one viable option — a regulation names the
  encryption standard, an existing contract fixes the API shape — state the
  constraint, name the option, and skip the alternatives. Verify the
  constraint is real first: "we've always done it that way" is not a
  constraint.

- The goal is a prototype or spike.

  If the question is whether something is feasible at all, skip the formal
  evaluation. Write the prototype, then come back and do the design for
  real, informed by the evidence it produced.

- A design choice is failing during implementation.

  Redo the design rather than patching around it. Sunk cost is not a
  quality.

- Two options are genuinely tied.

  Present both with their trade-offs and stop. The tie is the caller's to
  break, so do not flip a coin and proceed silently.

## Examples

- A compact decision capture:

  ```text
  Decision: use Postgres LISTEN/NOTIFY for job dispatch.

  Context:
  - Need to fan out ~50 jobs/sec from the API to workers.
  - p95 dispatch latency target: <200ms.
  - Team operates Postgres already; no Kafka or RabbitMQ in the stack.

  Dominant qualities: habitability, then simplicity, then performance.

  Options considered:

  1. Postgres LISTEN/NOTIFY (chosen)
     + No new infrastructure; reuses existing operational knowledge
       (habitability, simplicity).
     + Meets the latency target (~30ms p95 measured in a spike).
     - Caps at a few thousand jobs/sec; not future-proof past 10x growth.

  2. Redis Streams
     + Higher throughput ceiling.
     - New operational surface the on-call team is unfamiliar with.
     - Extra failure mode for a problem we do not have today.

  3. SQS
     + Managed, durable, scalable.
     - Adds cloud coupling; cross-region latency makes p95 marginal.
     - More expensive at our volume.

  Decision: option 1. Optimizes for habitability and simplicity while
  meeting the stated non-functional targets. Re-evaluate above a sustained
  2000 jobs/sec, where option 2 or 3 becomes worth its cost.

  Consequences:
  - Workers hold a long-lived Postgres connection, affecting pool sizing.
  - Migrating to a real queue is a known future cost; design the dispatch
    interface so that swap stays straightforward.
  ```
