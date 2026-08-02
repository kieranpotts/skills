# Style

The **style** skill is all about improving code presentation — whitespace,
style, ordering — without changing structure. It makes
changes that are visually large but semantically empty: consistent whitespace,
ordering, line wrapping, quotes, trailing commas, import order, and so on.

The rules apply to all kinds of text content — not only code, but technical
documentation, requirements specifications, and more. Use it where conventional
linting tools are unavailable for the target format. Where **[proof](../proof/)**
corrects language, **style** normalizes presentation.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Format this file.

> Fix the formatting / lint errors.

> Tidy up the whitespace and style here.

## Recommended models

A small, fast model is sufficient for this task.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  code["🤖<br/>code"]:::agentic
  styleSkill["🤖<br/>style"]:::agentic
  lint["⚙️<br/>lint"]:::scripted

  %% Main workflow sequence.
  code ==> styleSkill
  styleSkill ==> lint

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

**style** runs immediately after **[code](../code/)** in the build-increments loop,
normalizing presentation before the scripted lint step checks it.

## Related skills

- **[code](../code/):** runs immediately before this skill in the
  build-increments loop.

- **[proof](../proof/):** corrects language where this skill normalizes
  presentation.
