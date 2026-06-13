# `/reflect`

Extract durable lessons from the current session – corrections, validated approaches, revealed preferences, project decisions outside the code – and persist them to the agent's memory or to repo-committed convention files. Use at session end to make future sessions start smarter.

## What it does

`/reflect` distills *working-style* continuity – how to collaborate well with this user, in this codebase – as distinct from task state (which belongs in a handoff document). It scans the conversation for four signals (corrections, quietly-accepted non-obvious choices, revealed preferences, project decisions not encoded in version control), then **filters ruthlessly**: anything derivable from the code/git/docs, any standard best practice, any one-off detail, anything already captured is dropped. Each surviving candidate is classified (`user` / `feedback` / `project` / `reference`, or a codebase convention bound for `AGENTS.md`/`CLAUDE.md`) and walked past the user one at a time for approval before anything is written. Saved memories get the right format (with `Why:` / `How to apply:` for feedback and project types), cross-links, a `MEMORY.md` index entry, and aggressive redaction.

It is interactive – one candidate at a time, no batching – because batching invites blind approval. It updates rather than duplicates near-matches, surfaces contradictions with existing memories, and says so plainly when a session contained nothing worth saving.

## How to invoke

```
/reflect
```

Invoke it at the end of a session. With no argument it scans the whole conversation; expect a per-candidate walk-through, then a short report of what was saved, by type.

## Examples

After a session where the user said "we don't open PRs against `test` here, only `dev`", `/reflect` proposes a `feedback` memory – with the why (the trunk model) and how-to-apply (when choosing a PR base) – shows the draft, and asks: save, edit, change destination, or skip? On approval it writes the file and indexes it in `MEMORY.md`.

If a candidate is really a repository-wide rule other contributors need, it routes it to `AGENTS.md` instead of private memory; if the session yielded nothing durable, it reports "No durable lessons in this session" rather than manufacturing one.
