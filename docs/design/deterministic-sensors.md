# Deterministic sensors

[Sensors](./guides-and-sensors.md) regulate the quality of the evolving software. There are two types: deterministic sensors, and [inferential sensors](./inferential-sensors.md).

The deterministic sensors are our automated quality gates in which we impose our strong opinions on the expected outcomes from our agents. The deterministic sensors include our linters, build and packaging scripts, deployment pipelines, and of course the all-important acceptance tests.

A variety of deterministic sensors must exist to verify the evolving software at multiple levels, including but not limited to: code quality (eg. maintainability, style, complexity); architectural fitness (eg. performance, scalability, observability); and behavioral correctness (ie. the software meets its functional requirements).

These sensors work best when they are distributed across every step of the pipeline, providing continuous feedback throughout, rather than running in a single gate at the end. The sooner a defect is caught, the cheaper it is to fix, and the less work an agent has to unwind.

Deterministic sensors may be invoked by agents — with the scripts and function calls encoded in agent skills — so the agents can evaluate their own progress toward their goals. But there are no guarantees that agents will actually do this — no matter how well written the skill, and no matter how well the underlying model has been trained and fine-tuned for the task at hand. A skill is just a prompt. It steers a model, but it cannot _guarantee_ what the model does. We can't rely on agents marking their own homework.

So the verification of an agent's output must be done independently of the agent. Real enforcement of agent behaviors comes from automated, deterministic sensors — linters, type-checkers, and above all the test suite — run in _external processes_.

So, wherever a skill states a rule that a machine can verify, there should be a deterministic check, run by an external process, that verifies the agent's conformance to the rule.

This is particularly critical for the acceptance tests — the main quality gate in agentic workflows.

The less that validation of outcomes is dependent upon judgment, and the more it is handled by independent, deterministic sensors, the more predictably your agentic workflows will behave. And, as your trust in your agentic workflows increases, you will gain the confidence to have fewer humans in the loop. Having lots of deterministic sensors, operating at multiple levels of verification, and run by automated scripts not by autonomous agents, is the path to fully agentic software delivery.
