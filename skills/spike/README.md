# 🤖 `/spike`

<!-- Interactive? Outcome is a PR against one or more code repositories. This feeds back into design docs - not sure when these change... or is the spike based on existing proposed designs??? - yes, "provisionally approved". -->

Develop throwaway code (or other artifacts) to answer design questions – feasibility, performance, API ergonomics, integration risk. Time-boxed, scope-collapsed, never promoted to production. Runs non-interactively (🤖). Use when a design question can't be answered by reasoning alone, or when a specification is too speculative to commit to without evidence.

```mermaid
flowchart LR
  design["🤖 /design"]:::primary
  spike["🤖 /spike"]:::tertiary

  design <-.-> spike

  classDef primary fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef tertiary fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## What it does

`/spike` treats the code as a byproduct and the *answer* as the deliverable. It frames one falsifiable question, defines up front the evidence that would close it, and sets an enforced time-box. Then it takes the shortest path – no tests, no error handling, no abstraction, hardcoded inputs – runs the experiment, and records findings reproducible from the notes alone. It documents the answer in the right artifact (ADR, design-doc update, spec revision, decision log) and throws the code away.

It is non-interactive. Negative answers are captured with the same care as positive ones, and the code is never promoted – the production version is re-implemented cleanly.

## How to invoke

Give it one falsifiable question. It states the closing evidence and time-box, runs the experiment, captures the finding, and disposes of the code.

- `/spike`, `/skill:spike` (prompt varies by agent harness).
- `/spike can Postgres LISTEN/NOTIFY sustain 5000 dispatches/sec at p95 < 50ms?`
- "Spike on whether X is feasible."
- "Prototype this to answer the open question."
