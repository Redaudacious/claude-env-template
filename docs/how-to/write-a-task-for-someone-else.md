# How to write a task for someone else to execute

The guide is for whoever writes a task that they will not carry out themselves. There
are two cases:

- a task from a plan (the list of tasks, each with its verifier, that another session
  executes), carried out by a new session;
- the statement that the bridge (the tool that gives the worker the task and returns the
  diff only if the verifier passed) gives to a local worker (a model that runs on one of
  the human's machines and takes small tasks).

The executor does not see the conversation; it knows only what the task says. Why the
work is split this way:
[Splitting the work across models](../explanation/splitting-work-across-models.md).

## 1. It is first checked that it is worth sending

Three questions, in this order. A "no" to any of them stops the sending.

| Question | If not |
|---|---|
| Does the task have a completion criterion that the executor can verify alone? | the criterion is written first, otherwise it stops when it thinks fit |
| Can it be described without anything from the conversation so far? | what has to be known is written into the task |
| Does it take longer than writing it, sending it and verifying it? | it is done on the spot |

The last question cuts most of the sendings. A repair of a few lines costs more sent
than done, because the executor starts cold.

## 2. The instruction is written, in five parts

The instruction is self-contained and has five parts:

1. **What has to be done**, in one sentence.
2. **Where** — file paths, not descriptions.
3. **What is not touched** — just as important, and usually forgotten.
4. **How it is known to be done** — the command that must exit with 0, that is the
   verifier (the command that says by itself whether a task succeeded).
5. **What to report** — what exactly the sender wants back.

An example that has all five:

```
Fix the space check in bin/archive.sh.

Today it asks for exactly 5 GB. It must ask for as much as what is to be archived
occupies, plus 1 GB of margin — measured with `du -sk` on the source directory.

Do NOT touch anything in bin/restore.sh; it is a separate path, with its own tests.

Done means: `bash tests/archive.sh` exits with 0, and the new test fails if the
repair is removed. Show both runs.

Report: the diff applied, the output of the tests, and anything you found on the way
and did not fix.
```

The "what is not touched" part is the one that protects: an executor that sees a
neighboring problem repairs it out of goodwill, and the diff becomes larger than the
task.

⚠ **The row with "what you found and did not fix" is not left out.** Whoever read the
code knows things nobody asked for; without this row, they are lost without a trace.

## 3. What came back is verified

**The report is not evidence.** What changed is read from git, and that it works is
seen from the completion command, run again by the one who sent:

```bash
git diff --stat && git status --porcelain
```

⚠ **The diff is read, not only its summary.** A report that says "I repaired the
function" can hide a rewrite done on the way.

⚠ **An added test is verified in a pair.** It must fail with the repair removed and
pass with it in place; otherwise it protects nothing, and the suite goes on without a
sign.

## 4. It is decided what is done with what came back

- **it is kept** — the tests pass, the diff is the one asked for;
- **it is asked for again**, with the instruction corrected — usually the third or
  fourth part was missing;
- **it is thrown away** — it spread beyond the task, or it solved something else.

Throwing away must stay cheap. A half-good diff, kept because "work went into it",
brings into the code things nobody decided.

## Where it applies

| Who executes | Where the task sits | Who verifies |
|---|---|---|
| an execution session | a task from the plan, with the `Who` label | the execution, then the review |
| a local worker, through the bridge | the statement, written from the text of the task | the bridge runs the verifier, and the session runs it again |

The `Who` label is the line that says who does a task in the plan, and the review is the
new session that reads what execution did and decides on the merge.

Subagents (another Claude, started from a session) are not used. The rule is in
`CLAUDE.md` (the file with the rules every session of the project loads), under "Who does
what".
