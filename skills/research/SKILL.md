---
name: research
description: >-
  Gather external sources on a topic and produce a cited research report. Use
  when a decision is blocked on missing knowledge, or when the user says
  something like "research X", "look into X", "find out how X works", or "what
  are the options for X". Do not use it to make the decision the research
  informs, or to file the findings into their destination.
compatibility: >-
  requires Read, Write, Glob, Grep, WebSearch, WebFetch
license: CC0-1.0
---

# Research

Research a topic — a library, a protocol, a pattern, a regulation, or any
other prior art — by gathering external sources, analyzing them, and producing
a structured, cited research report.

Discovery and synthesis only. You MUST NOT change code or configuration, or
any documentation other than the research report itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A knowledge gap to close — REQUIRED.** A topic or question blocked on
  knowledge you do not hold and cannot derive from the codebase — how a
  library behaves, what a protocol mandates, how others solved a comparable
  problem, what a regulation requires, whether an approach is still current.

- **The decision the answer unblocks — RECOMMENDED.** What becomes possible
  once the question is answered. This sets the depth of the research and the
  point at which it stops. Where the user does not say, infer it from the
  surrounding context and state the inference in the report.

- **The project's own knowledge sources — REQUIRED.** Where the project keeps
  its convention files, documentation, decision records, and agent memory, so
  they can be checked before reaching outward. Discover these from the session
  context first, then from the environment. Do not assume a filesystem path or
  a document structure.

- **The report store — OPTIONAL.** Where the report is persisted. Resolve it
  from the last prompt, then from more recent context, then from the
  environment — a convention file, a workspace manifest, an existing
  directory of research notes. The store MAY be a directory in this
  repository, a separate repository, or an external service, so do not assume
  a path or a file format. Where nothing settles it, ask.

- **As-of date — OPTIONAL.** The date the findings are photographed at.
  Default to today.

## Success criteria

- One research report MUST exist in the resolved report store, following
  whatever structure and naming that store documents for itself. Where the
  store documents none, the report MUST follow the structure given under
  Examples.

- The report MUST open with a direct answer to the framed question, or with a
  statement of why no answer was reachable and what would settle it. A reader
  who stops after the opening MUST still have something actionable.

- Every claim the decision rests on MUST carry a source, and every claim that
  can go stale MUST carry the version or date it holds for, so a reader can
  judge whether it is still current.

- Sourced fact and your own inference MUST read as distinct categories
  throughout the report.

- Questions the research could not settle, including any deferred as
  out-of-scope, MUST be listed with what it would take to settle them.

- The report MUST be the only artifact produced. Code, configuration, and
  project documentation MUST be unchanged, and the findings MUST NOT have
  been written into a design document, a decision record, or a memory store.

## Instructions

1.  Frame the question.

    Restate the topic as one or more specific, answerable questions. A good
    frame is falsifiable and scoped: "Does library X support streaming
    responses, and from which version?" beats "research library X". Note what
    decision the answer unblocks — that decision sets the depth and the
    stopping point.

    Where the request is too broad to answer in one pass, narrow it to the
    questions that actually block progress and list the rest as deferred.

2.  Check what is already known.

    Search the project's own sources before reaching outward: the codebase,
    its documentation, its decision records, its convention files, and agent
    memory. Note what you found and what gap remains.

    Where the inward sources fully answer the question, skip the external
    search and report the finding against its in-repo source.

3.  Gather external sources for the remaining gap.

    Search the web, then retrieve the promising results in full rather than
    working from search snippets, which are frequently stale or truncated.

4.  Corroborate and date each claim that matters to the decision.

    Seek a second independent source for anything load-bearing, and record
    the version or date each claim holds for.

5.  Resolve the report store, then write the report there.

    Lead with a direct answer to the framed question, then the supporting
    evidence, then the open questions. The reader should get the actionable
    conclusion in the first few lines and drill into the evidence only if
    they need to.

6.  Mark which statements are sourced fact and which are your synthesis or
    recommendation.

    Where the evidence is thin, say so. An honest "the sources do not settle
    this" is more useful to the decision than false certainty.

7.  Name where the findings should go next — an input to a design decision, a
    decision record, a persisted memory entry, or simply the user's review —
    and stop there. Filing them is a separate step the caller initiates.

## Rules

- You SHOULD prefer primary sources over secondary, and recent over old.

  Prefer the specification over the blog post about it, and the current
  documentation over a three-year-old tutorial. Where you must rely on
  something older, you MUST flag its age, because the reader cannot otherwise
  tell a settled fact from a stale one.

- You MUST treat forums, blogs, and AI-generated content as leads to verify
  against a primary source, never as conclusions in themselves.

- You MUST surface disagreement between sources rather than launder it.

  Present the conflict and your read of which source is more credible and
  why. Silently collapsing it into one confident answer hides exactly the
  uncertainty the decision needs to account for.

- You MUST NOT fabricate a URL, or present a source as retrieved when you
  only saw it in a search result.

- You MUST NOT run an external search where the codebase or the project's own
  documentation already answers the question.

- You MUST stop once the framed questions are answered to the confidence the
  decision needs.

  Research expands to fill the time available. Continuing to read for
  completeness spends context on material the decision will not use.

- You MUST NOT act on the report.

  Editing code, configuration, or project documentation, and filing the
  findings into a design document or decision record, are separate steps the
  caller initiates. Suggest the destination; do not write to it.

## Edge cases

- Web access is unavailable or blocked.

  Answer as far as the project's own sources and your own knowledge allow,
  mark that portion's confidence as reduced and say why, and list what
  remains unverifiable. You MUST NOT invent citations to cover the gap.

- A source is paywalled, rate-limited, or otherwise unreachable.

  Note that it exists and could not be verified, and look for an open
  alternative — a preprint, a mirror, an official summary. Do not cite what
  you could not read.

- Sources agree with each other only because they share an origin.

  Several articles restating one upstream announcement are one source, not
  corroboration. Trace each back to its origin before counting it.

## Examples

- Where the report store documents no structure of its own, use this:

  ```md
  # Research: <topic>

  **Question:** <the question(s) framed in step 1>
  **Decision this unblocks:** <what becomes possible once answered>
  **As of:** <date>

  ## Answer

  <Direct, actionable answer in 1-3 sentences. The reader who stops here
  should still have what they need.>

  ## Findings

  - <Claim.> [source](url), accessed <date>. <Version/date it holds for.>
  - <Claim.> Corroborated by [source A](url) and [source B](url).
  - <Where sources disagreed, the disagreement and your read of it.>

  ## Open questions / low-confidence areas

  - <What the research could not settle, and what would settle it.>

  ## Suggested destination

  <Where these findings should go next.>

  ## Sources

  - [Title](url) - accessed <date> - <one line on what it covers>
  ```
