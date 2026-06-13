# 🤖 `/plan`

Decompose delivery into stable increments – supporting continuous integration – by breaking a designed change into a sequence of small steps, each independently mergeable, testable, and reversible. Runs non-interactively (🤖). Use after the design is agreed and before any implementation, whenever a change is bigger than a single commit or touches multiple seams.

## What it does

`/plan` decomposes an agreed design into a numbered checklist of deliverable steps. It restates the goal and constraints, finds the thinnest first end-to-end slice (a walking skeleton, the riskiest integration, or a feature-flagged path) to anchor the plan, then decomposes the rest so each step is independently mergeable, independently testable, reversible, and small (reviewable in under 30 minutes). It orders **by risk, not by ease** – the unknowns first, polish last – names the seams where flags, fixtures, or migrations decouple steps, and pressure-tests the result (if step N fails, can N+1 still merge? if we stop after step K, is the system coherent?). Each step gets a mode tag (`AFK` vs `HITL`), a stated pass/fail signal, and any prior-step dependency.

It is non-interactive and produces only the plan – no code. The plan is the script for the downstream build loop, consumed one step at a time, and is revisable as each step teaches more.

## How to invoke

```
/plan
```

Invoke it once the design is captured (and sharpened, if needed) and the change is larger than one atomic commit. It takes the agreed design and the ACs it must deliver; no other arguments.

## Examples

For "add a POST /orders endpoint with idempotency", `/plan` produces six risk-ordered steps: scaffold the route with a stubbed 501, add a reversible migration, implement the handler, add idempotency-key handling, enable the endpoint behind an `ORDERS_API_V2` flag (tagged `HITL` – needs SRE sign-off), then remove the flag after rollout. Each carries its pass/fail signal.

Given three steps – wire a new billing SDK, add a settings UI, update checkout copy – it orders them SDK-first, so an SDK incompatibility surfaces on day one rather than after the UI and copy work are already merged and wasted.
