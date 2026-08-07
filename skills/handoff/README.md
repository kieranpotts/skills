# Handoff

The handoff skill compacts a session so the next one can pick up the work.

The agent is instructed to write a single, ephemeral handoff document covering
what was done, what remains open, the state of the codebase, suggested next
steps, and any gotchas. Durable artifacts — specifications, designs, plans,
issues, commits — are referenced rather than copied, so the handoff cannot
drift from them. Anything that turns out to be durable is promoted into the
project's own artifacts instead.

The document is written outside the project tree, to the OS temp directory by
default, because it is disposable and should never be committed. The agent
reports its absolute path and stops there.

## Interactivity

This skill instructs the agent to run non-interactively. It never blocks for
user input, so it is safe in away-from-keyboard and unattended workflows. If
it cannot determine what it needs, it stops with an error rather than asking.

## How to invoke

> Hand this off to the next session.

> Write up where we've got to.

> I'm going to bed now, see you tomorrow.

An optional argument scopes the handoff to what the next session will work on,
eg. "hand off — next session continues with the API integration". Without one,
the handoff covers the full state of the current work.

## Recommended models

A mid-tier model is sufficient. The task is summarization over context the
agent already holds, not open-ended analysis.

## Related skills

- [**reflect**](../reflect/) \
  Companion skill that distills durable lessons from an agent session, while
  this skill persists task state for the next one.

## References

- This skill is adapted from
  [Matt Pocock's `handoff` skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md).
