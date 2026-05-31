---
name: review
description: Audit a code change for correctness, design, clarity, test coverage, security, and completeness. Classify every finding as blocking or non-blocking. Use when reviewing a pull request, auditing a peer's branch, or self-reviewing changes before opening a PR.
license: MIT
---

# Review

Use this skill when auditing a pull request, reviewing a peer's branch, or self-reviewing a change before opening a PR for others.

Do NOT use this skill to verify acceptance criteria end-to-end (use [`test`](../test/SKILL.md), which runs after review) or to investigate a failing test (use [`debug`](../debug/SKILL.md)). Review evaluates the *change as a piece of work* against static qualities; [`test`](../test/SKILL.md) then evaluates the *running system* against dynamic qualities.

If review surfaces a stylistic or presentational issue, fix it via [`format`](../format/SKILL.md). If it surfaces an internal-quality issue that needs structural work, hand off to [`refactor`](../refactor/SKILL.md) - which may in turn loop back to [`design`](../design/SKILL.md) if the change is architecturally significant.

## Instructions

1.  **Understand what the change is and why.**

    Before reading any code:

    - Read the PR description, linked issue, or commit body.
    - Identify the acceptance criteria (or the specification) it claims to satisfy.
    - Note the [`design`](../design/SKILL.md) decision behind it, if one was captured.

    If the *why* is unclear from the description, ask the author. Do not reverse-engineer intent from the diff - reviewers who do that miss the cases where the diff does not match the intent.

2.  **Pin the comparison base, then read the diff in commit order.**

    Before reading anything, state the comparison base explicitly - a commit SHA, branch name, tag, or `main`. "Review the PR" is ambiguous when the source branch may have shifted; "review HEAD against `dev` as of abc123" is not. Capture the diff command once (eg. `git diff <base>...HEAD` for three-dot, merge-base comparison) so every subsequent step references the same set of changes.

    Read the diff in commit order, not file-by-file. Commit-ordered reading reveals the author's thought process, exposes intermediate states, and surfaces drive-by edits hiding inside larger commits. File-by-file reading hides this.

    If the branch is a single squashed commit, ask the author to split it - one logical change per commit is a [`commit`](../commit/SKILL.md) convention.

3.  **Check correctness.**

    Against the ACs and the design:

    - Does the change implement what the AC requires?
    - Does it handle edge cases the AC implies but doesn't enumerate (empty input, max input, null, concurrent calls, error paths)?
    - Are the assumptions in the code (about types, ranges, ordering, idempotency) actually guaranteed by the callers?
    - Does the change touch state in a way that could leave the system inconsistent if interrupted halfway?

4.  **Check design.**

    - Does the change follow the architecture and patterns established in the codebase? Match the style of nearby files unless the change is deliberately replacing them.
    - Is the module decomposition cohesive? Each module/function/class has one clear responsibility?
    - Are new dependencies (third-party, internal) justified? Could the change have been made without adding them?
    - Does it introduce premature abstractions? Three similar lines is better than one abstraction with one caller.

5.  **Check clarity.**

    - Could a developer unfamiliar with this area understand *what* the code does and *why*?
    - Are names meaningful and idiomatic?
    - Are comments adding value (explaining a non-obvious *why*) rather than narrating *what* the code does?
    - Are dead code, debug logs, commented-out blocks, and `TODO` markers removed or justified?

6.  **Check test coverage.**

    - Does every new behavior have at least one test that fails when the behavior is removed?
    - Do tests assert on meaningful behavior, not implementation details?
    - Are test doubles used judiciously - real implementations where practical, doubles only where needed?
    - Is the test name a description of the behavior, not the method?

7.  **Check security.**

    For any change that touches input, auth, persistence, or external calls:

    - Are inputs validated at the system boundary?
    - Are access controls enforced - not just at the UI, but at the service layer?
    - Is sensitive data (PII, secrets, tokens) handled appropriately - encrypted at rest/in transit, never logged, not exposed in error responses?
    - Does the change widen the attack surface (new endpoint, new file write, new shell call, new dependency)? If so, was that intentional?

8.  **Check completeness.**

    Does the change include everything it needs to ship?

    - Documentation updates (README, API docs, runbook).
    - Configuration / environment variable additions, documented.
    - Migration scripts, reversible.
    - Feature-flag wiring, with a cleanup tracking issue.
    - Telemetry / logs for the new behavior.

9.  **Classify and write findings.**

    Every comment gets a severity label:

    - *Blocking*: MUST be addressed before merge (correctness, security, missing tests for new behavior, breaks the build).
    - *Suggestion*: would improve the change but is acceptable as-is.
    - *Nit*: stylistic preference, optional.
    - *Praise*: explicitly noting something well done. Reinforces good patterns.

    Each comment is specific and actionable. "This is wrong" is unhelpful; "This does not handle the case where `items` is empty - consider an early return" is actionable.

10. **Conclude with an explicit verdict.**

    - *Approve*: ship it; no blocking comments.
    - *Request changes*: at least one blocking comment.
    - *Comment*: feedback offered, but decision deferred to another reviewer.

    Approve when the code is *good enough*, not when it is perfect. Every change is an increment, not a final draft.

## Rules

-   **Organize findings into two axes: Specification and Standards.**

    A change can pass one axis and fail the other:

    - Code that follows every standard but implements the wrong thing → *Standards pass, Specification fail.*
    - Code that does exactly what the issue asked but breaks the project's conventions → *Specification pass, Standards fail.*

    *Specification axis*: does the change faithfully implement the originating issue, ACs, or PRD? Covers correctness and completeness. Quote the specification line for each finding.

    *Standards axis*: does the change conform to the repo's documented standards - CLAUDE.md, CONTRIBUTING.md, ADRs, naming conventions, architectural patterns? Covers design, clarity, test style, and security idioms. Cite the standard (file + rule) for each finding.

    Keep the axes distinct in the review output - don't merge them. Reporting them separately stops one axis from masking the other.

-   **Approve at "good enough", not "perfect".**

    Holding out for perfection blocks delivery and signals that the reviewer's preference outranks the change's purpose. If a comment is genuinely optional, label it Suggestion or Nit and approve.

-   **Distinguish blocking from non-blocking explicitly.**

    Unlabelled comments leave the author guessing what must change. Every comment carries a severity.

-   **Focus on what machines can't check.**

    Style, formatting, and lint issues belong to automated tooling. Spend human attention on correctness, design, security, and clarity.

-   **Do not bikeshed.**

    Personal preference is not feedback. If a difference is purely stylistic and the existing code is consistent, leave it alone.

-   **Review promptly.**

    A delayed review blocks integration, forces the author to context-switch, and stale diffs grow harder to merge. Aim to complete within one working day; if you can't, say so so the author can find another reviewer.

-   **Comments are about the code, not the author.**

    "This is wrong" stings; "This does not handle X" describes the code. Same content, different framing.

-   **Catch the missing test, not the missing tab.**

    The highest-leverage review finding is "you added behavior with no test for it". Lower-leverage findings (style, naming nits) should not dominate the comment count.

-   **Self-review is the same skill.**

    Run the full procedure on your own diff before opening the PR. Most of the easy findings can be fixed before another human sees them.

## Examples

A labelled comment set on a hypothetical diff:

```
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

Verdict block to close the review, organized by axis:

```
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

## Edge cases

-   **Reviewer is the author.**

    Self-review still applies. Open the diff and run the full procedure as if it were a stranger's. Most easy findings will surface.

-   **The change is huge.**

    Stop and ask the author to split it. Reviews of >~400 LOC become ineffective - reviewers skim and miss issues. A large change is a [`plan`](../plan/SKILL.md) failure; address it there.

-   **The change is urgent (hotfix).**

    Apply the same criteria but accept narrower scope: correctness + security for the fix itself, with a follow-up issue for non-blocking comments. Don't skip review just because it's urgent - hotfixes are where defects most often regress.

-   **Author disagrees with a finding.**

    Discuss, don't override. The goal is a better change, not a "won" argument. If genuinely stuck, pull in a third reviewer.

-   **You don't understand a section.**

    Say so. "I don't follow why X is needed here - can you walk me through it?" is a legitimate review comment. Approving code you don't understand is how subtle bugs ship.

## Success criteria

-   **The *why* of the change is understood before any code is read.**

    Description, linked issue, design notes - all consulted first.

-   **Every comment carries a severity label.**

    Blocking, Suggestion, Nit, or Praise. No bare comments.

-   **Findings are specific and actionable.**

    Each comment names the file/line, describes the issue, and suggests a direction.

-   **Correctness, design, clarity, test coverage, security, and completeness are all considered.**

    Even if a category has no findings, it has been thought about.

-   **The verdict is explicit.**

    Approve, Request changes, or Comment. Not implied.

## References

<!--

TODO: Reinstate TS-* cross-references when those are republished.

- [TS-7: Code Review](https://github.com/kieranpotts/standards/tree/dev/ts/007): The standard this skill is derived from. Read for purpose, what-to-review, how-to-review, pair-programming.

-->

- [`specify`](../specify/SKILL.md): The source of truth for "does this do what it should do".

- [`test`](../test/SKILL.md): Downstream of review - verifies the running system. Review evaluates static qualities; test evaluates dynamic ones.

- [`format`](../format/SKILL.md): Sidecar for presentation-only findings (whitespace, style, ordering).

- [`refactor`](../refactor/SKILL.md): For findings that require structural change. May escalate further to [`design`](../design/SKILL.md) if architecturally significant.

- [`audit`](../audit/SKILL.md): Different scope - proactively scans the whole codebase for structural problems, rather than evaluating a specific diff.

- [`commit`](../commit/SKILL.md): One logical change per commit - relevant when asking authors to re-split a squashed PR.
