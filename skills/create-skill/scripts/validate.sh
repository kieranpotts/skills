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
Usage: validate.sh <skill_dir>

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
    printf "  Install with: pip install skills-ref\n" >&2
    return 0
  fi

  if skills-ref validate "${skill_dir}"; then
    return 0
  fi
  return 1
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

  # '## Parameters' and '## Success criteria' must come first, in that order,
  # before any other '##' heading.
  first_two="$(grep -E '^## +' "${skill_md}" | head -2 | sed -E 's/^## +//')"
  expected="$(printf 'Parameters\nSuccess criteria')"
  if [ "${first_two}" = "${expected}" ]; then
    printf "  [PASS] '## Parameters' then '## Success criteria' lead the body\n" >&2
  else
    printf "  [FAIL] First two sections must be '## Parameters' then '## Success criteria'\n" >&2
    printf "         Found: %s\n" "$(echo "${first_two}" | tr '\n' '/')" >&2
    failed=1
  fi

  # There must be no separate output section — it is absorbed by the
  # success criteria.
  if grep -qE '^## +Output\b|^\*\*Output\*\*:' "${skill_md}"; then
    printf "  [FAIL] Has an output section; fold it into '## Success criteria'\n" >&2
    failed=1
  else
    printf "  [PASS] No separate output section\n" >&2
  fi

  # Inline bold is reserved for the '## Parameters' leads. Flag bold-lead
  # bullets appearing anywhere after the success criteria heading.
  bold_after="$(awk '/^## +Success criteria/{f=1} f && /^- +\*\*/{c++} END{print c+0}' "${skill_md}")"
  if [ "${bold_after}" -eq 0 ]; then
    printf "  [PASS] Inline bold confined to '## Parameters'\n" >&2
  else
    printf "  [WARN] %d bold-lead bullet(s) after '## Success criteria'\n" "${bold_after}" >&2
    printf "         Rules, criteria, and examples should be plain prose\n" >&2
  fi

  check_preferred_model "${skill_md}" || failed=1

  return "${failed}"
}

#
# The human-facing README.md carries a fixed set of sections, in a fixed
# order. 'Interactivity', 'How to invoke', 'Recommended models', and 'Related
# skills' are required; 'Examples', 'Suggested workflows', and 'References'
# are optional, but must sit in their canonical positions when present.
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
  found="$(grep -E '^## +' "${readme}" | sed -E 's/^## +//; s/[[:space:]]+$//')"

  for section in 'Interactivity' 'How to invoke' 'Recommended models' 'Related skills'; do
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

#
# 'metadata.preferred_model' names a model that must actually exist. The
# vocabulary is not hard-coded: it is read from `ollama list` where Ollama is
# installed, else from the modelfiles repo. Where neither is available the
# check is skipped rather than guessed at.
#
model_vocabulary() {
  if command -v ollama >/dev/null 2>&1; then
    # Strip the ':tag' suffix; 'PROSE_DEEP:latest' is 'PROSE_DEEP'.
    if ollama list 2>/dev/null | awk 'NR > 1 && NF { sub(/:.*/, "", $1); print $1 }' | grep -q .; then
      ollama list 2>/dev/null | awk 'NR > 1 && NF { sub(/:.*/, "", $1); print $1 }'
      return 0
    fi
  fi

  # Fall back to the modelfiles repo, checked at its conventional siblings of
  # this collection. Each subdirectory of a dist tree is one model.
  local here candidate
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  for candidate in \
    "${MODELFILES_DIR:-}" \
    "${here}/../../../../../modelfiles/default" \
    "${here}/../../../../modelfiles" \
    "${HOME}/dev/personal/kieranpotts/modelfiles/default"; do
    [[ -n "${candidate}" && -d "${candidate}/dist/default" ]] || continue
    find "${candidate}/dist/default" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
    return 0
  done

  return 1
}

check_preferred_model() {
  local skill_md="$1"
  local declared vocabulary

  # Read only the front matter, so prose mentioning the field is not matched.
  declared="$(awk '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { exit }
    infm && /^[[:space:]]+preferred_model:[[:space:]]*/ {
      sub(/^[[:space:]]*preferred_model:[[:space:]]*/, ""); print; exit
    }' "${skill_md}")"

  if [[ -z "${declared}" ]]; then
    printf "  [PASS] No 'preferred_model' declared (optional)\n" >&2
    return 0
  fi

  if ! vocabulary="$(model_vocabulary)"; then
    printf "  [SKIP] Cannot check 'preferred_model' — no 'ollama' and no modelfiles repo\n" >&2
    return 0
  fi

  # 'ollama/PROSE_DEEP' names the 'PROSE_DEEP' model on the ollama
  # provider. Compare on the model name alone.
  local model="${declared##*/}"
  if grep -qxF "${model}" <<<"${vocabulary}"; then
    printf "  [PASS] preferred_model '%s' exists\n" "${declared}" >&2
    return 0
  fi

  printf "  [FAIL] preferred_model '%s' is not an available model\n" "${declared}" >&2
  printf "         Available: %s\n" "$(tr '\n' ' ' <<<"${vocabulary}")" >&2
  return 1
}

main "$@"
