---
name: skill-name
description: >-
  One sentence describing what the skill does. Use when <specific triggers —
  user phrasings, situations, file types, contexts>. Optional third sentence
  naming any situation in which the skill must not be used.
compatibility: requires <tool> or <tool>, and <tool>
license: <license>
---

# [Skill name]

One or two sentences, adapted from the description, saying what the skill
does.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification.

<!-- For a non-interactive skill, use this preamble instead:

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the user
with an error message. -->

- **The first parameter — REQUIRED.** Describe it, and how to discover it
  from the surrounding context and environment if the user does not supply it
  explicitly.

- **The second parameter — OPTIONAL.** Describe it, and its default when
  absent.

- **Output — REQUIRED for non-interactive skills.**
  If an agent is expected to run non-interactively, it MUST be given clear
  guidelines on where and how it will persist its outputs. The agent should
  be instructed to discover this, first from the last prompt, then from more
  recent context, and finally from the environment — eg. a convention file, a
  workspace manifest, etc. The store MAY be a directory in the same repository,
  a separate repository, or an external service — the agent MUST NOT be left
  making assumptions about which one it is.

## Success criteria

- [An artifact MUST exist, named and located.]

- [A state MUST hold, stated so it can be checked.]

- [A deterministic check MUST pass — a linter, a validator, a command.]

- [A boundary MUST have been respected: what the skill did NOT touch.]

- Every success criterion MUST have an RFC 2119 keyword.

## Instructions

1.  First step. Write plain prose in the imperative.

    Add extra paragraphs to cover any detail the agent may need.

2.  Second step.

    ```sh
    some --command
    ```

## Rules

- You MUST state each rule as a full sentence.

  Follow it with an indented paragraph giving the rationale for the rule,
  if not obvious. Explaining _why_ lets an agent apply judgment at the edges.

- You SHOULD keep rules non-sequential. Anything with an order belongs in
  the instructions sections. Anything that holds throughout belongs here.

- Every rule MUST have an RFC 2119 keyword.

- Rules MUST NOT duplicate success criteria.

## Edge cases

- Some edge case, stated as the situation the agent finds itself in.

  Describe how the agent should handle it. Add further paragraphs to the list
  item if detailed guidance may be required.

- The next edge case.

  Describe it. Instruct the agent how to handle it.

## Examples

- Describe a representative input and the expected output or behavior.

- Another example.

## Assets

- [Some template](./assets/template.md) \
  The bundled template to fill out in step N.

## References

- [API errors](./references/api-errors.md) \
  Read if the API returns a non-200 status code.

- [External reference](https://raw.githubusercontent.com/.../AGENTS.md) \
  Read for [purpose].
