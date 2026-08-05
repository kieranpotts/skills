---
name: audit
description: >-
  Evaluate the evolving architecture for modularity, consistency, coupling, etc.
  Security and privacy is out-of-scope. Use this skill when the user says
  something like "audit this codebase", "do an architectural audit", or
  "is the design still sound?".
compatibility: requires Read, Grep, Glob, Write, Bash (git clone)
license: CC0-1.0
---

# Audit

Audit the as-built static structure of a software system. Report code smells
and anti-patterns like shallow abstractions, tangled dependencies, single-caller
wrappers, inverted dependencies, and misnamed abstractions. Uncover edge cases,
such as uncommon failure modes, that are not handled gracefully.

This task is scoped to static review of code and data structures. Review of
security and privacy is out-of-scope. Review of dynamic qualities observed at
runtime, such as latency and throughput, is also out-of-scope.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message.

- **Target codebase — REQUIRED.** Determine the path or URL of the codebase
  that will be the subject of your audit. If a URL, clone the repository to
  a temporary local directory. If the codebase location is not explicitly
  defined, look in the environment. If the current working directory (cwd) is
  within a code repository, assume that is the target codebase.

- **Audit reports store — REQUIRED.** The audit reports may be saved to a
  directory within the target codebase, a separate repository, or an external
  service such as a wiki.

## Success criteria

- The report MUST be an artifact capturing candidates for architecture
  improvements.

- Each candidate MUST cite specific files and lines, stating what is observed
  and the cost it imposes.

- Vague platitudes like "the API layer is messy" MUST NOT appear in your report.

- The report MUST be written to the audit store, following whatever
  conventions that store defines for itself.

- Exactly one report MUST exist for this audit.

- Findings SHOULD be prioritized, following the conventions of the audit store.

## Instructions

1.  Decide what is in scope — which repositories, services, or directories —
    based on the target codebase. Try to pin the codebase to a specific revision,
    eg. `owner/repo@<commit-sha>`, else assume the `HEAD` commit of the default
    branch.

2.  Read the source code.

3.  Read the data schema. Look for migrations files or object-relational mappings
    from which the data schema of the persistence layers can be determined.

4.  Identify modules. Analyze the target codebase and identify the major
    component parts of the system. Identify the architectural tiers, eg. UI,
    services, domain, infrastructure.

5.  Identify the communication patterns and protocols between the major
    layers, and between the components within each layer.

6.  Check on module depth. For each significant module, ask "if I removed this
    module, where would its complexity go?" If complexity would concentrate
    elsewhere in a worse arrangement, the module is deep — earning its keep.
    But if the effect would be to simply redistribute the complexity, the
    module is shallow — potentially NOT earning its keep.

    Shallow modules hide only a thin layer of behavior behind an interface wider
    than the behavior justifies. Flag these in your audit report.

7.  Enumerate the significant structural boundaries — between architectural
    tiers, between modules, and at the edges where the system integrates with
    external services or stores.

    For each boundary, ask "is the boundary in the right place, and does it
    leak?" A clean boundary exposes a narrow, intention-revealing interface and
    hides its internals. A leaky one forces callers to know about the other
    side's representation, ordering, or lifecycle.

    In your audit report, flag boundaries that are misplaced, too wide, or
    that leak implementation detail across the divide.

    Trust boundaries — where data crosses from an untrusted actor — are a
    security concern, and are out-of-scope here.

8.  Look for the following code smells.

    - Wide interfaces relative to behavior. Many exported functions for thin
      underlying logic. Often the boundary is in the wrong place.

    - Tangled dependencies. Modules importing each other directly or via chains.
      If changing one module will necessitate changes in other modules, the
      modules are too tightly coupled and are not truly modular.

    - Single-caller abstractions. An interface, base class, or helper used by
      exactly one caller. Such abstractions probably aren't earned.

    - Repeated patterns not yet abstracted. Three or more places doing the same
      shape of work, none extracted. May be worth extracting to a named concept.

    - Inverted dependencies. Lower-level modules importing higher-level ones.
      Stable code depending on more volatile code.

    - Names that don't match content or behavior. A utility doing domain logic,
      a "manager" with a single method, or a "service" component that's
      actually just a thin DAO.

9.  Prioritize findings by impact ÷ effort.

    For each finding, determine:

    - Impact. How much the rest of the codebase will be simplified if the issue
      is fixed. Findings that unlock other improvements rank high.

    - Effort. How invasive the change would be. Local renames rank above
      cross-cutting restructures.

    - Priority. From the impact and effort scores, determine an overall priority
      rating, following the audit stores own conventions.

    Order the findings by priority. The highest priority items are those that
    will yield the highest impact relative to the effort involved.

10. Write your report. Follow the instructions and conventions defined in
    the audit store itself.

    Check if the new report has already been scaffolded, ready for you to fill
    out. Otherwise generate a new audit report from scratch.

## Rules

- You MUST NOT read existing design docs, threat models, etc. You MUST form your
  judgment from analysis of the code and data structures alone. Knowledge of
  design trade-offs already considered would bias your review. Your evaluation
  of the architecture MUST be your honest, independent assessment of the
  _as-built_ system, not the _intended_ design.

- Discovery only. You MUST NOT change any code or other production artifacts.
  You MUST NOT commit, branch, file issues, or open pull requests against the
  code repositories of the audited codebases.

- Focus audit reports on findings, not fixes. Your _observations_ are the
  deliverable. You MAY suggest fixes and alternative designs, but strictly
  these are out-of-scope for audit reports, so mention them only in passing.

- Security and privacy findings are out-of-scope. You SHOULD NOT report security
  or privacy weaknesses — eg. injection points, broken auth boundaries, unsafe
  secrets handling, etc. Security review is a separate exercise, with its own
  tools and methods

- Stay within the codebase's idioms. You MUST NOT flag style choices that are
  consistent across the codebase as smells, just because you would prefer a
  different style. Your audit report MUST target structural problems, not
  preferences.
