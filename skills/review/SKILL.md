---
name: review
description: >-
  Evaluate code for style conventions and pattern consistency. Use when
  reviewing a pull request, auditing a peer's branch, or self-reviewing
  changes before opening a PR, or when the user says something like "review
  this PR", "review my changes before I push", or "check this diff against the
  spec and our conventions".
license: CC0-1.0
metadata:
  interactive: no
  preferred_model: ollama/CODE_STANDARD
---

# Review

Audit a code change for correctness, design, clarity, test coverage,
security, and completeness. Classify every finding as blocking or
non-blocking.

Review only. You MUST NOT make any code or configuration changes to the
software itself.

## Parameters

Determine the following information from the surrounding context and
environment. You MUST NOT prompt the user for clarification on this task's
requirements; if you cannot determine them, stop and alert the user with an
error message. You MAY prompt solely to establish where an artifact lives or
how to access it, when context and environment do not settle it.

- **A code change to audit — REQUIRED.** A pull request, a peer's branch, or
  one's own diff before opening a PR. The comparison base is pinned
  explicitly.

- **The specification to check against — REQUIRED.** The acceptance criteria
  the change claims to satisfy, plus any captured design decision.

- Where the specification, the decision store, and the project's standards
  live — REQUIRED. Discover these rather than assuming them: check this
  session's context first, then the environment (a convention file such as
  `AGENTS.md`, a workspace manifest, a configured connector). If none settles
  it, ask the user. Each MAY be a directory in this repository, a separate
  repository, or an external service — do not assume a filesystem path, a
  file name, or a document structure.

This task otherwise runs non-interactively to completion. You MUST NOT
prompt the user about the substance of the task; if in doubt about that,
stop and print an error message. You MAY prompt solely to establish where an
artifact lives or how to access it, when context and environment do not
settle it.

## Success criteria

You will achieve the following outcomes:

- A set of findings, each carrying a severity label (Blocking, Suggestion,
  Nit, Praise) and organized along two axes (Specification and Standards),
  closed with an explicit verdict (Approve, Request changes, or Comment).

- Review reports its findings and stops; acting on them — fixing
  presentation, restructuring, re-running the system — is a separate,
  downstream responsibility.

- Findings MUST be organized into two axes: Specification and Standards.

  The two axes MUST be kept distinct in the review output.

- Every comment MUST carry a severity label.

  Blocking, Suggestion, Nit, or Praise. There MUST be no bare
  comments.

- Every finding MUST be specific and actionable.

  Each comment MUST name the file/line, describe the issue, and
  suggest a direction.

- The verdict MUST be explicit.

  Approve, Request changes, or Comment. It MUST NOT be implied.

## Instructions

1.  Understand what the change is and why.

    Read the PR description, linked issue, or commit body. Identify the
    acceptance criteria (or the specification) it claims to satisfy. Note
    any captured design decision behind it. If the why is unclear from
    the description, ask the author.

2.  Pin the comparison base, then read the diff in commit order.

    State the comparison base explicitly — a commit SHA, branch name,
    tag, or `main`. Capture the diff command once (eg. `git diff
    <base>...HEAD` for three-dot, merge-base comparison) so every
    subsequent step references the same set of changes. Read the diff in
    commit order, not file-by-file.

3.  Check correctness.

    Check, against the ACs and the design:

    - Does the change implement what the AC requires?

    - Does it handle edge cases the AC implies but doesn't enumerate
      (empty input, max input, null, concurrent calls, error paths)?

    - Are the assumptions in the code (about types, ranges, ordering,
      idempotency) actually guaranteed by the callers?

    - Does the change touch state in a way that could leave the system
      inconsistent if interrupted halfway?

4.  Check design.

    Check:

    - Does the change follow the architecture and patterns established
      in the codebase? Match the style of nearby files unless the change
      is deliberately replacing them.

    - Is the module decomposition cohesive? Each module/function/class
      has one clear responsibility?

    - Are new dependencies (third-party, internal) justified? Could the
      change have been made without adding them?

    - Does it introduce premature abstractions? Three similar lines is
      better than one abstraction with one caller.

5.  Check clarity.

    Check:

    - Could a developer unfamiliar with this area understand what the
      code does and why?

    - Are names meaningful and idiomatic?

    - Are comments adding value (explaining a non-obvious why) rather
      than narrating what the code does?

    - Are dead code, debug logs, commented-out blocks, and `TODO`
      markers removed or justified?

6.  Check test coverage.

    Check:

    - Does every new behavior have at least one test that fails when
      the behavior is removed?

    - Do tests assert on meaningful behavior, not implementation
      details?

    - Are test doubles used judiciously — real implementations where
      practical, doubles only where needed?

    - Is the test name a description of the behavior, not the method?

7.  Check security.

    For any change that touches input, auth, persistence, or external
    calls, check:

    - Are inputs validated at the system boundary?

    - Are access controls enforced — not just at the UI, but at the
      service layer?

    - Is sensitive data (PII, secrets, tokens) handled appropriately —
      encrypted at rest/in transit, never logged, not exposed in error
      responses?

    - Does the change widen the attack surface (new endpoint, new file
      write, new shell call, new dependency)? If so, was that
      intentional?

8.  Check completeness.

    Check that the change includes everything it needs to ship:

    - Documentation updates (README, API docs, runbook).

    - Configuration / environment variable additions, documented.

    - Migration scripts, reversible.

    - Feature-flag wiring, with a cleanup tracking issue.

    - Telemetry / logs for the new behavior.

9.  Classify and write findings.

    Assign every comment a severity label:

    - Blocking: to be addressed before merge (correctness, security,
      missing tests for new behavior, breaks the build).

    - Suggestion: would improve the change but is acceptable as-is.

    - Nit: stylistic preference, optional.

    - Praise: explicitly noting something well done. Reinforces good
      patterns.

    Write each comment to be specific and actionable.

10. Conclude with an explicit verdict.

    Choose one of:

    - Approve: ship it; no blocking comments.

    - Request changes: at least one blocking comment.

    - Comment: feedback offered, but decision deferred to another
      reviewer.

## Rules

- You MUST discover artifact locations and conventions; you MUST NOT assume
  them.

  This skill is used across projects that keep their artifacts in different
  places, in different formats, under different tools. A path, file name,
  template, or lifecycle state that is right in one project is wrong in the
  next. Resolve each store first, then read and follow whatever conventions
  it documents for itself.

- You MUST understand the why before reading code.

  The description, linked issue, and design notes MUST be consulted
  first. You MUST NOT reverse-engineer intent from the diff.

- You MUST read the diff in commit order against a pinned base.

  "Review the PR" is ambiguous when the source branch may have shifted;
  the base MUST be explicit.

- You SHOULD ask the author to split a single squashed commit.

  One logical change per commit is the convention; a single squashed
  commit hides intermediate states and drive-by edits.

- You MUST keep findings organized into two axes: Specification and
  Standards.

  A change can pass one axis and fail the other. You MUST quote the
  specification line for each Specification finding and cite the standard
  (file + rule) for each Standards finding. You MUST NOT merge the
  axes.

- You SHOULD approve at "good enough", not "perfect".

  Holding out for perfection blocks delivery. If a comment is genuinely
  optional, label it Suggestion or Nit and approve.

- You MUST distinguish blocking from non-blocking explicitly.

  Every comment MUST carry a severity label.

- You SHOULD focus on what machines can't check.

  Style, formatting, and lint issues belong to automated tooling. You
  SHOULD spend human attention on correctness, design, security, and
  clarity.

- You MUST NOT bikeshed.

  Personal preference is not feedback. If a difference is purely
  stylistic and the existing code is consistent, you MUST leave it
  alone.

- You SHOULD review promptly.

  A delayed review blocks integration, forces the author to
  context-switch, and stale diffs grow harder to merge. You SHOULD aim
  to complete within one working day; if you can't, you SHOULD say so
  so the author can find another reviewer.

- Comments MUST be about the code, not the author.

  "This is wrong" stings; "This does not handle X" describes the code.
  Same content, different framing.

- You MUST catch the missing test, not the missing tab.

  The highest-leverage review finding is "you added behavior with no
  test for it". Lower-leverage findings (style, naming nits) SHOULD NOT
  dominate the comment count.

- Self-review MUST apply the same skill.

  You MUST run the full procedure on your own diff before opening the
  PR. Most of the easy findings can be fixed before another human sees
  them.

- You MUST consider correctness, design, clarity, test coverage,
  security, and completeness.

  Even if a category has no findings, it MUST have been thought about.

## Edge cases

- Reviewer is the author.

  Self-review still applies. Open the diff and run the full procedure
  as if it were a stranger's. Most easy findings will surface.

- The change is huge.

  Stop and ask the author to split it. Reviews of >~400 LOC become
  ineffective — reviewers skim and miss issues. A large change is a
  planning failure; address it there.

- The change is urgent (hotfix).

  Apply the same criteria but accept narrower scope: correctness +
  security for the fix itself, with a follow-up issue for non-blocking
  comments. Don't skip review just because it's urgent — hotfixes are
  where defects most often regress.

- Author disagrees with a finding.

  Discuss, don't override. The goal is a better change, not a "won"
  argument. If genuinely stuck, pull in a third reviewer.

- You don't understand a section.

  Say so. "I don't follow why X is needed here — can you walk me
  through it?" is a legitimate review comment. Approving code you
  don't understand is how subtle bugs ship.

## Examples

- A labeled comment set on a hypothetical diff:

  ```sh
  [Blocking] handlers/orders.ts:42
    The new endpoint accepts an `amount` field but doesn't validate it's
    positive. A negative amount would currently refund the customer.
    Suggest: validate `amount > 0` at the request boundary and return 400.

  [Suggestion] handlers/orders.ts:67
    The retry loop has no jitter — under load all retries will land in the
    same window. Adding jitter (`base * (0.5 + Math.random())`) would
    smooth retries. Non-blocking; we can do it in a follow-up.

  [Nit] handlers/orders.ts:91
    `orderRepository` is referenced once — could be inlined. Optional.

  [Praise] handlers/orders.spec.ts:104
    The concurrent-key test using Promise.all is exactly the kind of test
    this endpoint needs. Nice.
  ```

- Verdict block to close the review, organized by axis:

  ```sh
  Request changes.

  ## Specification
  - [Blocking] AC-2 requires "amount must be positive" — the handler
    does not validate this (handlers/orders.ts:42). Quoted from
    issue #482, AC-2.
  - [PASS]    AC-1 (concurrent same-key requests return one row) is
    implemented and tested.

    ## Standards
  - [Suggestion] CONTRIBUTING.md §3.2 requires retries to use jitter;
    the new retry loop has none (handlers/orders.ts:67).
  - [Praise]   Test naming follows the project convention in
    CLAUDE.md §"Tests".

    Summary: 1 Specification blocker, 1 Standards suggestion. Re-review needed
    on the Specification finding; Standards finding non-blocking.
    ```

## References

None.
