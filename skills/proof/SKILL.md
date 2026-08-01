---
name: proof
description: >-
  Proofread, then conservatively edit, text for spelling, grammar, and
  consistency. Use when polishing documentation, a README, release notes, or
  any written content before it ships, or when the user says something like
  "proofread this document" or "check this for spelling and grammar".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/technical-writer
---

# Proof

Proofread prose, making conservative copy edits — spelling, grammar,
punctuation, typos, awkward phrasing, and consistency of terminology and
capitalization.

You MUST NOT change code examples or technical meaning.

## Input

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- A set of prose files — REQUIRED.
  Markdown, AsciiDoc, reStructuredText, or plain text. Defaults to the
  prose files changed in the working tree when no set is given.

## Output

The same files, edited in place with conservative copy edits only — prose
words corrected, code/markup/structure untouched — plus a per-file summary
of the edits made and any items flagged for the author. Nothing is staged,
committed, or pushed; version control is left to a separate step.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and
print an error message.

## Instructions

1.  Resolve the set of files to proofread.

    From the user's request, build the list of target files. The target
    may be a single file, a glob, a directory (recurse it for prose files),
    or unstated. If unstated, proofread the prose files changed in the
    working tree (`git status --porcelain`). If the working tree is clean,
    ask the user which files to review.

    Apply the file-selection Rules: include only prose files and skip
    generated or vendored files.

2.  Detect the markup language and the line-wrapping convention per file.

    Before editing a file, note its format (so you know which syntax to
    protect) and its existing wrapping style — one-sentence-per-line,
    hard-wrapped at a column, or unwrapped paragraphs. Keep the wrapping
    style unchanged.

3.  Proofread one file at a time, editing in place.

    Work through the files individually. For each file, apply the allowed
    edits in the Rules section and protect the forbidden zones in the Rules
    section. Make the edits directly in the file. After finishing a file,
    record which changes you made (for the summary) and drop the file from
    working memory before opening the next — do not re-read a completed
    file.

4.  Report a summary and stop.

    When every target file is processed, print a concise summary grouped
    by file: for each file that changed, a short bullet list of the kinds
    of edits made (eg. "3 typos, 1 subject-verb agreement, standardized
    'web-site' → 'website'"). Name any files reviewed but left unchanged
    and any files skipped as generated or vendored. Then stop — do not
    stage, commit, or push.

## Rules

### Allowed edits

- You MAY fix spelling, grammar, punctuation, and obvious typos.

- You MAY smooth genuinely awkward phrasing in prose — but only where the
  meaning is unambiguous and preserved. When in doubt, leave it.

- You SHOULD make terminology and capitalization consistent within and
  across the target files (eg. pick one of "GitHub"/"Github", "set up" vs
  "setup" by part of speech).

- You SHOULD default to the project's established English variety. Infer
  it from the surrounding text (eg. "colour"/"color"). If genuinely
  ambiguous, leave existing spellings and flag the inconsistency in the
  summary rather than imposing a variety.

### Forbidden — never change

- You MUST NOT change technical meaning, facts, version numbers, commands,
  API names, or identifiers. A factual error is for a human to fix, not a
  copy editor. If a fact looks wrong, flag it in the summary rather than
  correcting it.

- You MUST NOT change anything inside code. Fenced/indented code blocks,
  inline code spans, and their language-specific equivalents:

  - Markdown: ` ``` ` fences, `~~~` fences, indented blocks, `` `inline`
    ``.
  - AsciiDoc: `----`, `....`, `[source,...]` blocks, `+inline+`/``
    `inline` ``.
  - reStructuredText: `::` literal blocks, `.. code-block::` directives,
    `` ``inline`` ``.

  Leave code, commands, and sample output verbatim. If a typo appears
  inside a code span or block, leave it and flag it in the summary only if
  it is plausibly prose that was wrongly marked as code.

- You MUST NOT change markup syntax and structure. Links and link
  targets, image refs, macros, cross-references (`xref:`, `<<>>`,
  `:ref:`), anchors/IDs, includes, directives, conditionals, comments,
  attribute/front-matter entries, admonition labels (NOTE:, TIP:,
  WARNING:, etc.), heading levels, and section ordering.

- You MUST NOT change the file's structure. You MUST NOT add, remove,
  reorder, merge, or split sections, paragraphs, or list items.
  Proofreading changes words, not architecture.

### File selection

- You MUST include only prose files.

  By extension `.md`, `.markdown`, `.adoc`, `.asciidoc`, `.rst`, `.txt`,
  and extensionless prose like `README`, `CHANGELOG`, `LICENSE` text. Skip
  code, config, lockfiles, and generated files.

- You MUST skip generated or vendored files.

  Skip anything under conventional generated/vendor paths unless the
  user explicitly names it. Report that they were skipped.

### Discipline

- You SHOULD prefer the project's configured formatter for pure
  whitespace/style.

  If a deterministic prose linter or formatter is configured (eg. Vale,
  markdownlint, Prettier for Markdown), pure presentation issues are its
  job, not this skill's — this skill is for the language-level edits a
  formatter cannot make.

- You MUST edit in place only.

  Modify the target files. You MUST NOT create new files, rename, move,
  or touch any file not on the target list.

- When a "fix" is really a rewrite, you MUST stop and flag it.

  If correcting something would require changing meaning or structure,
  you MUST NOT do it — note it in the summary as a suggestion for the
  author.

- You MUST flag, but NOT remove, leftover chatbot artifacts.

  Conversational residue from AI-assisted drafting — "I hope this helps!",
  "Certainly!", "Let me know if you'd like me to expand on this", "You're
  absolutely right that" — does not belong in shipped documentation.
  Removing it is a content edit, not a copy edit, so list each instance in
  the summary for the author to remove rather than deleting it yourself.

- You MUST flag, but NOT rewrite, overused semicolons and misused colons.

  Both are common AI writing smells. A semicolon joining two independent
  clauses can almost always be split into two plain sentences; a colon
  should only ever introduce a list, never an explainer clause. Splitting
  or rephrasing changes sentence structure, so it is out of scope for this
  skill's edits — flag each instance (with the sentence) in the summary as
  a suggestion for the author.

- You MUST treat front matter and metadata conservatively.

  Proofread human-readable values (a `title:` or `description:`) but
  never the keys, and never structural metadata (slugs, IDs, dates,
  tags). When unsure whether a value is prose or data, leave it.

- If the files mix British and American spellings and no project
  convention is discoverable, you MUST NOT impose one.

  Report the inconsistency and let the author choose.

## Success criteria

- Only prose MUST have changed; code, markup, and structure MUST be
  byte-identical except where prose words were corrected.

  A diff shows word-level prose edits and nothing else — no reflowed
  blocks, no moved sections, no touched code.

- No technical fact, identifier, version, or command MUST have been
  altered.

  Anything that looked wrong MUST have been flagged for the author, not
  silently changed.

- The file's markup MUST remain valid and its original line-wrapping
  convention MUST be unchanged.

  The document still parses/renders as before; line-wrapping style is
  unchanged.

- A per-file summary of edits MUST have been reported, and nothing MUST
  have been committed.

  The summary MUST report which files changed, which were reviewed but
  left unchanged, and which were skipped as generated or vendored. The
  user can see what changed and decide when and how to commit it.

- Generated or vendored files MUST have been skipped and reported.

## References

None.
