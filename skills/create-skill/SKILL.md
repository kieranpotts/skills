---
name: create-skill
description: >-
  Create a new skill (SKILL.md) or improve an existing one, in this skills
  collection or any downstream project. Use when the user asks to create, write,
  draft, add, or update a skill, or wants to capture a workflow as a reusable
  skill, or when the user says "create a skill for X", "turn this workflow into
  a skill", or "improve the <name> skill".
license: CC0-1.0
metadata:
  interactive: yes
  preferred_model: ollama/technical-writer
---

# Create skill

**Input:** A description of the skill to create, or a path to an existing skill
to improve, plus whatever the surrounding conversation already reveals about its
purpose and triggers. OPTIONAL — the seed may be just a rough idea.

**Output:** A complete skill directory — a `SKILL.md` conforming to the bundled
template (valid front-matter, prominent Input/Output paragraphs, Instructions
and/or Rules, Success criteria), a sibling `README.md`, and any bundled
`assets/`, `references/`, or `scripts/` — passing the validator. This skill
authors the skill and stops; installing it into target agents is a separate
step.

**Interactivity:** This skill is interactive. It gathers the rest of its input
from the user through prompts during the session, asking one question at a time.

##  Instructions

1.  **Clarify intent.**

    Establish what the skill should do and when it should trigger. Extract as
    much as you can from the conversation before asking questions. At minimum,
    understand the task, trigger situations, expected output, and any hard
    constraints or edge cases.

2.  **Research the domain.**

    Before writing, gather relevant context. Look up tool documentation, check
    the project for similar existing skills, and identify any scripts or reference
    files that should be bundled. Come prepared so you can minimize questions to
    the user.

3.  **Choose a name and location.**

    Place the skill in the project's skills directory as
    `<skill-name>/SKILL.md`. Skill names are kebab-case and SHOULD be meaningful
    actions or verbs (eg. `specify`, `commit`, `release`, `review`). Prefer
    single verbs; use `<verb>-<noun>` only when disambiguation is needed (eg.
    `create-skill`).

4.  **Write the `SKILL.md`.**

    Use the [bundled template](./assets/skill-template/skill-name/SKILL.md).
    Include the sections, front-matter, and formatting required by the Rules
    below. Reach for the references linked in the template and Rules when you
    need details.

5.  **Bundle supporting files if needed.**

    Add `scripts/`, `references/`, or `assets/` as required. Include instructions
    in `SKILL.md` for when and how to run any scripts. Namespace every bundled
    file to avoid collisions when the skill is installed alongside others — see
    [create-skill-collision-safety.md](./references/create-skill-collision-safety.md).

6.  **Write the `README.md`.**

    Use the [bundled template](./assets/skill-template/skill-name/README.md).
    This is human-readable documentation. Describe what the skill does, how to
    invoke it, and provide invocation examples.

7.  **Review the draft.**

    Re-read the completed `SKILL.md` with fresh eyes. Check for unnecessary
    verbosity, redundant rules, or instructions that assume too much. Trim
    anything that isn't pulling its weight.

8.  **Validate the skill.**

    Run the bundled validator against the new skill directory:

    ```sh
    scripts/validate.sh <path/to/new-skill-dir>
    ```

    The script wraps `skills-ref validate` (if installed) for canonical Agent
    Skills checks, and adds repo-specific checks: sibling `README.md`, ~300-line
    limit, presence of `## Instructions`/`## Rules`, and `## Success criteria`.
    Fix any reported failures before finishing.

## Rules

-   **The `description` field is the primary trigger mechanism.**

    It determines whether an agent invokes the skill. You SHOULD err toward being
    explicit rather than brief. You MUST follow this two-sentence pattern, written
    in the third person:

    1. *First sentence* — what the skill does.
    2. *Second sentence* — `Use when ...` followed by specific triggers (user
       phrasings, situations, file types, contexts).

    ```
    ✅ Good:
    Extract text and tables from PDF files, fill forms, merge documents.
    Use when working with PDF files or when the user mentions PDFs, forms,
    or document extraction.

    ❌ Bad:
    Helps with documents.
    ```

-   **`SKILL.md` MUST include the canonical sections.**

    - **Front-matter:** `name` and `description` are REQUIRED. `compatibility`
      and `license` are OPTIONAL. Under `metadata`, a skill MAY pin a model via
      `preferred_model` and MAY declare `interactive: no` if it never blocks on
      the user.

    - **Input, Output, and Interactivity paragraphs:** Immediately after the
      title, three prominent bold-lead paragraphs — `**Input:**`, `**Output:**`,
      and `**Interactivity:**` — stating what the skill consumes, produces, and
      whether it blocks for user input. State whether the input is REQUIRED or
      OPTIONAL. For an interactive skill, the **Input** paragraph MAY also note
      that the skill gathers input from the user through prompts during the
      session.

    - **Instructions** or **Rules:** MUST include at least one of these two
      sections.

    - **Success criteria:** REQUIRED.

    OPTIONAL sections: Examples, Edge cases, References, Assets.

-   **Keep Instructions and Rules separate.**

    Instructions are ordered steps — the procedural workflow the agent follows.
    Rules are individual, non-sequential guidelines, recommendations, and
    constraints. You MUST keep them separate, and MUST NOT embed rules inside
    instructions.

-   **Use RFC 2119 keywords consistently.**

    Mark requirement levels with MUST, SHOULD, MAY, etc. See
    [create-skill-requirements-levels.md](./references/create-skill-requirements-levels.md)
    for their meaning and when to use each.

-   **Explain the why behind non-obvious requirements.**

    Instead of bare imperatives, explain the reasoning so the agent can apply
    judgment in edge cases. When multiple approaches are valid, prefer explaining
    the *purpose* over prescribing exact steps.

-   **Match prescriptiveness to fragility.**

    Be prescriptive — exact commands, flags, ordering — when operations are
    fragile, consistency is critical, or a specific sequence must be followed.
    Otherwise, avoid enumerating every edge case in the body; handle genuinely
    tricky ones in an "edge cases" section or a `references/` file. Simple
    skills need only Instructions and Success criteria.

-   **Provide defaults, not menus.**

    When multiple tools or approaches could work, pick one as the default and
    mention alternatives as escape hatches. The agent SHOULD follow the default
    unless there is a specific reason not to.

-   **Favor procedures over declarations.**

    Teach the agent *how to approach* a class of problems, not what to produce
    for a single instance. A reusable method that generalizes beats a hardcoded
    answer.

-   **Keep the skill token-efficient.**

    Skills are loaded into the agent's context window. `SKILL.md` SHOULD stay
    under ~300 lines. Offload deep detail to `references/` files; link them with
    a trigger condition so they're only read when needed. Extract recurring
    logic to `scripts/`. Balance token efficiency against human readability.

-   **Keep gotchas in `SKILL.md`.**

    Environment-specific facts that defy reasonable assumptions (wrong field
    names, soft-delete filters, non-obvious API constraints) MUST stay in the
    main file — the agent needs them *before* it encounters the situation. When
    an agent makes a mistake you have to correct, add the correction to the edge
    cases section.

-   **Use imperative form in instructions.**

    "Use this format", not "You should use this format".

-   **Use consistent terminology.**

    One word MUST mean one thing; avoid synonyms.

-   **Reach for proven structural techniques**, eg.:

    - *Step checklists* for multi-step workflows where the agent must track
      progress across dependencies or validation gates.
    - *Output templates* — provide concrete structure rather than prose
      descriptions; long or conditional templates belong in `assets/`.
    - *Validation loops* — run a validator, fix failures, repeat until it passes.
    - *Plan-validate-execute* — for batch or destructive operations, produce a
      plan, validate it, then execute. The validator MUST produce error messages
      specific enough for the agent to self-correct.

-   **Only `scripts/`, `references/`, and `assets/` are propagated.**

    Installers ignore any other bundled subdirectories. Namespace every file to
    avoid collisions when skills are installed side-by-side; this matters most
    for hosts that flatten all resources into one shared directory.

## Examples

A minimal skill with no bundled resources:

```
skills/
└── commit/
    ├── SKILL.md
    └── README.md
```

A skill with bundled scripts and references:

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

## Edge cases

- **Improving an existing skill:** Read the current `SKILL.md` first, then treat
  the improvement like a new draft. Rewrite rather than patch. Preserve the
  `name` field unchanged.

- **A similar skill already exists elsewhere**, eg. in Anthropic's skills repo.
  Use it as a reference for domain knowledge, but adapt the instructions and
  format to the bundled template and the conventions of the project you are
  authoring in. Don't copy verbatim.

## Success criteria

- **Front-matter MUST be valid.** The `name` and `description` fields MUST be
  present and non-empty, and `name` MUST match the directory name.

- **All REQUIRED paragraphs MUST be present.** At minimum: the `#` title, the
  `**Input:**`, `**Output:**`, and `**Interactivity:**` paragraphs, `##
  Instructions` or `## Rules`, and `## Success criteria`.

- **The Input, Output, and Interactivity paragraphs MUST be present and
  prominent.** They MUST appear immediately after the title, before the first
  `##`. The **Input** paragraph MUST state whether input is REQUIRED or OPTIONAL.
  The **Interactivity** paragraph MUST state whether the skill runs
  non-interactively or is interactive. For an interactive skill, the **Input**
  paragraph MAY also note that the skill gathers input from the user through
  prompts during the session.

- **The skill MUST be token-efficient.** No section is padded with detail that
  belongs in a `references/` file, and `SKILL.md` SHOULD be under ~300 lines.

- **The `description` MUST be specific enough to trigger correctly.** It MUST
  name both the capability and the contexts that should invoke it — not just a
  one-line summary of what the skill does.

- **A `README.md` MUST exist alongside the `SKILL.md`.**

## Assets

- [Skill template](./assets/skill-template/skill-name/SKILL.md): The bundled
  SKILL.md template to base new skills on.

## References

- [create-skill-collision-safety.md](./references/create-skill-collision-safety.md):
  Read before adding files to `assets/`, `references/`, or `scripts/` — how to
  namespace bundled resources so they don't collide across skills.

- [create-skill-requirements-levels.md](./references/create-skill-requirements-levels.md):
  Read when wording requirement levels — the RFC 2119 keyword subset (MUST,
  SHOULD, MAY, …) and when to use each.

- [create-skill-preferred-model.md](./references/create-skill-preferred-model.md):
  Read when deciding whether to pin a model via `metadata.preferred_model`, and
  how hosts like Pi's `realize` interpret it.

- [create-skill-interactive.md](./references/create-skill-interactive.md): Read
  when deciding whether a skill prompts the user mid-flow, and whether to
  declare `metadata.interactive` (default `yes`).
