# The structure of the workspace

What each folder and each file in the workspace root (the folder into which the
environment's repository was cloned) is, who reads it, and what breaks without it. The
words with a meaning of their own here get their gloss at first use; all of them are in
the [glossary](glossary.md).

The numbers in the document are not dated, but re-measurable: the block in
[README.md](../../README.md) prints them all.

```
<workspace root>                ← the clone of the environment's repository
├── CLAUDE.md                   the house rules; loads by itself in every session
├── README.md                   the entry page
├── IMPACT.md                   what breaks if something is touched, with verifiable commands
├── STATE.md                    the environment's state plus the next session's prompt — IGNORED
├── plugins.lock.json           the pinned versions of the plugins
├── .gitignore                  what stays out: projects/, records/, /STATE.md, /CLAUDE.local.md
├── .claude/launch.json         the local server the diagrams are drawn from
├── bin/                        the tools: verification, restore, move, usage, the diagrams
├── docs/                       the environment's documentation, after the Divio model
├── example/                    a whole work item, frozen after review
├── records/                    the personal layer: the records, the memory, the house rules — IGNORED
├── skills/                     the skills written here, not taken from plugins
├── template/                   what a new project starts from
└── projects/                   one folder per project — IGNORED by git
```

The tracked repository is the framework (the repository with the rules, skills and tools
common to all projects). `records/` and `projects/` sit in its folder, but are separate
repositories, ignored by it.

## The files at the root

| File | What it is | Who reads it |
|---|---|---|
| `CLAUDE.md` | the file with the rules every session of the project loads: the order of the skills, the rules for the modes, the link to the journal | Claude Code, automatically, in every session |
| `README.md` | what the repository is, the map, how it is restored on a new machine | a human who arrives here for the first time |
| `IMPACT.md` | the impact map (the table of what breaks at each change, with the command that checks it): a tool, a folder name or the lockfile; the fourth column of each row is a command that exits with 0 as long as the row is true | `bin/check-maps.sh`, plus whoever is about to touch something |
| `STATE.md` | the state file (the project's state and what comes next, rewritten at every end of session): the measured state of the environment, what does not work, the work of the next session. **Ignored by git**, local on each machine | the human and the agent, at the start of every session |
| `plugins.lock.json` | the pinned marketplaces (the repositories the plugins are installed from) and plugins, each with URL and SHA | `bin/restore-env.sh` and `bin/check-lock.sh` |
| `.gitignore` | what stays out of the repository: `projects/`, `records/`, `/STATE.md`, `/CLAUDE.local.md` | git |
| `.claude/launch.json` | the "diagrams" configuration: the local server, on port 8766, from which `bin/diagrams.html` is opened | the Claude application, when a preview starts |

`CLAUDE.md` loads by itself, `README.md` does not. What has to reach every session
without anyone asking goes into `CLAUDE.md`, and that is why that file stays short: every
line in it is paid for at every start.

`STATE.md` does not come with the clone. It is ignored because it describes what was
measured on **one** machine, today, and what **one** human has to do tomorrow. On a new
machine it is written at the end of the first session.

The rule belongs to the **environment**: a project's `STATE.md` goes into its own
repository, and `template/STATE.md` stays too, because it is a template.

⚠ **`STATE.md` is not allowed to grow.** What closes **leaves** it: system problems
go to `records/journal/`, decisions worth explaining to `docs/explanation/`, the
rest is deleted, because git keeps it anyway. A state file that only grows is no
longer read, and then it is no longer true either.

## `bin/` — the tools

Nine scripts and a page. The six for verification and restore exit with 0 when the thing
verified is in order and with something else when it is not, so they can be chained
with `&&`. `usage.py` measures, and `move-md.py` moves; neither verifies.
`merge-claude-config.py` is not called by hand: the restore calls it.

| Tool | What it does | When it is run |
|---|---|---|
| `check-docs.py` | verifies the documentation of a tree: links, anchors, paths written in prose, the kind of each document and the shape of the tree; it also reads `example/`, with its records | after any writing in the documentation or move of a folder |
| `values.py` | says which command, path or number disappeared from a set of documents compared with a git revision; a value moved into another document is not a loss | at every documentation rewrite, before the commit |
| `diagrams.html` | draws every Mermaid diagram in a document and says which ones do not draw; a page, not a script | after a diagram is written or changed, opened in the application's browser |
| `check-maps.sh` | runs the commands in the fourth column of every `IMPACT.md` under the root; a command that exits with 77 is skipped, not failed | after any code change that could invalidate a map |
| `check-lock.sh` | verifies, **without the network**, that every SHA in the lockfile really exists in the repository the lockfile names | at the start of the session, and after any plugin update |
| `make-lock.py` | regenerates `plugins.lock.json` from the current installation | after a plugin was installed or updated |
| `restore-env.sh` | restores the environment on a new machine, from the lockfile; it **merges** the three files in `~/.claude/`, it does not rewrite them, it makes the skeleton of the personal layer when `records/` is missing and it links the agent's memory for the root and for every project | once, on a clean machine, and after every new project |
| `merge-claude-config.py` | merges `settings.json`, `known_marketplaces.json` and `installed_plugins.json` in `~/.claude/` with what the lockfile requires, changing only the keys the lockfile asks for | from `restore-env.sh`, at every restore |
| `usage.py` | counts every session from Claude Code's local logs at the API price and shows where the tokens went: the conversation re-read, the writing into the cache, the output | after a handoff between models, to see whether it paid off |
| `move-md.py` | moves a file or a folder with `git mv` and rewrites the markdown links that leave it or arrive at it | when a record is moved and when a work item is closed |

"Skipped" is a test that cannot run on this machine: it exits with 77 and is not counted
as failed. "The handoff", in the row of `usage.py`, is the note in `STATE.md` for the
next session.

⚠ **`check-docs.py` receives a root, not a pattern.** Given a project root, it reads
the top-level documents plus everything under **its** `docs/`; given a `docs/` tree
itself, it has a third term precisely for this case.

Without it, the verification would have passed reading **a single** file in the whole
tree — it happened.

It reads its `docs/`, not the docs of the projects inside. Otherwise "the environment is
clean" would be a claim about another tree. The projects are verified each with its own
root.

`STATE.md` is not verified for reachability. It is ignored by git, so a link to it would
be broken on a fresh clone, and a `README.md` that links it would be wrong. The map names
it without linking it, on purpose.

The links **from** it are still verified: it is the next session's prompt, and a broken
one there costs a session.

`check-maps.sh` uses `eval`, and that is appropriate here because the commands come
from files of the repository. It would not be appropriate if the source came from
outside. A literal `|` in a command is written `\|`, as the markdown
table requires anyway, and the tool hides it before splitting into columns.

⚠ **`make-lock.py` has to find out in which repository each plugin lives**, and the
answer is not uniform: in `marketplace.json`, `source: "./"` means the plugin **is**
the marketplace's repository itself, and `source: {"source": "url", …}` means a
separate repository.

Both forms appear in the present installation, so a script that looks for the SHA only
in the marketplace's repository succeeds on some of the plugins and seems to work.

`restore-env.sh` clones over HTTPS, not over SSH. The remotes configured locally may be
SSH, and on a machine without a key in the agent those fail with an authentication error
that looks nothing like the real cause.

## `tests/` — the tests

A test is a script that calls the code and checks the answer. The shape of the tests is a
convention of the **framework**, not of the human: it lived only in the agent's memory,
that is, on a single machine, until it came in here.

- the tests sit in a tree: `tests/` at the root, `<domain>/tests/` in a project with
  domains;
- the collector is `./test`, one per repository, with no skip list;
- discovery is by the execute bit, not by extension, and each test's shebang says how
  it is run;
- a test that cannot run on this machine defends itself, exiting with code **77**, and
  is counted as skipped, not as failed — by `./test` and by `check-maps.sh` alike, when
  the test is the command of a row in `IMPACT.md`;
- the verdict is the exit code, not the last line printed.

## `docs/` — the environment's documentation

The environment's documentation, after the Divio model. The table of contents and the
difference between the four kinds are in [docs/README.md](../README.md).

| Folder | What it contains |
|---|---|
| `tutorial/` | a single document: the complete cycle of a project, with all the plugins |
| `how-to/` | one guide per question, each answering only one |
| `reference/` | this structure, plus one document per installed plugin |
| `explanation/` | why it is made this way: what each plugin does, how it triggers, what breaks on overlap |

## `example/` — a work item carried to the end

The example is a small project, carried whole through the four sessions and frozen. It
is the tutorial's project, `greeting.sh`, with its work item frozen after review: the
request, the spec, the plan, the closing and the state file, in the exact forms the
sessions leave.

The story, with the handoffs quoted, is in [example/README.md](../../example/README.md).

It is allowed to carry dates, although it is tracked by git: it is a fabricated record,
not documentation, and the `records/` under it belongs to the example, not to the
personal layer.

Who checks it: `check-docs.py` reads it whole, `./test` runs its test, `check-maps.sh`
runs its map, and `tests/test-example.py` reads its forms from the skills.

## `records/` — the personal layer

The personal layer is `records/`, the clone of a private repository of the human's, with
their records. The framework's repository ignores it. It holds the human's records, the
agent's memory and the house rules (the rules that describe the human's place, not the
framework) — what describes a human and their machines, not the framework.

| Record | What it holds | The index |
|---|---|---|
| `journal/` | the problems of the laptop and of the environment, with the machine written in each entry | `INDEX.md`, in the personal repository |
| `pitfalls/` | the code pitfalls, with the method by which they were caught | `INDEX.md`, in the personal repository |
| `decisions/` | the decisions, with the reason, the history and the rejected alternatives | `INDEX.md`, in the personal repository |
| `work/` | the work items with a plan, each in a folder | `INDEX.md`, in the personal repository: the state of all and the backlog |
| `memory/` | the agent's memory, linked from `~/.claude/projects/.../memory` | — |
| `house-rules.md` | the language, the machines of the house, access to them, the names from the template — loaded through `CLAUDE.local.md` | — |
| `local-workers.md` | the machines, the access, the bridge, the table of measured workers | — |

A record is a series of dated entries, which are appended and not rewritten: one file
per entry, dated in its name, untouched after it is written. Only its index is rewritten
— it is the map, the entries are the facts.

In `local-workers.md`, a local worker is a model that runs on one of the human's machines
and takes small tasks, and the bridge is the tool that gives the worker the task and
returns the diff only if the verifier passed.

`journal/` goes into the personal repository, with the machine written in each entry: a
repair from yesterday is useful on the next laptop too, and kept only locally it would
die with this one. Only `STATE.md` stays local.

A project in `projects/` keeps its records in its own repository, tracked by git, because
they belong to the project, not to one particular human. A project's work item, journal,
pitfalls and `STATE.md` sit there, not here; here sit only the framework's.

No tracked file of the framework links into `records/`. A path written in prose is how
the framework names its contract with the personal layer, but a link would resolve on
today's machine and break on a fresh clone, where the folder is missing.
`bin/check-docs.py` catches it, printing `PERSONAL:`.

`bin/check-docs.py` enters `records/` only for links. The file and the anchor of every
link there are verified; repetition, size, kind and reachability are not.

An entry is allowed to be long and to repeat a phrase from an older entry — that is what
a record does — but a broken link in it costs a session, because that is where someone
looks up what has already been hit.

### `records/journal/` — the system problems

Problems of the **environment** and of the laptop — plugins, `node`, tools — not of a
particular project. A machine kept by a project has its history in the project's journal,
which is in git. The code pitfalls sit in `records/pitfalls/`.

The file names are `YYYY-MM-DD-subject.md`, with the date first, so that alphabetical
order is also chronological. The sorting is done by the file system, not by a field
kept up to date by hand.

The index, in `records/journal/INDEX.md`, is read first. Without it, looking for an
already solved problem becomes a `grep` through the whole folder. A tool of a project,
even installed on the laptop, is written in the project's journal, not here.

How an entry is written: [How to solve an environment problem](../how-to/fix-an-environment-problem.md).

### `records/work/` — the work items

A work item with a plan has a folder (the folder with its spec, plan and closing), not two
files in two folders: `open/<YYYY-MM-DD-subject>/` while it is open, `closed/` after. The
forms of the files are in the `documentation` skill.

| The file | What it answers |
|---|---|
| `README.md` | what is pursued and why, in plain terms, for humans |
| the spec, `<folder>-design.md` | **what** is done and **why**, with the rejected alternatives |
| the plan, one or more | **in what order**, with a verification command at each step |
| `closing.md` | what came out and where each leftover went |

`INDEX.md`, the work index, keeps the state of all: in progress, not started, the backlog
(what waits without a folder: leftovers, requests, defects found), closed.

⚠ **A plan without a spec is a list of intentions.** The spec is where the rejected
alternatives are written; without it, the first session that runs into a decision
thinks it has found a loophole and "repairs" it back.

A plan step closes with a command that exits with 0, not with a claim.

⚠ **A work item is closed only when every leftover has a destination.** A leftover is a
task not done from a work item; without a destination, it stays in a plan that nobody
opens any more.

### `records/decisions/` — the decisions

One decision per file: the rule or the choice, who asked for it, why, the history and
the rejected alternatives. The rule itself sits in `CLAUDE.md` or in its skill; here
sits why it is so. A changed decision gets a new entry.

## `skills/` — the skills written here

The skills here (a skill is a set of instructions that enters the conversation when the
situation matches) are written in the framework, not taken from plugins. They live in the
repository and are symlinked into `~/.claude/skills/`, where Claude Code looks for them.
The link is made by `bin/restore-env.sh`, so they appear by themselves on a new machine.

| Skill | What it does | When it is invoked |
|---|---|---|
| `documentation` | the five kinds of document, the rule for when the documentation already exists, and what is never written | before writing or rewriting documentation |
| `end-of-session` | reads from git what changed, rewrites `STATE.md`, proposes the record entries that are missing | at the closing of a session, or by typing `/end-of-session` |
| `execute` | carries a written plan to the end: the plan header, the local worker, the stop rules, the closing on the branch | in the new session that executes a handed-over plan, or by typing `/execute` |
| `local-workers` | how `records/local-workers.md` is built and kept up to date: which machines, which numbers, the bridge contract | when the human has models or tools on their machines, or by typing `/local-workers` |

The plan header, in the row of `execute`, is the first lines of a plan, with the model
and who merges the work.

All four have a length threshold: under 150 lines. A `SKILL.md` is read at every
invocation, so every line is paid for every time. What is read only once goes into
`references/`. The threshold is verified by four rows in `IMPACT.md`, so it cannot be
broken silently.

⚠ **The source is a single one, and it is the one in the repository.** A second copy
once existed in a project, which had fallen 70 lines behind without telling anybody. A
copy of a skill never says it is old.

The skill loader follows symlinks — verified, not assumed: the linked skill appears in
the session's list. So the link holds, and there is no need for a copy plus a
`diff` to compare it.

## `template/` — what a new project starts from

The template is the `template/` folder, from which a new project starts. It is copied
over the folder of a new project, and the placeholders in it are filled in.

```
template/
├── CLAUDE.md               the rules specific to the project, if it has any
├── README.md               the entry page, with the documentation map
├── IMPACT.md               the impact map, with verifiable commands
├── STATE.md                the state plus the next session's prompt
├── .gitignore
├── docs/
│   ├── README.md           the table of contents, with the difference between the kinds
│   └── tutorial/ how-to/ reference/ explanation/    (with .gitkeep)
└── records/
    └── pitfalls/ journal/ decisions/ work/    one INDEX.md each, with no entries
```

Who reads each top-level file, and what they look for in it:

| Document | For whom | What it answers |
|---|---|---|
| `README.md` | a human deciding whether the project interests them | what it is, what it does, where to start |
| `CLAUDE.md` | the session that has just started | what breaks the project if it is not known: its commands, what is source and what is a copy, the order in which the code is read |
| `IMPACT.md` | whoever is about to touch something | what breaks if you change X, with a command that can prove it |
| `STATE.md` | the next session | the measured state, what does not work, what is done next |
| `records/` | whoever runs into a problem that seems familiar | what has happened before, with the date next to it |

`CLAUDE.md` is the only optional one, and that is a rule, not an oversight. It loads at
every session start, so a file whose sections were left empty costs at every
start without giving anything in return.

The template ships it as a list of questions precisely so that the answer "none applies
here" leads to a deleted file, not to an empty one.

The rows that point to `IMPACT.md` and `STATE.md` stay in the map of `README.md`. A
project that removes them leaves its agent files unmentioned on the first page, and
whoever opens the project searches for them through the folder — exactly the case the
rule came out of.

How it is used: [How to start a new project](../how-to/start-a-new-project.md).

## `projects/` — the projects

One folder per project, each with its own repository. This folder is the only entry in
`.gitignore`, so nothing in it reaches the environment's repository.

How a new one is made: [How to start a new
project](../how-to/start-a-new-project.md).

The repository's name is not necessarily the folder's name. A project renamed locally may push to a repository with the old name, and renaming the repository breaks
the existing clones. Which repository each project has is read from the source, not from
a list kept by hand:

```bash
for p in projects/*/; do
  if [ "$(git -C "$p" rev-parse --show-toplevel 2>/dev/null)" = "$(cd "$p" && pwd -P)" ]; then
    printf '%-26s %s\n' "$(basename "$p")" "$(git -C "$p" remote get-url origin 2>/dev/null || echo 'no remote')"
  else
    printf '%-26s %s\n' "$(basename "$p")" 'NOT A REPOSITORY'
  fi
done
```

⚠ **A folder without its own repository gives no error, but the environment's remote.**
`git -C` climbs from parent to parent until it finds a repository, and `projects/` sits
inside the environment's clone. That is why the loop first compares the root git found
with the folder itself.

The comparison uses `pwd -P`: git returns the path without symlinks, and with a plain
`pwd` a real project, opened through a link, would appear as "not a repository".

⚠ **`projects/` is ignored, so `grep` in a session skips it.** The shell function
respects `.gitignore`; a search that must cover the projects too is done with
`/usr/bin/grep`.

⚠ **A session for a project is opened in its folder.** Claude Code loads at launch the
`CLAUDE.md` of the starting folder and of its parents.

Those in subfolders it loads at the first file read from there with the Read tool: the
whole chain of `CLAUDE.md` enters (all the `CLAUDE.md` files from the root down to the
folder being read); `cat` brings nothing.

The agent's memory is per starting folder too; that is why the restore links it for
every project from the same `records/memory`.

## What is not in the repository

Keys, tokens, databases, `.env` files. They are not ignored — they **are not in the
folder at all.** They live next to the services that use them, on their machines.

Nor are the plugins here. They are tens of megabytes of foreign code, and the lockfile
does the same job with a few kilobytes: the restore from an empty `HOME` exits with 0.
