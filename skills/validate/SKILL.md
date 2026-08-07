---
name: validate
description: >-
  Judge working software against the originating user need rather than its
  acceptance criteria, and report prioritized gaps in the requirements
  specification. Use when the user says something like "did we build the right
  thing?", "does the software fulfill its goals?", or "what gaps can you find
  in the requirements specification?". Do not use it to check whether the code
  satisfies its acceptance criteria, which is verification, not validation.
compatibility: >-
  requires Read, Glob, Grep, Bash (git clone, running the software)
license: CC0-1.0
---

# Validate

Ask whether the software serves the users' actual needs, and report the gaps
between what the requirements specification says and what the users were
likely to have wanted. This is an evaluation: report prioritized suggestions,
and change no specification and no code.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **Requirements specification — REQUIRED.** The specification under
  validation. Resolve where it lives from the last prompt, then from wider
  context, then from the environment — a convention file, a workspace
  manifest, an existing directory of specifications, a configured connector.
  The store MAY be a directory in this repository, a separate repository, or
  an external service such as a tracker or wiki, so do not assume a filesystem
  path, a file name, or a document structure. Where it is a remote repository,
  clone it locally to read it.

- **Statement of need — OPTIONAL.** A preserved product requirements document,
  discovery report, or equivalent capturing the business requirements and user
  needs the system was commissioned to serve. Resolve it the same way. Where
  none survives, fall back to the specification's own outcome, goal, or
  success-measure sections.

- **Working software — OPTIONAL.** A running instance, or instructions for
  standing one up, so the user's journey can be walked in practice. Default to
  the completed, tested increments in the target repository.

## Success criteria

- The report MUST hold between five and ten findings, ordered by priority.
  A bounded list forces a judgment about what matters; an exhaustive wishlist
  defers that judgment to the reader.

- The report MUST cite the originating need it judged against, or name the
  absence of any surviving statement of need as its first finding.

- Every finding MUST rest on cited evidence — an observed behavior, a
  measurement against a success metric, or a concrete step in the user's
  flow. A gap asserted as preference is not a finding.

- Every finding MUST carry a gap type (unmet need, wrong target, missing
  requirement, over-specification, or stale assumption), a suggested
  direction, and a change cost, so that whoever revises the specification can
  act on it without re-deriving the analysis.

- The report MUST state one of two verdicts explicitly, MEETS THE NEED or
  GAPS FOUND. An implied verdict does not count.

- The working tree MUST be unchanged when the task ends: no specification
  edits, no code edits, no commits, branches, issues, or pull requests.

## Instructions

1.  Recover the original need, not just the acceptance criteria.

    Take the originating intent from the strongest source available, in
    order: the preserved statement of need, the specification's own outcome,
    goal, or success-measure sections, then the discovery record. If no
    statement of need survives anywhere, report that absence as the first
    finding and proceed on the best reconstruction you can defend.

2.  Walk the working software as the user, against that need.

    Exercise the completed, tested increments end-to-end, pursuing the user's
    actual goal rather than the specified steps. For each outcome the
    specification claimed to serve, establish whether the software lets the
    user reach it in practice, whether the path is as direct as the need
    warrants, and whether it meets the stated success measure. Record what you
    observe as you go — the observations are the evidence.

3.  Classify the gaps between specification and need.

    Assign each gap one type — unmet need, wrong target, missing requirement,
    over-specification, or stale assumption — and tie it to the evidence
    gathered in step 2.

4.  Prioritize by need-impact against change-cost.

    Rank gaps by how much closing them serves the real need, weighed against
    how disruptive the specification change would be. "Leave it" is a valid
    finding where the fix costs more than the gap.

5.  Compose the report, using this structure:

    ```markdown
    # Validation report

    ## Summary
    <2–3 sentences: does the working software meet the users' need? Where
    is the largest gap between what was specified and what was wanted?>

    ## Verdict
    <One of: MEETS THE NEED (no specification change warranted) /
    GAPS FOUND (specification should evolve — see findings).>

    ## Findings (prioritized)

    ### 1. <Outcome / need>
    **Gap.** <Unmet need / wrong target / missing requirement /
    over-specification / stale assumption — one sentence.>
    **Evidence.** <Observed behavior, measurement, or flow step.>
    **Suggested direction.** <What the specification should say instead,
    for someone else to draft — or "leave it" with rationale.>
    **Change cost.** <Small / medium / large.>

    ### 2. <Outcome / need>
    ...
    ```

6.  Deliver the report and the verdict, then stop.

    Acting on the report belongs to whoever revises the specification.

## Rules

- You MUST judge the software against the need, not against the
  specification.

  The specification is the thing under suspicion here. Checking the software
  against its acceptance criteria only re-runs the acceptance tests, so a
  specification that is faithfully implemented and still wrong would pass.

- You MUST NOT change any specification artifact or any code, and MUST NOT
  draft the replacement wording as an edit.

  The output is a report of suggestions. Revising the requirements belongs to
  whoever acts on it; this skill's job ends at the suggestion.

- You MUST distinguish a specification gap from an implementation defect.

  Software that fails because the code does not meet a correct acceptance
  criterion is a defect, for testing and diagnosis to catch. Validation fires
  only where the criterion itself, faithfully implemented, fails the need.

- You MUST report MEETS THE NEED where the software genuinely serves the
  user, and MUST NOT manufacture gaps to justify the exercise.

  Validation is not obliged to find fault, and a fabricated gap costs a whole
  refinement cycle.

- You MUST NOT treat scope expansion as validation.

  A brand-new capability nobody asked for is a new requirement, not a gap
  against the original need. Note it as a follow-up outside the findings.

- You SHOULD state uncertainty rather than resolving it silently.

  Where the need has to be reconstructed rather than read, say so in the
  finding, so the reader can weigh it accordingly.

## Edge cases

- No working instance of the software can be run.

  Where the increments cannot be exercised — no deployment, no local run,
  missing credentials — validate against the next-best evidence: acceptance
  test coverage, interface definitions, screenshots, or telemetry. Say plainly
  in the summary that the walkthrough was not possible, since findings drawn
  this way are weaker.

- The specification and the statement of need contradict each other.

  Treat the contradiction itself as the first finding, classified as wrong
  target. Do not pick a side silently.
