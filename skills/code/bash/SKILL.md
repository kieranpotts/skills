---
name: bash
description: Coding conventions and design patterns for Bash scripts.
compatibility: requires bash, shellcheck
license: MIT
---

# Bash

Use this skill when authoring or modifying scripts that target Bash specifically - scripts that use Bash extensions, or that are deployed only to environments where Bash is guaranteed to be available.

Do NOT use this skill for scripts that must be portable across multiple shells. For that, use the `posix` skill instead.

Do NOT use this skill for Python scripts or shell configuration files (`.bashrc`, `.zshrc`).

Use project-specific shell skills if available.

All rules from the `posix` skill apply here. This skill extends them with Bash-specific conventions.

## Rules

- **Use `#!/usr/bin/env bash` as the shebang.**

  The env-style shebang searches `PATH` for the `bash` binary, making the script more portable across environments where Bash may not be at a fixed path:

  ```bash
  #!/usr/bin/env bash
  ```

- **Enable strict mode with `set -euo pipefail`.**

  This extends the POSIX `set -eu` with `-o pipefail`, which causes a pipeline to return a failure status if any command within it fails - not just the last one:

  ```bash
  #!/usr/bin/env bash

  set -euo pipefail

  # Start of script...
  ```

- **Declare function variables `local`.**

  Use `local` for all variables declared inside functions, including loop counters. This prevents polluting the global namespace and avoids accidentally overwriting variables in the caller:

  ```bash
  process_items() {
    local count=0
    local item
    for item in "$@"; do
      (( count += 1 ))
    done
  }
  ```

  Where `local` is intentionally omitted to update a global variable, leave a comment explaining why.

- **Use `[[ … ]]` for conditionals.**

  Prefer the Bash double-bracket syntax over `[ … ]` and `test`. It prevents pathname expansion and word splitting, and supports regular expression matching:

  ```bash
  # ✅ Regex match, no word splitting.
  if [[ "${filename}" =~ ^[[:alnum:]]+$ ]]; then
    printf "Alphanumeric filename\n" >&2
  fi

  # ❌ f* expands to directory contents — likely a "too many arguments" error.
  if [ "${filename}" == f* ]; then
    ...
  fi
  ```

  Use `==` for equality, not `=` (which reads as assignment):

  ```bash
  # ✅
  if [[ "${var}" == "value" ]]; then ...

  # ❌
  if [[ "${var}" = "value" ]]; then ...
  ```

  Use `-z` and `-n` to test for empty and non-empty strings:

  ```bash
  if [[ -z "${var}" ]]; then ...  # true if empty
  if [[ -n "${var}" ]]; then ...  # true if non-empty
  ```

  Use `(( … ))` or `-lt`/`-gt` for numeric comparisons. Do not use `<` or `>` inside `[[ … ]]` - they perform lexicographical comparison:

  ```bash
  # ✅
  if (( count > 3 )); then ...

  # ❌ Lexicographical: true for "4" but false for "22".
  if [[ "${count}" > 3 ]]; then ...
  ```

- **Use `(( … ))` and `$(( … ))` for arithmetic.**

  Do not use `$[ … ]` (deprecated), `let` (word-splitting risk), or `expr` (external process):

  ```bash
  # ✅
  result=$(( a + b ))
  (( count += 1 ))

  # ❌
  result=$[ a + b ]
  let result="a + b"
  result=$(expr "${a}" + "${b}")
  ```

  Variables may be referenced without `${…}` inside `$(( … ))`:

  ```bash
  echo "$(( hr * 3600 + min * 60 + sec ))"
  ```

- **Use arrays for argument lists.**

  Bash arrays safely expand lists without word splitting. Use them when building argument lists for commands:

  ```bash
  declare -a flags
  flags=(--output="${output_dir}" --verbose)
  flags+=(--config="${config_file}")
  mybinary "${flags[@]}"
  ```

  Do not accumulate arguments in a string - it breaks for values containing spaces:

  ```bash
  # ❌
  flags="--output=${output_dir} --verbose"
  mybinary ${flags}
  ```

  Name array variables in the plural. Use the singular form for loop iteration variables:

  ```bash
  for zone in "${zones[@]}"; do
    process "${zone}"
  done
  ```

- **Use `.` not `source` for sourcing files.**

  `source` is a Bash extension, so it works. But the POSIX-compliant `.` is more portable, concise, and perfectly readable.

  ```bash
  # ❌
  source lib/helpers.sh

  # ✅
  . lib/helpers.sh
  ```

  Be aware of sourcing pitfalls:

  - `cd` in a sourced file changes the parent script's working directory. Restore it before returning.

  - Variable name collisions between parent and sourced files are a common bug. Prefer passing data as arguments rather than relying on shared global state.

- **Use `.sh` or no extension for file names.**

  Never use `.bash` as a file extension. Use `.sh` for libraries and scripts invoked by other tools. Omit the extension entirely for scripts invoked directly as commands.

## Examples

Script with strict mode, local variables, arrays, and Bash conditionals:

```bash
#!/usr/bin/env bash

set -euo pipefail

main() {
  local input_dir="${1:-}"

  if [[ -z "${input_dir}" ]]; then
    printf "Usage: %s <directory>\n" "$0" >&2
    exit 1
  fi

  if [[ ! -d "${input_dir}" ]]; then
    printf "Error: not a directory: %s\n" "${input_dir}" >&2
    exit 1
  fi

  process_files "${input_dir}"
}

process_files() {
  local dir="$1"
  local -a files
  local count=0
  local file

  mapfile -t files < <(find "${dir}" -name "*.txt" -type f)

  for file in "${files[@]}"; do
    printf "Processing: %s\n" "${file}" >&2
    (( count += 1 ))
  done

  printf "Done. Processed %d file(s).\n" "${count}" >&2
}

main "$@"
```

## References

- This skill is based on [TS-19a: Bash](https://github.com/kieranpotts/standards/tree/dev/ts/019a)

- [Bash reference manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)

- [Pure Bash bible](https://github.com/dylanaraps/pure-bash-bible) by Dylan Araps

- [Bash scripting quirks and safety tips](https://jvns.ca/blog/2017/03/26/bash-quirks/) by Julia Evans

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — Practical conventions

- [ShellCheck](https://www.shellcheck.net/) — Static analysis tool for shell scripts
