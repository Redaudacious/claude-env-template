# The documentation of the working environment

The documentation covers two things: **the workspace** — the folders, the tools, the flows by which
a project is started or something is repaired — and **the four plugins** pinned in
`plugins.lock.json`: superpowers, ponytail, caveman and RTK.

The plugins do not do the same thing, although they all promise "less". They touch four different
layers of the same conversation: superpowers sets **the order of the work**, ponytail **how much
code is written**, caveman **how the answer is worded**, RTK **how much of a command's output
reaches the conversation**. That is why they can be kept together without cancelling each other.

What the repository itself is and how it is restored on a new machine is in the
[README.md](../README.md) at the root.

The documentation is split into four kinds of text, each with a different purpose. A document that
tries to do all four is good at none.

| Kind | What is looked for | Folder |
|---|---|---|
| Tutorial | learning the flow, from zero | `tutorial/` |
| How-to guide | solving a specific problem | `how-to/` |
| Reference | an exact value, a command, a cost | `reference/` |
| Explanation | the reason behind a decision | `explanation/` |

## Tutorial

It is read only once, in order, with hands on the keyboard.

- [The first work item, through the four sessions](tutorial/first-work-item.md) — a small work item, from request to closing: the spec (the document that decides what is done and how), the plans, the execution, the review

## How-to guides

Each answers a single question.

- [How to write a task for someone else to execute](how-to/write-a-task-for-someone-else.md) — the five parts of the instruction and the verification on return, for a plan or for the bridge (the tool that gives the worker the task and returns the diff only if the verifier passed)
- [How to start a new project](how-to/start-a-new-project.md) — from an empty folder to a repository on GitHub, with starting prompts
- [How to solve an environment problem](how-to/fix-an-environment-problem.md) — from symptom to cause, and how it gets into the journal (the system problems solved, with the symptom, the cause and the method)
- [How to load skills at the start of a session](how-to/load-skills-at-startup.md) — through `CLAUDE.md` (the file with the rules every session of the project loads), through a reference to a file, or through a reference to `CLAUDE.md` from outside the folder
- [How to trigger a skill from a prompt](how-to/trigger-a-skill-from-a-prompt.md) — the wordings that bring each superpowers skill, and those that bring nothing
- [How to switch modes](how-to/switch-modes.md) — the ponytail and caveman levels, in the session and permanently
- [How to check that a plugin really works](how-to/check-a-plugin-works.md) — six checks, from the cheapest to the slowest

## Reference

Exact values, read from the system, not from memory. None is dated: those of the plugins belong to
the versions pinned in `plugins.lock.json`, and those of the environment are re-measured with the
block in [README.md](../README.md).

⚠ At a plugin update, the values in the four references are re-read from disk. The exact path is
given by `ls ~/.claude/plugins/cache/`.

- [The structure of the workspace](reference/structure.md) — every folder and every file: what it is, who reads it, what breaks without it
- [Glossary](reference/glossary.md) — the words the workspace uses differently, each with its gloss
- [superpowers](reference/superpowers.md) — 14 skills, no slash command, the cost of each
- [ponytail](reference/ponytail.md) — the seven-rung ladder, the 6 commands, the declared measurements
- [caveman](reference/caveman.md) — the levels, the counterintuitive rules, the 21 skills
- [RTK](reference/rtk.md) — the 43 compressed programs and the list of exclusions

## Explanation

They are read away from the computer.

- [What each plugin does and when it is worth it](explanation/what-each-plugin-does.md) — the four layers, the best and the worst case for each
- [How a plugin comes to apply](explanation/how-a-plugin-applies.md) — the three mechanisms, and why the descriptions do not say what the skill does
- [Splitting the work across models](explanation/splitting-work-across-models.md) — why a work item with a plan goes through four sessions, on different models, and where the line falls
- [Conflicts and pitfalls](explanation/conflicts-and-pitfalls.md) — seven pitfalls, each with the method by which it was caught

## Where to start

The starting path is a single one, in [README.md](../README.md), at "The documentation map".

## The plugins' numbers and paths

| Landmark | Value |
|---|---|
| Installed plugins | 4, all in the `user` scope |
| The configuration | `~/.claude/settings.json` |
| The plugins' files | `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` |
| The binary that manages them | `claude` from `PATH`; otherwise the one in the application, `~/.config/Claude/claude-code/<version>/claude` on Linux or `~/Library/Application Support/Claude/claude-code/<version>/claude` on macOS, at the newest version |
| Permanent cost, total | ~2,516 tokens in every session |
| Slash commands available | 12 (ponytail 6, caveman 5, RTK 1; superpowers none) |
| Skills available | 42 (caveman 21, superpowers 14, ponytail 6, RTK 1) |

What has to be installed for it to work, with the version and the command that reads it,
sits in a single list: [Quick start](../README.md#what-it-needs), in the README.

## What is not here

The documentation describes the plugins as they were read from disk. It does not describe
functionality promised in their repositories for other tools — Codex, Gemini, Copilot — which does
not apply here, and it does not reproduce measurements it cannot verify. Where a figure comes from
an author's documentation and not from the system, the source is named.
