---
name: probe
description: >-
  Run a structured, interactive threat modeling session to identify the
  security and privacy risks a system carries. The agent facilitates the
  workshop, helping to decompose the system into components, data flows, trust
  boundaries, and assets, then assessing each against a named threat modeling
  framework (eg. STRIDE, LINDDUN, OWASP) and rating every threat by likelihood
  and impact, which are combined into an overall severity score. The answers
  are captured in a workshop report, and the project's risk register is updated
  in response to the report's findings. This is discover and record-keeping only
  — no code changes, and no active exploitation of the system. Use this skill
  when the user says "probe the security of...", "run a threat model on…",
  "what are the security risks of this design?", "do a STRIDE session on…",
  or "assess the privacy risks here".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/security-analysis
---

# Probe

Run an interactive threat modeling session.

**Input:**

- **What to assess. REQUIRED.** A subsystem, service, data flow, feature, or
  design. The user MAY point at a codebase, a design doc, a diagram, or simply
  describe it in the session. This can be vague at the start — the session
  sharpens it through decomposition.

- **Where to write the outcome. REQUIRED.** The project's risk register — a
  concrete implementation of [TS-54: Threat
  Modeling](https://github.com/kieranpotts/standards/tree/dev/src/054). Check the
  `AGENTS.md` file in the current working directory for the path or URL of the
  risk register (it is typically a separate repository, see
  [`risks`](https://github.com/kieranpotts/risks)). If not found, check whether
  the current working directory has a `risks/` subdirectory containing a
  `REGISTER.md`. If the register cannot be located, stop and alert the user.

This skill is interactive: the agent facilitates the session, asking one
question at a time, gathering the rest of its input from the user through the
conversation.

**Output:** Two artifacts, written to the risk register store, following the
conventions defined there:

1. **An immutable session report** at `risks/YYYY-MM-DD-<slug>/` (or wherever the
   store's conventions place it), built from the store's `TEMPLATE.md` — business
   context, technical scope, system decomposition, the threat assessment table,
   the risks raised, mitigation strategies, and follow-ups.

2. **New rows in the living `REGISTER.md`** for the threats worth tracking over
   time, using that register's columns (Ref, Risk, Type, Details, Probability,
   Impact, Severity, Mitigation, Status, Residual risk, Reviewed).

The session report is a point-in-time snapshot. The register is the living
source of truth for where each risk stands. A threat may appear in the report's
assessment but NOT be promoted to the register — only risks worth tracking over
time are.

## Instructions

You MUST facilitate the session as a structured workshop, following the TS-54
method. You MUST ask one question at a time and wait for each answer before
asking the next. You SHOULD let each answer shape the question that follows. You
MUST take notes continuously — you are building the report as you go.

1.  **Locate the register and confirm the seed.**

    You MUST find the risk register store first (see **Input**), and read its
    `AGENTS.md` or `README.md`, its `TEMPLATE.md`, and its `REGISTER.md` so you
    follow local conventions and know the existing Ref numbering. If the register
    cannot be found, you MUST stop and tell the user — there is nowhere to record
    the outcome.

    You MUST restate what is to be assessed, in one sentence: *"We're
    threat-modeling <subsystem / flow> — is that the scope you mean?"* You MUST
    clarify before proceeding.

2.  **Establish the business context.**

    You MUST ask, one at a time:

    - *"Why does this system exist? What business value does it provide?"*
    - *"What are the critical business functions here?"*
    - *"What is the business impact of a security or privacy failure — financial,
      reputational, regulatory, operational?"*

    You MUST capture this as the report's *Business context*. This anchors
    severity later: a threat's impact is measured against what the business
    stands to lose.

3.  **Fix the technical scope.**

    You MUST ask, one at a time:

    - *"What exactly is in scope — which components, services, and data flows?"*
    - *"What is deliberately out of scope, so we can judge the coverage?"*
    - *"What's the technology stack, and what are the deployment environments?"*
    - *"Can we pin this to a specific revision — `owner/repo@<commit>`?"*

    An explicit out-of-scope boundary matters as much as the in-scope list. You
    MUST push for it.

4.  **Decompose the system.**

    You MUST walk the system with the user, building the decomposition tables the
    template calls for. You MUST ask about each in turn:

    - **Key components** — for each: its role, its trust level (Trusted /
      Semi-trusted / Untrusted), and the data it handles.
    - **Data flows** — source, destination, data type, protocol, authentication.
    - **Sensitive assets** — sensitivity, integrity and availability
      requirements, privacy concerns.
    - **Entry points** — the external interfaces, APIs, and user interfaces.
    - **Trust boundaries** — where trust changes (internet → DMZ, DMZ →
      internal, unauthenticated → authenticated, tenant → tenant).

    If a data-flow or architecture diagram exists, you MUST ask for it and
    reference it. You cannot assess threats against a system you have not
    decomposed — this step is the foundation for everything after.

5.  **Choose the framework(s).**

    You MUST ask: *"Which lens do we assess through — STRIDE for general security,
    LINDDUN for privacy, the OWASP Top 10, or a combination?"*

    STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial of
    service, Elevation of privilege) is the RECOMMENDED default. You SHOULD add
    LINDDUN when personal data is in scope. Whatever is chosen, every threat MUST
    be classified under a named category from it.

6.  **Sweep for common weaknesses.**

    The framework categories are abstract. You MUST ground them by sweeping the
    system for these concrete, recurring weakness patterns, mapping each to its
    framework category as you go. At every trust boundary, you MUST ask first:
    *"What does each side trust the other to have already checked?"* — an implicit
    trust across a boundary is where most of these hide.

    - **Injection points** (Tampering / Elevation). User-controlled input
      reaching a query, command, template, or interpreter without a parameterized
      API or an escaping boundary between them.

    - **Broken authentication or authorization boundaries** (Spoofing /
      Elevation). An action or resource reachable without the check its sibling
      endpoints enforce. Authorization decided client-side, or inferred from data
      the caller controls.

    - **Unsafe secrets handling** (Information disclosure). Credentials, keys, or
      tokens in source, logs, error messages, or client-visible responses.
      Long-lived secrets where short-lived ones would do.

    - **Insecure defaults** (multiple). A configuration, flag, or dependency that
      ships permissive, verbose, or unauthenticated unless explicitly hardened.

    - **Missing validation at trust boundaries** (Tampering / Information
      disclosure). Input trusted past the point where it first crosses from an
      untrusted actor, rather than checked at the boundary itself.

    - **Unsafe dependency or supply-chain patterns** (Tampering / Elevation).
      Unpinned versions, unverified sources, or install-time script execution for
      third-party code that runs with production privileges.

    This sweep complements the framework walk in the next step — it catches the
    concrete weaknesses that an abstract category walk can skate over. A finding
    from either route becomes a threat to assess and rate.

7.  **Assess threats, one target at a time.**

    You MUST walk the trust boundaries, data flows, and sensitive assets from
    step 4. For each, you MUST apply the chosen framework's categories and ask:

    - *"At this boundary/flow/asset, is <category> a credible threat? How would
      it play out?"*
    - *"What existing countermeasures already reduce it?"*

    For the STRIDE approach, you MAY either walk each category across the system,
    or take each critical component and check it against the full STRIDE list (one
    table per component) — TS-54 §4 describes both layouts; you SHOULD follow
    whichever the template favors.

    You MUST record every credible threat as a row: a `Ref` (eg. `TA1`, continuing
    the register's numbering), the component/flow, a description, the type, and the
    countermeasures already in place. You MUST NOT rate them yet — surface them
    first.

8.  **Rate each threat.**

    For every threat surfaced, you MUST ask (or reason with the user):

    - *"How likely is this — Probable, Likely, Possible, Unlikely, or Rare?"*
    - *"If it happened, how bad — Catastrophic, Critical, Severe, Marginal, or
      Negligible?"*

    You MUST combine likelihood × impact into a **Severity** (Critical / High /
    Medium / Low) using the store's scoring scheme (see its `docs/risk-rating.md`).
    You MUST apply the scheme consistently — do not eyeball severities
    independently of likelihood and impact.

9.  **Decide which threats become tracked risks.**

    You MUST ask, for the higher-severity threats: *"Is this worth tracking over
    time in the register, or is it noted-and-closed here?"*

    A threat goes into the register when it carries residual exposure that must
    be watched, mitigated, or periodically re-reviewed. A threat that is fully
    countered already, or too trivial to track, stays in the report's assessment
    only. You MUST record the promoted ones under *Risks raised*.

10. **Agree a mitigation strategy per risk raised.**

    For each risk promoted to the register, you MUST ask: *"What's the response —
    mitigate (how?), or a reasoned decision to accept it?"*

    You MUST capture enough rationale that a future reader understands *why* this
    response was chosen. You MUST then ask for the **residual risk** after that
    mitigation (Critical / High / Medium / Low). Detailed remediation steps belong
    in the relevant code repository's issue tracker — you SHOULD capture a link if
    one exists, not the worked-out fix.

11. **Write the session report.**

    You MUST confirm with the user that the assessment is complete, then fill out
    the store's `TEMPLATE.md` into a new dated report directory
    (`risks/YYYY-MM-DD-<slug>/`, using today's date and a short kebab-case slug of
    the scope). You MUST populate the Summary, Business context, Technical scope,
    Decomposition tables, Threat assessment table, Risks raised, Mitigation
    strategies, and Follow-ups from your notes.

    You MUST follow the store's own conventions (its `AGENTS.md`, `README.md`, and
    any local skills). If none can be found, you SHOULD match the structure of
    existing session reports in the store.

12. **Update the living register.**

    For each risk under *Risks raised*, you MUST append a row to the store's
    `REGISTER.md`, using its exact columns. You MUST continue the register's
    existing Ref numbering — do NOT restart or collide with existing refs. You MUST
    set Status to *Pending* (or the agreed target date), and fill Probability,
    Impact, Severity, Mitigation, and Residual risk from the session. You MUST set
    Reviewed to today's date. You MUST keep the register sorted by severity per its
    own instructions.

    You MUST report both artifacts — the new report path and the register rows
    added — as this skill's output, and stop.

## Rules

-   **You MUST ask one question at a time.**

    You MUST NOT batch questions. A workshop is a conversation; batching erases
    the chance for one answer to reshape the next, and loses the participant.

-   **Discovery and record-keeping only — you MUST NOT change code.**

    You MUST NOT modify, patch, or "fix" the assessed system. Threat
    identification MUST NOT include actively exploiting the system — reason about
    how a threat *would* play out; do not carry it out. This skill's deliverables
    are the report and the register rows, nothing more.

-   **You MUST NOT commit, branch, file issues, or open pull requests.**

    Your output is the two artifacts written to disk. The risk register store's
    own workflow — a human, or its companion skills (eg. `draft-session`,
    `land-session`, `update-register`) — owns branching, committing, and
    indexing. Writing the files is where this skill MUST stop. The user SHALL
    decide what to do with the outcome next.

-   **Every threat MUST be classified and rated.**

    Every credible threat MUST carry a named framework category (STRIDE /
    LINDDUN / OWASP / …) AND a likelihood, impact, and derived severity, using a
    consistent scoring scheme. An unrated threat is not assessable and MUST NOT
    survive into the report.

-   **You MUST distinguish an existing control from a proposed one.**

    A countermeasure already implemented reduces likelihood today; a proposed
    mitigation does not. Do not credit the system for controls that are not yet
    built — that understates severity. Record proposed mitigations under the risk,
    not the current countermeasures column.

-   **You MUST push back.**

    You MUST NOT be a "yes" machine. Interrogate optimistic likelihood estimates
    and downplayed impacts. Surface threats the participant has not thought of.
    Flag when a claimed control does not actually cover the boundary it is meant
    to. No sycophancy.

-   **Only track what is worth tracking.**

    The register is not a dump of every threat considered. A threat is promoted
    only when it carries residual exposure worth watching over time. Over-filling
    the register erodes its value as a live view of real risk.

-   **You MUST take notes continuously.**

    Capture the decomposition, threats, ratings, and decisions as the session
    runs. You are assembling the report live; do not rely on reconstructing it
    from memory at the end.

-   **The tone MUST be rigorous.**

    Direct. No fluff. No padding. Show the reasoning behind a severity, not just
    the verdict.

## Success criteria

-   **The register store MUST have been located before the session starts.**

    If no `REGISTER.md` / risk store can be found, the skill MUST have stopped and
    alerted the user — there is nowhere valid to record the outcome.

-   **A dated, scoped session report MUST exist on disk.**

    A new `risks/YYYY-MM-DD-<slug>/` report MUST be present, built from the
    store's template, citing the exact system context assessed (components, data
    flows, and `repo@commit` where applicable) so it is a reproducible
    point-in-time snapshot.

-   **Every threat in the report MUST be classified and rated.**

    Each row in the threat assessment MUST carry a framework category, a
    likelihood, an impact, and a derived severity. None may be blank.

-   **Every risk raised MUST appear as a register row.**

    Each threat listed under *Risks raised* MUST have a corresponding row in
    `REGISTER.md`, with a unique Ref continuing the existing numbering, a
    mitigation (or explicit accept decision), a residual risk, and a Reviewed
    date. The report's *Risks raised* list and the new register rows MUST agree.

-   **The register MUST remain a valid living document.**

    New rows MUST use the register's exact columns and MUST NOT duplicate or
    collide with existing Refs. The register MUST stay sorted per its own
    conventions.

-   **Nothing MUST be committed.**

    `git status` in the register store MUST show the new report and the modified
    `REGISTER.md` as uncommitted — never staged, branched, or committed by this
    skill. The assessed codebase MUST be left unchanged — `git diff` over it MUST
    be empty.

## References

- [TS-54: Threat Modeling](https://github.com/kieranpotts/standards/tree/dev/src/054):
  The underlying standard — the workshop method, the decomposition model, the
  STRIDE/LINDDUN frameworks, the rating scheme, and the register fields.

- [`risks`](https://github.com/kieranpotts/risks): The reference implementation
  of the risk register store this skill writes into — its `TEMPLATE.md`,
  `REGISTER.md`, and conventions.

- [`assets/probe/threat-report.template.md`](./assets/probe/threat-report.template.md): A
  fallback threat-report template, used only when the target store provides no
  `TEMPLATE.md` of its own.
