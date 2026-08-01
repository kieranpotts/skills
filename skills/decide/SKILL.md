---
name: decide
description: >-
  Frame a technical decision and write it up as an RFC — a proposal that
  invites informed disagreement before the decision is settled. Use when a
  decision about architecture, process, technology, or tooling needs
  stakeholder review, or when the user says something like "write an RFC for
  this", "draft an RFC proposing X", "we need to decide whether to adopt Y",
  or "help me make the case for this change".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/software-architect
---

# Decide

Frame a technical decision, work through its genuine alternatives, and write
it up as an RFC — a document whose purpose is to be argued with *before* the
decision is settled.

Covers decisions about architecture, process, technology, and tooling. This
skill authors the decision record's content only. Moving it through whatever
lifecycle the decision store defines, and landing it there, belongs to that
store's own workflow.

An RFC is written while the outcome is still open. A decision that has
already been settled is recorded the same way — as a decision record in the
same store, written retrospectively — not as a separate class of artifact
kept somewhere else.

## Parameters

Determine the following from the surrounding context and environment.

- **A decision that needs making — REQUIRED.** Supplied as the user's
  description, an issue, a discussion thread, or an upstream design doc.
  This skill ALSO gathers what it needs (motivation, constraints, candidate
  options, stakeholders) from the user through prompts during the session,
  so the initial input MAY be partial or absent.

- **Where the decision store lives, and how to write to it — REQUIRED.**
  Discover this rather than assuming it: check this session's context first,
  then the environment (a convention file such as `AGENTS.md`, a workspace
  manifest, a configured connector). If neither settles it, ask the user.
  The store MAY be a directory in this repository, a separate repository, or
  an external service such as a wiki or documentation platform — do not
  assume a filesystem path, a file name, or a document structure. Different
  projects call this an RFC archive, a decision log, an ADR directory, or a
  set of key design decisions; they are the same role.

This skill is interactive. The agent prompts the user to gather what the
decision needs, and to establish where the decision store is when context
and environment do not settle it.

## Success criteria

You will achieve the following outcomes:

- A completed decision record, written against the target store's own
  template where it has one, stating the decision, its motivation, the
  alternatives considered, the honest trade-offs, a recommendation, and the
  conditions under which that recommendation would change.

- No lifecycle action was taken. No branch was cut, pull request opened,
  label applied, or merge performed — those belong to the store's own
  workflow.

- The decision statement is a single, disagreeable sentence.

  One sentence, specific enough that a reviewer could reasonably argue the
  opposite, accompanied by an explicit out-of-scope list.

- At least two genuine alternatives are evaluated, plus doing nothing.

  None of them is a strawman; each is an option a competent colleague could
  advocate.

- The downsides of the recommendation are stated explicitly.

  The RFC names what the preferred option costs and what it risks, not only
  what it gains.

- Every load-bearing claim is marked verified or assumed.

  No assumption is presented as established fact; unverified ones appear in
  the open questions.

- The RFC states what would change the recommendation.

  At least one concrete condition under which a different option wins.

- The store was discovered, not assumed.

  Its location and access method trace to session context, to the
  environment, or to an answer from the user — no path, file name, or
  document structure was taken for granted.

- The document fits the target store's template.

  Every section that store's template requires is present and filled, with
  no leftover boilerplate. Where the store had no template, the minimum
  section set is covered and the report says which shape was used.

## Instructions

1.  Write the decision statement.
    One sentence naming exactly what is being decided. Then write a short list
    of what is explicitly *out* of scope.

    Test it: could a reasonable colleague disagree with that sentence? If it
    is too vague to disagree with ("improve our tooling"), it is not yet a
    decision — sharpen it until it is ("adopt pnpm as the package manager for
    all TypeScript services").

2.  Check the decision warrants a record.
    A decision record earns its cost when the decision is expensive to
    reverse, crosses team or service boundaries, or sets a precedent others
    will follow.

    If it is cheap to reverse and touches one module, skip the record and
    just make the change. Say so and stop rather than generating ceremony.

    If the decision is already settled and only needs recording, still write
    it here — the same store, the same shape, entered at whatever state that
    store uses for a decision already taken. Note in the record that it was
    written retrospectively, so a reader knows the alternatives were weighed
    before the fact rather than after.

3.  Establish the motivation.
    State the problem, who suffers from it, and why it needs addressing now.
    Quantify wherever possible — incident counts, build minutes, onboarding
    days, error rates.

    "The current approach is bad" is not motivation. Include the cost of
    doing nothing; if that cost is low, the RFC may not be justified.

4.  Describe the current state honestly.
    How the affected architecture, process, technology, or tooling works
    today, and specifically where it falls short. Omit for a greenfield
    choice with no incumbent.

    Resist the urge to make the status quo look worse than it is. Reviewers
    who know the system will spot it, and it costs you the argument.

5.  Separate what is known from what is assumed.
    List the facts the decision turns on, and mark each as verified or
    assumed.

    Where the decision depends on external facts — library maturity,
    licensing, benchmark numbers, API capability — use the
    [`research`](../research/) skill to establish them. Where it depends on
    whether something will actually work, use the [`spike`](../spike/) skill.
    Do not build a recommendation on unverified assumptions; either verify
    them or carry them into the open questions.

6.  Enumerate genuine alternatives.
    At least two real options, plus doing nothing. Each MUST be an option a
    competent colleague could actually advocate.

    For architecture decisions, run the trade-off analysis with the
    [`design`](../design/) skill and bring its conclusions here rather than
    duplicating the method.

7.  Weigh the trade-offs honestly.
    For each option, state what it costs, what it risks, and who carries the
    burden — including the operational tail: monitoring, migration, on-call,
    dependency upkeep.

    State the downsides of your preferred option explicitly. An RFC with no
    stated downsides reads as advocacy and gets discounted accordingly.

8.  Assess the impact.
    Rate the blast radius (`HIGH`, `MEDIUM`, `LOW`) and name who and what is
    affected — the architecture, the development or operations process, the
    contributors, the service level agreement. Note effects on cross-cutting
    concerns: security, performance, availability, the technology stack.

    For decisions with a security dimension, the [`probe`](../probe/) skill
    can surface threats worth naming here.

9.  Recommend one option — and say what would change your mind.
    Name the recommendation and the reasoning: which factors dominate, and
    which you are accepting as weaker.

    Then state the conditions under which a different option wins ("if
    sustained throughput exceeds 2,000/sec, option 3 becomes correct"). This
    is what turns a fait accompli into a genuine request for comments, and it
    gives reviewers something concrete to push against.

10. Surface the open questions.
    List what remains unresolved, and what is deliberately deferred to a
    separate decision. Do not paper over unknowns — an RFC that hides them
    gets ambushed in review, and the ambush costs more than the admission.

11. Write it up against the target store's own template.
    Resolve the decision store (see Input), then read whatever it publishes
    about itself — its template, its convention file, its contributor
    documentation — and fill out the sections it actually defines, including
    any metadata header and any categorisation it expects.

    Where the store has no template, cover at minimum: summary, motivation,
    impact, current state, proposed state, alternatives, trade-offs and
    risks, open questions, and references. Where the store is not empty but
    undocumented, match the shape of the records already in it.

    Write the proposed state in the present tense, describing the system as
    it would be. Lead with the summary; keep it skimmable. Where a diagram
    carries the argument better than prose, embed one.

12. Self-review, report, and stop.
    Check the draft against the rules and success criteria below. Report the
    RFC and stop — do not cut a branch, open a pull request, apply labels, or
    merge anything.

## Rules

- You MUST make the RFC contestable.

  The document exists to gather comments. A proposal that offers reviewers
  no purchase — no stated downsides, no alternatives taken seriously, no
  conditions that would change the recommendation — collects agreement
  rather than scrutiny, which is how bad decisions get ratified.

-   **You MUST discover the decision store's location and conventions; you
    MUST NOT assume them.**

    This skill is used across projects that record decisions in different
    places and formats — an RFC archive, an ADR directory, a decision log, a
    wiki space. A path, file name, template, or section structure that is
    right in one project is wrong in the next. Resolve the store first, then
    read and follow whatever conventions it documents for itself.

- You MUST NOT present a strawman alternative.

  Listing options nobody would choose, purely to make the preferred one
  look inevitable, is worse than listing no alternatives at all. It signals
  the decision was made before the RFC was written.

- You MUST separate fact from assumption.

  Every claim the recommendation depends on is either verified (with a
  source, benchmark, or spike behind it) or explicitly labelled an
  assumption. Assumptions presented as facts are the most common way an RFC
  misleads its reviewers.

- You MUST NOT decide on the user's behalf.

  Recommend, with reasoning. The decision belongs to the people named in
  the RFC's approval gates, reached after the comment period.

- You SHOULD prefer the reversible option when the case is close.

  Where two options are near-equally weighted, the one that is cheaper to
  undo is usually correct — it buys information at lower cost. Say that
  this is the reasoning when you use it.

- You SHOULD keep the RFC as short as the decision allows.

  Reviewers ration attention. Length that does not carry argument spends
  that ration without buying scrutiny. Push supporting detail — benchmark
  runs, raw data, long diagrams — into linked artifacts alongside the RFC.

- You SHOULD name the stakeholders explicitly.

  An RFC without an audience does not get reviewed. Identify whose comment
  is actually needed, and whose approval gates the decision.

## Edge cases

- The decision is genuinely forced.

  If a regulation, contract, or hard platform constraint leaves only one
  viable option, state the constraint, name the option, and skip the
  alternatives. Verify the constraint is real first — "we have always done
  it this way" is convention, not constraint.

- The RFC is really several decisions.

  If the decision statement needs an "and", it is probably two RFCs.
  Bundled decisions are hard to accept or reject cleanly, because reviewers
  may agree with one half and not the other. Split them, and use the
  store's own mechanism for linking dependent records.

- The discussion has already happened.

  Where a decision was thrashed out in a thread or meeting, the RFC records
  and structures it rather than reopening it. Capture the alternatives that
  were actually raised and why they lost — the reasoning is the durable
  part, and it is usually the part nobody wrote down.

- The RFC drifts into implementation detail.

  An RFC settles *what* and *why*. Where the how starts to dominate, that
  material belongs in a design doc or delivery plan. Keep only the
  implementation detail that a reviewer needs in order to judge the
  decision.

## References

None.
