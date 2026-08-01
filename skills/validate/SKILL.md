---
name: validate
description: >-
  Ask, "did we build the right thing?" Use when the user asks something like
  "did we build the right thing?", "does the software fulfill its goals?", or
  "what gaps can you find in the requirements specification?"
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/xxxxxxxxxxxxxxxx
---

# Validate

Validate the requirements specification of a software system. Do they match
the users' actual needs, do you think? Look for gaps between what has been
specified, and what users' actual needs are likely to be.

Produce a report with prioritized suggestions for how the software could be
improved for better product-market fit.

Evaluation only. You MUST NOT make any code or configuration changes to the
software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **The requirements specification, and where it lives — REQUIRED.**
  Discover it rather than assuming it: check this session's context first,
  then the environment (a convention file such as `AGENTS.md`, a workspace
  manifest, a configured connector). If neither settles it, ask the user. It
  MAY be a directory in this repository, a separate repository, or an
  external service such as a tracker or wiki — do not assume a filesystem
  path, a file name, or a document structure. Where it is a remote
  repository, clone it locally to read it.

- **The originating statement of need — OPTIONAL.** Look in the context and
  environment for a preserved product requirements document (PRD) or other
  similar discovery report that captures, at a high level, the business
  requirements and user needs for the system.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Success criteria

You will achieve the following outcomes:

- A bounded, prioritized validation report — an explicit verdict (MEETS THE
  NEED / GAPS FOUND) and, where gaps exist, suggestions for how the
  specification should evolve, each classified by gap type, backed by
  evidence, and ready to seed a [refine](../refine/SKILL.md) →
  [specify](../specify/SKILL.md) pass.

- No specification or code was changed. Acting on the report was left to
  the caller.

- The originating need MUST be recovered before the software is judged.

  PRD, outcome, or success measure MUST be consulted first. Validation
  against the ACs alone is verification, not validation.

- Every finding MUST cite evidence.

  Observed behavior, a measurement, or a flow step — not an assertion
  of preference.

- Each finding MUST name its gap type and a suggested direction.

  Unmet need / wrong target / missing requirement / over-specification /
  stale assumption, plus what the specification should say instead,
  ready for [refine](../refine/SKILL.md).

- The verdict MUST be explicit.

  MEETS THE NEED or GAPS FOUND — it MUST NOT be implied.

- No specification or code MUST have been changed.

  The git tree MUST be unchanged. The output is a report of
  suggestions; enacting them is downstream.

- The report MUST be bounded.

  It MUST contain 5–10 prioritized candidates, not an exhaustive
  wishlist.

## Instructions

1.  Recover the original need, not just the ACs.

    Pull the originating intent from the strongest available source, in
    order: the preserved PRD, the specification's outcome / goal /
    success-measure sections, or the discovery report. If no statement of
    need survives anywhere, report that absence as the first finding.

2.  Walk the working software as the user, against the need.

    Exercise the completed, tested increments end-to-end, as the user
    pursuing their actual goal. For each user outcome the specification
    claimed to serve, check whether the working software lets the user
    achieve it in practice, whether the path is as direct as the need
    warrants, and whether it meets the stated success measure. Capture
    observed behavior.

3.  Surface the gaps between specification and need.

    Classify each gap by type: Unmet need, Wrong target, Missing
    requirement, Over-specification, or Stale assumption, and tie each
    gap to evidence.

4.  Prioritize by need-impact ÷ change-cost.

    Rank gaps by how much closing them serves the user's real need
    against how disruptive the specification change would be. "Leave it"
    is a valid finding where the fix costs more than the gap.

5.  Produce the validation report.

    Use this structure:

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
    over-specification / stale assumption — one sentence, with evidence.>
    **Evidence.** <Observed behavior, measurement, or flow step.>
    **Suggested direction.** <What the specification should say instead,
    for `refine` to draft — or "leave it" with rationale.>
    **Change cost.** <Small / medium / large.>

    ### 2. <Outcome / need>
    ...
    ```

6.  Report the verdict and stop.

    Report MEETS THE NEED or GAPS FOUND. Do not draft specification edits
    here; acting on the report is left to the caller.

## Rules

- You MUST validate against the need, not the specification.

  The specification is the thing under suspicion. Judging the software
  against the ACs only re-runs [test](../test/SKILL.md). You MUST judge
  it against the originating need — the PRD, the outcome, the success
  measure — so a passing-but-wrong specification can be caught.

- Evaluation only — you MUST suggest, and MUST NOT edit.

  This skill MUST NOT change any specification artifact and MUST NOT
  change any code. It outputs a report of suggestions. Editing the
  requirements is [refine](../refine/SKILL.md)'s responsibility; this
  skill's job ends at the suggestion.

- Every finding MUST carry evidence.

  An observed behavior, a measurement against a success metric, or a
  concrete step in the user's flow. A gap asserted without evidence is
  a preference and MUST NOT belong in the report.

- You MUST distinguish a specification gap from an implementation defect.

  If the software fails because the code does not meet a correct AC,
  that is a defect for [test](../test/SKILL.md) and diagnosis — not a
  validation finding. Validation fires only when the AC itself,
  faithfully implemented, fails to serve the need.

- "Meets the need" is a valid verdict.

  Validation is not obliged to find fault. If the working software
  serves the user's real need, you MUST say so and report no
  specification change. You MUST NOT manufacture gaps to justify the
  pass; that wastes a refine cycle.

- Scope expansion MUST NOT be treated as validation.

  A brand-new capability nobody asked for is not a gap against the
  original need — it is a new requirement. You MUST note it as a
  follow-up, but MUST NOT smuggle it into the validation report as
  though the specification was wrong to omit it.

## References

None.
