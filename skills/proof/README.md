# 🤖 `/proof`

Proofread, then conservatively edit text content for spelling, grammar, and consistency – across Markdown, AsciiDoc, reStructuredText, and plain text, fixing typos and awkward phrasing and standardizing terminology and capitalization. Never touches technical meaning, code, or markup. Runs non-interactively (🤖). Use when polishing documentation, a README, release notes, or any written content before it ships.

## What it does

`/proof` makes the edits a careful human editor would make on a final pass, and nothing more. It fixes spelling, grammar, punctuation, and typos; smooths genuinely awkward phrasing where meaning is preserved; and makes terminology and capitalization consistent, editing in place one file at a time. It protects the forbidden zones absolutely: code, markup syntax, links, identifiers, version numbers, and technical facts – a fact that looks wrong is flagged for the author, never silently "corrected".

It is non-interactive and stops at the edits: it does **not** branch, commit, or open PRs, so you can proofread on any branch and commit on your own terms. It reports a per-file summary of what changed.

## How to invoke

With no argument it proofreads the prose files changed in the working tree; otherwise point it at a file, glob, or directory.

- `/proof`, `/skill:proof` (prompt varies by agent harness).
- `/proof docs/`, `/proof README.md CHANGELOG.md`
- "Proofread this document."
- "Check this for spelling and grammar."

With no argument it proofreads the prose files changed in the working tree (falling back to asking). Otherwise it takes the files, glob, or directory to proofread. It edits in place and prints a summary.
