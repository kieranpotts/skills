# Create skill

The **create-skill** skill is all about authoring a new skill, or improving an
existing one, either in this global skills collection or any downstream
project.

It produces a complete skill directory, including:

- A `SKILL.md` based on the bundled template.
- A human-facing `README.md` with skill invocation instructions.
- Bundled scripts, references, and assets as required by the skill.

The agent is instructed to ensure all artifacts pass a deterministic validator.

## Interactivity

This skill instructs the agent to prompt the user if it needs help forming the
skill.

## How to invoke

> Create a skill for X.

> Turn this workflow into a skill.

> Improve the `<name>` skill.

## Recommended models

A mid-tier model is sufficient for basic skill authoring. Reach for a frontier
reasoning model when drafting a genuinely new skill from scratch.

## Related skills

- [**reflect**](../reflect/) \
  Draws lessons from an AI session, which can then be used as the basis for
  new skills, so persisting those learnings to disk rather than relying on
  memory.
