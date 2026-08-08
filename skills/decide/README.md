# Decide

The decide skill frames a technical decision and writes it up as an RFC — a
proposal meant to be argued with before the decision is settled.

It covers decisions about architecture, process, technology, and tooling, and
any other technical decision that would be expensive to reverse. The agent is
instructed to sharpen the decision into a single disagreeable sentence, weigh
at least two genuine alternatives plus doing nothing, separate verified facts
from assumptions, and state both the downsides of its recommendation and the
conditions that would overturn it.

The output is a decision record written against the target store's own
template. The skill stops at authoring: it does not cut branches, open pull
requests, apply labels, or merge anything.

## Interactivity

This skill is interactive. The agent is instructed to interview the user —
about motivation, constraints, candidate options, and stakeholders — and to
ask where the decision store lives when the session context and the
environment do not settle it.

## How to invoke

> Write an RFC for this.

> Draft an RFC proposing we move to trunk-based development.

> We need to decide whether to adopt pnpm across the TypeScript services.

> Help me make the case for replacing the audit log.

## Recommended models

A frontier reasoning model, ideally with extended thinking enabled. The task
is open-ended analysis: it needs judgment about which alternatives are
genuine, which trade-offs dominate, and where a claim is being asserted
rather than established.

## Related skills

- [**research**](../research/) \
  Establishes the external facts a decision turns on, so they can be recorded
  as verified rather than assumed.

- [**spike**](../spike/) \
  Answers "will this actually work?" with throwaway code, settling assumptions
  that would otherwise land in the open questions.

- [**design**](../design/) \
  Supplies architectural trade-off analysis, whose conclusions this skill
  carries into the alternatives section.

- [**elaborate**](../elaborate/) \
  Interrogates a proposed design and surfaces the decisions embedded in it.
  Where one is too large to settle in that interview, it lands here.
