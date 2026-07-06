# Version control as the substrate

Version control specifically — not just "a disk," but a system with commits, branches, and history — is the right substrate for the [persistence](./persistence.md) of agent outputs, because the whole ecosystem then runs on one consistent mechanism.

Everything an agentic workflow produces — not just the code, but the requirements, decisions, designs, and plans too — should be kept under version control.

This has numerous benefits:

- Code, requirements, decisions, designs, and plans are all branched, committed, reviewed, and merged using the same version control workflow. There are no separate methods and tools for "the spec" and "the code," for example.

- Everything stays together. Related artifacts are not scattered across different systems — wikis, trackers, a shared filesystem, and so on.

- Audit trails and undo operations are built-in. Because every agent-generated artifact is kept under version control, you get auditability and rollback for free.

- Easy integration with existing automation. For example, continuous integration systems can apply deterministic verification to agent output.
