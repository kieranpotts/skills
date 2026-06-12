---
name: specify
description: Specify software requirements as acceptance criteria (ACs) – both functional and non-functional – in testable forms, filed as a proposal in the project's SRS (software requirements specification) repository. Use when starting a new feature, scoping a change, refining a vague request into a contract, or before any design or coding work begins.
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: qwen3.5:cloud
---

# Specify

Use this skill before designing or coding a change, when the request is vague, or when the existing acceptance criteria are unclear, incomplete, or untestable. It produces a requirements proposal in the project's SRS (software requirements specification) repository, expressed as testable acceptance criteria.

Do NOT use this skill for design decisions (use [`design`](../design/SKILL.md)), implementation planning (use [`plan`](../plan/SKILL.md)), or test execution (use [`test`](../test/SKILL.md)).

This skill has two layers: (1) *Where and how the proposal is filed* is owned by the SRS repository and read at runtime – this skill does NOT restate that process. (2) *What makes the specification good* – the content expertise below – is owned by this skill.

##  Instructions

1.  **Locate the SRS repository.**

    Read the consuming project's root `AGENTS.md` and find its `Workflow repositories` section. This section maps each ecosystem role to a location (a path or a repository URL). Resolve the `SRS` entry to find where requirements live.

    If the project's `AGENTS.md` has no `Workflow repositories` section, or no `SRS` entry within it, the project is not wired to an SRS. Tell the user, and stop – do NOT guess a location or write requirements into an arbitrary file.

2.  **Read the SRS repository's `AGENTS.md` to learn its workflow.**

    The SRS repository's own `AGENTS.md` is the authoritative description of how a proposal is filed there: the proposal template, the branch convention, the lifecycle states, and the pull-request, discussion-thread, and label rules. Read it, and follow whatever it prescribes.

    Read `AGENTS.md`, NOT `CONTRIBUTING.md`. `CONTRIBUTING.md` is the workflow for human contributors; `AGENTS.md` is the workflow for agents. They may deliberately differ. As an agent, you follow `AGENTS.md`.

    Do NOT hard-code the SRS workflow from memory or from this skill. The process lives in the target repository so it can evolve, and so the agent workflow can differ from the human one. Always read it fresh.

3.  **Identify the user, the goal, and the value.**

    Before writing any criteria, answer three questions in plain language:

    - *Who* is this for? (User type, persona, role, or system actor.)
    - *What* do they want to do? (The goal, expressed as an outcome.)
    - *Why* does it matter? (The business value or problem to solve.)

    If any of these is unclear, ask the user. Do not invent answers.

4.  **Separate functional from non-functional requirements.**

    - *Functional requirements (FRs)*: what the system does – operations, behaviors, outputs.

    - *Non-functional requirements (NFRs)*: the constraints under which it operates – performance, security, availability, accessibility, data retention, scalability, and other dynamic qualities observed at runtime.

    Both MUST be specified. NFRs are often architecturally significant and harder to retrofit, so identify them up-front.

5.  **Write functional ACs in Gherkin** for any non-trivial feature.

    Use this structure:

    ```feature
    Feature: <short description>
      In order to <realize some value>
      As a <user type>
      I want to <achieve some goal>

      Scenario: <determinable situation>
        Given <state or precondition>
         And <state or precondition>
        When <event or action>
        Then <expected outcome>
         And <expected outcome>
    ```

    Rules:

    - One `.feature` file per feature (or per aspect of a feature).
    - Aim for ≤5 steps per scenario; ≤2 `When` steps.
    - Use `Background:` to factor out repeated `Given` steps.
    - Use `Scenario Outline:` + `Examples:` for variable-driven business rules – but only when the rule itself varies, not for UI permutations.
    - Steps describe observable outcomes (a report, a UI repaint, a response, a state change visible to the user) – NOT internal state.

    For simple requests where Gherkin is overkill, a structured bullet list of testable conditions is acceptable.

6.  **Write NFRs as measurable benchmarks.**

    Each NFR MUST be either:

    - A *quantitative metric* with a target (eg. "p99 latency under 200ms at 1000 concurrent users", "99.9% uptime", "MTTR under 15 minutes"), OR
    - *Conformance to a published standard* (eg. AES-256 at rest, TLS 1.3 in transit, WCAG 2.2 AA, GDPR Article 32), OR
    - *A user-story-style requirement* for security/authorization concerns (eg. "As an admin, I can revoke a user's session so that...").

    Vague NFRs ("must be fast", "should be secure") are NOT acceptable – convert them to one of the forms above or flag them for clarification.

7.  **Capture what is out of scope.**

    A specification that lists only what to build invites scope creep during design and implementation. Add an explicit "Out of scope" section that names:

    - *Deferred features* the user might assume are in scope ("Refund flow – coming in Phase 2").
    - *Adjacent functionality* that touches the same area but is not changing ("Order cancellation – existing behavior unchanged, not under review here").
    - *Decisions explicitly NOT being revisited* ("Payment provider choice – stays with Stripe for this change").
    - *Things ruled out during clarification* ("Discussed bulk refunds; decided to defer until single-refund flow is stable").

    A reader of the specification – a designer, a developer, a reviewer – should finish with a clear picture of where the specification ends, not just where it starts.

8.  **Verify each AC is testable.**

    For every scenario or condition, ask: *what observable outcome would prove this passes or fails?* If you can't answer that without referring to implementation details, the AC is not testable – rewrite it.

9.  **Check against the Definition of Ready.**

    Before declaring the specification complete, run through the DoR checklist:

    - Are the requirements clear and unambiguous?
    - Are the ACs in a testable, automatable form?
    - Are stakeholders identified?
    - Can the work be done independently of other parallel work?
    - Can it be implemented in small increments?

    Flag any unmet item to the user.

10. **File the proposal per the SRS repository's process.**

    Write the proposal content into the artifact the SRS repository's template defines, in the location its `AGENTS.md` specifies, and file it following that repository's workflow – branch, pull request, discussion thread, and lifecycle labels exactly as its `AGENTS.md` prescribes. Do not improvise these mechanics; defer to the target repository.

##  Rules

-   **Read the SRS repository's `AGENTS.md`, not its `CONTRIBUTING.md`.**

    `AGENTS.md` is the agent's workflow; `CONTRIBUTING.md` is the human's. They may differ deliberately. Follow `AGENTS.md`.

-   **Never hard-code the SRS workflow.**

    The branch convention, proposal template, lifecycle states, and filing mechanics live in the target repository. Read them fresh each time. Do not assume them from memory.

-   **Stop if no SRS is declared.**

    If the project's `AGENTS.md` does not declare an `SRS` location under `Workflow repositories`, do not write requirements anywhere. Tell the user the project is not wired to an SRS.

-   **Specify the problem, not the solution.**

    ACs describe user needs and outcomes. They MUST NOT prescribe implementation: no class names, no API endpoints, no database tables, no framework choices. Ideally, ACs do not even mention "software" – they describe what the user can do or observe.

-   **Use domain language, not technical jargon.**

    ACs are a contract with business stakeholders. Use the vocabulary of the business domain (customer, order, refund, dosage, invoice) – not the vocabulary of the codebase (entity, repository, DTO, controller).

-   **Doctor, not waiter.**

    The job is to surface the underlying need, then specify a solution that meets it – not to transcribe what the user literally asked for. If the requested change won't solve the actual problem, say so before writing ACs.

-   **Avoid `Then` assertions on internal state.**

    Assert on outputs the user can observe: rendered UI, API responses, logged messages, command output, state visible in a downstream report. Assertions on database rows, queue contents, or in-memory data structures couple the specification to the implementation.

-   **Bundle authorization into functional requirements.**

    Permissions and roles ("As an admin, I can...") belong in the functional specification as user stories, not in a separate NFR list. Encryption, audit logging, and compliance-driven constraints belong in NFRs.

-   **Identify NFRs early.**

    NFRs around scalability, durability, security, and compliance often dictate fundamental architecture choices (technology stack, database, deployment topology). Surface them in the specification before any design work starts.

## Examples

A minimal functional specification (Gherkin):

```feature
Feature: Refund item
  In order to be confident in my purchases
  As a customer
  I want to receive refunds for faulty goods

  Scenario: A customer returns a faulty microwave
    Given a customer has bought a microwave for $100
     And the customer has a valid receipt
    When the customer returns the microwave
    Then the customer should be refunded $100
```

A scenario outline for a variable business rule:

```feature
Scenario Outline: Tier-based discount
  Given a customer is on the <tier> plan
   And their cart subtotal is <subtotal>
  When they apply the loyalty discount
  Then the order total should be <total>

  Examples:
    | tier     | subtotal | total |
    | bronze   | 100      | 95    |
    | silver   | 100      | 90    |
    | gold     | 100      | 80    |
```

Non-functional requirements (measurable):

```
Performance:
- p95 API latency < 250ms at 500 RPS sustained.
- Cold start of the order-service Lambda < 800ms.

Availability:
- 99.9% monthly uptime for the public checkout API.
- RTO ≤ 1 hour, RPO ≤ 5 minutes for the orders database.

Security & compliance:
- All PII encrypted at rest with AES-256 and in transit with TLS 1.3.
- Conforms to GDPR Article 32 for processing of customer data.
- WCAG 2.2 AA for all customer-facing web pages.
```

Out-of-scope:

```
Out-of-scope:
- Bulk refund flow – deferred to Phase 2 (tracking issue #519).
- Refunds in non-USD currencies – existing single-currency handling
  remains unchanged.
- Payment-provider choice – stays with Stripe; not under review.
- Auto-detecting fraud during refund – discussed in clarification,
  ruled out until we have a baseline of single-currency refund data.
```

A `Workflow repositories` declaration, as it appears in the consuming project's root `AGENTS.md`:

```markdown
## Workflow repositories

- SRS: ./docs/specs
- RFC: ./docs/rfc
- Design: ./docs/design
- Plans: ./docs/plans
```

##  Edge cases

-   **No SRS declared.**

    The project's `AGENTS.md` has no `Workflow repositories` section, or no `SRS` entry. Stop and tell the user – the project is not wired to an SRS, and requirements have no home. Do not write them into an arbitrary file.

-   **Spike or research task.**

    The goal is to *learn*, not to ship a feature. Write the specification as a list of questions to answer, with a time-box, rather than as ACs.

-   **Bug fix.**

    The AC is usually a Gherkin scenario that fails today and should pass after the fix. Include the reproduction steps as `Given`/`When` and the correct behavior as `Then`.

-   **Refactor or internal change.**

    There are no new ACs. The specification is "existing ACs continue to pass, plus these new internal-quality criteria" (eg. cyclomatic complexity reduced, tests faster, module decoupled). Use [`refactor`](../refactor/SKILL.md) instead.

-   **Existing specification is wrong.**

    If you discover during specification that an existing AC is incorrect or contradicts a new requirement, flag the conflict to the user before resolving it. Do not silently rewrite.

##  Success criteria

-   **The proposal is filed in the SRS repository.**

    The specification lives in the project's declared SRS repository, in the artifact its template defines, filed through that repository's own workflow – not in an arbitrary file or the working repository.

-   **Every AC is testable.**

    For each scenario or condition, an observable pass/fail outcome is identifiable without reading implementation code.

-   **No implementation details leak into the specification.**

    No class, file, endpoint, table, or framework name appears in an AC. Re-read with that filter before finishing.

-   **Functional and non-functional requirements are both present.**

    Even if the NFR section is "no new NFRs – inherits from system baseline", it is stated explicitly, not omitted.

-   **Out-of-scope items are named.**

    The specification includes an explicit list of deferred features, adjacent functionality not under review, and decisions ruled out during clarification – not just what is being built.

-   **The user, goal, and value are stated.**

    Each feature block names *who* it is for, *what* they achieve, and *why*.

-   **The Definition of Ready is satisfied or unmet items are flagged.**

## References

- [`discover`](../discover/SKILL.md): Upstream sidecar – run a structured customer-discovery session before writing a specification when requirements are vague. The discovery report (outcome, stakeholders, rules, examples) is direct input to this skill.

- [`design`](../design/SKILL.md): The next step after a specification is approved.

- [`test`](../test/SKILL.md): How specified ACs are verified.

- [`refine`](../refine/SKILL.md): Where feedback from [`test`](../test/SKILL.md) (a wrong, missing, or ambiguous AC) flows back into the specification. Refinements land here as edits and re-enter the workflow.
