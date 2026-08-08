# Proof

The **proof** skill proofreads, then conservatively edits, prose for spelling,
grammar, and consistency.

The agent is instructed to make the edits a careful human editor would make on
a final pass, and nothing more, across Markdown, AsciiDoc, reStructuredText,
and plain text. It fixes spelling, grammar, punctuation, and typos; smooths
genuinely awkward phrasing where the meaning is preserved; and makes
terminology and capitalization consistent, editing in place one file at a
time.

The agent is instructed to leave code, markup syntax, links, identifiers,
version numbers, and technical facts untouched. Anything that would amount to
a rewrite — restructuring, deleting chatbot residue, unpicking a semicolon —
is reported for the author rather than done.

The agent stops at the edits. It does not stage or commit anything.

## Interactivity

This skill instructs the agent to run non-interactively. It never blocks for
user input, so it suits away-from-keyboard workflows such as a pre-release
pass or a CI job. Where it cannot work out what to proofread — no files named
and a clean working tree — it stops with an error rather than asking.

## How to invoke

> Proofread this document.

> Check this for spelling and grammar.

> Proofread the docs I've changed.

Name a file, a glob, or a directory to set the target. With no target named,
the skill proofreads the prose files changed in the working tree.

## Recommended models

A small, fast model is sufficient. The work is bounded, mechanical, and
governed by an explicit list of allowed and forbidden edits, so it does not
warrant a frontier reasoning model.

## Related skills

- [**style**](../style/) \
  Normalizes the presentation of a document, while this skill corrects its
  language. Run both on documentation, in either order, as separate changes.
