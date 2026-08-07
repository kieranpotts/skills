---
name: create-skill
description: >-
  Author a new skill, or improve an existing one, in this skills collection or
  any downstream project. Use when the user asks to create, write, draft, add,
  or update a skill, or wants to capture a workflow as a reusable skill, or
  when the user says "create a skill for X", "turn this workflow into a skill",
  or "improve the <name> skill".
compatibility: requires Read, Write, Bash (validator script)
license: CC0-1.0
---

# Create skill

Create a new skill or improve an existing one, either in this skills
collection or a downstream project.

## Parameters

Determine the following information from the surrounding context and
environment, if possible. If you're uncertain about the required parameters,
prompt the user for clarification.

- **A description of the skill — REQUIRED.** Either a description of a new
  skill to create, or a path to an existing skill to improve.

- **Trigger conditions — REQUIRED.** The situations and user phrasings that
  should invoke it.

- **Target project — OPTIONAL.** Where to install the skill. If not
  explicitly specified by the user, if the current working directory (cwd) is
  inside a Git repository, then you can assume that repository is the target
  repository for installation of the new skill. Otherwise install the skill
  in the user's home directory at `$HOME/.agents/skills/<skill-name>/`.

## Success criteria

- A complete skill directory MUST exist at the target location, holding a
  `SKILL.md`, a sibling `README.md` for humans, and any `assets/`,
  `references/`, and `scripts/` the skill needs.

- Every bundled file MUST be reachable from `SKILL.md`, each one carrying the
  condition under which the agent should load or run it. A bundled file that
  nothing points at is dead weight in every install of the skill.

- Every bundled file MUST be namespaced to the skill, so that flattening the
  bundle alongside other skills' bundles cannot silently overwrite it.

- The validator MUST report no failures against the skill directory.

- The target project's own code and configuration MUST be unchanged. This
  skill writes a skill directory, and nothing else.

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

3.  Use the [bundled template](./assets/create-skill-template/skill-name/SKILL.md)
    to write the `SKILL.md` file. Include the sections, front-matter, and
    formatting required by the rules defined below.

4.  Add files to `scripts/`, `references/`, or `assets/`. These capture
    additional context that an agent can load dynamically to solve particular
    issues it encounters. Include explicit instructions in `SKILL.md` for when
    and how to run any scripts, load any references, or extract any assets.

    Namespace every bundled file to avoid collisions when the skill is
    installed alongside others. See the collision safety instructions,
    [here](./references/create-skill-collision-safety.md).

5.  Use the [bundled template](./assets/create-skill-template/skill-name/README.md)
    to write a `README.md` file to accompany the `SKILL.md` file. This is
    human-readable documentation. Describe what the skill does, whether it
    runs interactively, how to invoke it, what class of model it warrants,
    and optionally how it fits into wider agentic workflows.

    Keep the readme template's section order. Drop the sections marked OPTIONAL
    where they are not relevant to the skill.

6.  Re-read the completed `SKILL.md` with fresh eyes. Check for unnecessary
    verbosity, redundant rules, or instructions that assume too much. Trim
    anything that isn't pulling its weight.

7.  Run the bundled validator against the new skill directory.

    ```sh
    scripts/create-skill-validate.sh <path/to/new-skill-dir>
    ```

    The script wraps `skills-ref validate` (if installed) for canonical
    Agent Skills checks, and adds further checks that capture rules defined
    here.

    Fix any reported failures before finishing.

## Rules

- You MUST NOT make any code or configuration changes to any software.

- The front-matter fields `name`, `description`, and `license` are
  REQUIRED.

- The `description` field is the primary trigger mechanism. It determines
  the scenarios in which an agent should ingest the skill. You SHOULD err toward
  being explicit rather than brief. You MUST follow this two-sentence pattern,
  written in the third person:

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

- You MAY add a third sentence that clarifies scenarios in which the skill must
  _not_ be used.

- For the `license` field, default to "CC0-1.0" unless the user says otherwise.

- You MUST open the body of the skill file with a level 1 Markdown heading.
  This MUST match the skill name. For example, for a skill named `create-skill`,
  the heading will be `# Create skill`.

- Immediately after the level 1 heading, include a short description (one to
  three sentences only) covering what the agent is being asked to do, and
  optionally what it should _not_ do. This MAY be adapted from the first part
  of the front-matter description, but it serves a different purpose. The
  `description` field defines trigger conditions for an agent ingesting the
  body of a skill, while the introductory paragraphs of the skill body should be
  treated more like an initial prompt after that ingestion happens.

- The remaining sections of the skill MUST follow the order in which they
  appear in the `SKILL.md` template.

- You MUST organize content into the appropriate sections. The `## Instructions`
  section defines a procedural workflow the agent should follow step-by-step.
  The `## Rules` section captures individual, non-sequential guidelines,
  recommendations, and constraints that govern the whole workflow. The
  `## Success criteria` section defines outcomes that the agent can check its
  own work against.

- The `## Parameters` section is REQUIRED. It defines what the skill consumes.
  Open this section with a short preamble telling the agent to determine the
  parameters from the surrounding context and environment, and stating plainly
  whether it may prompt the user when uncertain.

- The parameters MUST be a bulleted list, even for a single parameter. Each
  item has a bold-lead bullet naming the parameter and its requirement level,
  with explanatory text following in plain prose.

  ```md
  - **Scope — REQUIRED.** A description of the target system.

  - **Audit date — OPTIONAL.** Assume today if not given.
  ```

  Give each genuinely distinct parameter its own bullet. Do not join a
  primary parameter and a supporting one with "plus".

- The `## Success criteria` section is REQUIRED. It MUST be placed directly
  after `## Parameters` and before `## Instructions` (or `## Rules` if the
  instructions section is dropped). This section sets goals for the agent to
  achieve. List observable end states that the agent can verify against. Prefer
  to include deterministic checks, such as linters, validators, and shell
  commands. Rules constrain how the agent works; criteria state checkable
  properties of what it produced. A criterion MUST NOT simply reword a rule
  as a goal, and two criteria MUST NOT state the same outcome.

- The `## Instructions` section is an ordered procedure for the agent to follow.
  It is REQUIRED unless the skill is purely declarative, in which case
  `## Rules` alone suffices.

- The `## Rules` section covers individual, non-sequential constraints. It is
  REQUIRED unless the skill is purely procedural, in which case
  `## Instructions` alone suffices.

- At least one of `## Instructions` or `## Rules` MUST be present.

- The `## Edge cases` section is OPTIONAL. It gives instructions for the agent
  to handle edge cases that it may encounter from time-to-time. Extract
  instructions and rules here if they are expected to be applicable only
  rarely.

- The `## Examples` section is OPTIONAL. Include it only if you can provide
  canonical examples of outputs the agent is expected to generate.

- The `## Assets` section is OPTIONAL. Use it to reference static assets, such
  as templates, the agent may need to help compose its output.

- The `## References` section is OPTIONAL. It captures additional reference
  material the agent can ingest on-demand. For each reference, you MUST specify
  a trigger condition.

- You SHOULD use inline bold sparingly. Reserve it for the lead of each
  `## Parameters` bullet. Rules, success criteria, instructions, edge cases,
  and examples are plain prose. Bold carries meaning only while it is rare.

- Use RFC 2119 keywords consistently.

- Every instruction, rule, and success  criterion MUST be built around one or
  more of the RFC 2119 keywords. For example, rather than writing "run the
  validator before finishing", be explicit in the requirement level by writing
  "you MUST run the validator before finishing". A step with no requirement
  level is ambiguous about whether it can be skipped or varied.

- See [requirements levels](./references/create-skill-requirements-levels.md)
  for the allowed subset of RFC 2119 keywords.

- Skills SHOULD NOT hard-code the formats and storage locations of artifacts
  that an agent consumes or generates. Input and output SHOULD be discoverable
  from the context surrounding the skill, or from the environment. Decoupling
  skills from particular conventions for writing artifacts such as requirements
  specifications, decision records, and design documentation, allows skills to
  be more easily ported between projects and to remain stable as a project's
  own conventions evolve.

- Skills MUST NOT reference other skills by name. A global skill MUST NOT name
  a project-level skill, and a project-level skill MUST NOT name a global one.
  Skills in the same collection SHOULD not reference each other, either.
  Skills that do not explicitly hand-off to one another have greater reuse.
  They can be composed by orchestrators into all sorts of different workflows.

- Non-obvious requirements SHOULD explain the _why_ behind them. Instead of
  bare imperatives, explain the reasoning so the agent can apply judgment in
  edge cases. When multiple approaches are valid, rather tha prescribing
  exact steps, prefer to set out guiding principles that the agent can use to
  make its own judgment call to the best way forward.

- Prescriptiveness SHOULD match fragility. You SHOULD be prescriptive — eg.
  provide exact commands, flags, and ordering — when operations are fragile,
  consistency is critical, or a specific sequence must be followed. Otherwise,
  you SHOULD NOT enumerate every edge case in the body. Instead, genuinely
  tricky edge cases SHOULD be handled in the edge cases section or a separate
  `references/` file.

- Provide defaults, not menus. When multiple tools or approaches could work,
  pick one as the default and mention alternatives as escape hatches. The agent
  SHOULD follow the default unless there is a specific reason not to.

- Favor procedures over declarations. You SHOULD teach the agent how to approach
  a class of problems, not what to produce for a single instance. A reusable
  method that generalizes beats a hardcoded answer.

- Keep the skill token-efficient. Skills are loaded into the agent's context
  window, so the budget is on the file as loaded, not on its prose. You SHOULD
  NOT pad a section with detail that belongs in a `references/` file. Offload
  deep detail to `references/`, linked with a trigger condition so it is only
  read when needed, and extract recurring logic to `scripts/`. Balance token
  efficiency against human readability.

- Document gotchas directly in the main `SKILL.md` file. Do not extract these
  to reference resources. Environment-specific facts that defy reasonable
  assumptions (wrong field names, soft-delete filters, non-obvious API
  constraints) MUST stay in the main file, because the agent needs to know
  about them _before_ it encounters the situation. The `## Edge cases` section
  serves this purpose.

- Use imperative form in instructions. Instructions SHOULD read as commands:
  "use this format", not "you should use this format".

- Use terminology consistently. One word MUST mean one thing. Avoid synonyms.

- Reach for proven structural techniques when they fit. You SHOULD use these
  where applicable:

  - Step checklists for multi-step workflows where the agent must track
    progress across dependencies or validation gates.

  - Output templates provide concrete structure rather than prose
    descriptions. Long or conditional templates belong in `assets/`.

  - Validation loops run a validator, fix failures, and repeat until it
    passes.

  - Plan-validate-execute for batch or destructive operations. Produce a
    plan, validate it, then execute. The validator MUST produce error
    messages specific enough for the agent to self-correct.

## Edge cases

- You are improving an existing skill.

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
      │   └── code-openapi-validate.sh
      └── references/
          ├── code-openapi-error-codes.md
          └── code-openapi-schema-patterns.md
  ```

## Assets

- [Skill template](./assets/create-skill-template/skill-name/SKILL.md) \
  The bundled `SKILL.md` template to base new skills on. New skills MUST
  follow the structure and formatting herein.

## References

- [TS-27: Markdown](https://raw.githubusercontent.com/kieranpotts/standards/refs/heads/latest/dev/src/027/AGENTS.md) \
  Technical standard for formatting Markdown documents. Skill files
  MUST follow the formatting conventions described in this standard.

- [Collision safety for bundled resources](./references/create-skill-collision-safety.md) \
  How to namespace bundled resources so they don't collide across skills.
  Read before adding files to `assets/`, `references/`, or `scripts/`.

- [Requirements levels](./references/create-skill-requirements-levels.md) \
  Read when wording requirement levels. This document defines a subset of
  RFC 2119 to use.

- [Interactive vs. non-interactive skills](./references/create-skill-interactive.md) \
  Read when deciding whether a skill prompts the user mid-flow, and how to
  state that in the `## Parameters` preamble and the README's
  "Interactivity" section.
