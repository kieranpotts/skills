# 🤖 `code`

This skill implements changes in software code and configuration, following the test-driven development (TDD) methodology (red → green → refactor).

The outcome is one small change with accompanying unit tests, and integration tests where appropriate.

It is RECOMMENDED to execute this step in small increments toward delivery of a larger feature, refactor, performance enhancement, or other outcome. This will produce a small, clean diff for review.

This skill instructs the agent to run non-interactively (🤖).

```mermaid
flowchart LR
  %% Node labels and classes.
  discover["🤖🧑\ndiscover"]:::anthropic
  specify["🤖\nspecify"]:::agentic
  design["🤖\ndesign"]:::agentic
  triage["🤖\ntriage"]:::agentic
  plan["🤖\nplan"]:::agentic
  code["🤖\ncode"]:::agentic
  styleSkill["🤖\nstyle"]:::agentic
  lint["⚙️\nlint"]:::scripted
  review["🤖\nreview"]:::agentic
  resolve["🤖\nresolve"]:::agentic
  build["⚙️\nbuild"]:::scripted
  test["⚙️\ntest"]:::scripted
  integrate["⚙️\nintegrate"]:::scripted
  audit["🤖\naudit"]:::agentic
  validate["🤖\nvalidate"]:::agentic
  deploy["⚙️\ndeploy"]:::scripted

  conform["🤖\nconform"]:::agentic
  fix["🤖\nfix"]:::agentic
  debug["🤖\ndebug"]:::agentic

  spike["🤖🧑\nspike"]:::anthropic
  elaborate["🤖🧑\nelaborate"]:::anthropic
  refactor["🤖🧑\nrefactor"]:::anthropic
  refine["🤖🧑\nrefine"]:::anthropic

  %% Main workflow sequence.
  specify ==> design
  design ==> plan
  triage ==> code
  plan ==> code
  subgraph build_increments [build increments]
    direction LR
    code ==> styleSkill
    styleSkill ==> lint
    lint ==> build
    build ==> test
    test ==> review
    review ==> resolve
    resolve ==> integrate
    integrate ==> code

    %% Failures.
    lint -- fail --> conform
    build -- fail --> fix
    test -- fail --> debug
  end
  integrate ==> audit
  audit ==> validate
  validate ==> deploy

  %% Callouts to helpers.
  discover <-.-> specify
  design <-.-> spike
  design <-.-> elaborate

  %% Feedback loops.
  audit --> refactor
  refactor --> design
  validate --> refine
  refine --> specify

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3

  %% Subgraph (loop) border styling.
  style build_increments fill:#EEEEEE,stroke-width:0px
```

## How to invoke

- `/code`, `/skill:code` (prompts vary by harness).
- "Implement step 3 of the plan."
- "Code this up."
- "Build this change, test-first."

## Recommended models

Implementation of a single, already-scoped step benefits from a strong coding-tuned model, but the design decisions have already been made upstream, so a mid-tier coding model is usually enough. Reserve frontier reasoning models for steps with subtle algorithmic or concurrency complexity.
