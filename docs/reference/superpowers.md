# Reference — superpowers

Superpowers is the plugin that decides the order of the work: it says which skill comes
before which. The values are read from
`~/.claude/plugins/cache/superpowers-marketplace/superpowers/6.3.0/`, the version
pinned in `plugins.lock.json`.

## Identification

| Field | Value |
|---|---|
| Full name | `superpowers@superpowers-marketplace` |
| Version | 6.3.0 |
| Source | `obra/superpowers-marketplace` |
| Installation scope | user (`~/.claude/settings.json`) |
| Permanent cost | ~584 tokens in every session |

## Slash commands

None. The `commands/` folder does not exist in the plugin.

All 14 components are skills (a skill is a set of instructions that enters the
conversation when the situation matches), triggered by matching the description with the
request formulated in natural language. The practical consequence is treated in
[How to trigger a skill from a prompt](../how-to/trigger-a-skill-from-a-prompt.md).

## Skills

The "trigger" column reproduces the condition in each skill's `description` field —
that is, exactly the text the matching is done on.

| Skill | Trigger | Cost at invocation |
|---|---|---|
| `brainstorming` | before any creative work: a new feature, a new component, changed behavior | ~3,800 |
| `writing-plans` | there is a specification for a task with several steps, before touching code | ~1,700 |
| `executing-plans` | there is a written plan, to be executed in a separate session, with checkpoints | ~540 |
| `subagent-driven-development` | the execution of a plan with independent tasks, in the current session | ~8,000 |
| `dispatching-parallel-agents` | 2 or more independent tasks, with no shared state | ~1,500 |
| `test-driven-development` | any feature or repair, before the implementation code | ~2,200 |
| `systematic-debugging` | any defect, failing test or unexpected behavior, before proposing repairs | ~2,300 |
| `requesting-code-review` | a task finished, a major feature, before integration | ~700 |
| `receiving-code-review` | feedback was received, before implementing it | ~1,500 |
| `verification-before-completion` | before declaring something finished, repaired or passing | ~830 |
| `using-git-worktrees` | work that requires isolation from the current space | ~1,600 |
| `finishing-a-development-branch` | the implementation is complete, the tests pass, integration follows | ~1,900 |
| `writing-skills` | creating, editing or verifying skills | ~6,500 |
| `using-superpowers` | at the start of any conversation | ~720 |

**Three of them are not used in the workspace.** A written plan is executed with
`execute`, the framework's skill (the repository with the rules, skills and tools common
to all projects), not with `executing-plans`.

`subagent-driven-development` and `dispatching-parallel-agents` send work to subagents
(another Claude, started from a session), and here no session does that: [Splitting the work across models](../explanation/splitting-work-across-models.md#how-many-at-once-just-one).

## Hooks

| Moment | Command | Interpreter |
|---|---|---|
| `SessionStart` (`startup`, `clear`, `compact`) | `hooks/run-hook.cmd session-start` | bash |

A single hook, written in bash. It does not need `node`, unlike the other three
installed plugins — treated in [Conflicts and pitfalls](../explanation/conflicts-and-pitfalls.md).

## The central rule

The text from `using-superpowers/SKILL.md`, the section "The Rule":

> Invoke relevant or requested skills BEFORE any response or action — including
> clarifying questions, exploring the codebase, or checking files.

The declared order of priority, when several skills match: the process skills come
first and set the approach, then the implementation ones.

## Notable auxiliary files

| Path | Size | Content |
|---|---|---|
| `skills/writing-skills/anthropic-best-practices.md` | 46,197 bytes | the official guide to writing skills |
| `skills/writing-skills/persuasion-principles.md` | 5,901 bytes | the seven Cialdini principles applied to skills |
| `skills/writing-skills/testing-skills-with-subagents.md` | 12,558 bytes | the method of testing a skill on subagents |
