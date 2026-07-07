# 🧑 `refine`

`refine` = specification revision. It edits the *specification*, not the code, in response to acceptance testing feedback or to use of the working software. The boundary is sharp: if the spec was right and the code was wrong, this is a defect fix, not a refinement; refinement is for when the acceptance criterion itself is wrong, missing, contradictory, or ambiguous. It drafts the edit in the specification's own conventions (Gherkin scenarios, measurable NFRs, explicit out-of-scope) shown before-and-after, records the rationale and evidence, and traces the downstream impact on design, plan, code, and tests.

Use it when testing surfaces a specification gap, a stakeholder reports an unmet need against shipped behavior, or an NFR threshold turns out to be wrong in practice. It is disciplined: one logical change per pass, never a silent rewrite of a passed AC, never scope expansion in disguise. It changes no code — the output is a specification edit plus a traced impact list, ready to flow into `specify`.

It is the companion to [`validate`](../validate/), which supplies the suggestions it acts on. It is analogous to [`refactor`](../refactor/), which serves the equivalent role for the design.

It is interactive (🧑) where stakeholders must resolve a disagreement.

```mermaid
flowchart LR
  validate["🤖 /validate"]:::primary
  refine["🧑 /refine"]:::secondary
  specify["🤖 /specify"]:::primary

  validate --> refine
  refine --> specify

  classDef primary fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef secondary fill:#d4edda,stroke:#155724,color:#155724,stroke-width:2px,stroke-dasharray:7 3
```

## How to invoke

- `/refine`, `/skill:refine` (prompts vary by harness).
- "Refine the spec based on this feedback."
- "The acceptance criteria are wrong — fix the requirements."
- "Update the specification to match what we learned."

## Recommended models

Revising a specification from acceptance-testing feedback requires understanding what was learned and why it invalidates existing acceptance criteria. A mid-tier reasoning model is generally sufficient; escalate to frontier when the feedback reveals a deeper misunderstanding of the requirements rather than a simple gap.
