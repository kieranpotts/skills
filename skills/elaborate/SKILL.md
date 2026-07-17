---
name: elaborate
description: >-
  Interview the user one question at a time to stress-test and sharpen a draft
  design — walking the decision tree branch by branch, probing with concrete
  scenarios, sharpening fuzzy language, cross- referencing against the codebase,
  and capturing crystallized decisions as ADRs. Use after a draft design exists
  and before it is decomposed into steps, when the design has ambiguities,
  unstated assumptions, or contested terms, or when the user says "interrogate
  this design", "grill me on this draft", or "stress-test this design before we
  build it".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/software-architect
---

# Elaborate

**Input:** A draft design with soft edges — an ADR, design doc, or PR
description that has unresolved trade-offs, ambiguous terms, unstated
assumptions, or dependencies not yet thought through, plus any related
acceptance criteria and the relevant code. REQUIRED. This skill does not
originate the design; it consumes a draft to sharpen.

This skill is interactive: it gathers the rest of its input from the user
through prompts during the session, asking one question at a time.

**Output:** A decomposition-ready design — every open decision resolved or
explicitly deferred, terms reconciled with the glossary
(`docs/domain-model.md`), code-versus-design contradictions surfaced, and
qualifying decisions captured as ADRs. Whatever decomposes or otherwise consumes
the sharpened design is the orchestrator's concern, not this skill's.

## Instructions

1.  **Load the context.**
    Before asking anything, you MUST read the draft design, related acceptance
    criteria, the relevant code (modules touched, public APIs, tests), and any
    existing `docs/domain-model.md` or `docs/adr/` decisions in the area. If a
    question can be answered by reading the code instead of asking the user, you
    SHOULD read the code.

2.  **Map the decision tree.**
    You SHOULD list the open decisions in dependency order: which block others,
    which terms are loose, which assumptions have alternatives. You SHOULD plan
    to walk the tree top-down. You MUST keep the list as your scratchpad, and
    MUST NOT publish it for the user.

3.  **Ask one question. Wait. Then the next.**
    For each open node, you MUST state the question precisely, offer your
    recommended answer with one-line reasoning, and wait for the response. A good
    question is specific, scoped, and answerable in one sentence: *"I see X in
    the draft. I read it as meaning A, but it could mean B. I'd lean A because
    [reason]. Which is it?"*

4.  **Sharpen fuzzy language as it appears.**
    When the user uses a vague or overloaded term, you MUST stop and pin it down.
    If the glossary already defines the term differently, you MUST surface the
    conflict. You MUST update `docs/domain-model.md` (or create it) the moment a
    term is resolved — inline, not at the end.

5.  **Probe with concrete scenarios.**
    When the user makes a domain assertion, you SHOULD invent a scenario that
    tests its boundary and ask what happens. Concrete scenarios expose
    unaccounted cases faster than abstract debate.

6.  **Cross-reference against the code.**
    When the user states "we do X", you MUST check whether the code agrees. If
    you find a contradiction, you MUST surface it immediately and ask which side
    is right.

7.  **Capture decisions as they crystallize.**
    When a decision is settled, you MUST write it down immediately. You MUST
    update `docs/domain-model.md` for resolved terms. You SHOULD create an ADR
    only for decisions that are hard to reverse, surprising without context, and
    the result of a real trade-off.

8.  **End the session when the tree is resolved.**
    You MUST end when every open decision is resolved or explicitly deferred,
    terms match the glossary, and no contradictions remain. You MUST report the
    sharpened design, or — if elaboration uncovered a flaw too large to resolve —
    report that the draft needs structural rework before it can proceed.

## Rules

- **You MUST ask one question at a time, and MUST wait for the answer.**
  Batched questions force the user to context-switch and produce shallow
  answers. The whole skill is the discipline of single-question turns.

- **You MUST always recommend an answer.**
  A question with no recommendation pushes the cognitive load back onto the
  user. "I'd lean A because <reason>. Which is it?" lets the user agree quickly
  or articulate the disagreement.

- **You SHOULD prefer reading code over asking.**
  Asking is for things only the user knows: intent, trade-offs, constraints,
  future direction. "How does X work today" should be answered from the code.

- **You MUST walk the tree parents-first.**
  Resolving a child decision before its parent often forces a re-decision.
  Identify dependencies and ask in dependency order.

- **You MUST sharpen language inline.**
  A vague term left in the conversation infects every subsequent decision.
  Stop, pin it down, update `docs/domain-model.md`, then proceed.

- **You MUST surface code-versus-specification contradictions immediately.**
  When stated design and implemented behavior disagree, that is the most
  valuable thing this skill can find. You MUST NOT gloss over it.

- **You SHOULD offer ADRs sparingly.**
  Most elaboration decisions do not need an ADR. Apply the three-criteria
  filter (hard to reverse, surprising without context, real trade-off). When
  in doubt, you SHOULD NOT.

- **`docs/domain-model.md` is a glossary, not a specification.**
  You MUST keep implementation details out. An entry is what the term IS, in
  one or two sentences. Behavior, persistence, and protocols belong in code,
  ADRs, or the specification.

- **You SHOULD create artifacts lazily.**
  No `docs/domain-model.md` yet? Create it when the first term is resolved,
  not at session start. No `docs/adr/`? Create it when the first ADR is
  needed. Empty files signal nothing; lazily-created ones signal the design is
  being captured as it solidifies.

- **You MUST NOT publish the internal decision tree as a list for the user.**
  The user sees questions one at a time, not your scratchpad.

## Examples

A single Q-and-A turn during elaboration:

```
Agent: The draft says "cancellation revokes the order". I'm reading
that two ways:

  (a) Sets `order.status = CANCELLED`, leaves line items intact
      (what the code currently does).
  (b) Marks the order cancelled AND issues refunds for any items
      already paid for.

I'd lean (b), because the specification mentions a refund flow and the existing
`cancelOrder()` doesn't trigger refunds today — so this is a
behavior change either way.

Which is it?

User: (b). And the refund should be partial if only some line items
were paid.

Agent: Got it. Updating docs/domain-model.md with the new definition of
"Cancellation". Then asking the next question.
```

A captured `docs/domain-model.md` update:

```md
# Domain model

The ubiquitous language for this project. Definitions here are
authoritative — code, specs, and conversations should match.

## Language

**Order:**
A collection of line items submitted by a customer for fulfillment.
_Avoid_: Purchase, transaction.

**Cancellation:**
The act of revoking an Order before it has been fully shipped. Triggers
refunds for any line items already paid for; refunds are partial when
only some line items were paid.
_Avoid_: Void, abort.

**Customer:**
A person or organization that places Orders.
_Avoid_: Client, buyer, account.
```

## Edge cases

- **The user is AFK.**
  Do not push ahead silently. Pause, leave a one-line note ("queued questions:
  1, 2, 3 — asking 1 when you're back"), and stop. The skill's value comes
  from the dialogue; producing a unilateral decision-doc defeats it.

- **The draft turns out to be too unfinished to elaborate.**
  If three or four questions in a row reveal that the design has not actually
  decided anything, stop and report that the draft needs to be reworked from
  scratch. Elaboration cannot rescue a draft that has no spine.

- **A question reveals a missing AC.**
  Stop, capture the gap, suggest the user revise the specification. Do not
  paper over it with a guess about what the requirement "probably" is.

- **The user disagrees with the recommended answer.**
  Good — that is the signal that the recommendation surfaced a real choice.
  Ask one follow-up to understand the reasoning, then move on. Do not
  relitigate.

- **The session keeps spawning new questions faster than it resolves them.**
  Likely a sign that the draft design is built on a shaky foundation. Pause,
  summarize the unresolved branch, and ask the user whether to keep
  elaborating or to send the draft back for a structural rethink.

- **The project does not yet have a `docs/domain-model.md`.**
  Create it when the first term is resolved, not at session start. Use the
  format shown in the examples. Do not pre-populate it with terms that have
  not actually been the subject of a question.

## Success criteria

- **Every open decision in the draft MUST be resolved or deferred with a stated
  reason.**

  Nothing left dangling in the "we'll figure that out later" pile without
  "later" being named.

- **Each question MUST have been asked one at a time, with a recommended answer.**
  No batched questions, no open-ended prompts without a lean.

- **Terms used in the conversation MUST match the glossary.**
  Either they already did, or `docs/domain-model.md` was updated inline as
  they were resolved.

- **Contradictions between stated design and existing code MUST have been surfaced.**
  Not glossed, not assumed away.

- **Decisions that meet the three-criteria filter MUST have become ADRs.**
  Decisions that did not, did not.

- **The output MUST be decomposition-ready.**
  A reader can pick up the design and break it into steps without re-asking
  the questions this skill resolved.
