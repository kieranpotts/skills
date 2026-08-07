# Interactive vs. non-interactive skills

Read this when deciding whether a skill should prompt the user mid-flow.

A skill is said to be **interactive** if it allows or instructs the agent to
block on user input — pausing to ask a question and waiting for the answer
before continuing. A skill is **non-interactive** if it explicitly tells the
agent to do its work from start-to-finish from its inputs and the workspace
alone, never stopping to get more input from the user.

Interactivity is desirable where human interaction is the core value in the
skill, for example a structured interview, or discovery of context that exists
only in the user's mind.

Non-interactivity is desirable where there may be valid use cases for running
agents unattended, for example in continuous integration systems.

State the mode plainly in prose, in two places:

- The `## Parameters` preamble, so the agent knows up front whether it may
  prompt the user when a parameter is uncertain.

- The README's `## Interactivity` section, so a human skimming the skill knows
  what to expect without needing to read the full `SKILL.md`.
