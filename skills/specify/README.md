# Specify

The **specify** skill is all about specifying functional and non-functional
requirements as testable acceptance criteria. It transforms a business-oriented
product requirements document
(PRD), or similar artifact, into executable acceptance criteria, and opens a pull
request against the project's software requirements specification (SRS)
repository, ready for the user to review.

Use it once business needs are recorded in a written artifact. That artifact may
come from a discovery workshop (**[discover](../discover/)**) or a refinement
(**[refine](../refine/)**) run in response to feedback from real people using
working software (**[validate](../validate/)**). Once a proposed specification is
approved, work can begin on the solution design — see **[design](../design/)**.
Accepting or rejecting proposed changes to the requirements specification is an
important decision left to sapiens, not agents.

This skill instructs the agent to run non-interactively. It validates the
inputted PRD and either rejects it as incomplete or autonomously completes the
transformation to the SRS, closing by returning the URL of the pull request that
needs the user's approval.

<!--
But skills alone can't guarantee predictable, consistent outcomes. Effective
agentic workflows are dependent upon concrete, unambiguous, testable success
criteria, and deterministic gates that independently verify agent output against
those criteria. These components of an agentic workflow are outside of the scope
of this skills repository.
-->

> [!IMPORTANT]
> This is a critical step in an agentic workflow.
>
> The outcome of the **specify** step is testable acceptance criteria, written in
> an executable form, covering both functional behaviors and non-functional
> runtime qualities. Those acceptance criteria become a stable contract that
> agents subsequently operate against. Later in the workflow, in the **test**
> phase, agents will validate their progress against the acceptance tests.
> Because the contract is executable, it means the agents can use deterministic
> tools — and not rely on judgment — to decide whether their work is done.
>
> The acceptance criteria act thus as a fitness function that the agent can
> iterate toward — a deterministic, stable signal of how close the current
> implementation is to the desired outcome. This is acceptance test-driven
> development (ATDD) applied to agentic workflows.
>
> The better the quality of the acceptance tests, the more effective they will
> be at driving agents to predictable, reliable outcomes, and so the less need
> there will be for humans-in-the-loop. In a fully end-to-end agentic workflow,
> humans need not read the generated code at all — in the same way we do not read
> a compiler's output — because the trust comes from the acceptance tests.
>
> We're now programming at a higher level of abstraction — our programming
> language is structured English, in the form of executable acceptance tests.

## Requirements

Agents following this skill will have the following expectations:

- The current project MUST have a file named `AGENTS.md` at the root. This file
  MUST have a section named "Workflow repositories" that specifies the location
  of the project's software requirements specification (SRS), which itself MUST
  be another repository on the local filesystem. Example:

  ```markdown
  ## Workflow repositories

  - SRS: ./docs/specs
  - RFC: ./docs/rfc
  - Design: ./docs/design
  - Plans: ./docs/plans
  ```

- The SRS repository MUST have its own root-level `AGENTS.md` file, which MUST
  specify the SRS's own workflow. This file MUST declare the availability of the
  following repository-level skills, which serve the following purposes:

  - `draft-spec`: Scaffolds the specification artifacts.
  - `write-spec`: Writes the requirements as verifiable acceptance criteria,
    based on the high-level requirements defined in the PRD.
  - `propose-spec`: Opens a pull request, ready for the user to review the new
    artifacts.

> [!NOTE]
> Agents are explicitly instructed to follow `AGENTS.md` rather than
> `CONTRIBUTING.md`. This provides the flexibility of specifying different
> workflows for agents and sapiens.

This **specify** skill instructs the agent to follow the guidelines in those named
sub-skills that are expected to be defined in the SRS repository. The sub-skills
are responsible for driving the software requirements workflow through to the
point of a new or updated software requirement being proposed via an open pull
request.

See the [**📋 Software Requirements Specification
(SRS)**](https://github.com/kieranpotts/specs) repository for a reference
implementation.

## How to invoke

> Turn this into acceptance criteria.

> Turn this into a spec.

> Prepare these as software requirements.

## Recommended models

Validating a PRD against the specification schema and rejecting incomplete input
is largely rule-based, so a mid-tier model handles it well. A frontier model
helps when judging whether examples are genuinely unambiguous, which is a
softer, more contestable call.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  discover["🤖🧑<br/>discover"]:::anthropic
  specify["🤖<br/>specify"]:::agentic
  design["🤖<br/>design"]:::agentic
  refine["🤖🧑<br/>refine"]:::anthropic

  %% Main workflow sequence.
  discover <-.-> specify
  specify ==> design

  %% Feedback loop.
  refine --> specify

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

**specify** turns a PRD from **[discover](../discover/)** into the acceptance
criteria that **[design](../design/)** builds against. Feedback from
**[refine](../refine/)** flows back in when the working software reveals the
specification itself needs to evolve.

## Related skills

- **[discover](../discover/):** supplies the PRD this skill transforms into
  acceptance criteria.

- **[design](../design/):** builds against the acceptance criteria this skill
  produces.

- **[refine](../refine/):** feeds edits back in when working software reveals
  the specification needs to evolve.

- **[validate](../validate/):** the ultimate source of the feedback that
  refine turns into a specification edit here.
