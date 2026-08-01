---
name: handoff
description: >-
  Compact a conversation for the next session to pick up. Use when ending a
  session, switching agents, approaching context limits, or pausing work that
  someone else will resume, or when the user says something like "hand this
  off to the next session", "write up where we've got to", or "I'm going to
  bed now, see you tomorrow".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/PROSE_STANDARD
---

# Handoff

Compact the current conversation into a handoff document, so a fresh agent or
human can pick up the work. Save the handoff document outside the project, such
as to the operating system's temporary file path. Reference existing documents
such as PRDs and delivery plans, without replicating them.

You MUST NOT make any code or configuration changes to any software
components.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **The current session's context — REQUIRED.** The work done, the decisions
  made, the durable artifacts already produced (specifications, designs,
  plans, ADRs, issues, commits), and the state of the codebase.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- A single, ephemeral handoff document written to the OS temp directory (not
  the repo), referencing those durable artifacts by path or URL rather than
  duplicating them.

- It captures what's done, what's open, the codebase state, suggested next
  steps, and gotchas. This skill reports the file's absolute path and stops;
  whether the next session is an agent or a human is the orchestrator's
  concern.

- The handoff MUST live outside the repo.

  Written to a temp-directory path, not the project tree.

- The handoff MUST use the following structure, omitting any section that
  has nothing to report:

  - `# Handoff: <topic> (<date>)`
  - `## What's been done` — summary of decisions and completed work.
  - `## What's open` — outstanding questions and blockers.
  - `## State of the codebase` — branch, working-tree status, known
    test failures, temporary instrumentation.
  - `## Suggested next steps` — the work the next session should pick
    up.
  - `## Watch out for` — gotchas, environmental quirks, explored dead
    ends.

- The handoff MUST reference every durable artifact by path or URL, and
  MUST NOT paste artifact content.

- The handoff MUST NOT contain credentials, PII, or internal-only URLs.

- Outstanding questions MUST be stated specifically, with their blockers
  named.

- The next session MUST be able to read the handoff alone and know what to
  do next.

- If there was nothing substantive to hand off, the output MUST say so
  explicitly rather than produce a fabricated document.

## Instructions

1.  Identify what the next session needs to know.

    If the user passed an argument describing the next session's focus
    (eg. "next session continues with the API integration"), use it to
    scope the handoff. Otherwise, treat the handoff as covering the full
    state of the current work.

    Ask yourself: if this conversation vanished now, what would a fresh
    agent need in order to not repeat the work, not re-litigate decisions,
    and not re-walk dead ends?

2.  Inventory existing artifacts.

    Before writing anything, list the durable artifacts the current work
    has already produced:

    - The specification / PRD and its path or URL.
    - The design document or chosen ADR.
    - The plan, with which steps are done and which are open.
    - Issue / ticket references.
    - PR or branch references.
    - Recent commits worth pointing at.
    - Any updated entries in the project's glossary.

3.  Draft the document.

    Write the handoff using the structure defined in the Success criteria.

    If the handoff is for a human rather than an agent, replace "Suggested
    next steps" with "Suggested first action" and describe the concrete
    next step the human should take.

4.  Redact sensitive information.

    Before writing the file, strip:

    - API keys, tokens, passwords, secrets of any kind.
    - Personally identifiable information (real names, emails, IDs,
      addresses).
    - Internal-only URLs or hostnames.

    If in doubt, redact.

5.  Save to a temporary location.

    Write to the OS temp directory:

    - macOS / Linux: `$TMPDIR/handoff-<topic>-<timestamp>.md` (fall back
      to `/tmp`).
    - Windows: `%TEMP%\handoff-<topic>-<timestamp>.md`.

6.  Tell the user the absolute path.

    Print the full absolute path.

7.  Handle an imminent context limit.

    If the context limit is imminent, write the handoff immediately, even
    if other work was mid-flight.

8.  Handle parallel work streams.

    If the session covered two unrelated streams of work, write one
    handoff per stream.

9.  Handle an empty handoff.

    If the user provided no topic and the conversation covered nothing
    substantive, say so and stop. Do not write a fabricated handoff
    document.

10. Handle unconfirmed decisions.

    If the handoff would contain a partial decision the user has not
    confirmed, mark it explicitly as unconfirmed in "What's open", not in
    "What's been done".

## Rules

- You MUST reference, not duplicate.

  Every fact already captured in a specification, plan, ADR, issue, commit,
  or diff MUST be referenced by path or URL. Duplication invites drift.

- The handoff is ephemeral.

  It MUST live outside the repo, and MUST be discarded once the next
  session has absorbed it. If a piece of the handoff turns out to be
  durable, you MUST promote it to the relevant project artifact (ADR,
  specification update, runbook) and remove it from the handoff.

- You MUST be specific about what's open.

  "Some questions remain about the API" is unhelpful. "Two questions
  remain on the API: (1) idempotency behavior on retry; (2) whether to
  accept partial updates — both blocked on product input" is actionable.

- You SHOULD suggest next steps, and MUST NOT dictate them.

  Name the work relevant to the road ahead, but the next session decides
  what to do. You MUST NOT pretend to know what the next session will
  encounter.

- You MUST redact aggressively.

  Anything that looks remotely like a credential, real identity, or
  internal URL MUST be removed. The bar is: "could this embarrass anyone
  if pasted into a public channel?"

- You MUST NOT fabricate state to fill the template.

  If a section has nothing to say, you MUST omit it or write "none"
  explicitly. An empty section is honest; an invented one is misleading.

## Examples

- A compact handoff:

  ```md
  # Handoff: orders POST endpoint (2026-05-26)

  ## What's been done
  Short summary of decisions made and work completed this session.
  Reference artifacts by path/URL; do not paste their content.

  ## What's open
  Outstanding questions, decisions deferred, work in progress.
  Be specific about what is undecided and why.

  ## State of the codebase
  Current branch, working-tree status, any tests known failing, any
  temporary instrumentation in place.

  ## Suggested next steps
  The work the next session should pick up — eg. decomposition if
  the plan is incomplete, implementation if the design is settled,
  diagnosis if a test is failing. Name the specific step if known,
  and any tool or skill suited to it.

  ## Watch out for
  Gotchas, environmental quirks, decisions that look obvious but
  weren't, dead-ends already explored that should not be re-tried.
  ```

## References

None.
