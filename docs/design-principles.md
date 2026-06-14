# Design principles

These are the design principles behind *this* collection of skills. They are deliberately stricter than the [generic best practices](./best-practices.md) for authoring agent skills, and they express the opinionated stance this repository takes. A skill in this collection MUST satisfy all of them.

The capitalized requirement keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in [IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## 🌐 Cohesive ecosystem

This is not a grab-bag of isolated skills. It's a cohesive collection that forms a complete end-to-end development workflow.

These skills are highly opinionated. They encode the author's [software development playbook](https://github.com/kieranpotts/playbook) and [technical standards](https://github.com/kieranpotts/standards), and they form part of a larger ecosystem of methods, tools, and artifacts for managing change in software at scale.

Specifically, these skills depend on the existence of version-controlled systems for managing software requirements, technical decisions, design documentation, and implementation plans. The following are reference implementations of these dependencies:

- [**📋 Software Requirements Specification (SRS)**](https://github.com/kieranpotts/specs): Captures what the system does, in business terms.

- [**💬 Requests for Comments (RFC)**](https://github.com/kieranpotts/rfc): Records how significant technical decisions were made, and why.

- [**📐 Design Docs**](https://github.com/kieranpotts/design): Documents what the system looks like in production, and manages proposed architectural changes.

- [**🗺️ Implementation Plans**](https://github.com/kieranpotts/plans): Tracks when, and in what order, the work gets done.

These skills are optimized for the development of application software that spans multiple code repositories – and potentially multiple teams – where requirements, decisions, designs, and plans are shared concerns that sit above any single codebase.

Since these skills are intended to be used globally across multiple code repositories, it is RECOMMENDED to install these skills in the user's home directory, or in a workspace root, rather than installing in individual code repositories. The bundled installer supports per-project installs, but this is not the intended use case for these skills.

For a standalone code repository – a small utility library, say – it is RECOMMENDED instead to encapsulate agent skills and supporting artifacts directly in that repository. These skills do not serve this use case.

## Predictable outcomes from any model

The overriding goal of this project is to produce **predictable, consistent, reliable outcomes from every mainstream model**. The same skill, run by different agents or on different days, should converge on the same shape of result. A skill that works beautifully on one frontier model and falls apart on another has failed this goal, however clever it is.

That goal sets up a chain of consequences that explains much of what follows:

- **Predictable outcomes require verifiable success criteria.** A model cannot reliably hit a target it cannot check itself against. So every skill gives the agent clear, *self-verifiable* criteria for what "done" and "correct" look like – concrete enough that the agent can evaluate its own work and know whether it succeeded, rather than guessing and hoping. Vague guidance ("write a good spec") produces model-dependent results; checkable criteria ("every acceptance criterion is in Gherkin, every NFR has a measurable threshold") produce convergent ones.

- **Verifiable criteria require strong, enforced opinions.** You can only check work against a definite standard, and a definite standard means picking one way and committing to it. So this collection is deliberately, sometimes arbitrarily, **opinionated** – about the format of a specification, the lifecycle states a design doc moves through, the branch and commit conventions, the structure of a plan. The specific choice often matters less than the fact that *a* choice was made and is enforced: a single enforced convention is verifiable; "whatever the model thinks best" is not.

This is why the principles below are stated as hard requirements rather than suggestions, and why the skills lean on rigid external contracts (an SRS repository's templates, a fixed commit grammar, a defined set of lifecycle labels). The rigidity is not pedantry – it is the mechanism by which a non-deterministic model is steered toward a deterministic-enough outcome.

## Specs-to-code: executable criteria as the primary feedback loop

The workflows these skills enable are deliberately **structured and disciplined**, and the discipline has a centre of gravity: **acceptance criteria specified in an executable form**. The aim is *specs-to-code* – agents that build the product exactly to specification, where the specification, not a sapien's running judgement, is the contract the agent works against.

Executable acceptance criteria are the **primary feedback loop** for evaluating the agent's work. An agent cannot reliably converge on the right result without a signal that tells it, unambiguously, whether the result is right – and a passing executable test is the strongest such signal there is. It is deterministic, stable, and re-runnable: the closest thing to *truth* available about whether the built thing matches the agreed thing. This is acceptance-test-driven development applied to agentic work, and it is what makes that work trustworthy. The more of the specification that is captured as executable criteria – functional behaviour as BDD-style scenarios, and increasingly the non-functional requirements too (performance, security) expressed as runnable checks – the less a sapien needs to sit in the loop, because the desired outcome and the verified outcome can be compared by machine.

This is *the* feedback loop, but not the *only* one. The collection builds in feedback at every layer of the work, each questioning a different assumption (see [single responsibility](#single-responsibility-and-the-duplication-it-avoids) and [evaluate or enact](#evaluate-or-enact-never-both)):

- **Against the acceptance criteria** – `/test` asks whether the increment meets the agreed spec. The core, executable loop above.
- **Against the architecture** – `/audit` asks whether the evolving design is sound, feeding `/refactor` → `/design`.
- **Against the product–market fit** – `/validate` asks whether the agreed spec was the right thing to build at all, feeding `/refine` → `/specify`.

The executable-criteria loop is primary because it is the one that can run unattended, every increment, with a deterministic verdict. The others are slower, more judgement-laden, and run less often – but they exist for the same reason: to give the work a signal it can be steered by, rather than leaving correctness to a model's unverifiable say-so.

## Iterative and incremental, not agentic waterfall

Specs-to-code, taken naively, collapses into an **agentic waterfall**: specify everything, design everything, then let the agent build the whole thing in one pass and ship a "big bang" release after a single trip through the lifecycle. That is *not* the workflow these skills enable, and the distinction is deliberate.

This workflow is **iterative and incremental**. There is genuine up-front work – a thorough specification and a considered design before construction begins; this is not "vibe-coding" with no plan. But the up-front artifacts are **living, not frozen**. Delivery is decomposed by `/plan` into small increments, each built, reviewed, and tested on its own, and the feedback gathered as those increments land flows *back* into the spec and the design and adjusts them mid-flight:

- An increment fails [`/validate`](#specs-to-code-executable-criteria-as-the-primary-feedback-loop) – the working software does not serve the real need – and `/refine` → `/specify` revises the requirements the remaining increments build toward.
- The evolving architecture drifts under construction, `/audit` catches it, and `/refactor` → `/design` corrects the design before the next increment compounds the problem.

The feedback loops in the workflow diagram are exactly this mechanism: they are what stop big-spec-and-big-design from hardening into waterfall. Up-front planning sets the initial direction; the loops let that direction be corrected by what construction actually reveals. The agent is not handed a frozen specification and left to build blind to a single deadline – it builds in increments, and the plan it builds to is allowed to learn.

This is why the cost of being wrong stays bounded. A waterfall that discovers a flawed spec or design at the end has built the whole product on it; an iterative workflow discovers the flaw one increment in and adjusts. The same executable-criteria discipline that makes each increment verifiable is what makes frequent, cheap correction possible – you can afford to adjust the spec mid-stream precisely because re-verifying against it is automatic.

## Enforcement lives outside the skill

**Skills steer; deterministic tests evaluate.**

It is worth being honest about what a skill can and cannot do. **A skill is a text file – a prompt.** It instructs, guides, and constrains a model, but it cannot *guarantee* the model's behaviour. A `MUST` in a `SKILL.md` is an instruction the agent is very likely to follow, not a law it is incapable of breaking. However carefully written, a skill steers; it does not enforce. Treating skills as if they were guarantees is the central mistake to avoid.

Real enforcement is **deterministic checks that sit outside the skill** and do not depend on the model honouring anything: the commit-message validation regex, the branch-name pattern, the linter, the type-checker, the CI pipeline, and – most importantly – the **automated acceptance test suite**. These run the same way every time, pass or fail without judgement, and cannot be talked out of a verdict. They are where the actual guarantees live. The executable acceptance criteria from the [specs-to-code loop](#specs-to-code-executable-criteria-as-the-primary-feedback-loop) are the most important of these checks, because they verify the thing that matters most – that the built software does what was agreed – and they do it deterministically, with no sapien or LLM in the loop to second-guess.

The two halves work together, and neither suffices alone:

- **A skill without a deterministic check** is a strong suggestion with no backstop. If the only thing standing between the agent and a malformed commit is a `SKILL.md` saying "use this format", malformed commits will eventually land. The skill raises the odds of the right outcome; it does not secure it.

- **A deterministic check without a skill** is a gate with no guidance. CI will reject a bad commit, but the agent wastes cycles discovering by trial and error what the gate wants. The skill front-loads the standard so the agent gets it right the first time; the check confirms that it did.

So the design stance is: **use skills to steer the agent toward the right outcome, and deterministic checks to guarantee it.** Wherever a skill states a rule that can be mechanically verified, there should be – or should come to be – an automated check that actually enforces it. The skill is how the agent learns the rule; the check is what makes the rule binding. This is also why the [convention skills](#skills-for-judgement-scripts-for-automation) (`/branch`, `/commit`, `/release`) pair naturally with validation regexes and CI jobs: the skill teaches the convention, the check enforces it, and the agent is held to the outcome regardless of whether it read the skill carefully.

## Skills for judgement, scripts for automation

This collection covers the parts of the software development lifecycle that call for *judgement* – the work that cannot be reduced to a deterministic procedure. Specifying requirements, weighing design trade-offs, decomposing delivery, reviewing a change, deciding whether the right thing was built: each demands reasoning about an open-ended problem, the kind of work an agent is well suited to and a script is not. These are the phases where a capable model earns its keep.

The deterministic parts of the lifecycle are deliberately **out of scope**. Anything that can be specified once and then run the same way every time – building, deploying, running migrations, linting, packaging, tagging an artifact – is better expressed as a script, a CI job, or a Makefile target than as a skill. There is no `/deploy` skill, and there should not be: a deployment is a fixed sequence of commands, and wrapping it in a skill only adds an unpredictable interpreter in front of a procedure that should be exact and repeatable. The same goes for `/build`, `/lint`, and their kind.

The dividing line is whether the work needs *deciding* or merely *doing*. If the outcome depends on context, taste, or trade-offs that change case by case, it is a candidate for a skill. If the outcome is the same procedure every time, it belongs in a script, and the skills here are designed to sit alongside that automation – calling it, being called by it – rather than to replace it.

Note that *agentic* is not a synonym for *automated*. Automation is deterministic: the same inputs yield the same outputs, every time, by a fixed procedure. Agentic work is the opposite – a model reasons through an open-ended problem and may reach a different, better answer on a different run. Both reduce human toil, but they are different tools for different kinds of work: automation for the procedures that should never vary, agentic skills for the judgements that legitimately can.

(One nuance: a few skills in this collection codify a *convention* rather than a judgement – `/branch`, `/commit`, and `/release`, for instance, encode naming rules and formats. These earn their place because applying the convention still requires reading an open-ended change and choosing the right category – a judgement – even though validating the result is deterministic. The deterministic half (the validation regex) is exactly the part that is also expressed as a script or CI check.)

## Workflow skills run non-interactively

The main workflow skills in this collection – `/specify`, `/design`, `/plan`, and their peers – are designed to run **non-interactively**, so they can be driven agentically without a sapien-in-the-loop. A workflow skill takes everything it needs from its initial prompt, its surrounding context, and the environment (the repository, the project's `AGENTS.md`, the upstream artifact it consumes), does its job, and stops. It does not stop partway to ask the user a question.

The corollary is that **a workflow skill fails rather than prompts.** If it cannot obtain everything it needs from the prompt, the context, and the environment, it stops with a clear, specific account of what is missing – it does NOT fall back to interviewing the user to fill the gap. `/specify` is the model: handed an incomplete PRD, it rejects it with an itemized list of what is absent, instead of asking the user to supply the missing rules. A clean failure is something an orchestrating agent can act on; a blocking prompt is not.

This is what makes these skills composable into an autonomous pipeline. An orchestrator – a sapien, an agent, or a script – can chain `/specify` → `/design` → `/plan` and let them run to completion or fail loudly, with no interactive turn in between. The place where missing information is *gathered* is a separate, explicitly interactive skill upstream (requirement elicitation is `/discover`'s job, not `/specify`'s); the workflow skills downstream consume what those produce and never re-open the conversation.

(Declare this with `metadata.interactive: no` in the skill's front-matter. The default is `yes`; a workflow skill overrides it deliberately. The opposite case – a skill *built* to interview a human, such as `/discover` – stays `interactive: yes`.)

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

A skill MUST NOT instruct the agent to invoke another skill next, name "the next step" as a specific skill, or chain itself to a successor. Sequencing skills into a workflow is **not a skill's decision** – it belongs to whatever orchestrates the skills: a sapien, an orchestrating agent, or a pipeline script. The skill exposes a clean output and a clear stopping point; the orchestrator decides what, if anything, runs next.

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

- **The judgement is reviewable before anything changes.** A sapien (or orchestrator) sees what `/review` or `/audit` found and decides what to act on, rather than discovering after the fact that a skill silently rewrote the code while "reviewing" it. Evaluation with side effects is hard to trust and hard to undo.

- **Each half is independently useful.** Evaluation is valuable on its own – a CI gate may run `/test` or `/audit` purely to report, with no intent to change anything. Enactment is valuable on its own – findings can come from a sapien, a tracker, or a prior run, not only from the paired evaluator.

- **It keeps each skill single-responsibility.** "Evaluate *and* fix" is two jobs; splitting them is just [single responsibility](#single-responsibility-and-the-duplication-it-avoids) applied to this specific seam. A skill that both judged and changed would be harder to reason about and impossible to use for evaluation alone.

This is a separation of responsibilities, not a hand-off: the evaluating skill does **not** name or invoke its enacting counterpart (that would break [independence](#independence) and the [no-hand-offs](#no-hand-offs-between-skills) rule). It reports neutrally and stops; the orchestrator – not the skill – decides whether to run the enactor next. The pairing is a fact of the *workflow*, documented here and shown in the repository's workflow diagram, not a link baked into either skill.

## Consequence for orchestration

Because skills neither reference nor hand off to one another, the *workflow* – the order in which skills run, the conditions under which one follows another, the sapien approval gates between phases – lives entirely outside the skills. It is the orchestrator's concern. A skill is a tool; the workflow is how the tools are wielded. Documenting a recommended workflow (for sapiens) is fine, and belongs in repository documentation – not inside any skill.

## Driving another repository's skills: read, don't invoke

A workflow skill in this collection may drive a target repository's own skills – `/specify` drives an SRS repository's `draft-spec` → `write-spec` → `propose-spec`, for instance. There are two ways it could do that, and only one of them is allowed here.

A global workflow skill MUST NOT literally *invoke* a target repository's local skills. It **reads their rules and instructions and executes that procedure itself**, in a non-interactive mode. The local skill is the authoritative *source of the procedure*; the workflow skill is the *engine that runs it* unattended.

This is a deliberate consequence of two facts about the local skills:

- **Local skills are interactive by design.** Every repository-level skill across the SRS, RFC, Design, and Plans repositories declares `metadata.interactive: yes`. They are written for a sapien operator at a keyboard: they prompt for a description, confirm a slug, ask which change type applies, and end by directing the user to the next skill in the lifecycle. Run literally, they would block on prompts the orchestrator cannot answer, and would tell the user to perform a step the orchestrator is itself about to perform.

- **A global workflow skill that consumes a PRD already holds the answers.** When `specify` drives the SRS workflow, the validated PRD supplies everything the interactive prompts would ask a sapien for. The skill does not need to *ask*; it needs to *apply*. So it reads what `draft-spec`/`write-spec`/`propose-spec` prescribe – the branch convention, the template, the acceptance-criteria format, the Definition of Ready, the lifecycle labels – and carries that procedure out directly, drawing every answer from the PRD instead of from a prompt.

Reading-not-invoking is also what keeps the *content rules in one place*. The target repository remains the single authoritative source for how its artifacts are written and how its proposals move through their states; the workflow skill never hard-codes a second copy of those rules from memory. It reads them fresh from the target repository each run (via that repository's `AGENTS.md` and the local skills it names), so a project that tunes its own `write-spec` automatically changes how `specify` behaves – without `specify` itself changing.

The division of labour, then:

- **Local repository-level skills** (`draft-spec`, `write-spec`, …) are `interactive: yes`. They are the sapien-operable, authoritative definition of each step, and the canonical home of the content and lifecycle rules.
- **Global workflow skills** (`specify`, …) are `interactive: no`. They consume an upstream artifact (a PRD), read the local skills' procedures, and execute them unattended – prompting for nothing, because the input already answers what the interactive path would ask.

## Presentation: skills as slash commands

A skill is presented as a slash command in documentation. Across this collection – and the wider ecosystem of repositories that expose their own agent skills – a skill name is written with a leading `/` inside backticks wherever it is presented *as an invocable command*:

- **Linked references**: `` [`/specify`](./skills/specify/) `` – the `/` goes inside the backticks; the link target (the path) is never prefixed.
- **H1 titles**: each `SKILL.md` and `README.md` opens with `` # `/specify` `` (not a prose title).
- **Bare command mentions**: "run `` `/discover` `` first".

The `/` is a presentation convention only. It is NOT added to the `name:` frontmatter field (the canonical identifier stays bare, e.g. `name: specify`), nor to file paths, code, branch names, commit types, lifecycle states, or to the word when it is used as an activity, phase, or noun rather than a command ("the discovery report", "after release"). Workflow-diagram node labels also stay bare.

## Token efficiency: the `SKILL.md` / `README.md` split

A `SKILL.md` is written for an agent, and every token it contains is loaded into the agent's context window when the skill fires. So a `SKILL.md` is written for **token efficiency**: it carries only what the agent needs to do the job, and no more. The 300-line ceiling (see [creating skills](./creating-skills.md)) is the hard limit; the spirit of the rule is to stay well under it. Token efficiency does not mean terse-to-illegibility, though – a `SKILL.md` MUST still be human-readable and cleanly formatted, with judicious use of whitespace, because sapiens author and maintain it. The two goals are compatible: cut redundancy and padding, keep the structure that makes the remaining content scannable.

The sibling `README.md` is written for **sapiens** – contributors and users browsing the collection. It is NOT loaded into the agent's context. This split decides where each piece of material belongs:

- **Anything the agent must read to act** – instructions, rules, success criteria, the bundled template it fills out – lives in `SKILL.md`.

- **Anything that is for human benefit only** – the prose overview, the workflow diagram, invocation examples, and **references to external resources** (the technique a skill is based on, the upstream skill it was adapted from, background reading) – lives in `README.md`.

The reference rule is the sharp edge of this principle. A link in a `SKILL.md` is an invitation for the agent to fetch it, pulling an unbounded external document into context and bloating it for no operational gain – the agent does not need to read the academic source behind a technique to apply the technique. So **external references that exist for human context belong in the `README.md`, never the `SKILL.md`.** A `SKILL.md` links outward only to material the agent genuinely needs to read to do its job – and per [portability](#portability), that material is almost always a bundled file inside the skill's own directory (a template, a script, a `references/` doc), not an external URL. The result: a `SKILL.md` whose `## References` section, if it has one, points only at the skill's own bundled assets, while the sapiens-facing citations sit in the `README.md` where a curious sapien can follow them without ever costing the agent a token.

## Every skill declares its input and output up front

Every `SKILL.md` opens – immediately after its intro prose, before the first `##` heading – with two prominent, bold-lead paragraphs:

```
**Input**: <what the skill consumes, how it is supplied, and whether it is REQUIRED or OPTIONAL>

**Output**: <what the skill produces, in what form, where it goes, and what completeness it guarantees>
```

This is the **contract** an orchestrator (agent or sapien) reads to decide whether the skill applies and how to wire it into a workflow. A skill is a tool; **Input**/**Output** is the shape of its socket – and prominence is what makes the collection composable.

The prominence is not cosmetic. It follows directly from the things this collection is built on:

- **Composition needs a declared contract.** Because the [workflow lives outside the skills](#consequence-for-orchestration) – no skill names, sequences, or hands off to another – the only way an orchestrator can chain skills is by matching one skill's output to the next skill's input. That matching is impossible if the contract is implicit or scattered through the prose. Stating **Input** and **Output** explicitly, in a fixed place and a fixed shape, is what lets `/discover` → `/specify` → `/design` → `/plan` → `/code` be assembled (and re-assembled in other orders) by a caller that knows nothing of any skill's internals. The contract *is* the composition seam.

- **Up front, because it is read first.** A caller decides *whether to use the skill at all* before it reads the instructions – does my situation match this input? is this output the thing I need? Burying that in a closing "Inputs and outputs" section forces the reader through the whole procedure to answer a gating question. So the contract goes immediately after the intro, before the first `##`: the agent encounters the shape of the job before its mechanics, and a sapien skimming the file gets the same answer in the first few lines.

- **A clean failure is a contract violation, made legible.** A [workflow skill fails rather than prompts](#workflow-skills-run-non-interactively): handed input that does not meet its declared **Input**, it stops with a specific account of what is missing. That behavior only makes sense against an explicit input contract – the declaration is the thing the failure is measured against. Without it, "missing input" is a judgement call; with it, it is a checkable fact.

For an **interactive** skill the **Input** paragraph carries one extra obligation: it MUST state that the skill *also* gathers input from the user through prompts during the session. Otherwise the contract reads as if the initial input is the whole input, when in fact an interactive skill (`/discover`, `/elaborate`, `/refine`, `/reflect`, `/create-skill`) deliberately starts from a partial or even absent seed and elicits the rest in conversation. A caller who does not know this cannot tell a "missing input" failure from a "will be asked for interactively" by-design – so the distinction is stated, not left implicit.

### The output declaration and the success criteria are two ends of one promise

The **Output** paragraph *describes* what the skill produces; the [`## Success criteria`](#predictable-outcomes-from-any-model) section *verifies* it. They are the same promise stated twice, for two different readers and two different moments. The **Output** is the up-front claim a caller reads to decide whether to use the skill; the success criteria are the self-checks the agent runs at the end to confirm the claim was met before it finishes. A well-formed skill keeps them aligned: every guarantee the **Output** advertises – an explicit out-of-scope list, a counter-example per rule, an NFR recorded even when none, a `PROPOSED` proposal awaiting approval – has a corresponding success criterion the agent can check itself against. The output declaration makes the promise; the success criteria are how the agent proves, to itself, that it kept it. If the **Output** claims something no success criterion checks, the skill is asserting an outcome it cannot verify – exactly the model-dependent, hope-it-worked behavior this collection exists to eliminate.

## Related

- [Best practices](./best-practices.md): Generic, universal guidance for authoring any agent skill – single responsibility, when a skill is worth adding, interactive vs. non-interactive execution.

- [Creating skills](./creating-skills.md): The authoring path (`create-skill`) and the contributor mechanics for this repository.

- [Collision safety](../skills/create-skill/references/create-skill-collision-safety.md): Namespacing bundled resources so a portable skill survives installation alongside others.
