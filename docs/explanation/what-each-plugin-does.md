# What each plugin does and when it is worth it

The four installed plugins seem to do similar things — they all promise "less". In reality
they touch four different layers of the same conversation, and that is why they can sit
together without cancelling each other.

## Each plugin touches a different layer of the conversation

| Layer | Plugin | What it controls |
|---|---|---|
| The order of the work | superpowers | what is done before what |
| The code written | ponytail | how much code is born |
| The answer shown | caveman | how what is read is worded |
| The terminal's output | RTK | how much of a command's result enters the conversation |

Only one plugin of the four touches the code. Only one touches what comes from the terminal.
The real overlap appears only between superpowers and caveman, and is treated in [Conflicts
and pitfalls](conflicts-and-pitfalls.md).

## superpowers makes a step impossible to skip

The 14 skills (a skill is a set of instructions that enters the conversation when the
situation matches) do not add knowledge. They add a **mandatory sequence**: it is discussed
before planning, it is planned before writing, the test is written before the code, it is
verified before saying "done".

The value does not lie in any step taken separately — everyone knows tests are good. It lies
in the fact that the step can no longer be skipped under pressure.

The `using-superpowers` skill contains a table of twelve rationalizations, each with its
answer: "This is just a simple question", "I need more context first", "The skill is
overkill". Those twelve sentences are exactly the excuses an agent produces by itself when
it wants to skip discipline.

**Best case:** a task large enough for the order to matter — a new feature, a defect whose
origin is not visible, a branch that has to be integrated.

**Worst case:** a one-line question. The `brainstorming` skill costs ~3,800 tokens at
invocation; a question whose answer is "yes" does not deserve it.

## ponytail catches the extra construction

The seven-rung ladder, stopping at the first that holds, moves the question from "how do I
write this" to "does this have to be written". The first rung is not about code at all:
*does it need to exist?*

The author's measurement, on a real repository with twelve tasks, gives -54% lines of code
and -22% tokens against the same session without the skill.

What says as much as the figure is **where** it appears: the reduction is large where there
is an over-construction trap (a 404-line calendar comes down to 23, because `<input
type="date">` is used instead of a library) and almost nil on code that is already minimal.

So ponytail does not make code smaller in general. It catches a particular kind of mistake:
the one where a tool is built instead of using an existing one.

**Best case:** any moment when the risk is extra construction — a new feature, the choice of
a library, a refactoring that could become a rewrite.

**Worst case:** an algorithm in which correctness at the edges matters more than length. The
skill provides for its own exception: "Two stdlib options, same size? Take the one that's
correct on edge cases."

## caveman compresses the small part of the conversation

It compresses the answer: no articles, no filler, fragments accepted.

The counterintuitive part is that its rules forbid almost everything someone would do
instinctively to seem compressed. No invented abbreviations (`cfg`, `impl`), because the
tokenizer splits them the same as the whole word — zero saving, extra decoding.

No arrows, which are a separate token. No words added to sound primitive. The declared rule
is: if the compressed wording is not shorter than the normal one, the normal one is used.

What has to be known before counting it as a saving: in the agentic measurement in
ponytail's documentation, caveman comes out at **+7% tokens, +3% cost, +2% time** against
the baseline, cutting only 20% of the lines of code. The measurement belongs to a competing
plugin, so it is not a neutral source — but the mechanism behind it is verifiable.

In a real work session, most tokens come not from what the agent writes, but from what it
reads: files, command outputs, search results. Compressing the final answer touches the
small part. And the plugin's permanent ~1,244 tokens are paid in every session, whether the
mode is used or not.

**Best case:** someone who wants density when reading — answers without pleasantries and
without repetition.

**Worst case:** the writing of documentation and explanations, where the whole sentence is
the product itself.

## RTK cuts from what enters the model

The only one that works in the other direction: not what comes out of the model, but what
goes into it from the system.

It is placed in front of every shell command and, if the program is among the 43 on the
list, runs it through its own binary, which compresses its output. A long `git status`, a
test suite, a package installation — that is where the thousands of tokens that are not seen
are.

The permanent cost is ~12 tokens. Of the four, it is the only one for which the question "is
it worth it?" practically does not arise.

**Best case:** long sessions, with many commands that produce large output.

**Worst case:** a workflow built from commands chained with pipes — those pass uncompressed
by construction, so as not to break scripts. Whoever works mostly with `grep ... | head`
will not see the promised savings.

## The plugin that promises savings costs the most at startup

The four descriptions are loaded in every session, used or not:

| Plugin | Permanent tokens |
|---|--:|
| caveman | ~1,244 |
| ponytail | ~676 |
| superpowers | ~584 |
| RTK | ~12 |
| **Total** | **~2,516** |

The order is the opposite of intuition. The plugin that promises token savings is the most
expensive at startup, and the one that really cuts from the input is the cheapest. The
reason is simple: caveman has 21 skills and 3 agents to declare, RTK has just one.

## Understand-Anything: a plugin evaluated and rejected

[Egonex-AI/Understand-Anything](https://github.com/Egonex-AI/Understand-Anything),
v2.9.7, MIT, evaluated on 19 September 2026. It builds a knowledge graph of the project,
but it starts up to 5 Claude analyzers in parallel, plus four more agents.

That is what stops it: the rule of the framework (the repository with the rules, skills
and tools common to all projects) allows no subagent (another Claude, started from a
session).

Its automatic-update hook asks the session, literally, not to ask the human. It requires
`pnpm` ≥ 10 and compiles on the first run.

**It is reopened** if the plugin gains a mode without subagents, if the subagent rule
changes, or if a foreign repository appears that is too large to be read by hand.
