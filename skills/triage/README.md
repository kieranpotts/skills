# 🤖 `triage`

`triage` = bug and incident verification. It takes a freshly-filed issue and
decides what happens next: implement, defer, reject, or get more information. It
moves issues through a state machine of category and state labels — gathering
context from the thread and code, reproducing bugs before anything else,
grilling under-specified issues into shape, and applying the outcome (an agent
brief, a needs-info request, or a durably-captured wontfix rationale).

Use it as the reactive entry point to the workflow, to work the incoming queue
or prep issues for agents, before the build loop sets about resolving the issue.
It assumes an issue tracker with category/state labels (and sets up the
vocabulary if missing).

It runs non-interactively but **recommends rather than decides**: triage is the
maintainer's call, so it does the legwork and waits for direction before
applying labels or closing. AI-generated comments are marked with a disclaimer
(🤖).

This skill instructs the agent to run non-interactively (🤖).

```mermaid
flowchart LR
  triage["🤖 /triage"]:::primary
  code["🤖 /code"]:::primary

  triage ==> code

  classDef primary fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
```

> **Note:** the description above reflects the skill's intended narrowed scope
(bugs and incidents only). The current `SKILL.md` additionally classifies
enhancements and routes issues through a label state machine. It will be brought
into line when the skill itself is updated.

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

- `/triage`, `/skill:triage` (prompts vary by harness).
- "Triage this issue."
- "Work the incoming issue queue."
- "Prep this issue for an agent."

## Recommended models

Classifying issues and moving them through a state machine is largely
rule-based, so a mid-tier model is sufficient for most of the workflow. A
frontier model helps when reproducing an ambiguous bug report or judging whether
an issue needs to be "grilled into shape" before it's ready for an agent.

## References

- [Original source — mattpocock/skills
  `triage`](https://github.com/mattpocock/skills/blob/main/skills/engineering/triage/SKILL.md):
  The skill this one is adapted from, including the agent-brief and out-of-scope
  conventions.
