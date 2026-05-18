---
name: code-posix
description: Coding conventions and design patterns for POSIX-compliant shell scripts.
compatibility: requires sh, shellcheck
license: MIT
---

# POSIX

Use this skill when authoring or modifying shell scripts that must be POSIX-compliant and run across multiple shells (sh, bash, zsh, dash, etc.) and platforms (Linux, macOS, WSL2, and Git Bash for Windows).

Do NOT use this skill for Bash-specific scripts, Python scripts, or shell configuration files (`.bashrc`, `.zshrc`).

Use project-specific shell skills if available.

## Rules

-   **Use POSIX-compliant syntax.**

    Use `#!/bin/sh` (not `#!/bin/bash`).

    No Bashisms (`[[`, `=~`, `${var^}`, etc.). Scripts must work in `sh`, `bash`, `zsh`, and `dash`.

    Do not use the `function` keyword in function declarations – it is not POSIX:

    ```sh
    # ❌
    function my_func() { : ; }

    # ✅
    my_func() { : ; }
    ```

-   **Trap errors.**

    Use `set -eu` at the top of most scripts. `-e` exits immediately when any command returns a non-zero status. `-u` treats references to undefined variables as errors. Both SHOULD be set before any other logic.

    `set -x` MAY be added temporarily for debugging but MUST NOT be committed.

    `set -o pipefail` is not POSIX – do not use it.

    ```sh
    #!/bin/sh

    set -eu

    # Start of script...
    ```

-   **Wrap non-trivial scripts in `main()`.**

    For any script longer than a few lines, define a `main()` function as the entry point and call it at the end of the script:

    ```sh
    main() {
      # Script logic here.
    }

    main "$@"
    ```

    This keeps executable code out of the global scope and away from function definitions.

-   **Return explicit exit codes.**

    Use `return <number>` in functions and `exit <number>` in scripts. 0 = success, non-zero = failure. Avoid implicit status from the last command.

-   **Prefer built-ins over external commands.**

    Shell built-ins run in the shell's own process. External commands spawn a new process.

    Prefer built-in parameter expansion over `sed`, `awk`, etc., for simple text manipulation. It is faster and has no external dependency.

    When external commands are unavoidable, prefer POSIX-standard utilities: `grep`, `sed`, `awk`, `find`, `xargs`, `cut`, `sort`, `uniq`, `tr`, etc. For anything else, eg. non-POSIX utilities for JSON parsing and HTTP requests, document the dependency explicitly.

-   **Use lowercase_snake_case for variable and function names.**

    Do not use `UPPER_SNAKE_CASE` for script variables – it risks collision with shell and environment variables. Use only for variables that are explicitly exported to the environment:

    ```sh
    # ❌ No:
    readonly OUTPUT_DIR="/tmp/out"

    # ✅ Yes:
    readonly output_dir="/tmp/out"

    # ✅ Yes:
    export MY_APP_LOG_LEVEL="info"
    ```

-   **Err on the side of clarity over brevity.**

    Prefer descriptive names over terse abbreviations: `input_file` over `f`, `exit_code` over `rc`.

-   **Declare variables `readonly` by default.**

    Variables SHOULD be `readonly` unless the logic requires reassignment. Apply `readonly` immediately after assignment:

    ```sh
    # ❌ No:
    readonly config_file="/etc/app/config"

    # ✅ Yes:
    result="$(some_command)"
    readonly result
    ```

-   **Quote all variables.**

    Always write `"${var}"`. This is easier to read than `"$var"`, and more reliable than `$var`.

    Quoting prevents word-splitting and glob expansion.

    Exception: intentional word-splitting must have a comment explaining why.

-   **Use `$()` for command substitution.**

    Prefer `$(command)` over backtick syntax. Backticks require escaping when nested; `$()` nests cleanly:

    ```sh
    # ❌ No:
    result=`outer \`inner\``

    # ✅ Yes:
    result="$(outer "$(inner)")"
    ```

-   **Separate data output from messaging.**

    Reserve plain `echo` / `printf` for script *output* (the data the caller expects).

    Send status, errors, and debug info to stderr.

    ```sh
    # Data output:
    echo "result: $value"

    # Status/error messages:
    printf "Processing file: %s\n" "$file" >&2
    ```

    If using a project-specific output library, follow its conventions.

-   **Use `printf` over `echo -e`.**

    The `-e` flag for `echo` is not POSIX. Its handling of backslash escape sequences is implementation-defined and so varies between shells.

    Use `printf` for any output that requires escape interpretation:

    ```sh
    # ❌ No:
    echo -e "Done.\nSee log for details."

    # ✅ Yes:
    printf "Done.\nSee log for details.\n"
    ```

    Plain `echo` (without `-e`) is fine for simple string output with no escape sequences.

-   **Choose argument-handling pattern by scope.**

    *No-argument scripts* validate and reject any input:

    ```sh
    if [ $# -gt 0 ]; then
      printf "Error: script does not accept arguments\n" >&2
      return 1
    fi
    ```

    *Single-option scripts* use a simple case:

    ```sh
    case "${1:-}" in
      --help)  show_help; return 0 ;;
      -*)      printf "Error: unknown option '%s'\n" "$1" >&2; return 1 ;;
      *)       : ;;
    esac
    ```

    *Multi-option scripts* use a loop:

    ```sh
    while [ $# -gt 0 ]; do
      case "$1" in
        --name)  name="$2"; shift 2 ;;
        --file)  file="$2"; shift 2 ;;
        -*)      printf "Error: unknown option '%s'\n" "$1" >&2; return 1 ;;
        *)       break ;;
      esac
    done
    ```

-   **Add defensive checks before destructive operations.**

    Verify assumptions before modifying files, deleting paths, or overwriting data. Handle edge cases - empty strings, missing files, unset variables, or multiple spaces in data:

    ```sh
    # Verify a required external tool is available.
    if ! command -v jq >/dev/null 2>&1; then
      printf "Error: 'jq' is required but not installed\n" >&2
      exit 1
    fi

    # Verify a file exists before operating on it.
    if [ ! -f "${target_file}" ]; then
      printf "Error: file not found: %s\n" "${target_file}" >&2
      exit 1
    fi

    # Dry-run a command before committing to it.
    if ! some_command >/dev/null 2>&1; then
      printf "Error: precondition check failed\n" >&2
      exit 1
    fi
    ```

-   **Do not use `eval` or aliases.**

    `eval` executes arbitrary strings as shell code, making it impossible to reason about what variables were set or whether commands succeeded. Use explicit commands instead.

    Aliases are unreliable in scripts. They are not always expanded and behave differently between interactive and non-interactive shells. Define functions instead.

-   **Validate with ShellCheck.**

    Run this before committing:

    ```sh
    shellcheck --severity=style <script.sh>
    ```

    Address all warnings before committing changes.

    Use ShellCheck's "source" directive to point it to the real path of sourced files (relative to the current file):

    ```sh
    # shellcheck source=./lib/helpers.sh
    . "$(dirname "$0")/lib/helpers.sh"
    ```

    Use ShellCheck's "disable" directive (`# shellcheck disable=SC2086`) sparingly and only with clear justification (which MUST be explained in an adjacent comment).

## Examples

Basic script with argument parsing:

```sh
#!/bin/sh

set -eu

main() {
  action="${1:-}"

  case "$action" in
    start)   start_service; return 0 ;;
    stop)    stop_service; return 0 ;;
    status)  check_status; return 0 ;;
    *)       printf "Error: unknown action '%s'\n" "$action" >&2; return 1 ;;
  esac
}

start_service() {
  if [ -f "$service_pid" ]; then
    printf "Error: service already running\n" >&2
    return 1
  fi
  printf "Starting service...\n" >&2
}

stop_service() {
  printf "Stopping service...\n" >&2
}

check_status() {
  echo "Service is running"
}

main "$@"
```

Defensive checks before file operations:

```sh
#!/bin/sh

set -eu

backup_file() {
  src="$1"
  dst="$2"

  if [ ! -f "$src" ]; then
    printf "Error: source file not found: %s\n" "$src" >&2
    return 1
  fi

  if [ -f "$dst" ]; then
    printf "Error: destination already exists: %s\n" "$dst" >&2
    return 1
  fi

  cp "$src" "$dst" || {
    printf "Error: copy failed\n" >&2
    return 1
  }
}

backup_file "$@"
```

## References

- This skill is based on [TS-19: Unix Shells](https://github.com/kieranpotts/standards/tree/dev/ts/019)

- [POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html) — Official standard

- [Pure sh bible](https://github.com/dylanaraps/pure-sh-bible) by Dylan Araps

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — Practical conventions

- [ShellCheck](https://www.shellcheck.net/) — Static analysis tool for shell scripts
