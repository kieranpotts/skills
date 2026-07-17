---
name: handoff
description: >-
  Compact the current conversation into a handoff document so a fresh agent or
  sapien can pick up the work. Save it outside the project (the OS temp
  directory) and reference existing artifacts (PRDs, plans, ADRs, issues,
  commits) rather than duplicating them. Use when ending a session, switching
  agents, approaching context limits, or pausing work that someone else will
  resume, or when the user says "hand this off to the next session" or "write up
  where we got to before I stop".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-writer
---

# Handoff

**Input:**

- **The current session's context. REQUIRED.** The work done, the decisions
  made, the durable artifacts already produced (specifications, designs, plans,
  ADRs, issues, commits), and the state of the codebase.

This skill is non-interactive: agents MUST NOT block for user input after the
initial prompt, and MUST follow the instructions to completion or fail with an
error message.

**Output:** A single, ephemeral handoff document written to the OS temp
  directory (not the repo), referencing those durable artifacts by path or URL
  rather than duplicating them. It captures what's done, what's open, the codebase
  state, suggested next steps, and gotchas. This skill reports the file's absolute
  path and stops; whether the next session is an agent or a human is the
  orchestrator's concern.

## Instructions

1.  **Identify what the next session needs to know.**
    If the user passed an argument describing the next session's focus (eg.
    "next session continues with the API integration"), you MUST use it to scope
    the handoff. Otherwise, you MUST treat the handoff as covering the full state
    of the current work.

    You SHOULD ask yourself: if this conversation vanished now, what would a
    fresh agent need in order to *not* repeat the work, *not* re-litigate
    decisions, and *not* re-walk dead ends?

2.  **Inventory existing artifacts.**
    Before writing anything, you MUST list the durable artifacts the current work
    has already produced:

    - The specification / PRD and its path or URL.
    - The design document or chosen ADR.
    - The plan, with which steps are done and which are open.
    - Issue / ticket references.
    - PR or branch references.
    - Recent commits worth pointing at.
    - Any updated entries in `docs/domain-model.md`.

3.  **Draft the document.**
    You MUST write the handoff using the structure defined in the Success
    criteria.

    If the handoff is for a human rather than an agent, you MUST replace
    "Suggested next steps" with "Suggested first action" and describe the
    concrete next step the human should take.

4.  **Redact sensitive information.**
    Before writing the file, you MUST strip:

    - API keys, tokens, passwords, secrets of any kind.
    - Personally identifiable information (real names, emails, IDs, addresses).
    - Internal-only URLs or hostnames.

    If in doubt, you MUST redact.

5.  **Save to a temporary location.**
    You MUST write to the OS temp directory:

    - macOS / Linux: `$TMPDIR/handoff-<topic>-<timestamp>.md` (fall back to
      `/tmp`).
    - Windows: `%TEMP%\handoff-<topic>-<timestamp>.md`.

6.  **Tell the user the absolute path.**
    You MUST print the full absolute path.

7.  **Handle an imminent context limit.**
    If the context limit is imminent, you MUST write the handoff immediately,
    even if other work was mid-flight.

8.  **Handle parallel work streams.**
    If the session covered two unrelated streams of work, you SHOULD write one
    handoff per stream.

9.  **Handle an empty handoff.**
    If the user provided no topic and the conversation covered nothing
    substantive, you MUST say so and stop. You MUST NOT write a fabricated
    handoff document.

10. **Handle unconfirmed decisions.**

    If the handoff would contain a partial decision the user has not confirmed,
    you MUST mark it explicitly as unconfirmed in "What's open", not in "What's
    been done".

## Rules

- **You MUST reference, not duplicate.**
  Every fact already captured in a specification, plan, ADR, issue, commit, or
  diff MUST be referenced by path or URL. Duplication invites drift.

- **The handoff is ephemeral.**
  It MUST live outside the repo, and MUST be discarded once the next session
  has absorbed it. If a piece of the handoff turns out to be durable, you MUST
  promote it to the relevant project artifact (ADR, specification update,
  runbook) and remove it from the handoff.

- **You MUST be specific about what's open.**
  "Some questions remain about the API" is unhelpful. "Two questions remain on
  the API: (1) idempotency behavior on retry; (2) whether to accept partial
  updates — both blocked on product input" is actionable.

- **You SHOULD suggest next steps, and MUST NOT dictate them.**
  Name the work relevant to the road ahead, but the next session decides what
  to do. You MUST NOT pretend to know what the next session will encounter.

- **You MUST redact aggressively.**
  Anything that looks remotely like a credential, real identity, or internal
  URL MUST be removed. The bar is: "could this embarrass anyone if pasted into
  a public channel?"

- **You MUST NOT fabricate state to fill the template.**
  If a section has nothing to say, you MUST omit it or write "none" explicitly.
  An empty section is honest; an invented one is misleading.

## Success criteria

- **The handoff MUST live outside the repo.**
  Written to a temp-directory path, not the project tree.

- **The handoff MUST use the following structure, omitting any section that has
  nothing to report:**

  - `# Handoff: <topic> (<date>)`
  - `## What's been done` — summary of decisions and completed work.
  - `## What's open` — outstanding questions and blockers.
  - `## State of the codebase` — branch, working-tree status, known test
    failures, temporary instrumentation.
  - `## Suggested next steps` — the work the next session should pick up.
  - `## Watch out for` — gotchas, environmental quirks, explored dead ends.

- **The handoff MUST reference every durable artifact by path or URL, and MUST
  NOT paste artifact content.**

- **The handoff MUST NOT contain credentials, PII, or internal-only URLs.**

- **Outstanding questions MUST be stated specifically, with their blockers
  named.**

- **The next session MUST be able to read the handoff alone and know what to do
  next.**

- **If there was nothing substantive to hand off, the output MUST say so
  explicitly rather than produce a fabricated document.**

## Examples

- **A compact handoff:**

  ```md
  # Handoff: orders POST endpoint (2026-05-26)

  ## What's been done
  Short summary of decisions made and work completed this session.
  Reference artifacts by path/URL; do not paste their content.

  ## What's open
  Outstanding questions, decisions deferred, work in progress.
  Be specific about *what* is undecided and *why*.

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
