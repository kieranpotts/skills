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
product requirements document (PRD) or other informal requirements written
in business language.

If the requirements are vague or incomplete — or otherwise insufficient to
translate into a formal requirements specification written as testable
acceptance criteria — reject with reasons. You MUST NOT attempt to fill-in
missing requirements.

Specification only. You MUST NOT make any code or configuration changes to the
software itself.

**Input:** Determine the following information from the surrounding context
and environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

<!--
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
-->

- A PRD to transform — REQUIRED.
  Expected to be sufficiently complete to turn into a formal software
  requirements specification. This skill does not gather requirements or
  interview the user; if the PRD is not sufficiently detailed, you MUST
  **reject** it with a list of what is missing or ambiguous, and not proceed
  further.

**Output:** An open pull request against the SRS repository, capturing the
changes as testable acceptance criteria, at `PROPOSED` and awaiting the user's
review and approval.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Read the PRD.**

    You MUST obtain the PRD from the supplied file path, pasted text, or earlier
    session output, and MUST read it in full before doing anything else. If no
    PRD is supplied and none can be found, you MUST reject immediately and tell
    the user a PRD must be gathered first.

2.  **Validate the PRD for completeness.**

    You MUST check that the PRD supplies all of the following:

    - **User, goal, and value** — *who* it is for, *what* outcome they want, and
      *why* it matters.

    - **Rules** — the business rules that govern the behavior, each a clear
      declarative statement.

    - **Examples and counter-examples** — for each rule, at least one concrete
      case where it applies and one similar case where it does not.

    - **Scope, in both directions** — an explicit *out-of-scope* list, not just
      what is in.

    - **Non-functional requirements** — stated, or an explicit statement that
      there are none beyond the system baseline.

    - **Blocking open questions resolved** — any open question whose answer is
      needed to write a rule or an AC.

    If any of these is missing or ambiguous, you MUST reject the PRD, and MUST
    output a specific, itemized list of what is absent or unclear. You MAY
    normalize purely mechanical gaps (a `Feature` title derived from the goal,
    scenario ordering, tidy phrasing) without rejecting; the bar for rejection is
    substantive incompleteness.

3.  **Locate the SRS repository.**

    You MUST read the consuming project's root `AGENTS.md` and find its `Workflow
    repositories` section, then resolve the `SRS` entry to find where
    requirements live. If no `Workflow repositories` section or `SRS` entry
    exists, you MUST tell the user the project is not wired to an SRS, and stop.

4.  **Read the SRS repository's `AGENTS.md` to learn its workflow.**

    You MUST read the SRS repository's own `AGENTS.md` for the proposal template,
    branch convention, lifecycle states, and pull-request, discussion-thread, and
    label rules, and MUST follow whatever it prescribes.

5.  **Scaffold the proposal — follow `draft-spec`.**

    You MUST read the SRS repository's scaffolding skill (`draft-spec`, or the
    equivalent its `AGENTS.md` names) and carry out its procedure yourself:
    create the branch, the proposal document from the template, the draft pull
    request, and the discussion thread. You MUST derive the change description,
    slug, and change type from the PRD's outcome rather than prompting for them.
    You SHOULD preserve the originating PRD as the origin artifact if the
    scaffolding procedure provides for it.

6.  **Author the specification content — follow `write-spec`.**

    You MUST read the SRS repository's content-authoring skill (`write-spec`, or
    its equivalent) and apply its rules to the validated PRD, mapping:

    - The PRD's *rules* and *examples / counter-examples* → functional
      acceptance criteria.

    - The PRD's *non-functional requirements* → the repository's measurable
      quality requirements.

    - The PRD's *outcome* and *stakeholders* → the user, goal, and value.

    - The PRD's *out-of-scope* list → the specification's out-of-scope boundary.

    If checking the Definition of Ready surfaces a gap that stems from missing
    PRD information, you MUST reject the PRD (step 2) and name the gap.

7.  **Mark the proposal ready — follow `propose-spec`.**

    Once the content is authored and meets the Definition of Ready, you MUST read
    the SRS repository's readiness skill (`propose-spec`, or its equivalent) and
    carry out its checks. You MUST verify completeness, then take the pull request
    out of draft for stakeholder review.

8.  **Report the outcome and the required approval.**

    On finishing, you MUST tell the user plainly that the specification proposal
    is filed and `PROPOSED`, and that it now needs their review and approval
    before downstream work begins. You MUST state explicitly that the next SDLC
    phase — design — MUST NOT start until this specification is approved
    (`ACCEPTED`). You MUST link the pull request and its discussion thread.

## Rules

- **You MUST NOT gather requirements interactively.**

  This skill MUST NOT ask the user questions or elicit missing requirements.
  Its input is a PRD. If the PRD is incomplete, you MUST reject it with
  reasons so the requirements can be gathered separately.

- **You MUST reject substantive gaps, and MUST NOT invent content.**

  When the PRD is missing a rule, an example, a counter-example, a scope
  boundary, or a measurable NFR target, you MUST reject. Only purely
  mechanical gaps MAY be filled without rejecting.

- **You MUST read the SRS repository's `AGENTS.md`, not its
  `CONTRIBUTING.md`.**

  `AGENTS.md` is the agent's workflow; `CONTRIBUTING.md` is the human's. They
  may differ deliberately.

- **You MUST NOT hard-code the SRS workflow.**

  The branch convention, proposal template, lifecycle states, and filing
  mechanics live in the target repository. You MUST read them fresh each time.

- **You MUST stop if no SRS is declared.**

  If the project's `AGENTS.md` does not declare an `SRS` location under
  `Workflow repositories`, you MUST NOT write requirements anywhere. You MUST
  tell the user the project is not wired to an SRS.

- **You MUST defer content rules to the SRS repository.**

  The AC format, NFR expression, artifact taxonomy, and Definition of Ready are
  owned by the target SRS repository. You MUST read and apply those rules; you
  MUST NOT hard-code a format from this skill.

- **You MUST run autonomously once the PRD passes validation.**

  After validation, you MUST drive the scaffold → author → mark-ready phases
  through to `PROPOSED` without pausing for user input. You MUST stop only to
  reject a validation failure surfaced mid-run.

- **You MUST specify the need the PRD states, not a literal transcription.**

  You MUST translate the PRD's *outcome* and *rules* into criteria that meet
  the underlying need. If the PRD is internally incoherent, or its stated
  solution plainly won't meet its own stated goal, reject it and name the
  contradiction.

- **You MUST NOT approve the proposal or advance to the design phase.**

  This skill MUST stop at `PROPOSED`. Approval to `ACCEPTED`, and any
  subsequent design work, is the user's decision.

## Edge cases

- **No SRS declared.**

  The project's `AGENTS.md` has no `Workflow repositories` section, or no
  `SRS` entry. Stop and tell the user — the project is not wired to an SRS,
  and requirements have no home. Do not write them into an arbitrary file.

- **Spike or research task.**

  The goal is to *learn*, not to ship a feature. Write the specification as a
  list of questions to answer, with a time-box, rather than as ACs.

- **Bug fix.**

  The AC captures behavior that is wrong today and should be correct after the
  fix — the reproduction as preconditions and trigger, the correct behavior as
  the expected outcome. Express it in the SRS repository's AC format.

- **Refactor or internal change.**

  There are no new ACs. A pure internal-quality change (eg. cyclomatic
  complexity reduced, tests faster, module decoupled) is not specification
  work and does not belong here — the existing ACs continue to pass unchanged.

- **PRD contradicts the existing specification.**

  If the PRD's rules contradict an existing AC already in the SRS, do not
  silently rewrite the existing AC. Surface the conflict in the proposal (and
  its discussion thread) for reviewers to resolve, citing both the existing AC
  and the conflicting PRD rule.

- **Incomplete PRD.**

  The PRD is missing rules, examples, counter-examples, scope, or measurable
  NFRs. Reject it (step 2) with an itemized list of the gaps, so the
  requirements can be gathered before retrying. Write nothing to the SRS.

## Success criteria

- **The proposal MUST reach `PROPOSED` via the repository's own procedure.**

  On a valid PRD, the skill MUST leave an open, non-draft proposal pull
  request labeled for review, created by carrying out the scaffold → author →
  mark-ready procedure defined by the repository's local skills. The format and
  lifecycle rules MUST be read from the local skills.

- **The user MUST be told the specification awaits their approval.**

  The closing message MUST state that the proposal is `PROPOSED`, needs the
  user's review and approval, and that the design phase MUST NOT begin until
  the specification is `ACCEPTED`. The pull request and discussion thread MUST
  be linked.

- **The specification MUST conform to the SRS repository's content rules.**

  The authored artifacts MUST follow the target repository's format and
  conventions — acceptance criteria in the prescribed form, non-functional
  requirements as that repository requires, and implementation detail MUST NOT
  leak in.

- **Functional and non-functional requirements MUST both be present.**

  Even if the NFR section is "no new NFRs — inherits from system baseline",
  it MUST be stated explicitly.

- **Out-of-scope items MUST be named.**

  The specification MUST include an explicit list of deferred features and
  adjacent functionality not under review.

- **The user, goal, and value MUST be carried from the PRD.**

  Each feature block MUST name *who* it is for, *what* they achieve, and
  *why* — traceable to the PRD's outcome and stakeholders.

- **The Definition of Ready MUST be satisfied, or the PRD MUST have been
  rejected for the gap.**

- **An incomplete PRD MUST be rejected, not patched.**

  When the PRD lacks substantive content, the output MUST be an itemized
  rejection naming the gaps. Nothing MUST be written to the SRS.

## Examples

The consuming project locates its SRS through a `Workflow repositories`
declaration in its root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

The shape of the specification content itself — Gherkin acceptance criteria,
measurable non-functional requirements, the out-of-scope section — is defined by
the target SRS repository's content rules (its `write-spec` skill), not here.
This skill validates the PRD, then carries out the procedure that the
repository's `draft-spec` → `write-spec` → `propose-spec` skills define —
reading their rules and running them non-interactively — to file the proposal to
whatever format and process that repository prescribes.
