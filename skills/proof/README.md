# Proof

The **proof** skill is all about proofreading, then conservatively editing,
text for spelling, grammar, and consistency.

The agent is instructed to makes the edits a careful human editor would make on
a final pass, and nothing more, across Markdown, AsciiDoc, reStructuredText,
and plain text. It fixes spelling, grammar, punctuation, and typos; smooths
genuinely awkward phrasing where meaning is preserved; and makes terminology
and capitalization consistent, editing in place one file at a time.

The agent is instructed to avoid changing code, markup syntax, links,
identifiers, version numbers, and technical facts.

The agent stops at the edits. It does not commit anything.

## Interactivity

This skill instructs the agent to run non-interactively.

## How to invoke

> Proofread this document.

> Check this for spelling and grammar.

## Recommended models

A small, fast model is sufficient for this task.

## Related skills

- **[style](../style/).** Normalizes presentation, while this skill corrects
  language.
