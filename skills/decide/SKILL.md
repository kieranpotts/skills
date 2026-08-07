---
name: decide
description: >-
  Frame a technical decision, weigh its genuine alternatives, and write it up
  as an RFC that invites informed disagreement before the decision is settled.
  Use when a decision about architecture, process, technology, or tooling
  needs stakeholder review, or when the user says something like "write an RFC
  for this", "draft an RFC proposing X", "we need to decide whether to adopt
  Y", or "help me make the case for this change". Do not use it to move an
  existing record through its lifecycle, nor to implement a decision already
  taken.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, WebFetch, WebSearch
license: CC0-1.0
---

# Decide

Frame a technical decision, work through its genuine alternatives, and write
it up as an RFC — a document whose purpose is to be argued with *before* the
decision is settled. Author the record's content only: moving it through
whatever lifecycle the decision store defines belongs to that store's own
workflow.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification.

- **A decision that needs making — REQUIRED.** Supplied as the user's
  description, an issue, a discussion thread, or an upstream design document.
  The initial input MAY be partial or absent, because you gather the rest —
  motivation, constraints, candidate options, stakeholders — by prompting the
  user during the session.

- **The decision store — REQUIRED.** Where decision records live and how to
  write to them. Discover this rather than assuming it: check this session's
  context first, then the environment (a convention file, a workspace
  manifest, a configured connector), then ask the user. The store MAY be a
  directory in this repository, a separate repository, or an external service
  such as a wiki, so do not assume a filesystem path, a file name, or a
  document structure. Projects variously call this an RFC archive, a decision
  log, an ADR directory, or a set of key design decisions; they are the same
  role.

- **The record's state on entry — OPTIONAL.** Whichever state the store uses
  for a proposal still open to comment. Where the decision has already been
  taken and only needs recording, use the store's state for a settled
  decision instead.

## Success criteria

- A decision record MUST exist in the resolved store, stating the decision,
  its motivation, the alternatives, the trade-offs, a recommendation, and the
  conditions under which that recommendation would change.

- The decision statement MUST be a single sentence specific enough that a
  reviewer could reasonably argue the opposite, paired with an explicit
  out-of-scope list.

- At least two alternatives plus the do-nothing option MUST each be evaluated
  with their costs and risks stated — including the costs and risks of the
  recommended option.

- Every load-bearing claim MUST be marked verified or assumed, and each
  unverified one MUST also appear in the open questions.

- The record MUST fill every section the store's template defines, leaving no
  boilerplate behind. Where the store publishes no template, the minimum
  section set MUST be covered and your report MUST name the shape used.

- No lifecycle action MUST have been taken and no application code changed:
  no branch cut, no pull request opened, no label applied, no merge.

## Instructions

1.  Write the decision statement. Use one sentence naming exactly what is
    being decided, then list what is explicitly *out* of scope.

    Test it: could a reasonable colleague disagree with that sentence? A
    statement too vague to disagree with ("improve our tooling") is not yet a
    decision — sharpen it until it is ("adopt pnpm as the package manager for
    all TypeScript services").

2.  Check the decision warrants a record. A record earns its cost when the
    decision is expensive to reverse, crosses team or service boundaries, or
    sets a precedent others will follow.

    Where it is cheap to reverse and touches one module, you SHOULD say so
    and stop, rather than generating ceremony.

    Where the decision is already settled and only needs recording, still
    write it here — same store, same shape, entered at the store's state for
    a decision already taken. Note that it was written retrospectively, so a
    reader knows whether the alternatives were weighed before or after.

3.  Establish the motivation. State the problem, who suffers from it, and why
    it needs addressing now. Quantify wherever possible — incident counts,
    build minutes, onboarding days, error rates.

    "The current approach is bad" is not motivation. Include the cost of
    doing nothing; where that cost is low, the RFC may not be justified.

4.  Describe the current state honestly: how the affected architecture,
    process, technology, or tooling works today, and where specifically it
    falls short. Omit this for a greenfield choice with no incumbent.

    Resist the urge to make the status quo look worse than it is. Reviewers
    who know the system will spot it, and it costs you the argument.

5.  Separate what is known from what is assumed. List the facts the decision
    turns on and mark each as verified or assumed.

    Where the decision depends on external facts — library maturity,
    licensing, benchmark numbers, API capability — you SHOULD establish them
    from primary sources. Where no source settles a claim, carry it into the
    open questions as an assumption to be tested; you MUST NOT build the
    recommendation on an unverified assumption presented as fact.

6.  Enumerate genuine alternatives: at least two real options, plus doing
    nothing. Where a separate trade-off analysis already exists, bring its
    conclusions here rather than reproducing the working.

7.  Weigh the trade-offs. For each option, state what it costs, what it
    risks, and who carries the burden — including the operational tail:
    monitoring, migration, on-call, dependency upkeep.

    State the downsides of your preferred option explicitly. An RFC with no
    stated downsides reads as advocacy and gets discounted accordingly.

8.  Assess the impact. Rate the blast radius (`HIGH`, `MEDIUM`, `LOW`) and
    name who and what is affected — the architecture, the development or
    operations process, the contributors, the service level agreement. Note
    effects on cross-cutting concerns: security, performance, availability,
    the technology stack.

    For a decision with a security dimension, name the threats the choice
    introduces or mitigates.

9.  Recommend one option, and say what would change your mind. Name the
    recommendation and the reasoning: which factors dominate, and which you
    accept as weaker.

    Then state the conditions under which a different option wins ("if
    sustained throughput exceeds 2,000/sec, option 3 becomes correct"). This
    is what turns a fait accompli into a genuine request for comments, and it
    gives reviewers something concrete to push against.

10. Surface the open questions: what remains unresolved, and what is
    deliberately deferred to a separate decision. Do not paper over unknowns
    — an RFC that hides them gets ambushed in review, and the ambush costs
    more than the admission would have.

11. Write it up against the target store's own template. Resolve the store as
    described under Parameters, read whatever it publishes about itself — its
    template, convention file, or contributor documentation — and fill out
    the sections it actually defines, including any metadata header and any
    categorization it expects.

    Where the store has no template, cover at minimum: summary, motivation,
    impact, current state, proposed state, alternatives, trade-offs and
    risks, open questions, and references. Where the store is not empty but
    undocumented, match the shape of the records already in it.

    Write the proposed state in the present tense, describing the system as
    it would be. Lead with the summary and keep it skimmable. Where a diagram
    carries the argument better than prose, embed one.

12. Self-review against the rules and success criteria, report the record,
    and stop.

## Rules

- You MUST make the RFC contestable.

  The document exists to gather comments. A proposal that offers reviewers no
  purchase — no stated downsides, no alternatives taken seriously, no
  conditions that would change the recommendation — collects agreement rather
  than scrutiny, which is how bad decisions get ratified.

- You MUST discover the decision store's location and conventions, and MUST
  NOT assume them.

  This skill runs across projects that record decisions in different places
  and formats. A path, file name, template, or section structure that is
  right in one project is wrong in the next. Resolve the store first, then
  follow whatever conventions it documents for itself.

- You MUST NOT present a strawman alternative.

  Listing options nobody would choose, purely to make the preferred one look
  inevitable, is worse than listing no alternatives at all. It signals the
  decision was made before the RFC was written.

- You MUST write the record and stop there.

  Cutting a branch, opening a pull request, applying a label, and merging
  belong to the store's own workflow, which owns how a decision travels from
  proposed to accepted.

- You MUST NOT decide on the user's behalf.

  Recommend, with reasoning. The decision belongs to the people named in the
  record's approval gates, reached after the comment period.

- You SHOULD prefer the reversible option when the case is close.

  Where two options are near-equally weighted, the one that is cheaper to
  undo is usually correct — it buys information at lower cost. Say that this
  is the reasoning when you use it.

- You SHOULD keep the record as short as the decision allows.

  Reviewers ration attention. Length that does not carry argument spends that
  ration without buying scrutiny. Push supporting detail — benchmark runs,
  raw data, long diagrams — into linked artifacts alongside the record.

- You SHOULD name the stakeholders explicitly.

  A proposal without an audience does not get reviewed. Identify whose
  comment is actually needed, and whose approval gates the decision.

## Edge cases

- The decision is genuinely forced.

  Where a regulation, contract, or hard platform constraint leaves only one
  viable option, state the constraint, name the option, and skip the
  alternatives. Verify the constraint is real first — "we have always done it
  this way" is convention, not constraint.

- The record is really several decisions.

  Where the decision statement needs an "and", it is probably two records.
  Bundled decisions are hard to accept or reject cleanly, because reviewers
  may agree with one half and not the other. Split them, and use the store's
  own mechanism for linking dependent records.

- The discussion has already happened.

  Where a decision was thrashed out in a thread or meeting, record and
  structure it rather than reopening it. Capture the alternatives that were
  actually raised and why they lost — the reasoning is the durable part, and
  it is usually the part nobody wrote down.

- The record drifts into implementation detail.

  A proposal settles *what* and *why*. Where the how starts to dominate, that
  material belongs in a design document or delivery plan. Keep only the
  implementation detail a reviewer needs in order to judge the decision.
