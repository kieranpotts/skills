# Single responsibility

To achieve composable agentic workflows, in which individual steps may have multiple trigger conditions and be sequenced differently across multiple pipelines, each agent skill should define a single, discrete step and instruct the agent to stop at a well-defined boundary. Similarly, each deterministic script should be narrow in scope and not reach into adjacent concerns.

For maximum composability, no one agent skill should do both _evaluation_ and _implementation_. A skill either analyzes and reports its findings, or it enacts a change — but never both. For example, a skill that proofreads a document does not also commit the changes it makes to the document. The decision of whether, when, and how to commit the changes from the proofreading step belongs to the orchestrator.

Keeping these two concerns — evaluation and implementation — apart brings numerous benefits, besides avoiding the sycophancy that models exhibit when asked to review their own work. Orchestrators have the option to review findings from evaluation steps before applying changes. Having a single responsibility gives each skill a clear trigger condition, too. And each skill becomes more useful on its own. For example, you could reuse an evaluator skill to report into a CI gate.

A single responsibility is a question of scope, not just of boundary. A skill should be sized the same way we would scope a well-designed function or a Unix tool — small, focused, and free of overlapping responsibility with its neighbors. Each skill should also be pitched at the level of abstraction that an agent (like a human) would naturally reason about the task.

Small, focused skills, which are executed by independent agent sessions within a larger pipeline, also help to manage the context length. A single session asked to specify, design, plan, and implement a large feature end-to-end will eventually be reasoning over a context dominated by its own accumulated exploration rather than the task at hand. Decompose these individual individual steps, each starting with a fresh context, will help to improve the reliability of your agents' reasoning.
