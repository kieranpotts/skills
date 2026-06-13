# `/review`

Audit a code change for correctness, design, clarity, test coverage, security, and completeness, classifying every finding as blocking or non-blocking. Use when reviewing a pull request, auditing a peer's branch, or self-reviewing changes before opening a PR.

## What it does

`/review` evaluates a change as a *piece of work* against static qualities – it does not run the system end-to-end (that's verification) or chase a failing test (that's diagnosis). It understands the *why* before reading any code (description, linked issue, design notes), pins the comparison base explicitly, and reads the diff in commit order to follow the author's thinking and catch drive-by edits. It checks correctness, design, clarity, test coverage, security, and completeness, then writes findings that are specific and actionable, each carrying a severity – Blocking, Suggestion, Nit, or Praise. Findings are organized along two axes kept distinct: **Specification** (does it faithfully implement the issue/ACs, quoting the spec line) and **Standards** (does it conform to the repo's documented conventions, citing file and rule). It closes with an explicit verdict: Approve, Request changes, or Comment.

It is non-interactive and surfaces findings without fixing them – fixing, restructuring, and re-running are downstream responsibilities. It approves at "good enough", not "perfect", and aims human attention at what machines can't check (correctness, design, security), not at style nits.

## How to invoke

```
/review
```

Invoke it on a PR, a peer's branch, or your own diff before opening a PR. Self-review runs the identical procedure. Give it the change and the spec/ACs it claims to satisfy; it pins the base itself if not told.

## Examples

On a new orders endpoint, `/review` posts a `[Blocking]` finding that `amount` isn't validated as positive (a negative amount would refund the customer, citing AC-2), a `[Suggestion]` that the retry loop lacks jitter (citing CONTRIBUTING.md §3.2), a `[Nit]` to inline a single-use variable, and `[Praise]` for a concurrent-key test – then closes "Request changes" with the findings grouped under Specification and Standards.

If the change exceeds ~400 LOC, it stops and asks the author to split it, since reviews of large diffs degrade to skimming.
