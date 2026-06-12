# `specify`

Turn a vague request into a testable contract. Use `specify` before any design or coding work, to pin down *what* a change must do – as acceptance criteria a test could later prove pass or fail – and the constraints it must hold to.

## What it does

Walks the agent through producing a specification, not a solution:

- **Frames the need** – who it's for, what they want to achieve, and why it matters – before any criteria are written, asking the user rather than inventing answers.

- **Separates functional from non-functional requirements** – what the system does, versus the runtime constraints (performance, security, availability, accessibility, compliance) it operates under – and insists both are stated, since NFRs are architecturally significant and hard to retrofit.

- **Writes functional acceptance criteria in Gherkin** (`Feature` / `Scenario` / `Given`-`When`-`Then`), with rules on scenario size, `Background`, and `Scenario Outline` – falling back to a structured bullet list for trivial requests.

- **Writes NFRs as measurable benchmarks** – a quantitative target, conformance to a published standard, or a security user story – rejecting vague phrasing like "must be fast".

- **Names what is out of scope** – deferred features, adjacent untouched functionality, decisions not being revisited – so the specification bounds the work, not just opens it.

- **Checks testability and readiness** – every criterion maps to an observable outcome, and the result is run against a Definition of Ready before it is declared complete.

It carries the rules that keep a specification honest: specify the problem not the solution, use domain language not codebase jargon, assert on observable outputs not internal state, and play *doctor, not waiter* – surface the underlying need rather than transcribe the literal request.

## How to invoke

Ask the agent to specify or scope a change – eg. *"specify the refund feature"*, *"write acceptance criteria for X"*, *"turn this request into testable requirements"*, or *"what's the spec for Y?"*. The skill triggers when a change needs pinning down before design or coding begins.

It is the natural next step after [`discover`](../discover/SKILL.md) (when requirements start out vague) and the entry point to [`design`](../design/SKILL.md).

## Examples

- **Scope a new feature:** *"Specify the faulty-goods refund flow."* → a `Feature` file with `Given`-`When`-`Then` scenarios, an NFR section, and an explicit out-of-scope list.

- **Tighten a vague request:** *"Make 'checkout should be fast' a real requirement."* → a measurable NFR (eg. *p95 checkout latency < 250ms at 500 RPS*) replacing the hand-wave.

- **Specify a bug fix:** *"Write the spec for issue #412."* → a Gherkin scenario that fails today and should pass after the fix, with the reproduction as `Given`/`When`.
