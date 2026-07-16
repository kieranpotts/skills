# Research

The `research` skill is all about **external knowledge gathering**. It looks
*outward* to pull knowledge inward: a library, protocol, pattern, regulation, or
prior-art approach the agent or project does not yet understand.

It frames the topic as specific, falsifiable questions, checks inward sources
first (codebase, `docs/`, ADRs, memory) so it doesn't spend a web search on
something the repo already records, then gathers authoritative external sources —
primary over secondary, recent over old. The outcome is a single cited report
that leads with a direct answer, separates sourced fact from its own inference,
and names where the findings should go.

Use it when a decision is blocked on missing knowledge — often ahead of a
[`design`](../design/) decision or a [`spike`](../spike/). Give it the topic or
question; writing the findings into a design doc, ADR, or memory is a separate
step the caller initiates.

This skill instructs the agent to run non-interactively; it is discovery and
synthesis only, and changes no code, docs, or skills. Where there's no web
access, or the honest answer is "it depends", it says so rather than fabricating
certainty.

## How to invoke

> Research does library X support streaming responses, and from which version?

> Look into X.

> Find out how X works.

## Recommended models

Research and synthesis over current external sources benefits from a frontier
reasoning model with strong long-context handling — the value is in weighing
conflicting sources and building a coherent, cited argument, not just retrieving
facts. Extended thinking helps when the topic has genuine trade-offs to
reconcile.
