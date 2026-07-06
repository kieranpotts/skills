# Isolated environments

[Persisting state](./persistence.md) to a [shared repository](./version-control-substrate.md) solves handoff between sequential steps. But it creates a new problem when more than one agent or script needs to operate on that repository concurrently — whether that's parallel subagents building independent increments, or a human still working in the same checkout while an agent runs.

Two processes writing to the same working tree at the same time will corrupt each other's work. One process's uncommitted edits become visible, half-finished, to the other; checked-out branches conflict; build artifacts and lockfiles collide.

So, wherever a workflow runs multiple agents or scripts against a single code repository at once, each must be given its own isolated working copy to operate on, rather than sharing one.

For most local and agentic workflows, the right tool for this is a Git worktree — a second working directory checked out from the same repository, on its own branch, without the overhead of a full clone. This lets an orchestrator spin up one worktree per parallel agent, hand each agent its own isolated copy of the codebase, and only resolve the resulting branches back together at integration time.

This isn't always necessary. In CI systems, for example, isolation is typically already provided by the platform — each job clones the repository fresh into its own ephemeral environment, so there is no shared working tree to corrupt. Worktrees matter specifically where multiple processes would otherwise share one checkout — parallel agents on a developer's machine, or multiple long-running agent sessions against the same local repository.

Whether isolation is needed at all, and which mechanism provides it — a worktree, a fresh clone, a container — is a decision for the orchestrator, not for the skills themselves.

Persistence, version control, and isolation are not incidental tooling choices. Together, they compose the agentic workflow infrastructure.

So, while agentic steps should be loosely coupled from one another to support composability, each one is necessarily tightly coupled to this wider infrastructure.

This means a well-designed agentic workflow cannot just be dropped, unmodified, into any development environment. It assumes a structured development environment already in place around it.
