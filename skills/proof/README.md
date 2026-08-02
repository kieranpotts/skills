# Proof

The **proof** skill is all about proofreading, then conservatively editing,
text for spelling, grammar, and consistency. It makes the edits
a careful human editor would make on a final pass, and nothing more, across
Markdown, AsciiDoc, reStructuredText, and plain text. It fixes spelling, grammar,
punctuation, and typos; smooths genuinely awkward phrasing where meaning is
preserved; and makes terminology and capitalization consistent, editing in place
one file at a time. It protects the forbidden zones absolutely: code, markup
syntax, links, identifiers, version numbers, and technical facts — a fact that
looks wrong is flagged for the author, never silently "corrected".

Use it when polishing documentation, a README, release notes, or any written
content before it ships. With no argument it proofreads the prose files changed
in the working tree (falling back to asking); otherwise point it at a file, glob,
or directory. Where it overlaps with **[style](../style/)**, the division is clear:
**style** normalizes presentation, **proof** corrects language.

This skill instructs the agent to run non-interactively, and stops at the edits:
it does **not** branch, commit, or open PRs, so you can proofread on any branch
and commit on your own terms. It reports a per-file summary of what changed.

## How to invoke

> Proofread this document.

> Check this for spelling and grammar.

## Recommended models

Proofreading is precise but shallow work — spelling, grammar, consistency — with
no technical judgment involved. A small, fast model is sufficient and often
preferable, since it won't second-guess or rewrite content beyond the brief.

## Related skills

- **[style](../style/):** normalizes presentation, where this skill corrects
  language — the two divide the polish pass between them.
