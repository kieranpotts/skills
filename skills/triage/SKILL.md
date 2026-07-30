---
name: triage
description: >-
  Verify that a reported bug or incident is real and reproducible. Use when
  triaging incoming issues, lining them up to be worked on by either humans or
  downstream agents. Also use when the user says something like "triage this
  issue", "work the incoming issue queue", or "prep this issue for an agent".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-lead
---

# Triage

Move a single issue in a project's issue tracker through a small state
machine of state labels.

## Input

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

- The target issue — REQUIRED.
  Look in the user's last input prompt for an explicit reference to a target
  issue. This may be a full URL or an ID like "#42".

## Output

A recommended classification per issue, applied as the outcome once the
maintainer confirms — a label change, an agent brief (problem statement,
repro, acceptance criteria, likely files, out-of-scope, AI disclaimer), a
needs-info request, or a durably-captured wontfix rationale. This skill
recommends and routes; it does not implement the fix or write the
specification that follows.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Instructions

1.  Establish the label vocabulary.

    Two category labels:

    - `bug` — something is broken.
    - `enhancement` — new feature or improvement.

    Five state labels:

    - `needs-triage` — maintainer needs to evaluate.
    - `needs-info` — waiting on the reporter for more information.
    - `ready-for-agent` — fully specified, ready for an AFK agent.
    - `ready-for-human` — needs human implementation (architectural
      judgment, external access, manual verification).
    - `wontfix` — will not be actioned.

    Every triaged issue carries exactly one category label and exactly
    one state label. The actual strings in the tracker may differ (eg.
    `kind/bug` instead of `bug`); maintain a mapping if so.

    The state machine:

    ```mermaid
    stateDiagram-v2
      [*] --> unlabeled
      unlabeled --> needs_triage: enter triage
      needs_triage --> needs_info: missing detail
      needs_info --> needs_triage: reporter replies
      needs_triage --> ready_for_agent: specified, agent-implementable
      needs_triage --> ready_for_human: specified, needs human judgment
      needs_triage --> wontfix: rejected
      ready_for_agent --> [*]: implemented & closed
      ready_for_human --> [*]: implemented & closed
      wontfix --> [*]: closed
    ```

2.  Identify which issues need attention.

    Query the tracker for three buckets, oldest first:

    1. Unlabeled — never triaged.
    2. `needs-triage` — evaluation in progress.
    3. `needs-info` with new reporter activity — the reporter has
       replied since the last triage notes, so the issue needs
       re-evaluation.

    Present counts and a one-line summary per issue, and let the
    maintainer pick which to work on next.

3.  Gather context for the chosen issue.

    Read the full issue: body, comments, labels, reporter, dates. Parse
    any prior triage notes so you do not re-ask resolved questions.
    Explore the relevant code to understand which modules the issue
    touches. Check the out-of-scope knowledge base (eg.
    `docs/out-of-scope/`) for any prior rejection of a similar issue and
    link to it.

4.  Recommend a classification.

    State your category and state recommendation with reasoning, plus
    a brief codebase summary relevant to the issue. Wait for direction
    from the maintainer before applying any labels.

5.  For bugs: attempt reproduction.

    Read the reporter's steps, trace the code, and run the failing
    command. Report one of:

    - Successful repro: include the exact code path that triggered the
      bug.
    - Failed repro: state what you tried and what happened instead.
    - Insufficient detail: this is a strong signal for `needs-info`.

    A confirmed repro makes for a much stronger agent brief later.

6.  Grill the issue into shape (if needed).

    If the issue is under-specified for whichever state it's heading to,
    interrogate it — question the reporter and the code until its
    requirements are sharp. The output is a sharpened set of
    requirements, ready to be implemented, escalated to a human, or
    rejected with a captured reason.

7.  Apply the outcome.

    Map state to action:

    - `ready-for-agent` → post an agent-brief comment (template below).
      Apply the label.
    - `ready-for-human` → same structure as the agent brief, but note
      specifically why it can't be delegated. Apply the label.
    - `needs-info` → post a triage-notes comment (template below) with
      specific outstanding questions. Apply the label.
    - `wontfix` (bug) → post a polite explanation and close.
    - `wontfix` (enhancement) → capture the rejection in the
      out-of-scope knowledge base (`docs/out-of-scope/<topic>.md`), link
      to it from a closing comment, then close.
    - `needs-triage` → apply the label only. Optionally comment if
      there's partial progress to record.

8.  Mark AI-generated activity.

    If the triage is being performed by an AI agent, prefix every
    comment posted with a short disclaimer (eg.
    `> *AI-generated during triage.*`) so the reporter and maintainer
    can distinguish agent activity from human activity at a glance.

## Rules

- You MUST treat triage as a maintainer's decision.

  Recommend; you MUST NOT unilaterally label, comment, or close. The
  maintainer applies labels and closes issues; the skill makes that
  decision cheap.

- You MUST flag conflicting labels before resolving them.

  If state labels conflict (eg. an issue is both `needs-info` and
  `ready-for-agent`), you MUST flag the inconsistency and ask before
  resolving.

- State transitions MUST follow the machine.

  Typical path: unlabeled → `needs-triage` → (`needs-info` |
  `ready-for-agent` | `ready-for-human` | `wontfix`). `needs-info`
  returns to `needs-triage` once the reporter replies. Unusual
  transitions (eg. jumping straight from unlabeled to `wontfix`) MUST
  be flagged explicitly.

- You MUST read prior notes before asking anything.

  Re-asking questions the reporter already answered erodes their
  willingness to engage. Parse `Triage Notes` blocks and existing
  comments before you compose a single question.

- A confirmed repro SHOULD be the gold standard for bugs.

  Issues that can be reliably reproduced are much faster to fix and
  much harder to mis-classify.

- Out-of-scope rejections MUST be durable.

  A one-line "wontfix" close on an enhancement is easily lost. You
  MUST capture the reasoning in `docs/out-of-scope/<topic>.md` so the
  next person to file the same idea gets the explanation by reference,
  not by re-litigation.

- `ready-for-agent` issues MUST have a brief.

  An issue with the label but no brief is a setup for failure. If the
  maintainer asks to apply the label without grilling, you MUST ask
  whether they want a brief first.

- Questions in `needs-info` MUST be specific and actionable.

  "Please provide more info" is not a question. Each question MUST
  name what is missing and why it matters.

## Edge cases

- The reporter ghosts on `needs-info`.

  After a reasonable interval (varies by project — often 14-30 days),
  close politely: "Closing for lack of activity; please reopen with
  the requested info." Re-opening is cheap; stale `needs-info` issues
  obscure the active queue.

- Duplicate of an existing issue.

  Confirm the duplication explicitly: link to the original and quote
  the symptom that matches. Close as wontfix with the dup link in the
  closing comment. Do not silently close.

- An issue mixes a bug and an enhancement.

  Split it. The bug part gets its own issue, gets reproduced, gets
  triaged on its own. The enhancement part follows the enhancement
  path. Cross-link the two issues.

- Maintainer overrides the recommendation.

  Trust them. Apply what they asked for, even if your recommendation
  differed. Do not relitigate.

## Success criteria

- Every triaged issue MUST carry one category and one state label.

- State transitions MUST follow the machine.

  Unusual transitions MUST be flagged, not silently performed.

- `ready-for-agent` issues MUST have a brief.

  Problem statement, ACs, files likely involved, and explicit
  out-of-scope items.

- `wontfix` enhancement closures MUST be captured in
  `docs/out-of-scope/`.

- AI-generated comments MUST be marked.

- Outstanding questions MUST be specific and actionable.

## Examples

- A `needs-info` triage-notes comment:

  ```md
  > *AI-generated during triage.*

  ## Triage notes

  **What we've established so far:**
  - Reproduced on Postgres 15.4 with `MAX_CONNECTIONS=10` (steps from
    reporter, run locally).
  - Pool exhaustion happens when N concurrent requests exceed pool size,
    which is expected. The unexpected part is the `500` response, not
    the saturation itself.

  **What we still need from you (@reporter):**
  - Are you seeing this on Postgres 14 as well, or only 15.x?
  - What value of `pool_size` are you running with?
  - Is your client setting a request timeout? If so, what value?
  ```

- A `ready-for-agent` agent-brief comment:

  ```md
  > *AI-generated during triage.*

  ## Agent brief

  **Problem.** When the DB connection pool is saturated, requests return
  `500 Internal Server Error` instead of `503 Service Unavailable`.

  **Reproduction.** `make load-test CONCURRENCY=20` against a server
  with the default `pool_size=10`, on Postgres 15.x.

  **Expected behavior.** Saturated pool returns `503` with a `Retry-After`
  header. The retry-after value is tunable via config.

  **Acceptance criteria:**
  - [ ] Saturated pool returns `503`.
  - [ ] Response includes a `Retry-After` header (config-tunable, default
        5 seconds).
  - [ ] Existing tests that assert `500-on-pool-error` are updated to
        assert `503` instead.

  **Files likely involved:** `db/pool.go`, `middleware/error_handler.go`.

  **Out-of-scope:** Changing the default `pool_size`. Adding a circuit
  breaker. Both deferred; raise separate issues if wanted.
  ```

- A wontfix-enhancement closure with out-of-scope capture:

  ```md
  > *AI-generated during triage.*

  Thanks for the suggestion. We've decided not to pursue this; rationale
  captured in [`docs/out-of-scope/bulk-import-via-csv.md`](../docs/out-of-scope/bulk-import-via-csv.md)
  so future suggestions land on a reasoned reply rather than starting from
  scratch. Closing.
  ```

## References

None.
