---
name: skill-name
description: >-
  One sentence describing what the skill does. Optional sentence describing
  what's out-of-scope. Use when <specific triggers — user phrasings, situations,
  file types, contexts>.
compatibility: requires <tool> or <tool>, and <tool>
license: <license>
metadata:
  <key>: <value>
  interactive: no
  preferred_model: <model-id>
---

# <Skill name>

One sentence, copied from the description, describing what the skill does.

Optionally, set boundaries. What's out-of-scope?

**Input:** Determine the following information from the surrounding context
and environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

- The first input — REQUIRED.
  Describe it, and how to discover it from the surrounding context when the user
  does not supply it explicitly.

- The second input — OPTIONAL.
  Describe it, and its default when absent.

**Output:** What the skill produces, in what format, and where it is written — a
report, a direct edit, a file, a commit, the conversation itself.

Optionally, specify how the agent should summarize the outcomes of its work.

**Interactivity:** You MUST complete this task non-interactively. You MUST NOT
block for user input. You MUST follow the below instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

## Instructions

1.  **Run the extract script.**

    ```sh
    $ python3 scripts/extract.py
    ```

2.  ...

## Rules

- **Base new scripts on this template:**

  ```sh
  #!/bin/env sh
  set -eu

  # ...
  ```

- **Variable naming convention:**

  - `UPPER_SNAKE_CASE` for variables exported to the environment.
  - `lower_snake_case` for everything else, including functions.

  ```sh
  # ❌ No:
  readonly OUTPUT_DIR="/tmp/out"

  # ✅ Yes:
  readonly output_dir="/tmp/out"

  # ✅ Yes:
  export MY_APP_LOG_LEVEL="info"
  ```

## Edge cases

- **Some edge case.**

  Describe the edge case and how the agent should handle it.

## Success criteria

- **The output matches the expected format.**

  Describe the specific structural or syntactic requirement — eg. the regex
  passes, the file is in the right location, the required fields are present.

- **All rules have been respected.**

  Review the completed output against the rules above before finishing.

- **Some domain-specific check.**

  Add one or two concrete, observable conditions specific to this skill —
  things the agent can verify without running external tooling.

  Follow on paragraph here.

## Examples

- **Some example scenario.**

  Describe a representative input and the expected output or behavior.

## Assets

- [Some template](./assets/template.md):
  The bundled template to fill out in step N.

## References

- [API errors](./references/api-errors.md):
  Read if the API returns a non-200 status code.

- [External reference](https://raw.githubusercontent.com/.../AGENTS.md):
  Used this skill for [purpose].

- [Other skill](../skill-name/SKILL.md):
  Used this skill for [purpose] — include only if required to create this skill.
