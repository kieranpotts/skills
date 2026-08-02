# Commit

The **commit** skill encapsulates the rules for creating revisions in Git defined in
[TS-9: Version Control](https://github.com/kieranpotts/standards/tree/latest/dev/src/009).

The skill defines a fixed subject-line format — `<type>: <description>` with an
optional ` - <flag>` suffix. The `<type>` is derived from an allowed list of
commit types, each with precise semantics.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Write a commit message for this.

> Is this commit message valid?

> Why did commit validation fail in CI?

## Recommended models

A small, fast model is sufficient for this task.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  branch["🤖<br/>branch"]:::agentic
  commit["🤖<br/>commit"]:::agentic
  merge["🤖<br/>merge"]:::agentic

  %% Main workflow sequence.
  branch ==> commit
  commit ==> merge

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[branch](../branch/)**
- **[merge](../merge/)**
- **[release](../release/)**

## References

- [This GitHub action](https://github.com/kieranpotts/actions/tree/dev/validate-commit-messages)
  is used to validate commit messages against the conventions described in TS-9
  and this skill.

- [These pre-commit hooks](https://github.com/kieranpotts/pre-commit-hooks)
  also validate commit messages against the same conventions.
