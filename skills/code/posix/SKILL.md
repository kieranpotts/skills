---
name: posix
description: Coding conventions and design patterns for POSIX-compliant shell scripts.
compatibility: requires sh, shellcheck
license: MIT
---

# POSIX

Use this skill when authoring or modifying a shell scripts that are required to be POSIX-compliant and compatible with the widest possible range of Unix shells, including Bash, Zsh, and Dash, and also Git Bash for Windows and WSL2.

## Instructions

1. **Start from the canonical template.** Use [`bin/git-whoami`](../../bin/git-whoami) as the reference. Every `bin/` script has this shape:

   ```sh
   #!/bin/env sh
   set -eu

   #
   # <command-name> - <one-line description>.
   #
   # <Longer description if needed.>
   #
   # Usage:
   #   $ git <command> [args]
   #
   # Dependencies: <list, or "None">
   #

   # shellcheck source=../lib/print.sh
   . "$(dirname "$0")/../lib/print.sh"

   main() {
     # ...
   }

   main "$@"
   ```

   The **Dependencies** line records external CLI tools the script invokes beyond Git and the standard POSIX utilities (eg. `jq`, `curl`). Git, `lib/` files, and POSIX utilities (`grep`, `sed`, `awk`, `printf`, …) are assumed and not listed. Write `None` if there are no extras.

   `set -x` MAY be added temporarily for debugging but MUST NOT be committed.

2. **Use `print_*` helpers for all user-facing output.** Sourcing [`lib/print.sh`](../../lib/print.sh) exposes:

   | Helper | Stream | Use for |
   | --- | --- | --- |
   | `print_info` | stdout | Neutral informational output (e.g., "nothing to amend"). |
   | `print_success` | stdout | Successful completion of an action. |
   | `print_error` | stderr | Errors that caused the script to abort. |
   | `print_warning` | stderr | Non-fatal warnings the user should see. |
   | `print_hint` | stderr | A follow-up suggestion after an error (e.g., "Try 'gitex --help'"). |
   | `print_prompt` | stdout + stderr | Interactive prompt before a `read`. |

   Plain `echo` / `printf` is reserved for the command's *data* output (e.g., `git whoami` printing `name: …`). Anything that frames or annotates that data uses the helpers.

3. **Pick an argument-handling pattern matching the command's surface.**

   *No-argument commands* ([`bin/git-whoami`](../../bin/git-whoami), [`bin/git-amend`](../../bin/git-amend)) reject all arguments up front:

   ```sh
   if [ $# -gt 0 ]; then
     print_error "git-<name> does not accept any options"
     return 1
   fi
   ```

   *Optioned commands* parse flags. For a fixed, small set of mutually exclusive flags, use a single `case` ([`bin/gitex`](../../bin/gitex)). For mixed positional/named arguments, use `while/case` ([`bin/git-author`](../../bin/git-author)):

   ```sh
   while [ $# -gt 0 ]; do
     case "$1" in
       --name)  author_name="$2"; shift 2 ;;
       --email) author_email="$2"; shift 2 ;;
       -*)      print_error "unknown option '$1'"; return 1 ;;
       *)       # positional handling
                shift ;;
     esac
   done
   ```

   Unknown options emit `print_error "unknown option: …"` followed (where `--help` is implemented) by `print_hint "Try '… --help' for more information."`

4. **Add defensive checks before destructive operations.** Verify preconditions before rewriting history, deleting refs, or force-pushing. Pattern from [`bin/git-amend`](../../bin/git-amend):

   ```sh
   if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
     print_error "no commits exist to amend"
     return 1
   fi
   ```

   Default patterns:
   - Verify `HEAD` exists before any history-rewriting command.
   - Use `git diff --cached --quiet` / `git diff --quiet` to distinguish staged vs. working changes.
   - Use `git ls-files --others --exclude-standard` to detect untracked files.
   - Redirect probing commands' stderr to `/dev/null` so the user only sees the script's own error messages.

5. **Validate.** Run `shellcheck --severity=style bin/<script>` until clean. The full pipeline is `./check` (see [`../testing/SKILL.md`](../testing/SKILL.md)).

## Examples

Sourcing helpers and emitting an error:

```sh
# shellcheck source=../lib/print.sh
. "$(dirname "$0")/../lib/print.sh"

if [ ! -d ".git" ]; then
  print_error "not inside a Git repository"
  return 1
fi
```

## House rules

* Scripts MUST pass `shellcheck --severity=style`.
