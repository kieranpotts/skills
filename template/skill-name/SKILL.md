---
name: skill-name
description: Skill description here.
compatibility: requires <tool> or <tool>
license: <license>
metadata:
  <key>: <value>
---

# Skill name

Use this skill when...

This skill extends [this skill](https://raw.githubusercontent.com/...) – all rules there apply here.

Do NOT use this skill for...

## Instructions

Instructions are step-by-step procedural implementation workflows.

1.  **Short description.**

    Extended details.

2.  **Run the execution script.**

    ```sh
    $ python3 scripts/extract.py
    ```

3.  ...

## Rules

Rules are an unordered list of guidelines, recommendations, and best practices.

-   **Short description.**

    Extended details.

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

A small number of canonical input/output examples. Regular prose. OPTIONAL.

## Edge cases

Warn about potential edge cases. Regular prose. OPTIONAL.

## References

List of links with extended and related information for agents.

- [Technical reference](./references/REFERENCE.md)
- [Domain-specific notes](./references/<subdomain>.md)
- [Adjacent skill](../skill-name/SKILL.md) – used for xxxxx.
- [External skill](https://raw.githubusercontent.com/.../SKILL.md] – used for xxxxx.
