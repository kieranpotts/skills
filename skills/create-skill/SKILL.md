---
name: create-skill
description: Create a new skill or improve an existing one – either in this skills repository or another one. Use when the user asks to create, write, draft, add, or update a skill, or wants to capture a workflow as a reusable skill.
license: MIT
---

# Create skill

Use this skill when creating a new skill from scratch or improving an existing one. Use this skill for creating new skills either in this shared-skills repository, or in project-specific skills libraries.

Do NOT use this skill for one-off instructions or CLAUDE.md (or other agent-specific configuration). Skills are reusable, agent-agnostic prompts.

## Instructions

1.  **Clarify intent.**

    Establish what the skill should do and when it should trigger. Extract as much as you can from the conversation before asking questions. At minimum, understand:

    - What task or workflow should the skill enable?

    - In what specific situations should it trigger? (This informs the `description` field.)

    - What is the expected output — format, location, content?

    - Are there hard constraints, edge cases, or failure modes to document?

2.  **Research the domain.**

    Before writing, gather relevant context. Look up tool documentation, check for similar existing skills in `skills/`, identify any scripts or reference files that should be bundled. Come prepared, so you can minimize questions to the user.

3.  **Choose a name and location.**

    If installing the skill in this repository, the skill names are kebab-case and follow a `<category>-<topic>` pattern. Categories in use: `code-`, `utils-`, `tools-`, `docs-`, `plan-`, `product-`, `standards-`.

    Place the skill at `skills/<skill-name>/SKILL.md`.

    If installing the skill in another project, follow the conventions and documented patterns of that project.

4.  **Write the `SKILL.md`** using the [template](../../template/skill-name/SKILL.md). The REQUIRED sections are:

    - **Frontmatter**: `name` and `description` are REQUIRED. Other fields like `compatibility` and `license` are OPTIONAL.

    - **Instructions** or **Rules**: MUST include at least one of these two sections.

    - **Success criteria**: Concrete, self-verifiable checks the agent runs before finishing. REQUIRED.

    OPTIONAL sections: Examples, Edge cases, References.

5.  **Bundle supporting files if needed.**

    - `scripts/`: Executable scripts for deterministic or repetitive sub-tasks; include instructions in SKILL.md for when and how to run them.

    - `references/`: Detailed documentation loaded into context as needed; link from SKILL.md with an explicit trigger condition.

    - `assets/`: Static files used in output (templates, icons, fonts).

6.  **Write the `README.md`** using the [template](../../template/skill-name/README.md). This is human-readable documentation. Describe what the skill does, how to invoke it, and provide invocation examples.

7.  **Review the draft.**

    Re-read the completed SKILL.md with fresh eyes. Check for unnecessary verbosity, redundant rules, or instructions that assume too much. Trim anything that isn't pulling its weight.

## Rules

-   **The `description` field is the primary trigger mechanism.**

    It determines whether an agent invokes the skill. Write it to include both what the skill does and the specific contexts in which to use it. Err toward being explicit rather than brief. A vague description leads to the skill being ignored.

-   **Instructions versus rules.**

    Instructions are ordered steps — the procedural workflow the agent follows. Rules are individual, non-sequential guidelines, recommendations, and constraints – the most important ones come first.

    Keep them separate. Don't embed rules inside instructions.

-   **Explain the why behind non-obvious requirements.**

    Instead of bare imperatives (`ALWAYS do X`), explain the reasoning so the agent can apply judgment in edge cases. Well-reasoned instructions are more robust than rigid rules.

-   **Write for token efficiency.**

    Skills are loaded into the agent's context window. Keep SKILL.md under ~300 lines. Offload deep detail to `references/` files. Link references from SKILL.md with a trigger condition so they're only read when needed.

-   **Use imperative form in instructions.**

    "Use this format", not "You should use this format".

-   **Don't over-specify.**

    Avoid enumerating every possible edge case in the body. Handle genuinely tricky cases in an "edge cases" section or a `references/` file. Simple skills need only Instructions and Success criteria.

## Examples

A minimal skill with no bundled resources:

```
skills/
└── utils-git-commits/
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

-   **Improving an existing skill**:

    Read the current SKILL.md first, then treat the improvement like a new draft. Rewrite rather than patch. Preserve the `name` field unchanged.

-   **Skill already exists in Anthropic's repo**:

    Use it as a reference for domain knowledge, but adapt the instructions and format to this repo's template and style. Don't copy verbatim.

## Success criteria

-   **Frontmatter is valid.**

    `name` and `description` fields are present and non-empty. `name` matches the directory name.

-   **All required sections are present.**

    At minimum: a titled intro paragraph, `## Instructions`, and `## Success criteria`.

-   **The skill is token-efficient.**

    No section is padded with detail that belongs in a `references/` file. SKILL.md is under ~300 lines.

-   **The `description` is specific enough to trigger correctly.**

    It names both the capability and the contexts that should invoke it — not just a one-line summary of what the skill does.

-   **A `README.md` exists** alongside the `SKILL.md`.

## References

- [Skill template](../../template/skill-name/SKILL.md): The canonical SKILL.md template to base new skills on.

- [Example skill — utils-git-commits](../utils-git-commits/SKILL.md): A well-formed example of a completed skill.

- [Creating skills](../../docs/creating-skills.md): Human-readable documentation on the skill creation process.
