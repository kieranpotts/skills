---
name: specify
description: >-
  Transform a product requirements document into a formal software
  requirements specification, written as testable acceptance criteria. Use
  when the user says something like "turn this into acceptance criteria",
  "turn this into a spec", "write up the requirements", or "prepare these as
  software requirements", or after a discovery step has produced a PRD. Do
  not use it to gather or invent requirements: an incomplete PRD is rejected,
  not filled in.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, Bash (git, review host CLI)
license: CC0-1.0
---

# Specify

Turn a product requirements document (PRD), or other informal requirements
written in business language, into a formal software requirements
specification expressed as testable acceptance criteria. Reject requirements
too vague or incomplete to specify rather than filling the gaps yourself. This
is specification work only: make no changes to the software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on the substance
of the requirements; if the PRD is inadequate, reject it rather than asking.
You MAY prompt solely to establish where the specification lives and how to
file into it, when context and environment do not settle it.

- **A PRD to transform — REQUIRED.** Supplied as a file path, pasted text, or
  the output of an earlier step in this session. It is expected to be complete
  enough to specify from; this skill neither gathers requirements nor
  interviews the user.

- **The specification store — REQUIRED.** Where the project keeps its
  requirements, and how to file into it. Discover this rather than assuming
  it: check this session's context first, then the environment (a convention
  file such as `AGENTS.md`, a workspace manifest, a configured tool or
  connector). If neither settles it, ask the user. The store MAY be a
  directory in this repository, a separate repository, or an external
  service — do not assume a filesystem path, a file name, or a document
  structure.

## Success criteria

- The specification MUST exist in the project's store, filed by that store's
  own scaffold → author → mark-ready procedure, and left at whatever state
  the store uses for "awaiting review".

- Every rule and example in the PRD MUST be traceable to at least one
  acceptance criterion, and each feature MUST name who it is for, what they
  achieve, and why — carried from the PRD's outcome and stakeholders.

- The specification MUST cover functional and non-functional requirements
  both, stating explicitly that there are no new NFRs beyond the system
  baseline where that is the case, and MUST carry an explicit out-of-scope
  list naming deferred features and adjacent functionality.

- The specification MUST read as behavior only, with no implementation detail
  leaking in — no chosen technology, schema, algorithm, or module layout.

- Where the PRD fell short of the store's readiness bar, nothing MUST have
  been written to the store, and the output MUST instead be an itemized list
  of the gaps.

- The software itself MUST be unchanged — no application code, tests, build
  configuration, or dependencies touched — and the specification MUST NOT
  have been approved or advanced past "awaiting review".

- The closing message MUST state that the requirements are filed and await
  the user's approval, MUST say that design cannot begin until the
  specification is approved, and MUST link whatever the store produced.

## Instructions

1.  Read the PRD.

    Obtain it from the supplied file path, pasted text, or earlier session
    output, and read it in full before doing anything else. If no PRD is
    supplied and none can be found, reject immediately and tell the user a
    PRD must be gathered first.

2.  Validate the PRD for completeness.

    Check that the PRD supplies all of the following:

    - User, goal, and value — who it is for, what outcome they want, and
      why it matters.

    - Rules — the business rules governing the behavior, each a clear
      declarative statement.

    - Examples and counter-examples — for each rule, at least one concrete
      case where it applies and one similar case where it does not.

    - Scope, in both directions — an explicit out-of-scope list, not just
      what is in.

    - Non-functional requirements — stated, or explicitly absent beyond the
      system baseline.

    - Blocking open questions resolved — any question whose answer is needed
      to write a rule or an acceptance criterion.

    If any of these is missing or ambiguous, reject the PRD with a specific,
    itemized list of what is absent or unclear. Purely mechanical gaps (a
    title derived from the goal, scenario ordering, tidy phrasing) MAY be
    normalized without rejecting; the bar for rejection is substantive
    incompleteness.

3.  Locate the specification store.

    Work outward: what the session context already tells you, then the
    environment — a convention file at the project root, a workspace
    manifest, a configured connector to a tracker or wiki. If none of that
    settles it, ask the user.

4.  Learn the store's own workflow.

    Read whatever the store publishes about itself — its convention file,
    contributor documentation, templates, or bundled procedures — to
    establish its document template, its lifecycle states, and the mechanics
    it expects for filing a change (branching, review, labelling,
    discussion). Follow whatever it prescribes.

    If the store documents no procedure at all, infer its conventions from
    the artifacts already in it, and say in your report what you inferred.

5.  Scaffold the change by the store's own procedure.

    Create the document from the store's template and set up whatever review
    vehicle it uses. Derive the change description, its identifier, and its
    type from the PRD's outcome rather than prompting for them. Preserve the
    originating PRD as the origin artifact where the store provides for it.

6.  Author the specification content.

    Read the store's content-authoring conventions — a documented procedure
    if it names one, otherwise its style guide or best-practice
    documentation — and apply its rules to the validated PRD, mapping:

    - The PRD's rules and examples → functional acceptance criteria.

    - The PRD's non-functional requirements → the store's form of measurable
      quality requirements.

    - The PRD's outcome and stakeholders → the user, goal, and value.

    - The PRD's out-of-scope list → the specification's out-of-scope
      boundary.

    If the store defines a readiness checklist and checking it surfaces a gap
    stemming from missing PRD information, return to step 2 and reject.

7.  Mark the change ready by the store's own procedure.

    Once the content meets whatever readiness bar the store defines, carry
    out its checks and advance the change to its "ready for review" state.

8.  Report the outcome and the approval still required.

    Tell the user plainly that the requirements are filed and awaiting
    review, and that the next SDLC phase — design — does not start until
    they approve the specification. Link whatever the store produced: the
    document, its review vehicle, and any discussion thread.

## Rules

- You MUST NOT gather requirements interactively.

  The input to this skill is a PRD. Eliciting missing requirements is
  separate work, done with the user's full attention; smuggling it into a
  specification run produces requirements nobody agreed to.

- You MUST reject substantive gaps rather than invent content.

  A missing rule, example, counter-example, scope boundary, or measurable
  NFR target is grounds for rejection. Only purely mechanical gaps MAY be
  filled without rejecting.

- You MUST discover artifact locations and conventions, and MUST NOT assume
  them.

  This skill runs across projects that keep requirements in different places,
  formats, and tools. A path, file name, template, or section structure that
  is right in one project is wrong in the next. If you cannot establish where
  requirements belong — from context, from the environment, or by asking —
  report what you could not resolve and stop, rather than inventing a
  destination.

- You MUST defer the content rules and the filing mechanics to the store.

  The acceptance-criteria format, how NFRs are expressed, the artifact
  taxonomy, the readiness bar, the branch convention, and the lifecycle
  states all belong to the target store, and you MUST read them fresh each
  time rather than hard-coding any of them here.

- You SHOULD prefer agent-facing guidance where a store publishes both.

  Where an agent-facing convention file sits alongside human-facing
  contributor documentation, follow the agent-facing one. They may differ
  deliberately.

- You MUST run autonomously once the PRD passes validation.

  Drive the scaffold, author, and mark-ready phases through to the store's
  "awaiting review" state without pausing for input. Stop only to reject a
  validation failure surfaced mid-run, or to ask where an artifact lives when
  that cannot be discovered.

- You MUST specify the need the PRD states, not transcribe its words.

  Translate the outcome and rules into criteria that meet the underlying
  need. If the PRD is internally incoherent, or its stated solution plainly
  will not meet its own stated goal, reject it and name the contradiction.

- You MUST NOT approve the specification or begin design work.

  Approval, and everything downstream of it, is the user's decision.

## Edge cases

- The specification store cannot be discovered.

  Nothing in context or the environment names one. Ask the user where
  requirements belong. If they cannot say either, tell them the project has
  no home for requirements and stop — do not write them into an arbitrary
  file.

- The store is an external service rather than a repository.

  A tracker, wiki, or documentation platform. The procedure is unchanged:
  learn its conventions, file the requirements as it expects, and report the
  resulting item. If you have no means to write to it, say so and output the
  specification for the user to file manually.

- Spike or research task.

  The goal is to learn, not to ship a feature. Write the specification as a
  list of questions to answer, with a time-box, rather than as acceptance
  criteria.

- Bug fix.

  The acceptance criteria capture behavior that is wrong today and should be
  correct after the fix — the reproduction as preconditions and trigger, the
  correct behavior as the expected outcome — expressed in the store's own
  format.

- Refactor or internal change.

  There are no new acceptance criteria. A pure internal-quality change is not
  specification work and does not belong here; the existing criteria continue
  to pass unchanged.

- The PRD contradicts requirements already in the store.

  Do not silently rewrite what is already there. Surface the conflict in the
  change and its discussion thread for reviewers to resolve, citing both the
  existing criterion and the conflicting PRD rule.
