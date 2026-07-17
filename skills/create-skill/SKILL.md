---
name: create-skill
description: >-
  Create a new skill or improve an existing one, in this skills collection or
  any downstream project. Use when the user asks to create, write, draft, add,
  or update a skill, or wants to capture a workflow as a reusable skill, or
  when the user says "create a skill for X", "turn this workflow into a skill",
  or "improve the <name> skill".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/technical-writer
---

# Create skill

Create a new skill or improve an existing one, either in this skills collection
or a downstream project.

**Input:**

- A description of the skill to create, or a path to an existing skill
  to improve. REQUIRED.

- The purpose of the skill. REQUIRED.

- Trigger conditions. REQUIRED.

- Target project in which to install the skill. OPTIONAL. If not explicitly
  specified, if the current working directory is inside a Git repository, assume
  that is the target project, else install in the user's home directory at
  `$HOME/.agents/skills/<skill-name>/`.

Gather as much of this information as possible from the surrounding context.
Prompt the user for anything that's missing or unclear.

**Output:**

A complete skill directory, including a `SKILL.md` file conforming to the
bundled template, a sibling `README.md` for humans, and any bundled assets,
references, and scripts. All artifacts pass the validator.

## Instructions

1.  **Clarify the scope and target project for the skill.**

    You MUST establish what the skill should do and when it should trigger
    before drafting anything. Extract as much as you can from the conversation
    before asking questions. At minimum, understand the task, trigger
    situations, expected input and output, and any hard constraints or edge
    cases.

2.  **Research the domain.**

    Before writing, you SHOULD gather relevant context. Look up tool
    documentation, check the project for similar existing skills, and
    identify any scripts or reference files that ought to be bundled. Come
    prepared so you can minimize questions to the user.

3.  **Choose a name and location.**

    You MUST identify the target directory for installation. If not
    explicitly specified, is the current working directory under a Git
    directory? If so, assume the root directory of the Git repository is the
    target. If not, assume the user's home directory is the target — for
    global installation of the new skill.

    Under the target directory, the skill file MUST be installed at
    `.agents/skills/<skill-name>/SKILL.md`.

    Skill names MUST be kebab-case and SHOULD be meaningful actions or verbs,
    eg. "specify", "commit", "release", "review"). Prefer single verbs, but
    use `<verb>-<noun>` when disambiguation is needed, eg."create-skill".

4.  **Write the `SKILL.md` file.**

    You MUST use the [bundled template](./assets/skill-template/skill-name/SKILL.md)
    and MUST include the sections, front-matter, and formatting required by
    the rules below.

5.  **Bundle supporting files if needed.**

    Add files to `scripts/`, `references/`, or `assets/` when the skill
    needs them.

    You MUST include instructions in `SKILL.md` for when and how to run any
    scripts, load any references, or extract any assets.

    You SHOULD namespace every bundled file to avoid collisions when the skill
    is installed alongside others. See the collision safety instructions,
    [here](./references/create-skill-collision-safety.md).

6.  **Write the `README.md`.**

    You MUST use the [bundled template](./assets/skill-template/skill-name/README.md).

    This is human-readable documentation. Describe what the skill does, how to
    invoke it, and provide invocation examples.

7.  **Review the draft.**

    You SHOULD re-read the completed `SKILL.md` with fresh eyes. Check for
    unnecessary verbosity, redundant rules, or instructions that assume too
    much. Trim anything that isn't pulling its weight.

8.  **Validate the skill.**

    You MUST run the bundled validator against the new skill directory:

    ```sh
    scripts/validate.sh <path/to/new-skill-dir>
    ```

    The script wraps `skills-ref validate` (if installed) for canonical Agent
    Skills checks, and adds repo-specific checks.

    You MUST fix any reported failures before finishing.

## Rules

- **The `description` field is the primary trigger mechanism.**
  It determines when an agent invokes the skill. You SHOULD err toward
  being explicit rather than brief. You MUST follow this two-sentence
  pattern, written in the third person:

  1. First sentence — what the skill does.
  2. Second sentence — `Use when ...` followed by specific triggers (user
     phrasings, situations, file types, contexts).

  ```
  ✅ Good:
  Extract text and tables from PDF files, forms, or documents. Use when
  working with PDF files or when the user mentions PDFs, forms, or
  document extraction.

  ❌ Bad:
  Helps with documents.
  ```

- **`SKILL.md` MUST include the canonical sections.**

  - **Front-matter:** `name` and `description` are REQUIRED. `compatibility`
    and `license` are OPTIONAL. Under `metadata`, a skill MAY pin a model via
    `preferred_model` and MAY declare `interactive: no` if it never blocks on
    the user.

  - **Description:** Immediately after the level 1 heading, which is the title
    of the skill, include a short one or two sentence description of the
    skill's purpose. This MAY be copied from the first part of the header
    description.

  - **Input/output:** Immediately after the description, describe the input
    and output — what the skill consumes, produces, and whether it blocks
    for user input. Be explicit about the circumstances in which the agent
    may prompt for user input.

  - **Instructions** or **Rules:** MUST include at least one of these two
    sections.

  - **Edge cases:** Potential edge cases to warn about. OPTIONAL.

  - **Success criteria:** Evaluation criteria against which the agent can
    mark its own homework. Include deterministic scripts — eg. linters, other
    validators — that the agent can run, if possible. REQUIRED.

  - **Examples:** A small number of canonical input/output examples. OPTIONAL.

  - **Assets:** Static assets, such as templates, that the agent MAY use to
    help it to compose its output. OPTIONAL.

  - **References:** Additional reference material, such as coding standards,
    the agent can load on-demand. For each, specify a trigger condition.
    OPTIONAL.

  Sections MAY be reordered as appropriate to maximize the effectiveness of
  the skill.

- **Keep instructions and rules separate.**
  Instructions are ordered steps — the procedural workflow the agent follows.
  Rules are individual, non-sequential guidelines, recommendations, and
  constraints. You MUST keep them separate. You MUST NOT embed rules inside
  instructions, or instructions inside rules.

- **Use RFC 2119 keywords consistently.**
  Mark requirement levels with MUST, SHOULD, MAY, etc. See
  [requirements levels](./references/create-skill-requirements-levels.md)
  for the allowed subset of RFC 2119 keywords.

  Every instruction, rule, and success criterion MUST be built around one
  of these keywords, stated explicitly. For example, rather than writing
  "run the validator before finishing", be explicit in the requirement level
  by writing "you MUST run the validator before finishing". A step with no
  requirement level is ambiguous about whether it can be skipped or
  varied.

- **Explain the _why_ behind non-obvious requirements.**
  Instead of bare imperatives, explain the reasoning so the agent can apply
  judgment in edge cases. When multiple approaches are valid, prefer
  explaining the _purpose_ over prescribing exact steps.

- **Match prescriptiveness to fragility.**
  Be prescriptive — exact commands, flags, ordering — when operations are
  fragile, consistency is critical, or a specific sequence must be followed.
  Otherwise, avoid enumerating every edge case in the body. Instead, handle
  genuinely tricky edge cases in the edge cases section or a separate
  `references/` file.

  Simple skills need only instructions and success criteria.

- **Provide defaults, not menus.**
  When multiple tools or approaches could work, pick one as the default and
  mention alternatives as escape hatches. The agent SHOULD follow the default
  unless there is a specific reason not to.

- **Favor procedures over declarations.**
  You SHOULD teach the agent _how to approach_ a class of problems, not
  what to produce for a single instance. A reusable method that generalizes
  beats a hardcoded answer.

- **Keep the skill token-efficient.**
  Skills are loaded into the agent's context window. `SKILL.md` SHOULD stay
  under ~300 lines. Offload deep detail to `references/` files. Link them with
  a trigger condition so they're only read when needed. Extract recurring
  logic to `scripts/`. Balance token efficiency against human readability.

- **Keep gotchas in `SKILL.md`.**
  Environment-specific facts that defy reasonable assumptions (wrong field
  names, soft-delete filters, non-obvious API constraints) MUST stay in the
  main file — the agent needs them _before_ it encounters the situation. When
  an agent makes a mistake you have to correct, add the correction to the edge
  cases section.

- **Use imperative form in instructions.**
  Instructions SHOULD read as commands: "use this format", not "you should
  use this format".

- **Use consistent terminology.**
  One word MUST mean one thing. Avoid synonyms.

- **Reach for proven structural techniques when they fit.**
  You SHOULD use these where applicable:

  - **Step checklists** for multi-step workflows where the agent must track
    progress across dependencies or validation gates.

  - **Output templates** provide concrete structure rather than prose
    descriptions. Long or conditional templates belong in `assets/`.

  - **Validation loops** run a validator, fix failures, and repeat until it
    passes.

  - **Plan-validate-execute** for batch or destructive operations. Produce a
    plan, validate it, then execute. The validator MUST produce error messages
    specific enough for the agent to self-correct.

- **Only `scripts/`, `references/`, and `assets/` are propagated.**
  Installers ignore any other bundled subdirectories. You SHOULD namespace
  every file to avoid collisions when skills are installed side-by-side.

## Edge cases

- **Improving an existing skill.**
  Read the current `SKILL.md` first, then treat the improvement like a new
  draft. Rewrite rather than patch. Preserve the `name` field unchanged.

- **A similar skill already exists elsewhere**, eg. in Anthropic's skills repo.
  Use it as a reference for domain knowledge, but adapt the instructions and
  format to the bundled template and the conventions of the project you are
  authoring in. Don't copy verbatim.

## Success criteria

- **Front-matter MUST be valid.**
  The `name` and `description` fields MUST be present and non-empty, and `name`
  MUST match the directory name.

- **All REQUIRED paragraphs MUST be present.**
  At minimum: the `#` title, the `**Input:**` and `**Output:**` sections,
  `## Instructions` or `## Rules`, and `## Success criteria`.

- **The input and output sections MUST be present and prominent.**
  They MUST appear immediately after the title, before the first `##`. The
  input section MUST state whether input is "REQUIRED" or "OPTIONAL", and MUST
  state whether the agent should run non-interactively to completion or if it
  may interact with the user — blocking to ask questions, presenting options,
  and waiting for answers.

- **The skill MUST be token-efficient.**
  No section is padded with detail that belongs in a `references/` file. The
  `SKILL.md` SHOULD be under ~300 lines.

- **The `description` MUST be specific enough to trigger correctly.**
  It MUST name both the capability and the contexts that should invoke it — not
  just a one-line summary of what the skill does.

- **A `README.md` MUST exist alongside the `SKILL.md`.**

## Examples

- **A minimal skill with no bundled resources:**

  ```
  skills/
  └── commit/
      ├── SKILL.md
      └── README.md
  ```

- **A skill with bundled scripts and references:**

  ```
  skills/
  └── code-openapi/
      ├── SKILL.md
      ├── README.md
      ├── scripts/
      │   └── validate.sh
      └── references/
          ├── error-codes.md
          └── schema-patterns.md
  ```

## Assets

- [Skill template](./assets/skill-template/skill-name/SKILL.md):
  The bundled `SKILL.md` template to base new skills on. New skills MUST follow
  the structure and formatting herein.

## References

- [TS-27: Markdown](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/027/AGENTS.md):
  Technical standard for formatting Markdown documents. Skills `*.md` files MUST
  follow the formatting conventions described in this standard.

- [Collision safety for bundled resources](./references/create-skill-collision-safety.md):
  How to namespace bundled resources so they don't collide across skills.
  Read before adding files to `assets/`, `references/`, or `scripts/`.

- [skills/create-skill/references/create-skill-requirements-levels.md](./references/create-skill-requirements-levels.md):
  Read when wording requirement levels. This document defines a subset of
  RFC 2119 to use.

- [Preferred model](./references/create-skill-preferred-model.md):
  Read when deciding which model to pin to the skill via
  `metadata.preferred_model`.

- [Interactive vs. non-interactive skills](./references/create-skill-interactive.md):
  Read when deciding whether a skill prompts the user mid-flow, and whether to
  declare `metadata.interactive: no` (default `yes`).
