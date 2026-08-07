---
name: elaborate
description: >-
  Sharpen a draft design by interviewing the user one question at a time,
  pinning down loose terms, probing assumptions with concrete scenarios, and
  cross-referencing the draft against the code that already exists. Use after
  a draft design exists but before it is decomposed into implementation
  increments, when that design has ambiguities, unstated assumptions, or
  contested terms, or when the user says something like "interrogate this
  design", "grill me on this draft", or "stress-test this design before we
  build it". Do not use it to originate a design, to decompose one into
  increments, or to implement one.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep
license: CC0-1.0
---

# Elaborate

Interview the user, one question at a time, to stress-test and sharpen a draft
design: walk its open decisions in dependency order, sharpen fuzzy language,
probe assertions against the code, and capture each resolution as it lands.
This is discovery work — you MUST NOT change the software itself.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. This skill is interactive: where context and
environment leave a parameter unsettled, prompt the user for it, one question
at a time, and wait for the answer before asking the next.

- **A draft design with soft edges — REQUIRED.** A design document, decision
  record, or pull request description carrying unresolved trade-offs,
  ambiguous terms, unstated assumptions, or dependencies not yet thought
  through. This skill does not originate the design; it consumes a draft to
  sharpen.

- **The code the design touches — REQUIRED.** The modules, public interfaces,
  and tests the draft would change, so its claims can be checked against what
  is already implemented. Locate these from the draft's own references and by
  searching the workspace, rather than asking the user to list them.

- **The acceptance criteria the design answers to — OPTIONAL.** The
  requirements the design is meant to satisfy, wherever the project keeps
  them. Where none can be found, proceed without them and treat any
  requirement gap a question exposes as a finding to report.

- **The glossary — REQUIRED.** The project's record of its ubiquitous
  language. Discover it rather than assuming it: check this session's context
  first, then the environment (a convention file, a workspace manifest, an
  existing glossary, a configured connector), then ask the user.

- **The decision store — REQUIRED.** The project's record of settled
  decisions, discovered the same way. Projects variously call this an RFC
  archive, a decision log, or an ADR directory; they are the same role.

  Neither store's location is safe to assume. Either MAY be a file in this
  repository, a separate repository, or an external service such as a wiki,
  so do not assume a filesystem path, a file name, or a document structure.

## Success criteria

- The sharpened design MUST be decomposition-ready: a reader MUST be able to
  break it into implementation steps without re-asking the questions this
  session resolved.

- Every open decision the draft carried MUST have been resolved, or deferred
  with a stated reason and a named point at which it will be taken.

- Every term resolved during the session MUST appear in the glossary with the
  agreed definition, written there as it was settled rather than at the end.

- Every disagreement found between the draft and the implemented behavior
  MUST have been put to the user and settled one way or the other.

- Decision records MUST exist for exactly those decisions passing the
  three-criteria filter in the rules below — no more, no fewer.

- Application code, configuration, and tests MUST be unchanged. The only
  writes MUST be to the glossary, the decision store, and the draft itself.

## Instructions

1.  Load the context.

    Read the draft design, the acceptance criteria, the code it touches, and
    any glossary or decision-store entries covering this area. Anything the
    code can answer, answer from the code before the session starts.

2.  Map the decision tree.

    List the open decisions in dependency order: which block others, which
    terms are loose, which assumptions have alternatives. This list is your
    scratchpad for walking the tree top-down.

3.  Ask one question. Wait. Then the next.

    For each open node, state the question precisely, offer your recommended
    answer with one-line reasoning, and wait. A good question is specific,
    scoped, and answerable in one sentence: "I see X in the draft. I read it
    as meaning A, but it could mean B. I'd lean A because [reason]. Which is
    it?"

4.  Sharpen fuzzy language as it appears.

    When the user reaches for a vague or overloaded term, stop and pin it
    down. Where the glossary already defines that term differently, surface
    the conflict rather than quietly adopting either reading.

5.  Probe assertions with concrete scenarios.

    When the user makes a domain assertion, invent a scenario that tests its
    boundary and ask what happens. Concrete scenarios expose unaccounted
    cases faster than abstract debate does.

6.  Cross-reference claims against the code.

    When the user says "we do X", check whether the code agrees, and raise
    any disagreement in your next question. A gap between stated design and
    implemented behavior is the most valuable thing this skill finds, and it
    only stays valuable while it is still cheap to act on.

7.  Capture each resolution the moment it lands.

    Write resolved terms into the glossary and settled points back into the
    draft as you go. Write a decision record only where the three-criteria
    filter applies.

8.  End when the tree is resolved.

    Stop once every open decision is resolved or explicitly deferred, terms
    match the glossary, and no contradictions remain. Report the sharpened
    design — or, where elaboration uncovered a flaw too large to resolve,
    report that the draft needs structural rework before it can proceed.

## Rules

- You MUST ask one question at a time, and MUST wait for the answer.

  Batched questions force the user to context-switch and produce shallow
  answers. The whole skill is the discipline of single-question turns.

- You MUST always offer a recommended answer.

  A question with no recommendation pushes the cognitive load back onto the
  user. "I'd lean A because [reason]. Which is it?" lets the user agree
  quickly or articulate the disagreement.

- You SHOULD prefer reading the code over asking.

  Asking is for what only the user knows: intent, trade-offs, constraints,
  future direction. "How does X work today" is answered from the code.

- You MUST walk the tree parents-first.

  Resolving a child decision before its parent often forces a re-decision, so
  identify dependencies and ask in dependency order.

- You MUST capture resolutions inline rather than at the end of the session.

  A vague term left standing infects every decision that follows it, and a
  session that ends early loses everything not yet written down.

- You SHOULD write decision records sparingly, applying a three-criteria
  filter: hard to reverse, surprising without context, the result of a real
  trade-off. Where a decision fails any of the three, you SHOULD NOT record
  it separately — the sharpened draft already carries it.

- You MUST keep implementation detail out of the glossary.

  A glossary entry says what the term IS, in a sentence or two. Behavior,
  persistence, and protocols belong in the code, the decision store, or the
  requirements.

- You MUST discover the glossary and the decision store rather than assuming
  them.

  This skill runs across projects that keep their language and their
  decisions in different places and formats. A path or file name that is
  right in one project is wrong in the next. Resolve both, then follow
  whatever conventions each store documents for itself.

- You SHOULD create either store lazily.

  No glossary yet? Create it when the first term is resolved, not at session
  start. Empty artifacts signal nothing; lazily-created ones signal that the
  design is being captured as it solidifies. Put it where that project would
  conventionally expect it, and say where you put it.

- You MUST sharpen the design and stop there.

  Decomposing it into increments and implementing it are the caller's work.
  This skill's product is a design someone else can now break up with no
  questions left to ask.

- You MUST NOT publish the decision tree to the user as a list.

  The user sees questions one at a time, not your scratchpad.

## Edge cases

- The user is away from the keyboard.

  Do not push ahead silently. Pause, leave a one-line note ("queued
  questions: 1, 2, 3 — asking 1 when you're back"), and stop. The value comes
  from the dialogue; a unilateral decision document defeats it.

- The draft turns out to be too unfinished to elaborate.

  Where three or four questions in a row reveal that the design has not
  actually decided anything, stop and report that the draft needs reworking
  from scratch. Elaboration cannot rescue a draft with no spine.

- A question reveals a missing acceptance criterion.

  Stop, capture the gap, and suggest the user revise the requirements. Do not
  paper over it with a guess at what the requirement probably is.

- The user disagrees with your recommended answer.

  Good — that is the signal that the recommendation surfaced a real choice.
  Ask one follow-up to understand the reasoning, then move on. Do not
  relitigate.

- The session keeps spawning questions faster than it resolves them.

  Usually a sign that the draft rests on a shaky foundation. Pause,
  summarize the unresolved branch, and ask the user whether to keep
  elaborating or to send the draft back for a structural rethink.

## Examples

- A single question-and-answer turn during elaboration:

  ```text
  Agent: The draft says "cancellation revokes the order". I'm reading
  that two ways:

    (a) Sets `order.status = CANCELLED`, leaves line items intact
        (what the code currently does).
    (b) Marks the order canceled AND issues refunds for any items
        already paid for.

  I'd lean (b), because the requirements mention a refund flow and the
  existing `cancelOrder()` doesn't trigger refunds today — so this is a
  behavior change either way.

  Which is it?

  User: (b). And the refund should be partial if only some line items
  were paid.

  Agent: Got it — writing that definition of "Cancellation" into the
  glossary now, then asking the next question.
  ```

- A glossary updated inline, in whatever location and format the project's
  own glossary uses:

  ```md
  Order:
  A collection of line items submitted by a customer for fulfillment.
  _Avoid_: Purchase, transaction.

  Cancellation:
  The act of revoking an Order before it has been fully shipped. Triggers
  refunds for any line items already paid for; refunds are partial when
  only some line items were paid.
  _Avoid_: Void, abort.
  ```
