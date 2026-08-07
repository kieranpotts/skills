---
name: proof
description: >-
  Proofread, then conservatively edit, prose for spelling, grammar, and
  consistency. Use when polishing documentation, a README, release notes, or
  any written content before it ships, or when the user says something like
  "proofread this document" or "check this for spelling and grammar". Do not
  use it to rewrite, restructure, or fact-check a document.
compatibility: >-
  requires Read, Edit, Glob, Bash (git status, git diff)
license: CC0-1.0
---

# Proof

Proofread prose, making the conservative copy edits a careful human editor
would make on a final pass — spelling, grammar, punctuation, typos, awkward
phrasing, and consistency of terminology and capitalization. Change words,
never code, markup, structure, or technical meaning.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **A set of prose files — REQUIRED.** Markdown, AsciiDoc, reStructuredText,
  or plain text, given as a file, a glob, or a directory to recurse. When the
  request names no set, default to the prose files changed in the version
  control working tree.

## Success criteria

- The target files MUST have been edited in place, so that the diff shows
  word-level prose edits and nothing else — no reflowed blocks, no moved
  sections, no touched code.

- Every technical fact, identifier, version number, and command MUST read
  exactly as it did before.

- Each edited file MUST still parse and render as it did before, with its
  markup valid and its original line-wrapping convention intact.

- A diff of the working tree MUST show no file created, renamed, deleted, or
  modified beyond the resolved target list.

- A per-file summary MUST have been reported, naming which files changed,
  which were reviewed but left unchanged, which were skipped as generated or
  vendored, and every item flagged for the author to resolve.

- The edits MUST have been left unstaged, uncommitted, and unpushed.
  Proofreading ends at the edit. Filing the change belongs to the caller.

## Instructions

1.  Resolve the set of files to proofread.

    Expand the requested file, glob, or directory into a concrete list,
    recursing directories for prose files. Where the request names no set,
    take the prose files changed in the working tree:

    ```sh
    git status --porcelain
    ```

    Apply the file-selection rules below: prose files only, generated and
    vendored files skipped.

2.  Detect the markup language and the line-wrapping convention per file.

    Before editing a file, note its format, so you know which syntax to
    protect, and its wrapping style — one sentence per line, hard-wrapped at
    a column, or unwrapped paragraphs. Rewrapping a paragraph buries the
    prose edits in a diff nobody can review, so the style MUST survive
    unchanged.

3.  Proofread one file at a time, editing in place.

    For each file, make the allowed edits and protect the forbidden zones.
    Record what you changed for the summary, then drop the file from working
    memory before opening the next — do not re-read a completed file.

4.  Report a summary and stop.

    Print a concise summary grouped by file. For each file that changed, give
    a short bullet list of the kinds of edit made, eg. "3 typos, 1
    subject-verb agreement, standardized 'web-site' to 'website'". Name any
    file reviewed but left unchanged, and any file skipped as generated or
    vendored. List every item flagged for the author. Then stop.

## Rules

- You MAY fix spelling, grammar, punctuation, and obvious typos.

- You MAY smooth genuinely awkward phrasing, but only where the meaning is
  unambiguous and preserved. When in doubt, leave it.

- You SHOULD make terminology and capitalization consistent within and across
  the target files, eg. settle on one of "GitHub" and "Github", or on "set up"
  against "setup" by part of speech.

- You SHOULD follow the project's established variety of English, inferred
  from the surrounding text, eg. "colour" against "color".

- You MUST NOT change technical meaning, facts, version numbers, commands,
  API names, or identifiers.

  A factual error is for a human to fix, not a copy editor. Where a fact
  looks wrong, flag it in the summary instead of correcting it.

- You MUST NOT change anything inside code — fenced or indented blocks,
  inline spans, and their per-format equivalents:

  - Markdown: ` ``` ` and `~~~` fences, indented blocks, `` `inline` ``.

  - AsciiDoc: `----` and `....` blocks, `[source,...]` blocks, `+inline+`,
    `` `inline` ``.

  - reStructuredText: `::` literal blocks, `.. code-block::` directives,
    `` ``inline`` ``.

  Code, commands, and sample output stay verbatim, because a reader will run
  them exactly as written.

- You MUST NOT change markup syntax or structural metadata: links and link
  targets, image references, macros, cross-references (`xref:`, `<<>>`,
  `:ref:`), anchors and IDs, includes, directives, conditionals, comments,
  attribute and front-matter entries, admonition labels, heading levels, and
  section ordering.

- You MUST NOT add, remove, reorder, merge, or split sections, paragraphs, or
  list items. Proofreading changes words, not architecture.

- You MUST edit the target files in place, and MUST NOT create, rename, or
  move any file, nor touch a file that is not on the target list.

- You MUST include only prose files.

  Take them by extension — `.md`, `.markdown`, `.adoc`, `.asciidoc`, `.rst`,
  `.txt` — plus extensionless prose such as `README`, `CHANGELOG`, and
  license text. Skip code, configuration, lockfiles, and data.

- You MUST skip generated and vendored files unless the user names one
  explicitly, and MUST report each skip.

  Editing a generated file loses the edit on the next build, and editing a
  vendored one diverges the copy from upstream.

- When a fix would really be a rewrite, you MUST NOT make it. Note it in the
  summary as a suggestion for the author instead.

  This applies wherever a correction would change meaning or structure.

- You MUST flag, but MUST NOT remove, leftover chatbot artifacts.

  Conversational residue from AI-assisted drafting — "I hope this helps!",
  "Certainly!", "Let me know if you'd like me to expand on this" — does not
  belong in shipped documentation, but removing it is a content edit rather
  than a copy edit. List each instance for the author.

- You MUST flag, but MUST NOT rewrite, overused semicolons and misused
  colons.

  Both are common AI writing smells. A semicolon joining two independent
  clauses can almost always be split into two plain sentences, and a colon
  should introduce a list rather than an explainer clause. Splitting or
  rephrasing changes sentence structure, so it is out of scope — quote each
  instance in the summary.

- You MUST treat front matter and metadata conservatively.

  Proofread human-readable values, such as a title or a description, but
  never the keys, and never structural metadata such as slugs, IDs, dates,
  and tags. Where you are unsure whether a value is prose or data, leave it.

## Edge cases

- No file set is given and the working tree is clean.

  There is nothing to proofread and you MUST NOT prompt for a target. Stop
  and report that no candidate files were found.

- The files mix varieties of English and no project convention is
  discoverable.

  You MUST NOT impose one. Leave the existing spellings, report the
  inconsistency, and let the author choose.

- The project configures a deterministic prose linter or formatter, eg. Vale,
  markdownlint, or a Markdown formatter.

  Pure presentation and whitespace issues are its job. You SHOULD leave them
  alone and confine yourself to the language-level edits a formatter cannot
  make.

- A typo appears inside a code span or block.

  Leave it. You SHOULD flag it only where the content is plausibly prose that
  was wrongly marked up as code.
