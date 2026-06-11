---
name: audit
description: Proactively scan a codebase for architectural improvement candidates – shallow abstractions, tangled dependencies, single-caller wrappers, repeated patterns – and produce a prioritized report. Discovery only, no code changes. Use when the user wants to know where the codebase needs work, ahead of committing to specific changes.
license: CC0-1.0
metadata:
  preferred_model: gemma4:31b
---

# Audit

Use this skill when the user asks for a proactive architectural review of the codebase – for example, "where should we refactor next?", "find the worst parts of this codebase", or "what's worth cleaning up?".

This skill is **discovery only**. The output is a prioritized report. Findings feed into [`design`](../design/SKILL.md), where they kick off a new workflow iteration (design → elaborate → plan → code → review → test) to implement the proposed changes. Audit does *not* feed directly into [`refactor`](../refactor/SKILL.md) – refactor is a feedback loop within an in-flight code → review → test cycle, not a destination for audit findings.

Do NOT use this skill when:

- The user has already named the area to improve – use [`design`](../design/SKILL.md) for architectural changes, or [`refactor`](../refactor/SKILL.md) for internal-quality improvements within an in-flight iteration.
- The user wants changes applied – this skill stops at the generated report.
- The user wants issues filed, tickets cut, or PRs opened – leave that to their workflow.

Distinct from [`review`](../review/SKILL.md): `review` evaluates a specific diff for style and pattern consistency. `audit` proactively scans the whole codebase for *acrhitectural* problems – module boundaries, abstractions, dependencies.

##  Instructions

1.  **Read available architecture documentation first.**

    Before scanning code, consult any documents that describe the *intended* structure. Common locations:

    - `docs/adr/`, `docs/architecture/`, `docs/design/`
    - `docs/domain-model.md`, `ARCHITECTURE.md`, `CONTEXT.md`
    - Top-level `README.md`
    - `AGENTS.md`, `CLAUDE.md`

    Understanding what the codebase *meant* to be lets you judge what it *is*. A divergence between intended and actual structure is itself a finding worth reporting.

2.  **Walk the codebase applying the deletion test.**

    For each significant module, ask: *if I removed this module, where would its complexity go?*

    - If complexity would **concentrate elsewhere in a worse arrangement** – the module is **deep**, earning its keep.
    - If complexity would **simply redistribute** without becoming worse – the module is **shallow**, not earning its keep. Flag it.

    A shallow module's primary value is hiding a thin layer of behavior behind an interface wider than the behavior justifies.

3.  **Look for these specific smells.**

    - **Wide interfaces relative to behavior.** Many exported functions for thin underlying logic. Often the boundary is in the wrong place.
    - **Tangled dependencies.** Modules importing each other directly or via chains that resist independent change. Touching one requires touching several.
    - **Single-caller abstractions.** An interface, base class, or helper used by exactly one caller. The abstraction wasn't earned.
    - **Repeated patterns not yet abstracted.** Three or more places doing the same shape of work, none extracted. Worth promoting to a named concept.
    - **Inverted dependencies.** Lower-level modules importing higher-level ones; stable code depending on volatile code.
    - **Names that don't match content.** A `util` doing domain logic, a `Manager` with one method, a `Service` that's a thin DAO.

4.  **Prioritize findings by impact ÷ effort.**

    - **Impact**: how much the rest of the codebase simplifies if this is fixed. Findings that unlock other improvements rank high.
    - **Effort**: how invasive the change would be. Local renames rank above cross-cutting restructures.

    The top entry is the cheapest high-impact fix. Cap the report at 5–10 candidates – a 30-item backlog won't be acted on.

5.  **Produce the report.**

    Use this structure:

    ```markdown
    # Audit report

    ## Summary
    <2–3 sentences on the dominant themes – what's working, what's not.>

    ## Findings (prioritized)

    ### 1. <Module / area>
    **Problem.** <One sentence, citing files and lines.>
    **Direction.** <Proposed change to take into design, or "leave it" with rationale.>
    **Effort.** <Small / medium / large.>

    ### 2. <Module / area>
    ...
    ```

##  Rules

-   **Discovery only.**

    Do not change any code, file any issues, open any PRs. The output is the report; the user decides what to act on.

-   **Cite files and lines.**

    Every finding names specific paths. Vague findings ("the API layer is messy") are useless – be concrete.

-   **Distinguish observation from prescription.**

    State what you see before stating what to do about it. The user may disagree with the prescription but still find the observation valuable.

-   **"Leave it" is a valid finding.**

    Not every smell is worth fixing. If the cost of the fix exceeds the cost of the smell, say so explicitly.

-   **Stay within the codebase's idioms.**

    Don't flag style choices that are consistent across the codebase as smells just because you'd prefer a different style. Audit is for structural problems, not preferences.

##  Success criteria

-   **The report cites specific files for every finding.**

    No vague platitudes. Each finding names a module/file path and a concrete observation.

-   **Findings are prioritized by impact ÷ effort.**

    A reader can stop after the top three entries and still have something actionable.

-   **No code changes were made.**

    The git tree is unchanged after this skill runs.

-   **The report is bounded.**

    Top 5–10 candidates. Not an exhaustive enumeration.

## References

- [`design`](../design/SKILL.md): Downstream destination for all audit findings. Each finding becomes input to a new workflow iteration starting at design.

- [`refactor`](../refactor/SKILL.md): Different scope – refactor is a feedback step within an in-flight code → review → test cycle, not a destination for audit findings. The design iteration triggered by an audit finding may eventually produce refactor work, but only as a side effect.

- [`review`](../review/SKILL.md): Different scope – reviews a specific diff for style/pattern consistency rather than scanning the whole codebase for structural problems.
