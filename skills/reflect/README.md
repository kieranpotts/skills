# 🧑 `reflect`

`reflect` = durable lesson capture. It distills *working-style* continuity — how to collaborate well with this user, in this codebase — as distinct from task state (which belongs in a handoff document). It scans the conversation for durable lessons (corrections, quietly-accepted non-obvious choices, revealed preferences, project decisions not in version control), filters ruthlessly (anything derivable from the code, any standard best practice, any one-off detail is dropped), and walks each surviving candidate past the user for approval before persisting it to memory or convention files.

Use it at the end of a session to make future sessions start smarter. With no argument it scans the whole conversation; expect a per-candidate walk-through, then a short report of what was saved. It says so plainly when a session contained nothing worth saving.

It is the companion to [`handoff`](../handoff/).

It is interactive — one candidate at a time, no batching, because batching invites blind approval (🧑).



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

- `/reflect`, `/skill:reflect` (prompts vary by harness).
- "Reflect on this session."
- "What should you remember from this?"
- "Save the lessons from our work today."

## Recommended models

Extracting durable lessons from a session is a synthesis task over a conversation the model already has in context. A mid-tier model is sufficient — the bar is faithful, well-organized extraction, not novel reasoning.
