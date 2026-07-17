---
name: skill-name
description: >-
  One sentence describing what the skill does. Optional sentence describing
  what's out of scope. Use when <specific triggers — user phrasings, situations,
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

Optionally, set boundaries. What's out of scope?

**Input:**

<!--
Input is ALWAYS a list, even when there is only one input. Each item is a
bullet whose bold lead is a short description followed by the requirement
level (REQUIRED or OPTIONAL). Explanatory text follows the bold lead — this
is optional.
Give each genuinely distinct input its own bullet. Split a primary input and a
supporting convention/context into separate items rather than joining them
with "plus".
-->

- **The first input. REQUIRED.** Describe it, and how to discover it from the
  surrounding context when the user does not supply it explicitly.

- **The second input. OPTIONAL.** Describe it, and its default when absent.

You MUST complete this task non-interactively. You MUST NOT block for user input
after this initial prompt. You MUST follow the instructions to completion, else
fail with an error message. If in doubt about any of the requirements of this
task, you MUST stop and print an error message.

<!--
The interactivity statement above is ALWAYS its own paragraph, immediately
after the input descriptions. State whether the skill runs non-interactively to
completion, or is interactive — blocking to ask questions, present options,
and wait for answers.
Keep `metadata.interactive` in the front-matter consistent with this.
-->

**Output:**

What the skill produces, in what format, and where it is written — a
report, a direct edit, a file, a commit, the conversation itself.

Optionally, specify how the agent should summarize the outcomes of its work.

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
