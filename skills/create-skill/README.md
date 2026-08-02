# Create skill

The **create-skill** skill is all about authoring a new skill, or improving an
existing one, either in this global skills collection or any downstream
project.

It produces a complete skill directory, including:

- A `SKILL.md` written from the bundled template.
- A human-facing `README.md` with skill invocation instructions.
- Any bundled scripts, references, and assets.

The agent is instructed to ensure all artifacts pass the validator.

The agent is instructed to prompt the user for input to help it form the skill.

## How to invoke

> Create a skill for X.

> Turn this workflow into a skill.

> Improve the `<name>` skill.

## Recommended models

A mid-tier model will handle basic skill authoring, especially since the schema
and structure are well defined in this skill so the agent is mostly following
instructions.

Reach for a frontier reasoning model when drafting a genuinely new skill from
scratch, where getting the scope, triggers, and boundaries right requires
weighing trade-offs, rather than following a template.

## Related skills

- **[reflect](../reflect/):** flags a universal, session-derived lesson as a
  candidate for a new skill authored here, rather than saving it to memory.
