# Human-in-the-loop

Choosing where a workflow pauses for input is another key design decision in agentic workflows.

Interactive steps and human checkpoints should be inserted where decisions are genuinely the human's to make, or where the cost of an undetected error is unacceptably high.

If, in testing your agentic workflow, you fail to consistently achieve predictable outcomes, then you need more humans-in-the-loop.

How frequently humans need to enter the loop varies between domains and teams. High-integrity software — code with safety, financial, or regulatory consequences — will typically require a human checkpoint at every significant step. A personal project or a low-stakes website may need none at all, relying entirely on automated checks and agent judgment to reach a workable outcome.

There is no universal ratio of human checkpoints to automated and agentic steps. The right level of human involvement is a judgment call, tuned to the cost of failure in the domain you're working in, and revisited as your confidence in your pipeline's reliability grows or falls.
