---
name: handoff
description: >-
  Compact the state of the current session into an ephemeral handoff document
  that a fresh agent or human can resume from. Use when ending a session,
  switching agents, approaching a context limit, or pausing work someone else
  will pick up, or when the user says something like "hand this off to the
  next session", "write up where we've got to", or "I'm going to bed now, see
  you tomorrow". Do not use it to record durable lessons or decisions, which
  belong in the project's own artifacts.
compatibility: >-
  requires Read, Write, Glob, Grep, Bash (git status, git log)
license: CC0-1.0
---

# Handoff

Compact the current session into a single handoff document, so a fresh agent
or human can pick up the work without repeating it. Reference the durable
artifacts the work has already produced, rather than replicating them.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message.

- **The current session's context — REQUIRED.** The work done, the decisions
  made, the durable artifacts already produced, and the state of the codebase.

- **Scope — OPTIONAL.** A description of what the next session will focus on,
  eg. "next session continues with the API integration". Where the user gives
  none, cover the full state of the current work.

- **Output location — OPTIONAL.** Where to write the handoff. Take it from the
  user's instruction if given, else from the environment — `TMPDIR` or `TEMP`,
  falling back to `/tmp`. It MUST resolve outside the project tree, because
  the handoff is disposable and MUST NOT be committed.

## Success criteria

- One handoff document MUST exist at a path outside the project tree, and its
  absolute path MUST have been reported to the user.

- The document MUST carry the sections shown under Examples, omitting any
  section with nothing to report.

- Every durable artifact the work produced — specifications, designs, plans,
  decision records, issues, branches, pull requests, commits — MUST be
  identified by path, reference, or URL.

- The document MUST NOT contain credentials, personally identifying
  information, or internal-only hostnames and URLs.

- A reader with no access to this session MUST be able to act on the document
  alone.

- No file in the project MUST have changed. Writing a handoff is a reporting
  task, and MUST NOT touch code, configuration, or documentation.

## Instructions

1.  Scope the handoff.

    Ask yourself: if this conversation vanished now, what would a fresh reader
    need in order to not repeat the work, not re-litigate settled decisions,
    and not re-walk dead ends? Where the user named a focus for the next
    session, narrow to what serves it.

2.  Inventory the durable artifacts the work has produced.

    List them before writing anything: the requirements or specification, the
    design or decision record, the plan and which of its steps are done, issue
    references, branch and pull request references, commits worth pointing at,
    and any glossary or documentation entries touched. Where the session
    context does not settle an artifact's location, you MAY search the
    workspace for it rather than guessing.

3.  Establish the state of the codebase.

    Read the current branch, the working-tree status, and recent commits, so
    the next session is not surprised by uncommitted or in-flight work. Note
    any known test failures and any temporary instrumentation left behind.

4.  Draft the document, following the structure under Examples.

5.  Redact before writing.

    Strip API keys, tokens, passwords, and secrets of any kind; personally
    identifying information such as real names, email addresses, and postal
    addresses; and internal-only URLs or hostnames. Where in doubt, redact.

6.  Write the file, naming it so it is recognizable later, eg.
    `handoff-<topic>-<timestamp>.md`, then report its absolute path and stop.

## Rules

- The handoff MUST be ephemeral.

  It exists to carry state across a session boundary and is discarded once
  the next session has absorbed it. Anything in it that turns out to be
  durable — a decision, a constraint, an operational gotcha — SHOULD be
  promoted to the relevant project artifact instead, and dropped from the
  handoff. Duplicating what an artifact already records invites drift.

- You MUST be specific about what is open.

  "Some questions remain about the API" is unhelpful. "Two questions remain
  on the API: (1) idempotency behavior on retry; (2) whether to accept partial
  updates — both blocked on product input" is actionable. Name the blocker for
  each open question.

- You SHOULD suggest next steps, and MUST NOT dictate them.

  Name the work that looks relevant to the road ahead, but leave the choice to
  the next session, which will have context this one does not.

- You MUST NOT fabricate state to fill out the structure.

  An omitted section is honest; an invented one misleads the reader into
  trusting work that was never done.

- Write for either audience.

  Whether the next session is an agent or a human is the caller's concern, not
  yours, so the document SHOULD read equally well to both.

## Edge cases

- A context limit is imminent.

  Write the handoff immediately, even with other work mid-flight, and record
  what was interrupted under what is open.

- The session covered two or more unrelated streams of work.

  Write one handoff per stream, and report each path. A single document
  covering unrelated work forces the next reader to untangle it.

- A decision was reached but never confirmed by the user.

  Record it under what is open, marked explicitly as unconfirmed. Recording it
  as done would let the next session build on a decision nobody made.

- The session covered nothing substantive, and the user named no topic.

  Say so and stop. Do not write a document.

- The handoff is explicitly for a human rather than an agent.

  Replace the suggested next steps section with a single concrete first
  action for them to take.

## Examples

- The document structure:

  ```md
  # Handoff: orders POST endpoint (2026-05-26)

  ## What's been done
  Decisions made and work completed this session. Reference artifacts by
  path or URL; do not paste their content.

  ## What's open
  Outstanding questions, deferred decisions, work in progress, each with
  its blocker named.

  ## State of the codebase
  Current branch, working-tree status, tests known to be failing, any
  temporary instrumentation still in place.

  ## Suggested next steps
  The work the next session could pick up — eg. decomposition if the plan
  is incomplete, implementation if the design is settled, diagnosis if a
  test is failing.

  ## Watch out for
  Gotchas, environmental quirks, decisions that look obvious but weren't,
  dead ends already explored that should not be re-tried.
  ```
