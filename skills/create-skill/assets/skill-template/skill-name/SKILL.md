---
name: skill-name
description: >-
  One sentence describing what the skill does. Optional sentence describing
  what's out-of-scope. Use when <specific triggers — user phrasings, situations,
  file types, contexts>.
compatibility: requires <tool> or <tool>, and <tool>
license: <license>
metadata:
  interactive: no
  preferred_model: <model-id>
---

# [Skill name]

One or two sentences, adapted from the description, saying what the skill
does.

Set the boundaries. What is out-of-scope? What should the agent explicitly
not do?

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
  from the surrounding context when the user does not supply it explicitly.

- **The second parameter — OPTIONAL.** Describe it, and its default when
  absent.

- **Where the [artifact] lives, and how to write to it — REQUIRED.**
  Discover this rather than assuming it: check this session's context first,
  then the environment (a convention file, a workspace manifest, a configured
  connector). If neither settles it, ask the user. The store MAY be a
  directory in this repository, a separate repository, or an external service
  — do not assume a filesystem path, a file name, or a document structure.

## Success criteria

You will achieve the following outcomes:

- [An artifact MUST exist, named and located.]

- [A state MUST hold, stated so it can be checked.]

- [A deterministic check MUST pass — a linter, a validator, a command.]

- [A boundary MUST have been respected: what the skill did NOT touch.]

- Every success criterion MUST have an RFC 2119 keyword.

## Instructions

1.  First step, in the imperative.

    Any detail the step needs, in plain prose.

2.  Second step.

    ```sh
    some --command
    ```

## Rules

- You MUST state each rule as a full sentence.

  Follow it with an indented paragraph giving the reason, where the reason
  is not obvious. Explaining why lets the agent apply judgment at the edges.

- You SHOULD keep rules non-sequential.

  Anything with an order belongs in Instructions. Anything that holds
  throughout belongs here.

- Every rule MUST have an RFC 2119 keyword.

- Rules MUST NOT duplicate success criteria.

## Edge cases

- Some edge case.

  Describe the edge case and how the agent should handle it.

## Examples

- Some example scenario.

  Describe a representative input and the expected output or behavior.

## Assets

- [Some template](./assets/template.md):
  The bundled template to fill out in step N.

## References

- [API errors](./references/api-errors.md):
  Read if the API returns a non-200 status code.

- [External reference](https://raw.githubusercontent.com/.../AGENTS.md):
  Read for [purpose].
