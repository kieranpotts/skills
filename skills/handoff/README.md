# Handoff

The **handoff** skill is all about compacting a conversation for the next
session to pick up.

The agent is instructed to compact a conversation into an ephemeral handoff
document so a fresh agent or human can resume the work. The document should
capture just enough state to continue, removing issues that have been resolved
and decisions that have been made.

The agent is instructed to write the handoff document to the OS temp directory.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Hand this off to the next session.

> Write up where we've got to.

> I'm going to bed now, see you tomorrow.

## Recommended models

A mid-tier model is sufficient for this task.

## Related skills

- **[reflect](../reflect/).** Companion skill that distills durable lessons
  from an agent session, while this skill persists task state.

## References

- This skill is adapted from
  [Matt Pocock's `handoff` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md).
