---
name: reflect
description: >-
  Extract durable lessons from the current session — corrections, validated
  approaches, revealed preferences, project decisions outside the code — and
  persist them to the agent's memory system or to repo-committed convention
  files (AGENTS.md / CLAUDE.md). Use at session end to make future sessions
  start smarter, or when the user says "reflect on this session", "what should
  you remember from this?", or "save the lessons from our work today".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/technical-writer
---

# Reflect

**Input:**

- **The current session's conversation. REQUIRED.** The source of durable
  lessons — corrections, validated approaches, revealed preferences, and
  project decisions surfaced during the work.

- **The agent's existing memory files. REQUIRED.** Checked so new lessons update
  or extend prior entries rather than duplicating them.

- **The repo's convention files. REQUIRED.** `AGENTS.md` / `CLAUDE.md`, the
  destination for codebase conventions and a source to check against before
  proposing.

Seek per-candidate approval from the user, prompting before persisting.

**Output:**

Zero or more persisted lessons — memory entries (indexed in
`MEMORY.md`) and/or appended convention rules — each non-obvious and capable of
changing future agent behavior, written only after per-candidate user approval.
Universal lessons better encoded as a new skill are flagged, not saved.

## Instructions

1.  **Scan the conversation for non-obvious lessons.**

    You MUST walk the session looking for four signal types:

    - **Corrections.** The user redirected the approach: *"no, don't do that"*,
      *"we don't do it that way here"*, *"stop doing X"*. Each correction is a
      candidate.

    - **Validated approaches.** The user accepted a non-obvious choice without
      pushback, especially where your first instinct would have been different.
      Quiet acceptance of an unusual move is a signal.

    - **Revealed preferences.** How the user wants to work — response length,
      tone, format, levels of explanation, when to ask vs. when to act.

    - **Project decisions outside version control.** Constraints, deadlines,
      stakeholder requirements, business context the codebase does not encode.

2.  **Filter the candidates.**

    You MUST evaluate each candidate against the drop criteria in the Rules
    section.

3.  **Classify each surviving candidate.**

    You MUST assign one of these types — the type drives the format and the
    destination:

    - **`user`** — The user's role, expertise, working preferences.
      *Destination: user-level memory if universal across projects;
      project-level memory if specific to this project.*

    - **`feedback`** — Guidance on how to approach work. Corrections and
      validated approaches both fit here. *Destination: project-level memory
      (usually); user-level if it applies regardless of project.*

    - **`project`** — Facts, decisions, or constraints about ongoing work that
      aren't captured in version control. *Destination: project-level memory.*

    - **`reference`** — Pointers to where information lives in external systems
      (Linear, Slack, Confluence, dashboards). *Destination: project-level
      memory.*

    - **Codebase convention** — A repository-specific rule or pattern other
      contributors (human and agent) should see. *Destination: AGENTS.md or
      CLAUDE.md — committed to the repo, not private memory.*

4.  **Walk the user through each candidate.**

    You MUST follow the one-at-a-time procedure in the Rules section. For each
    candidate, you MUST present a one-sentence summary, the proposed type and
    destination, and a draft of the entry as it would be written. You MUST ask
    for approval before persisting.

5.  **Write each accepted lesson.**

    For memory destinations, you MUST use the format defined in the Success
    criteria.

    You SHOULD cross-link related memories with `[[name]]`.

    For codebase-convention destinations, you MUST append a concise rule to `AGENTS.md`
    (or `CLAUDE.md`, whichever the project uses) in the section that fits —
    usually `## Rules` or a project-specific equivalent.

6.  **Update the `MEMORY.md` index.**

    For each new memory file, you MUST add a one-line entry:

    ```
    - [Title](file.md) — one-line hook
    ```

    `MEMORY.md` is an index, not a memory. You SHOULD keep entries terse.

7.  **Handle duplicates and contradictions during the walk-through.**

    If a candidate is close to an existing memory:

    - If the existing entry is stale or wrong, you SHOULD *update* it instead of
      creating a new one.

    - If the new lesson refines an existing one, you SHOULD edit the existing
      entry to incorporate the refinement.

    - You SHOULD only create a new file when the lesson is genuinely fresh.

    If a candidate *contradicts* an existing memory, you MUST surface the
    contradiction in the walk-through. You MUST ask the user which reflects
    current truth, then update or delete the stale entry.

8.  **Report briefly.**

    Once the walk-through is complete, you MUST print the report described in the
    Success criteria.

## Rules

- **You MUST walk one candidate at a time.**

  Walk through proposals individually. Batching invites blind approval;
  one-at-a-time invites scrutiny. Wait for the user's answer before moving on.

- **You MUST filter ruthlessly.**

  Drop a candidate if any of the following apply:

  - It is derivable from the current code, git history, or existing project
    docs.

  - It is a standard best practice any reasonable agent would follow.

  - It is a one-off task detail with no reusable shape.

  - It is already captured in an existing memory file or convention doc. Check
    existing memories AND `AGENTS.md` / `CLAUDE.md` before proposing.

  A candidate survives if it would meaningfully change how a *fresh* agent
  behaves on a *future* session.

- **You MUST reference external systems, not duplicate them.**

  If the lesson is about a Linear ticket, Slack thread, or external dashboard,
  you MUST save a `reference` memory that points at it — you MUST NOT paste its
  content. The external system is the source of truth.

- **Codebase conventions MUST go to AGENTS.md / CLAUDE.md, not memory.**

  Things other contributors need to see MUST be committed to the repo. Memory
  files are agent-private; committed convention files are team-visible. Pick
  the right destination.

- **You MUST redact aggressively.**

  Memory persists. You MUST strip API keys, tokens, real names, internal-only
  URLs, and anything else that would embarrass if leaked.

- **You MUST distinguish rules from facts.**

  `feedback` (how to work) and `project` (what's true now) MUST carry the
  **Why:** + **How to apply:** structure — their reason gives future agents room
  for judgment on edge cases. `user` and `reference` types are statements of
  fact and need no such scaffolding.

- **You SHOULD update rather than duplicate.**

  A new lesson close to an existing memory SHOULD usually edit the existing
  entry, not create a sibling. Two entries saying nearly-the-same thing is
  worse than one entry saying it accurately.

- **If the session contained nothing worth saving, you MUST say so explicitly
  and stop.**

  Do not manufacture lessons to justify the invocation.

- **If the user disagrees with a proposed lesson, you MUST drop it.**

  The user's view of their own preferences trumps your inference from the
  conversation.

- **If a lesson is genuinely universal, you MUST flag it as a candidate for a
  new skill rather than save it as memory.**

  Lessons that apply regardless of user / project belong in a skill, not a
  memory entry.

- **If the agent's memory system has no obvious file path, you MUST fall back
  to `AGENTS.md` for codebase conventions and skip the memory-file steps for
  `user` / `feedback` / `project` / `reference` types.**

  Flag the deferred candidates in the final report.

## Success criteria

- **Every saved lesson MUST be non-obvious and MUST change future agent
  behavior.**

  A reader of the entry can identify what you would do *differently* because
  of it.

- **Each `feedback` and `project` entry MUST have both a Why: and a How to apply:
  line.**

- **Every new memory file MUST be indexed in `MEMORY.md`.**

  An unindexed memory file is invisible to future sessions.

- **No saved lesson MUST duplicate an existing memory or convention doc entry.**

- **No credentials, PII, or internal URLs MUST appear in any saved entry.**

- **Memory entries MUST follow the required format.**

  ```markdown
  ---
  name: <short-kebab-case-slug>
  description: <one-line summary — specific, used by future agents to decide relevance>
  metadata:
    type: <user | feedback | project | reference>
  ---

  <Lesson content.>

  <For `feedback` and `project` types, follow with:>

  **Why:** <The reason — the past incident, preference, or constraint that makes this matter.>

  **How to apply:** <When and where this guidance kicks in.>
  ```

- **The final report MUST state how many candidates were proposed and how many
  were saved (by type), the paths/filenames of new and updated entries, and any
  skipped candidates worth revisiting in a future session.**
