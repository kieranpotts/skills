---
name: posix
description: Coding conventions and design patterns for POSIX-compliant shell scripts.
compatibility: requires sh, shellcheck
license: MIT
---

# POSIX

Use this skill when authoring or modifying shell scripts that must be POSIX-compliant and run across multiple shells (sh, bash, zsh, dash) and platforms (Linux, macOS, Windows WSL2, Git Bash).

Do NOT use this skill for Bash-specific scripts, Python scripts, or shell configuration files (`.bashrc`, `.zshrc`). Use project-specific shell skills if available.

## Instructions

1.  **Start with POSIX-compliant structure**:

    ```sh
    #!/bin/sh
    set -eu

    #
    # Script description in a comment block at the top.
    # Usage: script-name [options] [args]
    # Dependencies: none (or list external tools: jq, curl, etc.)
    #

    main() {
      # Script logic here.
      return 0
    }

    main "$@"
    ```

    Use `#!/bin/sh` (not `#!/bin/bash`).

    Add shellcheck directives for sourced files:

    ```sh
    # shellcheck source=./lib/helpers.sh
    . "$(dirname "$0")/lib/helpers.sh"
    ```

    `set -eu` enables:
    - `-e`: Exit on first error
    - `-u`: Error on undefined variables

    `set -x` MAY be added temporarily for debugging but MUST NOT be committed.

2. **Separate data output from messaging.**

    Reserve plain `echo` / `printf` for script *output* (the data the user/caller expects). Use structured messaging for everything else (status, errors, debug info):

    ```sh
    # Data output (user expects this)
    echo "result: $value"

    # Status messages (send to stderr)
    printf "Processing file: %s\n" "$file" >&2
    ```

    If using a project-specific output library, follow its conventions.

3.  **Choose argument-handling pattern by scope.**

    *No-argument scripts* validate and reject any input:

    ```sh
    if [ $# -gt 0 ]; then
      printf "Error: script does not accept arguments\n" >&2
      return 1
    fi
    ```

    *Single-option scripts* use simple checks:
    ```sh
    case "${1:-}" in
      --help)  show_help; return 0 ;;
      -*)      printf "Error: unknown option '%s'\n" "$1" >&2; return 1 ;;
      *)       break ;;
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

4.  **Add defensive checks before destructive operations.**

    Verify assumptions before modifying files, deleting paths, or overwriting data:

    ```sh
    # Check preconditions before deletion
    if [ ! -f "$target_file" ]; then
      printf "Error: file not found: %s\n" "$target_file" >&2
      return 1
    fi

    # Check for required tools
    if ! command -v jq >/dev/null 2>&1; then
      printf "Error: 'jq' is required but not installed\n" >&2
      return 1
    fi

    # Test before committing
    if ! some_command > /dev/null 2>&1; then
      printf "Error: precondition check failed\n" >&2
      return 1
    fi
    ```

5. **Validate with ShellCheck**:

    ```sh
    shellcheck --severity=style script.sh
    ```

    Address all warnings. Use directives (`# shellcheck disable=SC2086`) sparingly and only with clear justification.

## Rules

- **POSIX-only.** No Bashisms (`[[`, `=~`, `${var^}`, etc.). Test scripts work in `sh`, `bash`, `zsh`, and `dash`.

- **No external dependencies unless necessary.** Rely on POSIX utilities: `grep`, `sed`, `awk`, `find`, `xargs`, `cut`, `sort`, `uniq`, `tr`. For complex operations (JSON parsing, HTTP requests), document the dependency.

- **Trap errors explicitly.** Use `set -e` to exit on error, but understand it has edge cases. For critical sections, add explicit error checks.

- **Quote variables.** Always quote: `"$var"` not `$var`. Prevents word-splitting and glob expansion. Exception: intentional word-splitting must have a comment explaining why.

- **Use meaningful variable names.** Prefer `input_file` over `f`, `exit_code` over `rc`. Shell isn't verbose; clarity matters.

- **Return explicit exit codes.** Use `return N` (functions) or `exit N` (scripts). 0 = success, non-zero = failure. Avoid implicit status from the last command.

- **Handle edge cases.** Empty strings, missing files, unset variables, multiple spaces in data. Test with `set -u` and `-e` enabled.

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

- [POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html) — Official standard

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — Practical conventions

- [ShellCheck](https://www.shellcheck.net/) — Static analysis tool for shell scripts
