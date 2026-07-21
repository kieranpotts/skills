# Agentic versus automated

An agentic workflow consists of a mix of both agentic and automated steps.
[Humans enter the loop](./human-in-the-loop.md) where steps cannot be reliably
handled by some combination of agents and automation.

We should be clear about the definitions of "automated" versus "agentic".

**Automated** tasks are deterministic. They involve computation using the
traditional, instructions-based programming model. Given a set of inputs, the
outputs are entirely predictable.

**Agentic** work, by contrast, involves applying judgment, making decisions,
learning and adapting, and coming up with novel ideas. Agents have _agency_.
Give an agent the same set of inputs in different sessions, and you'll get
different outputs every time.

Choosing which steps to automate, and which to hand off to agents, is a key
design decision in agentic workflows.

Agents should not be used where regular computation will suffice. Use agents
only for tasks that demand the capabilities of large language models: open-ended
problems that require judgment to weigh up trade-offs, experimentation to try
different paths forward, and reflection to evaluate one's own progress toward
solving the problem.

An agentic step, encoded in a skill file, is worth adding wherever judgment
can't be reduced to a deterministic rule.

Linting, building, packaging, deploying, migrating… these steps in the software
development lifecycle are best left scripted. This is why you won't find "build"
or "deploy" skills in this collection. Those steps do not belong here.

Agent skills are for the parts of the software development lifecycle that
resist automation by conventional tools.
