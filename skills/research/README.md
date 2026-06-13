# 🤖 `/research`

Gather external sources on a topic and produce a cited research report – on a library, protocol, pattern, regulation, or prior-art approach the agent or project does not yet understand. Discovery and synthesis only, no code or doc changes. Runs non-interactively (🤖). Use when a decision is blocked on missing knowledge.

## What it does

`/research` looks *outward* to pull knowledge inward. It frames the topic as specific, falsifiable questions and notes the decision they unblock (which sets the depth and stopping point), checks inward sources first (codebase, `docs/`, ADRs, `AGENTS.md`/`CLAUDE.md`, memory) so it doesn't spend a web search on something the repo already records, then gathers authoritative external sources – primary sources over secondary, recent over old. Every decision-bearing claim is corroborated (two independent sources, or one primary) and dated where time-sensitive, with source disagreements surfaced rather than laundered. It synthesizes a report that leads with a direct answer, separates sourced fact from its own inference, and names where the findings should go.

It is non-interactive and discovery-only: it changes no code, docs, or skills, and stops when the framed question is answered to the confidence the decision needs. Where there's no web access, or the honest answer is "it depends", it says so rather than fabricating certainty.

## How to invoke

```
/research
/research does library X support streaming responses, and from which version?
```

Give it the topic or question. It produces a single cited report (answer, findings, open questions, suggested destination, sources) and stops – writing the findings into a design doc, ADR, or memory is a separate step the caller initiates.

## Examples

Asked whether a library supports streaming responses, `/research` checks the repo first, then reads the official docs and changelog, pins the answer to a version ("supported since v4.2"), corroborates it, and opens the report with a one-line actionable answer followed by dated, sourced findings.

When two sources disagree on a protocol detail, it presents both and its read of which is more credible, rather than collapsing them into one confident-but-wrong claim. With no search tool available, it answers as far as inward sources allow and marks that portion's confidence as reduced.
