---
name: resolve
description: >-
  Action the open review comments on a pull request, implementing each fix,
  verifying it, and marking the thread resolved. Use after a code review, or
  when the user says something like "action the review comments", "address
  the feedback on this PR", or "resolve the open review threads". Do not use
  it to triage, dismiss, or argue with comments — everything still open is
  implemented.
compatibility: >-
  requires Read, Write, Edit, Grep, Bash (git, review host CLI, test runner)
license: CC0-1.0
---

# Resolve

Action the open review comments on a pull request. Implement each fix in
code, verify it, reply, and mark the thread resolved. Stop there: judging
whether the comments were worth making is not part of this task.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the requirements, stop and alert the
user with an error message.

- **The pull request under review — REQUIRED.** The change whose open
  comments are to be actioned. Discover it from the last prompt, then from
  recent context (the review that produced the comments), then from the
  environment — the branch currently checked out and the pull request open
  against it.

- **The review host — REQUIRED.** Where the comment threads live and how to
  read and write them. Discover this from the environment: the remote the
  branch pushes to, and the host CLI or API available in the workspace. You
  MUST NOT assume a particular host, because not every host exposes
  resolvable threads.

- **The code under review — REQUIRED.** The branch, and the base commit the
  comments are anchored to. Take the base from the review itself rather than
  assuming the branch tip, since the branch MAY have advanced since.

## Success criteria

- Every open comment MUST be dispositioned: either resolved — fixed,
  verified, replied to, thread marked resolved — or left open and reported
  as blocked with a specific reason. None MUST be silently skipped.

- Every thread marked resolved MUST have a passing verification behind it: a
  test that fails before the fix and passes after, or a green run of the
  existing tests covering the touched code.

- Every resolved thread MUST carry a reply naming what changed and where, so
  the reviewer can confirm the fix without re-reading the diff.

- The diff MUST contain nothing that no open comment asked for. Unrequested
  refactors, drive-by fixes, and formatting churn are out-of-scope.

- The resolution work MUST sit in its own commit(s), distinct from the
  commits under review, and the branch MUST be pushed so re-review and CI
  see the fixes.

- The pull request MUST be left open and in review. It MUST NOT be merged,
  closed, or otherwise advanced — the verified change is handed back to the
  caller.

## Instructions

1.  Collect the open comments.

    Query the review host for the comment threads that are not resolved.
    Where the host is GitHub:

    ```sh
    gh pr view <number> --json reviewThreads \
      --jq '.reviewThreads[] | select(.isResolved == false)'
    ```

    Capture each thread's identifier, anchored file and line, and requested
    change. If there are no open comments, report that and stop.

2.  Pin the working base.

    State the branch and the base commit you are working against, matching
    the base the review anchored its comments to. If the branch has advanced
    past that commit, re-anchor each comment to its current location before
    editing anything.

3.  Order the comments by dependency, not by line number.

    Group related comments and sequence them so an earlier fix does not
    invalidate a later one. Structural comments (rename, extract, move)
    usually precede local comments inside the code they touch.

4.  Implement each comment as the smallest faithful change.

    Where a comment names a concrete fix, apply that fix. Where it names a
    problem without a fix, apply the smallest change that resolves the
    problem, in the style of the surrounding code.

5.  Verify each fix.

    For a correctness finding, add or extend a test that fails before the
    fix and passes after. For a missing-test finding, add the missing test.
    Otherwise, run the existing tests covering the touched code.

6.  Reply, then resolve, each thread.

    Leave a one-line reply stating what changed and where (`Fixed in <sha> —
    validates amount at the boundary, returns 400`), then mark the thread
    resolved. Where the host is GitHub:

    ```sh
    gh api graphql -f query='
      mutation($threadId:ID!) {
        resolveReviewThread(input:{threadId:$threadId}) {
          thread { isResolved }
        }
      }' -F threadId=<threadId>
    ```

7.  Commit the resolutions.

    Commit the fixes with a message tying them to the review, eg. `fix:
    address review comments on order validation`. Keep this work in its own
    commit(s), separate from the commits under review, then push the branch.

8.  Report the outcome.

    Report how many open comments were resolved, and list any that were not,
    each with a specific account of why it could not be actioned.

## Rules

- You MUST treat every still-open comment as a commitment to implement.

  The author's curation happened before this skill ran; a comment that is
  still open is one the author wants done. Disagreeing with, deferring, or
  dismissing a comment is out-of-scope.

- You MUST NOT widen a comment into a broader change.

  Action exactly what the comment asks. Adjacent code that could be improved
  is a separate concern, and mixing it in makes the re-review harder than
  the original review.

- You MUST NOT mark a thread resolved as a way of closing out a comment you
  could not action. Leave it open and report it instead — a falsely resolved
  thread hides the problem from the one person able to settle it.

- You SHOULD prefer the host's own resolve mechanism over any local record
  of the work, so that the reviewer's unresolved-thread count is accurate.

- You MAY reorder or batch the fixes as step 3 dictates, but each comment
  MUST end up individually replied to, so the reply stays traceable to the
  comment it answers.

## Edge cases

- The branch moved since the review.

  Comments anchored to old line numbers may no longer point at the right
  code. Re-anchor each comment to its current location before editing. If a
  comment's target has been deleted or rewritten by later work, treat it as
  unresolvable and surface it.

- Two open comments contradict each other.

  The author left both open, but they cannot both be satisfied. Do not pick
  one silently. Resolve neither, and report the contradiction so the author
  can dismiss one.

- A comment asks for a redesign rather than a fix.

  If actioning it would mean restructuring beyond the change under review,
  it is not a resolution task. Surface it as out-of-scope rather than
  ballooning the diff; architecturally significant rework is a separate,
  upstream responsibility.

- A nit or a praise comment is still open.

  A praise comment needs no code change: reply acknowledging it and resolve.
  A nit the author left open is, by the curation rule, one they want done —
  action it like any other comment.

- The review host has no resolvable-thread API.

  Where threads cannot be marked resolved programmatically, record the
  resolution in the reply and in the commit message instead, and report
  which comments were addressed so a human can close the threads.

## Examples

- A resolution pass over three open comments:

  ```text
  Open comments on PR #482 (base abc123): 3

  [handlers/orders.ts:42]  validate amount > 0, return 400
    → Added boundary check + test orders.spec.ts:51 (fails before, passes
      after). Replied + resolved.

  [handlers/orders.ts:67]  retry loop needs jitter
    → Added jitter `base * (0.5 + Math.random())`. Existing retry test
      green. Replied + resolved.

  [handlers/orders.ts:91]  inline single-use orderRepository
    → Inlined. Existing tests green. Replied + resolved.

  Committed as `fix: address review comments on order validation` (def456).
  3 of 3 open comments resolved.
  ```

- A pass that cannot fully resolve:

  ```text
  Open comments on PR #482: 2

  [handlers/orders.ts:42]  validate amount > 0
    → Fixed + verified. Replied + resolved.

  [handlers/orders.ts:80]  "this should use the shared RateLimiter"
    → NOT RESOLVED. No shared RateLimiter exists in this codebase; the
      comment assumes a component that isn't present. Left open, flagged
      for the reviewer — needs either the component built (separate work)
      or the comment withdrawn.

  1 of 2 resolved; 1 surfaced as blocked.
  ```
