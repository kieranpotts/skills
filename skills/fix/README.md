# Fix

The **fix** skill is all about repairing something whose cause is already
known, and proving the repair worked.

The issue may have been raised by a tool (eg. a failing build) or a user.
The solution is already understood — the **[diagnose](../diagnose/)** skill
may be used for this purpose.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Fix the build.

> Fix the lint errors.

> Make the type-checker pass.

> Implement the fix to resolve this known bug.

## Recommended models

A mid-tier coding model is sufficient for mechanical fixes. A more capable
model may be beneficial if the fix changes a large surface area of code.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  build["⚙️<br/>build"]:::scripted
  diagnose["🤖<br/>diagnose"]:::agentic
  fix["🤖<br/>fix"]:::agentic

  %% Main workflow sequence.
  build -- fail --> diagnose
  diagnose ==> fix

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[diagnose](../diagnose/)** finds the underlying cause for an issue.
