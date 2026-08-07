---
name: review
description: >-
  Audit a proposed code change against the specification it claims to satisfy
  and the project's own standards, classifying every finding by severity and
  closing with a verdict. Use when reviewing a pull request, auditing a peer's
  branch, or self-reviewing a diff before opening a PR, or when the user says
  something like "review this PR", "review my changes before I push", or
  "check this diff against the spec and our conventions". Do not use it to
  apply the fixes it recommends.
compatibility: >-
  requires Read, Glob, Grep, Bash (git diff, gh)
license: CC0-1.0
---

# Review

Audit a code change for correctness, design, clarity, test coverage,
security, and completeness, classifying every finding as blocking or
non-blocking. Review only: report the findings and stop, changing no code or
configuration yourself.

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
  the change claims to satisfy, plus any captured design decision behind it.

- **The artifact stores — REQUIRED.** Where the specification, the decision
  records, and the project's standards live. Discover each rather than
  assuming it: check this session's context first, then the environment (a
  convention file, a workspace manifest, a configured connector). If none
  settles it, ask the user. A store MAY be a directory in this repository, a
  separate repository, or an external service, so do not assume a filesystem
  path, a file name, or a document structure.

## Success criteria

- Every finding MUST name a file and line, describe the issue, and suggest a
  direction, so the author can act on it without a follow-up conversation.

- Findings MUST be split across two axes, Specification and Standards, kept
  visibly distinct in the output. Each Specification finding MUST quote the
  specification line it tests against; each Standards finding MUST cite the
  standard by file and rule.

- Every finding MUST carry one of the severity labels Blocking, Suggestion,
  Nit, or Praise. An unlabelled comment leaves the author guessing whether
  it gates the merge.

- The review MUST account for all six categories — correctness, design,
  clarity, test coverage, security, completeness — recording an explicit
  "no findings" for any that yielded none, so a skipped category is
  distinguishable from a clean one.

- The review MUST close with one verdict: Approve, Request changes, or
  Comment.

- The working tree MUST be left exactly as found: no file edited, no commit,
  no push, no review thread resolved.

## Instructions

1.  Establish what the change is and why, before reading any code.

    Read the PR description, linked issue, or commit body, and identify the
    acceptance criteria it claims to satisfy along with any captured design
    decision behind it. You MUST NOT reverse-engineer intent from the diff:
    a reviewer who infers the goal from the code can only ever confirm that
    the code does what the code does.

2.  Pin the comparison base, then read the diff in commit order.

    State the base explicitly — a commit SHA, branch name, or tag — because
    "review the PR" is ambiguous once the source branch moves. Capture the
    diff command once, so every later step sees the same change set:

    ```sh
    git diff <base>...HEAD
    ```

    Read commit by commit rather than file by file, so the author's
    intermediate reasoning stays visible.

3.  Check correctness against the acceptance criteria and the design.

    You MUST establish:

    - Whether the change implements what the criteria require.

    - Whether it handles edge cases the criteria imply but do not
      enumerate — empty input, maximum input, null, concurrent calls,
      error paths.

    - Whether the assumptions the code makes about types, ranges,
      ordering, and idempotency are actually guaranteed by its callers.

    - Whether it touches state in a way that could leave the system
      inconsistent if interrupted halfway.

4.  Check design.

    You SHOULD weigh:

    - Whether the change follows the architecture and patterns already
      established, matching nearby files unless it deliberately replaces
      them.

    - Whether each module, function, and class carries one clear
      responsibility.

    - Whether new dependencies, third-party or internal, are justified.

    - Whether it introduces premature abstraction. Three similar lines
      beat one abstraction with a single caller.

5.  Check clarity.

    You SHOULD weigh:

    - Whether a developer unfamiliar with the area could tell what the
      code does and why.

    - Whether names are meaningful and idiomatic for the language.

    - Whether comments explain a non-obvious why, rather than narrating
      what the code already says.

    - Whether dead code, debug logging, commented-out blocks, and TODO
      markers are removed or justified.

6.  Check test coverage.

    You MUST establish:

    - Whether every new behavior has at least one test that would fail if
      the behavior were removed.

    - Whether the tests assert on behavior rather than implementation
      detail.

    - Whether test doubles are used judiciously — real implementations
      where practical, doubles only where needed.

    - Whether each test name describes the behavior rather than the
      method under test.

7.  Check security, wherever the change touches input, authentication,
    persistence, or external calls.

    You MUST establish:

    - Whether inputs are validated at the system boundary.

    - Whether access controls are enforced at the service layer, not
      merely in the UI.

    - Whether sensitive data — personal data, secrets, tokens — is
      encrypted in transit and at rest, kept out of logs, and absent from
      error responses.

    - Whether the change widens the attack surface with a new endpoint,
      file write, shell call, or dependency, and whether that was
      intentional.

8.  Check completeness — whether the change carries everything it needs to
    ship.

    You SHOULD look for documentation updates, new configuration and
    environment variables documented, reversible migrations, feature-flag
    wiring with a cleanup issue behind it, and telemetry for the new
    behavior.

9.  Classify every comment, then write it up.

    Assign one severity to each:

    - Blocking — to be addressed before merge: correctness, security, a
      new behavior with no test, a broken build.

    - Suggestion — would improve the change, acceptable as-is.

    - Nit — stylistic preference, optional.

    - Praise — something done well, called out to reinforce the pattern.

    Group the write-up by axis, Specification and Standards, and keep each
    comment specific enough to act on.

10. Close with one verdict.

    Approve where nothing blocks; Request changes where at least one
    Blocking finding stands; Comment where the feedback is offered but the
    decision belongs to another reviewer.

## Rules

- You MUST discover artifact locations and conventions rather than assume
  them.

  This skill runs across projects that keep specifications, decisions, and
  standards in different places, formats, and tools. A path or template that
  is right in one project is wrong in the next. Resolve each store first,
  then follow whatever conventions that store documents for itself.

- You MUST report findings and stop there.

  Fixing the code, restructuring it, or re-running the system is downstream
  work for someone else. A reviewer who starts editing forfeits the
  independence that makes the review worth having.

- You SHOULD approve at "good enough" rather than hold out for perfect.

  Perfection blocks delivery. Where a comment is genuinely optional, label
  it Suggestion or Nit and approve anyway.

- You SHOULD spend attention where machines cannot help.

  Formatting, lint, and style belong to automated tooling. The
  highest-leverage finding is "you added behavior with no test for it";
  naming nits SHOULD NOT dominate the comment count.

- You MUST NOT bikeshed.

  Personal preference is not feedback. Where a difference is purely
  stylistic and the surrounding code is internally consistent, leave it
  alone.

- Comments MUST address the code, not the author.

  "This is wrong" stings; "this does not handle X" describes the code. Same
  content, different framing.

- You SHOULD ask the author to split a change squashed into a single commit.

  One logical change per commit is the convention. A single squashed commit
  hides intermediate states and drive-by edits.

## Edge cases

- The reviewer is the author.

  Self-review still applies. Run the full procedure over your own diff as
  though it were a stranger's, before anyone else is asked to look. Most of
  the easy findings surface that way.

- The change is very large.

  Stop and ask the author to split it. Review effectiveness falls off
  sharply past a few hundred changed lines — reviewers skim and miss
  issues. An oversized change is a planning failure; say so, and address it
  there.

- The change is an urgent hotfix.

  Apply the same criteria over a narrower scope: correctness and security
  for the fix itself, with non-blocking comments deferred to a follow-up
  issue. Do not skip the review; hotfixes are where defects most often
  regress.

- The author disagrees with a finding.

  Discuss it rather than override it. The goal is a better change, not a
  won argument. Where genuinely stuck, recommend a third reviewer.

- A section of the change is not understood.

  Say so. "I don't follow why X is needed here — can you walk me through
  it?" is a legitimate review comment. Approving code you do not understand
  is how subtle bugs ship.

## Examples

- Labeled comments on a hypothetical diff:

  ```text
  [Blocking] handlers/orders.ts:42
    The new endpoint accepts an `amount` field but does not validate that
    it is positive. A negative amount would currently refund the customer.
    Suggest validating `amount > 0` at the request boundary, returning 400.

  [Suggestion] handlers/orders.ts:67
    The retry loop has no jitter, so under load all retries land in the
    same window. Adding jitter (`base * (0.5 + Math.random())`) would
    smooth them out. Non-blocking; fine as a follow-up.

  [Nit] handlers/orders.ts:91
    `orderRepository` is referenced once and could be inlined. Optional.

  [Praise] handlers/orders.spec.ts:104
    The concurrent-key test using Promise.all is exactly the test this
    endpoint needs.
  ```

- A closing verdict block, organized by axis:

  ```text
  Request changes.

  ## Specification
  - [Blocking] AC-2 requires "amount must be positive" — the handler does
    not validate this (handlers/orders.ts:42). Quoted from issue #482.
  - [No findings] AC-1 (concurrent same-key requests return one row) is
    implemented and tested.

  ## Standards
  - [Suggestion] CONTRIBUTING.md §3.2 requires retries to use jitter; the
    new retry loop has none (handlers/orders.ts:67).
  - [Praise] Test naming follows the project convention.

  Categories: correctness (1 blocking), design (no findings), clarity (no
  findings), test coverage (no findings), security (no findings),
  completeness (1 suggestion).
  ```
