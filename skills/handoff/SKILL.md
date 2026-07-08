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

Use this skill when the work is about to be picked up by someone (or something)
without the current session's context. It produces an *ephemeral* handoff
document — a bridge across the gap between sessions, not a durable project
artifact — that references existing artifacts (PRDs, plans, ADRs, issues,
commits) rather than duplicating them.

## Interface

**Input**: The current session's context — the work done, the decisions made,
the durable artifacts already produced (specifications, designs, plans, ADRs,
issues, commits), and the state of the codebase. REQUIRED.

**Interactive**: TODO -  Whether the skill runs non-interactively to completion,
or is necessarily interactive — blocking to ask questions, present options, and
wait for answers.

**Output**: A single, ephemeral handoff document written to the OS temp
directory (not the repo), referencing those durable artifacts by path or URL
rather than duplicating them. It captures what's done, what's open, the codebase
state, suggested next steps, and gotchas. This skill reports the file's absolute
path and stops; whether the next session is an agent or a human is the
orchestrator's concern.

##  Instructions

1.  **Identify what the next session needs to know.**

    If the user passed an argument describing the next session's focus (eg.
    "next session continues with the API integration"), use it to scope the
    handoff. Otherwise, treat the handoff as covering the full state of the
    current work.

    Ask yourself: if this conversation vanished now, what would a fresh agent
    need in order to *not* repeat the work, *not* re-litigate decisions, and
    *not* re-walk dead ends?

2.  **Inventory existing artifacts.**

    Before writing anything, list the durable artifacts the current work has
    already produced:

    - The specification / PRD and its path or URL.
    - The design document or chosen ADR.
    - The plan, with which steps are done and which are open.
    - Issue / ticket references.
    - PR or branch references.
    - Recent commits worth pointing at.
    - Any updated entries in `docs/domain-model.md`.

    The handoff document references these by path or URL — it does NOT duplicate
    their content. Duplication rots: if the artifact changes, the handoff lies.

3.  **Draft the document.**

    Use this structure:

    ```md
    # Handoff: <topic> (<date>)

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

4.  **Redact sensitive information.**

    Before writing the file, strip:

    - API keys, tokens, passwords, secrets of any kind.
    - Personally identifiable information (real names, emails, IDs, addresses).
    - Internal-only URLs or hostnames.

    If in doubt, redact. Handoff documents are often pasted into other channels.

5.  **Save to a temporary location.**

    Write to the OS temp directory:

    - macOS / Linux: `$TMPDIR/handoff-<topic>-<timestamp>.md` (fall back to
      `/tmp`).
    - Windows: `%TEMP%\handoff-<topic>-<timestamp>.md`.

    Do NOT commit the handoff to the project repo. The handoff is a session
    bridge, not a project artifact.

6.  **Tell the user the absolute path.**

    The user (or the next agent) needs to know where to find the file. Print the
    full absolute path.

##  Rules

-   **You MUST reference, not duplicate.**

    Every fact already captured in a specification, plan, ADR, issue, commit, or
    diff MUST be referenced by path or URL. Duplication invites drift.

-   **The handoff is ephemeral.**

    It MUST live outside the repo, and MUST be discarded once the next session
    has absorbed it. If a piece of the handoff turns out to be durable, you MUST
    promote it to the relevant project artifact (ADR, specification update,
    runbook) and remove it from the handoff.

-   **You MUST be specific about what's open.**

    "Some questions remain about the API" is unhelpful. "Two questions remain on
    the API: (1) idempotency behavior on retry; (2) whether to accept partial
    updates — both blocked on product input" is actionable.

-   **You SHOULD suggest next steps, and MUST NOT dictate them.**

    Name the work relevant to the road ahead, but the next session decides what
    to do. You MUST NOT pretend to know what the next session will encounter.

-   **You MUST redact aggressively.**

    Anything that looks remotely like a credential, real identity, or internal
    URL MUST be removed. The bar is: "could this embarrass anyone if pasted into
    a public channel?"

-   **You MUST NOT fabricate state to fill the template.**

    If a section has nothing to say, you MUST omit it or write "none" explicitly.
    An empty section is honest; an invented one is misleading.

## Examples

A compact handoff:

```md
# Handoff: orders POST endpoint (2026-05-26)

## What's been done
- Specification agreed (issue #482).
- Design captured as ADR-0007 in `docs/adr/`.
- Plan written as 6 steps; see PR #483 description.
- Steps 1-4 implemented and merged (commits abc123..def456).

## What's open
- Step 5 (feature flag wiring) is HITL; awaiting SRE sign-off on
  the `ORDERS_API_V2` rollout plan. Slack thread: REDACTED.
- AC-4 (24h replay of idempotency key) flagged as a specification gap;
  comment posted on #482, no answer yet.

## State of the codebase
- Branch: `temp/482-idempotency`.
- Tests green locally.
- One `[DEBUG-a4f2]` log left in `handlers/orders.ts:42` from
  earlier diagnosis; remove before merging step 5.

## Suggested next steps
- Implement step 5 once SRE sign-off lands.
- Review once steps 5 and 6 are integrated.

## Watch out for
- The `idempotency-key` header parsing in `handlers/orders.ts:64`
  is case-sensitive. A previous attempt to lower-case broke a
  test that was deliberately preserved. Don't "fix" it without
  reading commit def456.
```

##  Edge cases

-   **Context limit imminent.**

    Write the handoff immediately, even if other work was mid-flight. A handoff
    written *before* compaction is far higher-fidelity than one reconstructed
    after.

-   **Multiple parallel threads of work.**

    If the session covered two unrelated streams, write two handoffs — one per
    stream. Mixing them produces a document the next session has to triage
    before using.

-   **Handing off to a human, not an agent.**

    Same skill, same structure — but replace "Suggested next steps" with
    "Suggested first action", describing the concrete next step the human should
    take.

-   **The user provided no topic and the conversation covered nothing
    substantive.**

    There's nothing to hand off. Say so. Do NOT fabricate state to fill the
    template.

-   **The handoff would contain a partial decision the user hasn't confirmed.**

    Mark it explicitly as unconfirmed in "What's open", not in "What's been
    done". A handoff that misrepresents an in-flight decision as settled is
    worse than one that says nothing at all.

##  Success criteria

-   **The handoff MUST live outside the repo.**

    Written to a temp-directory path, not the project tree.

-   **Every artifact referenced MUST have a path or URL, not pasted content.**

-   **All credentials, PII, and internal-only URLs MUST be redacted.**

-   **Outstanding questions MUST be stated specifically, with their blockers
    named.**

-   **The next session MUST be able to read the handoff alone and know what to do
    next.**
