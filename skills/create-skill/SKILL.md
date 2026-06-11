---
name: create-skill
description: Create a new skill (SKILL.md) or improve an existing one in any project that has installed this skills collection. Use when the user asks to create, write, draft, add, or update a skill, or wants to capture a workflow as a reusable skill.
license: CC0-1.0
metadata:
  preferred_model: qwen3.5:35b
---

# Create skill

Use this skill when creating a new skill from scratch or improving an existing one in any project that has installed this skills collection.

Do NOT use this skill for one-off instructions or CLAUDE.md (or other agent-specific configuration). Skills are reusable, agent-agnostic prompts.

Do NOT use this skill to add new skills to the source [`kieranpotts/skills`](https://github.com/kieranpotts/skills) repository – that repo uses [`docs/creating-skills.md`](https://github.com/kieranpotts/skills/blob/dev/docs/creating-skills.md) + [`template/skill-name/`](https://github.com/kieranpotts/skills/tree/dev/template/skill-name) for its own contribution workflow. This skill is packaged for downstream consumers.

##  Instructions

1.  **Clarify intent.**

    Establish what the skill should do and when it should trigger. Extract as much as you can from the conversation before asking questions. At minimum, understand:

    - What task or workflow should the skill enable?

    - In what specific situations should it trigger? (This informs the `description` field.)

    - What is the expected output — format, location, content?

    - Are there hard constraints, edge cases, or failure modes to document?

2.  **Research the domain.**

    Before writing, gather relevant context. Look up tool documentation, check for similar existing skills in `skills/`, identify any scripts or reference files that should be bundled. Come prepared, so you can minimize questions to the user.

3.  **Choose a name and location.**

    Place the skill at `skills/<skill-name>/SKILL.md`. Skill names are kebab-case and SHOULD be meaningful actions or verbs (eg. `specify`, `commit`, `release`, `review`). Skills support agent workflows, so a verb-first name makes the skill's purpose immediately legible. Prefer single verbs; use `<verb>-<noun>` only when disambiguation is needed (eg. `create-skill`).

4.  **Write the `SKILL.md`** using the [bundled template](./assets/skill-template/skill-name/SKILL.md). The REQUIRED sections are:

    - **Frontmatter**: `name` and `description` are REQUIRED. Other fields like `compatibility` and `license` are OPTIONAL.

    - **Instructions** or **Rules**: MUST include at least one of these two sections.

    - **Success criteria**: Concrete, self-verifiable checks the agent runs before finishing. REQUIRED.

    OPTIONAL sections: Examples, Edge cases, References.

5.  **Bundle supporting files if needed.**

    - `scripts/`: Executable scripts for deterministic or repetitive sub-tasks; include instructions in SKILL.md for when and how to run them.

    - `references/`: Detailed documentation loaded into context as needed; link from SKILL.md with an explicit trigger condition.

    - `assets/`: Static files used in output (templates, icons, fonts).

6.  **Write the `README.md`** using the [bundled template](./assets/skill-template/skill-name/README.md). This is human-readable documentation. Describe what the skill does, how to invoke it, and provide invocation examples.

7.  **Review the draft.**

    Re-read the completed SKILL.md with fresh eyes. Check for unnecessary verbosity, redundant rules, or instructions that assume too much. Trim anything that isn't pulling its weight.

8.  **Validate the skill.**

    Run the bundled validator against the new skill directory:

    ```sh
    scripts/validate.sh <path/to/new-skill-dir>
    ```

    The script wraps `skills-ref validate` (if installed) for canonical Agent Skills checks, and adds repo-specific checks: sibling `README.md`, ~300-line limit, presence of `## Instructions`/`## Rules`, and `## Success criteria`. Fix any reported failures before finishing.

##  Rules

-   **The `description` field is the primary trigger mechanism.**

    It determines whether an agent invokes the skill. Err toward being explicit rather than brief. A vague description leads to the skill being ignored. Follow this two-sentence pattern, written in the third person:

    1. *First sentence* - what the skill does.
    2. *Second sentence* - `Use when ...` followed by specific triggers (user phrasings, situations, file types, contexts).

    ```
    ✅ Good:
    Extract text and tables from PDF files, fill forms, merge documents.
    Use when working with PDF files or when the user mentions PDFs, forms,
    or document extraction.

    ❌ Bad:
    Helps with documents.
    ```

    The bad example gives the agent no way to distinguish this from other document-related skills. The good example names both the capability and the trigger conditions.

-   **Instructions versus rules.**

    Instructions are ordered steps — the procedural workflow the agent follows. Rules are individual, non-sequential guidelines, recommendations, and constraints – the most important ones come first.

    Keep them separate. Don't embed rules inside instructions.

-   **Explain the why behind non-obvious requirements.**

    Instead of bare imperatives (`ALWAYS do X`), explain the reasoning so the agent can apply judgment in edge cases. Well-reasoned instructions are more robust than rigid rules. When multiple approaches are valid, prefer explaining the *purpose* over prescribing exact steps — an agent that understands the why makes better context-dependent decisions.

-   **Match prescriptiveness to fragility.**

    Be prescriptive — exact commands, flags, ordering — when operations are fragile, consistency is critical, or a specific sequence must be followed. Otherwise, avoid enumerating every edge case in the body; handle genuinely tricky ones in an "edge cases" section or a `references/` file. Simple skills need only Instructions and Success criteria.

-   **Provide defaults, not menus.**

    When multiple tools or approaches could work, pick one as the default and mention alternatives as escape hatches. The agent should follow the default unless there is a specific reason not to.

-   **Favor procedures over declarations.**

    Teach the agent *how to approach* a class of problems, not what to produce for a single instance. A reusable method that generalizes beats a hardcoded answer.

-   **Write for token efficiency.**

    Skills are loaded into the agent's context window. Keep SKILL.md under ~300 lines. Offload deep detail to `references/` files; link them with a trigger condition so they're only read when needed. If the same logic recurs across runs — parsing a format, validating output, building a fixture — extract it to `scripts/` rather than duplicating it in prose.

-   **Gotchas live in `SKILL.md`, not in references.**

    Environment-specific facts that defy reasonable assumptions (wrong field names, soft-delete filters, non-obvious API constraints) MUST stay in the main file — the agent needs them *before* it encounters the situation. When an agent makes a mistake you have to correct, add the correction to the edge cases section.

-   **Use imperative form in instructions.**

    "Use this format", not "You should use this format".

-   **Use consistent terminology.**

    One word means one thing. Avoid synonyms. For example

-   **Reach for proven structural techniques** when the situation calls for them:

    -   *Step checklists* (`- [ ] Step N`) for multi-step workflows where the agent must track progress across dependencies or validation gates.

    -   *Output templates* — provide a concrete template rather than a prose description; agents pattern-match against structure more reliably than they interpret descriptions. Long or conditional templates belong in `assets/`.

    -   *Validation loops* — instruct the agent to run a validator, fix any failures, and repeat until it passes.

    -   *Plan-validate-execute* — for batch or destructive operations, have the agent produce a plan, validate it against a source of truth, then execute. The validator MUST produce error messages specific enough for the agent to self-correct.

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

-   **Improving an existing skill**:

    Read the current SKILL.md first, then treat the improvement like a new draft. Rewrite rather than patch. Preserve the `name` field unchanged.

-   **Skill already exists in Anthropic's repo**:

    Use it as a reference for domain knowledge, but adapt the instructions and format to this repo's template and style. Don't copy verbatim.

## Success criteria

-   **Frontmatter is valid.**

    `name` and `description` fields are present and non-empty. `name` matches the directory name.

-   **All REQUIRED sections are present.**

    At minimum: a titled intro paragraph, `## Instructions`, and `## Success criteria`.

-   **The skill is token-efficient.**

    No section is padded with detail that belongs in a `references/` file. SKILL.md is under ~300 lines.

-   **The `description` is specific enough to trigger correctly.**

    It names both the capability and the contexts that should invoke it — not just a one-line summary of what the skill does.

-   **A `README.md` exists alongside the `SKILL.md`.**

## References

- [Skill template](./assets/skill-template/skill-name/SKILL.md): The bundled SKILL.md template to base new skills on.

- [Example skill — commit](../commit/SKILL.md): A well-formed example of a minimal skill (no bundled scripts or references).
