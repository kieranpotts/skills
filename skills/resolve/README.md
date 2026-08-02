# Resolve

The **resolve** skill is all about actioning open review comments, and marking
them as resolved.

The agent is instructed to takes the comments left on an open pull request,
to review each in turn, and respond with a comment and — where appropriate — a
code change.

It assumes the user has already curated the review, such that every comment still
open requires resolution. Comments that do not require a resolution are assumed
to be already closed and marked as resolved.

Any comment the agent cannot action is left open, with a comment explaining why
it was skipped.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Action the review comments.

> Address the feedback on this PR.

## Recommended models

A mid-tier coding model is sufficient for this task. Escalate to a frontier
model for ambiguous review comments.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  review["🤖<br/>review"]:::agentic
  resolve["🤖<br/>resolve"]:::agentic
  integrate["⚙️<br/>integrate"]:::scripted

  %% Main workflow sequence.
  review ==> resolve
  resolve ==> integrate

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[review](../review/)** leaves the comments this skill then actions.
