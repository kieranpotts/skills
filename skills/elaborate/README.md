# Elaborate

The `elaborate` skill is all about **stress-testing a draft design**. It is a
highly interactive session with one objective: to nail down an architectural
design and mitigate the major risks within it.

For input it requires architectural design artifacts — anything in a textual
format (some models will also process images). The agent interrogates the
design, then interviews the user one question at a time on the rationale for the
design choices. Each question carries a recommended answer, so the user can agree
quickly or articulate a disagreement. The agent sharpens fuzzy terms, probes
assertions with concrete scenarios, and surfaces contradictions between the
stated design and what the code actually does.

It is a companion to [`design`](../design/), applied to a draft before it is
decomposed by [`plan`](../plan/).

This skill is interactive; it interviews the user one question at a time.

## How to invoke

> Interrogate this design.

> Grill me on this draft.

> Stress-test this design before we build it.

## Recommended models

Interrogating a draft design one question at a time, sharpening fuzzy language,
and cross-referencing the codebase is judgment-heavy, interactive work. Use a
frontier reasoning model — this is one of the few skills where the entire value
proposition is the model's ability to find the weak point in an argument.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  design["🤖\ndesign"]:::agentic
  elaborate["🤖🧑\nelaborate"]:::anthropic

  %% Main workflow sequence.
  design <-.-> elaborate

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

`elaborate` is a helper to [`design`](../design/): it takes the draft design,
interrogates it with the user, and returns a sharpened design ready to be
decomposed by [`plan`](../plan/).

## References

- Inspired by Matt Pocock's
  [`grill-me`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
  skill.

- The name of this skill is taken from the elaboration phase in the [Unified
  Process](https://www.amazon.co.uk/dp/0201571692). The goal of this phase is to
  establish and validate a proposed system architecture.
