# How work is done in this project

⚠ **This file is optional.** It loads at every session start, so every line in it is
paid for every time. A project gets it when it has something to say that **costs if it is
not known**. If none of the questions below has an answer, the file is deleted.

The order of the skills and the house rules are in the `CLAUDE.md` at the root of the
workspace and load by themselves. Here sits only what belongs to the project.

## Commands

What is run, from where, and what does **not** work from where it might seem to.

| What | The command |
|---|---|
| build | |
| tests | |
| map verification | `../../bin/check-maps.sh .` |
| documentation verification | `python3 ../../bin/check-docs.py .` |

## The direction: what is source and what is pulled

The question: **is there a folder in the repository that is a copy of something from
another machine?** If so, a change made here is lost at the next sync, and that is written
down. If the whole repository is source, the section is deleted.

## The order in which the code is read

The question: **where does someone who has never seen the project start?** The entry
file, then what it calls. Three or four lines, not a complete map.

## What is not touched

The question: **which closed decision would someone reopen who does not know it was
closed?** Each line with the reason, and the history in `records/decisions/`.

## The pitfalls that get forgotten

The question: **what has already cost time twice?**

A pitfall caught once goes into `records/pitfalls/`. Only those that repeated come up
here — otherwise the file grows at every session and nobody reads it any more.
