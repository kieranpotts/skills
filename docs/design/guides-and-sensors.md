# Guides and sensors

We steer agents with skills, technical standards, and other guidelines, and we enforce their behaviors with deterministic checkpoints. A robust, reliable agentic workflow is therefore constructed from two types of constraints: [guides and sensors](https://martinfowler.com/articles/harness-engineering.html).

- **Guides** are the feed-forward controls that steer the agent *before* it acts, anticipating problems and increasing the odds of good output on the first attempt. `AGENTS.md` and skill files are emerging as the standard protocols for agent guides.

- **Sensors** are the feedback controls that verify an agent's output *after* it acts. A linter, a type-checker, a test suite, and human code review are all examples of sensors.

An agent steered only by guides can repeat the same undetected mistakes indefinitely. An agent steered only by sensors will run in a slow, expensive trial-and-error loop.

Reliable, efficient agentic workflows need a mix of both guides and sensors.
