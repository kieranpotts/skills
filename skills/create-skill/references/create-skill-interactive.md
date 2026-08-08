# Interactive vs. non-interactive skills

Read this when deciding whether a skill should prompt the user mid-flow.

A skill is said to be **interactive** if it allows or instructs the agent to
block on user input — pausing to ask a question and waiting for the answer
before continuing. A skill is **non-interactive** if it explicitly tells the
agent to do its work from start-to-finish from its inputs and the workspace
alone, never stopping to get more input from the user.

Interactivity is desirable where human interaction is the core value in the
skill, for example a structured interview, or discovery of context that exists
only in the user's mind.

Non-interactivity is desirable where there may be valid use cases for running
agents unattended, for example in continuous integration systems.

State the mode plainly in prose, in two places:

- The `## Parameters` preamble, so the agent knows up front whether it may
  prompt the user when a parameter is uncertain.

- The README's `## Interactivity` section, so a human skimming the skill knows
  what to expect without needing to read the full `SKILL.md`.

## A non-interactive skill facing a confirmation requirement

A repository's own rules may require explicit user confirmation before some
action — promoting a maturity marker, deleting a file, closing an issue. A
non-interactive skill cannot satisfy that requirement by prompting; it has
already committed to running unattended.

The skill MUST NOT perform the action outright, and MUST NOT skip past the
confirmation requirement silently. Instead, it recommends the action and
surfaces the recommendation in its report, leaving the human to confirm by
reviewing and committing (or discarding) the uncommitted working tree. The
working tree change is proposed, not applied — the review gate the
confirmation requirement asked for still exists, just moved to happen after
the skill runs rather than mid-flow.

This differs from asking the user directly only in timing: an interactive
skill blocks and asks before acting; a non-interactive skill finishes its run
and asks by way of what it left for review.
