# How to switch modes

Ponytail (the plugin that decides how much code is written) and caveman (the plugin that
compresses the model's answers) are permanent modes: they start at the beginning of the
session and stay active until an explicit stop.

Superpowers (the plugin that decides the order of the work) and RTK (the tool that
shortens the output of commands before it reaches the conversation) have no modes.

## Switching during the session

1. **The current level is checked**, by giving the command without an argument:

   ```
   /ponytail
   ```

   The answer contains the active level.

2. **The level is changed**, by giving the wanted argument:

   ```
   /ponytail ultra
   ```

   Accepted levels: `lite`, `full`, `ultra`, `off`. For caveman, in addition:
   `wenyan-lite`, `wenyan-full`, `wenyan-ultra`.

3. **The mode is stopped** by a command or by a phrase:

   ```
   /caveman off
   ```

   The phrases "stop caveman" and "normal mode" have the same effect. For ponytail:
   "stop ponytail".

The change lasts until the end of the session. The next session restarts from the
default level.

## Changing the default level

For every new session to start at a level other than `full`, this is written to
`~/.config/ponytail/config.json`:

```json
{ "defaultMode": "lite" }
```

The alternative, if an environment variable is preferable: `PONYTAIL_DEFAULT_MODE=lite`.

Both accept `lite`, `full`, `ultra` and `off`. The value `off` leaves the plugin
installed and the skills available, but does not start the mode by itself.

## Caveman is stopped before writing documentation

Caveman and the writing of documentation contradict each other at the root — the
reason is in [Conflicts and pitfalls](../explanation/conflicts-and-pitfalls.md).

Here, `caveman off` means more than stopping the compression: it is the mode in which the
model explains for someone outside the field. That is, whole sentences, but also concrete
comparisons, numbers with their meaning and the decisions stated openly.

1. Before asking for documentation:

   ```
   /caveman off
   ```

2. The documentation is asked for.
3. Afterwards, if the mode is wanted back:

   ```
   /caveman full
   ```

The order matters: stopping after the document is written does not rewrite it.

## The plugin is disabled so that it costs nothing any more

Switching the mode does not unload the plugin, so the permanent cost is still paid.
To remove that cost too, the plugin is disabled:

```bash
claude="$(command -v claude || { ls -d ~/.config/Claude/claude-code/*/claude ~/"Library/Application Support/Claude"/claude-code/*/claude 2>/dev/null | sort -V | tail -1; })"
"$claude" plugin disable caveman
```

Re-enabling is done with `enable` instead of `disable`. Both require restarting the
application. Why the binary is looked up this way, and not on a fixed path, is
explained at the start of the guide
[How to check that it works](check-a-plugin-works.md).

Ponytail writes state outside its own folder too. Its complete uninstallation is
described in [Reference — ponytail](../reference/ponytail.md).
