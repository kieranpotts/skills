---
name: research
description: Research a topic the agent or project does not yet understand – a library, protocol, pattern, regulation, prior-art approach – by gathering current external sources, then produce a structured, cited research report. Discovery and synthesis only, no code or doc changes. Use when a decision is blocked on missing knowledge, when the user says "research X", "look into X", "find out how X works", or before a design decision when an option depends on facts the team does not yet hold.
license: CC0-1.0
metadata:
  interactive: no
---

# `/research`

Use this skill when progress is blocked on knowledge the agent does not currently hold and cannot derive from the codebase: how a third-party library actually behaves, what a protocol mandates, how others have solved a comparable problem, what a regulation requires, whether an approach is still current. The job is to look *outward*, gather authoritative sources, and synthesize them into a report someone can act on.

Research looks *outward*: it pulls knowledge inward from external sources, rather than distilling lessons from the current session. It does not write production code or project docs – it produces an input that other work consumes.

The output is a single research report. Where it lands (a design doc, an ADR input, a memory entry, a message back to the user) is the *caller's* decision, stated when the skill is invoked or chosen by the user afterward. This skill does not edit shipped skills, project documentation, or code.

Do NOT use this skill to:

- Write or change code – that is implementation work, a separate responsibility.
- Answer a design question by *building* something. Use `/research` when the answer exists in the world already; when it has to be discovered by experiment, that is a separate, build-and-measure responsibility.
- Capture session lessons – that is distilling knowledge inward from the session, a separate responsibility.
- Elicit requirements from a human – that is requirements discovery, a separate responsibility.

**Input**: A topic or question blocked on knowledge the agent does not hold and cannot derive from the codebase – how a library behaves, what a protocol mandates, how others solved a comparable problem, what a regulation requires, whether an approach is still current. REQUIRED.

**Output**: A single, cited research report – a direct answer to the framed question, the supporting evidence (each decision-bearing claim sourced and, where time-sensitive, dated), the open questions, and a suggested destination for the findings. This skill produces the report and stops; writing the findings into a design doc, an ADR, persisted memory, or anywhere else is a separate, explicit step the caller initiates.

## Instructions

1.  **Frame the question.**

    Restate the topic as one or more specific, answerable questions. A good frame is falsifiable and scoped: *"Does library X support streaming responses, and from which version?"* beats *"research library X"*. Note explicitly what decision the answer unblocks – that decision sets the depth and stopping point.

    If the request is too broad to answer in one pass, narrow it to the questions that actually block progress and say which you are deferring.

2.  **Check what is already known first.**

    Before reaching outward, check inward sources that may already hold the answer: the codebase, `docs/`, existing ADRs, committed convention files (`AGENTS.md` / `CLAUDE.md`), and agent memory. Do not spend a web search on something the repo already records. Note what you found and what gap remains.

3.  **Gather external sources.**

    Use web search and fetch (`WebSearch` / `WebFetch` or the host's equivalent) to collect authoritative sources for the remaining gap. Prefer, in order:

    - Primary sources: official docs, specifications, RFCs, source code, changelogs.
    - Maintainer-authored material: design notes, issue threads, release announcements.
    - Reputable secondary sources: well-regarded articles, conference talks, books.

    Treat forums, blogs, and AI-generated content as leads to verify against a primary source, not as conclusions. Capture the URL and the access date for everything you rely on.

4.  **Corroborate and date every claim.**

    A claim that matters to the decision needs at least two independent sources, or one primary source. Version- and time-sensitive facts (API shapes, pricing, limits, "best practice") MUST carry the version or date they were true as of – knowledge goes stale, and a dated claim lets a future reader judge whether it still holds.

    When sources disagree, say so explicitly rather than silently picking one.

5.  **Synthesize into a structured report.**

    Write the report (format below). Lead with a direct answer to the framed question, then the supporting evidence, then the open questions. The reader should get the actionable conclusion in the first few lines and be able to drill into the evidence only if they need to.

6.  **Separate fact from inference.**

    Mark clearly which statements are sourced fact and which are your synthesis or recommendation. Never present an inference as if a source asserted it. If the evidence is thin, say the confidence is low – an honest "the sources don't settle this" is more useful than false certainty.

7.  **State where the report should go – but do not put it there.**

    End by naming the natural destination(s) for the findings (an input to a design decision, an ADR, a persisted memory entry, or simply the user's review) and stop. Writing into those destinations is a separate, explicit step the caller initiates.

## Rules

-   **Cite everything that matters.**

    Every claim the decision rests on carries a source URL and an access date. An uncited claim in a research report is just an opinion.

-   **Primary sources beat secondary; recent beats old.**

    Prefer the spec over the blog post about the spec. Prefer the current docs over a three-year-old tutorial. When you must rely on something older, flag its age.

-   **Date version- and time-sensitive facts.**

    "As of version 4.2" or "as of 2026-06" attached to a claim is mandatory whenever the fact can change. The world moves; the report should say when it was photographed.

-   **Distinguish fact from inference.**

    Sourced facts and your own synthesis are different categories and must read as different categories. Recommendations are clearly labeled as yours, not the sources'.

-   **Surface disagreement; do not launder it.**

    When sources conflict, present the conflict and your read of which is more credible and why. Do not silently collapse it into a single confident answer.

-   **Discovery only – no production changes.**

    This skill never edits code, project docs, or shipped skills. It produces a report. Acting on the report is a separate, explicit step.

-   **Stop when the framed question is answered.**

    Research expands to fill the time available. When the questions from step 1 are answered to the confidence the decision needs, stop – do not keep reading for completeness.

## Report format

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

## Edge cases

-   **No web access available.**

    Some hosts expose no search/fetch tool. Say so plainly, answer as far as the inward sources (step 2) and the model's own knowledge allow, and mark that portion's confidence as reduced and its facts as undated-by-source. Do not fabricate URLs or pretend to have browsed.

-   **The question turns out to be answerable from the codebase alone.**

    If step 2 fully answers it, stop there – report the finding with its in-repo source and skip the external search. An unnecessary web search is wasted budget.

-   **The topic is too broad to research in one pass.**

    Narrow to the decision-blocking questions, answer those, and list the rest as deferred. A focused answer to the real question beats a shallow survey of everything.

-   **Sources are paywalled or unreachable.**

    Note the source exists but could not be accessed, and do not represent its contents as verified. Find an open alternative where one exists.

-   **The honest answer is "it depends" or "unknown".**

    Report that. A research skill that always returns a confident answer is not researching – it is rationalising. Name the dependency or the gap.

## Success criteria

-   **The framed question is answered, or its unanswerability is explained.**

    The report opens with a direct answer, or with a clear statement of why no answer was reachable and what would be needed.

-   **Every decision-bearing claim is cited and, where time-sensitive, dated.**

    A reader can follow each material claim to a source and judge whether it is still current.

-   **Fact and inference are visibly separated.**

    Nothing you inferred is presented as something a source asserted.

-   **The report is actionable from its first few lines.**

    The conclusion leads; the evidence supports. The reader is not made to assemble the answer themselves.

-   **No production artifact was changed.**

    Code, project docs, and shipped skills are untouched; the output is a report plus a suggested destination.
