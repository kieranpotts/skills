# Design principles

These are the design principles behind *this* collection of skills. They are deliberately stricter than the [generic best practices](./best-practices.md) for authoring agent skills, and they express the opinionated stance this repository takes. A skill in this collection MUST satisfy all of them.

The capitalized requirement keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in [IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Skills for judgement, scripts for automation

This collection covers the parts of the software development lifecycle that call for *judgement* – the work that cannot be reduced to a deterministic procedure. Specifying requirements, weighing design trade-offs, decomposing delivery, reviewing a change, deciding whether the right thing was built: each demands reasoning about an open-ended problem, the kind of work an agent is well suited to and a script is not. These are the phases where a capable model earns its keep.

The deterministic parts of the lifecycle are deliberately **out of scope**. Anything that can be specified once and then run the same way every time – building, deploying, running migrations, linting, packaging, tagging an artifact – is better expressed as a script, a CI job, or a Makefile target than as a skill. There is no `/deploy` skill, and there should not be: a deployment is a fixed sequence of commands, and wrapping it in a skill only adds an unpredictable interpreter in front of a procedure that should be exact and repeatable. The same goes for `/build`, `/lint`, and their kind.

The dividing line is whether the work needs *deciding* or merely *doing*. If the outcome depends on context, taste, or trade-offs that change case by case, it is a candidate for a skill. If the outcome is the same procedure every time, it belongs in a script, and the skills here are designed to sit alongside that automation – calling it, being called by it – rather than to replace it.

Note that *agentic* is not a synonym for *automated*. Automation is deterministic: the same inputs yield the same outputs, every time, by a fixed procedure. Agentic work is the opposite – a model reasons through an open-ended problem and may reach a different, better answer on a different run. Both reduce human toil, but they are different tools for different kinds of work: automation for the procedures that should never vary, agentic skills for the judgements that legitimately can.

(One nuance: a few skills in this collection codify a *convention* rather than a judgement – `/branch`, `/commit`, and `/release`, for instance, encode naming rules and formats. These earn their place because applying the convention still requires reading an open-ended change and choosing the right category – a judgement – even though validating the result is deterministic. The deterministic half (the validation regex) is exactly the part that is also expressed as a script or CI check.)

## Portability

A skill MUST be portable: it MUST NOT reference any out-of-band material – anything outside its own directory.

Everything a skill needs to run MUST live within `skills/<name>/`: the `SKILL.md` itself, and any bundled `assets/`, `references/`, or `scripts/`. A skill MUST NOT link to a file elsewhere in the repository (a root `docs/` page, a shared reference, the project `AGENTS.md`), nor to another skill's directory. If the skill needs a piece of reference material, it carries its own copy under its own `references/`.

This is what lets a single skill be lifted out and installed on its own, into any project, and still work. The moment a skill depends on a file outside its directory, that file does not travel with it, and the skill breaks on install.

When bundling resources, namespace them so they remain unique if the skill is later installed alongside others – see [collision safety](../skills/create-skill/references/create-skill-collision-safety.md). Installers for Copilot and Cursor flatten every skill's `assets/`, `references/`, and `scripts/` into one shared directory, so an un-namespaced file is a silent-overwrite bug.

## Independence

A skill MUST be independent: it MUST NOT cross-reference another skill.

No `SKILL.md` links to, names as a dependency, or assumes the presence of another skill in the collection. A skill is a complete, self-contained unit, with **no knowledge of any other skill**. This is what gives the user the freedom to **delete any skill they don't want** without breaking the ones they keep, and to install a single skill without dragging in the rest.

Independence and portability are two sides of the same rule: portability forbids reaching *outside the directory*; independence forbids reaching *into a sibling skill* specifically.

**Scope: independence is within this collection.** The rule forbids a skill from knowing about *other skills in this collection*. It does not forbid a skill from driving the skills that live in a *separate, external repository* it is designed to work with – for example, a workflow skill here that carries out the procedure defined by a target project's repository-local skills (see [*driving another repository's skills*](#driving-another-repositorys-skills-read-dont-invoke) below). Those are not siblings in this collection; naming and sequencing their procedures is the skill's legitimate job. The line is: no knowledge of a peer in *this* collection; orchestrating another project's skills across a repository boundary is allowed.

**Independence between skills is not isolation from everything.** A skill here is independent of its *sibling skills*, but it may be – and often is – *tightly coupled to external artifacts*: a repository structure, a file convention, a documented pattern it expects the target project to follow. For example, the `specify` skill knows nothing of any sibling skill, yet it is deliberately bound to an SRS repository that follows a specific pattern and exposes its own agent skills (scaffold, author, mark-ready) for `specify` to drive. That coupling is intentional and is what makes the skill *do* something useful in this ecosystem. The independence rule governs skill-to-*skill* relationships within the collection; it says nothing against a skill depending on an external contract, structure, or pattern. Reusability (above) is then a matter of how widely that external contract is shared – a skill bound to a common, well-documented pattern travels further than one bound to a bespoke one.

Beyond deletability, strict self-containment pays off in two further ways:

- **Maintainability.** A skill with no knowledge of any other can be read, changed, and reasoned about on its own. There are no ripple effects to trace: editing one skill cannot silently break another, because nothing depends on its internals or its presence. The blast radius of any change is a single directory.

- **Reusability across contexts.** A self-contained, single-responsibility skill drops cleanly into a different collection, a different workflow, or a different project, with no assumptions to satisfy first. The more a skill knows about its neighbours, the more tightly it is bound to *this* collection and *this* workflow — and the less reusable it becomes anywhere else. Independence keeps each skill a free-standing tool, useful wherever its one job is needed.

## No hand-offs between skills

A skill MUST NOT hand off to another skill. It does its one job, reports its outcome, and stops.

A skill MUST NOT instruct the agent to invoke another skill next, name "the next step" as a specific skill, or chain itself to a successor. Sequencing skills into a workflow is **not a skill's decision** – it belongs to whatever orchestrates the skills: a human, an orchestrating agent, or a pipeline script. The skill exposes a clean output and a clear stopping point; the orchestrator decides what, if anything, runs next.

This follows from independence. A hand-off is a cross-reference with a direction, and it couples the skill to a workflow it should not assume. The same skill might be the last step in one workflow and the middle of another; baking in "next, run X" forecloses that.

A skill MAY describe *what kind of input it expects* and *what its output represents* in neutral terms – that is its contract, and it does not name another skill. It MUST NOT say "then run `plan`"; it MAY say "the output is an approved specification, ready for whatever consumes it."

## Single responsibility, and the duplication it avoids

A skill MUST have a single responsibility: it does one job and stops at the boundary of that job, leaving adjacent work to the caller. (See [best practices](./best-practices.md#single-responsibility) for the general principle.)

The cleanest way to see a skill's single responsibility is to state it as the one question the skill answers. The evaluation skills make this especially sharp, because each **questions an assumption that an earlier step took for granted**. Earlier steps build on the outputs of the ones before – `/specify` produces the requirements, `/design` produces the architecture, `/code` builds against both – and each evaluation step exists to re-open one of those settled outputs:

- `/test` asks **"does it meet the agreed requirements?"** – the implementation against its acceptance criteria. It *trusts* the spec and the design, and questions only whether the code honours them. *Did we build it right?*
- `/audit` asks **"is the design sound?"** – the as-built architecture against the structure it was meant to have. It still trusts the spec, but now *questions the design* that `/test` took for granted. *Is it well-built?*
- `/validate` asks **"was this the right thing to build?"** – the working software against the users' actual need. It trusts nothing below it: it *questions the spec itself*, asking whether the agreed criteria were ever the right ones. *Did we build the right thing?*

Read in order, the questioning climbs back up the stack. `/test` trusts everything beneath it; `/audit` distrusts the design; `/validate` distrusts the requirements. Each step peels back one more layer that the previous step relied on – which is exactly why the two feedback loops point where they do: `/audit` → `/refactor` → `/design` re-opens the design, and `/validate` → `/refine` → `/specify` re-opens the spec. (`/review` sits earlier and narrower: it questions a single diff – is *this change* correct and well-made? – before it ever reaches `/test`.)

These are genuinely distinct jobs, and the point of single responsibility is that they stay distinct. A change can pass `/test` (meets every criterion) yet fail `/audit` (the design drifted) or `/validate` (the criteria themselves were wrong) – precisely because each interrogates a different layer of trust. Folding any two of them into one skill would blur questions that need separate answers, and separate, independently-runnable skills. The same discipline applies to the building skills: `/specify` captures *what* is required, `/design` decides *how*, `/plan` decides *in what order*, `/code` *builds one increment* – four questions, four skills, no skill answering two.

Single responsibility is what makes portability, independence, and no-hand-offs *achievable rather than painful*. When two skills find themselves needing the same shared content – the same checklist, the same format definition, the same convention – that is usually a signal that a responsibility has been drawn in the wrong place, not that the content should be shared between them.

Where shared content genuinely is unavoidable, **each skill carries its own copy**. Duplication is the accepted cost of independence and portability: a self-contained, deletable, individually-installable skill is worth more than a DRY one that cannot stand alone. But reach for duplication only after confirming the responsibility split is right – the better fix is almost always to draw the boundaries so the duplication is not needed in the first place.

This reverses the older "cross-reference instead of duplicate" guidance: a cross-reference breaks independence and portability, so it is not an acceptable way to avoid duplication here.

## Evaluate or enact, never both

A skill either **evaluates and reports**, or it **enacts a change** – never both in one skill. Judging whether something is wrong is a different responsibility from putting it right, and the two are split into separate skills.

This shows up across the collection as paired skills, one of each kind:

| Evaluates and reports | Enacts the change |
| --------------------- | ----------------- |
| `/review` – finds issues in a change | `/resolve` – actions the review comments |
| `/test` – verifies against the acceptance criteria | `/debug` – diagnoses and fixes a failure |
| `/audit` – evaluates the evolving architecture | `/refactor` – iterates the design in code |
| `/validate` – judges whether the right thing was built | `/refine` – revises the requirements specification |

The evaluating skill produces a report and stops. It changes nothing – no code, no specification, no files. Its output is a set of findings the orchestrator can act on, discard, or route to the matching enacting skill. The enacting skill takes findings as input and makes the change, leaving the *judgement* of whether the change is warranted to whoever decided to invoke it.

Keeping the two apart pays off several ways:

- **The judgement is reviewable before anything changes.** A human (or orchestrator) sees what `/review` or `/audit` found and decides what to act on, rather than discovering after the fact that a skill silently rewrote the code while "reviewing" it. Evaluation with side effects is hard to trust and hard to undo.

- **Each half is independently useful.** Evaluation is valuable on its own – a CI gate may run `/test` or `/audit` purely to report, with no intent to change anything. Enactment is valuable on its own – findings can come from a human, a tracker, or a prior run, not only from the paired evaluator.

- **It keeps each skill single-responsibility.** "Evaluate *and* fix" is two jobs; splitting them is just [single responsibility](#single-responsibility-and-the-duplication-it-avoids) applied to this specific seam. A skill that both judged and changed would be harder to reason about and impossible to use for evaluation alone.

This is a separation of responsibilities, not a hand-off: the evaluating skill does **not** name or invoke its enacting counterpart (that would break [independence](#independence) and the [no-hand-offs](#no-hand-offs-between-skills) rule). It reports neutrally and stops; the orchestrator – not the skill – decides whether to run the enactor next. The pairing is a fact of the *workflow*, documented here and shown in the repository's workflow diagram, not a link baked into either skill.

## Consequence for orchestration

Because skills neither reference nor hand off to one another, the *workflow* – the order in which skills run, the conditions under which one follows another, the human approval gates between phases – lives entirely outside the skills. It is the orchestrator's concern. A skill is a tool; the workflow is how the tools are wielded. Documenting a recommended workflow (for humans) is fine, and belongs in repository documentation – not inside any skill.

## Workflow skills run non-interactively

The main workflow skills in this collection – `specify`, `design`, `plan`, and their peers – are designed to run **non-interactively**, so they can be driven agentically without a human in the loop. A workflow skill takes everything it needs from its initial prompt, its surrounding context, and the environment (the repository, the project's `AGENTS.md`, the upstream artifact it consumes), does its job, and stops. It does not stop partway to ask the user a question.

The corollary is that **a workflow skill fails rather than prompts.** If it cannot obtain everything it needs from the prompt, the context, and the environment, it stops with a clear, specific account of what is missing – it does NOT fall back to interviewing the user to fill the gap. `specify` is the model: handed an incomplete PRD, it rejects it with an itemized list of what is absent, instead of asking the user to supply the missing rules. A clean failure is something an orchestrating agent can act on; a blocking prompt is not.

This is what makes these skills composable into an autonomous pipeline. An orchestrator – a human, an agent, or a script – can chain `specify` → `design` → `plan` and let them run to completion or fail loudly, with no interactive turn in between. The place where missing information is *gathered* is a separate, explicitly interactive skill upstream (requirement elicitation is `discover`'s job, not `specify`'s); the workflow skills downstream consume what those produce and never re-open the conversation.

(Declare this with `metadata.interactive: no` in the skill's front-matter. The default is `yes`; a workflow skill overrides it deliberately. The opposite case – a skill *built* to interview a human, such as `discover` – stays `interactive: yes`.)

## Driving another repository's skills: read, don't invoke

A workflow skill in this collection may drive a target repository's own skills – `specify` drives an SRS repository's `draft-spec` → `write-spec` → `propose-spec`, for instance. There are two ways it could do that, and only one of them is allowed here.

A global workflow skill MUST NOT literally *invoke* a target repository's local skills. It **reads their rules and instructions and executes that procedure itself**, in a non-interactive mode. The local skill is the authoritative *source of the procedure*; the workflow skill is the *engine that runs it* unattended.

This is a deliberate consequence of two facts about the local skills:

- **Local skills are interactive by design.** Every repository-level skill across the SRS, RFC, Design, and Plans repositories declares `metadata.interactive: yes`. They are written for a human operator at a keyboard: they prompt for a description, confirm a slug, ask which change type applies, and end by directing the user to the next skill in the lifecycle. Run literally, they would block on prompts the orchestrator cannot answer, and would tell the user to perform a step the orchestrator is itself about to perform.

- **A global workflow skill that consumes a PRD already holds the answers.** When `specify` drives the SRS workflow, the validated PRD supplies everything the interactive prompts would ask a human for. The skill does not need to *ask*; it needs to *apply*. So it reads what `draft-spec`/`write-spec`/`propose-spec` prescribe – the branch convention, the template, the acceptance-criteria format, the Definition of Ready, the lifecycle labels – and carries that procedure out directly, drawing every answer from the PRD instead of from a prompt.

Reading-not-invoking is also what keeps the *content rules in one place*. The target repository remains the single authoritative source for how its artifacts are written and how its proposals move through their states; the workflow skill never hard-codes a second copy of those rules from memory. It reads them fresh from the target repository each run (via that repository's `AGENTS.md` and the local skills it names), so a project that tunes its own `write-spec` automatically changes how `specify` behaves – without `specify` itself changing.

The division of labour, then:

- **Local repository-level skills** (`draft-spec`, `write-spec`, …) are `interactive: yes`. They are the human-operable, authoritative definition of each step, and the canonical home of the content and lifecycle rules.
- **Global workflow skills** (`specify`, …) are `interactive: no`. They consume an upstream artifact (a PRD), read the local skills' procedures, and execute them unattended – prompting for nothing, because the input already answers what the interactive path would ask.

## Presentation: skills as slash commands

A skill is presented as a slash command in documentation. Across this collection – and the wider ecosystem of repositories that expose their own agent skills – a skill name is written with a leading `/` inside backticks wherever it is presented *as an invocable command*:

- **Linked references**: `` [`/specify`](./skills/specify/) `` – the `/` goes inside the backticks; the link target (the path) is never prefixed.
- **H1 titles**: each `SKILL.md` and `README.md` opens with `` # `/specify` `` (not a prose title).
- **Bare command mentions**: "run `` `/discover` `` first".

The `/` is a presentation convention only. It is NOT added to the `name:` frontmatter field (the canonical identifier stays bare, e.g. `name: specify`), nor to file paths, code, branch names, commit types, lifecycle states, or to the word when it is used as an activity, phase, or noun rather than a command ("the discovery report", "after release"). Workflow-diagram node labels also stay bare.

## Related

- [Best practices](./best-practices.md): Generic, universal guidance for authoring any agent skill – single responsibility, when a skill is worth adding, interactive vs. non-interactive execution.

- [Creating skills](./creating-skills.md): The authoring path (`create-skill`) and the contributor mechanics for this repository.

- [Collision safety](../skills/create-skill/references/create-skill-collision-safety.md): Namespacing bundled resources so a portable skill survives installation alongside others.
