# Research

The **research** skill is all about gathering external sources on a topic and
producing a cited research report. It looks
*outward* to pull knowledge inward: a library, protocol, pattern, regulation, or
prior-art approach the agent or project does not yet understand.

It frames the topic as specific, falsifiable questions, checks inward sources
first (codebase, `docs/`, ADRs, memory) so it doesn't spend a web search on
something the repo already records, then gathers authoritative external sources —
primary over secondary, recent over old. The outcome is a single cited report
that leads with a direct answer, separates sourced fact from its own inference,
and names where the findings should go.

Use it when a decision is blocked on missing knowledge — often ahead of a
**[design](../design/)** decision or a **[spike](../spike/)**. Give it the topic or
question; writing the findings into a design doc, ADR, or memory is a separate
step the caller initiates.

It is discovery and synthesis only, and changes no code, docs, or skills. Where
there's no web access, or the honest answer is "it depends", it says so rather
than fabricating certainty.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Research X.

> Look into X.

> Find out how X works.

## Recommended models

A frontier reasoning model with strong long-context handling is best suited to
this task.

## Related skills

- **[design](../design/):** a design decision is often blocked on the
  knowledge this skill gathers.

- **[spike](../spike/):** its companion for questions reasoning alone can't
  answer — this skill looks outward for existing knowledge, spike runs an
  experiment.
