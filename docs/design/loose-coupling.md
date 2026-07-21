# Loose coupling

For skills to be [composable](./composable-pipelines.md) into different
workflows, they need to be loosely coupled from one another. And for skills to
be loosely coupled, they must be connected by contracts —
[interface definitions](./interface-definitions.md) — not by direct handoffs.

One skill's output is the input to the next skill in the pipeline. But no skill
should directly refer to, invoke, or hand off to another skill. Each does its
one job, reports the result, and stops.

This means the workflow composition lives externally to the skills files. The
order in which skills are run, and the deterministic approval gates that are
injected between the agentic steps, are the responsibility of the orchestrator —
the person or thing that is running the workflow.

An orchestrator may be a human, manually invoking each skill via their agent
harness, or it might be a deterministic script, perhaps running the workflow in
a continuous integration system. The orchestrator might even be a God-like agent
that manages multiple subagents and executes the deterministic scripts that
validate their output.

The critical design constraint is that skills, and the subagents that read them,
are unaware of the workflow. The workflow becomes something the user puts
together — whether that user is a human, a script, or another agent.

Coupling through contracts rather than handoffs also makes individual skills
easier to maintain and to reuse, and it helps to keep an agent's context length
trim and precise.
