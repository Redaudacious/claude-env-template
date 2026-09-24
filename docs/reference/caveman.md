# Reference — caveman

Caveman is the plugin that compresses the model's answers. In the workspace it is stopped
with `/caveman off` before documentation. The values are read from
`~/.claude/plugins/cache/caveman/caveman/3b74643f4d91/`,
the version pinned in `plugins.lock.json`.

## Identification

| Field | Value |
|---|---|
| Full name | `caveman@caveman` |
| Version | `3b74643f4d91` (a commit identifier, not a version number) |
| Source | `JuliusBrussee/caveman` |
| Author | Julius Brussee |
| Permanent cost | ~1,244 tokens in every session |

The permanent cost is the largest of the four installed plugins — more than twice
that of superpowers (the plugin that decides the order of the work), which has 14 skills
against 21. The reason is treated in
[What each plugin does and when it is worth it](../explanation/what-each-plugin-does.md).

## Levels

| Level | What changes |
|---|---|
| `lite` | filler and hedging disappear; articles and whole sentences stay |
| `full` | articles disappear, fragments are accepted, short synonyms; no tool narration, no decorative tables |
| `ultra` | conjunctions disappear too, when cause and effect stay unambiguous; a single word when one is enough |
| `wenyan-lite` / `wenyan-full` / `wenyan-ultra` | the variants in classical Chinese |
| `off` | stopped |

Default: `full`. Switching: `/caveman <level>`. Stopping also by "stop caveman" or
"normal mode".

## Rules that contradict intuition

They are written explicitly in `skills/caveman/SKILL.md` and are worth knowing,
because they describe what the mode does **not** do:

- **No invented abbreviations** (`cfg`, `impl`, `req`, `res`, `fn`). The stated reason: the tokenizer splits them the same as the whole word, so the saving is zero, and the reader still has to decode them.
- **No arrows** (`→`). They are a separate token; they save nothing.
- **No words added to sound primitive.** Compression is not allowed to grow the output. "when it not" costs one token more than "when not".
- **Never** are `not`, `never`, `no`, `only`, `except` cut. Reversing the meaning costs more than any token saved.
- **The language is preserved.** The style is compressed, not the language. For a request in Romanian, the answer stays in Romanian.
- Technical terms, code, API names, commands and the exact texts of errors stay untouched.

## Commands

| Command | Effect |
|---|---|
| `/caveman [level]` | switches the level |
| `/caveman-commit` | compressed commit message |
| `/caveman-review` | compressed review |
| `/caveman-stats` | statistics |
| `/caveman-init` | initialization |

## Skills

Twenty-one (a skill is a set of instructions that enters the conversation when the
situation matches), of which only a part concern the compression of style. The rest are
workflow skills that overlap with superpowers:

| Group | Skills |
|---|---|
| Style | `caveman`, `caveman-compress`, `caveman-help`, `caveman-stats`, `caveman-setup`, `caveman-manage`, `caveman-learn`, `caveman-optimize` |
| Workflow | `investigate-first`, `lean-build`, `safe-refactor`, `surgical-patch`, `verify-and-stop`, `migration` |
| Review | `caveman-review`, `caveman-evidence-review`, `caveman-commit` |
| Exploration | `caveman-explore`, `caveman-discover` |
| Delegation | `cavecrew` |

The overlap with superpowers is real: `investigate-first` covers the same ground as
`systematic-debugging`, `verify-and-stop` as `verification-before-completion`,
`lean-build` as the ladder of ponytail, the plugin that decides how much code is written.

The overlap is treated in [Conflicts and pitfalls](../explanation/conflicts-and-pitfalls.md).

## Agents

`cavecrew-builder`, `cavecrew-investigator`, `cavecrew-reviewer`.

## Hooks

| Moment | Command | Interpreter |
|---|---|---|
| `SessionStart` | `src/hooks/caveman-activate.js` | node |
| `UserPromptSubmit` | `src/hooks/caveman-mode-tracker.js` | node |

The hooks for Claude Code sit in `.claude-plugin/plugin.json`. The repository also
contains `.codex/hooks.json`, with a simple `echo` — that one is for Codex and does
not apply here.
