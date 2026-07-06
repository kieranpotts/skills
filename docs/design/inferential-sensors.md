# Inferential sensors

Not all [sensors](./guides-and-sensors.md) can be scripted. Inferential sensors are the second category of sensor — alongside [deterministic sensors](./deterministic-sensors.md) — in which one agent is tasked with judging the output from another agent further upstream in the workflow. They can be run only by agents, and cannot be offloaded to traditional scripts.

Agent skills that describe how to "review" and "audit" code are examples of inferential sensors. They are distinct from deterministic sensors like "build" and "test".

We must not depend on inferential sensors to verify the outcomes of our agentic workflows. Deterministic sensors — especially executable acceptance criteria — are the most important sensors for controlling outcomes. Nevertheless, inferential sensors do bring added value to agentic workflows. They can help to improve the quality of the output by adding more perspectives.

The critical design constraint is that an agent that generates output (eg. write program code) must not be the one that analyses that output (eg. does code review). Models exhibit sycophancy. An agent asked to critique its own recent work is biased toward judging it favorably.

A fresh agent is far more likely to surface real defects. Therefore, orchestrators should invoke inferential sensors as distinct agent sessions. This gives the reviewing agent no visibility into the reasoning that produced the output it is marking.

Evaluator agents should be framed as adversarial personalities. An agent instructed to assume the work is correct and to check for obvious problems will tend to agree with what it reads. An agent instructed to assume the work is broken, and to actively verify that claim, is far less prone to rubber-stamping.
