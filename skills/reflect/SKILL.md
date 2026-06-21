---
name: reflect
description: Extract durable lessons from the current session – corrections, validated approaches, revealed preferences, project decisions outside the code – and persist them to the agent's memory system or to repo-committed convention files (AGENTS.md / CLAUDE.md). Use at session end to make future sessions start smarter, or when the user says "reflect on this session", "what should you remember from this?", or "save the lessons from our work today".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: qwen3.5:27b
---

# `/reflect`

Use this skill at the end of a session to distill what was *learned* about working with the user, in this codebase, or on this project – durable working-style lessons, not task progress. Output is persistent: file-based memory entries the agent reads on future sessions, and/or additions to repo-committed convention files.

**Input**: The current session's conversation, the agent's existing memory files, and the repo's convention files (AGENTS.md / CLAUDE.md). REQUIRED. This skill is **interactive**: it seeks per-candidate user approval through prompts before persisting anything.

**Output**: Zero or more persisted lessons – memory entries (indexed in `MEMORY.md`) and/or appended convention rules – each non-obvious and capable of changing future agent behavior, written only after per-candidate user approval. Universal lessons better encoded as a new skill are flagged, not saved.

##  Instructions

1.  **Scan the conversation for non-obvious lessons.**

    Walk the session looking for four signal types:

    - **Corrections.** The user redirected the approach: *"no, don't do that"*, *"we don't do it that way here"*, *"stop doing X"*. Each correction is a candidate.
    - **Validated approaches.** The user accepted a non-obvious choice without pushback, especially where your first instinct would have been different. Quiet acceptance of an unusual move is a signal.
    - **Revealed preferences.** How the user wants to work – response length, tone, format, levels of explanation, when to ask vs. when to act.
    - **Project decisions outside version control.** Constraints, deadlines, stakeholder requirements, business context the codebase does not encode.

2.  **Filter ruthlessly.**

    Drop a candidate if any of the following apply:

    - It is derivable from the current code, git history, or existing project docs.
    - It is a standard best practice any reasonable agent would follow.
    - It is a one-off task detail with no reusable shape.
    - It is already captured in an existing memory file or convention doc. Check existing memories AND `AGENTS.md` / `CLAUDE.md` before proposing.

    A candidate survives if it would meaningfully change how a *fresh* agent behaves on a *future* session.

3.  **Classify each surviving candidate.**

    Assign one of these types – the type drives the format and the destination:

    - **`user`** – The user's role, expertise, working preferences. *Destination: user-level memory if universal across projects; project-level memory if specific to this project.*
    - **`feedback`** – Guidance on how to approach work. Corrections and validated approaches both fit here. *Destination: project-level memory (usually); user-level if it applies regardless of project.*
    - **`project`** – Facts, decisions, or constraints about ongoing work that aren't captured in version control. *Destination: project-level memory.*
    - **`reference`** – Pointers to where information lives in external systems (Linear, Slack, Confluence, dashboards). *Destination: project-level memory.*
    - **Codebase convention** – A repository-specific rule or pattern other contributors (human and agent) should see. *Destination: AGENTS.md or CLAUDE.md – committed to the repo, not private memory.*

4.  **Walk the user through each candidate, one at a time.**

    For each candidate, present:

    - A one-sentence summary of the lesson.
    - The proposed type and destination.
    - A draft of the entry as it would be written.

    Ask: *"Save as proposed, edit, change the destination, or skip?"*

    Wait for the answer before moving on. Do NOT batch.

5.  **Write each accepted lesson.**

    For memory destinations, use this format:

    ```markdown
    ---
    name: <short-kebab-case-slug>
    description: <one-line summary – specific, used by future agents to decide relevance>
    metadata:
      type: <user | feedback | project | reference>
    ---

    <Lesson content.>

    <For `feedback` and `project` types, follow with:>

    **Why:** <The reason – the past incident, preference, or constraint that makes this matter.>

    **How to apply:** <When and where this guidance kicks in.>
    ```

    Cross-link related memories with `[[name]]`.

    For codebase-convention destinations, append a concise rule to `AGENTS.md` (or `CLAUDE.md`, whichever the project uses) in the section that fits – usually `## Rules` or a project-specific equivalent.

6.  **Update the `MEMORY.md` index.**

    For each new memory file, add a one-line entry:

    ```
    - [Title](file.md) — one-line hook
    ```

    `MEMORY.md` is an index, not a memory. Keep entries terse.

7.  **Handle duplicates and contradictions during the walk-through.**

    If a candidate is close to an existing memory:

    - If the existing entry is stale or wrong, *update* it instead of creating a new one.
    - If the new lesson refines an existing one, edit the existing entry to incorporate the refinement.
    - Only create a new file when the lesson is genuinely fresh.

    If a candidate *contradicts* an existing memory, surface the contradiction in the walk-through. Ask the user which reflects current truth, then update or delete the stale entry.

8.  **Report briefly.**

    Once the walk-through is complete, print:

    - How many candidates were proposed and how many were saved (by type).
    - Paths/filenames of new and updated entries.
    - Any skipped candidates worth revisiting in a future session.

    Keep the report to ~5 lines.

##  Rules

-   **One candidate at a time.**

    Walk through proposals individually. Batching invites blind approval; one-at-a-time invites scrutiny.

-   **Filter ruthlessly.**

    A memory entry that doesn't change future agent behavior is clutter. Better to surface ten candidates and save two than to save ten that dilute the signal.

-   **Reference external systems; don't duplicate them.**

    If the lesson is about a Linear ticket, Slack thread, or external dashboard, save a `reference` memory that points at it – do not paste its content. The external system is the source of truth.

-   **Codebase conventions go to AGENTS.md / CLAUDE.md, not memory.**

    Things other contributors need to see are committed to the repo. Memory files are agent-private; committed convention files are team-visible. Pick the right destination.

-   **Redact aggressively.**

    Memory persists. Strip API keys, tokens, real names, internal-only URLs, and anything else that would embarrass if leaked.

-   **Distinguish rules from facts.**

    `feedback` (how to work) and `project` (what's true now) need the **Why:** + **How to apply:** structure – their reason gives future agents room for judgment on edge cases. `user` and `reference` types are statements of fact and need no such scaffolding.

-   **Update rather than duplicate.**

    A new lesson close to an existing memory should usually edit the existing entry, not create a sibling. Two entries saying nearly-the-same thing is worse than one entry saying it accurately.

##  Edge cases

-   **The session contained nothing worth saving.**

    Say so explicitly and stop. Do NOT manufacture lessons to justify the invocation. *"No durable lessons in this session"* is the right output when it's the right output.

-   **The user disagrees with a proposed lesson.**

    Drop it. The user's view of their own preferences trumps your inference from the conversation.

-   **The lesson is genuinely universal (about a tool's behavior, not the user or project).**

    Lessons that apply regardless of user / project may belong in a *skill*, not a memory entry. Flag them in the final report as candidates for authoring into a new skill, but do not save them as memory.

-   **The agent's memory system has no obvious file path.**

    Some agents (Cursor, Copilot) do not expose a standard memory directory. In that case, fall back to `AGENTS.md` for codebase conventions and skip the memory-file steps for `user` / `feedback` / `project` / `reference` types – flag them in the report as deferred.

##  Success criteria

-   **Every saved lesson is non-obvious and would change future agent behavior.**

    A reader of the entry can identify what you would do *differently* because of it.

-   **Each `feedback` and `project` entry has both a Why: and a How to apply: line.**

-   **Every new memory file is indexed in `MEMORY.md`.**

    An unindexed memory file is invisible to future sessions.

-   **No saved lesson duplicates an existing memory or convention doc entry.**

-   **No credentials, PII, or internal URLs appear in any saved entry.**
