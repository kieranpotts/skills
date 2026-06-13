# `/format`

Apply presentation-only changes – whitespace, indentation, line wrapping, quotes, trailing commas, import ordering – without altering behavior or structure. Use when normalizing style after a feature, fixing CI lint failures, or aligning a file to project conventions.

## What it does

`/format` makes code or content changes that are visually large but semantically empty – a reviewer running `git diff -w` should see nothing. It first confirms the change really is presentation only (and stops to reclassify as a refactor if it isn't), then prefers the project's configured formatter (`.prettierrc`, `.editorconfig`, `black`/`ruff`, `rustfmt`, `gofmt`, a `format` script, a pre-commit hook) over hand-editing. It scopes the run deliberately to keep the diff legible, verifies behavior is unchanged by running the tests (significant-whitespace languages and side-effect imports can break on a "harmless" reformat), and lands the result as its own `format:` commit – never bundled with feature, fix, or refactor work.

It is non-interactive. Crucially, it refuses the "while I'm here" rename or logic tweak: any structural edit – even recasing a constant – is a refactor and belongs in a separate commit. If it had to hand-format, it files a follow-up `maintenance:` task to add the missing automation.

## How to invoke

```
/format
```

Invoke it to normalize style before committing, to clear a CI formatting failure, or to bring a file or directory into line with conventions. Describe or point it at the scope (a file, a directory, the repo); it picks and runs the configured formatter. No other arguments.

## Examples

After a feature lands, `/format` runs `npm run format` on `handlers/` and commits `format: apply prettier to handlers/` as a separate, seconds-to-review diff. Converting tabs to spaces across `src/`, it applies the change via `.editorconfig`, confirms no files outside `src/` changed, and verifies the tests still pass.

While "formatting" `auth.py` it notices `_normalize_token` was renamed to `normalize_token` – that alters the module's public surface, so it reverts the rename and records a `refactor:` follow-up rather than smuggling it into the format commit.
