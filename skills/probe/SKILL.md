---
name: probe
description: >-
  Facilitate an interactive threat modeling workshop over a system or design,
  then record the security and privacy risks it surfaces in the project's risk
  store. Use when the user says something like "probe the security of…",
  "run a threat model on…", "do a STRIDE session on…", "what are the
  security risks of this design?", or "assess the privacy risks here". Do not
  use it to fix findings, to change the assessed system, or to exploit it.
compatibility: >-
  requires Read, Write, Edit, Glob, Grep, WebFetch
license: CC0-1.0
---

# Probe

Facilitate a structured threat modeling workshop: decompose the system into
components, data flows, trust boundaries, and assets, assess each against a
named framework, and rate every threat by likelihood and impact to yield a
severity. Capture the outcome in a session report, and promote the threats
worth tracking into the project's living risk register. Analysis only — you
MUST NOT change the assessed system, and you MUST NOT exploit it.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. This skill is interactive: the workshop is itself a
conversation, so you SHOULD prompt the user whenever a parameter, a fact about
the system, or a rating is uncertain — one question at a time.

- **What to assess — REQUIRED.** A subsystem, service, data flow, feature, or
  design. The user MAY point at a codebase, a design document, or a diagram,
  or simply describe it in the session. This MAY be vague at the start; the
  decomposition sharpens it.

- **Where the risk store lives, and how to write to it — REQUIRED.** Discover
  this rather than assuming it: check this session's context first, then the
  environment (a convention file, a workspace manifest, a directory that
  plainly holds risk records, a configured connector). If neither settles it,
  ask the user. The store MAY be a directory in this repository, a separate
  repository, or an external service such as a GRC platform or issue tracker,
  so do not assume a filesystem path, a file name, or a document structure.

- **Threat modeling framework — OPTIONAL.** The lens to assess through. Ask
  the user; where they express no preference, default to STRIDE, adding
  LINDDUN when personal data is in scope.

## Success criteria

- The risk store's location and access method MUST trace to session context,
  to the environment, or to an answer from the user — never to an assumed
  path.

- Exactly one dated, scoped session report MUST exist in the store, written
  where and how that store places reports, using the store's own template
  where it has one and the bundled fallback where it does not. It MUST cite
  the exact system context assessed — components, data flows, and the
  revision under assessment where applicable — so that it stands as a
  reproducible point-in-time snapshot.

- The report MUST cover business context, technical scope, system
  decomposition, the threat assessment, the risks raised, mitigation
  strategies, and follow-ups.

- Every row in the report's threat assessment MUST carry a framework
  category, a likelihood, an impact, and a derived severity, with none left
  blank.

- Every risk raised MUST appear in the store's living register, with a unique
  reference continuing the register's existing numbering, a mitigation or an
  explicit accept decision, a residual risk, and a review date, mapped onto
  whatever fields that register defines. The report's list of risks raised and
  the new register entries MUST agree.

- The assessed system MUST be unchanged: no edits to its code, configuration,
  or dependencies, and no probing traffic sent to it.

- Nothing MUST have been committed or published. Where the store is
  version-controlled, the new report and the modified register MUST be left
  uncommitted — never staged, branched, or committed. Where the store is an
  external service, the entries MUST be left in whatever draft state that
  service offers, or reported for the user to file.

## Instructions

Facilitate the session as a structured workshop. You MUST ask one question at
a time and wait for each answer before asking the next, letting each answer
shape the question that follows. Take notes continuously — you are building
the report as you go.

1.  Locate the risk store and confirm the seed.

    You MUST establish where this project records security and privacy risk,
    and how to write to it, before the assessment starts. Work outward: what
    the session context already tells you, then the environment — a convention
    file at the project root, a workspace manifest, a directory that plainly
    holds risk records, a configured connector. If none of that settles it,
    ask the user.

    Then read whatever that store publishes about itself — its convention
    file, its contributor documentation, its report template, its existing
    register — so that you follow its conventions and continue its reference
    numbering.

    Restate what is to be assessed, in one sentence: "We're threat modeling
    [subsystem / flow] — is that the scope you mean?" Clarify before
    proceeding.

2.  Establish the business context.

    Ask, one at a time:

    - "Why does this system exist? What business value does it provide?"
    - "What are the critical business functions here?"
    - "What is the business impact of a security or privacy failure —
      financial, reputational, regulatory, operational?"

    Capture this as the report's business context. It anchors severity later,
    because a threat's impact is measured against what the business stands to
    lose.

3.  Fix the technical scope.

    Ask, one at a time:

    - "What exactly is in scope — which components, services, and data
      flows?"
    - "What is deliberately out of scope, so we can judge the coverage?"
    - "What's the technology stack, and what are the deployment
      environments?"
    - "Can we pin this to a specific revision — `owner/repo@<commit>`?"

    You SHOULD push for the out-of-scope boundary. It matters as much as the
    in-scope list, because it is what tells a later reader what this report
    does not speak to.

4.  Decompose the system.

    Walk the system with the user, asking about each of these in turn:

    - Key components — for each: its role, its trust level (trusted,
      semi-trusted, untrusted), and the data it handles.

    - Data flows — source, destination, data type, protocol, authentication.

    - Sensitive assets — sensitivity, integrity and availability
      requirements, privacy concerns.

    - Entry points — the external interfaces, APIs, and user interfaces.

    - Trust boundaries — where trust changes (internet to DMZ, DMZ to
      internal, unauthenticated to authenticated, tenant to tenant).

    Where a data-flow or architecture diagram exists, you SHOULD ask for it
    and reference it. This step is load-bearing: you cannot assess threats
    against a system you have not decomposed.

5.  Agree the framework.

    Ask: "Which lens do we assess through — STRIDE for general security,
    LINDDUN for privacy, the OWASP Top 10, or a combination?" Whatever is
    chosen, every threat MUST be classified under a named category from it.

6.  Sweep for common weaknesses.

    Framework categories are abstract. Ground them by sweeping the system for
    these concrete, recurring weakness patterns, mapping each to its framework
    category as you go. At every trust boundary, ask first: "What does each
    side trust the other to have already checked?" — an implicit trust across
    a boundary is where most of these hide.

    - Injection points (tampering, elevation). User-controlled input reaching
      a query, command, template, or interpreter without a parameterized API
      or an escaping boundary between them.

    - Broken authentication or authorization boundaries (spoofing,
      elevation). An action or resource reachable without the check its
      sibling endpoints enforce. Authorization decided client-side, or
      inferred from data the caller controls.

    - Unsafe secrets handling (information disclosure). Credentials, keys, or
      tokens in source, logs, error messages, or client-visible responses.
      Long-lived secrets where short-lived ones would do.

    - Insecure defaults (multiple). A configuration, flag, or dependency that
      ships permissive, verbose, or unauthenticated unless explicitly
      hardened.

    - Missing validation at trust boundaries (tampering, information
      disclosure). Input trusted past the point where it first crosses from
      an untrusted actor, rather than checked at the boundary itself.

    - Unsafe dependency or supply-chain patterns (tampering, elevation).
      Unpinned versions, unverified sources, or install-time script execution
      for third-party code that runs with production privileges.

    This sweep complements the framework walk in the next step. It catches the
    concrete weaknesses that an abstract category walk can skate over. A
    finding from either route becomes a threat to assess and rate.

7.  Assess threats, one target at a time.

    Walk the trust boundaries, data flows, and sensitive assets from step 4.
    For each, apply the agreed framework's categories and ask:

    - "At this boundary, flow, or asset, is [category] a credible threat? How
      would it play out?"
    - "What existing countermeasures already reduce it?"

    You MAY walk each category across the whole system, or take each critical
    component and check it against the full category list, one table per
    component. Follow whichever layout the store's template favors.

    Record every credible threat as a row: a reference continuing the store's
    numbering, the component or flow, a description, the category, and the
    countermeasures already in place. You SHOULD NOT rate them yet — surface
    them all first, so that ratings are set against the full picture.

8.  Rate each threat.

    For every threat surfaced, ask, or reason through with the user:

    - "How likely is this — probable, likely, possible, unlikely, or rare?"

    - "If it happened, how bad — catastrophic, critical, severe, marginal, or
      negligible?"

    Combine likelihood and impact into a severity using the store's own
    scoring scheme wherever it documents one. Where it documents none, use
    critical, high, medium, low, and say in the report that you supplied the
    scale. You MUST apply whichever scheme consistently, rather than eyeball
    severities independently of likelihood and impact.

9.  Decide which threats become tracked risks.

    Ask, for the higher-severity threats: "Is this worth tracking over time in
    the register, or is it noted and closed here?"

    A threat SHOULD be promoted when it carries residual exposure that must be
    watched, mitigated, or periodically re-reviewed. A threat that is fully
    countered already, or too trivial to track, stays in the report's
    assessment only. Record the promoted ones under risks raised.

10. Agree a mitigation strategy per risk raised.

    For each risk promoted to the register, ask: "What's the response —
    mitigate (how?), or a reasoned decision to accept it?" Then ask for the
    residual risk after that mitigation.

    You MUST capture enough rationale that a future reader understands why
    this response was chosen. Detailed remediation steps belong in the
    relevant code repository's issue tracker, so capture a link where one
    exists rather than the worked-out fix.

11. Write the session report.

    Confirm with the user that the assessment is complete.

    You MUST first check whether a report has already been scaffolded for this
    scope — a blank or placeholder-filled report matching this assessment, on
    the current branch or in the store. Where one exists, write into it.
    Creating a second report alongside a scaffolded one splits the record and
    leaves an empty artifact behind.

    Otherwise, write the report where and how the store expects it, following
    its own template, naming, and placement conventions. Where it documents
    none, match the structure of the reports already in it. Where the store is
    empty and offers no template, use the bundled fallback template and say
    in the report that you did.

12. Update the living register.

    For each risk raised, add an entry to the store's register, using whatever
    fields it actually defines. You MUST continue its existing reference
    numbering, neither restarting it nor colliding with existing references.
    Record the status, the likelihood, impact, and severity, the mitigation,
    the residual risk, and the review date, mapped onto the fields the
    register provides. Keep it ordered however the store orders it.

    Then report both artifacts — where the report was written, and which
    register entries were added — and stop.

## Rules

- You MUST NOT batch questions.

  A workshop is a conversation. Batching erases the chance for one answer to
  reshape the next, and loses the participant.

- Discovery and record-keeping only — you MUST NOT change code.

  You MUST NOT modify, patch, or fix the assessed system, and threat
  identification MUST NOT extend to actively exploiting it. Reason about how a
  threat would play out; do not carry it out. This skill's deliverables are
  the report and the register entries, nothing more.

- You MUST NOT commit, branch, file issues, or open pull requests.

  Branching, committing, reviewing, and indexing belong to the store's own
  documented workflow, or to a human. Writing the artifacts is where this
  skill stops. The user decides what happens to the outcome next.

- You MUST discover the store's location and conventions, and MUST NOT assume
  them.

  This skill is used across projects that record risk in different places and
  formats — a directory of Markdown, a separate repository, a GRC platform, an
  issue tracker. A path, file name, field set, or rating scale that is right
  in one project is wrong in the next. Where no store can be established even
  after asking, you MUST stop and alert the user: there is nowhere valid to
  record the outcome.

- The register MUST be the living source of truth for where each risk stands.

  A threat MAY appear in the report's assessment without being promoted. The
  report is a point-in-time snapshot; the register is what someone consults
  months later to see where a risk got to.

- The register MUST NOT become a dump of every threat considered.

  Over-filling it erodes its value as a live view of real risk.

- You MUST distinguish an existing control from a proposed one.

  A countermeasure already implemented reduces likelihood today; a proposed
  mitigation does not. Do not credit the system for controls that are not yet
  built, because that understates severity. Record proposed mitigations under
  the risk, not in the current-countermeasures column.

- You MUST push back, and MUST NOT be a "yes" machine.

  Interrogate optimistic likelihood estimates and downplayed impacts. Surface
  threats the participant has not thought of. Flag when a claimed control does
  not actually cover the boundary it is meant to. No sycophancy.

- You MUST take notes continuously.

  Capture the decomposition, threats, ratings, and decisions as the session
  runs. You are assembling the report live; do not rely on reconstructing it
  from memory at the end.

- The tone MUST be rigorous: direct, no padding, and showing the reasoning
  behind a severity rather than just the verdict.

## Edge cases

- The user cannot answer the business-context or scope questions, because
  they are working from a codebase or design document alone.

  Derive what you can by reading the sources in scope, then state each
  derivation back as an assumption for the user to confirm or correct, and
  record the confirmed assumptions in the report. An assumption recorded is
  auditable later; an assumption made silently is not.

- The store documents no scoring scheme, no report template, and holds no
  prior reports to imitate.

  Use the bundled fallback template and the critical, high, medium, low
  severity scale, and say in the report which conventions you supplied. The
  next session then has something to match, rather than diverging again.

## Assets

- [Threat report template](./assets/probe/threat-report.template.md) \
  A fallback report template, used at step 11 only when the target store
  provides no template of its own.

## References

- [TS-54: Threat Modeling](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/054/AGENTS.md) \
  One documented instance of the method this skill follows — the workshop
  procedure, the decomposition model, the STRIDE and LINDDUN frameworks, and
  a rating scheme. Read it when the target store documents no method of its
  own. Where the store does document one, the store wins.
