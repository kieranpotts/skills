# Installation

There are two ways to install these skills:

1.  **skills.sh** – RECOMMENDED:

    Change to the root directory of the project in which you want to install these skills. Then use Vercel's [skills CLI](https://www.skills.sh/), which fetches the skills directly from GitHub and installs them in the paths supported by your target agents:

    ```sh
    # Interactive skill picker.
    npx skills add kieranpotts/skills

    # Install all skills from this repo.
    npx skills add kieranpotts/skills --all

    # Install one specific skill.
    npx skills add kieranpotts/skills --skill commit

    # Target a specific agent (default: prompts).
    npx skills add kieranpotts/skills -a claude

    # Preview available skills without installing.
    npx skills add kieranpotts/skills --list
    ```

    The CLI's `add` command installs the skills files into individual projects. Re-run the `skills add` command in each project where you want the skills to be available to agents. Re-run the command to pick up upstream changes.

    [Every mainstream agent is supported.](https://www.skills.sh/agent).

    Whenever you install skills using this CLI, anonymous telemetry data will be collected that will feed into the leaderboards on the [skills.sh website](https://www.skills.sh/), helping others to discover popular skills.

2.  **Custom installer:**

    Alternatively, you can run this repository's own [`./run/install`](../run/install) script. This supports fewer agents, but it offers a bit more flexibility by allowing skills to be installed at the user/global level (for agents that support this), as an alternative to a per-project installation.

    Clone this repository to your computer, then run `./run/install` from the repository's root directory. At least one agent flag is required; running the script with no arguments prints the help text.

    Use `./run/install --help` for detailed options. Here are some examples:

    ```sh
    # Claude only, user-level (default).
    ./run/install --claude

    # Pi only, user-level (default).
    ./run/install --pi

    # Claude into a specific project, Cursor into cwd.
    ./run/install --claude ~/dev/my-project --cursor .

    # All four agents; Claude/Pi user-level, Cursor/Copilot in cwd.
    ./run/install --all --cursor . --copilot .

    # Per-project install, one tool.
    ./run/install --cursor ~/dev/my-project

    # Remove Claude's user-level symlinks.
    ./run/install --uninstall --claude

    # Remove Pi's symlinks from a particular project.
    ./run/install --uninstall --pi ~/dev/my-project
    ```

    The custom installer currently supports four coding agents: Claude Code (`--claude`), Pi (`--pi`), Cursor (`--cursor`), and GitHub Copilot (`--copilot`). The `DIR` argument controls where the skills are installed:

    - **Claude and Pi:** `DIR` is OPTIONAL. Defaults to `~` (user-level). Pass any other path to install at project-level.
    - **Cursor and Copilot:** `DIR` is REQUIRED. These tools only auto-discover skills in project directories. Passing `~` is allowed but the installer will warn, since the files will not be picked up.

    A leading `~` in any `DIR` is expanded to `$HOME`. Use `.` for the current working directory.

    The target installation paths are:

    | Tool | Per-project | User |
    |------|-------------|------|
    | Claude Code | `<DIR>/.claude/skills/<skill>/` | `~/.claude/skills/<skill>/` |
    | Pi | `<DIR>/.pi/skills/<skill>/` | `~/.pi/agent/skills/<skill>/` |
    | Cursor | `<DIR>/.cursor/rules/<skill>.mdc` | – |
    | Copilot | `<DIR>/.github/instructions/<skill>.instructions.md` | – |

    Claude and Pi installs are **symlinks**, which means you can edit a skill in this repo and those tools will pick up the change immediately. This is useful for local development of these skills, because you can evaluate your changes faster.

    Cursor (`.mdc`) and Copilot (`.instructions.md`) installs are **generated files**, because both need different frontmatter than the [conventional `SKILL.md` format](https://agentskills.io/home). So if you edit a skill in the cloned repository, you will need to re-run `./run/install` to refresh the skills in these agents.

    The install script will not overwrite anything it didn't create. For Claude and Pi, it only touches a symlink whose target points back into this repository. For Cursor and Copilot, it identifies its own files via a marker comment in the generated skills files.

    The custom installer also provides a mechanism for uninstalling skills. The `--uninstall` flag is used with the same combination of other flags (eg. `--claude --copilot ~/dev/project`). The script will only uninstall what it previously installed. Empty target directories will be pruned.
