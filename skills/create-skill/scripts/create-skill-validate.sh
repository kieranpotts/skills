#!/usr/bin/env bash

#
# Validate a skill directory against the canonical Agent Skills spec and this
# repo's additional conventions.
#
# If `skills-ref` is installed on the host, it is used for the canonical
# checks (front-matter, naming, required fields). Repo-specific checks always
# run regardless.
#

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-skill-validate.sh <skill_dir>

Validate a skill directory containing a SKILL.md.

Arguments:
  <skill_dir>   Path to a skill directory (must contain SKILL.md).

Exit codes:
  0   All checks passed.
  1   One or more checks failed, or invalid invocation.
EOF
}

main() {
  local skill_dir="${1:-}"

  if [[ -z "${skill_dir}" || "${skill_dir}" == "-h" || "${skill_dir}" == "--help" ]]; then
    usage
    [[ -z "${skill_dir}" ]] && exit 1 || exit 0
  fi

  if [[ ! -d "${skill_dir}" ]]; then
    printf "Error: not a directory: %s\n" "${skill_dir}" >&2
    exit 1
  fi

  skill_dir="${skill_dir%/}"
  local skill_md="${skill_dir}/SKILL.md"

  if [[ ! -f "${skill_md}" ]]; then
    printf "Error: SKILL.md not found at %s\n" "${skill_md}" >&2
    exit 1
  fi

  local errors=0

  run_skills_ref "${skill_dir}" || errors=$(( errors + 1 ))
  run_repo_checks "${skill_dir}" "${skill_md}" || errors=$(( errors + 1 ))

  printf "\n"
  if (( errors > 0 )); then
    printf "Validation FAILED.\n" >&2
    exit 1
  fi
  printf "Validation PASSED.\n" >&2
}

run_skills_ref() {
  local skill_dir="$1"

  printf "== Canonical checks (skills-ref) ==\n" >&2

  if ! command -v skills-ref >/dev/null 2>&1; then
    printf "  skills-ref not installed — skipping canonical checks.\n" >&2
    printf "  Install with: pipx install skills-ref\n" >&2
    return 0
  fi

  if skills-ref validate "${skill_dir}"; then
    return 0
  fi
  return 1
}

#
# Emit a Markdown file with its fenced code blocks removed, so that headings
# and list markers inside worked examples are not mistaken for the document's
# own structure.
#
strip_fences() {
  awk '/^[[:space:]]*```/ { f = !f; next } !f' "$1"
}

#
# Emit the YAML front-matter block of a Markdown file.
#
front_matter() {
  awk '/^---$/ { c++; next } c == 1' "$1"
}

run_repo_checks() {
  local skill_dir="$1"
  local skill_md="$2"
  local failed=0

  printf "\n== Repo-specific checks ==\n" >&2

  # Sibling README.md is required (see create-skill SKILL.md success criteria).
  if [[ -f "${skill_dir}/README.md" ]]; then
    printf "  [PASS] README.md present\n" >&2
    check_readme_sections "${skill_dir}/README.md" || failed=1
  else
    printf "  [FAIL] Missing sibling README.md\n" >&2
    failed=1
  fi

  # SKILL.md is under 500 lines, matching the canonical Agent Skills
  # guidance. Physical lines, blank lines included — the budget is on the
  # file as loaded into the context window, not on its prose.
  local line_count
  line_count=$(wc -l <"${skill_md}")
  if (( line_count <= 500 )); then
    printf "  [PASS] SKILL.md is %d lines (<= 500)\n" "${line_count}" >&2
  else
    printf "  [FAIL] SKILL.md is %d lines (exceeds 500-line limit)\n" "${line_count}" >&2
    failed=1
  fi

  # At least one of '## Instructions' or '## Rules' is required.
  # Tolerate extra spaces after the '##' marker (eg. '##  Rules').
  if grep -qE '^## +(Instructions|Rules)\b' "${skill_md}"; then
    printf "  [PASS] Has '## Instructions' and/or '## Rules'\n" >&2
  else
    printf "  [FAIL] Missing both '## Instructions' and '## Rules'\n" >&2
    failed=1
  fi

  # '## Success criteria' is required.
  if grep -qE '^## +Success criteria\b' "${skill_md}"; then
    printf "  [PASS] Has '## Success criteria' section\n" >&2
  else
    printf "  [FAIL] Missing '## Success criteria' section\n" >&2
    failed=1
  fi

  # '## Parameters' is required.
  if grep -qE '^## +Parameters\b' "${skill_md}"; then
    printf "  [PASS] Has '## Parameters' section\n" >&2
  else
    printf "  [FAIL] Missing '## Parameters' section\n" >&2
    failed=1
  fi

  # The Agent Skills standard treats 'license' and 'compatibility' as
  # optional, so skills-ref checks neither. This collection requires both.
  local fm_field
  for fm_field in license compatibility; do
    if front_matter "${skill_md}" | grep -qE "^${fm_field}:[[:space:]]*[^[:space:]]"; then
      printf "  [PASS] Front-matter declares '%s'\n" "${fm_field}" >&2
    else
      printf "  [FAIL] Front-matter is missing '%s'\n" "${fm_field}" >&2
      failed=1
    fi
  done

  # The body must open with a level 1 heading matching the skill name in
  # sentence case, hyphens replaced by spaces — 'create-skill' -> 'Create skill'.
  local name expected_h1 actual_h1
  name="$(front_matter "${skill_md}" | sed -nE 's/^name:[[:space:]]*//p' | head -1)"
  expected_h1="$(tr '-' ' ' <<<"${name}")"
  expected_h1="${expected_h1^}"
  actual_h1="$(strip_fences "${skill_md}" | sed -nE 's/^# +//p' | head -1)"
  if [[ "${actual_h1}" == "${expected_h1}" ]]; then
    printf "  [PASS] H1 matches the skill name ('%s')\n" "${expected_h1}" >&2
  else
    printf "  [FAIL] H1 is '%s'; expected '%s'\n" "${actual_h1}" "${expected_h1}" >&2
    failed=1
  fi

  # Sections must appear in the canonical template order, with no headings
  # outside that set. This subsumes the rule that '## Parameters' and
  # '## Success criteria' lead the body.
  local canonical found unknown
  canonical="$(printf '%s\n' \
    'Parameters' \
    'Success criteria' \
    'Instructions' \
    'Rules' \
    'Edge cases' \
    'Examples' \
    'Assets' \
    'References')"
  found="$(strip_fences "${skill_md}" | grep -E '^## +' | sed -E 's/^## +//; s/[[:space:]]+$//')"

  unknown="$(grep -vxF -f <(printf '%s\n' "${canonical}") <<<"${found}" || true)"
  if [[ -n "${unknown}" ]]; then
    printf "  [FAIL] SKILL.md has unrecognized section(s): %s\n" \
      "$(tr '\n' '/' <<<"${unknown}")" >&2
    failed=1
  elif [[ "${found}" == "$(grep -xF -f <(printf '%s\n' "${found}") <<<"${canonical}")" ]]; then
    printf "  [PASS] SKILL.md sections are in canonical order\n" >&2
  else
    printf "  [FAIL] SKILL.md sections are out of order: %s\n" \
      "$(tr '\n' '/' <<<"${found}")" >&2
    failed=1
  fi

  # There must be no separate output section — it is absorbed by the
  # success criteria.
  if strip_fences "${skill_md}" | grep -qE '^## +Output\b|^\*\*Output\*\*:'; then
    printf "  [FAIL] Has an output section; fold it into '## Success criteria'\n" >&2
    failed=1
  else
    printf "  [PASS] No separate output section\n" >&2
  fi

  # Inline bold is reserved for the '## Parameters' leads. Flag bold-lead
  # bullets appearing anywhere after the success criteria heading.
  local bold_after
  bold_after="$(strip_fences "${skill_md}" \
    | awk '/^## +Success criteria/{f=1} f && /^- +\*\*/{c++} END{print c+0}')"
  if [ "${bold_after}" -eq 0 ]; then
    printf "  [PASS] Inline bold confined to '## Parameters'\n" >&2
  else
    printf "  [FAIL] %d bold-lead bullet(s) after '## Success criteria'\n" "${bold_after}" >&2
    printf "         Rules, criteria, edge cases, and examples are plain prose\n" >&2
    failed=1
  fi

  # Every top-level item under '## Rules' and '## Success criteria' should
  # carry a requirement level. Continuation lines are folded into their item,
  # so a keyword anywhere in the item counts.
  local no_keyword
  no_keyword="$(strip_fences "${skill_md}" | awk '
      /^## +(Rules|Success criteria)[[:space:]]*$/ { in_section = 1; item = ""; next }
      /^## +/ { if (item != "") print item; item = ""; in_section = 0; next }
      !in_section { next }
      /^- / { if (item != "") print item; item = $0; next }
      item != "" { item = item " " $0 }
      END { if (item != "") print item }
    ' | grep -cvE '(^|[^A-Za-z])(MUST|SHOULD|REQUIRED|RECOMMENDED|OPTIONAL|MAY)([^A-Za-z]|$)' || true)"
  if [[ "${no_keyword}" -eq 0 ]]; then
    printf "  [PASS] Every rule and criterion carries a requirement level\n" >&2
  else
    printf "  [WARN] %d rule(s)/criteria without an RFC 2119 keyword\n" "${no_keyword}" >&2
    printf "         A step with no requirement level is ambiguous\n" >&2
  fi

  check_compatibility_tools "${skill_md}"
  check_line_length "${skill_md}" || failed=1
  check_bundled_resources "${skill_dir}" "${skill_md}" || failed=1

  return "${failed}"
}

#
# 'compatibility' names the agent tools a skill needs. External commands are
# not agent tools: they belong in a parenthetical after Bash, eg.
# 'Bash (git diff)'. Advisory for now — some skills still name a bare command.
#
check_compatibility_tools() {
  local skill_md="$1"
  local allowed=" Bash Edit Glob Grep Read WebFetch WebSearch Write "
  local compat tool unknown=""

  # Capture the value, following YAML folded-scalar continuation lines.
  compat="$(front_matter "${skill_md}" | awk '
      /^compatibility:/ {
        v = $0
        sub(/^compatibility:[[:space:]]*/, "", v)
        if (v == ">-" || v == ">" || v == "|" || v == "|-") v = ""
        grab = 1
        next
      }
      grab && /^[[:space:]]+[^[:space:]]/ {
        line = $0
        sub(/^[[:space:]]+/, "", line)
        v = (v == "" ? line : v " " line)
        next
      }
      grab { grab = 0 }
      END { print v }
    ')"

  # Drop the 'requires' lead and any parenthetical qualifiers, then split.
  compat="${compat/#requires/}"
  compat="$(sed -E 's/\([^)]*\)//g; s/ (or|and) /, /g' <<<"${compat}")"

  while IFS= read -r tool; do
    [[ -z "${tool}" ]] && continue
    [[ "${allowed}" == *" ${tool} "* ]] || unknown+=" ${tool}"
  done < <(tr ',' '\n' <<<"${compat}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

  if [[ -z "${unknown}" ]]; then
    printf "  [PASS] 'compatibility' names known agent tools\n" >&2
  else
    printf "  [WARN] 'compatibility' names non-tool value(s):%s\n" "${unknown}" >&2
    printf "         Put external commands in a parenthetical, eg. 'Bash (git diff)'\n" >&2
  fi
}

#
# TS-27 puts lines at 80 characters SHOULD, 160 MUST. Tables, fenced code, and
# unbreakable links are exempt. The budget covers the front-matter too, so no
# line is skipped on account of being metadata.
#
check_line_length() {
  local skill_md="$1"
  local over_80 over_160

  over_80="$(awk '
      /^[[:space:]]*```/ { fence = !fence; next }
      fence { next }
      /^[[:space:]]*\|/ { next }
      /\]\(/ || /http/ { next }
      length($0) > 80 { c++ }
      END { print c+0 }
    ' "${skill_md}")"

  over_160="$(awk '/^[[:space:]]*\|/ { next } /http/ { next } length($0) > 160 { c++ } END { print c+0 }' "${skill_md}")"

  if (( over_160 > 0 )); then
    printf "  [FAIL] %d line(s) exceed the 160-character hard limit\n" "${over_160}" >&2
    return 1
  fi

  if (( over_80 == 0 )); then
    printf "  [PASS] Lines are within the 80-character budget\n" >&2
  else
    printf "  [WARN] %d line(s) exceed 80 characters\n" "${over_80}" >&2
  fi
  return 0
}

#
# Bundled resources under assets/, references/, and scripts/ are merged into
# one shared directory per agent when a skill is compiled for flat-file
# targets such as Copilot and Cursor. Two skills shipping the same path there
# collide, the second silently overwriting the first. So every immediate
# child of those directories must be namespaced to the skill — either a
# directory named after it, or a name prefixed with it.
#
# Each immediate child must also be reachable from SKILL.md, carrying the
# condition under which the agent loads or runs it. Nesting below that level
# is the skill's own business; only the entry point needs naming.
#
check_bundled_resources() {
  local skill_dir="$1"
  local skill_md="$2"
  local failed=0
  local name subdir child base found_any=0

  name="$(basename "${skill_dir}")"

  for subdir in assets references scripts; do
    [[ -d "${skill_dir}/${subdir}" ]] || continue
    for child in "${skill_dir}/${subdir}"/*; do
      [[ -e "${child}" ]] || continue
      base="$(basename "${child}")"
      found_any=1

      if [[ "${base}" != "${name}"* ]]; then
        printf "  [FAIL] %s/%s is not namespaced (expected '%s' prefix)\n" \
          "${subdir}" "${base}" "${name}" >&2
        failed=1
      fi

      # Match on the path, not the bare name. A directory named after the
      # skill would otherwise match trivially, the skill's own name being
      # all over its SKILL.md.
      if ! grep -qF "${subdir}/${base}" "${skill_md}"; then
        printf "  [FAIL] %s/%s is not referenced from SKILL.md\n" \
          "${subdir}" "${base}" >&2
        failed=1
      fi
    done
  done

  if (( found_any == 0 )); then
    printf "  [PASS] No bundled resources to check\n" >&2
  elif (( failed == 0 )); then
    printf "  [PASS] Bundled resources are namespaced and referenced\n" >&2
  fi

  return "${failed}"
}

#
# The human-facing README.md carries a fixed set of sections, in a fixed
# order. 'Interactivity', 'How to invoke', and 'Recommended models' are
# required — every skill has an interactivity mode, an invocation, and a
# model class. 'Examples', 'Suggested workflows', 'Related skills', and
# 'References' are contingent on the skill, so they are optional, but must
# sit in their canonical positions when present.
#
check_readme_sections() {
  local readme="$1"
  local failed=0
  local canonical section found

  canonical="$(printf '%s\n' \
    'Interactivity' \
    'How to invoke' \
    'Examples' \
    'Recommended models' \
    'Suggested workflows' \
    'Related skills' \
    'References')"

  # Tolerate extra spaces after the '##' marker, as elsewhere in this script.
  found="$(strip_fences "${readme}" | grep -E '^## +' | sed -E 's/^## +//; s/[[:space:]]+$//')"

  for section in 'Interactivity' 'How to invoke' 'Recommended models'; do
    if grep -qxF "${section}" <<<"${found}"; then
      printf "  [PASS] README.md has '## %s'\n" "${section}" >&2
    else
      printf "  [FAIL] README.md is missing '## %s'\n" "${section}" >&2
      failed=1
    fi
  done

  # Every section must be a known one, and the sections that are present must
  # appear in canonical order. Filtering the canonical list down to what was
  # found gives the expected order to compare against.
  local unknown
  unknown="$(grep -vxF -f <(printf '%s\n' "${canonical}") <<<"${found}" || true)"
  if [[ -n "${unknown}" ]]; then
    printf "  [FAIL] README.md has unrecognized section(s): %s\n" \
      "$(tr '\n' '/' <<<"${unknown}")" >&2
    failed=1
  elif [[ "${found}" == "$(grep -xF -f <(printf '%s\n' "${found}") <<<"${canonical}")" ]]; then
    printf "  [PASS] README.md sections are in canonical order\n" >&2
  else
    printf "  [FAIL] README.md sections are out of order: %s\n" \
      "$(tr '\n' '/' <<<"${found}")" >&2
    failed=1
  fi

  return "${failed}"
}

main "$@"
