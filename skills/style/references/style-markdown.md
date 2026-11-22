# Markdown conventions

...

Read this when normalizing Markdown content in a project that configures no
formatter for it. The project's own conventions win over these.

## Baseline

- Target CommonMark. GitHub Flavored Markdown extensions, such as tables and
  task lists, MAY be used where the renderer supports them. Avoid extensions
  that other renderers would degrade.

- Use the `.md` extension.

- Use frontmatter only in files consumed by a tool that requires it. The opening
  `---` MUST be the first line.

## Headings

- Use ATX headings (`#`), never setext underlines. Put one space after the
  number signs and a blank line before and after.

- Use a single level 1 heading as the document title.

- Increase heading levels one step at a time. Never skip a level.

- Give each heading unique, descriptive text.

## Lists

- Indent nested items and continuation blocks to align with the first character
  of the parent item's text, consistently throughout the list. A fenced code
  block inside an item uses the same indent.

- Separate items written as full sentences with a blank line. Short items MAY be
  kept tight.

- Number short, stable ordered lists sequentially. Long or frequently edited
  ones MAY repeat `1.`.

## Code

- Use fenced code blocks with a language identifier, or `plaintext` where none
  applies.

- Where a block contains a fenced block, make the outer fence longer, eg. four
  backticks.

## Tables

- Put a pipe at the start and end of each row, and keep each row on one source
  line.

- Escape a literal pipe in a cell as `\|`, including inside inline code.

## Inline content

- Apply emphasis to words or short phrases, not whole paragraphs.

- Use a hard line break only where a break is semantically required, such as in
  an address. Write it as a trailing backslash, not as two trailing spaces,
  which formatters strip.

- Wrap prose as the project does. Where it documents no rule, keep one
  paragraph per source line.
