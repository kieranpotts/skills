---
name: triage
description: Move issues on the project issue tracker through a small state machine of category and state labels. Gather context, recommend a classification, attempt reproduction for bugs, grill the issue into shape if needed, then apply the outcome - a label change, an agent brief, a needs-info request, or a wontfix closure. Use when triaging incoming issues, preparing them for AFK agents, reviewing the backlog, or when the user says "triage this".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: glm-5.1:cloud
---

# Triage

Use this skill to move issues on the project's issue tracker through a deliberate state machine. The goal is to take a freshly-filed issue and decide what happens next: implement it, defer it, reject it, or get more information.

Do NOT use this skill to fix bugs (use [`debug`](../debug/SKILL.md)), implement features (use [`code`](../code/SKILL.md) from a [`plan`](../plan/SKILL.md)), or write requirements from scratch (use [`specify`](../specify/SKILL.md)).

This skill assumes the project has an issue tracker (GitHub Issues, Jira, Linear, etc.) and a labeling system that supports category and state labels. If the project has neither, set them up before triaging.

##  Instructions

1.  **Establish the label vocabulary.**

    Two *category* labels:

    - `bug` - something is broken.
    - `enhancement` - new feature or improvement.

    Five *state* labels:

    - `needs-triage` - maintainer needs to evaluate.
    - `needs-info` - waiting on the reporter for more information.
    - `ready-for-agent` - fully specified, ready for an AFK agent (see [`plan`](../plan/SKILL.md) for what "fully specified" means).
    - `ready-for-human` - needs human implementation (architectural judgment, external access, manual verification).
    - `wontfix` - will not be actioned.

    Every triaged issue carries *exactly one* category label and *exactly one* state label. The actual strings in the tracker may differ (eg. `kind/bug` instead of `bug`); maintain a mapping if so.

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

2.  **Identify which issues need attention.**

    Query the tracker for three buckets, oldest first:

    1. *Unlabeled* - never triaged.
    2. *`needs-triage`* - evaluation in progress.
    3. *`needs-info` with new reporter activity* - the reporter has replied since the last triage notes, so the issue needs re-evaluation.

    Present counts and a one-line summary per issue. Let the maintainer pick which to work on next.

3.  **Gather context for the chosen issue.**

    Read the full issue: body, comments, labels, reporter, dates. Parse any prior triage notes so you do not re-ask resolved questions. Explore the relevant code to understand which modules the issue touches. Check the out-of-scope knowledge base (eg. `docs/out-of-scope/`) for any prior rejection of a similar issue and link to it.

4.  **Recommend a classification.**

    State your category and state recommendation with reasoning, plus a brief codebase summary relevant to the issue. Wait for direction from the maintainer before applying any labels - triage is a maintainer's decision; the skill does the legwork to make that decision cheap.

5.  **For bugs: attempt reproduction.**

    Before grilling, try to reproduce: read the reporter's steps, trace the code, run the failing command. Report one of:

    - *Successful repro*: include the exact code path that triggered the bug.
    - *Failed repro*: state what you tried and what happened instead.
    - *Insufficient detail*: this is a strong signal for `needs-info`.

    A confirmed repro makes for a much stronger agent brief later. Spend disproportionate effort here.

6.  **Grill the issue into shape (if needed).**

    If the issue is under-specified for whichever state it's heading to, run an [`elaborate`](../elaborate/SKILL.md) session against it. The output is a sharpened set of requirements, ready to be implemented, escalated to a human, or rejected with a captured reason.

7.  **Apply the outcome.**

    Map state to action:

    - *`ready-for-agent`* → post an agent-brief comment (template below). Apply the label.
    - *`ready-for-human`* → same structure as the agent brief, but note specifically *why* it can't be delegated (architectural call, external access required, design judgment, manual verification). Apply the label.
    - *`needs-info`* → post a triage-notes comment (template below) with specific outstanding questions. Apply the label.
    - *`wontfix` (bug)* → post a polite explanation and close.
    - *`wontfix` (enhancement)* → capture the rejection in the out-of-scope knowledge base (`docs/out-of-scope/<topic>.md`), link to it from a closing comment, then close.
    - *`needs-triage`* → apply the label only. Optionally comment if there's partial progress to record.

8.  **Mark AI-generated activity.**

    If the triage is being performed by an AI agent, prefix every comment posted with a short disclaimer (eg. `> *AI-generated during triage.*`) so the reporter and maintainer can distinguish agent activity from human activity at a glance.

##  Rules

-   **Triage is a maintainer's decision.**

    Recommend; do not unilaterally label, comment, or close. The maintainer applies labels and closes issues; the skill makes that decision cheap.

-   **One category and one state per issue.**

    No exceptions. If state labels conflict (eg. an issue is both `needs-info` and `ready-for-agent`), flag the inconsistency and ask before resolving.

-   **State transitions follow the machine.**

    Typical path: *unlabeled* → `needs-triage` → (`needs-info` | `ready-for-agent` | `ready-for-human` | `wontfix`). `needs-info` returns to `needs-triage` once the reporter replies. Unusual transitions (eg. jumping straight from unlabeled to `wontfix`) get flagged explicitly.

-   **Read prior notes before asking anything.**

    Re-asking questions the reporter already answered erodes their willingness to engage. Parse `Triage Notes` blocks and existing comments before you compose a single question.

-   **A confirmed repro is the gold standard for bugs.**

    Issues that can be reliably reproduced are much faster to fix and much harder to mis-classify. Reproducibility is also the strongest signal a bug is `ready-for-agent`.

-   **Out-of-scope rejections are durable.**

    A one-line "wontfix" close on an enhancement is easily lost. Capture the reasoning in `docs/out-of-scope/<topic>.md` so the next person to file the same idea gets the explanation by reference, not by re-litigation.

-   **`ready-for-agent` requires a brief.**

    An issue with the label but no brief is a setup for failure. If the maintainer asks to apply the label without grilling, ask whether they want a brief first.

-   **Specific, actionable questions only in `needs-info`.**

    "Please provide more info" is not a question. Each question names what is missing and why it matters.

## Examples

A `needs-info` triage-notes comment:

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

A `ready-for-agent` agent-brief comment:

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

**Out of scope:** Changing the default `pool_size`. Adding a circuit
breaker. Both deferred; raise separate issues if wanted.
```

A wontfix-enhancement closure with out-of-scope capture:

```md
> *AI-generated during triage.*

Thanks for the suggestion. We've decided not to pursue this; rationale
captured in [`docs/out-of-scope/bulk-import-via-csv.md`](../docs/out-of-scope/bulk-import-via-csv.md)
so future suggestions land on a reasoned reply rather than starting from
scratch. Closing.
```

##  Edge cases

-   **The reporter ghosts on `needs-info`.**

    After a reasonable interval (varies by project - often 14-30 days), close politely: "Closing for lack of activity; please reopen with the requested info." Re-opening is cheap; stale `needs-info` issues obscure the active queue.

-   **Duplicate of an existing issue.**

    Confirm the duplication explicitly: link to the original and quote the symptom that matches. Close as wontfix with the dup link in the closing comment. Do not silently close.

-   **An issue mixes a bug and an enhancement.**

    Split it. The bug part gets its own issue, gets reproduced, gets triaged on its own. The enhancement part follows the enhancement path. Cross-link the two issues.

-   **Maintainer overrides the recommendation.**

    Trust them. Apply what they asked for, even if your recommendation differed. Do not relitigate.

-   **The out-of-scope knowledge base does not yet exist.**

    Create it lazily when the first wontfix-enhancement closure needs to be captured (eg. `docs/out-of-scope/bulk-import-via-csv.md`). Do not pre-populate it.

-   **An issue's labels conflict with the maintainer's request.**

    Surface the conflict ("this issue currently has `ready-for-agent` but you asked me to move it to `needs-info` - confirm?") before making any changes.

##  Success criteria

-   **Every triaged issue carries one category and one state label.**

-   **State transitions follow the machine.**

    Unusual transitions are flagged, not silently performed.

-   **`ready-for-agent` issues have a brief.**

    Problem statement, ACs, files likely involved, and explicit out-of-scope items.

-   **`wontfix` enhancement closures are captured in `docs/out-of-scope/`.**

-   **AI-generated comments are marked.**

-   **Outstanding questions are specific and actionable.**

## References

- [Original source — mattpocock/skills `triage`](https://github.com/mattpocock/skills/blob/main/skills/engineering/triage/SKILL.md): The skill this one is adapted from, including the agent-brief and out-of-scope conventions.

- [`elaborate`](../elaborate/SKILL.md): For grilling under-specified issues into shape.

- [`plan`](../plan/SKILL.md): What "ready-for-agent" specifications should resemble - including HITL / AFK tagging.

- [`specify`](../specify/SKILL.md): Where AC-style requirements come from in agent briefs.

- [`debug`](../debug/SKILL.md): For the implementation phase that follows a reproduced bug.
