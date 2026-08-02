# Plan

The **plan** skill is all about decomposing delivery into small, stable
increments. It turns a big up-front design into a sequenced checklist of small
construction steps that can be built through an iterative loop, so supporting
continuous integration.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Break this design into steps.

> Plan the implementation.

> How should we sequence this work?

## Recommended models

A frontier reasoning model, ideally with extended thinking, is best suited to
this task.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  design["🤖<br/>design"]:::agentic
  plan["🤖<br/>plan"]:::agentic
  code["🤖<br/>code"]:::agentic

  %% Main workflow sequence.
  design ==> plan
  plan ==> code

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[design](../design/).** Supplies the proposed architectural changes that
  this skill decomposes into work tasks.

- **[code](../code/).** Picks up each step this skill produces, one at a time.
