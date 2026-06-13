# `/specify`

Turn a **PRD** into a filed specification proposal in the project's SRS (software requirements specification) repository. `/specify` takes the product-requirements document – in practice a business-language discovery report – validates that it is complete, and either rejects it with reasons or files it by autonomously running the SRS repository's own sub-skills.

`/specify` is **non-interactive**. It does not interview the user or gather missing requirements; it consumes a PRD that was gathered separately. Its job is to *validate* the PRD, then *orchestrate*: on a valid PRD it drives the SRS repository's workflow end to end, without pausing, by running three sub-skills in sequence – **`draft-spec`** (scaffold the proposal), **`write-spec`** (author the content), **`propose-spec`** (mark it ready for review). The mechanics of each phase, and the content rules, belong to those skills; `/specify` owns the PRD gate and the orchestration. (Those are the reference-implementation names; a project may expose differently-named equivalents through its SRS repository's `AGENTS.md`.)

## What it does

The skill works in two layers. *Where and how the proposal is filed* is owned by the SRS repository and read at runtime. *What makes the specification good* is the skill's own expertise.

It first **reads the PRD** – supplied as a file path, pasted text, or a discovery report gathered earlier in the session – then **validates it for completeness**. A PRD is ready only if it supplies the user/goal/value, the business rules, an example *and* counter-example for each rule, an explicit out-of-scope boundary, measurable NFRs (or an explicit "none"), and resolution of any open question that blocks a criterion. If the PRD falls short, the skill **rejects it** with an itemized list of what's missing so the requirements can be gathered before retrying, and writes nothing. (Purely mechanical gaps – a missing `Feature` title, scenario ordering – it normalizes without rejecting.)

If the PRD passes, it **locates the SRS** – reading the project's root `AGENTS.md`, finding the `Workflow repositories` section, and resolving the `SRS` entry to the repository where requirements live. If no SRS is declared, it stops and says so rather than writing into an arbitrary file.

It then **reads that SRS repository's own `AGENTS.md`** – never `CONTRIBUTING.md` – to learn the repository's current workflow: its proposal template, branch convention, lifecycle states, and pull-request, thread, and label rules. The skill follows whatever it finds there rather than hard-coding the process, so it stays correct as the specification repository evolves. It follows `AGENTS.md` rather than `CONTRIBUTING.md` so the agent workflow can differ from the human one.

With the PRD validated, the destination found, and the process learned, it runs the three sub-skills in order, feeding each what the PRD provides:

- **`draft-spec`** scaffolds the proposal – branch, document from template, draft pull request, and discussion thread – using the change description from the PRD's outcome.

- **`write-spec`** authors the specification content. The PRD's rules and examples become functional acceptance criteria, its non-functional needs become measurable quality requirements, and its out-of-scope boundary is carried forward. This skill owns *how* that content is written – the AC format, the NFR conventions, the artifact taxonomy, and the Definition of Ready – so each project can tune its own standards.

- **`propose-spec`** verifies the proposal is complete and meets the Definition of Ready, then takes the pull request out of draft for stakeholder review.

That's where the autonomous run ends – at a `PROPOSED` proposal in reviewers' hands. **The outcome is a specification awaiting the user's review and approval, not an approved one.** The skill closes by telling the user the proposal needs their approval, and that the next SDLC phase – design – cannot begin until the specification is approved (`ACCEPTED`). Approving (`accept-spec`) or rejecting (`reject-spec`) is a deliberate, human-gated decision the skill never makes itself.

If `write-spec` surfaces a Definition-of-Ready gap that traces back to missing PRD information, `/specify` treats it as a validation failure and rejects – it does not invent the missing material. Where the PRD is internally incoherent or its solution won't meet its own goal, that too is a rejection, not something the skill quietly fixes.

## How to invoke

Give the agent a PRD and ask it to specify – eg. "specify this PRD", "turn this discovery report into a spec", or "validate and file these requirements". The skill triggers when a PRD is ready to become a specification. If the requirements are still vague, gather them into a PRD first – `/specify` will reject an incomplete PRD rather than interview you.

The project must declare its SRS location in its root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

## Examples

- **Specify a complete PRD:** "Specify this discovery report." (report has rules, examples, counter-examples, scope, NFRs) → `/specify` runs `draft-spec` → `write-spec` → `propose-spec` autonomously, ending with an open, non-draft proposal pull request in the SRS repository, ready for stakeholder review.

- **Reject an incomplete PRD:** "Specify this." (report has rules but no counter-examples and an empty out-of-scope list) → an itemized rejection naming the gaps. Nothing is scaffolded or written to the SRS.

- **Carry a fresh report through:** hand `/specify` a just-gathered discovery report → it is validated and, if complete, carried through the full scaffold-author-propose run in one step.

- **No SRS wired up:** "Specify this PRD." (project `AGENTS.md` has no `SRS` entry) → the skill reports that the project isn't wired to an SRS and writes nothing.
