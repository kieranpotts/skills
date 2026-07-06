# Objectives

The overriding objective in the design of an agentic workflow is to produce **predictable outcomes**, and for those outcomes to be highly **consistent** across all mainstream coding models.

Predictability comes from the constraints we wrap around our agents — the [guides and sensors](./guides-and-sensors.md) that steer and verify their work — and from [calibrating](./calibration.md) those constraints so that agents are given clear, self-verifiable criteria for what "done" and "correct" look like.

Beneath that overriding objective sit four supporting ones:

- **Composability.** Each step in a workflow is a small, sharp tool with a well-defined interface, which any orchestrator — human, script, or agent — can [compose](./composable-pipelines.md) into new pipelines.

- **Portability.** Skills encode [rules, not knowledge](./rules-versus-knowledge.md), staying technology- and domain-agnostic so they run unmodified across projects — and, per the consistency objective, across models.

- **Context economy.** The quality of a model's output degrades as its context window fills, so workflows are designed to keep each agent's context trim — through small increments of work, narrowly-scoped skills, and [persisting](./persistence.md) distilled outputs to disk rather than carrying working state forward in-conversation.

- **Earned autonomy.** As deterministic verification proves itself, fewer [humans are needed in the loop](./human-in-the-loop.md). The long-term goal is production-grade code delivered from specifications with minimal human involvement downstream.
