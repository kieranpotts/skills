---
name: skill-name
description: <One sentence describing what the skill does.> Use when <specific triggers – user phrasings, situations, file types, contexts>.
compatibility: requires <tool> or <tool>
license: <license>
metadata:
  <key>: <value>
  # Set to `no` to enable non-interactive execution of the skill.
  # Compatible agents will not prompt the user. OPTIONAL (default: yes).
  interactive: no
  # Proprietary metadata used by my own tools.
  # OPTIONAL (default: use host agent).
  preferred_model: <model-id>
---

# <Skill name>

Use this skill when <scenario>.

This skill extends [this skill](https://raw.githubusercontent.com/...) – all rules there apply here.

Do NOT use this skill for <exceptions...>.

**Input**: <What the skill consumes, and how it is supplied (file paths, URLs, pasted text, an upstream artifact, the surrounding context). State whether it is REQUIRED or OPTIONAL. For an interactive skill, state explicitly that the skill ALSO gathers input from the user through prompts during the session – so the initial input may be partial or absent.>

**Output**: <What the skill produces, in what form, and where it goes. Name any completeness guarantees the output enforces. State what is deliberately out of scope.>

##  Instructions

_Instructions are step-by-step procedural implementation workflows._

1.  **[Short description.]**

    [Extended details.]

2.  **Run the execution script.**

    ```sh
    $ python3 scripts/extract.py
    ```

3.  ...

##  Rules

_Rules are an unordered list of guidelines, recommendations, and best practices._

-   **[Short description.]**

    [Extended details.]

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

## Examples

_A small number of canonical input/output examples. Regular prose. OPTIONAL._

## Edge cases

_Warn about potential edge cases. Regular prose. OPTIONAL._

##  Success criteria

- **The output matches the expected format.** [Optionally, describe the specific structural or syntactic requirement — eg. the regex passes, the file is in the right location, the required fields are present.]

- **All rules have been respected.** Review the completed output against the rules above before finishing.

- **[Domain-specific check.]** [Add one or two concrete, observable conditions specific to this skill — things the agent can verify without running external tooling.]

## References

_Links to the skill's OWN bundled resources that the agent needs to read to do the job – each with an explicit trigger condition. OPTIONAL. Point only at files inside this skill's directory; external references that exist for human context (the technique behind the skill, an upstream skill it was adapted from, background reading) belong in the sibling `README.md`, NOT here – a link in a SKILL.md invites the agent to fetch it and bloat its context for no operational gain._

- [API errors](./references/api-errors.md): Read if the API returns a non-200 status code.

- [`assets/some-template.md`](./assets/some-template.md): The bundled template to fill out in step N.
