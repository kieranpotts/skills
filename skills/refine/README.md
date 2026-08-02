# Refine

The **refine** skill is all about producing new business requirements in
response to acceptance testing feedback. It edits the
*specification*, not the code, in response to acceptance-testing feedback or to
use of the working software. The boundary is sharp: if the spec was right and the
code was wrong, that is a defect fix, not a refinement; refinement is for when
the acceptance criterion itself is wrong, missing, contradictory, or ambiguous.

It drafts the edit in the specification's own conventions (Gherkin scenarios,
measurable NFRs, explicit out-of-scope) shown before-and-after, records the
rationale and evidence, and traces the downstream impact on design, plan, code,
and tests. It is disciplined: one logical change per pass, never a silent rewrite
of a passed AC, never scope expansion in disguise. It changes no code — the
output is a specification edit plus a traced impact list, ready to flow into
**[specify](../specify/)**.

It is the companion to **[validate](../validate/)**, which supplies the
suggestions it acts on, and it is analogous to **[refactor](../refactor/)**, which
serves the equivalent role for the design.

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

**refine** closes the product feedback loop: **[validate](../validate/)** surfaces
where the specification diverged from the real need, **refine** edits the
specification, and the change flows back into **[specify](../specify/)**.

## Related skills

- **[validate](../validate/):** supplies the suggestions this skill acts on.

- **[specify](../specify/):** receives the specification edit this skill
  produces.

- **[refactor](../refactor/):** its structural analogue — refactor serves the
  design where this skill serves the specification.
