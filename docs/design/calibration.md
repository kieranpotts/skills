# Calibration of guides and sensors

To achieve [predictable, consistent outcomes](./objectives.md), you need to base your agentic workflows on clear, unambiguous instructions, with output validated against concrete, verifiable success criteria.

Vague guidance and incomplete checks leave outcomes determined primarily by the quality of the underlying model. Concrete steps and success criteria produce more consistent outcomes across a wider range of models — frontier and mid-tier, closed-weight and open-weight.

The strongest guardrails are automated acceptance tests, ie. success criteria written in an executable form. A passing acceptance test is the strongest signal an agent can have that it is on the right track.

Acceptance tests can also be run by a regular quality gate (an automated step) to verify an agent's output (from a prior agentic step).

For automated acceptance tests to be an effective tool for steering agent behavior, their success criteria need to be sufficiently concrete that an agent can evaluate its own work and course-correct if necessary. This means imposing opinions. You can only verify something against a definitive standard, so you need to pick one way to do something, and then encode that opinion in a skill for that particular task.

For the same reason, agent skills (or other [guides](./guides-and-sensors.md)) work best when they have a certain rigidity — clear, unambiguous, prescriptive step-by-step instructions (ie. reusable procedures) for agents to follow, and success criteria that can be verified with a [deterministic test](./deterministic-sensors.md). For example, rather than giving agents a menu of equally-weighted options, prefer to provide a default with named alternatives for specific, clearly-articulated use cases. Match the specificity of an instruction to the fragility of the task at hand. Give the agent some latitude where the task tolerates variation, but explain *why* different approaches will be valid in different scenarios.

Reliability in agentic workflows comes primarily from the quality of the constraints that we wrap around our agents. The size and intelligence of the underlying model is important, but it's not our primary quality control. A frontier model given vague guidance will behave less predictably than a smaller model given a tightly specified skill and a deterministic gate to pass. Tightening the constraints is a more reliable lever than swapping in a stronger model.

Building in _just enough_ rigidity to the guides and sensors we give our agents is how we steer non-deterministic models toward predictable, consistent, quality outcomes.
