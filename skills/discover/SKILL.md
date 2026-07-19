---
name: discover
description: >-
  Run a discovery workshop with the customer to elicit product requirements.
  Use when requirements are vague, ambiguous, or unclear, or when the user
  says something like "let's discover the requirements for…", "run a discovery
  session on…", "help me understand what the customer actually needs", or
  "interview me about this feature".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/technical-reasoning
---

# Discover

Run a structured discover session with the customer, or their representative,
to elicit business requirements before specification. Produce a product
requirements document (PRD) in business language that captures outcomes,
stakeholders, scope, business rules (with examples), and non-functional
requirements.

Discovery only. You MUST NOT make any code or configuration changes to the
software itself.

**Input:** Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the input requirements,
prompt the user for clarification.

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

- A seed PRD or artifacts — OPTIONAL. The user MAY provide a draft PRD or
  similar artifacts (via file paths, URLs, or pasted text) to be edited in
  place, or to use as a basis for a fresh PRD. The seed may be vague,
  incomplete, or absent.

Gathers the rest of the input you need from the user. Prompt one question at
a time.

**Output:** A new or modified PRD in business language, covering outcomes,
stakeholders, scope, rules, examples, non-functional requirements, assumptions,
and open questions. The PRD enforces completeness by having a counter-example
for every rule, an explicit out-of-scope list, non-functional requirements
explicitly recorded (even if none), and blocking questions resolved. Technical
implementation and validation details are out-of-scope — this is not a
specification or design document.

This skill produces the PRD and stops. It does NOT file the PRD in any workflow
repository, and it does NOT translate the rules and examples into testable
acceptance criteria. These are separate downstream responsibilities.

## Instructions

You MUST conduct the session as a structured interview. You MUST ask one
question at a time, in the order below, and MUST wait for the answer before
asking the next. You SHOULD let each answer shape the question that follows.

1.  **Confirm the seed.**

    You MUST restate what the user has brought you, in one sentence: *"You want
    to understand the requirements for <feature/capability> — is that right?"*

    You MUST clarify before proceeding if the seed is ambiguous. A discovery
    built on a misread seed produces an invalid PRD.

    If the user supplies existing business requirements artifacts (a file path,
    a URL, or pasted text), you MUST read them in full first, then ask which way
    to proceed:

    - *"Refine these existing artifacts in place?"*: Interrogate and extend what
      is already written, keeping its structure, filling its gaps. Treat the
      supplied content as the working draft.

    - *"Produce a fresh PRD using these as a basis?"*: Extract the problem,
      outcome, scope, rules, and so on from the artifacts as raw material, then
      build a clean PRD to this skill's template. You MUST confirm each extracted
      item with the user before adopting it — you MUST NOT carry anything over
      unverified — the artifacts may be stale, partial, or wrong.

    You MUST NOT assume either mode. You MUST wait for the user to choose before
    continuing the interview.

2.  **Surface the outcome.**

    You MUST ask, one at a time:

    - *"What problem is the customer facing? What's wrong or missing?"*
    - *"What is the customer trying to achieve?"*
    - *"Why now? What's the trigger for this requirement?"*
    - *"What measurable change would tell the customer this worked?"*

    You MUST capture as *Problem*, *Goal*, *Why now*, *Success measure*. This is
    the Impact Mapping layer — it keeps the *why* alive for downstream skills.

3.  **Identify the stakeholders.**

    You MUST ask, one at a time:

    - *"Who is affected by this?"*
    - *"Who decides whether it's done?"*
    - *"Whose work changes as a result?"*

    For each stakeholder, you MUST capture role and interest in the outcome.

4.  **Establish scope.**

    You MUST ask: *"What is deliberately out of scope here? What are we choosing
    not to address?"*

    An explicit out-of-scope list is one of the most valuable discovery
    artifacts. You SHOULD push for it. Discovery sessions that produce only an
    *in-scope* list hide ambiguity that re-surfaces during build.

5.  **Elicit rules.**

    You MUST ask: *"What rules govern this? Rules are things that must always be
    true, or must never happen."*

    You MUST capture each rule as a single declarative sentence, and MUST number
    them.

6.  **For each rule, elicit concrete examples and counter-examples.**

    For *each* rule, you MUST ask:

    - *"Give me a real case where this rule applies."*
    - *"What's the situation, and what happens?"*
    - *"Now give me a case that looks similar but where the rule does NOT apply.
      What's different?"*

    Examples are the lifeblood of discovery. Without examples, rules are
    abstract noise. The counter-example forces a sharper boundary.

    You MUST capture examples in plain natural language (*"A premium customer
    with £600 in their cart sees free delivery presented at checkout"*). These
    are not yet testable acceptance criteria.

7.  **Elicit non-functional requirements.**

    You MUST ask: *"Beyond what it must do, are there constraints on how well it
    must do it — how fast, how many at once, how available, how secure, who must
    be able to use it?"*

    You SHOULD capture each as a measurable target where one exists (*"checkout
    completes within 2 seconds for 95% of requests"*), still in business
    language — no implementation detail.

    If the customer has no non-functional requirements, you MUST record *"None
    known"* explicitly rather than leaving the section blank. A downstream
    specification step may read an empty section as an omission, not a decision.

8.  **Surface assumptions.**

    Whenever the user states something with confidence, you MUST ask: *"Is that
    something the customer has told us, or something we're assuming?"* You MUST
    capture every assumption explicitly. Each one is a risk to validate later.

9.  **Capture open questions.**

    Any question the user/customer cannot answer in this session you MUST put
    into an *Open Questions* list, with a named owner. You MUST NOT stall on
    unanswered questions — capture and move on. Discovery sessions end when no
    new rules emerge, not when every question is resolved.

10. **Produce the PRD.**

    You MUST confirm with the user that no further rules need to be elicited,
    then fill out the bundled template at
    [`assets/discover/product-requirements.template.md`](./assets/discover/product-requirements.template.md).

    The template has these sections: *Outcome* (problem, goal, why now, success
    measure), *Stakeholders*, *Scope* (in and out), *Rules*, *Examples* (an
    applies/doesn't-apply pair per rule), *Non-functional requirements*,
    *Assumptions*, and *Open questions* (each with an owner).

    You MUST report the PRD as this skill's output and stop.

## Rules

- **You MUST ask one question at a time.**

  You MUST NOT batch. A user (or customer) cannot answer four questions in a
  row without losing context, and batching erases the chance to let one answer
  shape the next.

- **You MUST stay in business language.**

  No technical jargon. No data structures, APIs, schemas, or code. The PRD
  MUST read sensibly to a non-technical customer. If a concept can only be
  expressed in technical terms, it does not belong here — defer it to the
  technical design phase (see **[design](../design/SKILL.md)**.

- **You MUST NOT volunteer solutions.**

  This skill is for understanding the problem. If the user starts proposing
  implementations, redirect: *"Let's park that — I want to understand the
  requirement first."* Solutions captured in discovery anchor the design
  prematurely.

- **You MUST NOT ask leading questions.**

  Avoid *"You'd want X, right?"* or *"Presumably the customer expects Y?"*.
  Use open, neutral questions: *"What does the customer expect here?"*.
  Leading questions seed the answers and erase information.

- **You MUST distinguish observation from assumption.**

  When confidence is stated without a source, ask whether the customer
  actually said it or we're inferring. Inferences belong in *Assumptions*, not
  *Rules*. An assumption that hardens into a rule without validation is a
  silent failure mode.

- **You MUST push back.**

  You MUST NOT be a "yes" machine, and MUST NOT assume the user's answers are
  correct, as they may be based on assumptions and biases — it's your job to
  discover those. Interrogate vague requests. Disagree when something's off.
  Flag contradictions — never silently overwrite.

  No sycophancy.

- **You MUST take notes.**

  You MUST capture context, decisions, and open threads continuously, and MUST
  checkpoint before switching domains or when a chat runs long.

- **The tone MUST be rigorous.**

  Rigorous. Direct. No fluff. Cover things properly, but you MUST NOT pad
  responses. Remove filler. Show reasoning, not just conclusions.

## Success criteria

- **Every rule MUST have at least one example AND one counter-example.**

  A rule without a counter-example is not ready to specify from — its
  boundaries are unclear.

- **Scope MUST be explicit in both directions.**

  The *Out of scope* list MUST be non-empty. Discovery without explicit
  exclusions hides ambiguity.

- **Assumptions MUST be flagged as assumptions.**

  A statement of confidence without a source MUST NOT survive in *Rules* — it
  MUST have been moved to *Assumptions* if the customer did not directly say
  it.

- **Open questions MUST name their owners.**

  Each unanswered question MUST identify who should answer it next.

- **Non-functional requirements MUST be recorded, even if none.**

  The *Non-functional requirements* section MUST state measurable targets where
  they exist, or *"None known"* — it MUST NOT be left blank, which a downstream
  step would read as an omission.

- **The PRD MUST read in business language.**

  A non-technical reader MUST be able to follow every sentence. No code, no API
  names, no schema details.

## Assets

- [Product requirements template](./assets/discover/product-requirements.template.md):
  The bundled PRD template to fill out in the final step.
