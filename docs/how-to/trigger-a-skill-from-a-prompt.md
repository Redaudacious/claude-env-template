# How to trigger a skill from a prompt

A skill is a set of instructions that enters the conversation when the situation
matches. The guide applies to the skills of superpowers, the plugin that decides the
order of the work: they have no slash commands and are triggered exclusively by matching
the description. The mechanism behind it is explained in [How a plugin comes to apply](../explanation/how-a-plugin-applies.md).

## The situation is described, not the tool

The **situation** is described, not the tool. The descriptions of the skills are
written as situations ("when there is a written plan to execute"), so the match is
the surer the more the request resembles a situation.

## The steps of a request that triggers

1. **The stage is named, not the action.** "Add X" contains no stage. "I want us to
   build X, but I have not decided how" contains one.
2. **What is unknown is said.** Declared uncertainty is the strongest trigger for the
   process skills. A defect whose cause is not known leads to `systematic-debugging`;
   one described as "change line 12" does not.
3. **It is said where the work stands in time.** "Before I write code", "I am done,
   integration is next", "I received a review" — each of these three wordings
   corresponds to a different description.
4. **Confirmation is asked for.** The invoked skill is announced with the formula
   "Using [skill] to [purpose]". If the announcement is missing, the skill was not
   applied.

## Wordings that trigger

The right-hand column contains the situation from the skill's `description` field, not
a paraphrase.

| Wording in the request | Skill reached |
|---|---|
| "I want us to build…", "I am thinking of a feature that…" | `brainstorming` |
| "I have the specification, make a plan before you touch code" | `writing-plans` |
| "execute the plan <path> with the execute skill", in a new session | `execute`, the framework's skill |
| "write the test first" | `test-driven-development` |
| "I do not understand why it fails", "it behaves differently from what I expect" | `systematic-debugging` |
| "I am done, verify before you say it works" | `verification-before-completion` |
| "look over what I did before I integrate" | `requesting-code-review` |
| "I received this feedback, but I am not convinced" | `receiving-code-review` |
| "I want to work isolated from what is in the tree now" | `using-git-worktrees` |
| "the tests pass, what do I do with the branch" | `finishing-a-development-branch` |

`execute` does not come from superpowers, but from the framework (the repository with the
rules, skills and tools common to all projects).

`dispatching-parallel-agents` and `subagent-driven-development` are not used here: no
session sends work to subagents (another Claude, started from a session). The rule sits
under "Who does what", in `CLAUDE.md` (the file with the rules every session of the
project loads).

## Wordings that trigger nothing

| Wording | What is missing |
|---|---|
| "fix this" | no stage, no uncertainty |
| "add a button" | an action without a situation |
| "it is broken" | a symptom without the declaration that the cause is not known |
| "do my documentation" | covered by another skill, not by superpowers |

## When the name is better than the situation

Naming directly — "use systematic-debugging" — is more suitable in two cases:

1. When the right stage is already known and no negotiation is wanted.
2. When an earlier request missed the wanted skill and is being reworded.

The limit of direct naming is that it brings only the description into the
discussion. The behavior sits in the body of the skill, and the body is read only if
the skill is really invoked. The control formula stays the same: the announcement
"Using [skill] to […]" is awaited.

## Two mistakes that spoil the order

- **Several skills are not listed in a request.** The order is set by the plugin — the process ones first, the implementation ones after — and a list imposed from outside breaks it.
- **The implementation skill is not asked for directly on a large task.** "Write the tests" skips `brainstorming`, that is, exactly the step that decides what has to be tested.
