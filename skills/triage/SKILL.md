---
name: triage
description: >-
  Verify that a reported bug or incident is real and reproducible. Use when
  triaging incoming issues, lining them up to be worked on by either humans or
  downstream agents. Also use when the user says something like "triage this
  issue", "work the incoming issue queue", or "prep this issue for an agent".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/ANALYSIS_STANDARD
---

# Triage

Move a single issue in a project's issue tracker through a small state
machine of state labels.

## Parameters

Determine the following information from the surrounding context and
environment.

- **The target issue — REQUIRED.** Look in the user's last input prompt for
  an explicit reference to a target issue. This may be a full URL or an ID
  like "#42".

- **The issue tracker, and the project's label vocabulary — REQUIRED.**
  Discover both rather than assuming them: check this session's context
  first, then the environment (a convention file such as `AGENTS.md`, the
  labels the tracker actually defines, a configured connector). If neither
  settles it, ask the user. The tracker MAY be GitHub, GitLab, Jira, Linear,
  or anything else — do not assume a particular host or API.

- **Where rejected ideas are recorded — REQUIRED for a `wontfix` outcome.**
  The project's durable record of what is deliberately out of scope.
  Discover it as above; where a project has none, propose a location rather
  than assuming one.

This skill is interactive. Triage is a maintainer's decision: the agent
presents its recommendation and waits for direction before applying labels,
posting comments, or closing anything. It also prompts to establish the
tracker, the label vocabulary, and the out-of-scope record when context and
environment do not settle them.

## Success criteria

You will achieve the following outcomes:

- A recommended classification MUST exist for each issue, applied as the
  outcome only once the maintainer confirms it — a label change, an agent
  brief, a needs-info request, or a durably-captured wontfix rationale.

- Every triaged issue MUST carry one category and one state label.

- State transitions MUST follow the machine, and unusual transitions MUST
  be flagged, not silently performed.

- `ready-for-agent` issues MUST have a brief: a problem statement, a repro,
  acceptance criteria, the files likely involved, explicit out-of-scope
  items, and the AI disclaimer.

- `wontfix` enhancement closures MUST be captured durably, wherever this
  project records rejected ideas.

- The tracker, label vocabulary, and out-of-scope record MUST have been
  discovered, not assumed.

- AI-generated comments MUST be marked.

- Outstanding questions MUST be specific and actionable.

## Instructions

1.  Establish the tracker and the label vocabulary.

    Resolve which tracker this project uses and how to read and write to it
    (see Input). Then establish its label vocabulary from the labels that
    tracker actually defines, plus anything the project's convention file
    says about them.

    The model below is the default shape to map onto — two category labels
    and five state labels. Where the project already has an equivalent
    vocabulary under different names (`kind/bug`, `status/blocked`,
    `triage/needed`), use the project's names and maintain the mapping. Where
    the project has no vocabulary at all, propose this one and get the
    maintainer's agreement before applying it.

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
    one state label, in whatever names this project uses for them.

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
    touches. Check the project's record of rejected ideas (see Input) for any
    prior rejection of a similar issue, and link to it.

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
    - `wontfix` (enhancement) → capture the rejection in the project's
      record of rejected ideas, link to it from a closing comment, then
      close.
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

- You MUST triage and stop there.

  The fix, and the specification that precedes it, are the caller's.
  Classifying an issue is not the same as taking it on.

- You MUST discover the tracker and its vocabulary; you MUST NOT assume
  them.

  This skill is used across projects on different trackers with different
  label schemes and different places for recording rejected ideas. A host,
  API, label string, or path that is right in one project is wrong in the
  next. Resolve them first, then work in the project's own terms.

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

  A one-line "wontfix" close on an enhancement is easily lost. You MUST
  capture the reasoning wherever this project durably records rejected
  ideas, so the next person to file the same idea gets the explanation by
  reference, not by re-litigation. Where the project has no such record,
  propose creating one rather than closing with the reasoning unrecorded.

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

## Examples

- A `needs-info` triage-notes comment:

  ```md
  > *AI-generated during triage.*

  ## Triage notes

  What we've established so far:
  - Reproduced on Postgres 15.4 with `MAX_CONNECTIONS=10` (steps from
    reporter, run locally).
  - Pool exhaustion happens when N concurrent requests exceed pool size,
    which is expected. The unexpected part is the `500` response, not
    the saturation itself.

    What we still need from you (@reporter):
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

  Acceptance criteria:
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
  captured in the out-of-scope record (linked) so future suggestions land on
  a reasoned reply rather than starting from scratch. Closing.
  ```
