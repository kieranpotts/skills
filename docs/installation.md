# Installation

There are two ways to install these skills:

1.  **skills.sh** – RECOMMENDED:

    Change to the root directory of the project in which you want to install these skills. Then use Vercel's [skills CLI](https://www.skills.sh/), which fetches the skills directly from GitHub and installs them in the paths supported by your target agents, relative to the current working directory.

    Examples:

    ```sh
    # Use interactive picker to choose which skills to install.
    npx skills add kieranpotts/skills

    # Install all skills from this repository.
    npx skills add kieranpotts/skills --all

    # Install one specific skill.
    npx skills add kieranpotts/skills --skill commit

    # Target a specific agent.
    npx skills add kieranpotts/skills -a claude-code

    # Preview available skills without installing.
    npx skills add kieranpotts/skills --list
    ```

    The CLI's `add` command installs the skills files into the local project, into paths that are detected by your target agents. Re-run the command periodically to pick up upstream changes.

    Every mainstream agent is supported – [see the list here](https://www.skills.sh/agent).

    Whenever you install skills using this CLI, anonymous telemetry data will be collected that will feed into the leaderboards on the [skills.sh website](https://www.skills.sh/), helping others to discover popular skills.

2.  **Custom installer:**

    Alternatively, you can run this repository's own [`./run/install`](../run/install) script. This supports fewer agents, but it supports installation of skills at the user/global level, as an alternative to per-project installation.

    Not all agents currently auto-detect skills installed in the user's home directory. As of May 2026, Claude Code and Pi do, but Copilot and Cursor do not. However, you can configure most agents to detect skills at specific paths. So, if you install these skills globally, you may need to review you agents' configuration to ensure the skills are discoverable by them.

    User-level installation is particularly useful because this repository's skills are focused on universal development workflow steps like "plan", "branch", "commit", and "release".

    To run the custom installer, clone this repository to your computer, then run `./run/install` from the repository's root directory. At least one agent flag is required: `--claude`, `--pi`, `--copilot`, and/or `--cursor`. Alternatively, use `--all` to install the skills in a format that is recognized by all four agents.

    By default, the installer will place the skills files in a subdirectory of the current user's home directory (ie. the default install directory is "~"). For example, the Copilot skills will be installed at `~/.github/instructions/<skill-name>.instructions.md`.

    To install the skills on a per project basis, supply the path to the root of the target project via the `--dir` parameter.

    By default, the skills files are transpiled to artifacts understood by each target agents, and those artifacts are copied into the target installation directories. But if you pass the `--symlinks` parameter, symlinks targetting the built artifacts in the cloned repository will be installed instead. This is mostly useful when developing and evaluating these skills, as your changes will be immediately detected by new agent sessions.

    You can also use the `--uninstall` flag, in combination with the other targetting flags, to remove particular skills installed at particular locations – eg. `--claude --copilot --dir ~/dev/project`. Only skills installed by the `./run/install` script will be deleted; skills installed by other tools will not be.

    Use `./run/install --help` for detailed guidance. Here are some examples:

    ```sh
    # Claude only, installed at the user-level.
    ./run/install --claude

    # Pi only, installed at the user-level.
    ./run/install --pi

    # All four agents installed at the user-level.
    ./run/install --all

    # Claude and Cursor, installed into cwd.
    ./run/install --claude --cursor --dir .

    # All four agents, into a project in another directory.
    ./run/install --all --dir ~/dev/my-project

    # All four agents, installed as user-level symlinks.
    ./run/install --all --symlinks

    # Remove Claude's user-level install.
    ./run/install --uninstall --claude

    # Remove Pi's install from a particular project.
    ./run/install --uninstall --pi --dir ~/dev/my-project
    ```
