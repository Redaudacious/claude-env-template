# Conflicts and pitfalls

The pitfalls below (a pitfall is what cost time, with the method by which it was found)
were met while installing the four plugins. Each is written with the method by which it
was caught, because the method is reapplied, and the result is not.

## An "enabled" plugin that does nothing

**The symptom.** `claude plugin list` shows `✔ enabled`. The installation reported
success. Nothing that the plugin promises happens in the conversation.

**The cause.** The plugin's hooks run as separate processes, with the interpreter taken
from the path. Three of the four installed plugins start their hooks with `node`. On the
machine there was no `node`: absent from `/usr/bin`, absent from dpkg, no nvm, fnm, volta
or bun.

**Why it is a pitfall and not a peculiarity.** The installation does not verify the
interpreter at all. It copies files and writes an entry in `~/.claude/settings.json`;
nothing in this chain touches the hooks.

The obvious check — the install command, then the plugin list — passes completely. The
symptom appears only at the next session, as an absence, and an absence produces no error
message.

The Claude Code binary is compiled into a single 250 MB file and has node inside. That
does not help: it does not expose it on the path under the name `node`.

**The method that caught it.** The check is not about the plugin, but about what it calls.
The hooks file is read from `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`
and the command word is looked up.

Then that program is looked for on the path. The general rule: **a successfully installed
plugin says nothing about the programs it calls.**

## The hooks file read wrongly

**The symptom.** A plugin repository contains a `hooks.json` that asks only for `echo`.
The conclusion seems clear: the plugin needs nothing installed.

**The cause.** Repositories that target several tools keep a set of hooks for each. In
caveman, the plugin that compresses the model's answers, `.codex/hooks.json` contains an
`echo` and is meant for Codex.

The hooks for Claude Code sit in a completely different file, `.claude-plugin/plugin.json`,
and call `node`.

**Why it is a pitfall.** Both files are real, both have plausible names, and a search for
`hooks.json` finds the wrong one first — the other does not even have "hooks" in its name.

**The method that caught it.** The file is not looked for by name. The plugin's manifest
is read, which declares by itself the path of the hooks, in the `hooks` field. The general
rule: **in a multi-tool repository, the manifest says which file matters; the file's name
does not.**

## RTK savings lower than expected

**The symptom.** `/rtk-plugin:gain` shows savings far below the ones in the documentation's
example. RTK is here the tool that shortens the output of commands before it reaches the
conversation, so the savings should be large.

**The cause.** The dispatcher leaves uncompressed any command that contains shell
constructs — `|`, `&&`, `$()`. The exclusion is deliberate, so as not to break existing
scripts. A workflow built from `grep ... | head -20` passes entirely by the compressor.

**Why it is a pitfall.** The programs used *are* on the list of 43. `grep` is there, `git`
is there. The obvious check — "is my program on the list?" — passes. What actually decides
is not the program, but the form of the command.

**The method that caught it.** The real form of the commands given is compared, not the
programs. The general rule: **when a tool declares a list of accepted inputs, the list of
exclusions is looked for too; the second is usually shorter and more decisive.**

## The RTK binary downloaded without verification

**The symptom.** None. Everything works.

**The cause.** `scripts/bootstrap-rtk.mjs` downloads an executable from
`github.com/rtk-ai/rtk/releases` at the first session start. Searching for `sha256`,
`checksum`, `signature` and `verify` in the script returns zero matches.

**Why it matters.** That binary does not sit aside: it is placed in front of every shell
command, through the `PreToolUse` hook. It is the deepest position occupied by any of the
four plugins.

It is not a reason to stop it — a plugin downloaded from GitHub is foreign code running
locally anyway, and the other three are in the same situation without downloading
anything. It is a reason to know where the risk lies: not in the plugin, but in the file
the plugin brings later, from a repository different from the installed one.

## Caveman spoils the writing of documentation, unless it is stopped first

**The symptom.** The documentation comes out in fragments, without articles, without
tables.

**The cause.** Caveman's rules apply to every answer until an explicit stop. They ask for
articles to be cut, accept fragments and forbid decorative tables.

**Why it is a real conflict and not a preference.** Good documentation asks for exactly
what caveman cuts: the whole sentence, which can be read in a year by someone else. The
two sets of rules cannot be reconciled by dosing, because they differ not in intensity,
but in purpose — one compresses the text, the other builds it as a product.

**How it is avoided.** By stopping beforehand, not by correcting afterwards: "stop
caveman" or `/caveman off` before writing documentation, restarted after. The steps are in
[How to switch modes](../how-to/switch-modes.md).

## Caveman and superpowers match the same request

**The symptom.** Two different skills (a skill is a set of instructions that enters the
conversation when the situation matches) match the same request.

**The cause.** Of caveman's 21 skills, six cover ground already covered by superpowers,
the plugin that decides the order of the work.

They are `investigate-first` over `systematic-debugging`, `verify-and-stop` over
`verification-before-completion`, `lean-build` over the ponytail ladder, and
`caveman-review` and `caveman-evidence-review` over `requesting-code-review`.

**Why it is a pitfall.** The overlap does not produce an error, but a silent choice. One
of them is applied, and the other is no longer seen to have been missing.

**How it is kept under control.** By explicitly naming the wanted family in the request. A
prompt that says "systematic" or "methodical" pulls toward superpowers; one that says
"caveman" pulls toward the other set.

## Ponytail and superpowers contradict each other only on small tasks

**The symptom.** None visible. The two complement each other for the most part —
superpowers sets the order, ponytail (the plugin that decides how much code is written)
the size.

**The tension, where it exists.** Ponytail asks: "Complex request? Ship the lazy version
and question it in the same response. Never stall on an answer you can default."
Superpowers asks the opposite: the skill is invoked **before any answer,
including before clarifying questions**.

The first rule pushes toward delivering something immediately. The second pushes toward
producing nothing before the method is fixed.

**How it is resolved.** Not by choosing one. The two contradict each other only on small
tasks, where ponytail is right — a one-line request does not deserve ~3,800 tokens of
brainstorming. On large tasks superpowers is right, and the quick delivery of the lazy
version is exactly the mistake the order prevents.

The practical division: **ponytail decides how much is written, superpowers decides
whether it is worth starting.** When the task is clearly small, the first rule wins.
