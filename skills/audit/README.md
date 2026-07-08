# Audit skill

The `audit` skill is all about **architectural review**. It evaluates the
as-built architecture for modularity, consistency, security, communication
patterns, and other structural qualities. The agent is instructed to conduct
the evaluation on its own terms, with no reference to the documented
architecture and no knowledge of trade-offs already considered.

That deliberate blindness is the point. It keeps the review unbiased so the
agent is more likely to surface genuinely useful suggestions. The trade-off
is a bit more noisiness. The agent may retread design trade-offs that have
already been settled.

This is an evaluation skill. It does not change any code. To do that, pass the
output of this skill as input to the [`refactor`](../refactor/) skill.

This skill is a companion to [`validate`](../validate/). Whereas `validate` asks
whether the *specification* should evolve, `audit` asks whether the *design*
should.

This skill instructs the agent to run non-interactively.

## How to invoke

- `/audit`, `/skill:audit` (prompts vary by harness).
- "Audit the architecture."
- "Is the design still sound?"
- "Check the codebase for structural drift."

## Recommended models

A frontier reasoning model is the right fit here. This skill's value comes from
independent, unbiased judgment about structural quality — shallow abstractions,
tangled dependencies, repeated patterns. That kind of holistic judgment really
benefits from deep reasoning.

A mid-tier model tends to default to generic, checklist-style observations,
rather than genuinely novel structural insight.

## Workflows

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


