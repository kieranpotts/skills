# Code

The **code** skill writes the code and the tests for one small, already-designed
step of work, and commits it as a single reviewable diff.

The agent is instructed to quote the step's scope, establish a fast test
feedback loop, then work red → green → refactor in single cycles — one test,
one implementation, repeat — writing unit tests and, where appropriate,
integration tests alongside the code. It reviews its own diff against the
quoted step before committing, and stops at the commit: it does not push,
open a review, or start the next step.

It is RECOMMENDED to run this repeatedly, in small increments, toward a larger
feature, refactor, or performance goal. Each pass yields one small, clean diff
for review.

## Interactivity

This skill instructs the agent to run non-interactively, so it is suitable for
away-from-keyboard and continuous integration workflows. The agent may prompt
only to establish where an artifact lives or how to reach it; it must never ask
about the substance of the work. If the step is ambiguous, too large, or still
needs designing, the agent stops and reports rather than guessing.

## How to invoke

> Implement step 3 of the plan.

> Code this up.

> Build this change, test-first.

## Recommended models

A mid-tier coding model is sufficient. The design decisions have already been
made upstream, so this task is disciplined execution — test-first cycles, style
matching, scope policing — rather than open-ended reasoning.

## Suggested workflows

Run this once per planned step. Running it against work that has not been
decomposed is the main anti-pattern: the skill will stop rather than design
the step for you.

```mermaid
flowchart LR
  %% Node labels and classes.
  plan["🤖<br/>plan"]:::agentic
  triage["🤖<br/>triage"]:::agentic
  code["🤖<br/>code"]:::agentic
  styleSkill["🤖<br/>style"]:::agentic

  %% Main workflow sequence.
  plan ==> code
  triage ==> code
  code ==> styleSkill

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- [**plan**](../plan/) \
  Decomposes a requirements specification into a pipeline of small changes.
  Each of those changes is one invocation of this skill.

- [**triage**](../triage/) \
  An alternative upstream trigger, producing small scoped fixes rather than
  planned steps.

- [**style**](../style/) \
  Normalizes code presentation after the edits are made.
