# Interface definitions

Achieving [loose coupling](./loose-coupling.md) requires each step to have a well-defined set of inputs and outputs. Each agent skill must be explicit in what it consumes, whether that input is optional or required, and whether the skill requires an interactive session in which the agent is free to prompt the user for further input.

Each skill must also be explicit about what output it produces, in what formats, and where the output is written.

Every output should also have corresponding [success criteria](./calibration.md) against which it can be evaluated.

The input/output definitions are the contract the orchestrator reads to decide where a skill can fit into a workflow, how to connect it, and how to validate it.
