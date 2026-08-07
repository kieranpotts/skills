---
name: discover
description: >-
  Run a discovery workshop with the customer to elicit product requirements
  and record them as a product requirements document. Use when requirements
  are vague, ambiguous, or unclear, or when the user says something like
  "let's discover the requirements for…", "run a discovery session on…",
  "help me understand what the customer actually needs", or "interview me
  about this feature". Do not use it to write acceptance criteria, technical
  design, or code.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, WebFetch
license: CC0-1.0
---

# Discover

Run a structured discovery session with the customer, or their representative,
to elicit business requirements before specification, and record them as a
product requirements document (PRD) in business language. This is discovery
only — you MUST NOT change any code, configuration, or tests.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification. Beyond these parameters, this skill is
interactive throughout: you elicit the substance of the PRD from the user in
conversation, one question at a time.

- **A seed — OPTIONAL.** A draft PRD or similar artifacts, supplied as file
  paths, URLs, or pasted text. The seed MAY be vague, incomplete, or absent.
  Where it is absent, the outcome question in step 2 opens the session.

- **Product requirements store — REQUIRED.** Where the PRD is persisted.
  Discover this rather than assuming it: check this session's context first,
  then the environment (a convention file, an existing directory of product
  documentation, a configured connector), then ask the user. The store MAY be
  a file in this repository, a separate repository, or an external service
  such as a wiki or tracker, so do not assume a filesystem path or file name.

## Success criteria

- A PRD MUST exist in the resolved store, covering outcome, stakeholders,
  scope, rules, examples, non-functional requirements, assumptions, and open
  questions.

- Every rule MUST carry at least one example and one counter-example. A rule
  without a counter-example is not ready to specify from, because its
  boundary is undefined.

- The out-of-scope list MUST be non-empty, since discovery that names only
  what is included leaves the exclusions to be rediscovered during build.

- The non-functional requirements section MUST state measurable targets where
  they exist, or "None known" — never blank, which a downstream reader would
  take for an omission rather than a decision.

- Every open question MUST name the person or role who should answer it next.

- Anything the customer did not directly say MUST appear under assumptions
  rather than among the rules.

- The PRD MUST be free of code, identifiers, API and schema names, and field
  names, so that a non-technical reader can follow every sentence.

- Code, configuration, test, and build files MUST be unchanged, and the PRD's
  rules MUST NOT have been translated into acceptance criteria or filed into a
  downstream tracker.

## Instructions

Conduct the session as a structured interview. Ask one question at a time, in
the order below, and wait for the answer before asking the next. Let each
answer shape the question that follows.

1.  Confirm the seed.

    Restate what the user has brought you, in one sentence: "You want to
    understand the requirements for [feature/capability] — is that right?"
    Clarify before proceeding if the seed is ambiguous, since a discovery
    built on a misread seed produces an invalid PRD.

    If the user supplies existing artifacts, read them in full first, then
    ask which way to proceed:

    - Refine these existing artifacts in place: interrogate and extend what
      is already written, keeping its structure and filling its gaps. Treat
      the supplied content as the working draft.

    - Produce a fresh PRD using these as a basis: extract the problem,
      outcome, scope, and rules as raw material, then build a clean PRD to
      the bundled template. You MUST confirm each extracted item with the
      user before adopting it, because the artifacts may be stale, partial,
      or wrong.

    You MUST NOT assume either mode. Wait for the user to choose.

2.  Surface the outcome. Ask, one at a time:

    - "What problem is the customer facing? What's wrong or missing?"
    - "What is the customer trying to achieve?"
    - "Why now? What's the trigger for this requirement?"
    - "What measurable change would tell the customer this worked?"

    Capture as problem, goal, why now, and success measure. This layer keeps
    the why alive for whatever consumes the PRD next.

3.  Identify the stakeholders. Ask, one at a time:

    - "Who is affected by this?"
    - "Who decides whether it's done?"
    - "Whose work changes as a result?"

    For each stakeholder, capture the role and its interest in the outcome.

4.  Establish scope. Ask: "What is deliberately out-of-scope here? What are
    we choosing not to address?"

    You SHOULD push hard for an explicit out-of-scope list. It is among the
    most valuable things a discovery session produces.

5.  Elicit rules. Ask: "What rules govern this? Rules are things that must
    always be true, or must never happen."

    Capture each rule as a single declarative sentence, and number them.

6.  For each rule, elicit a concrete example and a counter-example. Ask:

    - "Give me a real case where this rule applies. What's the situation,
      and what happens?"
    - "Now give me a case that looks similar but where the rule does NOT
      apply. What's different?"

    Examples are the lifeblood of discovery — without them, rules are
    abstract noise, and the counter-example is what forces a sharp boundary.

    Capture examples in plain natural language, eg. "a premium customer with
    £600 in their cart sees free delivery presented at checkout". These are
    not yet testable acceptance criteria, and you MUST NOT write them as
    such.

7.  Elicit non-functional requirements. Ask: "Beyond what it must do, are
    there constraints on how well it must do it — how fast, how many at
    once, how available, how secure, who must be able to use it?"

    Capture each as a measurable target where one exists, eg. "checkout
    completes within 2 seconds for 95% of requests", still in business
    language. Where the customer has none, record "None known" explicitly.

8.  Surface assumptions. Whenever the user states something with confidence,
    ask: "Is that something the customer has told us, or something we're
    assuming?" Capture every assumption explicitly, as each one is a risk to
    validate later.

9.  Capture open questions. Any question the user or customer cannot answer
    in this session goes into the open questions list with a named owner.
    You SHOULD NOT stall on an unanswered question — capture it and move on.
    A session ends when no new rules emerge, not when every question is
    resolved.

10. Produce the PRD.

    Confirm with the user that no further rules need to be elicited, then
    fill out the bundled template and write the result to the resolved
    store, following whatever conventions that store documents for itself.

    Report the PRD as this skill's output and stop.

## Rules

- You MUST ask one question at a time, and MUST NOT batch.

  A user cannot answer four questions in a row without losing context, and
  batching erases the chance to let one answer shape the next.

- You MUST produce the PRD and stop there.

  You MUST NOT translate its rules and examples into testable acceptance
  criteria, nor carry it into design. Those are separate downstream
  responsibilities, and a PRD that arrives pre-specified forecloses the
  questions specification is meant to ask.

- You MUST stay in business language.

  No data structures, APIs, schemas, or code. If a concept can only be
  expressed in technical terms, it does not belong here — defer it to
  technical design.

- You MUST NOT volunteer solutions.

  If the user starts proposing implementations, redirect: "Let's park that —
  I want to understand the requirement first." Solutions captured during
  discovery anchor the design prematurely.

- You MUST NOT ask leading questions.

  Avoid "You'd want X, right?" or "Presumably the customer expects Y?". Use
  open, neutral questions instead: "What does the customer expect here?".
  Leading questions seed their own answers and erase information.

- You MUST distinguish observation from assumption.

  When confidence is stated without a source, ask whether the customer
  actually said it or we are inferring. An inference that hardens into a
  rule without validation is a silent failure mode.

- You MUST push back rather than agree.

  Do not assume the user's answers are correct — they may rest on the very
  assumptions and biases you are here to discover. Interrogate vague
  requests, disagree when something is off, and flag contradictions rather
  than silently overwriting. No sycophancy.

- You SHOULD take notes continuously, capturing context, decisions, and open
  threads, and SHOULD checkpoint before switching domains or when a session
  runs long.

- The tone SHOULD be rigorous and direct. Cover things properly, but do not
  pad. Show reasoning, not just conclusions.

## Edge cases

- The user answers as themselves rather than as the customer.

  Ask whether the answer reflects what a real customer has said or the
  user's own view, and record the latter under assumptions.

- The session produces rules but no examples the user can make concrete.

  Record the rule and raise an open question against it, owned by whoever
  can supply a real case. A rule with no example SHOULD NOT be presented as
  settled.

## Assets

- [Product requirements template](./assets/discover/product-requirements.template.md) \
  The PRD template to fill out in the final step, giving the section order
  and the shape of each entry.
