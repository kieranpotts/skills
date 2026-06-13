# `/resolve`

Clear the open review comments on a pull request: implement each one in code, verify it, and mark the comment resolved. The counterpart to [`/review`](../review/) – review posts the comments, `/resolve` actions them.

## What it does

`/resolve` takes the comments a review left open on a PR and turns each into a verified code change.

It assumes the author has already curated the review: between `/review` and `/resolve`, the author dismisses any comments they disagree with or want to defer. So `/resolve` does not negotiate or reject – every comment still open is one to implement. For each, it makes the smallest faithful change, verifies it (a passing test, or the existing tests over the touched code), replies on the thread with what changed, and marks the thread resolved. Fixes land in their own commit, separate from the original implementation, so each review round stays legible in the history.

It runs non-interactively. Anything it genuinely cannot action – a comment that contradicts another, depends on a decision outside the change, or assumes code that isn't there – is left open and reported with a reason, never silently skipped.

## How to invoke

Invoke `/resolve` on a pull request once a review has posted its comments and the author has dismissed the ones they don't want actioned:

```
/resolve
/resolve PR #482
```

It needs the PR's open review threads (read via the host API) and the branch under review checked out. No arguments adjust its behavior – it actions every open comment it finds.

## Examples

Given a PR with three open comments – a missing boundary validation, a retry loop without jitter, and a single-use variable to inline – `/resolve` implements all three, adds a test for the validation, runs the existing tests for the others, replies on each thread, marks them resolved, and commits the lot as `fix: address review comments on order validation`. It reports "3 of 3 open comments resolved. Ready for re-test."

Where a comment can't be honestly actioned – say it asks to use a shared component that doesn't exist in the codebase – `/resolve` leaves that thread open and surfaces it: "1 of 2 resolved; 1 surfaced as blocked," with the reason, so the author can build the component or withdraw the comment.
