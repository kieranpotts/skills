# `/create-skill`

The skill for authoring skills. Use it to create a new skill from scratch, or to improve an existing one.

## What it does

Walks the agent through the full authoring procedure: clarifying intent and trigger conditions, researching the domain, naming and placing the skill, writing a `SKILL.md` from the bundled template, bundling any `scripts/` / `references/` / `assets/`, writing the human-facing `README.md`, reviewing for token efficiency, and validating the result.

It also carries the authoring rules — how to write a triggering `description`, when to use instructions vs. rules, how prescriptive to be — that distinguish a reliable skill from one the agent ignores or misapplies.

Deeper reference material ships alongside the skill and is loaded only when relevant:

- [`references/create-skill-collision-safety.md`](./references/create-skill-collision-safety.md): Namespacing bundled resources so they don't collide across skills.

- [`references/create-skill-requirements-levels.md`](./references/create-skill-requirements-levels.md): The RFC 2119 keywords (MUST, SHOULD, MAY, …) and when to use each.

- [`references/create-skill-preferred-model.md`](./references/create-skill-preferred-model.md). Whether and how to pin a model via `metadata.preferred_model`.

The bundled starting template lives at [`assets/skill-template/skill-name/`](./assets/skill-template/skill-name/), and the validator at [`scripts/validate.sh`](./scripts/validate.sh).

## How to invoke

Ask the agent to create or improve a skill — eg. *"create a skill for X"*, *"draft a skill that does Y"*, *"turn this workflow into a skill"*, or *"improve the `<name>` skill"*. The skill triggers on those phrasings.

## Examples

- **New skill from a description:** *"Create a skill that extracts tables from PDFs."* → a new `pdf-extract/` directory with a `SKILL.md`, `README.md`, and any needed `scripts/`.

- **Capture a workflow:** *"We always do A, then B, then C when releasing — make that a skill."* → a procedural `SKILL.md` encoding the steps, with success criteria.

- **Improve an existing skill:** *"This skill misfires on docs-only PRs — tighten its description."* → a rewritten `description` and any supporting edits, re-validated.
