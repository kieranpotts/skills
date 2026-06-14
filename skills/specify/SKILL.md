---
name: specify
description: Validate a product requirements document (PRD) and, if complete, file it as a proposal in the project's software requirements specification (SRS) repository. Rejects an incomplete PRD with reasons, rather than asking questions. Use when a PRD exists and is ready to be turned into a specification, before any design or coding work begins, or when the user says "turn this into acceptance criteria", "turn this into a spec", or "prepare these as software requirements".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: qwen3.5:cloud
---

# `/specify`

Use this skill to turn a product requirements document (PRD) – a business-language artifact – into a testable specification, filed as a proposal in the project's software requirements specification (SRS) repository.

This skill is **non-interactive**.

**Input**: A PRD, expected to be sufficiently complete to transform into a formal software requirements specification. REQUIRED. This skill does not gather requirements or interview the user; if the PRD is not sufficiently detailed, you MUST **reject** it with a list of what is missing or ambiguous, and not proceed further.

**Output**: An open pull request against the SRS repository, capturing the changes as testable acceptance criteria, at `PROPOSED` and awaiting the user's review and approval.

When the PRD passes validation, this skill drives the SRS repository's workflow end to end – without pausing for the user – following the procedure defined by three of its local skills, in order:

1. **`draft-spec`** – scaffold the proposal: branch, document from template, draft pull request, and discussion thread.
2. **`write-spec`** – author the specification content: the PRD's rules and examples become the repository's acceptance criteria and measurable quality requirements.
3. **`propose-spec`** – mark the proposal ready for stakeholder review once it is complete and meets the Definition of Ready.

**Read these skills; do not invoke them.** The SRS repository's local skills are `interactive: yes` – written for a human operator, they prompt for input and direct the user from one step to the next. This skill instead *reads* each one's rules and instructions and **executes that procedure itself, non-interactively**, drawing every answer from the validated PRD instead of from a prompt.

These are the reference-implementation skill names; a project MAY expose differently-named equivalents, discoverable through its SRS repository's `AGENTS.md`. Read whichever skills that repository provides for these three phases – scaffold, author, mark-ready.

The run stops at a proposal that is `PROPOSED` – complete and open for review, but **not yet approved**. The outcome of this skill is a specification *awaiting the user's review and approval*, not an approved specification. Approval is a human decision the user makes deliberately; only an approved (`ACCEPTED`) specification unblocks the downstream design phase.

Use this skill only to turn an existing PRD into a filed specification. Do NOT use it to *gather* requirements (that produces the PRD this skill consumes), to make design decisions, to plan implementation, or to run tests – those are separate responsibilities.

This skill has two layers: (1) *Where and how the proposal is filed* is owned by the SRS repository, defined by its local skills – this skill reads and carries out their process but does NOT restate or duplicate it. (2) *Whether the PRD is fit to specify from* – the validation gate below – is owned by this skill.

##  Instructions

1.  **Read the PRD.**

    Obtain the PRD however it is supplied – a file path, pasted text, or a PRD produced earlier in this session. Read it in full before doing anything else.

    If no PRD is supplied and none can be found, reject immediately: there is nothing to specify. Tell the user a PRD must be gathered first.

2.  **Validate the PRD for completeness. Reject if it is not ready.**

    This is the gate. A PRD is ready to specify from only if it supplies all of the following. Check each:

    - **User, goal, and value** – *who* it is for, *what* outcome they want, and *why* it matters. (The PRD's *Outcome* and *Stakeholders* sections.)
    - **Rules** – the business rules that govern the behavior, each a clear declarative statement.
    - **Examples and counter-examples** – for each rule, at least one concrete case where it applies and one similar case where it does not. Without the counter-example, the rule's boundary is undefined and cannot be specified.
    - **Scope, in both directions** – an explicit *out-of-scope* list, not just what is in.
    - **Non-functional requirements** – stated, or an explicit statement that there are none beyond the system baseline.
    - **Blocking open questions resolved** – any open question whose answer is needed to write a rule or an AC MUST be resolved. Non-blocking open questions (parked for later, not gating any criterion) are acceptable and are carried into the proposal.

    If any of these is missing or ambiguous, **reject the PRD**. Output a specific, itemized list of what is absent or unclear – tied to the rule or section it concerns – so the requirements can be gathered before retrying. Do NOT ask the user questions yourself, and do NOT invent the missing content. Write nothing to the SRS.

    You MAY normalize purely mechanical gaps without rejecting – deriving a `Feature` title from the stated goal, ordering scenarios, tidying phrasing. The bar for rejection is *substantive* incompleteness, not formatting.

3.  **Locate the SRS repository.**

    Read the consuming project's root `AGENTS.md` and find its `Workflow repositories` section. This section maps each ecosystem role to a location (a path or a repository URL). Resolve the `SRS` entry to find where requirements live.

    If the project's `AGENTS.md` has no `Workflow repositories` section, or no `SRS` entry within it, the project is not wired to an SRS. Tell the user, and stop – do NOT guess a location or write requirements into an arbitrary file.

4.  **Read the SRS repository's `AGENTS.md` to learn its workflow.**

    The SRS repository's own `AGENTS.md` is the authoritative description of how a proposal is filed there: the proposal template, the branch convention, the lifecycle states, and the pull-request, discussion-thread, and label rules. Read it, and follow whatever it prescribes.

    Read `AGENTS.md`, NOT `CONTRIBUTING.md`. `CONTRIBUTING.md` is the workflow for human contributors; `AGENTS.md` is the workflow for agents. They may deliberately differ. As an agent, you follow `AGENTS.md`.

    Do NOT hard-code the SRS workflow from memory or from this skill. The process lives in the target repository so it can evolve, and so the agent workflow can differ from the human one. Always read it fresh.

5.  **Scaffold the proposal – follow `draft-spec`.**

    Read the SRS repository's scaffolding skill (`draft-spec`, or the equivalent its `AGENTS.md` names) and carry out its procedure yourself: create the branch, the proposal document from the template, the draft pull request, and the discussion thread. Where that skill would prompt a human for the change description, the slug, or the change type, derive each from the PRD's outcome instead – do not pause to ask. The skill is `interactive: yes`; you are running its procedure non-interactively.

    If the scaffolding procedure provides for preserving the originating PRD (the reference implementation writes it to `proposals/<slug>/product-requirements.md` and links it from the proposal's `Origin` field), supply *this skill's input PRD* as that origin artifact, verbatim. The validated PRD is no longer a transient working document: it becomes the proposal's durable, frozen origin record. Follow whatever the target repository prescribes for this; do not invent a location it does not define.

6.  **Author the specification content – follow `write-spec`.**

    Read the SRS repository's content-authoring skill (`write-spec`, or its equivalent) and apply it. That skill owns *how* the content is written – the acceptance-criteria format, how non-functional requirements are expressed, where each artifact lives, and the Definition of Ready. Apply its rules to the validated PRD, mapping:

    - The PRD's *rules* and *examples / counter-examples* → functional acceptance criteria.
    - The PRD's *non-functional requirements* → the repository's measurable quality requirements.
    - The PRD's *outcome* and *stakeholders* → the user, goal, and value.
    - The PRD's *out-of-scope* list → the specification's out-of-scope boundary, carried forward in full.

    Do NOT hard-code the content format from memory; apply the target repository's rules as `write-spec` states them. When checking the Definition of Ready surfaces a gap that stems from missing PRD information, treat it as a validation failure: reject the PRD (step 2) and name the gap.

7.  **Mark the proposal ready – follow `propose-spec`.**

    Once the content is authored and meets the Definition of Ready, read the SRS repository's readiness skill (`propose-spec`, or its equivalent) and carry out its checks – verify completeness, then take the pull request out of draft for stakeholder review.

    This is where `/specify`'s autonomous run ends. The outcome is a proposal at `PROPOSED`, **awaiting the user's review and approval** – not an approved specification. Approval is a deliberate human decision (advancing the proposal to `ACCEPTED`, via `accept-spec` in the reference implementation); rejection uses `reject-spec`. Neither is part of this skill.

8.  **Report the outcome and the required approval.**

    On finishing, tell the user plainly: the specification proposal is filed and `PROPOSED`, and it now needs their review and approval before downstream work begins. State explicitly that **the next SDLC phase – design – MUST NOT start until this specification is approved** (`ACCEPTED`). Link the pull request and its discussion thread for the user to act on.

##  Rules

-   **Non-interactive. Validate, don't elicit.**

    This skill does NOT ask the user questions or gather missing requirements. Its input is a PRD. If the PRD is incomplete, reject it with reasons so the requirements can be gathered separately – never interview the user to fill the gap yourself.

-   **Reject substantive gaps; never invent content.**

    When the PRD is missing a rule, an example, a counter-example, a scope boundary, or a measurable NFR target, reject – do NOT fabricate the missing material. Only purely mechanical gaps (a `Feature` title, scenario ordering, phrasing) may be filled without rejecting.

-   **Follow the SRS repository's procedure; read it, don't invoke it.**

    Once the PRD is validated, carry out the repository's scaffold → author → mark-ready procedure (defined by `draft-spec` → `write-spec` → `propose-spec`, or the equivalents its `AGENTS.md` names) in sequence, autonomously. Read each local skill and execute *its* steps yourself, non-interactively – do NOT literally invoke them; they are `interactive: yes` and would stop to prompt. This skill's value is the PRD gate plus running that procedure unattended. The *rules* for each phase – the format, the conventions, the lifecycle – belong to the local skills and are read fresh from them, never hard-coded here.

-   **Run autonomously once the PRD passes.**

    After validation, drive the three phases through to `PROPOSED` without pausing for user input. The PRD is the contract; everything needed is in it. Stop only to reject (a validation failure surfaced mid-run) or at the natural end, when the proposal is ready for human review.

-   **The outcome is an approval request, not an approval.**

    This skill never approves its own output. It stops at `PROPOSED` and hands the specification to the user to review and approve. Do NOT advance the proposal to `ACCEPTED`, and do NOT proceed to the design phase, on the skill's own authority – approval is the user's decision, and it gates the next SDLC phase.

-   **Read the SRS repository's `AGENTS.md`, not its `CONTRIBUTING.md`.**

    `AGENTS.md` is the agent's workflow; `CONTRIBUTING.md` is the human's. They may differ deliberately. Follow `AGENTS.md`.

-   **Never hard-code the SRS workflow.**

    The branch convention, proposal template, lifecycle states, and filing mechanics live in the target repository. Read them fresh each time. Do not assume them from memory.

-   **Stop if no SRS is declared.**

    If the project's `AGENTS.md` does not declare an `SRS` location under `Workflow repositories`, do not write requirements anywhere. Tell the user the project is not wired to an SRS.

-   **Defer the content rules to the SRS repository.**

    *How* the specification is written – the AC format, the way NFRs are expressed, the artifact taxonomy, and the Definition of Ready – is owned by the target SRS repository (in this ecosystem, its `write-spec` skill, reachable from `AGENTS.md`). Read and apply those rules; do NOT hard-code a format from this skill. This is what lets each project tune its own specification standards.

-   **Specify the need the PRD states, not a literal transcription.**

    Translate the PRD's *outcome* and *rules* into criteria that meet the underlying need – not a mechanical restatement of surface wording. If the PRD itself is internally incoherent, or its stated solution plainly won't meet its own stated goal, that is a validation failure: reject it and name the contradiction. (Surfacing the real need from a vague request is the upstream discovery step's job, not this skill's.)

## Examples

The consuming project locates its SRS through a `Workflow repositories` declaration in its root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

The shape of the specification content itself – Gherkin acceptance criteria, measurable non-functional requirements, the out-of-scope section – is defined by the target SRS repository's content rules (its `write-spec` skill), not here. This skill validates the PRD, then carries out the procedure that the repository's `draft-spec` → `write-spec` → `propose-spec` skills define – reading their rules and running them non-interactively – to file the proposal to whatever format and process that repository prescribes.

##  Edge cases

-   **No SRS declared.**

    The project's `AGENTS.md` has no `Workflow repositories` section, or no `SRS` entry. Stop and tell the user – the project is not wired to an SRS, and requirements have no home. Do not write them into an arbitrary file.

-   **Spike or research task.**

    The goal is to *learn*, not to ship a feature. Write the specification as a list of questions to answer, with a time-box, rather than as ACs.

-   **Bug fix.**

    The AC captures behavior that is wrong today and should be correct after the fix – the reproduction as preconditions and trigger, the correct behavior as the expected outcome. Express it in the SRS repository's AC format.

-   **Refactor or internal change.**

    There are no new ACs. A pure internal-quality change (eg. cyclomatic complexity reduced, tests faster, module decoupled) is not specification work and does not belong here – the existing ACs continue to pass unchanged.

-   **PRD contradicts the existing specification.**

    If the PRD's rules contradict an existing AC already in the SRS, do not silently rewrite the existing AC. Surface the conflict in the proposal (and its discussion thread) for reviewers to resolve, citing both the existing AC and the conflicting PRD rule.

-   **Incomplete PRD.**

    The PRD is missing rules, examples, counter-examples, scope, or measurable NFRs. Reject it (step 2) with an itemized list of the gaps, so the requirements can be gathered before retrying. Write nothing to the SRS.

##  Success criteria

-   **The proposal reaches `PROPOSED` via the repository's own procedure.**

    On a valid PRD, the skill carries out scaffold → author → mark-ready (the procedure defined by `draft-spec` → `write-spec` → `propose-spec`, or the repository's equivalents) autonomously, leaving an open, non-draft proposal pull request labelled for review – not an arbitrary file or a half-finished draft. The format and lifecycle rules are read from the local skills, not reinvented here.

-   **The user is told the specification awaits their approval.**

    The skill's closing message states that the proposal is `PROPOSED` and needs the user's review and approval, and that the design phase MUST NOT begin until the specification is approved (`ACCEPTED`). The pull request and discussion thread are linked for the user to act on. The skill does not approve, and does not advance to design, itself.

-   **The specification conforms to the SRS repository's content rules.**

    The authored artifacts follow the target repository's format and conventions (its `write-spec` rules) – acceptance criteria in the prescribed form, non-functional requirements as that repository requires, no implementation detail leaking in.

-   **Functional and non-functional requirements are both present.**

    Even if the NFR section is "no new NFRs – inherits from system baseline", it is stated explicitly, not omitted.

-   **Out-of-scope items are named.**

    The specification includes an explicit list of deferred features, adjacent functionality not under review, and decisions ruled out during discovery – not just what is being built.

-   **The user, goal, and value are carried from the PRD.**

    Each feature block names *who* it is for, *what* they achieve, and *why* – traceable to the PRD's outcome and stakeholders.

-   **The Definition of Ready is satisfied, or the PRD was rejected for the gap.**

-   **An incomplete PRD is rejected, not patched.**

    When the PRD lacks substantive content, the skill produces an itemized rejection naming the gaps – not a specification built on invented or assumed material, and nothing written to the SRS.
