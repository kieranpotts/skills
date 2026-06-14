# 🧑 `/reflect`

Distill durable lessons from the session into memory and convention files – corrections, validated approaches, revealed preferences, project decisions outside the code. Interactive (🧑): it walks each candidate lesson past the user for approval before saving. Companion to [`/handoff`](../handoff/). Use at session end to make future sessions start smarter.

## What it does

`/reflect` distills *working-style* continuity – how to collaborate well with this user, in this codebase – as distinct from task state (which belongs in a handoff document). It scans the conversation for durable lessons (corrections, quietly-accepted non-obvious choices, revealed preferences, project decisions not in version control), filters ruthlessly (anything derivable from the code, any standard best practice, any one-off detail is dropped), and walks each surviving candidate past the user for approval before persisting it to memory or convention files.

It is interactive – one candidate at a time, no batching – because batching invites blind approval. It says so plainly when a session contained nothing worth saving.

## How to invoke

Invoke it at the end of a session. With no argument it scans the whole conversation; expect a per-candidate walk-through, then a short report of what was saved.

- `/reflect`, `/skill:reflect` (prompt varies by agent harness).
- "Reflect on this session."
- "What should you remember from this?"
- "Save the lessons from our work today."
