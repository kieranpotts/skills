# Commit

The **`commit`** skill commits pending changes to Git as a single commit,
following the conventions defined in [TS-9: Version Control][TS-9].

The agent commits the staged changes, or everything (including untracked files)
in the working tree if nothing is yet staged. It writes the commit message from
the changeset, read alongside the session's conversation and the repository's
recent history, in the format `<type>: <description>[ - <flag>]`. The message
describes only what the commit contains.

The skill works in any Git repository. The agent stops, rather than commit, if
`HEAD` is detached, if a merge, rebase, cherry-pick, or revert is in progress,
or if the checked-out branch is a `test`, `ready`, or `release` trunk. Where
the project installs the [`validate-commit-message`][hooks] hook, the hook
enforces the message format.

## Interactivity

This skill instructs the agent to run non-interactively. The agent is told not
to prompt the user for answers to anything it is not sure about. Instead, if
the agent cannot complete its task from the initial single-shot prompt, it is
instructed to stop and report. This makes the skill useful in away-from-keyboard
workflows and automated delivery pipelines.

Invoking the skill counts as permission to commit. The commit stays local
until you push it, so you can still review it with `git show` and undo it with
`git reset HEAD~1`.

## How to invoke

> Commit this.

> Commit the staged changes.

> Commit this — it's temporary debug logging.

## Outcomes

The target repository has one new commit on the checked-out branch. Nothing is
pushed.

The agent's report opens with the new commit's short hash on the first line, so
an orchestrator can read it. This is followed by the commit's subject and the
files it touched.

## Recommended models

A small, fast model is sufficient. The work is a constrained transformation
against a fixed vocabulary, not open-ended reasoning.

## Suggested workflows

```mermaid
flowchart LR
  %% Node labels and classes.
  code["🤖<br/>code"]:::agentic
  commit["🤖<br/>commit"]:::agentic
  chronicle["🤖<br/>chronicle"]:::agentic

  %% Main workflow sequence.
  code ==> commit
  commit ==> chronicle

  %% Class definitions.
  classDef agentic fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef scripted fill:#e2e3e5,stroke:#4b5157,color:#383d41,stroke-width:2px
  classDef anthropic fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## Related skills

- [**`chronicle`**](../chronicle/) \
  Summarizes the headline changes in the commits since the last release.

## References

- [TS-9: Version Control][TS-9] \
  The technical standard this skill encodes.

- [Validate commit messages action](https://github.com/kieranpotts/actions/tree/dev/validate-commit-messages) \
  The GitHub action that validates commit messages against these conventions.

- [Pre-commit hooks][hooks] \
  Validate commit messages against the same conventions, locally.

[TS-9]: https://kieranpotts.com/standards/009
[hooks]: https://github.com/kieranpotts/pre-commit-hooks
