---
name: audit
description: >-
  Evaluate the evolving architecture — modularity, consistency, coupling, etc.
  Security and privacy is out-of-scope. Use this skill when the user says
  something like "audit this codebase", "do an architectural audit", "is the
  design still sound?", or "check the codebase for structural drift".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-reasoning
---

# Audit

Audit the as-built static structure (code plus data) of a software system. Report
code smells and anti-patterns like shallow abstractions, tangled dependencies,
single-caller wrappers, inverted dependencies, and misnamed abstractions.
Uncover edge cases, such as uncommon failure modes, that are not handled
gracefully.

This task is scoped to static review of code and data structures. Review of
security and privacy is out-of-scope.

Evaluation only. You MUST NOT make any code or configuration changes to the
software itself.

**Input:** Determine the following information from the surrounding context
and environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

- The target codebase — REQUIRED.
  Look in the user's last input prompt for an explicit reference to a target
  path or URL to a code repository. If a URL, clone the repository to a
  temporary directory. Otherwise, assume the target is the code repository
  under which the current working directory (cwd) sits. If the cwd is not part
  of a code repository, check the nearest `AGENTS.md` for paths to all the
  projects in the current workspace, else find all code repositories in nested
  subdirectories — assume they are all components of the target codebase. If the
  target codebase cannot be found, stop and alert the user.

- Where to write the report — REQUIRED.
  If not specified by the user, check the nearest `AGENTS.md` file for the path
  or URL to the audit reports. If not found, check if the current working
  directory has an `audits/` subdirectory that contains audit reports. If the
  path to the audit reports cannot be found, stop and alert the user.

**Output:** An artifact capturing candidates for architecture improvements, each
candidate citing specific files and lines, stating what is observed and the cost
it imposes, and optionally pointing toward a fix. The report is written to the
audit reports store, following the conventions defined there.

Security and privacy findings are out-of-scope for this skill. If you notice a
security concern during the review — eg. an injection point, a broken auth
boundary, unsafe secrets handling — do NOT write it up as an audit finding.
Instead note it for referral to a threat modeling session, then continue the
architecture review.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Establish scope.**

    You MUST decide what is in scope — which repositories, services, or
    directories — based on the target codebase. If a URL is provided, you MUST
    assume the target repository is to be cloned.

    You SHOULD pin the codebase to a specific revision, eg.
    `owner/repo@<commit-sha>`, where possible.

2.  **Identify modules.**

    You MUST analyze the target codebase and identify the major component parts
    of the system, and SHOULD identify the architectural tiers, eg. UI, services,
    domain, infrastructure.

3.  **Identify communication patterns.**

    You SHOULD identify the communication patterns and protocols between the
    major layers, and between the components within each layer.

4.  **Check on module depth.**

    For each significant module, you SHOULD ask: if I removed this module, where
    would its complexity go?

    If complexity would concentrate elsewhere in a worse arrangement, the module
    is deep — earning its keep. But if the effect would be to simply redistribute
    the complexity, the module is shallow — potentially NOT earning its keep.

    You SHOULD flag shallow modules. They hide a thin layer of behavior behind an
    interface wider than the behavior justifies.

5.  **Examine the module boundaries.**

    You SHOULD enumerate the significant structural boundaries — between
    architectural tiers, between modules, and at the edges where the system
    integrates with external services or stores.

    For each, ask: is the boundary in the right place, and does it leak? A clean
    boundary exposes a narrow, intention-revealing interface and hides its
    internals; a leaky one forces callers to know about the other side's
    representation, ordering, or lifecycle.

    You SHOULD flag boundaries that are misplaced, too wide, or that leak
    implementation detail across the divide.

    (Trust boundaries — where data crosses from an untrusted actor — are a
    security concern, out of scope here. You MUST note any you spot for referral
    to a threat modeling session, and move on.)

6.  **Look for these specific code smells.**

    - **Wide interfaces relative to behavior.** Many exported functions for
      thin underlying logic. Often the boundary is in the wrong place.

    - **Tangled dependencies.** Modules importing each other directly or via
      chains that resist independent change. Touching one requires touching
      several.

    - **Single-caller abstractions.** An interface, base class, or helper
      used by exactly one caller. The abstraction wasn't earned.

    - **Repeated patterns not yet abstracted.** Three or more places doing
      the same shape of work, none extracted. Worth promoting to a named
      concept.

    - **Inverted dependencies.** Lower-level modules importing higher-level
      ones. Stable code depending on volatile code.

    - **Names that don't match content.** A utility doing domain logic, a
      "manager" with a single method, or a "service" component that's actually
      just a thin DAO.

7.  **Prioritize findings by impact ÷ effort.**

    - **Impact:** How much the rest of the codebase simplifies if this is fixed.
      Findings that unlock other improvements rank high.

    - **Effort:** How invasive the change would be. Local renames rank above
      cross-cutting restructures.

    You MUST assign each finding a **Priority** — HIGH, MEDIUM, or LOW — from
    this ranking, and MUST order the report by it. The top entry is the cheapest
    high-impact fix.

    If more than 10 candidates remain after ranking, you MUST delete the
    lowest-ranking entries so the report is capped at 10.

8.  **Write the report.**

    You MUST write the report into the project's audit-report collection. You
    MUST follow the instructions in the audit reports collection or repository,
    identified via user input. Look for an `AGENTS.md` file, else `README.md`.
    You SHOULD follow instructions in local agent skills files, if useful.

    If no instructions can be found, you SHOULD analyze existing audit reports,
    establish common conventions, and follow those conventions in the writing of
    your new report.

## Rules

- **You MUST NOT read existing design docs, threat models, etc.**

  You MUST NOT read any design documentation or threat models that you find.
  You MUST form your judgment from analysis of the code alone. Knowledge
  of the _intended_ architecture would bias your review toward the design
  trade-offs already considered; the audit SHOULD surface genuinely novel
  suggestions.

  The evaluation MUST be your honest, independent assessment of the as-built
  system.

- **Discovery only: you MUST NOT change code.**

  You MUST NOT change any code in the audited repositories.

- **You MUST NOT commit, branch, file issues, or open pull requests.**

  Your only output is your report, written to disk. You MUST NOT commit it,
  create a branch for it, file issues, or open pull requests to implement
  your findings, where the target path is within a version control repository.

  The collection's own workflow — a human, or a companion skill — owns
  branching, committing, and indexing. Writing the report file is where this
  skill MUST stop. The user SHALL decide what to do with your report next.

- **You SHOULD cite files and lines.**

  Be concrete. Every finding SHOULD name specific paths where possible.
  Vague findings ("the API layer is messy") SHOULD be avoided.

- **You MAY suggest options for fixes.**

  You MUST state your findings before offering any suggestions about how to
  improve things.

  A pointer toward a fix is OPTIONAL, and MUST stay a pointer — never a
  worked-out alternative design.

  Your _observations_ are the deliverable. A reader MAY reject your
  suggested fixes but still find the observations useful.

- **Security and privacy findings are out of scope.**

  This skill evaluates architecture only. You MUST NOT report security or
  privacy weaknesses — injection points, broken auth boundaries, unsafe secrets
  handling, and the like — as audit findings. If you notice one, note it for
  referral to a threat modeling session and the
  [risk register](https://github.com/kieranpotts/risks), then continue the
  architecture review. See the **[probe](../probe/)** skill.

- **"Not worth fixing" MAY be a valid conclusion.**

  Not every smell earns a fix. Where the cost of the change would exceed the
  cost of the smell, you SHOULD say so — recording it as low priority, with the
  rationale.

- **You MUST stay within the codebase's idioms.**

  You MUST NOT flag style choices that are consistent across the codebase as
  smells just because you would prefer a different style. The audit MUST target
  structural problems, not preferences.

## Success criteria

- **The report MUST cite a specific file for every finding.**

  Each finding MUST name a module/file path and a concrete observation. Vague
  platitudes MUST NOT appear.

- **Findings MUST be prioritized by impact ÷ effort.**

  Each finding MUST carry a Priority (High / Medium / Low) derived from the
  ranking, and the report MUST be ordered by it. A reader SHOULD be able to
  stop after the top three entries and still have something actionable.

- **The audited repositories MUST be left unchanged.**

  Their tracked files MUST be unchanged after this skill runs — `git diff` over
  them MUST be empty. The new report file in the audit-report collection MUST be
  the only expected artifact.

- **The report MUST exist on disk and MUST NOT be committed.**

  The report file MUST be present at the location the collection's conventions
  (or `AGENTS.md`) specify, and `git status` MUST show it untracked — never
  staged or committed by this skill.

- **The report MUST be bounded.**

  It MUST contain between 5 and 10 findings, and MUST NOT exceed 10. It
  MUST NOT be an exhaustive enumeration of every observed smell.

- **The report MUST conform to the audit template.**

  It MUST carry the metadata header (including the Subject snapshot), a findings
  table, and per-finding Type / Priority / Location — matching the project's
  `TEMPLATE.md`, or the fallback structure where none exists.
