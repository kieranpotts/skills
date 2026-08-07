---
name: elaborate
description: >-
  Refine a proposed solution by interrogating the design docs. Use after a
  draft design exists but before it is decomposed into implementation
  increments (via a delivery plan), and when that design has ambiguities,
  unstated assumptions, or contested terms. Also use when the user says
  something like "interrogate this design", "grill me on this draft", or
  "stress-test this design before we build it".
compatibility: requires Read, Grep, Write
license: CC0-1.0
---

# Elaborate

Interview the user, one question at a time, to stress-test and sharpen a draft
design. Walk the decision tree by branch, probing with concrete scenarios,
sharpening fuzzy language, cross-referencing against the codebase and
capturing crystallized decisions as architectural decision records.

Discovery only. You MUST NOT make any code or configuration changes to the
software itself.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the input requirements,
prompt the user for clarification.

- **A draft design with soft edges — REQUIRED.** An ADR, design doc, or PR
  description that has unresolved trade-offs, ambiguous terms, unstated
  assumptions, or dependencies not yet thought through. This skill does not
  originate the design; it consumes a draft to sharpen.

- **Related acceptance criteria and the relevant code — REQUIRED.** The
  acceptance criteria tied to the design, and the code it touches, so the
  draft can be cross-referenced against what already exists.

- **Where the glossary and the decision store live — REQUIRED.** The
  project's record of its ubiquitous language, and its record of settled
  decisions. Discover both rather than assuming them: check this session's
  context first, then the environment (a convention file such as
  `AGENTS.md`, a workspace manifest, an existing glossary or decision
  directory, a configured connector). If neither settles it, ask the user.
  Either MAY be a file in this repository, a separate repository, or an
  external service such as a wiki — do not assume a filesystem path, a file
  name, or a document structure. Where a project genuinely has neither,
  create them in the most conventional place for that project and say where
  you put them.

This skill is interactive. The agent prompts the user one question at a
time, waits for the answer, and then asks the next — including to establish
where the glossary and decision store live, when context and environment do
not settle it.

## Success criteria

- The design MUST be decomposition-ready: a reader MUST be able to pick it
  up and break it into steps without re-asking the questions this skill
  resolved.

- Every open decision in the draft MUST be resolved or deferred with a
  stated reason, and nothing MUST be left dangling in the "we'll figure
  that out later" pile without "later" being named.

- Terms used in the conversation MUST match the project's glossary: either
  they already did, or the glossary was updated inline as they were
  resolved.

- Contradictions between stated design and existing code MUST have been
  surfaced, not glossed over or assumed away.

- Decisions that meet the three-criteria filter MUST have become ADRs in the
  project's decision store; decisions that did not, did not.

## Instructions

1.  Load the context.

    Before asking anything, read the draft design, related acceptance
    criteria, the relevant code (modules touched, public APIs, tests), and
    any existing entries in the project's glossary and decision store that
    touch this area. If a question can be answered by reading the code
    instead of asking the user, read the code.

2.  Map the decision tree.

    List the open decisions in dependency order: which block others, which
    terms are loose, which assumptions have alternatives. Plan to walk the
    tree top-down. Keep the list as your scratchpad, and do not publish it
    for the user.

3.  Ask one question. Wait. Then the next.

    For each open node, state the question precisely, offer your
    recommended answer with one-line reasoning, and wait for the response. A
    good question is specific, scoped, and answerable in one sentence: "I
    see X in the draft. I read it as meaning A, but it could mean B. I'd
    lean A because [reason]. Which is it?"

4.  Sharpen fuzzy language as it appears.

    When the user uses a vague or overloaded term, stop and pin it down.
    If the glossary already defines the term differently, surface the
    conflict. Update the glossary (or create it) the moment a term
    is resolved — inline, not at the end.

5.  Probe with concrete scenarios.

    When the user makes a domain assertion, invent a scenario that tests
    its boundary and ask what happens. Concrete scenarios expose
    unaccounted cases faster than abstract debate.

6.  Cross-reference against the code.

    When the user states "we do X", check whether the code agrees. If you
    find a contradiction, surface it immediately and ask which side is
    right.

7.  Capture decisions as they crystallize.

    When a decision is settled, write it down immediately. Update the
    glossary for resolved terms. Write a decision record — into the project's
    decision store, in whatever form that store uses — only for decisions
    that are hard to reverse, surprising without context, and the result of a
    real trade-off.

8.  End the session when the tree is resolved.

    End when every open decision is resolved or explicitly deferred, terms
    match the glossary, and no contradictions remain. Report the sharpened
    design, or — if elaboration uncovered a flaw too large to resolve —
    report that the draft needs structural rework before it can proceed.

## Rules

- You MUST ask one question at a time, and MUST wait for the answer.

  Batched questions force the user to context-switch and produce shallow
  answers. The whole skill is the discipline of single-question turns.

- You MUST sharpen the design and stop there.

  Decomposing it into steps and implementing it are the caller's. This
  skill's product is a design someone else can now break up with no
  questions left to ask.

- You MUST always recommend an answer.

  A question with no recommendation pushes the cognitive load back onto
  the user. "I'd lean A because [reason]. Which is it?" lets the user agree
  quickly or articulate the disagreement.

- You SHOULD prefer reading code over asking.

  Asking is for things only the user knows: intent, trade-offs,
  constraints, future direction. "How does X work today" should be
  answered from the code.

- You MUST walk the tree parents-first.

  Resolving a child decision before its parent often forces a
  re-decision. Identify dependencies and ask in dependency order.

- You MUST sharpen language inline.

  A vague term left in the conversation infects every subsequent
  decision. Stop, pin it down, update the glossary, then
  proceed.

- You MUST surface code-versus-specification contradictions immediately.

  When stated design and implemented behavior disagree, that is the most
  valuable thing this skill can find. You MUST NOT gloss over it.

- You SHOULD offer ADRs sparingly.

  Most elaboration decisions do not need an ADR. Apply the
  three-criteria filter (hard to reverse, surprising without context, real
  trade-off). When in doubt, you SHOULD NOT.

- The glossary is a glossary, not a specification.

  You MUST keep implementation details out. An entry is what the term IS,
  in one or two sentences. Behavior, persistence, and protocols belong in
  code, ADRs, or the specification.

- You MUST discover the glossary and decision store; you MUST NOT assume
  them.

  This skill is used across projects that keep their language and their
  decisions in different places and formats. A path, file name, or document
  structure that is right in one project is wrong in the next. Resolve both
  first, then read and follow whatever conventions they carry.

- You SHOULD create artifacts lazily.

  No glossary yet? Create it when the first term is
  resolved, not at session start. No decision store? Create it when the first
  decision record is needed. Empty files signal nothing; lazily-created ones
  signal the design is being captured as it solidifies. When you do create
  one, put it where that project would conventionally expect it, and say
  where you put it.

- You MUST NOT publish the internal decision tree as a list for the user.

  The user sees questions one at a time, not your scratchpad.

## Edge cases

- The user is AFK.

  Do not push ahead silently. Pause, leave a one-line note ("queued
  questions: 1, 2, 3 — asking 1 when you're back"), and stop. The skill's
  value comes from the dialogue; producing a unilateral decision-doc
  defeats it.

- The draft turns out to be too unfinished to elaborate.

  If three or four questions in a row reveal that the design has not
  actually decided anything, stop and report that the draft needs to be
  reworked from scratch. Elaboration cannot rescue a draft that has no
  spine.

- A question reveals a missing AC.

  Stop, capture the gap, suggest the user revise the specification. Do
  not paper over it with a guess about what the requirement "probably"
  is.

- The user disagrees with the recommended answer.

  Good — that is the signal that the recommendation surfaced a real
  choice. Ask one follow-up to understand the reasoning, then move on. Do
  not relitigate.

- The session keeps spawning new questions faster than it resolves them.

  Likely a sign that the draft design is built on a shaky foundation.
  Pause, summarize the unresolved branch, and ask the user whether to
  keep elaborating or to send the draft back for a structural rethink.

- The project does not yet have a glossary.

  Create it when the first term is resolved, not at session start. Use
  the format shown in the examples. Do not pre-populate it with terms
  that have not actually been the subject of a question.

## Examples

- A single Q-and-A turn during elaboration:

  ```sh
  Agent: The draft says "cancellation revokes the order". I'm reading
  that two ways:

    (a) Sets `order.status = CANCELLED`, leaves line items intact
        (what the code currently does).
    (b) Marks the order canceled AND issues refunds for any items
        already paid for.

  I'd lean (b), because the specification mentions a refund flow and the existing
  `cancelOrder()` doesn't trigger refunds today — so this is a
  behavior change either way.

  Which is it?

  User: (b). And the refund should be partial if only some line items
  were paid.

  Agent: Got it. Updating the glossary with the new definition of
  "Cancellation". Then asking the next question.
  ```

- A captured glossary update, in this project's chosen location and format:

  ```md
  # Domain model

  The ubiquitous language for this project. Definitions here are
  authoritative — code, specs, and conversations should match.

  ## Language

  Order:
  A collection of line items submitted by a customer for fulfillment.
  _Avoid_: Purchase, transaction.

  Cancellation:
  The act of revoking an Order before it has been fully shipped. Triggers
  refunds for any line items already paid for; refunds are partial when
  only some line items were paid.
  _Avoid_: Void, abort.

  Customer:
  A person or organization that places Orders.
  _Avoid_: Client, buyer, account.
  ```
