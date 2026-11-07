---
name: audit
description: >-
  Evaluate the as-built architecture of a codebase for modularity, coupling,
  consistency, and misplaced boundaries, and record the findings as an audit
  report. Use this skill when the user says something like "audit this codebase",
  "do an architectural audit", or "is the design still sound?". Do not use it to
  review security, privacy, or runtime performance.
compatibility: >-
  requires Read, Glob, Grep, Write, Edit, Bash (git clone)
license: CC0-1.0
---

# Audit

Audit the as-built static structure of a software system and report the code
smells and anti-patterns you find, such as shallow abstractions, misnamed
abstractions, tangled dependencies, inverted dependencies, single-caller
wrappers, and unhandled failure modes.

## Parameters

Determine the following information from the session context and local
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Target codebase — REQUIRED.** The path or URL of the codebase under audit.
  If a URL, clone the repository to a temporary local directory. If no location
  is specified, but if the current working directory sits within a code
  repository, treat that repository as the target.

- **Audit reports store — REQUIRED.** This is where you will file your audit
  report. Resolve it from the session context, then from the local environment.
  The store may be a directory inside the target codebase, a separate repository,
  or an external service such as a wiki — do not assume the store exists on the
  local filesystem.

- **Revision — OPTIONAL.** A specific revision, usually a Git commit hash,
  that is the subject of the audit, eg. `owner/repo@<commit-sha>`. Default to
  the `HEAD` commit of the checked-out branch, else the `HEAD` commit of the
  default branch.

## Success criteria

- Exactly one report MUST exist for this audit, written to the audit reports
  store, and following whatever conventions that store documents for itself.

- Every finding MUST cite specific files and lines, state what is observed, and
  describe the cost that the found pattern imposes. Unsubstantiated
  generalizations such as "the API layer is messy" MUST NOT appear in the
  audit report.

- Findings SHOULD be ordered by priority, using the store's own rating scheme
  if it specifies one.

- The audited codebase MUST be byte-for-byte unchanged, with no commits,
  branches, issues, or pull requests raised against it.

- The audit report MUST NOT carry security, privacy, or runtime-performance
  findings. These concerns fall outside of the scope of a basic code audit.

## Instructions

1.  Decide what is in scope — which repositories, services, or directories. Pin
    the codebase to a specific revision so the findings stay attributable when
    the code moves on.

2.  Read all the source code.

3.  Read the data schema. Look for migration files or object-relational mappings
    from which the schema of the persistence layers can be derived. Also look
    for domain entities, value objects, and other structures that describe the
    formats in which data flows through the software system at runtime.

4.  Identify the major component parts of the system, and the architectural
    tiers they sit in, eg. UI, services, domain, infrastructure, vendor, etc.

5.  Identify the communication patterns and protocols between the tiers, and
    between the components within each tier.

6.  Check module depth. For each significant module, ask "if I removed this
    module, where would its complexity go?" If complexity would concentrate
    elsewhere in a worse arrangement, the module is deep (a good thing). If the
    effect would be to merely redistribute the complexity, the module is shallow,
    hiding a thin layer of behavior behind an interface wider than that behavior
    justifies. Flag shallow modules as a code smell.

7.  Enumerate the significant structural boundaries — between tiers, between
    modules, and at the edges where the system integrates with external services
    or stores. For each boundary, ask "is it in the right place, and does it
    leak?" A clean boundary exposes a narrow, intention-revealing interface and
    hides its internals. A leaky one forces callers to know about the other
    side's representation, ordering, or lifecycle. Flag boundaries that are
    misplaced, too wide, or that leak implementation detail across the divide.

8.  Look for the following code smells.

    - Wide interfaces relative to behavior. Many exported functions for thin
      underlying logic. This is a code smell that the boundary may be in the
      wrong place.

    - Single-caller abstractions. An interface, base class, or helper used by
      exactly one caller. Such abstractions probably are not earned.

    - Repeated patterns not yet abstracted. Three or more places doing the same
      shape of work, none extracted. These patterns may be worth abstracting
      behind a new named concept.

    - Tangled dependencies. Modules importing each other directly or via chains.
      If changing one module forces changes in others, the components are too
      tightly coupled to be truly modular.

    - Inverted dependencies. Lower-level modules importing higher-level ones,
      or stable code depending on more volatile code.

    - Names that do not match content or behavior. A utility doing domain logic,
      a "manager" with a single method, or a "service" that is really a thin
      data-access object.

9.  Prioritize the findings by impact divided by effort. Impact is how much the
    rest of the codebase would be simplified by a fix. Findings that unlock
    other improvements should rank highly. Effort is how invasive the change
    would be. Local renames rank above cross-cutting restructures. Convert the
    two into an overall priority using the store's own rating scheme, and order
    the findings by it.

10. Write the audit report, following the instructions and conventions defined
in the audit report store itself. Check first whether a blank audit report has
already been scaffolded for you to fill out, eg. a template. If not, compose
your audit report entirely from scratch.

## Rules

- You MUST NOT read existing design docs, decision records, or risk registers.
  Form your judgment from the code and data structures alone. Knowledge of the
  trade-offs already considered would bias your review. The deliverable is an
  honest, independent assessment of the _as-built_ system, not of the _intended_
  design.

- This is discovery only. You MUST NOT change any code or other production
  artifacts. You MUST NOT commit, branch, file issues, or open pull requests
  against the audited codebase.

- You SHOULD focus the audit report on findings rather than fixes. The
  observations are the deliverable. You MAY note a candidate fix or alternative
  design in passing, but designing the remedy belongs to a later exercise.

- You SHOULD NOT report security or privacy weaknesses — injection points,
  broken auth boundaries, unsafe secrets handling. Trust boundaries, where
  data crosses from an untrusted actor, are likewise out-of-scope.

- You SHOULD NOT report dynamic qualities observed at runtime, such as latency
  and throughput. This audit is a review of _static_ code and data structures.

- You MUST NOT flag style choices that are consistent across the codebase as
  smells merely because the style is unconventional Stay within the codebase's
  idioms. Report structural problems, not your preferences.
