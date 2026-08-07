---
name: triage
description: >-
  Verify that a reported bug or enhancement request is real, reproducible, and
  well specified, then recommend how it should be classified and progressed.
  Use when triaging incoming issues, lining them up to be worked on by either
  humans or downstream agents, or when the user says "triage this issue",
  "work the incoming issue queue", or "prep this issue for an agent". Do not
  use it to implement a fix or to write the specification the fix works from.
compatibility: >-
  requires Read, Glob, Grep, Edit, Bash (issue tracker CLI, project build and
  test commands)
license: CC0-1.0
---

# Triage

Move a single issue in a project's issue tracker through a small state machine
of category and state labels, recommending each transition and letting the
maintainer decide. Do not fix the issue you triage.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification. This skill is interactive throughout:
triage is a maintainer's decision, so present a recommendation and wait for
direction before applying labels, posting comments, or closing anything.

- **The target issue — REQUIRED.** Look in the user's last input prompt for
  an explicit reference to a target issue. This may be a full URL or an ID
  like "#42". Where the user names a queue rather than one issue, select a
  single issue from it and triage that.

- **The issue tracker — REQUIRED.** How to read and write issues for this
  project. Check this session's context first, then the environment (a
  convention file, a configured connector, an authenticated CLI). The tracker
  MAY be GitHub, GitLab, Jira, Linear, or anything else, so do not assume a
  particular host or API.

- **The label vocabulary — REQUIRED.** The category and state labels this
  project uses. Read the labels the tracker actually defines, plus anything
  the project's convention file says about them, before mapping them onto the
  default model below.

- **Where rejected ideas are recorded — REQUIRED for a `wontfix` outcome.**
  The project's durable record of what is deliberately out of scope.
  Discover it as above; where a project has none, propose a location rather
  than assuming one.

## Success criteria

- A classification recommendation MUST have been presented to the maintainer
  with its reasoning, and any label, comment, or closure MUST have been
  applied only after the maintainer confirmed it.

- The triaged issue MUST end carrying exactly one category label and exactly
  one state label, in whichever names the project uses.

- An issue left in the agent-ready state MUST carry a brief giving a problem
  statement, a reproduction, acceptance criteria, the files likely involved,
  and explicit out-of-scope items.

- An enhancement closed as out of scope MUST have its rationale written into
  the project's record of rejected ideas, and the closing comment MUST link
  to it.

- Every comment the agent posts MUST open with a disclaimer marking it as
  AI-generated.

- The skill MUST NOT have changed any source file, test, configuration, or
  dependency, and MUST NOT have modified any issue other than the target and
  any issue split out of it. Triage classifies work; it does not do it.

## Instructions

1.  Establish the tracker and the label vocabulary.

    Resolve which tracker this project uses and how to read and write to it.
    Then establish its label vocabulary from the labels that tracker actually
    defines, plus anything the project's convention file says about them.

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

    Where the target issue is not already settled, query the tracker for
    three buckets, oldest first:

    1. Unlabeled — never triaged.
    2. Awaiting triage — evaluation in progress.
    3. Awaiting information, with new reporter activity — the reporter has
       replied since the last triage notes, so the issue needs
       re-evaluation.

    Present counts and a one-line summary per issue, and let the
    maintainer pick which to work on next.

3.  Gather context for the chosen issue.

    Read the full issue: body, comments, labels, reporter, dates. Parse
    any prior triage notes so you do not re-ask resolved questions.
    Explore the relevant code to understand which modules the issue
    touches. Check the project's record of rejected ideas for any prior
    rejection of a similar issue, and link to it.

4.  For bugs, attempt reproduction.

    Read the reporter's steps, trace the code, and run the failing
    command. Report one of:

    - Successful repro: include the exact code path that triggered the bug.
    - Failed repro: state what you tried and what happened instead.
    - Insufficient detail: this is a strong signal for the needs-info state.

    A confirmed repro makes for a much stronger agent brief later.

5.  Grill the issue into shape, where it needs it.

    If the issue is under-specified for whichever state it's heading to,
    interrogate it — question the reporter and the code until its
    requirements are sharp. The output is a sharpened set of requirements,
    ready to be implemented, escalated to a human, or rejected with a
    captured reason.

6.  Recommend a classification.

    State your category and state recommendation with reasoning, plus a
    brief summary of the code the issue touches. Then wait for direction.
    You MUST NOT apply labels, post comments, or close anything until the
    maintainer has confirmed the outcome.

7.  Apply the confirmed outcome.

    Map state to action:

    - Agent-ready → post an agent-brief comment (see the examples below),
      then apply the label.
    - Human-ready → same structure as the agent brief, but note
      specifically why it cannot be delegated. Apply the label.
    - Needs-info → post a triage-notes comment (see the examples below)
      with specific outstanding questions, then apply the label.
    - Wontfix, bug → post a polite explanation and close.
    - Wontfix, enhancement → capture the rejection in the project's record
      of rejected ideas, link to it from a closing comment, then close.
    - Needs-triage → apply the label only. Optionally comment if there is
      partial progress to record.

    Prefix every comment you post with a short disclaimer, eg.
    `> *AI-generated during triage.*`, so the reporter and maintainer can
    distinguish agent activity from human activity at a glance.

## Rules

- You MUST recommend rather than decide.

  The maintainer applies labels and closes issues; this skill's job is to
  make that decision cheap. Acting unilaterally spends the maintainer's
  authority without their consent, and is much harder to undo than a
  recommendation is to reject.

- You MUST triage and stop there.

  The fix, and the specification that precedes it, are the caller's.
  Classifying an issue is not the same as taking it on.

- You MUST discover the tracker and its vocabulary rather than assuming them.

  This skill runs across projects on different trackers with different label
  schemes and different places for recording rejected ideas. A host, API,
  label string, or path that is right in one project is wrong in the next.

- State transitions SHOULD follow the machine, and any transition outside it
  MUST be flagged before it is made.

  The typical path runs from unlabeled, to awaiting triage, and then to one
  of the four terminal states; needs-info returns to awaiting triage once the
  reporter replies. Shortcuts are sometimes right — an obvious duplicate need
  not linger — but they MUST be surfaced rather than performed quietly.

- You MUST flag conflicting labels before resolving them.

  An issue carrying two state labels reflects a disagreement somewhere. Ask
  which is intended instead of picking one.

- You MUST read prior notes before asking anything.

  Re-asking questions the reporter already answered erodes their willingness
  to engage. Parse existing triage notes and comments before you compose a
  single question.

- A confirmed reproduction SHOULD be the goal for every bug.

  Issues that can be reliably reproduced are much faster to fix and much
  harder to mis-classify.

- Out-of-scope rejections MUST be recorded durably.

  A one-line closing comment is easily lost, so the next person to file the
  same idea gets re-litigation instead of an explanation. Where the project
  has no record of rejected ideas, propose creating one rather than closing
  with the reasoning unrecorded.

- You MUST NOT apply the agent-ready label without a brief.

  An issue with the label but no brief is a setup for failure. If the
  maintainer asks for the label without the grilling, ask whether they want
  a brief first.

- Questions to a reporter MUST each name what is missing and why it matters.

  "Please provide more info" is not a question, and produces no answer.

## Edge cases

- The reporter ghosts while the issue awaits information.

  After a reasonable interval — varies by project, often 14 to 30 days —
  close politely: "Closing for lack of activity; please reopen with the
  requested info." Re-opening is cheap, and stale issues obscure the active
  queue.

- The issue duplicates an existing one.

  Confirm the duplication explicitly: link to the original and quote the
  symptom that matches. Close as wontfix with the link in the closing
  comment. Do not silently close.

- The issue mixes a bug and an enhancement.

  Split it. The bug part gets its own issue, gets reproduced, and gets
  triaged on its own. The enhancement part follows the enhancement path.
  Cross-link the two issues.

- The maintainer overrides your recommendation.

  Trust them. Apply what they asked for, even where your recommendation
  differed, and do not relitigate.

## Examples

- A triage-notes comment, for an issue awaiting information:

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

- An agent-brief comment, for an issue ready to be delegated:

  ```md
  > *AI-generated during triage.*

  ## Agent brief

  Problem. When the DB connection pool is saturated, requests return
  `500 Internal Server Error` instead of `503 Service Unavailable`.

  Reproduction. `make load-test CONCURRENCY=20` against a server with the
  default `pool_size=10`, on Postgres 15.x.

  Expected behavior. A saturated pool returns `503` with a `Retry-After`
  header. The retry-after value is tunable via config.

  Acceptance criteria:

  - [ ] Saturated pool returns `503`.
  - [ ] Response includes a `Retry-After` header (config-tunable, default
        5 seconds).
  - [ ] Existing tests that assert `500-on-pool-error` are updated to
        assert `503` instead.

  Files likely involved: `db/pool.go`, `middleware/error_handler.go`.

  Out of scope: changing the default `pool_size`; adding a circuit
  breaker. Both deferred; raise separate issues if wanted.
  ```

- A closing comment, for an enhancement rejected as out of scope:

  ```md
  > *AI-generated during triage.*

  Thanks for the suggestion. We've decided not to pursue this; rationale
  captured in the out-of-scope record (linked) so future suggestions land on
  a reasoned reply rather than starting from scratch. Closing.
  ```
