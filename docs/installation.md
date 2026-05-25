# Installation

There are two ways to install these skills:

1.  **skills.sh** – RECOMMENDED:

    Change to the root directory of the project in which you want to install these skills. Then use Vercel's [skills CLI](https://www.skills.sh/), which fetches the skills directly from GitHub and installs them in the paths supported by your target agents.

    Examples:

    ```sh
    # Use interactive picker to choose which skills to install.
    npx skills add kieranpotts/skills

    # Install all skills from this repo.
    npx skills add kieranpotts/skills --all

    # Install one specific skill.
    npx skills add kieranpotts/skills --skill commit

    # Target a specific agent.
    npx skills add kieranpotts/skills -a claude

    # Preview available skills without installing.
    npx skills add kieranpotts/skills --list
    ```

    The CLI's `add` command installs the skills files into the project at the current working directory. Re-run the `skills add` command in each project where you want the skills to be available to your agents. Re-run the command to pick up upstream changes.

    Every mainstream agent is supported – [see the list here](https://www.skills.sh/agent).

    Whenever you install skills using this CLI, anonymous telemetry data will be collected that will feed into the leaderboards on the [skills.sh website](https://www.skills.sh/), helping others to discover popular skills.

2.  **Custom installer:**

    Alternatively, you can run this repository's own [`./run/install`](../run/install) script. This supports fewer agents, but it offers a bit more flexibility by allowing skills to be installed at the user/global level (for agents that support this), as an alternative to a per-project installation.

    This is particularly useful because this repository's skills are focused on universal development workflow steps like "plan", "branch", "commit", and "release".

    Clone this repository to your computer, then run `./run/install` from the repository's root directory. At least one agent flag is required: `--claude`, `--pi`, `--copilot`, and/or `--cursor`. Alternatively, use `--all` to install the skills in a format that is recognized by all four agents.

    By default, the installer will place the skills files in a subdirectory of the current user's home directory (ie. the default install directory is "~"). However, not all agents will auto-discover user/global skills by default – unless you explicitly configure them to do so. For universal agent support, you will need to install the skills on a per project basis. Do this by supplying the path to the target project via the `--dir` parameter.

    Use `./run/install --help` for detailed options. Here are some examples:

    ```sh
    # Claude only, user-level (default).
    ./run/install --claude

    # Pi only, user-level (default).
    ./run/install --pi

    # Claude and Cursor, both into cwd.
    ./run/install --claude --cursor --dir .

    # All four agents into a specific project.
    ./run/install --all --dir ~/dev/my-project

    # All four agents, user-level (Cursor/Copilot will warn).
    ./run/install --all

    # Remove Claude's user-level symlinks.
    ./run/install --uninstall --claude

    # Remove Pi's symlinks from a particular project.
    ./run/install --uninstall --pi --dir ~/dev/my-project
    ```

    Claude and Pi installs are **symlinks**, which means you can edit a skill in this repo and those tools will pick up the change immediately. This is useful for local development of these skills, because you can evaluate your changes faster.

    Cursor (`.mdc`) and Copilot (`.instructions.md`) installs are **generated files**, because both have different skill files formats (`.mdc` and `.instructions.md` respectively, with different frontmatter). The installer compiles these proprietary artifacts from the [standard `SKILL.md` source files](https://agentskills.io/home). Therefore, after making changes to the source files, you will need to re-run `./run/install` to refresh the skills in Cursor and Copilot.

    The install script will not overwrite anything it didn't create. For Claude and Pi, it only touches a symlink whose target points back into this repository. For Cursor and Copilot, it identifies its own files via a marker comment in the generated skills files.

    The custom installer also provides a mechanism for uninstalling skills. The `--uninstall` flag is used with the same combination of other flags (eg. `--claude --copilot --dir ~/dev/project`). The script will only uninstall what it previously installed. Empty target directories will be pruned.
