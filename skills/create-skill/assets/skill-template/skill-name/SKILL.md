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

**Input:** Describe the information will require to perform the task encoded
in this skills.

- Alternatively a discrete piece of information required, as a single bullet
  point.

- And another discrete piece of information.

Gather the information you can from the surrounding context. If in doubt,
prompt the user for clarification.

Specify whether the agent should work non-interactively to completion, or if
the agent may interact with the user — blocking to ask questions, present
options, and wait for answers.

**Output:**

What the skill produces, in what format, and where it is written — a
report, a direct edit, a file, a commit, the conversation itself. Specify how
the agent should summarize the outcomes of its work.

##  Instructions

1.  **Run the extract script.**

    ```sh
    $ python3 scripts/extract.py
    ```

2.  ...

##  Rules

-   **Base new scripts on this template:**

    ```sh
    #!/bin/env sh
    set -eu

    # ...
    ```

-   **Variable naming convention:**

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

##  Success criteria

-   **The output matches the expected format.**

    Describe the specific structural or syntactic requirement — eg. the regex
    passes, the file is in the right location, the required fields are present.

-   **All rules have been respected.**

    Review the completed output against the rules above before finishing.

-   **Some domain-specific check.**

    Add one or two concrete, observable conditions specific to this skill —
    things the agent can verify without running external tooling.]

## Examples

A small number of canonical input/output examples. Regular prose. OPTIONAL.

## Edge cases

Warn about potential edge cases. Regular prose. OPTIONAL.

## References

Include a ist of links with extended and related information. For each, include
an explicit trigger condition.

- [API errors](./references/api-errors.md):
  Read if the API returns a non-200 status code.

- [Some template](./assets/template.md):
  The bundled template to fill out in step N.

- [Adjacent skill](../skill-name/SKILL.md):
  Used for [purpose].

- [External skill](https://raw.githubusercontent.com/.../SKILL.md):
  Used for [purpose].
