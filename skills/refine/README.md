# `/refine`

Revise the requirements specification in response to feedback from acceptance testing or use of the working software. Use when testing surfaces a specification gap, a stakeholder reports an unmet need against shipped behavior, or an NFR threshold turns out to be wrong in practice.

## What it does

`/refine` edits the *specification*, not the code. The boundary is sharp: if the spec was right and the code was wrong, this is a defect fix, not a refinement; refinement is for when the acceptance criterion itself is wrong, missing, contradictory, or ambiguous. It names the trigger (a failing AC that reflects a spec error, an exploratory-testing gap, stakeholder feedback, an NFR mismatch), locates the exact artefact to change, classifies the change (correction / addition / removal / reclassification / threshold adjustment), drafts the edit in the specification's own conventions (Gherkin scenarios, measurable NFRs, explicit out-of-scope) shown before-and-after, records the rationale and evidence, and traces the downstream impact on design, plan, code, and tests.

It is interactive where stakeholders disagree, and disciplined elsewhere: one logical change per pass, never a silent rewrite of a passed AC, and never scope expansion in disguise (a net-new feature is a fresh specification, not a refinement). It changes no code – the output is a specification edit plus a traced impact list, ready to flow into `/specify`.

## How to invoke

```
/refine
```

Invoke it when feedback proves the specification itself needs to change. It takes the trigger and the existing specification; no other arguments. (Within the workflow, `/validate` supplies the suggestions it acts on.)

## Examples

When an integration test fails because the spec mandates `200 OK` but the agreed SDK contract is `200 OK` plus a replay header, `/refine` classifies it a *correction*, shows the before/after Gherkin for the scenario, records the confirming conversation as rationale, and traces the impact: no design change, a handler edit, an updated test assertion.

When UX research shows perceived slowness starts at 150ms but the NFR says `p95 < 200ms`, it makes a *threshold adjustment* to `< 150ms`, cites the research session as evidence, and flags the downstream design re-evaluation (likely an in-memory cache layer) and a new performance increment.
