# 🤖 `/research`

Gather external sources on a topic and produce a cited research report – on a library, protocol, pattern, regulation, or prior-art approach the agent or project does not yet understand. Discovery and synthesis only, no code or doc changes. Runs non-interactively (🤖). Use when a decision is blocked on missing knowledge.

## What it does

`/research` looks *outward* to pull knowledge inward. It frames the topic as specific, falsifiable questions, checks inward sources first (codebase, `docs/`, ADRs, memory) so it doesn't spend a web search on something the repo already records, then gathers authoritative external sources – primary over secondary, recent over old. The outcome is a single cited report that leads with a direct answer, separates sourced fact from its own inference, and names where the findings should go.

It is non-interactive and discovery-only: it changes no code, docs, or skills. Where there's no web access, or the honest answer is "it depends", it says so rather than fabricating certainty.

## How to invoke

Give it the topic or question. Writing the findings into a design doc, ADR, or memory is a separate step the caller initiates.

- `/research`, `/skill:research` (prompt varies by agent harness).
- `/research does library X support streaming responses, and from which version?`
- "Research X." / "Look into X." / "Find out how X works."
