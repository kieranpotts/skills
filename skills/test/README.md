# Test

The **test** skill is all about checking the evolving software for both
functional correctness and runtime qualities. It verifies the whole
solution against the specification — it does not write fresh tests for new
behavior (that's the implementation's job) or diagnose a failure (that's
separate).

It runs the automated suite, covers non-automatable ACs by hand with captured
evidence, and verifies NFRs against their stated thresholds (recording the
*measured number*, not just "ok"). The outcome is a verification report mapping
every AC to a status (PASS / FAIL / BLOCKED / N/A) with evidence, and an explicit
verdict.

Use it after a change has cleared review, or before tagging a release. It
verifies against the agreed specification — whether the specification was right
in the first place is **[validate](../validate/)**'s job. It classifies each
failure as an implementation defect or a specification defect and reports it
without fixing, handing genuine bugs to **[diagnose](../diagnose/)**.

It tests **against the specification, not the implementation**. It never
silently weakens an AC, downgrades a BLOCKED to PASS, or retries a flaky test
until green.

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

**test** runs the built solution against its acceptance criteria before it can
integrate; a failure hands off to **[diagnose](../diagnose/)**, and only a
clean pass proceeds.

## Related skills

- **[validate](../validate/):** asks whether the specification this skill
  verifies against was right in the first place.

- **[diagnose](../diagnose/):** receives the genuine bugs this skill's failures
  reveal.
