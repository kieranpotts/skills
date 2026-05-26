# ✨ Skills [![skills.sh](https://skills.sh/b/kieranpotts/skills)](https://skills.sh/kieranpotts/skills)

A carefully-curated collection of agentic workflow skills – also known as rules, instructions, commands, and custom prompts, depending on the agent harness.

[**Browse the skills here 👉**](./skills/)

## 📓 Overview

This repository encapsulates a minimal suite of agent skills to support AI-assisted and agentic software development processes. The skills focus on universal phases of the software development lifecycle – specifying, designing, planning, coding, testing, reviewing, branching, committing, releasing – plus a small number of cross-cutting skills that support those phases – issue triage and session handoff, for example. Because these steps recur in every software project, regardless of the business domain or technology stack, these skills are designed to be installed at a global level – either in the user's home directory or a workspace root.

These skills are intended to be used with agents tailored for software development workflows, and models trained for computer programming tasks. Claude, Copilot, Cursor, and Pi are supported out-of-the-box. The [built-in installer](./run/install) transforms the source files, which are written to conform to the [Agent Skills](https://agentskills.io/) standard, into the proprietary formats used by Copilot (`.github/instructions/*.instructions.md`) and Cursor (`.cursor/rules/*.mdc`). All other mainstream agents are supported by using Vercel's [skills.sh installer](https://github.com/vercel-labs/skills).

The skills are designed to be small and composable to optimise token consumption. A key design goal is to balance context size with achieving consistent outcomes across models and agents.

The skills are unashamedly opinionated. Each skill enforces the use of methods and tools that reflect the author's preferred – and somewhat idiosyncratic – ways of working. Examples: Gherkin for acceptance criteria, ADRs for design decisions, trunk-based source control with occasional `temp/*` and `epic/*` branches, and so on. These choices are documented more existensively in the author's [technical standards](https://github.com/kieranpotts/standards) and [product development playbook](https://github.com/kieranpotts/playbook).

So you should treat this collection of skills as a baseline, not a framework. Fork the repository, copy individual skills, and use them as a starting point to write your own custom skills that encode your own workflow conventions.

A curated collection of skills – also known as rules, instructions, and custom prompts – for use by AI tools.

A bundled shell script automates installation for Claude Code, Cursor, GitHub Copilot, and Pi. All other agents are supported via Vercel's [skills.sh CLI](https://www.skills.sh/docs/cli).

<!--

## Skills

**Workflow skills**:

| Skill name     | Description                                 |
| -------------- | ------------------------------------------- |
| `spec`         | Specify requirements as acceptance criteria |
| `design`       | Explore architecture options and trade-offs |
| `plan`         | Break delivery into small increments        |
| `code`         | Write code and tests for one step           |
| `test`         | Verify the full solution againt the ACs     |
| `review`       | Audit code for security, consistency, etc.  |
| `refactor`     | Improve internal code quality               |

**Version control skills**:

| Skill name     | Description                                 |
| -------------- | ------------------------------------------- |
| `branch`       | Git branching strategy                      |
| `commit`       | Commit message conventions                  |
| `release`      | Release trunks and branches                 |
| `commit`       | Tagging version points                      |

**Other skills**:

| Skill name     | Description                                 |
| -------------- | ------------------------------------------- |
| `create-skill` | A skill to create new skills                |

-->

[**➡️ Browse the skills**](./skills/)

## 📓 Documentation

- [**Overview**](./docs/overview.md)
- [**Installation**](./docs/installation.md)
- [**Creating skills**](./docs/creating-skills.md)
- [**Publishing to skills.sh**](./docs/publishing.md)

-----

Copyright © 2026-present Kieran Potts, [MIT license](./LICENSE.txt)
