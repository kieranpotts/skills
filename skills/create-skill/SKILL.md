---
name: create-skill
description: >-
  Author a new skill, or improve an existing one, in this skills collection or
  any downstream project. Use when the user asks to create, write, draft, add,
  or update a skill, or wants to capture a workflow as a reusable skill, or
  when the user says "create a skill for X", "turn this workflow into a skill",
  or "improve the <name> skill".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/PROSE_DEEP
---

# Create skill

Create a new skill or improve an existing one, either in this skills
collection or a downstream project.

You MUST NOT make any code or configuration changes to any software.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification.

- **A description of the skill — REQUIRED.** Either a description of a new
  skill to create, or a path to an existing skill to improve.

- **The purpose of the skill — REQUIRED.** What it is for.

- **Trigger conditions — REQUIRED.** The situations and user phrasings that
  should invoke it.

- **Target project — OPTIONAL.** Where to install the skill. If not
  explicitly specified by the user, if the current working directory (cwd) is
  inside a Git repository then you can assume that repository is the target
  repository. Otherwise install the skill in the user's home directory at
  `$HOME/.agents/skills/<skill-name>/`.

## Success criteria

You will achieve the following outcomes:

- A complete skill directory MUST exist at the target location, holding a
  `SKILL.md`, a sibling `README.md` for humans, and any bundled `assets/`,
  `references/`, and `scripts/`.

- The front-matter MUST be valid. The `name` and `description` fields MUST
  be present and non-empty, and `name` MUST match the directory name.

- The `description` MUST follow the two-sentence pattern, naming both the
  capability and the contexts that should invoke the skill.

- The canonical sections MUST be present, in order: the `#` title and its
  description, `## Parameters`, `## Success criteria`, and at least one of
  `## Instructions` or `## Rules`. `## Parameters` and `## Success criteria`
  MUST come before any other `##` heading.

- The `## Parameters` section MUST open with a preamble whose stance on
  prompting the user matches the `metadata.interactive` flag, followed by a
  bulleted list in which every item carries a bold lead naming the parameter
  and its requirement level, `REQUIRED` or `OPTIONAL`.

- Every instruction, rule, and success criterion MUST carry an explicit
  requirement-level keyword.

- The `SKILL.md` MUST NOT name any other skill.

- The `SKILL.md` MUST be under 500 lines, blank lines included.

- A `README.md` MUST exist alongside the `SKILL.md`, and MUST carry the
  `## Interactivity`, `## How to invoke`, and `## Recommended models`
  sections, and MAY carry `## Related skills` too. The order in which the
  headings appear MUST match the bundled template.

- The validator MUST pass against the skill directory.

## Instructions

1.  Before writing, gather relevant context. Look up tool documentation,
    check the project for similar existing skills, and identify any scripts
    or reference files that ought to be bundled. Come prepared so you can
    minimize questions to the user.

2.  Under the target project, install the skill file at
    `.agents/skills/<skill-name>/SKILL.md` (relative to the project root).

    Use kebab-case for skill names, and favor meaningful actions or verbs,
    eg. "specify", "commit", "release", "review". Prefer single verbs, but
    use `<verb>-<noun>` when disambiguation is needed, eg. "create-skill".

3.  Write the `SKILL.md` file.

    Use the [bundled template](./assets/skill-template/skill-name/SKILL.md)
    and include the sections, front-matter, and formatting required by the
    rules below.

4.  Bundle supporting files if needed.

    Add files to `scripts/`, `references/`, or `assets/` when the skill needs
    them.

    Include instructions in `SKILL.md` for when and how to run any scripts,
    load any references, or extract any assets.

    Namespace every bundled file to avoid collisions when the skill is
    installed alongside others. See the collision safety instructions,
    [here](./references/create-skill-collision-safety.md).

5.  Write the `README.md`.

    Use the [bundled template](./assets/skill-template/skill-name/README.md).

    This is human-readable documentation. Describe what the skill does,
    whether it runs interactively, how to invoke it, what class of model it
    warrants, and (OPTIONALLY) how it fits into surrounding workflows.

    Keep the template's section order. Drop the sections marked OPTIONAL
    where they have nothing to say.

6.  Review the draft.

    Re-read the completed `SKILL.md` with fresh eyes. Check for unnecessary
    verbosity, redundant rules, or instructions that assume too much. Trim
    anything that isn't pulling its weight.

7.  Validate the skill.

    Run the bundled validator against the new skill directory:

    ```sh
    scripts/validate.sh <path/to/new-skill-dir>
    ```

    The script wraps `skills-ref validate` (if installed) for canonical
    Agent Skills checks, and adds repo-specific checks.

    Fix any reported failures before finishing.

## Rules

- The `description` field is the primary trigger mechanism.

  It determines when an agent invokes the skill. You SHOULD err toward
  being explicit rather than brief. You MUST follow this two-sentence
  pattern, written in the third person:

  1. First sentence — what the skill does.
  2. Second sentence — `Use when ...` followed by specific triggers (user
     phrasings, situations, file types, contexts).

  ```sh
  ✅ Good:
  Extract text and tables from PDF files, forms, or documents. Use when
  working with PDF files or when the user mentions PDFs, forms, or
  document extraction.

  ❌ Bad:
  Helps with documents.
  ```

- Write each canonical section to its own contract.

  - Front-matter: `name` and `description` are REQUIRED. `compatibility`
    and `license` are OPTIONAL. Under `metadata`, a skill MAY pin a model
    via `preferred_model` and MAY declare `interactive: no` if it never
    blocks on the user.

  - Description: Immediately after the level 1 heading, which is the title
    of the skill, include a short one to three sentence description of the
    skill's purpose, and what it does NOT do. This MAY be adapted from the
    first part of the front-matter description.

  - `## Parameters`: REQUIRED. What the skill consumes. Open with a short
    preamble telling the agent to determine these from the surrounding
    context and environment, and stating whether it may prompt the user
    when uncertain — this is where interactivity is declared, matching the
    `metadata.interactive` flag.

    The parameters MUST ALWAYS be a bulleted list, even for a single
    parameter. Each item is a bold-lead bullet naming the parameter and its
    requirement level, with explanatory text following in plain prose:

    ```md
    - **Scope — REQUIRED.** A description of the target system.

    - **Audit date — OPTIONAL.** Assume today if not given.
    ```

    Give each genuinely distinct parameter its own bullet. Do not join a
    primary parameter and a supporting one with "plus".

  - `## Success criteria`: REQUIRED, and placed directly after
    `## Parameters` — before the instructions, so the agent knows what it
    is aiming at before it starts. Open with `You will achieve the
    following outcomes:`, then list the observable end state as plain
    bullets.

    This section absorbs what the skill produces: an outcome bullet names
    an artifact that exists, a state that holds, or a check that passes.
    There is no separate output section. Include deterministic checks — a
    linter, a validator, a command — wherever the agent can run one.

    A criterion MUST NOT restate a rule or an instruction, and no two
    criteria MUST state the same outcome. A step the agent performs belongs
    in `## Instructions`; a constraint on how it works, and the scope it
    MUST stay inside, belong in `## Rules`. Ask of each bullet whether it
    can be checked against the finished work without watching the agent
    work: if not, it is a rule or a step wearing the wrong hat.

  - `## Instructions`: The ordered procedural steps. REQUIRED unless the
    skill is purely declarative, in which case `## Rules` alone suffices.

  - `## Rules`: Individual, non-sequential constraints. REQUIRED unless the
    skill is purely procedural, in which case `## Instructions` alone
    suffices. At least one of Instructions or Rules MUST be present.

  - `## Edge cases`: Potential edge cases to warn about. OPTIONAL.

  - `## Examples`: A small number of canonical examples. OPTIONAL.

  - `## Assets`: Static assets, such as templates, the agent MAY use to
    compose its output. OPTIONAL.

  - `## References`: Additional reference material the agent can load
    on-demand. For each, specify a trigger condition. OPTIONAL.

- You SHOULD use inline bold sparingly.

  Bold carries meaning only while it is rare. Reserve it for the lead of
  each `## Parameters` bullet, where it separates the parameter name and
  requirement level from the prose that explains it.

  Rules, success criteria, instructions, edge cases, and examples are
  written as plain prose. A rule states its constraint in a full sentence,
  optionally followed by an indented paragraph giving the reason:

  ```md
  - You MUST branch from `main`, not from any other branch.

    Audits are always cut from `main`. If local `main` is behind the
    remote, pull first.
  ```

  Bolding every rule heading turns the section into a wall of emphasis and
  makes the genuinely important lines harder to find.

- Keep instructions and rules separate.

  Instructions are ordered steps — the procedural workflow the agent
  follows. Rules are individual, non-sequential guidelines, recommendations,
  and constraints. You MUST keep them separate. You MUST NOT embed rules
  inside instructions, or instructions inside rules.

- Use RFC 2119 keywords consistently.

  Mark requirement levels with MUST, SHOULD, MAY, etc. See
  [requirements levels](./references/create-skill-requirements-levels.md)
  for the allowed subset of RFC 2119 keywords.

  Every instruction, rule, and success criterion MUST be built around one
  of these keywords, stated explicitly. For example, rather than writing
  "run the validator before finishing", be explicit in the requirement
  level by writing "you MUST run the validator before finishing". A step
  with no requirement level is ambiguous about whether it can be skipped
  or varied.

- Skills MUST discover where artifacts live; they MUST NOT assume it.

  A skill is installed across projects that use different methods and
  tools. It MUST NOT hard-code the location, file name, format, or internal
  structure of any artifact it reads or writes — requirements, decision
  records, design documentation, delivery plans, audit reports, risk
  registers, changelogs, glossaries, issue trackers.

  Where a skill consumes or produces such an artifact, its `## Parameters`
  section MUST carry a bullet naming the store and requiring its discovery:
  from session context first, then the environment (a convention file, a
  workspace manifest, an existing directory, a configured connector), then
  by asking the user. State explicitly that the store MAY be a directory in
  the current repository, a separate repository, or an external service.

  Having resolved a store, the skill MUST follow whatever conventions that
  store documents for itself. The store owns its template, its lifecycle,
  and its format; the skill owns only the method. A skill that prescribes a
  path or a document structure of its own works in exactly one project.

- Skills MUST NOT reference other skills by name.

  A global skill MUST NOT name a project-level skill, and a project-level
  skill MUST NOT name a global one. Refer to the *procedure* a store defines
  rather than the named skill that implements it. Cross-references couple
  the two layers and break independent installation.

- Non-obvious requirements MUST explain the why behind them.

  Instead of bare imperatives, explain the reasoning so the agent can apply
  judgment in edge cases. When multiple approaches are valid, you SHOULD
  explain the purpose over prescribing exact steps.

- Prescriptiveness MUST match fragility.

  You SHOULD be prescriptive — exact commands, flags, ordering — when
  operations are fragile, consistency is critical, or a specific sequence
  must be followed. Otherwise, you SHOULD NOT enumerate every edge case in
  the body. Instead, genuinely tricky edge cases SHOULD be handled in the
  edge cases section or a separate `references/` file.

  Simple skills need only instructions and success criteria.

- Provide defaults, not menus.

  When multiple tools or approaches could work, pick one as the default and
  mention alternatives as escape hatches. The agent SHOULD follow the
  default unless there is a specific reason not to.

- Favor procedures over declarations.

  You SHOULD teach the agent how to approach a class of problems, not what
  to produce for a single instance. A reusable method that generalizes
  beats a hardcoded answer.

- Keep the skill token-efficient.

  Skills are loaded into the agent's context window, so the budget is on the
  file as loaded, not on its prose. You SHOULD NOT pad a section with detail
  that belongs in a `references/` file. Offload deep detail to `references/`,
  linked with a trigger condition so it is only read when needed, and extract
  recurring logic to `scripts/`. Balance token efficiency against human
  readability.

- Keep gotchas in `SKILL.md`.

  Environment-specific facts that defy reasonable assumptions (wrong field
  names, soft-delete filters, non-obvious API constraints) MUST stay in the
  main file — the agent needs them before it encounters the situation.
  When an agent makes a mistake you have to correct, add the correction to
  the edge cases section.

- Use imperative form in instructions.

  Instructions SHOULD read as commands: "use this format", not "you
  should use this format".

- Use consistent terminology.

  One word MUST mean one thing. Avoid synonyms.

- Reach for proven structural techniques when they fit.

  You SHOULD use these where applicable:

  - Step checklists for multi-step workflows where the agent must track
    progress across dependencies or validation gates.

  - Output templates provide concrete structure rather than prose
    descriptions. Long or conditional templates belong in `assets/`.

  - Validation loops run a validator, fix failures, and repeat until it
    passes.

  - Plan-validate-execute for batch or destructive operations. Produce a
    plan, validate it, then execute. The validator MUST produce error
    messages specific enough for the agent to self-correct.

- Only `scripts/`, `references/`, and `assets/` are propagated.

  Installers ignore any other bundled subdirectories. You SHOULD namespace
  every file to avoid collisions when skills are installed side-by-side.

## Edge cases

- Improving an existing skill.

  Read the current `SKILL.md` first, then treat the improvement like a new
  draft. Rewrite rather than patch. Preserve the `name` field unchanged.

- A similar skill already exists elsewhere, eg. in Anthropic's skills repo.

  Use it as a reference for domain knowledge, but adapt the instructions and
  format to the bundled template and the conventions of the project you are
  authoring in. Don't copy verbatim.

## Examples

- A minimal skill with no bundled resources:

  ```sh
  skills/
  └── commit/
      ├── SKILL.md
      └── README.md
  ```

- A skill with bundled scripts and references:

  ```sh
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
  The bundled `SKILL.md` template to base new skills on. New skills MUST
  follow the structure and formatting herein.

## References

- [TS-27: Markdown](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/027/AGENTS.md):
  Technical standard for formatting Markdown documents. Skill files
  MUST follow the formatting conventions described in this standard.

- [Collision safety for bundled resources](./references/create-skill-collision-safety.md):
  How to namespace bundled resources so they don't collide across skills.
  Read before adding files to `assets/`, `references/`, or `scripts/`.

- [Requirements levels](./references/create-skill-requirements-levels.md):
  Read when wording requirement levels. This document defines a subset of
  RFC 2119 to use.

- [Preferred model](./references/create-skill-preferred-model.md):
  Read when deciding which model to pin to the skill via
  `metadata.preferred_model`.

- [Interactive vs. non-interactive skills](./references/create-skill-interactive.md):
  Read when deciding whether a skill prompts the user mid-flow, and whether
  to declare `metadata.interactive: no` (default `yes`).
