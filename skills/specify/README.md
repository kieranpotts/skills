# 🤖 `specify`

This skill instructs the agent to transform a business-oriented product requirements document (PRD), or similar artifacts, into testable acceptance criteria. The outcome is a PR opened against the project's software requirements specification (SRS) repository, ready for the user to review.

Use it once business needs are recorded in a written artifact. This artifact This artifact may come from a discovery workshop (`discover`) or a refinement workshop (`refine`) run in response to feedback from real people using working software (`validate`). If approved, its output PR enables the `design` skill to propose solutions to realize the requirements.

This skill instructs the agent to run non-interactively (🤖). The agent is instructed to validate the inputted PRD and either reject it as incomplete, or it autonomously completes the transformation to the SRS.







The `specify` skill closes by returning the URL to the pull request, telling the user the PR needs their approval.

Once a proposed specification is approved, work can begin on the solution design — see the [`design`](../design) skill. Accepting (or rejecting) the proposed changes to the requirements specification is an important decision left to sapiens — not agents.

> [!IMPORTANT]
> This is a critical step in an agentic workflow.
>
> The outcome of the `specify` step is testable acceptance criteria, written in an executable form, covering both functional behaviors and non-functional runtime qualities. Those acceptance criteria become a stable contract that agents subsequently operate against. Later in the workflow, in the `test` phase, agents will validate their progress against the acceptance tests. Because the contract is executable, it means the agents can use deterministic tools — and not rely on judgment — to decide whether their work is done.
>
> The acceptance criteria act thus as a fitness function that the agent can iterate toward — a deterministic, stable signal of how close the current implementation is to the desired outcome. This is acceptance test-driven development (ATDD) applied to agentic workflows.
>
> The better the quality of the acceptance tests, the more effective they will be at driving agents to predictable, reliable outcomes, and so the less need there will be for humans-in-the-loop. In a fully end-to-end agentic workflow, humans need not read the generated code at all — in the same way we do not read a compiler's output — because the trust comes from the acceptance tests.
>
> We're now programming at a higher level of abstraction — our programming language is structured English, in the form of executable acceptance tests.

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

## Requirements

Agents following this skill will have the following expectations:

- The current project MUST have a file named `AGENTS.md` at the root. This file MUST have a section named "Workflow repositories" that specifies the location of the project's software requirements specification (SRS), which itself MUST be another repository on the local filesystem. Example:

  ```markdown
  ## Workflow repositories

  - SRS: ./docs/specs
  - RFC: ./docs/rfc
  - Design: ./docs/design
  - Plans: ./docs/plans
  ```

- The SRS repository MUST have its own root-level `AGENTS.md` file, which MUST specify the SRS's own workflow. This file MUST declare the availability of the following repository-level skills, which serve the following purposes:

  - `draft-spec`: Scaffolds the specification artifacts.
  - `write-spec`: Writes the requirements as verifiable acceptance criteria, based on the high-level requirements defined in the PRD.
  - `propose-spec`: Opens a pull request, ready for the user to review the new artifacts.

> [!NOTE]
> Agents are explicitly instructed to follow `AGENTS.md` rather than `CONTRIBUTING.md`. This provides the flexibility of specifying different workflows for agents and sapiens.

This `specify` skill instructs the agent to follow the guidelines in those named sub-skills that are expected to be defined in the SRS repository. The sub-skills are responsible for driving the software requirements workflow through to the point of a new or updated software requirement being proposed via an open pull request.

See the [**📋 Software Requirements Specification (SRS)**](https://github.com/kieranpotts/specs) repository for a reference implementation.

## How to invoke

* `/specify`, `/skill:specify` (prompts vary by harness).
* `/specify <URL or path to PRD or equivalent>`
* "Turn this into acceptance criteria."
* "Turn this into a spec."
* "Prepare these as software requirements."

## Recommended models

Validating a PRD against the specification schema and rejecting incomplete input is largely rule-based, so a mid-tier model handles it well. A frontier model helps when judging whether examples are genuinely unambiguous, which is a softer, more contestable call.
