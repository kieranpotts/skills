# Reflect

The **reflect** skill is all about distilling durable lessons from the agent
session into memory.

The agent is instructed to distill _working-style_ continuity, ie. how
to collaborate well with the user. The **[handoff](../handoff/)** is
separately responsible for persisting task state.

The agent scans the conversation for durable lessons (corrections,
quietly-accepted non-obvious choices, revealed preferences, project decisions
not in version control), filters ruthlessly (anything derivable from the code,
any standard best practice, any one-off detail is dropped), and walks each
surviving candidate past the user for approval before persisting it to memory
or convention files.

## Interactivity

This skill is interactive.

## How to invoke

> Reflect on this session.

> What should you remember from this?

> Save the lessons from our work today.

## Recommended models

A mid-tier model is sufficient for this task.

## Related skills

- **[handoff](../handoff/)** is a companion skill for persisting task state
  between discrete agent sessions.
