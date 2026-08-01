---
name: design
description: >-
  Explore architectural options and their trade-offs. Use when a code change
  involves architecturally significant decisions, or when the user says
  something like "design this feature", "what are the options for building
  this?", or "work out the architecture for this change".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-reasoning
---

# Design

Explore architectural options and trade-offs for a feature or other change in
requirements. Enumerate alternatives, evaluate them against nine software
design qualities — completeness, correctness, performance, reliability,
experience, habitability, cohesiveness, changeability, and simplicity — then
recommend one option with clear reasoning for why its trade-offs are optimally
balanced.

Architectural design only. You MUST NOT make any code or configuration changes
to the software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **An approved specification — REQUIRED.** Functional acceptance criteria
  and non-functional requirements, already reviewed and approved. This skill
  consumes that specification; it does not write it, and its entry gate
  refuses to begin until the approval is in place.

- **Where the specification and the decision store live — REQUIRED.**
  Discover both rather than assuming them: check this session's context
  first, then the environment (a convention file such as `AGENTS.md`, a
  workspace manifest, a configured connector). If neither settles it, ask
  the user. Either MAY be a directory in this repository, a separate
  repository, or an external service such as a tracker or wiki — do not
  assume a filesystem path, a file name, or a document structure. Different
  projects call the decision store an RFC archive, a decision log, or an ADR
  directory; they are the same role.

This task otherwise runs non-interactively to completion. You MUST NOT
prompt the user about the substance of the design; if in doubt about that,
stop and print an error message. You MAY prompt solely to establish where
the specification and decision store are, when context and environment do
not settle it.

## Success criteria

You will achieve the following outcomes:

- A recommended design — the chosen option with its evaluation against the
  nine qualities, the rejected alternatives and why, and the decision
  captured durably in the project's decision store.

- Where a design question could not be answered by reasoning alone, a
  time-boxed prototype produced the evidence that fed back into the
  evaluation.

- Nothing beyond the design was produced. Decomposition into steps and
  implementation were left to the caller.

- The entry gate MUST have been checked: the specification is approved.

  Design MUST proceed only against an approved specification.
  If the specification was unapproved or merely proposed, the skill MUST
  have stopped and sent the user to approve it first.

- The constraints MUST be written down.

  Functional ACs, NFRs, existing-system shape, and budget MUST be explicit
  before any option is enumerated.

- Each decision point MUST have 2-4 evaluated alternatives.

  No decision MUST be presented as the only option.

- Each option MUST have been evaluated against the nine qualities.

  Not every quality needs detailed treatment for every option, but the
  dominant qualities for the domain MUST be explicitly weighed.

- The recommendation MUST name which qualities it prioritizes.

  "We pick X because it optimizes for Y and Z, accepting weaker W."

- The decision MUST be captured durably.

  Written into the project's own decision store, in that store's own form —
  somewhere a future reader can find it without asking, and without a second
  copy of the rationale existing anywhere else.

- The stores MUST have been discovered, not assumed.

  The location and access method for both the specification and the decision
  store MUST trace to session context, to the environment, or to an answer
  from the user.

## Instructions

1.  Check the entry gate.

    Resolve the specification store (see Input), then confirm the relevant
    requirements are approved — whatever state that store uses to mean
    "agreed and ready to build". If they are still draft, still under review,
    or missing entirely, stop, tell the user the design phase is gated on an
    approved specification, and direct them to approve or write one first.

2.  Gather the constraints.

    Before exploring options, write down:

    - Functional ACs the design must satisfy (from the approved
      specification).

    - Non-functional requirements: performance targets, security/compliance,
      availability, scalability, data retention.

    - Existing system shape: relevant modules, public APIs, data stores,
      deployment topology.

    - Budget: time, complexity tolerance, team familiarity, operational
      headroom.

    If any constraint is unclear, ask the user before proceeding.

3.  Identify the decision points.

    List the architecturally significant choices the design must make — the
    ones that would be expensive to reverse later. Typical examples:

    - Module/service boundaries.
    - Synchronous vs asynchronous communication.
    - Data ownership and consistency model.
    - Persistence technology.
    - Public API shape.
    - Concurrency / parallelism model.

    Cosmetic or easily-reversed decisions (variable names, file layout) are
    not decision points — defer them.

4.  Enumerate alternatives per decision point.

    Produce at least two options for each decision point, including a
    do-nothing or simplest-possible alternative. A single option masquerading
    as "the design" is an assumption, not a design.

5.  Evaluate each option against the nine design qualities.

    For each option, note its impact (positive, neutral, negative) on each
    quality. Be specific — "improves performance" is not useful; "removes the
    N+1 query, cutting p95 by ~40ms" is.

    - Completeness: does it cover all the functional ACs?
    - Correctness: can it maintain valid, consistent state under the
      expected workload?
    - Performance: does it meet the NFR targets?
    - Reliability: how does it handle and recover from failures?
    - Experience: how does it feel for the end user?
    - Habitability: how easy is it for the next developer to read,
      maintain, and evolve?
    - Cohesiveness: does it form a unified whole, or bolt on?
    - Changeability: how easily can it adapt to plausible future
      requirements?
    - Simplicity: does it minimize unnecessary complexity?

    Most options will trade qualities against one another. Capture the
    trade explicitly.

6.  Recommend one, with reasoning.

    State which option to pick and why it wins on the qualities that matter
    most for this domain. Name the qualities being prioritized and the
    qualities being sacrificed. If two options are close, say so and ask the
    user to break the tie.

7.  Capture the decision.

    For architecturally-significant decisions, write a decision record into
    the project's decision store — context, options considered, decision,
    consequences — using whatever template and lifecycle that store defines.
    For smaller designs, a paragraph in the change description or a comment
    on the issue may suffice.

    Do not invent a parallel location for decisions. If the project already
    keeps an RFC archive, a decision log, or an ADR directory, that is where
    this goes. Descriptive design documentation — what the architecture *is*
    — is a different artifact from the record of *why*; keep the rationale in
    the decision store and let the design documentation link to it.

    Include enough that a developer six months from now can answer "why did
    we do it this way?" without re-running the exercise.

8.  Report the design and stop.

    Flag any soft edges that remain — ambiguous terms, unstated assumptions,
    contested trade-offs — so they can be stress-tested before decomposition.
    Report the design and stop; what consumes it is the orchestrator's
    concern.

## Rules

- You MUST NOT design against an unapproved specification.

  The specification is the design's contract. Until the user has approved it,
  its acceptance criteria can still change in review — designing against a
  moving target wastes the work. If the specification is unapproved, missing,
  or still under review, you MUST stop and send the user back to approve it
  (or to write one, clarifying the requirements first, if it does not yet
  exist). This is the SDLC phase gate.

- You MUST discover artifact locations and conventions; you MUST NOT assume
  them.

  This skill is used across projects that keep requirements and decisions in
  different places, in different formats, under different tools. A path, file
  name, template, or lifecycle state that is right in one project is wrong in
  the next. Resolve each store first, then read and follow whatever
  conventions it documents for itself.

- You MUST always produce alternatives.

  A design that considers only one option is not a design. Even an
  obviously-best choice gets stronger when its alternatives are written down
  and rejected for stated reasons.

- You MUST evaluate against the qualities, not against personal preference.

  The nine qualities are universal. Personal preference and habit are not.
  When you reach for "I prefer X", restate it as which quality you are
  optimizing and why it matters here.

- You MUST identify the qualities that dominate this domain.

  Not all qualities matter equally in every domain. A financial ledger
  weights correctness over experience; a marketing site weights experience
  over performance; a long-lived internal tool weights habitability over
  simplicity. You MUST name the priority ordering before evaluating options.

- You MUST surface NFRs early.

  NFRs around scalability, durability, security, and compliance often dictate
  the design (technology stack, database, deployment topology) and are
  expensive to retrofit. If the specification omitted them, you MUST stop and
  clarify before continuing.

- You MUST cost the operational tail.

  Designs do not end at "shipped". Account for monitoring, alerting, on-call
  burden, backup/restore, schema migration, dependency lifecycle. Cheap to
  build does not mean cheap to own.

- You SHOULD prefer the boring option when qualities are close.

  Familiar technology, fewer moving parts, smaller blast radius. Novelty
  has a cost the design qualities do not fully capture.

- You SHOULD prefer deep modules to shallow ones.

  A module is deep when a small, simple interface hides a lot of useful
  behavior — callers benefit from leverage. A module is shallow when its
  interface is nearly as complex as its implementation. When two designs
  satisfy the same ACs and NFRs, the one with deeper modules wins on
  simplicity, habitability, and changeability simultaneously.

- You MUST document the rejected options too.

  The "why not" is often more useful to future readers than the "why".
  Future requirements may reopen one of the rejected options — the prior
  reasoning saves a re-evaluation.

## Edge cases

- The design is forced by an existing constraint.

  If there is genuinely only one viable option (eg. a regulatory requirement
  names the encryption standard; an existing contract fixes the API shape),
  state the constraint, name the option, and skip the alternatives. But
  verify the constraint is real before skipping — "we've always done it
  that way" is not a constraint.

- Prototype or spike.

  If the goal is to learn whether something is feasible, skip the formal
  evaluation. Write the prototype, then come back and do the design for real,
  informed by what you learned.

- Mid-build pivot.

  If a design choice is failing under implementation, stop and redo the
  design — do not patch around it. Sunk cost is not a quality.

- Two options are genuinely tied.

  Say so. Present both with their trade-offs and ask the user to break the
  tie. Do not flip a coin and proceed silently.

## Examples

- A compact decision capture:

  ```sh
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

## References

None.
