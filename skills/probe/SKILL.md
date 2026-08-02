---
name: probe
description: >-
  Run an interactive threat-modeling session. Record security risks. Use this
  when the user says something like "probe the security of...", "run a threat
  model on…", "what are the security risks of this design?", "do a STRIDE
  session on…", or "assess the privacy risks here".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/SECURITY_DEEP
---

# Probe

Run a structured, interactive threat modeling session to identify security and
privacy risks that are inherent with a system's design and domain. You will
facilitate the workshop. You will help to decompose the system into components,
data flows, trust boundaries, and assets. Then you will assess each against a
named threat modeling framework — eg. STRIDE, LINDDUN, and/or OWASP — rating
every threat by likelihood and impact, and then combining those scores into an
overall severity score, via which threats can be ranked from high to low.

Capture the outcomes in a workshop report, and update the project's risk
register in response to new or evolved findings in the report.

Analysis only. You MUST NOT make any code or configuration changes to the
software itself, and you MUST NOT actively exploit the system — static
analysis only.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the input requirements,
prompt the user for clarification.

- **What to assess — REQUIRED.** A subsystem, service, data flow, feature,
  or design. The user MAY point at a codebase, a design doc, a diagram, or
  simply describe it in the session. This can be vague at the start — the
  session sharpens it through decomposition.

- **Where the risk store lives, and how to write to it — REQUIRED.**
  Discover this rather than assuming it: check this session's context first,
  then the environment (a convention file such as `AGENTS.md`, a workspace
  manifest, a configured connector). If neither settles it, ask the user.
  The store MAY be a directory in this repository, a separate repository, or
  an external service such as a GRC platform or issue tracker — do not
  assume a filesystem path, a file name, or a document structure.

This skill is interactive. The agent facilitates a structured workshop,
asking one question at a time and waiting for each answer before asking the
  next.

## Success criteria

You will achieve the following outcomes:

- The risk store MUST have been discovered before the session starts: its
  location and access method MUST trace to session context, to the
  environment, or to an answer from the user, never to an assumed path.

- Exactly one dated, scoped session report MUST exist in the store, written
  where and how that store places reports, using the store's own report
  template where it has one and the bundled fallback where it does not. It
  MUST cite the exact system context assessed — components, data flows, and
  the revision under assessment where applicable — so it stands as a
  reproducible point-in-time snapshot.

- The report MUST cover business context, technical scope, system
  decomposition, the threat assessment, the risks raised, mitigation
  strategies, and follow-ups.

- Every threat in the report MUST be classified and rated: each row in the
  threat assessment MUST carry a framework category, a likelihood, an
  impact, and a derived severity, and none may be blank.

- Every risk raised MUST appear in the store's living register, with a
  unique reference continuing the existing numbering, a mitigation (or an
  explicit accept decision), a residual risk, and a review date, mapped onto
  whatever fields that register defines. The report's Risks raised list and
  the new register entries MUST agree.

- The register MUST remain a valid living document: new entries MUST use
  the register's own fields, MUST NOT duplicate or collide with existing
  references, and MUST leave it ordered per its own conventions.

- Nothing MUST have been committed or published. Where the store is
  version-controlled, the new report and the modified register MUST be
  left uncommitted — never staged, branched, or committed. Where the store
  is an external service, the entries MUST be left in whatever draft or
  unpublished state that service offers, or reported for the user to file.
  The assessed codebase MUST be left unchanged.

## Instructions

Facilitate the session as a structured workshop, following the TS-54 method.
Ask one question at a time and wait for each answer before asking the next.
Let each answer shape the question that follows. Take notes continuously —
you are building the report as you go.

1.  Locate the risk store and confirm the seed.

    Establish where this project records security and privacy risk, and how
    to write to it. Work outward: what the session context already tells
    you, then the environment — a convention file at the project root, a
    workspace manifest, a directory that plainly holds risk records, a
    configured connector. If none of that settles it, ask the user.

    Then read whatever that store publishes about itself — its convention
    file, its contributor documentation, its report template, its existing
    register — so you follow its conventions and continue its existing
    reference numbering. If no store can be established even after asking,
    stop and tell the user: there is nowhere to record the outcome.

    Restate what is to be assessed, in one sentence: "We're
    threat-modeling <subsystem / flow> — is that the scope you mean?"
    Clarify before proceeding.

2.  Establish the business context.

    Ask, one at a time:

    - "Why does this system exist? What business value does it provide?"
    - "What are the critical business functions here?"
    - "What is the business impact of a security or privacy failure —
      financial, reputational, regulatory, operational?"

    Capture this as the report's Business context. This anchors severity
    later: a threat's impact is measured against what the business stands to
    lose.

3.  Fix the technical scope.

    Ask, one at a time:

    - "What exactly is in-scope — which components, services, and data
      flows?"
    - "What is deliberately out-of-scope, so we can judge the coverage?"
    - "What's the technology stack, and what are the deployment
      environments?"
    - "Can we pin this to a specific revision — `owner/repo@<commit>`?"

    An explicit out-of-scope boundary matters as much as the in-scope list.
    Push for it.

4.  Decompose the system.

    Walk the system with the user, building the decomposition tables the
    template calls for. Ask about each in turn:

    - Key components — for each: its role, its trust level (Trusted /
      Semi-trusted / Untrusted), and the data it handles.

    - Data flows — source, destination, data type, protocol,
      authentication.

    - Sensitive assets — sensitivity, integrity and availability
      requirements, privacy concerns.

    - Entry points — the external interfaces, APIs, and user interfaces.

    - Trust boundaries — where trust changes (internet → DMZ, DMZ →
      internal, unauthenticated → authenticated, tenant → tenant).

    If a data-flow or architecture diagram exists, ask for it and
    reference it. You cannot assess threats against a system you have not
    decomposed — this step is the foundation for everything after.

5.  Choose the framework(s).

    Ask: "Which lens do we assess through — STRIDE for general security,
    LINDDUN for privacy, the OWASP Top 10, or a combination?"

    STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial
    of service, Elevation of privilege) is the recommended default. Add
    LINDDUN when personal data is in-scope. Whatever is chosen, every threat
    is classified under a named category from it.

6.  Sweep for common weaknesses.

    The framework categories are abstract. Ground them by sweeping the
    system for these concrete, recurring weakness patterns, mapping each to
    its framework category as you go. At every trust boundary, ask first:
    "What does each side trust the other to have already checked?" — an
    implicit trust across a boundary is where most of these hide.

    - Injection points (Tampering / Elevation). User-controlled input
      reaching a query, command, template, or interpreter without a
      parameterized API or an escaping boundary between them.

    - Broken authentication or authorization boundaries (Spoofing /
      Elevation). An action or resource reachable without the check its
      sibling endpoints enforce. Authorization decided client-side, or
      inferred from data the caller controls.

    - Unsafe secrets handling (Information disclosure). Credentials, keys,
      or tokens in source, logs, error messages, or client-visible
      responses. Long-lived secrets where short-lived ones would do.

    - Insecure defaults (multiple). A configuration, flag, or dependency
      that ships permissive, verbose, or unauthenticated unless explicitly
      hardened.

    - Missing validation at trust boundaries (Tampering / Information
      disclosure). Input trusted past the point where it first crosses from
      an untrusted actor, rather than checked at the boundary itself.

    - Unsafe dependency or supply-chain patterns (Tampering / Elevation).
      Unpinned versions, unverified sources, or install-time script
      execution for third-party code that runs with production privileges.

    This sweep complements the framework walk in the next step — it
    catches the concrete weaknesses that an abstract category walk can
    skate over. A finding from either route becomes a threat to assess and
    rate.

7.  Assess threats, one target at a time.

    Walk the trust boundaries, data flows, and sensitive assets from step 4.
    For each, apply the chosen framework's categories and ask:

    - "At this boundary/flow/asset, is <category> a credible threat? How
      would it play out?"
    - "What existing countermeasures already reduce it?"

    For the STRIDE approach, either walk each category across the system,
    or take each critical component and check it against the full STRIDE
    list (one table per component) — TS-54 §4 describes both layouts; follow
    whichever the template favors.

    Record every credible threat as a row: a `Ref` (eg. `TA1`,
    continuing the register's numbering), the component/flow, a
    description, the type, and the countermeasures already in place. Do not
    rate them yet — surface them first.

8.  Rate each threat.

    For every threat surfaced, ask (or reason with the user):

    - "How likely is this — Probable, Likely, Possible, Unlikely, or
      Rare?"

    - "If it happened, how bad — Catastrophic, Critical, Severe,
      Marginal, or Negligible?"

    Combine likelihood × impact into a severity using the store's own
    scoring scheme, wherever it documents one. Where it documents none, use
    Critical / High / Medium / Low and say in the report that you supplied
    the scale. Apply whichever scheme consistently — do not eyeball
    severities independently of likelihood and impact.

9.  Decide which threats become tracked risks.

    Ask, for the higher-severity threats: "Is this worth tracking over time
    in the register, or is it noted-and-closed here?"

    A threat goes into the register when it carries residual exposure that
    must be watched, mitigated, or periodically re-reviewed. A threat that
    is fully countered already, or too trivial to track, stays in the
    report's assessment only. Record the promoted ones under Risks raised.

10. Agree a mitigation strategy per risk raised.

    For each risk promoted to the register, ask: "What's the response —
    mitigate (how?), or a reasoned decision to accept it?"

    Capture enough rationale that a future reader understands why this
    response was chosen. Then ask for the residual risk after that
    mitigation (Critical / High / Medium / Low). Detailed remediation steps
    belong in the relevant code repository's issue tracker — capture a link
    if one exists, not the worked-out fix.

11. Write the session report.

    Confirm with the user that the assessment is complete.

    First check whether a report has already been scaffolded for this scope —
    a blank or placeholder-filled report matching this assessment, on the
    current branch or in the store. If one exists, write into it. Creating a
    second report alongside a scaffolded one splits the record and leaves an
    empty artifact behind.

    Otherwise, write the report where and how the store expects it — its own
    template, its own naming and placement convention. Populate the summary, business context,
    technical scope, decomposition, threat assessment, risks raised,
    mitigation strategies, and follow-ups from your notes.

    Follow the store's own conventions wherever it documents them. Where it
    documents none, match the structure of the reports already in it. Where
    the store is empty and offers no template, use the bundled fallback
    template and say that you did.

12. Update the living register.

    For each risk raised, add an entry to the store's register, using
    whatever fields it actually defines. Continue its existing reference
    numbering — do not restart or collide with existing references. Record
    the status, the likelihood, impact, and severity, the mitigation, the
    residual risk, and the review date, mapped onto the fields the register
    provides. Keep it ordered however the store orders it.

    Report both artifacts — where the report was written and which register
    entries were added — as this skill's output, and stop.

## Rules

- You MUST ask one question at a time.

  You MUST NOT batch questions. A workshop is a conversation; batching
  erases the chance for one answer to reshape the next, and loses the
  participant.

- Discovery and record-keeping only — you MUST NOT change code.

  You MUST NOT modify, patch, or "fix" the assessed system. Threat
  identification MUST NOT include actively exploiting the system — reason
  about how a threat would play out; do not carry it out. This skill's
  deliverables are the report and the register rows, nothing more.

- You MUST NOT commit, branch, file issues, or open pull requests.

  Your output is the two artifacts, written where the store keeps them.
  Branching, committing, reviewing, and indexing belong to the store's own
  workflow — whatever procedure it documents, or a human. Writing the
  artifacts is where this skill MUST stop. The user SHALL decide what to do
  with the outcome next.

- You MUST discover the store's location and conventions; you MUST NOT
  assume them.

  This skill is used across projects that record risk in different places
  and formats — a directory of Markdown, a separate repository, a GRC
  platform, an issue tracker. A path, file name, field set, or rating scale
  that is right in one project is wrong in the next. Resolve the store
  first, then read and follow whatever conventions it documents for itself.
  Where no store can be established even after asking, you MUST stop and
  alert the user: there is nowhere valid to record the outcome.

- You MUST adopt an existing scaffolded report rather than create a second
  one.

  A store's own workflow may scaffold a blank report and open it for review
  before the assessment runs. Where such a scaffold exists for this scope,
  write the findings into it — two artifacts for one assessment is a split
  record.

- The register MUST be the living source of truth for where each risk
  stands.

  A threat may appear in the report's assessment without being promoted to
  the register. The report is a point-in-time snapshot; the register is what
  someone consults months later to see where a risk got to.

- Every threat MUST be classified and rated.

  Every credible threat MUST carry a named framework category (STRIDE /
  LINDDUN / OWASP / …) AND a likelihood, impact, and derived severity,
  using a consistent scoring scheme. An unrated threat is not assessable
  and MUST NOT survive into the report.

- You MUST distinguish an existing control from a proposed one.

  A countermeasure already implemented reduces likelihood today; a
  proposed mitigation does not. Do not credit the system for controls that
  are not yet built — that understates severity. Record proposed
  mitigations under the risk, not the current countermeasures column.

- You MUST push back.

  You MUST NOT be a "yes" machine. Interrogate optimistic likelihood
  estimates and downplayed impacts. Surface threats the participant has
  not thought of. Flag when a claimed control does not actually cover the
  boundary it is meant to. No sycophancy.

- You SHOULD only track what is worth tracking.

  The register MUST NOT be a dump of every threat considered. A threat
  SHOULD be promoted only when it carries residual exposure worth watching
  over time. Over-filling the register erodes its value as a live view of
  real risk.

- You MUST take notes continuously.

  Capture the decomposition, threats, ratings, and decisions as the
  session runs. You are assembling the report live; do not rely on
  reconstructing it from memory at the end.

- The tone MUST be rigorous.

  Direct. No fluff. No padding. Show the reasoning behind a severity, not
  just the verdict.

## References

- [TS-54: Threat Modeling](https://github.com/kieranpotts/standards/tree/latest/dev/src/054):
  One documented instance of the method this skill follows — the workshop
  procedure, the decomposition model, the STRIDE/LINDDUN frameworks, and a
  rating scheme. Read it when the target store documents no method of its
  own. Where the store does document one, the store wins.

- [`assets/probe/threat-report.template.md`](./assets/probe/threat-report.template.md):
  A fallback threat-report template, used only when the target store
  provides no template of its own.
