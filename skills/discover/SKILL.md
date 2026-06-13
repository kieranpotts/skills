---
name: discover
description: Run a structured customer-discovery session to elicit business requirements before specification. Uses Example Mapping with a thin outcome layer (Impact Mapping-style). Produces a discovery report – a transient, business-language PRD with no Gherkin – that feeds `specify`. Use when requirements are vague and an interview-style refinement is needed before a specification can be filed.
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: gemma4:31b
---

# Discover

Use this skill to run a structured discovery session that refines a customer's business needs into a discovery report. The agent acts as the business analyst, asking one question at a time. The user answers as the customer – either directly (when the user is the product owner) or as a relay (paraphrasing what real customers said in a prior conversation).

The output is a **discovery report**, not Gherkin. It is the project's product-requirements document (PRD) in all but name: a business-language statement of the problem, outcome, scope, rules, and open questions. It is a transient working artifact – it feeds [`specify`](../specify/SKILL.md) and is superseded by it. The durable record is the SRS proposal that `specify` files; this report is not itself filed in any workflow repository. Translation of its rules and examples into testable acceptance criteria is [`specify`](../specify/SKILL.md)'s job.

Do NOT use this skill when:

- A complete PRD already exists – with rules, examples, counter-examples, and an explicit scope – so go straight to [`specify`](../specify/SKILL.md). (A requirement that is merely "clear in someone's head" is not a PRD; `specify` will reject it. Run discovery to produce the artifact.)
- The user wants to interrogate a draft *design* – use [`elaborate`](../elaborate/SKILL.md) for technical refinement.
- The user wants implementation answers or technology choices – stay in business language; technical exploration belongs in [`design`](../design/SKILL.md).

## Instructions

Conduct the session as a structured interview. Ask one question at a time. Wait for the answer before asking the next. Let each answer shape the question that follows.

1.  **Confirm the seed.**
    Restate what the user has brought you, in one sentence: *"You want to understand the requirements for `<feature/capability>` – is that right?"*

    Clarify before proceeding if the seed is ambiguous. A discovery built on a misread seed produces a misread report.

2.  **Surface the outcome.**
    Ask, one at a time:

    - *"What is the customer trying to achieve? What does success look like for them?"*
    - *"Why now? What's the trigger – why does this matter at this moment?"*
    - *"What measurable change would tell the customer this worked?"*

    Capture as *Goal*, *Why now*, *Success measure*. This is the Impact Mapping layer – it keeps the *why* alive for downstream skills.

3.  **Identify the stakeholders.**
    Ask, one at a time:

    - *"Who is affected by this?"*
    - *"Who decides whether it's done?"*
    - *"Whose work changes as a result?"*

    For each stakeholder, capture role and interest in the outcome.

4.  **Establish scope.**
    Ask: *"What is deliberately out of scope here? What are we choosing not to address?"*

    An explicit out-of-scope list is one of the most valuable discovery artifacts. Push for it. Discovery sessions that produce only an *in-scope* list hide ambiguity that re-surfaces during build.

5.  **Elicit rules.**
    Ask: *"What rules govern this? Things that must always be true, or must never happen."*

    Capture each rule as a single declarative sentence. Number them.

6.  **For each rule, elicit at least one concrete example AND one counter-example.**
    For *each* rule, ask:

    - *"Give me a real case where this rule applies. What's the situation, and what happens?"*
    - *"Now give me a case that looks similar but where the rule does NOT apply – what's different?"*

    Examples are the lifeblood of discovery. Without examples, rules are abstract noise. The counter-example forces a sharper boundary.

    Capture examples in plain natural language (*"A premium customer with £600 in their cart sees free delivery presented at checkout"*) – not Gherkin. [`specify`](../specify/SKILL.md) will translate.

7.  **Surface assumptions.**
    Whenever the user states something with confidence, ask: *"Is that something the customer has told us, or something we're assuming?"* Capture every assumption explicitly. Each one is a risk to validate later.

8.  **Capture open questions.**
    Any question the user/customer cannot answer in this session goes into an *Open Questions* list, with a named owner. Do NOT stall on unanswered questions – capture and move on. Discovery sessions end when no new rules emerge, not when every question is resolved.

9.  **Produce the discovery report.**
    Confirm with the user that no further rules need to be elicited, then fill out the bundled template at [`assets/discovery-report-template.md`](./assets/discovery-report-template.md). It has these sections: *Outcome* (goal, why now, success measure), *Stakeholders*, *Scope* (in and out), *Rules*, *Examples* (an applies/doesn't-apply pair per rule), *Assumptions*, and *Open questions* (each with an owner).

    This report is the project's PRD in all but name – it captures the problem, success measure, scope, rules, and open questions in business language. It is a transient working artifact: it feeds [`specify`](../specify/SKILL.md), which produces the durable record (the SRS proposal). Do NOT file this report in a workflow repository; hand it to `specify`.

##  Rules

-   **One question at a time.**
    Never batch. A user (or customer) cannot answer four questions in a row without losing context, and batching erases the chance to let one answer shape the next.

-   **Stay in business language.**
    No technical jargon. No data structures, APIs, schemas, or code. The discovery report MUST read sensibly to a non-technical customer. If a concept can only be expressed in technical terms, it does not belong here – defer it to [`design`](../design/SKILL.md).

-   **Do not volunteer solutions.**
    This skill is for understanding the problem. If the user starts proposing implementations, redirect: *"Let's park that – I want to understand the requirement first."* Solutions captured in discovery anchor the design prematurely.

-   **No leading questions.**
    Avoid *"You'd want X, right?"* or *"Presumably the customer expects Y?"*. Use open, neutral questions: *"What does the customer expect here?"*. Leading questions seed the answers and erase information.

-   **Distinguish observation from assumption.**
    When confidence is stated without a source, ask whether the customer actually said it or we're inferring. Inferences belong in *Assumptions*, not *Rules*. An assumption that hardens into a rule without validation is a silent failure mode.

-   **Pushback.**
    Don't be a "yes" machine – don't assume the user's answers are correct, as they may be based on assumptions and biases – it's your job to discover those. Interrogate vague requests. Disagree when something's off. Flag contradictions – never silently overwrite. No sycophancy.

-   **Note-taking**
    Capture context, decisions, and open threads continuously. Checkpoint before switching domains or when a chat runs long.

-   **Tone.**
    Rigorous. Direct. No fluff. Cover things properly but don't pad responses. Remove filler. Show reasoning, not just conclusions.

-   **Counter-examples are mandatory.**
    A rule without a counter-example has fuzzy boundaries. The contrast between *"this case applies"* and *"this case looks similar but doesn't"* is where the rule's real shape becomes visible.

-   **Park unanswered questions; don't stall.**
    If a question cannot be answered now, capture it in *Open questions* with a named owner and move on. The report MUST surface incompleteness, not hide it behind a half-finished session.

##  Success criteria

-   **Every rule has at least one example AND one counter-example.**
    A rule without a counter-example is not ready for [`specify`](../specify/SKILL.md) – its boundaries are unclear.

-   **Scope is explicit in both directions.**
    The *Out of scope* list is non-empty. Discovery without explicit exclusions hides ambiguity.

-   **Assumptions are flagged as assumptions.**
    No statement of confidence without a source survives in *Rules* – it has been moved to *Assumptions* if the customer did not directly say it.

-   **Open questions name their owners.**
    Each unanswered question identifies who should answer it next.

-   **The report reads in business language.**
    A non-technical reader can follow every sentence. No code, no API names, no schema details.

## References

- [`assets/discovery-report-template.md`](./assets/discovery-report-template.md): The bundled discovery-report template to fill out in step 9.

- [Example Mapping](https://cucumber.io/blog/bdd/example-mapping-introduction/) (Matt Wynne, 2015): The core technique – rules, examples, and questions, captured in a single session.

- [Specification by Example](https://gojko.net/books/specification-by-example/) (Gojko Adzic): The broader philosophy – refine requirements through concrete cases, not abstract prose.

- [Impact Mapping](https://www.impactmapping.org/) (Gojko Adzic): Source of the *goal / actor / impact* framing used in the outcome section.

- [`specify`](../specify/SKILL.md): Downstream destination. The discovery report becomes input to `specify`, which validates it and – if complete – translates rules + examples into Gherkin acceptance criteria and files them as a proposal in the project's SRS repository. `specify` is non-interactive: an incomplete report is rejected with reasons and bounced back here. The completeness this skill enforces (every rule with a counter-example, an explicit out-of-scope list, blocking questions resolved) is exactly what `specify` checks for.

- [`elaborate`](../elaborate/SKILL.md): Peer skill – also interrogation-style, but refines a draft *design* rather than business requirements. Discovery deals with the customer; elaborate deals with the system.

- [`prototype`](../prototype/SKILL.md): Related sidecar pattern – `prototype` is to `design` what `discover` is to `specify`. Both unblock their parent skill by gathering evidence.
