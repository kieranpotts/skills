# Best practices

This section covers best practices for designing agentic workflows.

## Single responsibility

Every skill MUST have a single responsibility. A skill does one job and stops at the boundary of that job – it does NOT reach into adjacent work, even when doing so would be convenient.

The canonical example: a skill that proofreads a document MUST NOT also commit the changes. Committing is a separate responsibility, and the decision of whether, when, and how to commit belongs to the caller – which might be a human, or an agent invoking another skill ([`commit`](../skills/commit/SKILL.md)). The proofreading skill edits and stops; what happens next is not its concern.

This is what makes the collection composable. Each skill is a small, sharp tool with one clear output and an explicit hand-off, so callers can chain skills in whatever order their workflow demands. A skill that bundles two responsibilities forecloses that choice and couples concerns that should stay independent.

Apply the test when scoping any skill: *can I name its responsibility in a single verb phrase, without an "and"?* "Proofread prose." "Compose a commit message." "Decompose a design into steps." If the honest description needs an "and" – "proofread **and** commit", "review **and** merge" – it is two skills, and the second responsibility belongs to a separate skill or to the caller.

The rest of this document builds on this principle: a single responsibility is what gives a skill a clear trigger condition, a clean hand-off, and a definite point at which to stop.

## When to add a skill

A skill is worth adding when it:

- **Encodes judgement, interpretation, or context-sensitivity.** Skills are for recurring work that can't be reduced to a deterministic rule.

- **Has no deterministic substitute.** Use AIs only for tasks they do better than traditional scripting and algorithms. If a linter, formatter, validator, Git hook, build script, or CI job already does (or could do) the job, prefer that. Skills are for the parts of the SDLC that resist automation by conventional tools.

  - Where a skill does invoke deterministic sub-tasks, embed explicit scripts to perform them. It saves tokens and removes ambiguity, improving predictability of outcomes.

- **Covers a single responsibility** (see above) with a clear trigger condition.

- **Is technology-agnostic and domain-agnostic**, and so useful across diverse projects.

- **Is opinionated.** Skills should describe one clear path for achieving a goal, not offer a menu of options.

- **Fits an existing workflow** with clear boundaries with other skills in the workflow, and explicit hand-offs to and from adjacent skills.

Do _not_ create a skill when:

- A deterministic tool already handles the task. Deployment of release artifacts, for example, belongs in a CI pipeline, not a skill.

- An existing skill already covers the concern. (Instead, propose to extend or refine the existing skill.)

- The shape is one-off, with no reusable form across projects.

- The content would primarily restate language-specific or framework-specific conventions.

Another key design decision is the choice between **synchronous and asynchronous execution of skills** — ie. whether the skill permits the agent to prompt the user for input mid-flow. Decide this deliberately for each skill:

- **Synchronous:** The skill MAY block on user input. Reserve this for stages where human interaction is essential to the outcome. And example is this repository's [`discover`](../skills/discover/SKILL.md), which is a structured agent-human interview, and is therefore its execution model is inherently sycnhronous. The same will be true of any skill whose value comes from eliciting judgement, preferences, or context that only the user holds. Synchronous skills MUST state clearly in their description when and why they prompt for input.

- **Asynchronous:** The skill MUST run to completion without user input, taking everything it needs from its inputs and the workspace. This should be the default behavior for skills (it doesn't need specifying in the skill itself). Use when the skill is intended to be run in unattended pipelines, supporting parallel agentic workflows.

When a synchronous skill feeds an asynchronous one, the hand-off should resolve all the human-dependent decisions first, so the downstream skill receives a complete, settled input.

The related design decision is **where a skill hands off to another agent and where it hands off to a human**. In a pipeline, the natural default is agent-to-agent: each skill passes its output to the next, and the workflow runs end-to-end without intervention. But some outcomes need a human to moderate them before the work proceeds — and choosing those checkpoints is another key design decision.

This is a trade-off, not a rule, but – insert a human checkpoint where:

- The cost of an undetected error is high, or hard to reverse downstream (eg. a flawed specification that propagates through design and implementation).

- The decision is genuinely the human's to make — a judgement call about scope, risk, or priorities that the agent should not settle alone.

- The output is the thing the human ultimately owns and signs off on (a release, a merged PR, a published artifact).

But guard against over-gating. Route _everything_ through a human and you recreate the bottleneck the pipeline was meant to remove. The poor human is swamped with PRs to review and becomes the rate-limiter for the whole workflow, which defeats the point of parallel agentic execution.

Each checkpoint should earn its place. Prefer to let agents hand off to agents wherever the outcome is low-risk, reversible, or verifiable by a deterministic check, and reserve human moderation for the decisions that genuinely warrant it.
