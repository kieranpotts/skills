---
name: research
description: >-
  Research a topic. Use when a decision is blocked on missing knowledge, or when
  the user says something like "research X", "look into X", or "find out how X
  works".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-writer
---

# Research

Research a given topic. The topic could be anything: a library, a protocol, a
pattern, a regulation, or any other prior art. Gather external reference
resources, analyze those resources, then produce a structured, cited research
report.

Discovery and synthesis only. Do NOT make any changes to any code or
configuration, or to any documentation beyond the research report itself.

**Input:**

- **A knowledge gap to close. REQUIRED.** A topic or question blocked on
  knowledge the agent does not hold and cannot derive from the codebase — how a
  library behaves, what a protocol mandates, how others solved a comparable
  problem, what a regulation requires, whether an approach is still current.

You MUST complete this task non-interactively. You MUST NOT block for user input
after this initial prompt. You MUST follow the instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

**Output:**

A single, cited research report — a direct answer to the framed
question, the supporting evidence (each decision-bearing claim sourced and,
where time-sensitive, dated), the open questions, and a suggested destination
for the findings. This skill produces the report and stops; writing the findings
into a design doc, an ADR, persisted memory, or anywhere else is a separate,
explicit step the caller initiates.

## Instructions

1.  **Frame the question.**

    You MUST restate the topic as one or more specific, answerable questions. A
    good frame is falsifiable and scoped: *"Does library X support streaming
    responses, and from which version?"* beats *"research library X"*. You MUST
    note explicitly what decision the answer unblocks — that decision sets the
    depth and stopping point.

    If the request is too broad to answer in one pass, you MUST narrow it to the
    questions that actually block progress and list the rest as deferred.

2.  **Check what is already known first.**

    Before reaching outward, you MUST check inward sources that may already hold
    the answer: the codebase, `docs/`, existing ADRs, committed convention files
    (`AGENTS.md` / `CLAUDE.md`), and agent memory. You MUST note what you found
    and what gap remains, as required by the Rules.

    If the question is fully answerable from inward sources, you MUST skip the
    external search and report the finding with its in-repo source.

3.  **Gather external sources.**

    You SHOULD use web search and fetch (`WebSearch` / `WebFetch` or the host's
    equivalent) to collect authoritative sources for the remaining gap,
    following the source-preference and citation Rules.

4.  **Corroborate and date every claim.**

    You MUST apply the corroboration and dating Rules to each claim that matters
    to the decision.

5.  **Synthesize into a structured report.**

    You MUST write the report using the structure defined in the Success
    criteria. You MUST lead with a direct answer to the framed question, then the
    supporting evidence, then the open questions. The reader should get the
    actionable conclusion in the first few lines and be able to drill into the
    evidence only if they need to.

6.  **Separate fact from inference.**

    You MUST mark clearly which statements are sourced fact and which are your
    synthesis or recommendation. You MUST NOT present an inference as if a source
    asserted it. If the evidence is thin, you MUST say the confidence is low — an
    honest "the sources don't settle this" is more useful than false certainty.

7.  **State where the report should go — but do not put it there.**

    You MUST end by naming the natural destination(s) for the findings (an input
    to a design decision, an ADR, a persisted memory entry, or simply the user's
    review) and stop. Writing into those destinations is a separate, explicit
    step the caller initiates.

## Rules

- **You MUST cite everything that matters.**

  Every claim the decision rests on MUST carry a source URL and an access date.
  An uncited claim in a research report is just an opinion.

- **You SHOULD prefer primary sources over secondary, and recent over old.**

  Prefer the spec over the blog post about the spec. Prefer the current docs
  over a three-year-old tutorial. When you must rely on something older, you
  MUST flag its age.

- **You MUST treat forums, blogs, and AI-generated content as leads to verify
  against a primary source, not as conclusions.**

- **You MUST date version- and time-sensitive facts.**

  "As of version 4.2" or "as of 2026-06" attached to a claim is REQUIRED
  whenever the fact can change. The world moves; the report should say when it
  was photographed.

- **You MUST distinguish fact from inference.**

  Sourced facts and your own synthesis are different categories and MUST read
  as different categories. Recommendations MUST be clearly labeled as yours,
  not the sources'.

- **You MUST surface disagreement, not launder it.**

  When sources conflict, present the conflict and your read of which is more
  credible and why. You MUST NOT silently collapse it into a single confident
  answer.

- **Discovery only: you MUST NOT make production changes.**

  This skill MUST NOT edit code, project docs, or shipped skills. It produces a
  report. Acting on the report is a separate, explicit step.

- **You MUST stop when the framed question is answered.**

  Research expands to fill the time available. When the questions from step 1
  are answered to the confidence the decision needs, you MUST stop — you MUST
  NOT keep reading for completeness.

- **You MUST NOT fabricate URLs or pretend to have browsed when web access is
  unavailable.**

- **You MUST NOT perform an unnecessary external search if the codebase or
  existing project docs already answer the question.**

- **If web access is unavailable, you MUST answer as far as the inward sources
  and the model's own knowledge allow, mark that portion's confidence as
  reduced, and you MUST NOT fabricate URLs or pretend to have browsed.**

- **If sources are paywalled or unreachable, you MUST note that they exist but
  could not be verified, and find an open alternative where one exists.**

## Success criteria

- **The framed question MUST be answered, or its unanswerability explained.**

  The report opens with a direct answer, or with a clear statement of why no
  answer was reachable and what would be needed.

- **Every decision-bearing claim MUST be cited; time-sensitive claims MUST be
  dated.**

  A reader can follow each material claim to a source and judge whether it is
  still current.

- **Fact and inference MUST be visibly separated.**

  Nothing you inferred is presented as something a source asserted.

- **The report MUST be actionable from its first few lines.**

  The conclusion leads; the evidence supports. The reader is not made to
  assemble the answer themselves.

- **The research report MUST be the only artifact produced.**

  Code, project docs, and shipped skills are untouched. The output is a report
  plus a suggested destination.

- **The report MUST follow this structure:**

  ```md
  # Research: <topic>

  **Question:** <the specific question(s) framed in step 1>
  **Decision this unblocks:** <what becomes possible once answered>
  **As of:** <date>

  ## Answer

  <Direct, actionable answer in 1-3 sentences. The reader who stops
  here should still have what they need.>

  ## Findings

  - <Claim.> [source](url), accessed <date>. <Version/date the claim holds for.>
  - <Claim.> Corroborated by [source A](url) and [source B](url).
  - <Where sources disagreed, the disagreement and your read of it.>

  ## Open questions / low-confidence areas

  - <What the research could not settle, and what it would take to settle it.>

  ## Suggested destination

  <Where these findings should go next: design input, ADR, memory, user review.>

  ## Sources

  - [Title](url) - accessed <date> - <one-line note on what it covers>
  ```

- **Deferred questions, if any, MUST be listed.**
