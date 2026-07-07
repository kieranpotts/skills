# 🤖 `research`

`research` = external knowledge gathering. It looks *outward* to pull knowledge inward: a library, protocol, pattern, regulation, or prior-art approach the agent or project does not yet understand. It frames the topic as specific, falsifiable questions, checks inward sources first (codebase, `docs/`, ADRs, memory) so it doesn't spend a web search on something the repo already records, then gathers authoritative external sources — primary over secondary, recent over old. The outcome is a single cited report that leads with a direct answer, separates sourced fact from its own inference, and names where the findings should go.

Use it when a decision is blocked on missing knowledge. Give it the topic or question. Writing the findings into a design doc, ADR, or memory is a separate step the caller initiates.

It is discovery and synthesis only: it changes no code, docs, or skills. Where there's no web access, or the honest answer is "it depends", it says so rather than fabricating certainty. It runs non-interactively (🤖).

This skill instructs the agent to run non-interactively (🤖).

## How to invoke

- `/research`, `/skill:research` (prompts vary by harness).
- `/research does library X support streaming responses, and from which version?`
- "Research X." / "Look into X." / "Find out how X works."

## Recommended models

Research and synthesis over current external sources benefits from a frontier reasoning model with strong long-context handling — the value is in weighing conflicting sources and building a coherent, cited argument, not just retrieving facts. Extended thinking helps when the topic has genuine trade-offs to reconcile.
