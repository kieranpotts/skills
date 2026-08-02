# Refine

The **refine** skill is all about producing new business requirements in
response to acceptance testing feedback.

The agent is instructed to edit the _specification_, not the code, in response
to acceptance-testing feedback or to real-world use of the working software.

The boundary is sharp: if the spec was right and the code was wrong, that is a
defect fix, not a refinement. Refinement is for when the acceptance criterion
itself is wrong, missing, contradictory, or ambiguous.

The agent drafts the edit in the specification's own conventions. It makes no
changes to code.

## Interactivity

This skill is interactive where stakeholders must resolve a disagreement.

## How to invoke

> Refine the spec based on this feedback.

> The acceptance criteria are wrong — fix the requirements.

> Update the specification to match what we learned.

## Recommended models

A mid-tier reasoning model is sufficient for this task. Escalate to a frontier
model for deeper misunderstandings of the requirements.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  validate["🤖<br/>validate"]:::agentic
  refine["🤖🧑<br/>refine"]:::anthropic
  specify["🤖<br/>specify"]:::agentic

  %% Main workflow sequence.
  validate --> refine
  refine --> specify

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- **[validate](../validate/)** is a companion skill that can be supply suggestions
  that this skill then acts on.

- **[specify](../specify/)** receives the specification edit this skill produces.

- **[refactor](../refactor/)** is the structural analogue to this skill.
