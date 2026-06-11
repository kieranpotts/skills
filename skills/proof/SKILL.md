---
name: proof
description: Proofread prose - Markdown, AsciiDoc, reStructuredText, plain text - making conservative copy edits only - spelling, grammar, punctuation, typos, awkward phrasing, and consistency of terminology and capitalisation. Never touches technical meaning, code, or markup syntax. Edits in place and reports a summary; committing is left to the version-control skills. Use when polishing documentation, a README, release notes, or any written content before it ships.
license: MIT
---

# Proof

Use this skill to proofread prose - documentation, a README, release notes, comments-as-prose, a design doc, a blog post. It makes the conservative copy edits a careful human editor would make on a final pass: fixing spelling, grammar, punctuation, and typos; smoothing genuinely awkward phrasing; and making terminology and capitalisation consistent. Nothing more.

It is format-aware across the common prose markup languages (Markdown, AsciiDoc, reStructuredText, plain text) - it edits the *prose* and leaves the *markup* and any embedded code untouched.

This skill edits files in place and stops. It does NOT branch, commit, or open pull requests - that is the job of [`branch`](../branch/SKILL.md), [`commit`](../commit/SKILL.md), and your release flow, invoked separately once the edits are reviewed. Keeping proofreading and version control separate lets you proofread on any branch and commit on your own terms.

Do NOT use this skill to:

- Rewrite, restructure, or re-argue content - this is copy editing, not [`refactor`](../refactor/SKILL.md) for prose. Structural change needs a human's intent.
- Edit code, configuration, or data files - it works on prose. Code presentation is [`format`](../format/SKILL.md).
- Translate, localise, or change the register/voice of the writing.
- Change technical facts, even wrong-looking ones (see edge cases).

## Instructions

1.  **Resolve the set of files to proofread.**

    From the user's request, build the list of target files. The target may be a single file, a glob, a directory (recurse it for prose files), or unstated. If unstated, proofread the prose files changed in the working tree (`git status --porcelain`), falling back to asking the user which files if the working tree is clean.

    Include only prose files - by extension `.md`, `.markdown`, `.adoc`, `.asciidoc`, `.rst`, `.txt`, and extensionless prose like `README`, `CHANGELOG`, `LICENSE` text. Skip code, config, lockfiles, and generated files.

2.  **Detect the markup language and the line-wrapping convention per file.**

    Before editing a file, note its format (so you know which syntax to protect) and its existing wrapping style - one-sentence-per-line, hard-wrapped at a column, or unwrapped paragraphs. You will preserve whichever it uses.

3.  **Proofread one file at a time, editing in place.**

    Work through the files individually. For each file, apply the allowed edits below and protect the forbidden zones below. Make the edits directly in the file. After finishing a file, record which changes you made (for the summary) and drop the file from working memory before opening the next - do not re-read a completed file.

4.  **Report a summary and stop.**

    When every target file is processed, print a concise summary grouped by file: for each file that changed, a short bullet list of the kinds of edits made (eg. "3 typos, 1 subject-verb agreement, standardised 'web-site' -> 'website'"). Name any files reviewed but left unchanged. Then stop - do not stage, commit, or push.

## Rules

### Allowed edits

-   **Fix spelling, grammar, punctuation, and obvious typos.**

-   **Smooth genuinely awkward phrasing in prose** - but only where the meaning is unambiguous and preserved. When in doubt, leave it.

-   **Make terminology and capitalisation consistent** within and across the target files (eg. pick one of "GitHub"/"Github", "set up" vs "setup" by part of speech).

-   **Default to the project's established English variety.** Infer it from the surrounding text (eg. "colour"/"color"). If genuinely ambiguous, leave existing spellings and flag the inconsistency in the summary rather than imposing a variety.

### Forbidden - never change

-   **Technical meaning, facts, version numbers, commands, API names, or identifiers.** A factual error is for a human to fix, not a copy editor (see edge cases).

-   **Anything inside code.** Fenced/indented code blocks, inline code spans, and their language-specific equivalents:

    - Markdown: ` ``` ` fences, `~~~` fences, indented blocks, `` `inline` ``.
    - AsciiDoc: `----`, `....`, `[source,...]` blocks, `+inline+`/`` `inline` ``.
    - reStructuredText: `::` literal blocks, `.. code-block::` directives, `` ``inline`` ``.

    Leave code, commands, and sample output verbatim.

-   **Markup syntax and structure.** Links and link targets, image refs, macros, cross-references (`xref:`, `<<>>`, `:ref:`), anchors/IDs, includes, directives, conditionals, comments, attribute/front-matter entries, admonition labels (NOTE:, TIP:, WARNING:, etc.), heading levels, and section ordering.

-   **The file's structure.** Do not add, remove, reorder, merge, or split sections, paragraphs, or list items. Proofreading changes words, not architecture.

### Discipline

-   **One file at a time; do not re-read a finished file.**

    Finish each file before opening the next, and remove it from context once done. This keeps the working set small and the edits focused.

-   **Preserve the existing line-wrapping convention.**

    If the file is one-sentence-per-line, keep it. If it is hard-wrapped at a column, re-wrap edited lines to match. Never reflow the whole file.

-   **Prefer the project's configured formatter for pure whitespace/style.**

    If a deterministic prose linter or formatter is configured (eg. Vale, markdownlint, Prettier for Markdown), pure presentation issues are its job, not this skill's - this skill is for the language-level edits a formatter cannot make. See [`format`](../format/SKILL.md).

-   **Edit in place only.**

    Modify the target files. Do not create new files, rename, move, or touch any file not on the target list.

-   **When a "fix" is really a rewrite, stop and flag it.**

    If correcting something would require changing meaning or structure, do not do it - note it in the summary as a suggestion for the author.

## Edge cases

-   **A technical fact looks wrong.**

    Do not "correct" it. A version number, command flag, or API name that looks off may be deliberate or may be a real bug - either way it is the author's call. Leave it unchanged and flag it in the summary: *"docs/install.md:42 - `--recurse` may be a typo for `--recursive`; left unchanged for author review."*

-   **Mixed English varieties within the corpus.**

    If the files mix British and American spellings and no project convention is discoverable, do not impose one - that is an editorial decision. Report the inconsistency and let the author choose.

-   **A typo appears inside a code span or block.**

    Leave it. Code is verbatim, even when it contains a misspelling - the misspelling may be a real identifier. Flag it in the summary only if it is plausibly prose that was wrongly marked as code.

-   **The target file is generated or vendored.**

    Skip it and say so. Editing generated output is wasted - the fix belongs in the source. Skip anything under conventional generated/vendor paths unless the user explicitly names it.

-   **Front matter and metadata.**

    Proofread human-readable values (a `title:` or `description:`) but never the keys, and never structural metadata (slugs, IDs, dates, tags). When unsure whether a value is prose or data, leave it.

## Success criteria

-   **Only prose changed; code, markup, and structure are byte-identical except where prose words were corrected.**

    A diff shows word-level prose edits and nothing else - no reflowed blocks, no moved sections, no touched code.

-   **No technical fact, identifier, version, or command was altered.**

    Anything that looked wrong was flagged for the author, not silently changed.

-   **The file's markup remains valid and its wrapping convention intact.**

    The document still parses/renders as before; line-wrapping style is unchanged.

-   **A per-file summary of edits was reported, and nothing was committed.**

    The user can see what changed in each file and decide when and how to commit it.

## References

- [`format`](../format/SKILL.md): The presentation-only sibling for *code* (whitespace, ordering, quotes). Proof is the language-level editor for *prose*; format is the whitespace-level normaliser, and prefers configured automated formatters.

- [`refactor`](../refactor/SKILL.md): For *structural* change. If prose needs reorganising or re-arguing rather than copy editing, that is a human-intent task, not this skill.

- [`commit`](../commit/SKILL.md): Invoked separately to commit the proofreading edits once reviewed. Proof deliberately stops short of version control.
