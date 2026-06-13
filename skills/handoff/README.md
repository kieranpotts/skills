# 🤖 `/handoff`

Compact a conversation for the next session to pick up – an ephemeral handoff document so a fresh agent or human can resume the work. Runs non-interactively (🤖). Use when ending a session, switching agents, approaching context limits, or pausing work someone else will resume.

## What it does

`/handoff` captures just enough state for the next session to continue without repeating work, re-litigating decisions, or re-walking dead ends. It inventories the durable artifacts the work has already produced – specification, design/ADR, plan with step status, issues, PRs, commits, glossary updates – and **references them by path or URL rather than duplicating their content** (duplication rots; if the artifact changes, a copy lies). It drafts a structured document (what's been done, what's open, codebase state, suggested next steps, gotchas), redacts secrets/PII/internal URLs, and writes it to the OS temp directory – never the repo, because a handoff is a session bridge, not a project artifact.

It is non-interactive. It is specific about what's open (the undecided thing and its blocker, not "some questions remain"), suggests next steps rather than dictating them, and never fabricates state to fill the template.

## How to invoke

```
/handoff
/handoff next session continues with the API integration
```

With no argument it covers the full state of the current work; an argument scopes the handoff to the next session's focus. It prints the absolute path of the file it wrote.

## Examples

Ending a session on an orders endpoint, `/handoff` writes `$TMPDIR/handoff-orders-2026-05-26.md`: spec agreed (#482), design as ADR-0007, plan of 6 steps with 1–4 merged, step 5 blocked on SRE sign-off, a `[DEBUG-a4f2]` log still in `handlers/orders.ts:42` to remove, and a warning not to "fix" the deliberately case-sensitive header parsing without reading the relevant commit – then prints the path.

If the session covered two unrelated streams it writes two handoffs; if nothing substantive happened, it says there's nothing to hand off rather than inventing state.
