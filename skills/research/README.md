# Research

The **research** skill gathers external sources on a topic and produces a
cited research report.

The agent is instructed to frame the topic as specific, answerable questions,
check the project's own documentation and memory before reaching outward,
then search and retrieve authoritative external sources on whatever gap
remains. It writes up a report that leads with a direct answer, cites and
dates every claim the decision rests on, keeps sourced fact visibly separate
from its own inference, and lists what it could not settle.

Use this skill when a decision is blocked on missing knowledge — how a
library behaves, what a protocol mandates, what a regulation requires,
whether an approach is still current.

The skill is discovery and synthesis only. The agent produces a report and
stops. It does not change code, configuration, or project documentation, and
it does not file the findings into a design document or decision record —
it names where they should go and leaves that step to the caller.

## Interactivity

This skill instructs the agent to run non-interactively: it works from its
inputs and the workspace alone, and stops with an error rather than asking
the user to clarify the research question. It is therefore suitable for
away-from-keyboard and continuous integration workflows.

The one exception is locating artifacts. The agent may ask where the report
should be written, or how to reach a knowledge source, when the session
context and the environment do not settle it.

## How to invoke

> Research X.

> Look into X.

> Find out how X works.

> What are the options for X?

Name the decision the research unblocks, if you know it — the agent uses it
to set the depth of the research and the point at which it stops. Naming a
destination for the report, if the project has no convention for one, saves
the agent from having to ask.

## Recommended models

A frontier reasoning model with strong long-context handling. The task calls
for judging source quality, reconciling sources that disagree, and holding a
lot of retrieved material in context while synthesizing it — none of which a
small model does reliably.

## Related skills

- [**spike**](../spike/) \
  Answers a question with throwaway code, where external sources alone
  cannot settle it. Reach for a spike when the uncertainty is about how
  something behaves in this codebase rather than what the documentation says.

- [**design**](../design/) \
  Consumes research reports as evidence when weighing architectural
  trade-offs. Research supplies the facts; design makes the call.

- [**decide**](../decide/) \
  Records the decision a piece of research unblocks. Run research first, then
  hand its report to the decision record as supporting evidence.
