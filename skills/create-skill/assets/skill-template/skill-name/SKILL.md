---
name: skill-name
description: >-
  One sentence describing what the skill does. Optional sentence describing
  what's out of scope. Use when <specific triggers — user phrasings, situations,
  file types, contexts>. Do NOT use this skill for <exceptions...>.
compatibility: requires <tool> or <tool>, and <tool>
license: <license>
metadata:
  <key>: <value>
  interactive: no
  preferred_model: <model-id>
---

# <Skill name>

One sentence, copied from the description, describing what the skill does.

**Input:** Describe the information the agent requires to perform the task
encoded in this skill, and mark it REQUIRED or OPTIONAL. Gather as much of this
information as possible from the surrounding context, and prompt the user for
anything that's missing or unclear.

<!--
  For a SINGLE input, describe it in the prose paragraph above, with the
  REQUIRED/OPTIONAL marker inline. For MULTIPLE distinct inputs, drop the prose
  and use one bold-lead bullet per input instead, with the marker inside the
  bold lead:

  **Input:**

  - **The first input. REQUIRED.** Describe it, and how to discover it from the
    context when the user does not supply it explicitly.

  - **The second input. OPTIONAL.** Describe it, and its default when absent.
-->

This skill is non-interactive: agents MUST NOT block for user input after the
initial prompt, and MUST follow the instructions to completion or fail with an
error message.

<!--
  The interactivity statement above is ALWAYS its own paragraph, immediately
  after the input description. State whether the skill runs non-interactively to
  completion, or is interactive — blocking to ask questions, present options,
  and wait for answers. For an interactive skill, say so and note that it
  gathers the rest of its input from the user during the session, eg.:

  This skill is interactive: it gathers the rest of its input from the user
  through prompts during the session, asking one question at a time.

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
