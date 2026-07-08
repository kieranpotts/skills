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

Use this skill *after* a draft design exists and *before* it is decomposed into
steps, when the design still has soft edges — unresolved trade-offs, ambiguous
terms, unstated assumptions, dependencies that haven't been thought through. The
job is to convert a sketch into a design that survives implementation; it
sharpens an existing draft, not originating the design itself.

This skill is an *interactive conversation*. Ask one question. Wait for the
answer. Then the next. Do not batch questions, do not draft entire plans before
checking in.

## Interface

**Input**: A draft design with soft edges — an ADR, design doc, or PR
description that has unresolved trade-offs, ambiguous terms, unstated
assumptions, or dependencies not yet thought through, plus any related
acceptance criteria and the relevant code. REQUIRED.

**Interactive**: This skill is interactive. It gathers the rest of its input
from the user through prompts during the session, asking one question at a time.
This skill does not originate the design; it consumes a draft to sharpen.

**Output**: A decomposition-ready design — every open decision resolved or
explicitly deferred, terms reconciled with the glossary
(`docs/domain-model.md`), code-versus-design contradictions surfaced, and
qualifying decisions captured as ADRs. Whatever decomposes or otherwise consumes
the sharpened design is the orchestrator's concern, not this skill's.

##  Instructions

1.  **Load the context.**

    Before asking anything, read:

    - The draft design (ADR, design doc, PR description, or whatever artifact
      holds it).
    - Any related acceptance criteria from the specification.
    - The relevant code: the modules the design touches, their public APIs,
      their tests.
    - Any existing `docs/domain-model.md` (the project's ubiquitous-language
      glossary) or `docs/adr/` decisions in the area.

    If a question can be answered by reading the code instead of asking the
    user, *read the code instead*. The user's time is the scarce resource.

2.  **Map the decision tree.**

    Skim the draft and list the open decisions in dependency order:

    - Which decisions block other decisions?
    - Which terms are used loosely and need pinning down?
    - Which assumptions are stated as if obvious but actually have alternatives?

    Plan to walk the tree top-down, resolving parents before children. Do not
    write the list out for the user — it is your scratchpad. The user sees
    questions one at a time.

3.  **Ask one question. Wait. Then the next.**

    For each open node:

    - State the question precisely.
    - Offer your recommended answer with one-line reasoning.
    - Stop and wait for the user's response.

    A good question has the form: *"I see X in the draft. I read it as meaning
    A, but it could mean B. I'd lean A because [reason]. Which is it?"*

    A bad question is open-ended ("what do you think about the data model?"),
    batched ("a few things: ...", "also, ..."), or context-free ("should we use
    Postgres?"). Sharpen until the question is specific, scoped, and answerable
    in one sentence.

4.  **Sharpen fuzzy language as it appears.**

    When the user uses a vague or overloaded term, stop and pin it down:

    - "You said 'account' — do you mean the Customer or the User? Those are
      different in the existing glossary."
    - "You said 'cancel' — the codebase has both `cancelOrder()` and
      `voidOrder()`; which behavior do you mean?"

    If the glossary already defines the term differently from how the user is
    using it, surface the conflict explicitly. Update `docs/domain-model.md` (or
    create it if missing) the moment a term is resolved — inline, not at the
    end.

5.  **Probe with concrete scenarios.**

    When the user makes a domain assertion, invent a specific scenario that
    tests its boundaries:

    - "Suppose a customer cancels an order after one of three items has shipped.
      What happens to the invoice?"
    - "Two clients send the same idempotency key, 30ms apart. What does each
      see?"

    Concrete scenarios expose the cases the design hasn't accounted for, much
    faster than abstract debate.

6.  **Cross-reference against the code.**

    When the user states "we do X", check whether the code agrees. If you find a
    contradiction, surface it:

    > "You just said partial cancellation is supported, but the
    `OrderService.cancel()` method takes only an order ID and marks the whole
    order cancelled. Which is right — is the code out of date, or is the design
    wrong?"

    Contradictions between stated behavior and implemented behavior are some of
    the highest-leverage findings of this skill.

7.  **Capture decisions as they crystallize.**

    When a decision is settled, write it down immediately. Two destinations:

    - *Glossary term resolved* → update `docs/domain-model.md`. Keep entries
      tight: what the term IS, one or two sentences, and any aliases to avoid.
      If the file does not yet exist, create it the moment the first term is
      resolved.

    - *Architectural decision settled* → ADR, but only if all three are true:

        1. *Hard to reverse* — the cost of changing your mind later is
           meaningful.
        2. *Surprising without context* — a future reader will wonder "why did
           they do it this way?"
        3. *The result of a real trade-off* — there were genuine alternatives.

        If any of the three is missing, skip the ADR. Most decisions during
        elaboration do NOT meet all three.

    Do not batch these. Write them down at the moment the decision is made.

8.  **End the session when the tree is resolved.**

    The session ends when:

    - Every open decision in the draft has been resolved or explicitly deferred
      (with a noted reason).
    - The terms in use match the glossary.
    - No contradictions remain between stated design and existing code.

    Report the result and stop: either a decomposition-ready design, or — if
    elaboration uncovered a flaw too large to resolve here — a note that the
    draft needs structural rework before it can proceed. Whatever consumes the
    elaborated design is the orchestrator's concern.

##  Rules

-   **One question at a time. Wait for the answer.**

    Batched questions force the user to context-switch and produce shallow
    answers. The whole skill is the discipline of single-question turns.

-   **Always recommend an answer.**

    A question with no recommendation pushes the cognitive load back onto the
    user. "Which is it?" alone is lazy. "I'd lean A because <reason>. Which is
    it?" lets the user agree quickly or articulate the disagreement.

-   **Prefer reading code over asking.**

    If the question is "how does X work today" or "what does Y currently
    return", read the code. Asking is for things only the user knows: intent,
    trade-offs, constraints, future direction.

-   **Walk the tree parents-first.**

    Resolving a child decision before its parent often forces a re-decision.
    Identify dependencies and ask in dependency order.

-   **Sharpen language inline.**

    A vague term left in the conversation infects every subsequent decision.
    Stop, pin it down, update `docs/domain-model.md`, then proceed.

-   **Surface code-versus-specification contradictions immediately.**

    When stated design and implemented behavior disagree, that is the most
    valuable thing this skill can find. Don't gloss over it.

-   **Offer ADRs sparingly.**

    Most elaboration decisions do not need an ADR. Apply the three-criteria
    filter (hard to reverse, surprising without context, real trade-off). When
    in doubt, don't.

-   **`docs/domain-model.md` is a glossary, not a specification.**

    Keep implementation details out. An entry is what the term IS, in one or two
    sentences. Behavior, persistence, and protocols belong in code, ADRs, or the
    specification.

-   **Create artifacts lazily.**

    No `docs/domain-model.md` yet? Create it when the first term is resolved,
    not at session start. No `docs/adr/`? Create it when the first ADR is
    needed. Empty files signal nothing; lazily-created ones signal the design is
    being captured as it solidifies.

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

Agent: Got it. That changes the cancellation contract. Two follow-ups
queued, I'll ask them next:
  - Does "partial refund" go back to the original payment instrument,
    or as store credit?
  - What's the user-visible flow when the cancel succeeds but the
    refund fails?

Updating docs/domain-model.md with the new definition of
"Cancellation". Then asking the next question.
```

A concrete-scenario probe:

```
Agent: The retry policy says "retry on 5xx with exponential backoff,
max 3 attempts". Suppose the third retry also fails. The draft doesn't
say what happens next.

I'd lean: surface the failure to the caller and emit a metric; do not
silently swallow. But this depends on whether the caller is a user-
facing endpoint (where surfacing is right) or a background job (where
dead-lettering might be better).

Which case are we designing for?
```

A code-versus-design contradiction:

```
Agent: You said "we charge the customer when the order is placed", but
PaymentService.charge() is only called from `ShipmentDispatched` -
which fires when the warehouse picks the order, not when it's placed.

Either the code is wrong, the description is wrong, or there's a
deliberate gap I'm missing. Which is it?
```

A captured `docs/domain-model.md` update:

```md
# Domain model

The ubiquitous language for this project. Definitions here are
authoritative — code, specs, and conversations should match.

## Language

**Order**:
A collection of line items submitted by a customer for fulfillment.
_Avoid_: Purchase, transaction.

**Cancellation**:
The act of revoking an Order before it has been fully shipped. Triggers
refunds for any line items already paid for; refunds are partial when
only some line items were paid.
_Avoid_: Void, abort.

**Customer**:
A person or organization that places Orders.
_Avoid_: Client, buyer, account.
```

An ADR captured at the moment a decision meets the three criteria:

```md
# 0007 — Cancellation triggers refund inline, not via async job

When an Order is cancelled, the cancellation handler issues the refund
synchronously and only marks the order CANCELLED if the refund
succeeds. We considered an async approach (mark cancelled immediately,
queue the refund) but rejected it: the failure mode "order cancelled,
refund stuck" is much worse for customer trust than "cancel button
spins for two extra seconds while the refund clears".

Consequences: cancellation latency is bounded by the payment provider's
response time. If that becomes a problem we revisit.
```

##  Edge cases

-   **The user is AFK.**

    Do not push ahead silently. Pause, leave a one-line note ("queued questions:
    1, 2, 3 — asking 1 when you're back"), and stop. The skill's value comes
    from the dialogue; producing a unilateral decision-doc defeats it.

-   **The draft turns out to be too unfinished to elaborate.**

    If three or four questions in a row reveal that the design has not actually
    decided anything, stop and report that the draft needs to be reworked from
    scratch. Elaboration cannot rescue a draft that has no spine.

-   **A question reveals a missing AC.**

    Stop, capture the gap, suggest the user revise the specification. Do not
    paper over it with a guess about what the requirement "probably" is.

-   **The user disagrees with the recommended answer.**

    Good — that is the signal that the recommendation surfaced a real choice.
    Ask one follow-up to understand the reasoning, then move on. Do not
    relitigate.

-   **The session keeps spawning new questions faster than it resolves them.**

    Likely a sign that the draft design is built on a shaky foundation. Pause,
    summarize the unresolved branch, and ask the user whether to keep
    elaborating or to send the draft back for a structural rethink.

-   **The project does not yet have a `docs/domain-model.md`.**

    Create it when the first term is resolved, not at session start. Use the
    format shown in the examples. Do not pre-populate it with terms that have
    not actually been the subject of a question.

##  Success criteria

-   **Every open decision in the draft is resolved or deferred with a stated
    reason.**

    Nothing left dangling in the "we'll figure that out later" pile without
    "later" being named.

-   **Each question was asked one at a time, with a recommended answer.**

    No batched questions, no open-ended prompts without a lean.

-   **Terms used in the conversation match the glossary.**

    Either they already did, or `docs/domain-model.md` was updated inline as
    they were resolved.

-   **Contradictions between stated design and existing code were surfaced.**

    Not glossed, not assumed away.

-   **Decisions that meet the three-criteria filter became ADRs.**

    Decisions that did not, did not.

-   **The output is decomposition-ready.**

    A reader can pick up the design and break it into steps without re-asking
    the questions this skill resolved.
