# Skill workflow diagrams

Read this when a collection's skills index — a manifest, a table in a
`README.md`, a navigation file — includes a Mermaid workflow diagram showing
skills as nodes. Not every collection keeps one; this only applies where one
exists.

The diagram marks each node with the skill's interactivity mode, which MUST
match, verbatim, what that skill's own `README.md` states in its
`## Interactivity` section:

- 🤖 — a non-interactive agentic step. The skill runs start-to-finish from
  its inputs and the workspace alone.

- 🤖🧑 — an interactive skill. The agent blocks on user input mid-flow.

- ⚙️ — a scripted, non-agentic automation step (a build, a test run, a
  deploy) that the diagram includes for context but that no skill in the
  collection implements.

A skill that changes its interactivity mode, or a new skill added to the
diagram, MUST carry the marker that matches its own README — never copied
from a neighboring node. This is what keeps the diagram from drifting out of
sync with the skills it depicts.

Reuse this `classDef` block verbatim, so every collection's diagram renders
consistently:

```text
classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

`anthropic` (the 🤖🧑 class) is the only one with a 1px stroke and a dashed
border — that's what visually sets a human checkpoint apart from a purely
automated or agentic one. Don't widen it to match the other two classes.

This collection's own [root README.md](../../../README.md) is the reference
example — two diagrams, one showing a fully agentic pipeline, one showing
where interactive skills sit upstream of it.
