# Create skill

The **create-skill** skill is all about authoring a new skill, or improving an
existing one, either in this global skills collection or any downstream
project.

It produces a complete skill directory, including:

- A `SKILL.md` written from the bundled template.
- A human-facing `README.md` with skill invocation instructions.
- Any bundled scripts, references, and assets.

The agent is instructed to ensure all artifacts pass the validator.

## Interactivity

The agent is instructed to prompt the user for input to help it form the skill.

## How to invoke

> Create a skill for X.

> Turn this workflow into a skill.

> Improve the `<name>` skill.

## Recommended models

A mid-tier model is sufficient for basic skill authoring. Reach for a frontier
reasoning model when drafting a genuinely new skill from scratch.

## Related skills

- **[reflect](../reflect/)** draws lessons from an AI session, which can then
  be used as the basis for new skills to persist those learnings to disk
  rather than relying on memory.
