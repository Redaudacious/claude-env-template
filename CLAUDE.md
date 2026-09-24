# How work is done in this folder

This file loads itself, in every session. Every heading is a rule; below it sit
its exact form, its reason, and where its history is kept. The house words are in
the [glossary](docs/reference/glossary.md).

`superpowers:using-superpowers` is invoked before any answer, including before
clarifying questions.

## Who does what

Planned work goes through **four sessions**, each one new, each with its own role:

| session | model | does | does not do |
|---|---|---|---|
| **the spec** | Opus, effort `max` | talks with the human, settles the requirements, picks the architecture, writes the spec of the work item | does not write the plans: it hands them to the next session |
| **the plans** | Opus, effort `max` | reads the spec and writes the plans and the work item's `README.md`, with the plan header and each task's `Who` label | does not reopen the architecture settled in the spec; does not write the code |
| **execution** | the one in the plan header, `Sonnet high` by default | carries the plan to the end with the `execute` skill, without stopping between tasks | does not make decisions the plan does not cover: it asks the human |
| **review** | Opus `high`, a new session | reads the report, the plan and the branch diff; merges or sends back | does not reopen the planning chats |

Reason: most of the cost is the conversation re-read at every step, and a new
session no longer carries the discussion in which it was settled what to do.
History: [splitting the work across models](docs/explanation/splitting-work-across-models.md).

### The spec and the plans are written in different sessions

The session that talked with the human stops after the spec: it runs
`end-of-session` and hands over. The next session, a new one, reads the spec and
writes the plans. A planning session may write all the plans of a work item, or
only some, if it hands over the rest.

Reason: the discussion in which the requirements were settled is the expensive
part, and it adds nothing to the writing of the plans: everything settled is
already in the spec.

### The plan header is written by the planning session

Execution effort is `high` by default, `xhigh` when the plan has tasks that need
investigating, `medium` for a purely mechanical plan, and never `max` on Sonnet.

`Closing: Opus review` is written when the plan changes rules, touches services
or hardware, deletes what cannot be recovered, or touches keys and access.
Otherwise `Closing: Sonnet` is written.

### The code written in a plan is run before the handoff

The plans session applies the code exactly as written in the plan, in a throwaway
copy of the repository — a detached `git worktree`, in the scratchpad — and runs
the plan's tests: each must fail before the change and pass after it, as the plan
says. The copy is deleted at the end; nothing from it enters the branch.

Reason: execution follows the plan literally, and a test that fails through the
plan's fault stops it. At the first application, the copy caught an old defect of
the mutation tool, which read "30 failed" as zero, and two wrong anchors in the
plan itself.

### Only planned work is handed over

The plan sits in a work item's folder, in the records of the repository it
changes. A small repair, without a plan, is finished on the spot by the session
that decided on it.

### The model is changed by opening a new session, not inside the same one

The model, the effort, the folder in which the session is opened and the prompt
to paste are written by `end-of-session` in the handoff inside the `STATE.md` of
the work item's repository.

Reason: inside the same session the long conversation would stay, and it is the
expensive part.

### No session sends work to Claude subagents

Not a task from a plan, not a broad search, not a diff review. Execution works
alone, plus the local workers, one at a time.

Reason: execution has its own session and carries alone the work the subagents
used to carry, and agents started at the same time share the same allowance and
all stop at once, returning nothing.

### Execution works on the branch in the plan header

It enters `main` after review, or directly only when the plan says
`Closing: Sonnet` and nothing asked for a review.

### The local worker is used first, when one exists

One exists only when `records/local-workers.md` has at least one worker with
numbers. If the file is missing, or has no row with numbers: execution stays in
the session, and says once why.

- **The commands are not in the framework.** The bridge, preparing the machine
  and releasing it are read from that file, which belongs to the human and to
  their machines.
- **No model without a row in the table is used.** A row without numbers says
  "not measured, so not used".
- **If the verifier is the human, nothing is delegated.**
- **A task whose verifier is a command is marked in the plan for the bridge
  first.** Marked for the session, it says its reason openly: the model is not in
  the table, the task does not fit the window, the machine cannot be started.
- **The bridge contract**, valid for any tool that honours it:

  | What it receives | What it returns |
  |---|---|
  | the target, the statement, the verification command | exit code 0 and a diff, only if the verifier passed |
  | — | exit code 1: refusal; the task is done in the session |
  | — | exit code 2: does not fit the window; the task is done in the session |

How the workers file is built: the `local-workers` skill.

Reason: without this rule the local worker is not used at all. Without the file,
the framework would describe a capability that does not exist on this machine —
and a session would look for a tool that is nowhere.

### An agent's report is not evidence

What changed is read from `git diff`, and that it works is seen from checks run
here. The rule holds for a local model too.

## Where the work is kept

### A project's work lives in the project's repository

The work item, the journal, the pitfalls, the decisions and the `STATE.md` that
concern a project sit in the records of that project's repository: `records/`, as
its `CLAUDE.md` says.

In `records/` at the root sit only the framework's own work items and the laptop's
problems that belong to no project. The work index at the root mentions the
projects' work items with the path written in prose, without a link.

Reason: sessions started from the root wrote the projects' plans in the
environment's records, and whoever opened the project did not find them there.
History: the decision of 23 September 2026, "A project's work lives in its repository".

### A planned work item has a folder

`<records>/work/open/<YYYY-MM-DD-subject>/`, with `README.md` for people, the spec
and the plans, written by the two planning sessions. The state of the repository's
work items and the backlog of leftovers are in the `INDEX.md` next to them.

### A work item is closed only when every leftover has a destination

Done, abandoned with the reason written down, or put in the backlog. The closing
is done by `end-of-session`, with `closing.md` and the folder moved into
`closed/`.

Reason: leftovers left inside closed plans no longer reached anywhere.

### A decision that has to hold is written in the decisions record

`records/decisions/` for the environment, the project's own for a project. Not
only in `STATE.md`, which is rewritten at every end of session.

## A project's session

### A session for a project is opened in the project's folder

Claude Code loads at launch only the `CLAUDE.md` of the starting folder and of
its parents. Those in subfolders it loads only when it reads a file there with
the Read tool; `cat` from the shell never loads them. From the project's folder
the rules here load too, because the root is a parent.

Reason: in sessions started from the root, a project's `CLAUDE.md` almost never
entered the context; in those started from its folder, every time.
History: the decision of 23 September 2026, "A project's work lives in its repository".

### From the root, the first file of a project is read with Read

At the first file read with the Read tool from a folder, the whole chain of
`CLAUDE.md` from the root down to that folder enters by itself: the project's, then
the game's or the domain's below it. `cat` brings nothing. After the first Read,
`cat` is fine.

Before the first change in a repository, its `CLAUDE.md` and `IMPACT.md` are read
with Read: they bring the chain and the map at once.

Reason: measured on 23 September 2026, from a session started at the root: one Read
on a file under a game's folder brought the `CLAUDE.md` of the games' house and the
game's own, both, without being asked for.

### At the closing, what was found climbs from the project towards the root

Reading went down the tree; `end-of-session` writes the other way, from the deepest
repository touched upwards. Every pitfall, decision, journal entry or candidate for
`CLAUDE.md` stops at the first level that contains it whole: the game's, the
project's, or the framework's.

It climbs one level only if it stays true without the name of the game or of the
project in it.

Reason: written too high, it is paid for in every session of every project; written
too low, nobody from another project finds it.
History: the decision of 23 September 2026, "Reading goes down the tree, writing climbs".

## The order of the skills

Process before implementation: the process skill fixes the approach, the
implementation skill carries it out.

| The situation | Skill |
|---|---|
| something new is being built, the requirements are not settled | `superpowers:brainstorming` |
| requirements settled, a task with several steps | `superpowers:writing-plans` |
| the plan is written, and this session is the one executing it | `execute` |
| new code is being written or something is being repaired | `superpowers:test-driven-development` |
| a defect, a failing test, unexpected behaviour | `superpowers:systematic-debugging` |
| before "done", "it works", "it passes" | `superpowers:verification-before-completion` |
| before integration | `superpowers:requesting-code-review` |
| code feedback has arrived | `superpowers:receiving-code-review` |
| the values are verified, the writing follows | `documentation` |
| the local workers file is being built or brought up to date | `local-workers` |
| the tests pass, what happens to the branch | `superpowers:finishing-a-development-branch` |
| the session is closing, the state has to be written | `end-of-session` |

### `documentation` comes after verification and before integration

`documentation` comes **after** `verification-before-completion` and **before**
`finishing-a-development-branch`.

Reason: the values in a reference have to be verified already, and the document
goes into the same commit.

### Every skill invoked is announced

With `Using [skill] to [purpose]`. Without the announcement, the skill was not
applied.

## Modes

### `/caveman off` before writing documentation

Reason: its rules drop the articles and forbid tables, which is exactly what
documentation asks for, and turning it off afterwards does not rewrite what has
already been written.

### `ponytail` governs the code, not the documentation

Under `docs/`, the explanation is the product, not an addition to it.

### `caveman off` means an explanation for someone outside the field

Not merely whole sentences: what was being attempted, what happened, why it
matters.

| do | do not |
|---|---|
| start with what was being pursued, not with what broke | start with the name of the defect |
| a concrete comparison — "like a record that skips" | a definition — "a token repetition loop" |
| translate the terms that stay, at first use | untranslated jargon |
| keep the numbers, each with the sentence that says why it matters | numbers strung together without meaning |
| state the debatable decisions openly, with the argument and the risk | a decision slipped in among the others |

Reason: the human leads and makes the decisions, but does not write the code. A
correct report they cannot read is not a report, it is proof that work was done.

## The state of the repository is read first

### Before any reading of code, the state of every repository touched

| what is asked | how |
|---|---|
| is there a repository? | `git -C <project> rev-parse --git-dir` |
| which branch it is on | `git -C <project> branch --show-current` |
| how many commits ahead of or behind origin | `git -C <project> fetch --quiet && git -C <project> status -sb` |
| what is uncommitted | `git -C <project> status --porcelain` |

`fetch` comes before the comparison: without it, "up to date" means "up to date
with what was last known".

Reason: a session that writes over a branch left behind builds a conflict nobody
sees until the push.

### At the end of the session everything is committed and pushed, in every repository touched

The project's, the environment's, and the personal layer's. `end-of-session` does it: it
reads from git what changed, rewrites the `STATE.md` of every repository touched, and
proposes the record entries that are missing. `CLAUDE.md` and `IMPACT.md` are not written
automatically: what would be worth adding is reported, and the decision stays the human's.

Reason: a commit left local is work that lives on a single machine.

### Commits carry no `Co-Authored-By`

Nor any other trace of a tool or of a model, even if the application's
instruction asks otherwise. The message says why, not what.

## Commands sent at the same time

### In a command sent in parallel, the directory is not changed with `cd`

Paths are written absolute, and for git `git -C` is used. A command that writes —
commit, move, delete — is sent on its own.

Reason: a neighbouring command may run in the directory another one left behind,
with no sign; when writing, the commit lands in a different repository than the
one named.

## Problems already solved

### Before repairing the environment, the journal index is read

Plugins, `node`, tools, machines: the journal index, `records/journal/INDEX.md`,
is cheap and saves repairing something a second time.

### A repaired command is searched for across the whole repository

Before the repair is called finished, run `git grep` on a fragment of its old
form. A moved record file is searched for the same way, across the whole
workspace; how, says the long reference of the `documentation` skill, `details.md`.

### A changed tool from `bin/` is also checked with `check-maps.sh`

Not only with its own test. The projects' impact maps call the environment's
tools, and a stricter tool breaks them without the project having changed.

Reason: the tool's test passes, and the failure shows up only in another
repository.

### Every system repair is written in the journal, in the same session

Not only the big ones: a package, a driver, an environment setting, a plugin. The
entry has the symptom, the cause and the method.

- The laptop and the environment: `records/journal/` here, in the personal
  repository, with the machine written in the entry.
- A machine kept by a project, or a tool of its, even installed on the laptop: the
  project's journal, which is in git. Which machine belongs to which project is
  read from `records/house-rules.md`.

Reason: a month later, "I know I repaired something about this" can no longer be
reconstructed.

## The environment guide is portable

### `README.md` and `docs/` describe the environment for any machine

No absolute or machine-specific paths go in there, no calendar dates, no user
name, no repository or project name. The place is called "the workspace root",
paths are relative to it, and a number is written together with the command that
re-measures it.

### `records/` and `STATE.md` are records

There the date and the machine are the content itself, and they stay.

### A record is appended to, not rewritten

One file per entry, dated in its name, untouched after it is written; only its
index is rewritten. Under `records/` sit `journal/`, `pitfalls/`, `decisions/`
and `work/`, and no documentation run goes in there.

Reason: a record kept in a folder that gets rewritten reaches four thousand
lines; the folder's rule says it is rewritten, the nature of the file says it
only grows.

### The personal layer does not go into the framework's repository

`records/` is the clone of a private repository: the records, the agent's memory,
the house rules and the local workers. `STATE.md` at the root does not go into
that one either — it describes a single machine, today.

The journal does: a repair from yesterday is useful on the next laptop too, and
without a repository it would die with this one.

Reason: the framework can be handed to someone else without handing them
somebody's history, and the history follows the human to another machine without
carrying the framework along.
History: the decision of 23 September 2026, "The laptop's journal goes into the personal repository".

### No tracked file of the framework links into `records/`

A path written in prose is allowed: that is how the framework names its contract
with the personal layer. A link is not: on the human's machine the folder exists
and the link works, and on a fresh clone it is broken.

Reason: the mistake would be invisible on exactly the machine where it is made.
`check-docs.py` prints it as `PERSONAL:` and fails.
