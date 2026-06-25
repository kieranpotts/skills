# 🧑 `/create-skill`

`/create-skill` = skill authoring. It is the single path for creating or improving a skill, in this collection or a downstream project. It produces a complete skill directory: a `SKILL.md` written from the bundled template, a human-facing `README.md`, any bundled `scripts/` / `references/` / `assets/`, all passing the validator. It also carries the authoring rules — how to write a triggering `description`, when to use instructions vs. rules, how prescriptive to be — that distinguish a reliable skill from one the agent ignores or misapplies.

Use it to create a new skill from scratch, or to improve an existing one. The bundled starting template lives at [`assets/skill-template/skill-name/`](./assets/skill-template/skill-name/), and the validator at [`scripts/validate.sh`](./scripts/validate.sh).

This skill is interactive (🧑). The agent may prompt the user for input.

## How to invoke

- `/create-skill`, `/skill:create-skill` (prompts vary by harness).
- "Create a skill for X."
- "Turn this workflow into a skill."
- "Improve the `<name>` skill."
