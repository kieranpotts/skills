# Reflect

The **reflect** skill distills durable lessons from an agent session and
persists them, so that the next session starts better-informed than this one
did.

The agent scans the conversation for four signals — corrections, quietly
accepted non-obvious choices, revealed preferences, and project decisions
that are not in version control. It filters ruthlessly: anything derivable
from the code, any standard best practice, and any one-off detail is dropped.
Each surviving candidate is classified by type, which decides where it goes —
agent-private memory for working-style and project context, the project's
committed convention file for codebase rules other contributors need to see.
Nothing is written until the user approves it.

The skill captures _working-style_ continuity, ie. how to collaborate well
with this user on this project. It does not record where a task got to.

## Interactivity

This skill is interactive. The agent proposes each candidate lesson
individually — a summary, the proposed type and destination, and a draft of
the entry — and blocks on the user's answer before persisting it. It may also
prompt to establish where memory and the project's convention file live. It is
therefore not suitable for unattended or CI use.

## How to invoke

> Reflect on this session.

> What should you remember from this?

> Save the lessons from our work today.

## Recommended models

A mid-tier model is sufficient. The judgment calls — is this lesson durable,
is it already captured, is it a memory or a repository convention — are
well-bounded, and the user reviews every proposal before it lands.

## Suggested workflows

Best run at the end of a working session, once the shape of the work is
settled and any corrections have played out. Running it mid-task tends to
capture provisional decisions that later get reversed.

It pairs naturally with, but is independent of, whatever step persists task
state for the next session. Reflection is about lessons; task state is a
separate concern.

Do not run it on every session by reflex. Most sessions teach nothing durable,
and an empty result is the correct outcome.

## Related skills

- [**handoff**](../handoff/) \
  Companion skill for persisting task state between discrete agent sessions.
  Where **reflect** records what was learned, **handoff** records where the
  work got to.
