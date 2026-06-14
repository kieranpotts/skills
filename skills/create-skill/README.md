# 🧑 `/create-skill`

Author or improve a skill – in this collection or a downstream project. The skill for authoring skills. Interactive (🧑). Use it to create a new skill from scratch, or to improve an existing one.

## What it does

`/create-skill` is the single authoring path for skills – in this collection or a downstream project. It produces a complete skill directory: a `SKILL.md` written from the bundled template, a human-facing `README.md`, any bundled `scripts/` / `references/` / `assets/`, all passing the validator. It also carries the authoring rules — how to write a triggering `description`, when to use instructions vs. rules, how prescriptive to be — that distinguish a reliable skill from one the agent ignores or misapplies.

The bundled starting template lives at [`assets/skill-template/skill-name/`](./assets/skill-template/skill-name/), and the validator at [`scripts/validate.sh`](./scripts/validate.sh).

## How to invoke

Ask the agent to create or improve a skill. It is interactive – expect a back-and-forth as it clarifies intent and trigger conditions.

- `/create-skill`, `/skill:create-skill` (prompt varies by agent harness).
- "Create a skill for X."
- "Turn this workflow into a skill."
- "Improve the `<name>` skill."
