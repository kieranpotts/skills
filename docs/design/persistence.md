# Persistence

For an orchestrator to hand off a task — to a different agent, a different
session, or a deterministic script — the output of each step must be persisted
to disk, not merely held in conversation state.

An agent that finishes a "design" step and writes its decisions to a design doc
has produced something the next agent, in a fresh session with an empty context
window, can read and act on.

Persisting to disk also serves a second purpose. It keeps the context window
clean. Agentic workflows accumulate noise — exploratory dead ends, intermediate
reasoning, tool output that mattered for five minutes and then didn't. If every
step's full working state has to be carried forward in-context so the next step
can use it, context windows fill with noise, recall degrades, and costs climb.

Writing only the _distilled_ output of a step to disk — a spec, a design doc, a
plan, a set of review findings — lets the next step start from a clean slate.
