# `specify`

Turn a vague request into a testable contract, filed in the project's SRS (software requirements specification) repository. Use `specify` before any design or coding work, to pin down *what* a change must do – as acceptance criteria a test could later prove pass or fail – and the constraints it must hold to.

## What it does

The skill works in two layers. *Where and how the proposal is filed* is owned by the SRS repository and read at runtime. *What makes the specification good* is the skill's own expertise.

It first **locates the SRS** – it reads the consuming project's root `AGENTS.md`, finds the `Workflow repositories` section, and resolves the `SRS` entry to the repository where requirements live. If no SRS is declared, it stops and says so rather than writing requirements into an arbitrary file.

It then **reads that SRS repository's own `AGENTS.md`** – never `CONTRIBUTING.md` – to learn the repository's current workflow – its proposal template, branch convention, lifecycle states, and pull-request, thread, and label rules. The skill follows whatever it finds there rather than hard-coding the process, so it stays correct as the specification repository evolves. It follows `AGENTS.md` rather than `CONTRIBUTING.md` so the agent workflow can differ from the human one.

With the destination and process established, it authors the proposal content. It:

- **Frames the need** – who it's for, what they want to achieve, and why it matters – asking the user rather than inventing answers.

- **Separates functional from non-functional requirements** and insists both are stated, since NFRs are architecturally significant and hard to retrofit.

- **Writes functional acceptance criteria in Gherkin** (`Feature` / `Scenario` / `Given`-`When`-`Then`), falling back to a structured bullet list for trivial requests.

- **Writes NFRs as measurable benchmarks** – a quantitative target, conformance to a published standard, or a security user story – rejecting vague phrasing like "must be fast".

- **Names what is out of scope** – deferred features, adjacent untouched functionality, decisions not being revisited.

- **Checks testability and readiness** – every criterion maps to an observable outcome, run against a Definition of Ready before completion.

Finally, it files the proposal following the SRS repository's process exactly.

It carries the rules that keep a specification honest: specify the problem not the solution, use domain language not codebase jargon, assert on observable outputs not internal state, and play *doctor, not waiter* – surface the underlying need rather than transcribe the literal request.

## How to invoke

Ask the agent to specify or scope a change – eg. "specify the refund feature", "write acceptance criteria for X", "turn this request into testable requirements", or "what's the spec for Y?". The skill triggers when a change needs pinning down before design or coding begins.

The project must declare its SRS location in its root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

## Examples

- **Scope a new feature:** "Specify the faulty-goods refund flow." → a proposal filed in the project's SRS repository, with `Given`-`When`-`Then` scenarios, an NFR section, and an explicit out-of-scope list.

- **Tighten a vague request:** "Make 'checkout should be fast' a real requirement." → a measurable NFR (eg. p95 checkout latency < 250ms at 500 RPS) replacing the hand-wave.

- **Specify a bug fix:** "Write the spec for issue #412." → a Gherkin scenario that fails today and should pass after the fix, with the reproduction as `Given`/`When`.

- **No SRS wired up:** "Specify the export feature." (project `AGENTS.md` has no `SRS` entry) → the skill reports that the project isn't wired to an SRS and writes nothing.
