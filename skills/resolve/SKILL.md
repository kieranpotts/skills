---
name: resolve
description: >-
  Action open review comments. Mark them as resolved. Use after a code review,
  or when the user says something like "action the review comments" or
  "address the feedback on this PR".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/computer-programmer
---

# Resolve

Action the open review comments on a pull request. Implement each fix in
code, verify it, and mark the comment as resolved.

## Input

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements. If you cannot determine the required inputs, stop and alert the
user with an error message.

- A pull request with open review comments — REQUIRED.
  The un-dismissed comments from [review](../review/SKILL.md); the author
  has already resolved any they do not want actioned, so what remains is
  the work list.

- The code under review — REQUIRED. The base commit is pinned.

## Output

A branch with each open comment implemented as a minimal, verified code
change; each thread replied to and marked resolved; the fixes committed and
pushed. Any comment that could not be honestly actioned is left open and
reported with a reason. The verified change is ready for
[test](../test/SKILL.md); what runs next is the orchestrator's concern.

This task runs non-interactively to completion. It does not block for user
input. If in doubt about any of the requirements of this task, stop and print
an error message.

## Instructions

1.  Collect the open comments.

    Pull the full set of unresolved review comments on the PR — the ones
    the author has not dismissed. Use the host's review-thread API:

    ```sh
    gh pr view <number> --json reviewThreads \
      --jq '.reviewThreads[] | select(.isResolved == false)'
    ```

    Capture each thread's comment ID, anchored file and line, and
    requested change. If there are no open comments, report that and stop.

2.  Pin the working base.

    State the branch and base commit you are working against, exactly as
    [review](../review/SKILL.md) pinned its comparison base. If the branch
    has advanced past the reviewed commit, re-anchor each comment to its
    current location before editing.

3.  Order the comments by dependency, not by line.

    Group related comments and sequence them so an earlier fix does not
    invalidate a later one. Structural comments (rename, extract, move)
    usually precede local comments inside the code they touch.

4.  Implement each comment as the smallest faithful change.

    For each open comment, apply exactly the change it asks for. If a
    comment names a concrete fix, apply that fix; if it names a problem
    without a fix, apply the smallest change that resolves the problem in
    the style of the surrounding code.

5.  Verify each fix.

    For correctness findings, add or extend a test that fails before the
    fix and passes after; for missing-test findings, add the missing test;
    otherwise run the existing tests covering the touched code.

6.  Reply, then resolve, each thread.

    For each actioned comment, leave a one-line reply stating what changed
    and where (`Fixed in <sha> — validates amount at the boundary, returns
    400`), then mark the thread resolved:

    ```sh
    gh api graphql -f query='
      mutation($threadId:ID!) {
        resolveReviewThread(input:{threadId:$threadId}) {
          thread { isResolved }
        }
      }' -F threadId=<threadId>
    ```

    If the host has no resolvable-thread API, record the resolution in the
    reply and the commit message instead, and report which comments were
    addressed so a human can close the threads.

7.  Commit the resolutions.

    Commit the fixes with a message that ties them to the review (eg.
    `fix: address review comments on order validation`). Keep the
    resolution work in its own commit(s), separate from the original
    implementation commits. Push the branch.

8.  Report what could not be resolved.

    If any open comment could not be actioned — it contradicts another open
    comment, depends on a decision outside this change, rests on a
    misunderstanding the code cannot satisfy, or asks for a redesign beyond
    the change under review — leave the thread open and report it with a
    specific account of why.

## Rules

- Every open comment MUST be treated as a commitment to implement.

  The author's curation happened before this skill ran. A comment that is
  still open is one the author wants done. Disagreeing with, deferring, or
  rejecting a comment is out-of-scope.

- You MUST make one minimal change per comment.

  You MUST action exactly what the comment asks. You MUST NOT expand
  scope, refactor adjacent code, or fix problems the comment did not
  raise.

- You MUST resolve only what you verified.

  A thread MUST be marked resolved only after its fix is shown to work.

- You MUST reply before you resolve.

  Every resolved thread MUST carry a one-line note of what changed and
  where, so the reviewer can confirm the resolution from the reply.

- You MUST keep resolution commits separate.

  The fixes that answer a review MUST go in their own commit(s),
  distinct from the original implementation.

- You MUST surface, never bury, what you can't resolve.

  A comment that cannot be honestly actioned MUST stay open and MUST be
  reported with a reason. Marking it resolved without a real fix, or
  silently leaving it open, both hide the problem.

## Edge cases

- The branch moved since the review.

  Comments anchored to old line numbers may no longer point at the right
  code. Re-anchor each comment to its current location before editing; if
  a comment's target has been deleted or rewritten by later work, treat
  it as unresolvable and surface it (instruction 8).

- Two open comments contradict each other.

  The author left both open, but they cannot both be satisfied. Do not
  pick one silently. Resolve neither; report the contradiction so the
  author can dismiss one.

- A comment asks for more than a fix — a redesign.

  If actioning a comment would mean restructuring beyond the change
  under review, it is not a resolve-loop task. Surface it as
  out-of-scope for this skill rather than ballooning the diff;
  architecturally significant rework is a separate, upstream
  responsibility.

- A "nit" or "praise" comment is still open.

  A praise comment needs no code change — reply acknowledging it and
  resolve. A nit the author left open is, by the curation rule, one they
  want done: action it like any other.

- The host has no resolvable-thread API.

  Where review threads cannot be marked resolved programmatically (some
  hosts, or plain patch review), record the resolution in the reply and
  the commit message instead, and report which comments were addressed
  so a human can close the threads.

## Success criteria

- Every open comment MUST be dispositioned.

  Each unresolved comment MUST be either resolved (fixed, verified,
  replied, marked resolved) or surfaced as blocked with a reason. None
  MUST be silently skipped.

- Every resolution MUST be verified.

  No thread MUST be marked resolved without a passing test or a run of
  the existing tests over the touched code.

- Every resolved thread MUST have a reply.

  Stating what changed and where, so the reviewer can confirm it without
  re-reading the diff.

- The diff MUST be minimal.

  Each change MUST answer a specific comment. No scope creep, no
  unrequested refactors.

- Resolution work MUST be committed and pushed.

  In its own commit(s), separate from the original implementation, with
  the branch pushed so the re-review and [test](../test/SKILL.md) see
  the fixes.

## Examples

- A resolution pass over three open comments:

  ```sh
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
  3 of 3 open comments resolved. Ready for re-test.
  ```

- A pass that cannot fully resolve:

  ```sh
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

## References

None.
