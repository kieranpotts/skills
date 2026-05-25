# Overview

This repository captures a curated collection of skills, rules, instructions, and custom prompts for use by AI agents.

Each skill includes:

- A list of use cases.
- Step-by-step instructions.
- Practical examples and edge cases.
- Technical references and domain-specific notes.

A Bash script is included to automate the installation of the skills for different AI agents – currently Claude, Pi, Cursor, and Copilot. Alternatively, you can install these skills using Vercel's [skills.sh CLI](https://www.skills.sh/), which supports a [much wider range of agents](https://www.skills.sh/agent).

When installed via the custom installer, every skill is generated with Cursor's `alwaysApply` set to `true` and Copilot's `applyTo` set to `"**"`, so all skills are always in scope. You may need to tune the targeting per-project. (Skills installed via the skills.sh CLI follow that tool's own defaults.)

Skills are written for token-efficiency, to moderate the size of the context window and thereby improve output quality.
