---
name: reflect
description: >-
  Distill durable lessons from the current session and persist them to the
  agent's memory or the project's committed convention file. Use at session
  end, or when the user says something like "reflect on this session", "what
  should you remember from this?", or "save the lessons from our work today".
  Do not use it to record where a task got to so work can resume later.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep
license: CC0-1.0
---

# Reflect

Extract durable lessons from the current session — corrections, validated
approaches, revealed preferences, and project decisions — and persist the
ones the user approves. Record how to work with this user on this project;
do not record task state.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification. This skill is interactive throughout: it
proposes each candidate lesson to the user and blocks on their answer before
persisting anything.

- **The current session's conversation — REQUIRED.** The source of durable
  lessons: corrections, validated approaches, revealed preferences, and
  project decisions surfaced during the work.

- **The agent's memory system, and how it is indexed — REQUIRED.** Discover
  the store and its layout from the harness rather than assuming one. Memory
  MAY be per-user, per-project, or both, and MAY keep an index file.

- **The project's committed convention file — REQUIRED.** The destination for
  codebase conventions, and a store to check against before proposing.
  Discover it rather than assuming it: it may be `AGENTS.md`, `CLAUDE.md`, a
  contributor guide, or something else. Check this session's context first,
  then the environment, then ask.

## Success criteria

- Every persisted lesson MUST be non-obvious and capable of changing a future
  agent's behavior, such that a reader of the entry can say what an agent
  would do differently because of it. Persisting nothing is a valid outcome.

- Every persisted lesson MUST have been approved by the user during the
  walk-through. Candidates the user declined, and lessons the user never saw,
  MUST NOT appear in any store.

- Entries MUST match the memory entry format given in the examples, and
  `feedback` and `project` entries MUST additionally carry a why line and a
  how-to-apply line.

- Each new memory MUST be reachable from the memory system's index, where one
  exists. An unindexed memory is invisible to future sessions.

- Saved entries MUST NOT restate a lesson already held in memory or in the
  project's convention file.

- Saved entries MUST NOT contain credentials, tokens, personal data, or
  internal-only URLs.

- Files other than the memory store, its index, and the project's convention
  file MUST NOT have been modified. Reflecting records lessons; it does not
  act on them, and it does not touch application code.

- The final report MUST state how many candidates were proposed and how many
  were persisted by type, the paths of new and updated entries, and any
  skipped candidates worth revisiting in a future session.

## Instructions

1.  Scan the conversation for non-obvious lessons.

    Walk the session looking for four signal types:

    - Corrections. The user redirected the approach: "no, don't do that",
      "we don't do it that way here", "stop doing X".

    - Validated approaches. The user accepted a non-obvious choice without
      pushback, especially where your first instinct would have been
      different. Quiet acceptance of an unusual move is a signal.

    - Revealed preferences. How the user wants to work — response length,
      tone, format, level of explanation, when to ask versus when to act.

    - Project decisions outside version control. Constraints, deadlines,
      stakeholder requirements, business context the codebase does not
      encode.

2.  Read the existing stores before proposing anything.

    Load the memory entries and the project's convention file, so that each
    candidate can be checked against what is already recorded.

3.  Filter the candidates against the drop criteria in the rules below.

4.  Classify each surviving candidate. The type drives both the entry format
    and the destination:

    - `user` — the user's role, expertise, and working preferences.
      Destination: user-level memory if it holds across projects,
      project-level memory otherwise.

    - `feedback` — guidance on how to approach work, including corrections
      and validated approaches. Destination: project-level memory, or
      user-level where it applies regardless of project.

    - `project` — facts, decisions, or constraints about ongoing work that
      are not captured in version control. Destination: project-level memory.

    - `reference` — a pointer to where information lives in an external
      system, eg. an issue tracker, a chat thread, a dashboard.
      Destination: project-level memory.

    - Codebase convention — a repository-specific rule or pattern that other
      contributors, human and agent, should see. Destination: the project's
      committed convention file, never private memory.

5.  Walk the user through the candidates, one at a time. For each, give a
    one-sentence summary, the proposed type and destination, and a draft of
    the entry as it would be written. Wait for approval before continuing.

6.  Write each approved lesson to its destination. Use the memory entry
    format from the examples, and cross-link related memories with
    `[[name]]`. For a codebase convention, append a concise rule to the
    convention file, in whichever section fits.

7.  Update the memory index, where the memory system keeps one. Add a
    one-line entry per new memory in that index's own form — typically a
    title, a link, and a short hook. The index is an index, not a memory, so
    keep entries terse.

8.  Report as described in the success criteria.

## Rules

- You MUST propose one candidate at a time and wait for the user's answer
  before moving to the next.

  Batching invites blind approval; one at a time invites scrutiny.

- You MUST filter ruthlessly. Drop a candidate if any of the following hold:

  - It is derivable from the current code, the git history, or existing
    project documentation.

  - It is a standard best practice any competent agent would follow anyway.

  - It is a one-off task detail with no reusable shape.

  - It is already captured in memory or in the convention file.

  A candidate survives only if it would meaningfully change how a fresh agent
  behaves in a future session.

- You MUST NOT manufacture lessons to justify the invocation. A session that
  taught nothing durable is common and unremarkable.

- You MUST point at external systems rather than copy them. Where a lesson
  concerns a ticket, a chat thread, or a dashboard, save a `reference` entry
  that locates it, and MUST NOT paste its content. The external system stays
  the source of truth, and pasted copies go stale silently.

- Codebase conventions MUST go to the project's committed convention file,
  not to memory.

  Memory is agent-private; the convention file is team-visible. Anything
  other contributors need to see has to be committed to the repository.

- You MUST redact aggressively. Strip API keys, tokens, real names,
  internal-only URLs, and anything else that would embarrass if leaked.

  Memory persists well beyond the session that wrote it.

- You MUST distinguish rules from facts. `feedback` and `project` entries
  carry a why line and a how-to-apply line, because stating the reason gives
  future agents room for judgment at the edges. `user` and `reference`
  entries are statements of fact and need no such scaffolding.

- You SHOULD update an existing entry rather than add a near-duplicate. Two
  entries saying nearly the same thing is worse than one saying it
  accurately.

- Entry descriptions SHOULD be specific enough that a future agent can judge
  relevance from the description alone, without opening the entry.

## Edge cases

- The session contained nothing worth saving.

  Say so explicitly and stop. Do not lower the filter to produce output.

- A candidate closely resembles an existing memory.

  Where the existing entry is stale or wrong, update it. Where the new lesson
  refines it, edit the existing entry to fold the refinement in. Create a new
  entry only when the lesson is genuinely fresh.

- A candidate contradicts an existing memory.

  Surface the contradiction during the walk-through, ask the user which
  reflects current truth, then update or delete the stale entry.

- The user disagrees with a proposed lesson.

  Drop it. The user's account of their own preferences overrides your
  inference from the conversation.

- A lesson is universal — it would hold for any user on any project.

  Flag it as a candidate for a new skill rather than saving it as a memory,
  and note it in the report. Memory is for what is particular.

- No memory system is available in this harness.

  Say so, route codebase conventions to the committed convention file as
  usual, and skip the memory destinations. List the deferred candidates in
  the report so they can be revisited.

## Examples

- The required format for a memory entry:

  ```markdown
  ---
  name: <short-kebab-case-slug>
  description: <one-line summary, specific enough to judge relevance from>
  metadata:
    type: <user | feedback | project | reference>
  ---

  <Lesson content.>

  <For `feedback` and `project` types, follow with:>

  **Why:** <The past incident, preference, or constraint that makes this
  matter.>

  **How to apply:** <When and where this guidance kicks in.>
  ```
