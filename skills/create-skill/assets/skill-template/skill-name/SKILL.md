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

Gather as much of this information as possible from the surrounding context.
Prompt the user for anything that's missing or unclear.

Specify whether the agent should work non-interactively to completion, or if
the agent may interact with the user — blocking to ask questions, present
options, and wait for answers.

**Output:**

What the skill produces, in what format, and where it is written — a
report, a direct edit, a file, a commit, the conversation itself.

Optionally, specify how the agent should summarize the outcomes of its work.

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

##  Edge cases

-   **Some edge case.**

    Describe the edge case and how the agent should handle it.

##  Success criteria

-   **The output matches the expected format.**

    Describe the specific structural or syntactic requirement — eg. the regex
    passes, the file is in the right location, the required fields are present.

-   **All rules have been respected.**

    Review the completed output against the rules above before finishing.

-   **Some domain-specific check.**

    Add one or two concrete, observable conditions specific to this skill —
    things the agent can verify without running external tooling.]

##  Examples

-   **Some example scenario.**

    Describe a representative input and the expected output or behavior.

##   Assets

-   [Some template](./assets/template.md):
    The bundled template to fill out in step N.

##   References

-   [API errors](./references/api-errors.md):
    Read if the API returns a non-200 status code.

-   [External reference](https://raw.githubusercontent.com/.../AGENTS.md):
    Used this skill for [purpose].

-   [Other skill](../skill-name/SKILL.md):
    Used this skill for [purpose] — include only if required to create this skill.
