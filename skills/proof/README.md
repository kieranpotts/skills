# `/proof`

Proofread prose – Markdown, AsciiDoc, reStructuredText, plain text – making conservative copy edits only: spelling, grammar, punctuation, typos, awkward phrasing, and consistency of terminology and capitalization. Never touches technical meaning, code, or markup. Use when polishing documentation, a README, release notes, or any written content before it ships.

## What it does

`/proof` makes the edits a careful human editor would make on a final pass, and nothing more. It resolves the target files (a file, glob, directory, or – if unstated – the prose files changed in the working tree), detects each file's markup language and line-wrapping convention, and proofreads one file at a time, editing in place. It fixes spelling, grammar, punctuation, and typos; smooths genuinely awkward phrasing where meaning is preserved; and makes terminology and capitalization consistent. It protects the forbidden zones absolutely: code blocks and inline spans, markup syntax and structure, links, identifiers, version numbers, and technical facts – a fact that looks wrong is flagged for the author, never silently "corrected".

It is non-interactive and stops at the edits: it does **not** branch, commit, or open PRs (that's left to the version-control skills), so you can proofread on any branch and commit on your own terms. It reports a per-file summary of what changed.

## How to invoke

```
/proof
/proof docs/
/proof README.md CHANGELOG.md
```

With no argument it proofreads the prose files changed in the working tree (falling back to asking). Otherwise it takes the files, glob, or directory to proofread. It edits in place and prints a summary.

## Examples

Pointed at `docs/`, `/proof` works through each prose file, fixing three typos in one, a subject-verb disagreement in another, and standardizing "web-site" → "website" across the set – then reports the changes grouped by file, naming any files reviewed but left unchanged.

Encountering `--recurse` where `--recursive` looks intended, it leaves the flag unchanged and flags it: "docs/install.md:42 – `--recurse` may be a typo for `--recursive`; left unchanged for author review." A misspelling inside a code span stays verbatim, because it may be a real identifier.
