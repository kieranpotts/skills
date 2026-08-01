---
name: specify
description: >-
  Specify functional and non-functional requirements as testable acceptance
  criteria. Use when the user says something like "turn this into acceptance
  criteria", "turn this into a spec", or "prepare these as software
  requirements".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/product-manager
---

# Specify

Write or update a formal software requirements specification (SRS) from a
product requirements document (PRD) or other informal requirements written in
business language.

If the requirements are vague or incomplete — or otherwise insufficient to
translate into a formal requirements specification written as testable
acceptance criteria — reject with reasons. You MUST NOT attempt to fill in
missing requirements.

Specification only. You MUST NOT make any code or configuration changes to
the software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A PRD to transform — REQUIRED.** Expected to be sufficiently complete to
  turn into a formal software requirements specification. This skill does
  not gather requirements or interview the user; if the PRD is not
  sufficiently detailed, you MUST reject it with a list of what is missing
  or ambiguous, and not proceed further.

- Where the requirements specification lives, and how to file into it —
  REQUIRED. Discover this rather than assuming it: check this session's
  context first, then the environment (a convention file such as `AGENTS.md`,
  a workspace manifest, a configured tool or connector). If neither settles
  it, ask the user. The store MAY be a directory in this repository, a
  separate repository, or an external service — do not assume a filesystem
  path, a file name, or a document structure.

This task otherwise runs non-interactively to completion. You MUST NOT
prompt the user about the substance of the requirements; if the PRD is
inadequate, reject it rather than asking. You MAY prompt solely to establish
where the specification store is and how to file into it, when context and
environment do not settle it.

## Success criteria

You will achieve the following outcomes:

- The requirements filed into the project's specification store as testable
  acceptance criteria, following that store's own conventions, and left at
  whatever state that store uses for "awaiting review" — awaiting the user's
  review and approval.

- The store MUST have been discovered, not assumed.

  The location and access method MUST trace to session context, to the
  environment, or to an answer from the user. No path, file name, or
  document structure MUST have been taken for granted.

- The requirements MUST reach the store's "awaiting review" state via that
  store's own procedure.

  On a valid PRD, the skill MUST leave the change filed and open for
  review, created by carrying out the scaffold → author → mark-ready
  procedure the store defines for itself. The format and lifecycle rules
  MUST be read from the store, not from this skill.

- The user MUST be told the specification awaits their approval.

  The closing message MUST state that the requirements are filed and
  awaiting review, need the user's approval, and that the design phase MUST
  NOT begin until the specification is approved. Whatever the store
  produced MUST be linked.

- The specification MUST conform to the store's content rules.

  The authored artifacts MUST follow the target store's format and
  conventions — acceptance criteria in the prescribed form, non-functional
  requirements as that store requires, and implementation detail MUST NOT
  leak in.

- Functional and non-functional requirements MUST both be present.

  Even if the NFR section is "no new NFRs — inherits from system
  baseline", it MUST be stated explicitly.

- Out-of-scope items MUST be named.

  The specification MUST include an explicit list of deferred features
  and adjacent functionality not under review.

- The user, goal, and value MUST be carried from the PRD.

  Each feature block MUST name who it is for, what they achieve, and
  why — traceable to the PRD's outcome and stakeholders.

- The store's readiness bar MUST be satisfied, or the PRD MUST have been
  rejected for the gap.

- An incomplete PRD MUST be rejected, not patched.

  When the PRD lacks substantive content, the output MUST be an
  itemized rejection naming the gaps. Nothing MUST be written to the
  store.

## Instructions

1.  Read the PRD.

    Obtain the PRD from the supplied file path, pasted text, or earlier
    session output, and read it in full before doing anything else. If no
    PRD is supplied and none can be found, reject immediately and tell
    the user a PRD must be gathered first.

2.  Validate the PRD for completeness.

    Check that the PRD supplies all of the following:

    - User, goal, and value — who it is for, what outcome they want, and
      why it matters.

    - Rules — the business rules that govern the behavior, each a clear
      declarative statement.

    - Examples and counter-examples — for each rule, at least one
      concrete case where it applies and one similar case where it does
      not.

    - Scope, in both directions — an explicit out-of-scope list, not
      just what is in.

    - Non-functional requirements — stated, or an explicit statement
      that there are none beyond the system baseline.

    - Blocking open questions resolved — any open question whose answer
      is needed to write a rule or an AC.

    If any of these is missing or ambiguous, reject the PRD, and output
    a specific, itemized list of what is absent or unclear. Purely
    mechanical gaps (a `Feature` title derived from the goal, scenario
    ordering, tidy phrasing) can be normalized without rejecting; the
    bar for rejection is substantive incompleteness.

3.  Locate the specification store.

    Establish where this project keeps its requirements, and how to write to
    it. Work outward: what the session context already tells you, then the
    environment — a convention file at the project root (`AGENTS.md` or
    equivalent), a workspace manifest, a configured connector to a tracker
    or wiki. If none of that settles it, ask the user.

    The store MAY be a directory in this repository, a sibling repository, or
    an external service. Do not assume any particular form.

4.  Learn the store's own workflow.

    Read whatever the store publishes about itself — its convention file, its
    contributor documentation, its templates, or any procedures it bundles —
    to establish its document template, its lifecycle states, and the
    mechanics it expects for filing a change (branching, review, labelling,
    discussion). Follow whatever it prescribes.

    If the store documents no procedure at all, infer its conventions from
    the artifacts already in it, and say in your report what you inferred.

5.  Scaffold the proposal by the store's own procedure.

    Carry out whatever the store prescribes for starting a new requirements
    change: create the document from its template, and set up whatever
    review vehicle it uses. Derive the change description, its identifier,
    and its type from the PRD's outcome rather than prompting for them.
    Preserve the originating PRD as the origin artifact if the store's
    procedure provides for it.

6.  Author the specification content — follow the store's content rules.

    Read the store's content-authoring conventions — a documented procedure
    if it names one, otherwise its style guide or best-practices
    documentation — and apply its rules to the validated PRD, mapping:

    - The PRD's rules and examples / counter-examples → functional
      acceptance criteria.

    - The PRD's non-functional requirements → the repository's
      measurable quality requirements.

    - The PRD's outcome and stakeholders → the user, goal, and value.

    - The PRD's out-of-scope list → the specification's out-of-scope
      boundary.

    If the store defines a readiness checklist and checking it surfaces a
    gap that stems from missing PRD information, reject the PRD (step 2) and
    name the gap.

7.  Mark the proposal ready by the store's own procedure.

    Once the content is authored and meets whatever readiness bar the store
    defines, carry out its checks and advance the change to that store's
    "ready for review" state.

8.  Report the outcome and the required approval.

    On finishing, tell the user plainly that the requirements are filed and
    awaiting review, and that they now need the user's approval before
    downstream work begins. State explicitly that the next SDLC phase —
    design — does not start until the specification is approved. Link
    whatever the store produced: the document, its review vehicle, and any
    discussion thread.

## Rules

- You MUST NOT gather requirements interactively.

  This skill MUST NOT ask the user questions or elicit missing
  requirements. Its input is a PRD. If the PRD is incomplete, you MUST
  reject it with reasons so the requirements can be gathered separately.

- You MUST reject substantive gaps, and MUST NOT invent content.

  When the PRD is missing a rule, an example, a counter-example, a scope
  boundary, or a measurable NFR target, you MUST reject. Only purely
  mechanical gaps MAY be filled without rejecting.

- You MUST discover artifact locations and conventions; you MUST NOT assume
  them.

  This skill is used across projects that keep their requirements in
  different places, in different formats, under different tools. A path,
  file name, template, or section structure that is right in one project is
  wrong in the next. Resolve the store first — from context, then the
  environment, then by asking — then read and follow whatever conventions
  that store documents for itself.

- You MUST prefer the agent-facing convention file where both exist.

  Where a store publishes both agent-facing and human-facing guidance (eg.
  `AGENTS.md` alongside `CONTRIBUTING.md`), follow the agent-facing one.
  They may differ deliberately.

- You MUST NOT hard-code the filing workflow.

  The branch convention, document template, lifecycle states, and filing
  mechanics belong to the target store. You MUST read them fresh each time.

- You MUST NOT write requirements to an arbitrary location.

  If you cannot establish where requirements belong — from context, from the
  environment, or by asking the user — you MUST NOT invent a destination.
  Report what you could not resolve, and stop.

- You MUST defer content rules to the store.

  The AC format, NFR expression, artifact taxonomy, and readiness bar are
  owned by the target store. You MUST read and apply those rules; you MUST
  NOT hard-code a format from this skill.

- You MUST run autonomously once the PRD passes validation.

  After validation, you MUST drive the scaffold → author → mark-ready
  phases through to the store's "awaiting review" state without pausing for
  user input. You MUST stop only to reject a validation failure surfaced
  mid-run, or to ask where an artifact lives when that cannot be
  discovered.

- You MUST specify the need the PRD states, not a literal transcription.

  You MUST translate the PRD's outcome and rules into criteria that meet
  the underlying need. If the PRD is internally incoherent, or its stated
  solution plainly won't meet its own stated goal, reject it and name
  the contradiction.

- You MUST NOT approve the proposal or advance to the design phase.

  This skill MUST stop at the store's "awaiting review" state. Approval,
  and any subsequent design work, is the user's decision.

## Edge cases

- The specification store cannot be discovered.

  Nothing in context or the environment names one. Ask the user where
  requirements belong. If they cannot say either, tell them the project has
  no home for requirements and stop — do not write them into an arbitrary
  file.

- The store is an external service rather than a repository.

  A tracker, wiki, or documentation platform. The procedure is unchanged:
  learn its conventions, file the requirements as it expects, and report
  the resulting item. If you have no means to write to it, say so and
  output the specification for the user to file manually.

- Spike or research task.

  The goal is to learn, not to ship a feature. Write the specification
  as a list of questions to answer, with a time-box, rather than as ACs.

- Bug fix.

  The AC captures behavior that is wrong today and should be correct
  after the fix — the reproduction as preconditions and trigger, the
  correct behavior as the expected outcome. Express it in the SRS
  repository's AC format.

- Refactor or internal change.

  There are no new ACs. A pure internal-quality change (eg. cyclomatic
  complexity reduced, tests faster, module decoupled) is not
  specification work and does not belong here — the existing ACs continue
  to pass unchanged.

- PRD contradicts the existing specification.

  If the PRD's rules contradict an existing AC already in the SRS, do
  not silently rewrite the existing AC. Surface the conflict in the
  proposal (and its discussion thread) for reviewers to resolve, citing
  both the existing AC and the conflicting PRD rule.

- Incomplete PRD.

  The PRD is missing rules, examples, counter-examples, scope, or
  measurable NFRs. Reject it (step 2) with an itemized list of the gaps,
  so the requirements can be gathered before retrying. Write nothing to
  the SRS.

## Examples

- Discovering the store. Any of these is a valid resolution — the skill
  takes whichever the project actually offers, in this order:

  ```sh
  # 1. Session context — the user or an upstream step already said:
  #    "requirements live in ../acme-specs"

  # 2. Environment — a convention file at the project root:
  ## Workflow repositories
  - SRS: ./docs/specs

    #    …or a directory that plainly holds requirements, …or a configured
    #    connector to a tracker, wiki, or documentation platform.

    # 3. Ask:
    #    "I can't find where this project keeps its requirements.
    #     Where should I file them?"
    ```

The shape of the specification content itself — the acceptance-criteria
format, how non-functional requirements are expressed, the out-of-scope
section — is defined by the target store's own content rules, wherever it
documents them, not here. This skill validates the PRD, discovers the
store, then carries out whatever scaffold → author → mark-ready procedure
that store defines, to file the requirements in whatever format and process
it prescribes.

## References

None.
