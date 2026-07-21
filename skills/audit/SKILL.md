---
name: audit
description: >-
  Evaluate the evolving architecture — modularity, consistency, coupling, etc.
  Security and privacy is out-of-scope. Use this skill when the user says
  something like "audit this codebase", "do an architectural audit", or "is the
  design still sound?".
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
security and privacy is out-of-scope. Review of dynamic qualities observed
at runtime, such as latency and throughput, is also out-of-scope.

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
  Find the location of the existing audit reports collection for the target
  codebase. If not specified by the user, check the nearest `AGENTS.md` file for
  the path or URL to the audit reports. If not found, check if the current working
  directory has an `audits/` subdirectory that contains audit reports. If the
  path to the audit reports cannot be found, stop and alert the user.

**Output:** An artifact capturing candidates for architecture improvements, each
candidate citing specific files and lines, stating what is observed and the cost
it imposes. The report is written to the audit reports store, following the
conventions defined there.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Establish scope.**

    Decide what is in scope — which repositories, services, or directories —
    based on the target codebase.

    Try to pin the codebase to a specific revision, eg. `owner/repo@<commit-sha>`,
    else assume the `HEAD` commit of the default branch.

2.  **Read the source code.**

3.  **Read the data schema.**

    Look for migrations files or object-relational mappings from which the
    data schema of the the persistence layers can be determined.

4.  **Identify modules.**

    Analyze the target codebase and identify the major component parts
    of the system.

    Identify the architectural tiers, eg. UI, services, domain, infrastructure.

5.  **Identify communication patterns.**

    Identify the communication patterns and protocols between the major
    layers, and between the components within each layer.

6.  **Check on module depth.**

    For each significant module, ask: if I removed this module, where
    would its complexity go?

    If complexity would concentrate elsewhere in a worse arrangement, the
    module is deep — earning its keep. But if the effect would be to simply
    redistribute the complexity, the module is shallow — potentially NOT
    earning its keep.

    Flag shallow modules in the audit report. Shallow modules hide only a
    thin layer of behavior behind an interface wider than the behavior
    justifies.

7.  **Examine the module boundaries.**

    Enumerate the significant structural boundaries — between architectural
    tiers, between modules, and at the edges where the system integrates
    with external services or stores.

    For each boundary, ask: is the boundary in the right place, and does it
    leak? A clean boundary exposes a narrow, intention-revealing interface and
    hides its internals. A leaky one forces callers to know about the other
    side's representation, ordering, or lifecycle.

    In your audit report, flag boundaries that are misplaced, too wide, or that
    leak implementation detail across the divide.

    Trust boundaries — where data crosses from an untrusted actor — are a
    security concern, and are out-of-scope here.

8.  **Look for these specific code smells.**

    - **Wide interfaces relative to behavior.**
      Many exported functions for thin underlying logic. Often the boundary is
      in the wrong place.

    - **Tangled dependencies.**
      Modules importing each other directly or via chains that resist
      independent change. Touching one requires touching several.

    - **Single-caller abstractions.**
      An interface, base class, or helper used by exactly one caller.
      The abstraction wasn't earned.

    - **Repeated patterns not yet abstracted.**
      Three or more places doing the same shape of work, none extracted.
      Worth promoting to a named concept.

    - **Inverted dependencies.**
      Lower-level modules importing higher-level ones. Stable code depending
      on more volatile code.

    - **Names that don't match content.**
      A utility doing domain logic, a "manager" with a single method, or a
      "service" component that's actually just a thin DAO.

9.  **Prioritize findings by impact ÷ effort.**

    For each finding, determine:

    - **Impact.**
      How much the rest of the codebase will be simplified if the issue is
      fixed. Findings that unlock other improvements rank high.

    - **Effort.**
      How invasive the change would be. Local renames rank above cross-cutting
      restructures.

    - **Priority.**
      From the impact and effort scores, determine an overall priority rating
      of `HIGH`, `MEDIUM`, or `LOW`. The highest priority items are those that
      will yield the highest impact relative to the effort involved.

    Order the findings by priority. The top entry will be the cheapest
    high-impact fix.

10.  **Write the report.**

    Follow the instructions in the existing store of audit reports to
    prepare a new architecture audit report, ready for the user to review.

    If no instructions can be found, you SHOULD analyze existing audit reports,
    establish common conventions, and follow those conventions in the writing of
    your new report.

## Rules

- **You MUST NOT read existing design docs, threat models, etc.**

  You MUST form your judgment from analysis of the code and data structures
  alone.

  Knowledge of the _intended_ architecture would bias your review toward the
  design trade-offs already considered.

  Your evaluation of the architecture MUST be your honest, independent
  assessment of the as-built system.

- **Discovery only. You MUST NOT change any code or other production artifacts.**

  In addition, you MUST NOT commit, branch, file issues, or open pull requests
  against the code repositories of the audited codebases.

  Your only output is your report, written to disk as determined by the
  instructions and conventions of the existing store of audit reports.

- **Focus audit reports on findings, not fixes.**

  Your _observations_ are the deliverable. You MAY suggest fixes and alternative
  designs, but strictly these are out-of-scope for audit reports, so mention
  them only in passing.

- **Security and privacy findings are out-of-scope.**

  You SHOULD NOT report security or privacy weaknesses — eg. injection points,
  broken auth boundaries, unsafe secrets handling, etc.

  These concerns are the scope of the **[probe](../probe/)** skill.

- **Stay within the codebase's idioms.**

  You MUST NOT flag style choices that are consistent across the codebase as
  smells, just because you would prefer a different style.

  Your audit report MUST target structural problems, not preferences.

## Success criteria

- **The report MUST cite a specific file for every finding.**

  Each finding MUST name a module/file path and a concrete observation.

  Vague platitudes like "the API layer is messy" MUST NOT appear in your report.

- **Findings MUST be prioritized.**

  Each finding MUST carry a priority of of `HIGH`, `MEDIUM`, or `LOW`,
  calculated based on your assessment of the impact and effort.
