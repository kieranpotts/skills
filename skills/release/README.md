# Release

The **release** skill encapsulates the rules for cutting release branches defined in
[TS-9: Version Control](https://github.com/kieranpotts/standards/tree/latest/dev/src/009).

The skill defines two mutually exclusive release strategies: a single
permanent `release` trunk , or `release/<version>` branches.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Cut a release.

> Tag version X.

> Prepare a release branch.

## Recommended models

A small, fast model is sufficient for this task.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  merge["🤖<br/>merge"]:::agentic
  release["🤖<br/>release"]:::agentic
  deploy["⚙️<br/>deploy"]:::scripted

  %% Main workflow sequence.
  merge ==> release
  release ==> deploy

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[branch](../branch/).** Defines the trunks that release branches are cut
  from.

- **[commit](../commit/).** Creates the revisions that a release is assembled
  from.

- **[merge](../merge/).** Integrates release branches back into the trunks.
