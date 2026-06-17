# Design notes

These are the design principles and goals that underpin this collection of skills.

## Predictable outcomes

The overriding goal of this project is to produce predictable, consistent, reliable outcomes from every mainstream coding model.

To achieve predictable outcomes, you need to base your agentic workflow on concrete, **verifiable success criteria**. A skill should give the agent clear, self-verifiable criteria for what "done" and "correct" look like. The success criteria should be concrete enough that the agent can evaluate its own work and course-correct if necessary.

Vague guidance (eg. "write a good spec") leaves outcomes determined primarily by the quality of the underlying model. Concrete success criteria produce more consistent outcomes across a wider range of models – frontier and mid-tier, closed-weight and open-weight.

The strongest guardrails are **automated tests** – acceptance criteria written in an executable form. This is the main feedback loop in agentic workflows. A passing acceptance test is the strongest signal an agent can have that it is on the right track.

Testable success criteria require imposing **strong opinions**. You can only check work against a definitive standard, which means picking one way of doing something and encoding it in the skill. Skills work best when they DO NOT offer agents a menu of options.

These skills describe rigid workflows for agents to follow step-by-step. That rigidity is the mechanism by which non-deterministic models are steered toward predictable outcomes.

## Enforcement lives outside

A skill is just a prompt. It guides a model, but it cannot guarantee what the model does – no matter how well the skill is worded.

Real enforcement comes from automated, deterministic checks that are executed independently of the agent: linters, type-checkers, and above all the test suite.

**Steer with skills, enforce with checks.** Wherever a skill states a rule that a machine can verify, there should be a deterministic check – executed independently of the agent – that enforces it.

## Agentic versus automated

Automation is deterministic. Given the same set of inputs, you get the same outputs on every execution. (If you don't, it's a bug.) Agentic work, by contrast, applies judgement and throws in a bit of randomness. Outputs are inconsistent.

Agents should not be used where regular computation will suffice. Reserve agentic work for tasks that only large-language models have the capability – specifically, **open-ended problems** that require **judgment** to weigh trade-offs, try different paths, and mark your own homework.

A skill is worth adding when it encodes judgement, interpretation, or context-sensitivity that can't be reduced to a deterministic rule.

Linting, building, packaging, deploying, migrating… these steps in the software development lifecycle are best left scripted. This is why there are no `/build` or `/deploy` skills in this collection. Those steps do not belong here. Skills are for the parts of the software development life cycle that resist automation by conventional tools.

> [!TIP]
> Where a skill does invoke deterministic sub-tasks, embed explicit scripts for the agent to execute. This saves valuable tokens and removes ambiguity, improving predictability of outcomes.

## Cohesive ecosystem

This is no grab-bag of random skills. It's a cohesive collection that forms a complete end-to-end development workflow. As such, it assumes a broader, structured environment of development methods and tools.

Specifically, these skills depend on version-controlled systems for tracking software requirements, technical decisions, design documentation, and implementation plans. The following are reference implementations of those dependencies:

- [**📋 Software Requirements Specification (SRS)**](https://github.com/kieranpotts/specs): Captures what the system does, in business terms.

- [**💬 Requests for Comments (RFC)**](https://github.com/kieranpotts/rfc): Records how significant technical decisions were made, and why.

- [**📐 Design Docs**](https://github.com/kieranpotts/design): Documents what the system looks like in production, and manages proposed architectural changes.

- [**🗺️ Implementation Plans**](https://github.com/kieranpotts/plans): Tracks when, and in what order, the work gets done.

The trade-off is that these skills can't be easily dropped into any project – they encode a very specific, strongly opinionated workflow.

## Everything under version control

The whole ecosystem runs on version control. Everything the workflow produces is kept there – not just the code, but the requirements, decisions, designs, and plans too.

This has numerous benefits:

- **One consistent process for everything.** Code, requirements, decisions, designs, and plans are all branched, committed, reviewed, and merged in (roughly) the same way. There are no separate methods and tools for "the spec" and "the code," for example.

- **Everything stays together.** Related artifacts are not scattered across different systems – wikis, trackers, a shared filesystem, and so on. All development artifacts – specs, decisions, designs, plans, and code – coexist in the same version control system.

- **Audit trails and undo operations are built-in.** Because every agent-generated artifact is kept under version control, you get auditability and rollback for free.

- **Integration with existing automation.** Continuous integration systems can apply deterministic verification to agent output.

## Skills hierarchy

While these skills are loosely coupled to one another, they are tightly coupled to external development tools. Specifically, they expect requirements specifications, technical decision logs, design docs, and implementation plans to exist in very particular formats. This is necessary to achieve predictable outcomes – the ultimate objective.

A workflow skill here may drive another repository's own skills. `/specify`, for instance, drives an SRS repository's `draft-spec` → `write-spec` → `propose-spec`. But it MUST NOT actually *run* them. Instead it **reads their instructions and carries them out itself**, without stopping for input. The other repository's skill is the authoritative *description of the steps*. The workflow skill is the thing that *runs those steps* on its own.

Reading rather than running keeps the rules in one place. The target repository stays the single source for how its documents are written. The workflow skill never keeps its own copy of those rules. It reads them fresh each time. So if a project changes its own `write-spec`, that changes how `/specify` behaves there, without `/specify` itself having to change.

## Global skills

These skills are optimized for the development of application software that spans multiple code repositories – and potentially multiple teams – where requirements, decisions, designs, and plans are shared concerns that sit above any single codebase.

As global skills, intended to be used across multiple projects, these skills are **technology-agnostic and domain-agnostic**. The skills instruct agents to extract things like coding conventions and domain language from local reference artifacts, extracted on-demand when the agents need this information. The skills specialize in the definition of agentic _workflows_, not the encoding of _knowledge_.

Since they are intended to be used globally across multiple code repositories, it is recommended to install these skills in the user's home directory or in a workspace root, rather than in individual code repositories. The bundled installer supports per-project installs, but that is not the intended use case.

For a standalone code repository – a small utility library, say – it is recommended instead to encapsulate bespoke skills and supporting artifacts directly in that repository. These skills do not serve that use case.

## Loose coupling

Skills are connected by contracts, not by handoffs. One skill's output is the next skill's input – but no skill names, refers to, or invokes another. Each does its one job, reports the result, and stops.

Deciding what runs next belongs to whoever is running the skills – another agent, a script, or a sapien – not to the skill itself. This lets the skills be composed into workflows in different ways.

Coupling through contracts rather than handoffs also makes individual skills easier to maintain and to reuse.

## External drivers

Because no skill refers to or hands off to another, the workflow – the order the skills run in, when one follows another, the approval steps between phases – lives entirely outside the skills.

A skill is a tool. The workflow is how you use the tools. The same skill might be the last step in one workflow and a middle step in another. Baking "next, run X" into a skill would foreclose that. So the order, the conditions under which one skill follows another, and the approval gates between phases all belong to the orchestrator. The orchestrator might be a sapien, an agent, or a script. It is never the skills themselves. Documenting a recommended workflow is fine. But it belongs in repository documentation, such as these notes, not inside any skill.

## Well-defined inputs and outputs

Achieving loose coupling requires each skill to have well-defined inputs and outputs. So every `SKILL.md` opens – immediately after its intro prose, before the first `##` heading – with two prominent, bold-lead paragraphs:

```
**Input**: <what the skill consumes, how it is supplied, and whether it is REQUIRED or OPTIONAL>

**Output**: <what the skill produces, in what form, where it goes, and what completeness it guarantees>
```

This is the **contract** the caller reads to decide whether the skill fits and how to connect it. The **Input** and **Output** are put up top for two reasons:

- **You can only chain skills if each one states what it takes and gives.** Since the [workflow lives outside the skills](#external-drivers), the only way to connect them is to match one skill's output to the next one's input. That's impossible if the contract is buried or vague.

- **It's read first.** A caller decides *whether to use the skill at all* before reading the steps. Putting the contract at the end would force them through the whole thing just to answer that.

For an **interactive** skill, the **Input** paragraph MUST also say that the skill asks the user for input during the session – otherwise it reads as if the starting input is all there is, and a caller can't tell a real "missing input" failure from "it will ask for the rest".

The **Output** paragraph *says* what the skill produces. The [`## Success criteria`](#predictable-outcomes) section *checks* it. They are the same promise written twice – one for the caller up front, one for the agent to check against at the end. A good skill keeps them matched. Everything the **Output** promises has a success criterion that confirms it. If the **Output** claims something no criterion checks, the skill is promising a result it can't actually verify – exactly the hope-it-worked behavior this collection exists to avoid.

## Single responsibility

A skill should have a single responsibility. It should do one job and stop at a well-defined boundary. A skill should not reach into adjacent work, even if doing so would be convenient.

An important design constraint on this skills collection is that no one skill does both _evaluation_ and _implementation_. A skill either analyzes and reports its findings, or it enacts a change – but never both. For example, a skill that proofreads a document (`/proof`) does not also commit the changes it makes to the document (`/commit`). The decision of whether, when, and how to commit belongs to the caller – which might be a sapien, or an orchestrating agent or script.

The following pairs of skills represent other splits between these two responsibilities:

| Evaluates and reports | Enacts the change |
| --------------------- | ----------------- |
| `/review` reviews code | `/resolve` actions the review comments |
| `/test` runs tests | `/debug` diagnoses and fixes a failure |
| `/audit` evaluates the architecture | `/refactor` iterates in code |
| `/validate` judges whether the right thing was built | `/refine` updates the requirements specification |

Keeping these two concerns apart means humans can review findings before anything changes. Having a single responsibility gives each skill a clear trigger condition, too. And each skill becomes more useful on its own. For example, you could reuse an evaluator skill to report into a CI gate, and you could feed an enacting skill findings recorded in an issue or inputted directly by a human.

## Interactive versus non-interactive

To support end-to-end agentic workflows, most skills are **non-interactive** (🤖). They run to completion without stopping to ask the user, taking only the initial prompt and what the environment provides. This is what lets them run unattended, in parallel pipelines. A few skills are deliberately **interactive** (🧑) and may block on input. These are used sparingly, only where the human interaction *is* the value. An example is this repository's [`discover`](../skills/discover/SKILL.md), a structured interview whose entire point is the dialogue.

Choosing where a workflow pauses for a human is itself a design decision. Insert a checkpoint where the cost of an undetected error is high or hard to reverse, where the call is genuinely the human's to make, or where the output is theirs to own and sign off. But each checkpoint should earn its place. Gate *everything* and you recreate the bottleneck the pipeline was meant to remove. Let the workflow run unattended wherever the outcome is low-risk, reversible, or verifiable by a deterministic check.

A skill MAY declare its mode in front-matter so hosts can route on it:

```yaml
metadata:
  interactive: no   # this skill never blocks on the user
```

The default, when the field is omitted, is `yes` – a skill is assumed interactive unless it says otherwise. This is the safe default. A host running skills unattended will not silently run one that might have needed a human. So set `interactive: no` only on skills you are confident run start-to-finish without ever blocking, and leave the field off for skills that are interactive or only *conditionally* interactive. Claiming `interactive: no` for a skill that might actually prompt is the mistake this field exists to prevent.

The field lives under `metadata`, the Agent Skills standard's sanctioned place for vendor data, so it validates against the canonical schema and stays portable – hosts that do not read it simply ignore it. (See also [`metadata.preferred_model`](../skills/create-skill/references/create-skill-preferred-model.md), in the same map for the same reason.)

Every skill says which kind it is up front – in its `metadata.interactive` front-matter, in the H1 emoji of its `SKILL.md` and `README.md`, and in the workflow diagram:

- **🧑 Interactive skills** (`metadata.interactive: yes`) require a sapien in the loop. They are *built* to converse – ask, present options, wait for answers – and cannot complete without a human responding: `/discover`, `/elaborate`, `/refine`, `/reflect`, `/create-skill`.

- **🤖 Agentic skills** (`metadata.interactive: no`) run with no human turn. They take everything from the prompt, context, and environment, do the job, and stop. This is most of the collection – `/specify`, `/design`, `/plan`, `/code`, `/review`, `/test` – and it is what lets an orchestrator chain them into an unattended pipeline.

The split draws a clean line. **Asking a person for input** is the job of a 🧑 skill upstream (gathering requirements is `/discover`'s job, not `/specify`'s), and the 🤖 skills downstream just *use* what those produce. This leads to one important rule. **A 🤖 skill fails instead of asking.** If it can't get everything it needs from the prompt, the context, and the environment, it stops and says exactly what is missing – it does NOT fall back to questioning the user. Take `/specify` as the example. Given an incomplete PRD, it rejects it with a list of what's absent. A clean failure is something the caller can act on. A skill stuck waiting for an answer is not. So a 🤖 skill that finds itself wanting to ask the user a question has either been given incomplete input – in which case it fails and says so – or taken on work that belongs to a 🧑 skill instead.

## Composable

If each skill is a small, sharp tool with well-defined input and output, an orchestrator can compose the skills into new, interesting workflows.

The [workflow diagram](../README.md) shows *one* recommended order – the proactive `/discover` → `/specify` → `/design` → `/plan` → build-loop path, and the reactive `/triage` → build-loop path. It is a **suggestion, not a rule**. Because every skill is [loosely coupled](#loose-coupling), hands off to nothing, and states its [input and output](#well-defined-inputs-and-outputs), any skill whose output matches another's input can feed into it, wherever they sit in the diagram.

A few combinations the diagram doesn't show:

- **An evaluation skill as a starting point.** `/validate` sits at the *end* of the main path, but its output – a ranked list of gaps between what was built and what was needed – is exactly what a discovery session works from. So it can be the **way in** to a fresh round of requirements work. The same goes for running `/audit` on a codebase you've inherited.

- **Building skills used on their own.** `/commit`, `/branch`, `/format`, and `/proof` are each useful on their own, run as needed, with no earlier skill having run first.

- **Loops the diagram leaves out.** Nothing stops you running `/review` → `/resolve` → `/review` until it's clean, or dropping in `/research` wherever you hit a gap in knowledge.

**Keep the skills unaware of the workflow, and the workflow becomes something the user puts together – not something the skills dictate.** Within a single project, this is what keeps the range of possible workflows open.

## Specs-to-code

Composed together, these skills support a complete **specs-to-code** workflow – one where the specification, captured as executable acceptance criteria, is what drives and verifies the build.

The pivot is the requirements specification (`/specify`). The more of the spec you can capture as executable acceptance tests – covering both functional behavior and non-functional runtime qualities – the more an agent can verify its own progress against the [primary feedback loop](#predictable-outcomes), with no human needed to judge whether it is done.

As outcomes become less dependent on judgment, you need fewer humans-in-the-loop.

## Iterative and incremental

Specs-to-code workflows risk becoming an **agentic waterfall**, in which large-scale code changes all land at once – resulting in fragile **big bang** releases.

This is resolved by breaking down deliverables into an incremental development plan (`/plan`). That up-front planning depends on a thorough spec and a considered design being in place – it's not vibe coding.

Incremental delivery keeps the cost of a mistake small. A flaw is caught one increment in, when correction is easier.

## Other design decisions

A few further conventions, in brief:

- **Portability.** A skill MUST NOT depend on anything outside its own directory. Everything it needs – the `SKILL.md`, plus any bundled `assets/`, `references/`, or `scripts/` – lives inside `skills/<name>/`, so a single skill can be lifted out and installed on its own and still work. Bundled files are uniquely named to avoid clashing when installed alongside others (see [collision safety](../skills/create-skill/references/create-skill-collision-safety.md)).

- **Naming convention.** In documentation, a skill is shown as a slash command with the `/` inside backticks wherever it names a runnable command (`` `/specify` ``, an H1 `` # `/specify` ``, a linked `` [`/specify`](./skills/specify/) `` with the path unprefixed). The `/` is presentation only – it is NOT added to the `name:` front-matter, file paths, branch names, commit types, or the word used as a plain noun ("after release").

- **Token efficiency: the `SKILL.md` / `README.md` split.** A `SKILL.md` is loaded into the agent's context every run, so it carries only what the agent needs (under the 300-line ceiling). The matching `README.md` is for people and is not loaded. Anything the agent must read to do the job goes in `SKILL.md`. The overview, diagram, usage examples, and **links to outside resources** go in `README.md`. A link in a `SKILL.md` invites the agent to pull a large document into context for no real benefit, and per the portability point above, what it does link to is almost always a file bundled in its own folder.

## Related

- [Creating skills](./creating-skills.md): The authoring path (`create-skill`) and the contributor mechanics for this repository.
