# Spike

The **spike** skill is all about developing throwaway code to answer design
questions.

Use this skill when a design question can't be answered by reasoning alone, or
when a specification is too speculative to commit to without evidence.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Do a spike on whether X is feasible.

> Prototype this to answer the open question.

## Recommended models

A mid-tier coding model is sufficient for this task. Reach for a frontier
reasoning model when the open question itself is subtle.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  design["🤖<br/>design"]:::agentic
  spike["🤖<br/>spike"]:::agentic

  %% Main workflow sequence.
  design ==> spike

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[design](../design/).** Companion skill that poses the questions a spike
  answers with throwaway code.
