# `specify`

Turn a **PRD** into a testable specification, filed in the project's SRS (software requirements specification) repository. `specify` takes the product-requirements document – in practice the discovery report from [`discover`](../discover/SKILL.md) – validates that it is complete, and either rejects it with reasons or translates it into acceptance criteria a test could later prove pass or fail.

`specify` is **non-interactive**. It does not interview the user or gather missing requirements – that is [`discover`](../discover/SKILL.md)'s role. Its job is to validate a PRD and act on it.

## What it does

The skill works in two layers. *Where and how the proposal is filed* is owned by the SRS repository and read at runtime. *What makes the specification good* is the skill's own expertise.

It first **reads the PRD** – supplied as a file path, pasted text, or the discovery report from a preceding `discover` run – then **validates it for completeness**. A PRD is ready only if it supplies the user/goal/value, the business rules, an example *and* counter-example for each rule, an explicit out-of-scope boundary, measurable NFRs (or an explicit "none"), and resolution of any open question that blocks a criterion. If the PRD falls short, the skill **rejects it** with an itemized list of what's missing, directs the user to [`discover`](../discover/SKILL.md), and writes nothing. (Purely mechanical gaps – a missing `Feature` title, scenario ordering – it normalizes without rejecting.)

If the PRD passes, it **locates the SRS** – reading the project's root `AGENTS.md`, finding the `Workflow repositories` section, and resolving the `SRS` entry to the repository where requirements live. If no SRS is declared, it stops and says so rather than writing into an arbitrary file.

It then **reads that SRS repository's own `AGENTS.md`** – never `CONTRIBUTING.md` – to learn the repository's current workflow: its proposal template, branch convention, lifecycle states, and pull-request, thread, and label rules. The skill follows whatever it finds there rather than hard-coding the process, so it stays correct as the specification repository evolves. It follows `AGENTS.md` rather than `CONTRIBUTING.md` so the agent workflow can differ from the human one.

With the PRD validated, the destination found, and the process learned, it translates the PRD into the proposal content. It:

- **Carries the need** – who it's for, what they want to achieve, and why it matters – from the PRD's outcome and stakeholders.

- **Separates functional from non-functional requirements** and insists both are present, since NFRs are architecturally significant and hard to retrofit.

- **Writes functional acceptance criteria in Gherkin** (`Feature` / `Scenario` / `Given`-`When`-`Then`), falling back to a structured bullet list for trivial requirements.

- **Writes NFRs as measurable benchmarks** – a quantitative target, conformance to a published standard, or a security user story – rejecting the PRD if a non-functional need can't be made measurable.

- **Carries the out-of-scope boundary** – deferred features, adjacent untouched functionality, decisions not being revisited – forward from the PRD.

- **Checks testability and readiness** – every criterion maps to an observable outcome, run against a Definition of Ready before completion.

Finally, it files the proposal following the SRS repository's process exactly.

It carries the rules that keep a specification honest: specify the problem not the solution, use domain language not codebase jargon, and assert on observable outputs not internal state. Where the PRD is internally incoherent or its solution won't meet its own goal, that's a rejection, not something the skill quietly fixes.

## How to invoke

Give the agent a PRD and ask it to specify – eg. "specify this PRD", "turn this discovery report into a spec", "validate and file these requirements", or run it straight after [`discover`](../discover/SKILL.md) to hand off the report. The skill triggers when a PRD is ready to become a specification. If the requirements are still vague, run [`discover`](../discover/SKILL.md) first – `specify` will reject an incomplete PRD rather than interview you.

The project must declare its SRS location in its root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

## Examples

- **Specify a complete PRD:** "Specify this discovery report." (report has rules, examples, counter-examples, scope, NFRs) → a proposal filed in the project's SRS repository, with `Given`-`When`-`Then` scenarios, an NFR section, and the out-of-scope list carried forward.

- **Reject an incomplete PRD:** "Specify this." (report has rules but no counter-examples and an empty out-of-scope list) → an itemized rejection naming the gaps, directing the user back to [`discover`](../discover/SKILL.md). Nothing is written to the SRS.

- **Hand off from discover:** run `specify` immediately after a `discover` session → the in-session discovery report is validated and, if complete, translated and filed in one step.

- **No SRS wired up:** "Specify this PRD." (project `AGENTS.md` has no `SRS` entry) → the skill reports that the project isn't wired to an SRS and writes nothing.
