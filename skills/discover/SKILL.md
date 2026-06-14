---
name: discover
description: Run a structured customer-discovery session to elicit business requirements before specification, producing a product requirements document (PRD) in business language that captures outcome, stakeholders, scope, rules with examples, and non-functional requirements. Uses Example Mapping with a thin Impact-Mapping-style outcome layer. Use when requirements are vague, ambiguous, or unclear, and an interview-style refinement is needed before a specification can be created, or when the user says things like "let's discover the requirements for…", "run a discovery session on…", "help me understand what the customer actually needs", or "interview me about this feature".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: gemma4:31b
---

# `/discover`

Use this skill to run a structured discovery session that refines a customer's business needs into a product requirements document (PRD). The agent acts as the business analyst, asking one question at a time. The user answers as the customer – either directly (as a real customer) or as a relay (paraphrasing what real customers said in prior conversations).

**Input**: The user MAY provide a draft PRD or similar artifacts (via file paths, URLs, or pasted text) to be edited in place, or to use as a basis for a fresh PRD. This is OPTIONAL – the seed may be vague, incomplete, or absent. This skill is **interactive** – it gathers the rest of the input from the user through prompts during the session, asking one question at a time. Crystallizing a vague business need into a complete PRD is the purpose of the discovery session.

**Output**: A new or modified PRD in business language, covering outcomes, stakeholders, scope, rules, examples, non-functional requirements, assumptions, and open questions. The PRD enforces completeness by having a counter-example for every rule, an explicit out-of-scope list, non-functional requirements explicitly recorded (even if none), and blocking questions resolved. Technical implementation and validation details are out-of-scope – this is not a specification or design document.

This skill produces the PRD and stops. It does NOT file the PRD in any workflow repository, and it does NOT translate the rules and examples into testable acceptance criteria. These are separate downstream responsibilities.

Do NOT use this skill when:

- A complete PRD (or similar artifact) already exists – with rules, examples, counter-examples, and an explicit scope – so it is ready to specify from directly (jump to [`/specify`](../specify/SKILL.md)).

- The user wants to interrogate a draft solution design – that is technical refinement of a system, not business discovery (see [`/elaborate`](../elaborate/SKILL.md)).

## Instructions

Conduct the session as a structured interview. Ask one question at a time, in the order below. Wait for the answer before asking the next. Let each answer shape the question that follows.

1.  **Confirm the seed.**

    Restate what the user has brought you, in one sentence: *"You want to understand the requirements for <feature/capability> – is that right?"*

    Clarify before proceeding if the seed is ambiguous. A discovery built on a misread seed produces an invalid PRD.

    If the user supplies existing business requirements artifacts (a file path, a URL, or pasted text), read them in full first, then ask which way to proceed:

    - *"Refine these existing artifacts in place?"*: Interrogate and extend what is already written, keeping its structure, filling its gaps. Treat the supplied content as the working draft.

    - *"Produce a fresh PRD using these as a basis?"*: Extract the problem, outcome, scope, rules, and so on from the artifacts as raw material, then build a clean PRD to this skill's template. Confirm each extracted item with the user before adopting it – do NOT carry anything over unverified – the artifacts may be stale, partial, or wrong.

    Do NOT assume either mode. Wait for the user to choose before continuing the interview.

2.  **Surface the outcome.**

    Ask, one at a time:

    - *"What problem is the customer facing? What's wrong or missing?"*
    - *"What is the customer trying to achieve?"*
    - *"Why now? What's the trigger for this requirement?"*
    - *"What measurable change would tell the customer this worked?"*

    Capture as *Problem*, *Goal*, *Why now*, *Success measure*. This is the Impact Mapping layer – it keeps the *why* alive for downstream skills.

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

    Ask: *"What rules govern this? Rules are things that must always be true, or must never happen."*

    Capture each rule as a single declarative sentence. Number them.

6.  **For each rule, elicit concrete examples and counter-examples.**

    For *each* rule, ask:

    - *"Give me a real case where this rule applies."*
    - *"What's the situation, and what happens?"*
    - *"Now give me a case that looks similar but where the rule does NOT apply. What's different?"*

    Examples are the lifeblood of discovery. Without examples, rules are abstract noise. The counter-example forces a sharper boundary.

    Capture examples in plain natural language (*"A premium customer with £600 in their cart sees free delivery presented at checkout"*). These are not yet testable acceptance criteria.

7.  **Elicit non-functional requirements.**

    Ask: *"Beyond what it must do, are there constraints on how well it must do it – how fast, how many at once, how available, how secure, who must be able to use it?"*

    Capture each as a measurable target where one exists (*"checkout completes within 2 seconds for 95% of requests"*), still in business language – no implementation detail.

    If the customer has no non-functional requirements, record *"None known"* explicitly rather than leaving the section blank. A downstream specification step may read an empty section as an omission, not a decision.

8.  **Surface assumptions.**

    Whenever the user states something with confidence, ask: *"Is that something the customer has told us, or something we're assuming?"* Capture every assumption explicitly. Each one is a risk to validate later.

9.  **Capture open questions.**

    Any question the user/customer cannot answer in this session goes into an *Open Questions* list, with a named owner. Do NOT stall on unanswered questions – capture and move on. Discovery sessions end when no new rules emerge, not when every question is resolved.

10. **Produce the PRD.**

    Confirm with the user that no further rules need to be elicited, then fill out the bundled template at [`assets/product-requirements.template.md`](./assets/product-requirements.template.md).

    The template has these sections: *Outcome* (problem, goal, why now, success measure), *Stakeholders*, *Scope* (in and out), *Rules*, *Examples* (an applies/doesn't-apply pair per rule), *Non-functional requirements*, *Assumptions*, and *Open questions* (each with an owner).

    Report the PRD as this skill's output and stop.

##  Rules

-   **One question at a time.**

    Never batch. A user (or customer) cannot answer four questions in a row without losing context, and batching erases the chance to let one answer shape the next.

-   **Stay in business language.**

    No technical jargon. No data structures, APIs, schemas, or code. The PRD MUST read sensibly to a non-technical customer. If a concept can only be expressed in technical terms, it does not belong here – defer it to the technical design phase (see [`/design`](../design/SKILL.md).

-   **Do not volunteer solutions.**

    This skill is for understanding the problem. If the user starts proposing implementations, redirect: *"Let's park that – I want to understand the requirement first."* Solutions captured in discovery anchor the design prematurely.

-   **No leading questions.**

    Avoid *"You'd want X, right?"* or *"Presumably the customer expects Y?"*. Use open, neutral questions: *"What does the customer expect here?"*. Leading questions seed the answers and erase information.

-   **Distinguish observation from assumption.**

    When confidence is stated without a source, ask whether the customer actually said it or we're inferring. Inferences belong in *Assumptions*, not *Rules*. An assumption that hardens into a rule without validation is a silent failure mode.

-   **Push back.**

    Don't be a "yes" machine. Don't assume the user's answers are correct, as they may be based on assumptions and biases – it's your job to discover those. Interrogate vague requests. Disagree when something's off. Flag contradictions – never silently overwrite.

    No sycophancy.

-   **Note-taking**

    Capture context, decisions, and open threads continuously. Checkpoint before switching domains or when a chat runs long.

-   **Tone.**

    Rigorous. Direct. No fluff. Cover things properly but don't pad responses. Remove filler. Show reasoning, not just conclusions.

-   **Counter-examples are mandatory.**

    A rule without a counter-example has fuzzy boundaries. The contrast between *"this case applies"* and *"this case looks similar but doesn't"* is where the rule's real shape becomes visible.

##  Success criteria

-   **Every rule has at least one example AND one counter-example.**

    A rule without a counter-example is not ready to specify from – its boundaries are unclear.

-   **Scope is explicit in both directions.**

    The *Out of scope* list is non-empty. Discovery without explicit exclusions hides ambiguity.

-   **Assumptions are flagged as assumptions.**

    No statement of confidence without a source survives in *Rules* – it has been moved to *Assumptions* if the customer did not directly say it.

-   **Open questions name their owners.**

    Each unanswered question identifies who should answer it next.

-   **Non-functional requirements are recorded, even if none.**

    The *Non-functional requirements* section states measurable targets where they exist, or *"None known"* – never left blank, which a downstream step would read as an omission.

-   **The PRD reads in business language.**

    A non-technical reader can follow every sentence. No code, no API names, no schema details.

## References

- [`assets/product-requirements.template.md`](./assets/product-requirements.template.md): The bundled PRD template to fill out in the final step.
