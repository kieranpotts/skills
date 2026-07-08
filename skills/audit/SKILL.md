---
name: audit
description: >-
  Evaluate the as-built architecture of a software system. Report code smells
  and anti-patterns like shallow abstractions, tangled dependencies, and
  single-caller wrappers. Evaluation only – no code changes. Use this skill when
  the user says "audit the architecture", "is the design still sound?", or
  "check the codebase for structural drift".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/software-architect
---

# Audit

**Input:**

- **The target codebase. REQUIRED.** Unless the user inputs an explicit target
  path, assume the target is the code repository in the current working
  directory. If the current working directory is not part of a code repository,
  check `AGENTS.md` in the current working directory for paths to all projects
  in the current workspace. Else find all code repositories in nested
  subdirectories and assume they are all the target codebase.

- **Where to write the report. REQUIRED.** Check the `AGENTS.md` file in the
  current working directory for the path or URL of the audit reports (they may
  be in a separate repository). If not found, check if the current working
  directory has an `audits/` subdirectory that contains audit reports. If the
  path to the audit reports cannot be found, stop and alert the user of the
  failure.

**Output:**

A prioritized, bounded report of architectural improvement candidates, each
citing specific files and lines, stating what is observed and the cost it
imposes, and optionally pointing toward a fix. The report is written to the
audit reports collection or repository, following the conventions defined
there.

The audit evaluates the as-built system on its own terms. It does NOT read
any design documentation, does NOT compare the code against the intended
architecture, and does NOT report drift from the docs. This deliberate
blindness keeps the review unbiased, so it surfaces genuinely novel
suggestions.

**Interactivity:**

Agents MUST NOT block for user input after the initial prompt. Agents MUST
follow this skill's instructions to completion, or fail with an error message.

##  Instructions

1.  **Establish scope and pin the subject.**

    Decide what is in scope — which repositories, services, or directories the
    audit covers — and record the exact commit of each
    (`owner/repo@<commit-sha>`), so the report is a reproducible point-in-time
    snapshot of what was examined.

    Do NOT open the design documentation. This audit forms its judgment from the
    code alone. Reading the intended architecture would bias the review toward
    the trade-offs already considered — the opposite of what this skill is for.

2.  **Walk the codebase applying the deletion test.**

    For each significant module, ask: *if I removed this module, where would its
    complexity go?*

    - If complexity would **concentrate elsewhere in a worse arrangement** — the
      module is **deep**, earning its keep.
    - If complexity would **simply redistribute** without becoming worse — the
      module is **shallow**, not earning its keep. Flag it.

    A shallow module's primary value is hiding a thin layer of behavior behind
    an interface wider than the behavior justifies.

3.  **Look for these specific smells.**

    - **Wide interfaces relative to behavior.** Many exported functions for thin
      underlying logic. Often the boundary is in the wrong place.
    - **Tangled dependencies.** Modules importing each other directly or via
      chains that resist independent change. Touching one requires touching
      several.
    - **Single-caller abstractions.** An interface, base class, or helper used
      by exactly one caller. The abstraction wasn't earned.
    - **Repeated patterns not yet abstracted.** Three or more places doing the
      same shape of work, none extracted. Worth promoting to a named concept.
    - **Inverted dependencies.** Lower-level modules importing higher-level
      ones; stable code depending on volatile code.
    - **Names that don't match content.** A `util` doing domain logic, a
      `Manager` with one method, a `Service` that's a thin DAO.

4.  **Prioritize findings by impact ÷ effort.**

    - **Impact**: how much the rest of the codebase simplifies if this is fixed.
      Findings that unlock other improvements rank high.
    - **Effort**: how invasive the change would be. Local renames rank above
      cross-cutting restructures.

    Assign each finding a **Priority** — High, Medium, or Low — from this
    ranking, and order the report by it. The top entry is the cheapest
    high-impact fix. Cap the report at 5–10 candidates — a 30-item backlog won't
    be acted on.

5.  **Write the report.**

    Write the report into the project's audit-report collection, following its
    conventions:

    - **If the project has an `audits/` collection**, copy its `TEMPLATE.md` and
      save the report at the path its `README.md` specifies (typically
      `audits/YYYY-MM-DD-<slug>/README.md`). Fill the metadata header —
      Auditors, Date, Subject (the `repo@commit` snapshot from step 1), Scope —
      and leave workflow fields (eg. the audit PR number) blank for the user.
      The collection's `TEMPLATE.md` is authoritative for structure.

    - **Do NOT commit, branch, or open a pull request.** The collection's own
      workflow — a human, or a companion skill — owns branching, committing, and
      indexing. Writing the report file is where this skill stops.

    - **If the project has no audit-report collection**, check `AGENTS.md` for
      naming and location conventions. Failing that, write
      `audit-report-<timestamp>.md` to a sensible location — the repository
      root, or the OS temp directory if the target is not a git repository —
      using the fallback structure below.

    Fallback structure (a project's `TEMPLATE.md`, where present, supersedes
    this):

    ```markdown
    # Audit report — <subject>

    - Auditors: <name(s)>
    - Date: YYYY-MM-DD
    - Subject: owner/repo@<commit>, ...
    - Scope: <the subsystems / areas examined>

    ## Summary
    <2–3 sentences on the dominant themes — what's structurally sound, what's not.>

    ## Scope and method
    <What was examined and how; what was deliberately left out, so coverage can be judged.>

    ## Findings (prioritized)

    | ID  | Finding | Type | Priority | Location |
    | --- | ------- | ---- | -------- | --------- |
    | F01 | <title> | <smell> | High | path:line |

    ### F01 — <title>
    - **Type:** <shallow abstraction | tangled dependency | single-caller wrapper | …>
    - **Priority:** High | Medium | Low
    - **Location:** <file:line>

    <What is observed — the structure that exists — and the cost it imposes. Optionally, a short pointer toward a fix — never a worked-out design.>

    ## Themes
    <Recurring patterns the individual findings are symptoms of. Often more valuable than any single finding.>

    ## Recommendations
    <A prioritized shortlist of what to address first, to feed downstream refactoring.>
    ```

##  Rules

-   **Discovery only.**

    Do not change any code in the audited repositories, and do not file issues
    or open pull requests to implement the findings. The output is the report;
    the user decides what to act on.

-   **Do not commit the report.**

    Write it to disk so it persists and can be referenced by
    [`refactor`](../refactor/) and the collection's own workflow, but leave
    committing — or discarding — to the user.

-   **Cite files and lines.**

    Every finding names specific paths. Vague findings ("the API layer is
    messy") are useless — be concrete.

-   **Observation first; any pointer is optional.**

    State what you see and the cost it imposes before offering any suggestion. A
    pointer toward a fix is optional, and MUST stay a pointer — never a
    worked-out alternative design (that is the job of `design`, downstream). The
    observation is the deliverable; a reader may reject the pointer and still
    find the observation valuable.

-   **"Not worth fixing" is a valid conclusion.**

    Not every smell earns a fix. If the cost of the change would exceed the cost
    of the smell, say so — record it as low priority, with the rationale.

-   **Stay within the codebase's idioms.**

    Don't flag style choices that are consistent across the codebase as smells
    just because you'd prefer a different style. Audit is for structural
    problems, not preferences.

##  Success criteria

-   **The report cites specific files for every finding.**

    No vague platitudes. Each finding names a module/file path and a concrete
    observation.

-   **Findings are prioritized by impact ÷ effort.**

    Each carries a Priority (High / Medium / Low) derived from the ranking, and
    the report is ordered by it. A reader can stop after the top three entries
    and still have something actionable.

-   **No code was changed in the audited repositories.**

    Their tracked files are unchanged after this skill runs — `git diff` over
    them is empty. The new report file in the audit-report collection is the one
    expected artifact.

-   **The report exists on disk and is not committed.**

    The report file is present at the location the collection's conventions (or
    `AGENTS.md`) specify, and `git status` shows it untracked — never staged or
    committed by this skill.

-   **The report is bounded.**

    Top 5–10 candidates. Not an exhaustive enumeration.

-   **The report conforms to the audit template.**

    It carries the metadata header (including the Subject snapshot), a findings
    table, and per-finding Type / Priority / Location — matching the project's
    `TEMPLATE.md`, or the fallback structure where none exists.

##  References

-   The project's `audits/README.md` and `audits/TEMPLATE.md`, where present —
    the authoritative conventions for the report's path, structure, and
    lifecycle.

-   [`refactor`](../refactor/): Consumes this report to propose and make the
    changes the user chooses to act on.
