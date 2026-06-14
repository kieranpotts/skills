---
name: validate
description: Evaluate completed, tested work against the users' actual needs – not against the agreed acceptance criteria – to judge whether the specification itself should evolve. Produce prioritized suggestions for specification change. Use once all of a plan's increments are built and tested, as a product-level checkpoint that asks "did we build the right thing?" and feeds the specification feedback loop.
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: gemma4:31b
---

# `/validate`

Use this skill once all of a plan's increments are complete – built, reviewed, and tested – to evaluate the working software against the users' *actual needs*, and judge whether the specification itself should evolve. The output is a prioritized set of suggestions, each seeding a separate [`/refine`](../refine/SKILL.md) → [`/specify`](../specify/SKILL.md) pass.

This is **validation**, not verification, and the distinction is the whole point:

- [`/test`](../test/SKILL.md) asks *did we build the thing right?* – the increment against its **agreed acceptance criteria**.
- `/validate` asks *did we build the right thing?* – the working software against the **users' real need**, questioning whether the agreed criteria were ever the right ones.

A change can pass every AC in `/test` and still fail `/validate`: it does exactly what was specified, and what was specified is not what the user needed. That gap is what this skill surfaces.

This skill is **evaluation only**. It outputs suggestions; it changes no specification and no code. Acting on a suggestion – editing the requirements – is [`/refine`](../refine/SKILL.md)'s job, which in turn flows into [`/specify`](../specify/SKILL.md). The loop is `validate → refine → specify`: this skill judges, `/refine` enacts, `/specify` re-establishes the requirement.

Do NOT use this skill to:

- Verify the increment against its acceptance criteria – that is [`/test`](../test/SKILL.md).
- Fix a defect where the code fails a *correct* AC – the specification is right, so there is nothing to validate; that is implementation work.
- Edit the specification – this skill suggests; [`/refine`](../refine/SKILL.md) edits.
- Evaluate the *design* or architecture – that is [`/audit`](../audit/SKILL.md), the design-level counterpart that feeds [`/refactor`](../refactor/SKILL.md) → [`/design`](../design/SKILL.md).

**Input**: Completed work that has already passed [`/test`](../test/SKILL.md) (verified against its ACs), together with the originating statement of need – the preserved PRD, the specification's outcome and success measures, or the discovery report. REQUIRED. Run once all of a plan's increments are complete.

**Output**: A bounded, prioritized validation report – an explicit verdict (MEETS THE NEED / GAPS FOUND) and, where gaps exist, suggestions for how the specification should evolve, each classified by gap type, backed by evidence, and ready to seed a [`/refine`](../refine/SKILL.md) → [`/specify`](../specify/SKILL.md) pass. No specification or code is changed; what consumes the report is the orchestrator's concern.

##  Instructions

1.  **Recover the original need, not just the ACs.**

    Before looking at the working software, recover *why* it was built. Pull the originating intent from the strongest available source, in order:

    - The proposal's preserved product requirements document (PRD) – the business-language statement of need the specification was written from.
    - The specification's outcome / goal / success-measure sections.
    - The discovery report, if one exists.

    The ACs tell you what was promised; the PRD and success measures tell you what was *wanted*. Validation compares the working software to the latter. If no statement of need survives anywhere, say so – without it, validation has nothing to judge against, and that absence is itself the first finding.

2.  **Walk the working software as the user, against the need.**

    Exercise the completed, tested increments end-to-end – not scenario by scenario, but as the user pursuing their actual goal. For each user outcome the specification claimed to serve, ask:

    - Does the working software let the user achieve the outcome, in practice, not just on paper?
    - Is the path to it as direct as the need warrants, or has the specification mandated friction the user will not tolerate?
    - Does it meet the *success measure* (the metric the PRD said would prove it worked), where one was stated?

    Capture observed behavior, not assumed behavior – the same evidence discipline as [`/test`](../test/SKILL.md). "The flow works" is not a finding; "the user must re-enter the address at step 4, which the need says they should never have to" is.

3.  **Surface the gaps between specification and need.**

    Classify each gap by how the specification diverged from the need:

    - **Unmet need.** A stated outcome the working software does not actually deliver, even though every related AC passes. The ACs under-specified the need.
    - **Wrong target.** The specification optimized for something the user does not value, at the cost of something they do.
    - **Missing requirement.** A need that surfaced only once the software was usable – never captured as an AC at all.
    - **Over-specification.** The specification demanded behavior the user does not need, adding cost or friction for no benefit.
    - **Stale assumption.** A success measure or constraint that was reasonable when specified but is now disproven by the working software.

    Tie each gap to evidence: an observed behavior, a measured shortfall against a success metric, a step in the flow. A gap without evidence is a preference, not a finding.

4.  **Prioritize by need-impact ÷ change-cost.**

    Rank gaps by how much closing them serves the user's real need, against how disruptive the specification change would be. The top entry is the cheapest change that most improves fitness for purpose. Cap the report at 5–10 candidates – an unbounded wishlist will not be acted on. "Leave it" is a valid finding: a gap whose fix costs more than the gap itself stays unspecified, said explicitly.

5.  **Produce the validation report.**

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
    for `/refine` to draft — or "leave it" with rationale.>
    **Change cost.** <Small / medium / large.>

    ### 2. <Outcome / need>
    ...
    ```

6.  **Report the verdict and stop.**

    - **MEETS THE NEED** – the working software serves the user's real need; no specification change is warranted. The work is validated.
    - **GAPS FOUND** – report the prioritized suggestions. Each is input to a [`/refine`](../refine/SKILL.md) pass, which drafts the specification edit and flows into [`/specify`](../specify/SKILL.md). Do not draft the edits here; suggest the direction and stop. What consumes the report is the orchestrator's concern.

##  Rules

-   **Validate against the need, not the specification.**

    The specification is the thing under suspicion. Judging the software against the ACs only re-runs [`/test`](../test/SKILL.md). Judge it against the originating need – the PRD, the outcome, the success measure – so a passing-but-wrong specification can be caught.

-   **Evaluation only – suggest, never edit.**

    This skill changes no specification artefact and no code. It outputs a report of suggestions. Editing the requirements is [`/refine`](../refine/SKILL.md)'s responsibility; this skill's job ends at the suggestion.

-   **Every finding carries evidence.**

    An observed behavior, a measurement against a success metric, a concrete step in the user's flow. A gap asserted without evidence is a preference and does not belong in the report.

-   **Distinguish a specification gap from an implementation defect.**

    If the software fails because the code does not meet a *correct* AC, that is a defect for [`/test`](../test/SKILL.md) and diagnosis – not a validation finding. Validation fires only when the AC itself, faithfully implemented, fails to serve the need.

-   **"Meets the need" is a valid verdict.**

    Validation is not obliged to find fault. If the working software serves the user's real need, say so and report no specification change. Manufacturing gaps to justify the pass wastes a refine cycle.

-   **The report is bounded.**

    Top 5–10 candidates, prioritized. An exhaustive backlog of every conceivable improvement will not be acted on and buries the findings that matter.

-   **Scope expansion is not validation.**

    A brand-new capability nobody asked for is not a gap against the original need – it is a new requirement. Note it as a follow-up, but do not smuggle it into the validation report as though the specification was wrong to omit it.

##  Success criteria

-   **The originating need is recovered before the software is judged.**

    PRD, outcome, or success measure consulted first. Validation against the ACs alone is verification, not validation.

-   **Every finding cites evidence.**

    Observed behavior, a measurement, or a flow step – not an assertion of preference.

-   **Each finding names its gap type and a suggested direction.**

    Unmet need / wrong target / missing requirement / over-specification / stale assumption, plus what the specification should say instead, ready for [`/refine`](../refine/SKILL.md).

-   **The verdict is explicit.**

    MEETS THE NEED or GAPS FOUND – not implied.

-   **No specification or code was changed.**

    The git tree is unchanged. The output is a report of suggestions; enacting them is downstream.

-   **The report is bounded.**

    Top 5–10 candidates, prioritized by need-impact ÷ change-cost.
