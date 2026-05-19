# Installation

The `./run/install` script installs skills into various AI coding tools – currently Claude, Copilot, and Cursor.

## Quick start

From the repo root:

```sh
./run/install                           # Claude only, into cwd.
./run/install --claude ~                # Claude only, user/global.
./run/install --all                     # All three, all into cwd.
./run/install --all --claude ~          # Claude global.
                                        # Cursor and Copilot into cwd.
./run/install --cursor ~/some/project   # Per-project install, one tool.
./run/install --uninstall --claude ~    # Remove Claude's user symlinks.
./run/install --help                    # Show help.
```

## How each tool is supported

All three tools support per-project installs. Claude additionally supports a true user-level install.

| Tool | Per-project | User |
|------|-------------|-------------|
| Claude Code | `<DIR>/.claude/skills/<skill>/` | `~/.claude/skills/<skill>/` |
| Cursor | `<DIR>/.cursor/rules/<skill>.mdc` | – |
| Copilot | `<DIR>/.github/instructions/<skill>.instructions.md` | – |

Each tool flag accepts an optional `DIR` argument:

- `--claude [DIR]`: Symlinks added to `DIR/.claude/skills/`. `DIR` defaults to cwd. Use `~` to instal global skills in the user home directory.

- `--cursor [DIR]`: Generates `.mdc` files, installed into `DIR/.cursor/rules/`.

- `--copilot [DIR]`: Generates `.instructions.md` files, installed into `DIR/.github/instructions/`.

A leading `~` in any `DIR` value is expanded to `$HOME`.

## Live edits vs. regeneration

Claude installs are **symlinks**, which means you can edit a skill in this repo and Claude will pick up the change immediately.

Cursor (`.mdc`) and Copilot (`.instructions.md`) installs are **generated files**, because both need different frontmatter than `SKILL.md`. Edit a skill, then re-run `./run/install` to refresh them in your tooling.

## Conflicts and uninstall

The script will not overwrite anything it didn't create. For Claude, it only touches a symlink whose target points back into this repo. For Cursor / Copilot, it identifies its own files via a marker comment in the generated content.

The `--uninstall` flag removes only what this script installed. Pass the same target flags (and `DIR`) you used at install time.  Empty target directories are pruned.

## Conventions

- Skill directory names follow `<category>-<skill-name>` (flat namespace, required for Claude's discovery model).

- Each skill ships a `SKILL.md` with YAML frontmatter. The install script reads `description` for Cursor's frontmatter. Cursor's `alwaysApply` is set to `true` and Copilot's `applyTo` to `"**"`, whihc means that all skills are always in scope. You may need to tune the targetting per-project.
