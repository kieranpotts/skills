---
name: audit
description: >-
  Evaluate the as-built architecture and security posture of a software
  system, in one pass. Report code smells and anti-patterns like shallow
  abstractions, tangled dependencies, and single-caller wrappers, alongside
  security weaknesses like broken trust boundaries, injection points, and
  unsafe secrets handling. Evaluation only – no code changes. Use this skill
  when the user says "audit this codebase", "audit the architecture", "check for
  security issues", "is the design still sound?", or "check the codebase for
  structural drift".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/software-architect
---

# Audit

**Input:**

- **The target codebase. REQUIRED.** Unless the user inputs an explicit target
  path or URL, assume the target is the code repository in the current working
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

A single prioritized, bounded report covering both architecture and security
improvement candidates, each citing specific files and lines, stating what
is observed and the cost it imposes, and optionally pointing toward a fix.
Findings from both concerns are ranked together in one list, not split into
separate reports — a codebase's most pressing problem might be architectural
or might be a security gap, and the report should say which, rather than
assume one matters more by construction. The report is written to the audit
reports collection or repository, following the conventions defined there.

**Interactivity:**

Agents MUST NOT block for user input after the initial prompt. Agents MUST
follow this skill's instructions to completion, or fail with an error message.

##  Instructions

1.  **Establish scope.**

    Decide what is in scope — which repositories, services, or directories —
    based on the target codebase. If a URL is provided, assume the target
    repository is to be cloned.

    Is it possible to pin the codebase to a specific revision, eg.
    `owner/repo@<commit-sha>`?

2.  **Identify modules.**

    Analyze the target codebase and identify the major component parts of the
    system. Identify the architectural tiers, eg. UI, services, domain,
    infrastructure.

3.  **Identify communication patterns.**

    Identify the communication patterns and protocols between the major
    layers, and between the components within each layer.

4.  **Check on module depth.**

    For each significant module, ask: if I removed this module, where would
    it's complexity go?

    If complexity would concentrate elsewhere in a worse arrangement, the module
    is deep — earning its keep. But if the effect would be to simply redistribute
    the complexity, the module is shallow — potentially NOT earnings its keep.

    Flag shallow modules. They hide a thin layer of behavior behind an interface
    wider than the behavior justifies.

5.  **Identify the trust boundaries.**

    Enumerate every point where data or control crosses a trust boundary, eg.
    external input entering the system, calls to other services, reads/writes
    to store, and privilege changes.

    For each, ask: what does this side trust the other side to have already
    checked?

    Flag components that implicitly trust things on another side of a
    boundary.

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

7.  **Look for these specific security risks.**

    - **Injection points.** User-controlled input reaching a query,
      command, template, or interpreter without a parameterized API or an
      escaping boundary between them.

    - **Broken authentication or authorization boundaries.** An action or
      resource reachable without the check its sibling endpoints enforce.
      Authorization decided client-side or inferred from data the caller
      controls.

    - **Unsafe secrets handling.** Credentials, keys, or tokens in source,
      logs, error messages, or client-visible responses. Long-lived secrets
      where short-lived ones would do.

    - **Insecure defaults.** A configuration, flag, or dependency that ships
      permissive, verbose, or unauthenticated unless explicitly hardened.

    - **Missing validation at trust boundaries.** Input trusted past the
      point where it first crosses from an untrusted actor, rather than
      checked at the boundary itself.

    - **Unsafe dependency or supply-chain patterns.** Unpinned versions,
      unverified sources, or install-time script execution for third-party
      code that runs with production privileges.

8.  **Prioritize findings by impact ÷ effort.**

    - **Impact**: How much the rest of the codebase simplifies if this is fixed.
      Findings that unlock other improvements rank high.

    - **Effort**: How invasive the change would be. Local renames rank above
      cross-cutting restructures.

    Assign each finding a **Priority** — HIGH, MEDIUM, or LOW — from this
    ranking, and order the report by it. The top entry is the cheapest
    high-impact fix.

    Cap the report at 10 candidates.

9.  **Write the report.**

    Write the report into the project's audit-report collection.

    Follow the instructions in the audit reports collection or repository,
    identified via user input. Look for an `AGENTS.md` file, else `README.md`.
    Follow instruction in local agent skills files, if useful.

    If no instructions can be found, analyze existing audit reports, establish
    common conventions, and follow those conventions in the writing of your
    new report.

##  Rules

-   **Do NOT read existing design docs, threat models, etc.**

    Do NOT read any design documentation or threat models that you find.

    You MUST form your judgment from analysis of the code alone. Knowledge
    of the _intended_ architecture and security controls would bias your review
    toward the design trade-offs already considered. We're looking for you to
    surface genuinely novel suggestions.

    We want your honest, independent evaluation of the as-built system.

-   **Discovery only.**

    Do NOT change any code in the audited repositories.

-   **Do not commit the report.**

    Your only output is your report, written to disk. Do NOT commit it, if the
    target path is within a version control repository.

    The user will decide what next to do with your report.

-   **Do NOT open issues or PRs.**

    Only write your report to disk. Do NOT file issues or open pull requests
    to implement your findings.

-   **Cite files and lines.**

    Be concrete. Every finding SHOULD name specific paths, if possible.

    Vague findings ("the API layer is messy") are not so useful.

-   **Observation first; any pointer is optional.**

    State what you see and the cost it imposes before offering any suggestion.

    A pointer toward a fix is OPTIONAL , and MUST stay a pointer — never a
    worked-out alternative design.

    The observation is the deliverable; a reader may reject the pointer and still
    find the observation valuable.

-   **"Not worth fixing" is a valid conclusion.**

    Not every smell earns a fix. If the cost of the change would exceed the cost
    of the smell, say so — record it as low priority, with the rationale.

-   **Stay within the codebase's idioms.**

    Don't flag style choices that are consistent across the codebase as smells
    just because you'd prefer a different style. Audit is for structural
    problems, not preferences.

    - **Do NOT commit, branch, or open a pull request.** The collection's own
      workflow — a human, or a companion skill — owns branching, committing, and
      indexing. Writing the report file is where this skill stops.

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

-   The project's `audits/README.md` and `audits/TEMPLATE.md`, where present
    (often a separate sibling repository, eg.
    [`kieranpotts/audits`](https://github.com/kieranpotts/audits), pointed to
    from the target project's `AGENTS.md`) — the authoritative conventions
    for the report's path, structure, and lifecycle.

-   [`refactor`](../refactor/): Consumes an architecture audit's findings to
    propose and make the changes the user chooses to act on.
