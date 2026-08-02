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
  preferred_model: ollama/ANALYSIS_STANDARD
---

# Discover

Run a structured discovery session with the customer, or their representative,
to elicit business requirements before specification. Produce a product
requirements document (PRD) in business language that captures outcomes,
stakeholders, scope, business rules (with examples), and non-functional
requirements.

Discovery only. You MUST NOT make any code or configuration changes to the
software itself.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the input requirements,
prompt the user for clarification.

- **A seed PRD or artifacts — OPTIONAL.** The user MAY provide a draft PRD
  or similar artifacts (via file paths, URLs, or pasted text) to be edited
  in place, or to use as a basis for a fresh PRD. The seed may be vague,
  incomplete, or absent.

- **Where the PRD should be written — REQUIRED.** Discover this rather than
  assuming it: check this session's context first, then the environment (a
  convention file such as `AGENTS.md`, an existing directory of product
  documentation, a configured connector). If neither settles it, ask the
  user. It MAY be a file in this repository, a separate repository, or an
  external service such as a wiki or tracker — do not assume a filesystem
  path or a file name.

Gathers the rest of the input you needs from the user. Prompt one question
at a time.

This skill is interactive. The agent prompts the user for clarification,
asking one question at a time and waiting for the answer before proceeding.

## Success criteria

You will achieve the following outcomes:

- The skill MUST produce a new or modified PRD in business language,
  covering outcomes, stakeholders, scope, rules, examples, non-functional
  requirements, assumptions, and open questions.

- The PRD MUST enforce completeness by having a counter-example for every
  rule, an explicit out-of-scope list, non-functional requirements
  explicitly recorded (even if none), and blocking questions resolved.

- Technical implementation and validation details MUST be out-of-scope —
  this is not a specification or design document; this skill MUST produce
  the PRD and stop.

- It MUST NOT file the PRD in any workflow repository, and it MUST NOT
  translate the rules and examples into testable acceptance criteria —
  these are separate downstream responsibilities.

- Every rule MUST have at least one example AND one counter-example — a
  rule without a counter-example is not ready to specify from, since its
  boundaries are unclear.

- Scope MUST be explicit in both directions: the out-of-scope list MUST be
  non-empty, since discovery without explicit exclusions hides ambiguity.

- Assumptions MUST be flagged as assumptions: a statement of confidence
  without a source MUST NOT survive in Rules — it MUST have been moved to
  Assumptions if the customer did not directly say it.

- Open questions MUST name their owners: each unanswered question MUST
  identify who should answer it next.

- Non-functional requirements MUST be recorded, even if none: the
  Non-functional requirements section MUST state measurable targets where
  they exist, or "None known" — it MUST NOT be left blank, which a
  downstream step would read as an omission.

- The PRD MUST read in business language: a non-technical reader MUST be
  able to follow every sentence, with no code, no API names, no schema
  details.

## Instructions

Conduct the session as a structured interview. Ask one question at a time,
in the order below, and wait for the answer before asking the next. Let each
answer shape the question that follows.

1.  Confirm the seed.

    Restate what the user has brought you, in one sentence: "You want to
    understand the requirements for <feature/capability> — is that right?"

    Clarify before proceeding if the seed is ambiguous. A discovery built
    on a misread seed produces an invalid PRD.

    If the user supplies existing business requirements artifacts (a file
    path, a URL, or pasted text), read them in full first, then ask which
    way to proceed:

    - "Refine these existing artifacts in place?": Interrogate and extend
      what is already written, keeping its structure, filling its gaps.
      Treat the supplied content as the working draft.

    - "Produce a fresh PRD using these as a basis?": Extract the problem,
      outcome, scope, rules, and so on from the artifacts as raw material,
      then build a clean PRD to this skill's template. Confirm each
      extracted item with the user before adopting it — do not carry
      anything over unverified — the artifacts may be stale, partial, or
      wrong.

    Do not assume either mode. Wait for the user to choose before
    continuing the interview.

2.  Surface the outcome.

    Ask, one at a time:

    - "What problem is the customer facing? What's wrong or missing?"
    - "What is the customer trying to achieve?"
    - "Why now? What's the trigger for this requirement?"
    - "What measurable change would tell the customer this worked?"

    Capture as Problem, Goal, Why now, Success measure. This is the
    Impact Mapping layer — it keeps the why alive for downstream skills.

3.  Identify the stakeholders.

    Ask, one at a time:

    - "Who is affected by this?"
    - "Who decides whether it's done?"
    - "Whose work changes as a result?"

    For each stakeholder, capture role and interest in the outcome.

4.  Establish scope.

    Ask: "What is deliberately out-of-scope here? What are we choosing not
    to address?"

    An explicit out-of-scope list is one of the most valuable discovery
    artifacts. Push for it. Discovery sessions that produce only an
    in-scope list hide ambiguity that re-surfaces during build.

5.  Elicit rules.

    Ask: "What rules govern this? Rules are things that must always be
    true, or must never happen."

    Capture each rule as a single declarative sentence, and number them.

6.  For each rule, elicit concrete examples and counter-examples.

    For each rule, ask:

    - "Give me a real case where this rule applies."
    - "What's the situation, and what happens?"
    - "Now give me a case that looks similar but where the rule does NOT
      apply. What's different?"

    Examples are the lifeblood of discovery. Without examples, rules are
    abstract noise. The counter-example forces a sharper boundary.

    Capture examples in plain natural language ("A premium customer with
    £600 in their cart sees free delivery presented at checkout"). These
    are not yet testable acceptance criteria.

7.  Elicit non-functional requirements.

    Ask: "Beyond what it must do, are there constraints on how well it must
    do it — how fast, how many at once, how available, how secure, who must
    be able to use it?"

    Capture each as a measurable target where one exists ("checkout
    completes within 2 seconds for 95% of requests"), still in business
    language — no implementation detail.

    If the customer has no non-functional requirements, record "None
    known" explicitly rather than leaving the section blank. A downstream
    specification step may read an empty section as an omission, not a
    decision.

8.  Surface assumptions.

    Whenever the user states something with confidence, ask: "Is that
    something the customer has told us, or something we're assuming?"
    Capture every assumption explicitly. Each one is a risk to validate
    later.

9.  Capture open questions.

    Any question the user/customer cannot answer in this session, put
    into an Open Questions list, with a named owner. Do not stall on
    unanswered questions — capture and move on. Discovery sessions end
    when no new rules emerge, not when every question is resolved.

10. Produce the PRD.

    Confirm with the user that no further rules need to be elicited, then
    fill out the bundled template at
    [`assets/discover/product-requirements.template.md`](./assets/discover/product-requirements.template.md).

    The template has these sections: Outcome (problem, goal, why now,
    success measure), Stakeholders, Scope (in and out), Rules, Examples
    (an applies/doesn't-apply pair per rule), Non-functional requirements,
    Assumptions, and Open questions (each with an owner).

    Report the PRD as this skill's output and stop.

## Rules

- You MUST ask one question at a time.

  You MUST NOT batch. A user (or customer) cannot answer four questions in
  a row without losing context, and batching erases the chance to let one
  answer shape the next.

- You MUST stay in business language.

  No technical jargon. No data structures, APIs, schemas, or code. The
  PRD MUST read sensibly to a non-technical customer. If a concept can
  only be expressed in technical terms, it does not belong here — defer
  it to the technical design phase.

- You MUST NOT volunteer solutions.

  This skill is for understanding the problem. If the user starts
  proposing implementations, redirect: "Let's park that — I want to
  understand the requirement first." Solutions captured in discovery
  anchor the design prematurely.

- You MUST NOT ask leading questions.

  Avoid "You'd want X, right?" or "Presumably the customer expects Y?".
  Use open, neutral questions: "What does the customer expect here?".
  Leading questions seed the answers and erase information.

- You MUST distinguish observation from assumption.

  When confidence is stated without a source, ask whether the customer
  actually said it or we're inferring. Inferences belong in Assumptions,
  not Rules. An assumption that hardens into a rule without validation is
  a silent failure mode.

- You MUST push back.

  You MUST NOT be a "yes" machine, and MUST NOT assume the user's answers
  are correct, as they may be based on assumptions and biases — it's your
  job to discover those. Interrogate vague requests. Disagree when
  something's off. Flag contradictions — never silently overwrite.

  No sycophancy.

- You MUST take notes.

  You MUST capture context, decisions, and open threads continuously,
  and MUST checkpoint before switching domains or when a chat runs long.

- The tone MUST be rigorous.

  Rigorous. Direct. No fluff. Cover things properly, but you MUST NOT
  pad responses. Remove filler. Show reasoning, not just conclusions.

## Assets

- [Product requirements template](./assets/discover/product-requirements.template.md):
  The bundled PRD template to fill out in the final step.

## References

None.
