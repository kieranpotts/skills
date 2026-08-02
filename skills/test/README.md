# Test

The **test** skill is all about checking the evolving software for both
functional correctness and runtime qualities.

The agent is instructed to verify the whole solution against the specification.
It runs the automated suite, and covers non-automatable ACs by hand with captured
evidence, and verifies NFRs against their stated thresholds.

The outcome is a verification report mapping every AC to a status, with evidence.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Test this against the spec.

> Verify this meets the acceptance criteria.

> Run acceptance testing on this change.

## Recommended models

A mid-tier model is sufficient for this task. Escalate to a frontier reasoning
model for non-functional acceptance criteria.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  build["⚙️<br/>build"]:::scripted
  test["🤖<br/>test"]:::agentic
  integrate["⚙️<br/>integrate"]:::scripted
  diagnose["🤖<br/>diagnose"]:::agentic

  %% Main workflow sequence.
  build ==> test
  test ==> integrate
  test <-.-> diagnose

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[validate](../validate/).** Asks whether the specification this skill
  verifies against was right in the first place.

- **[diagnose](../diagnose/).** Receives any bugs revealed in testing.
