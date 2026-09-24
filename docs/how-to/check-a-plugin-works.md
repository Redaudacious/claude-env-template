# How to check that a plugin really works

A plugin can show up as `enabled` without doing anything. The reason is in
[Conflicts and pitfalls](../explanation/conflicts-and-pitfalls.md). The checks below
are ordered from the cheapest to the slowest.

The commands need the `claude` binary. Where it is not installed separately, the one
from the desktop application is taken. Its path is not written with a version number:
the application updates itself and keeps only the recent versions on disk, so a path
pinned to one version ends up exiting with 127.

The application keeps its binaries under `~/.config/Claude/` on Linux and under
`~/Library/Application Support/Claude/` on macOS, so the lookup covers both.

```bash
claude="$(command -v claude || { ls -d ~/.config/Claude/claude-code/*/claude ~/"Library/Application Support/Claude"/claude-code/*/claude 2>/dev/null | sort -V | tail -1; })"
"$claude" plugin list
```

`sort -V` compares the numbers in the version as numbers. An ordinary sort puts
`2.1.99` after `2.1.266` and would choose the older version.

## 1. The installation has entered the configuration

```bash
cat ~/.claude/settings.json
```

The plugin must appear in `enabledPlugins` with the value `true`, and its marketplace
(the repository it is installed from) in `extraKnownMarketplaces`. If it is missing from here, the installation was not
written, and the rest of the checks make no sense.

## 2. The interpreter the hooks require exists

What the plugin calls is read, then that program is looked for on the path:

```bash
grep -rhoE '"command": *"[^"]+"' ~/.claude/plugins/cache/*/*/*/hooks/*.json ~/.claude/plugins/cache/*/*/*/.claude-plugin/plugin.json 2>/dev/null | sort -u
```

For each program that appears — usually `node` or `bash` — its presence is checked:

```bash
command -v node
```

A missing program means a dead hook, whatever the plugin list says.

## 3. The mode starts by itself

After restarting the application, in a new session:

```
/ponytail
```

The command is ponytail's, the plugin that decides how much code is written. An answer
that names the active level confirms that the `SessionStart` hook ran. An
answer that the command does not exist means the plugin was not loaded.

## 4. The skills trigger

The skills of superpowers, the plugin that decides the order of the work, have no
command, so they are checked by effect (a skill is a set of instructions that enters the
conversation when the situation matches).

A request is worded that contains a situation, not an action — for example one that declares
uncertainty about the cause of a defect.

The confirmation is the announcement `Using [skill] to [purpose]`. Its absence means
the skill was not applied; the wordings that trigger are in
[How to trigger a skill from a prompt](trigger-a-skill-from-a-prompt.md).

## 5. RTK really compresses

RTK is the tool that shortens the output of commands before it reaches the conversation.

```
/rtk-plugin:gain
```

The dashboard shows the number of routed commands and the savings. Two results need
interpretation:

| Result | What it means |
|---|---|
| "RTK is not installed yet" | the `SessionStart` hook did not download the binary; the application is restarted |
| Zero routed commands, although work was done | the commands given contained pipes or chains, so they went through uncompressed |

The second case is not a malfunction. The check that tells it apart is comparing the
form of the commands given with the exclusion list in
[Reference — RTK](../reference/rtk.md), not with the list of accepted programs.

## 6. The cost paid is the expected one

```bash
claude="$(command -v claude || { ls -d ~/.config/Claude/claude-code/*/claude ~/"Library/Application Support/Claude"/claude-code/*/claude 2>/dev/null | sort -V | tail -1; })"
"$claude" plugin details caveman
```

The example is caveman, the plugin that compresses the model's answers. The report shows
the inventory of components and the permanent cost, plus the cost of each skill at
invocation. It is worth running before enabling a new plugin, not after.
