# Interactive versus non-interactive

A key design decision in the [interface definition](./interface-definitions.md)
of an agent skill is whether the skill can be executed non-interactively.

Non-interactive execution supports agentic workflows that run to completion
without stopping to ask the user, taking only the initial prompt and what the
environment provides for input. Non-interactive skills can be run unattended.
And, depending on where they fit in a workflow, non-interactive instructions may
be followed by parallel subagents, too.

But some skills are necessarily interactive. They may instruct the agent to
block for user input: to ask questions, present options, and wait for answers.

Interactive skills should be used sparingly. They should be used only where
human interaction *is* the value in the skill. An example is this collection's
**[discover](../skills/discover/SKILL.md)** skill, which is a structured interview
whose entire point is the dialogue.

The emerging goal of the specs-to-code movement is for all interactive sessions
to happen upstream. Humans are in-the-loop only in the initial phases of the
software development lifecycle. The objective is for predictable,
production-grade code to be realized from requirements specifications inputted
as executable acceptance criteria, with minimal human involvement further
downstream.
