# 🤖 `/format`

<!-- Input: existing code branch. Outcome: non-deterministic (subjective) formatting rules applied. -->

Improve code presentation – whitespace, style, ordering, line wrapping, quotes, trailing commas, import order – without changing structure or behavior. Runs non-interactively (🤖). Use when normalizing style after a feature, fixing CI lint failures, or aligning a file to project conventions.

```mermaid
flowchart LR
  code["🤖 /code"]:::primary
  format["🤖 /format"]:::tertiary

  code <-.-> format

  classDef primary fill:#cce5ff,stroke:#004085,color:#004085,stroke-width:2px
  classDef tertiary fill:#fff3cd,stroke:#856404,color:#856404,stroke-width:1px,stroke-dasharray:2 3
```

## What it does

`/format` makes code or content changes that are visually large but semantically empty – a reviewer running `git diff -w` should see nothing. It prefers the project's configured formatter over hand-editing, verifies behavior is unchanged by running the tests, and lands the result as its own `format:` commit – never bundled with feature, fix, or refactor work.

It is non-interactive. Crucially, it refuses the "while I'm here" rename or logic tweak: any structural edit – even recasing a constant – is a refactor and belongs in a separate commit.

## How to invoke

Invoke it to normalize style before committing, to clear a CI formatting failure, or to bring a file or directory into line with conventions. Point it at the scope (a file, a directory, the repo).

- `/format`, `/skill:format` (prompt varies by agent harness).
- "Format this file."
- "Fix the formatting / lint errors."
- "Tidy up the whitespace and style here."
