# Collision safety for bundled resources

Read this before adding anything to a skill's `assets/`, `references/`, or
`scripts/` directories, to avoid name collisions across a collection of skills.

For Claude Code and Pi, each skill installs as its own self-contained directory,
so subdirectory contents never interact across skills. But for Copilot and
Cursor, skills compile to flat instruction/rules files, and the installer merges
every skill's `assets/`, `references/`, and `scripts/` directories into a single
shared directory at the target. Two skills that both ship `assets/foo.md` will
therefore collide — the second silently overwrites the first.

To avoid this, namespace every bundled file so it is unique across the whole
collection. Either nest it under a directory named after the skill, or prefix
the filename with the skill name:

```
skills/
└── my-skill/
    ├── assets/
    │   └── my-skill/          ← Asset namespaced by a subdirectory
    │       └── template.md      named after the skill.
    └── references/
        └── my-skill-api-errors.md    ← Namespaced by filename prefix.
```

Apply this even if the skill is the only one in a project today. A skill is
portable: it may be installed alongside others later, and a collision then is a
silent data-loss bug.
