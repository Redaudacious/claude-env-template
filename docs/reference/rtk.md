# Reference — RTK

RTK is the tool that shortens the output of commands before it reaches the conversation;
the plugin here brings it and puts it in the path of the commands. The values are read
from `~/.claude/plugins/cache/enix/rtk-plugin/0.1.2/`,
the version pinned in `plugins.lock.json`.

## Identification

| Field | Value |
|---|---|
| Full name | `rtk-plugin@enix` |
| Version | 0.1.2 |
| Source | `enixCode/plugins` |
| Permanent cost | ~12 tokens in every session |

The cheapest of the four, by two orders of magnitude. The plugin has almost no content
of its own: it brings a binary and a dispatcher.

## Command

| Command | Effect |
|---|---|
| `/rtk-plugin:gain` | the savings dashboard: routed commands, tokens in and out, total savings, breakdown by program |

## How it works

| Moment | What happens |
|---|---|
| `SessionStart` | `scripts/bootstrap-rtk.mjs` downloads the RTK binary into `${CLAUDE_PLUGIN_DATA}/rtk/`, then runs `rtk init -g` once per session |
| `PreToolUse` on `Bash` | `bin/dispatch.mjs` reads the command and, if the program is on the list, rewrites it by prefixing it with the RTK binary |

The rewrite is literal: `git status` becomes `"<path>/rtk" git status`. RTK runs the
command and compresses its output before it reaches the conversation.

## The compressed programs

The complete list, from `bin/dispatch.mjs`, the field `RtkRoute.TOOLS` — 43 programs:

| Group | Programs |
|---|---|
| Files and search | `ls`, `find`, `grep`, `diff`, `cat`, `less`, `head`, `tail` |
| Git | `git`, `gh` |
| Build and tests | `cargo`, `go`, `pytest`, `jest`, `vitest`, `playwright`, `rake`, `rspec`, `mocha` |
| Static analysis | `eslint`, `tsc`, `prettier`, `ruff`, `rubocop`, `golangci-lint` |
| Packages | `npm`, `npx`, `pnpm`, `yarn`, `pip`, `pipx`, `poetry`, `bundle`, `prisma` |
| Infrastructure | `docker`, `kubectl`, `helm`, `aws`, `gcloud`, `az` |
| Network | `curl`, `wget`, `jq` |

## What passes uncompressed

| Case | Reason |
|---|---|
| Any command with `\|`, `&&`, `$()` or another shell construct | the dispatcher leaves it intact, so as not to break existing scripts |
| A program that is not in the list of 43 | it has no route |
| A command already prefixed with `rtk` | it is not prefixed twice |

The exclusion of commands with pipes has an important practical effect, treated in
[How to check that it works](../how-to/check-a-plugin-works.md).

## Where the data sits

| What | Path (Linux) |
|---|---|
| The binary | `~/.claude/plugins/data/rtk-plugin*/rtk/rtk` |
| The measurement history | `~/.local/share/rtk/` (SQLite) |

Telemetry is off by construction. It is inspected with `rtk config`.

## The binary's source

`https://github.com/rtk-ai/rtk/releases`, the file name being built from the platform:
`rtk-<target>.<extension>`.

The download script verifies no checksum and no signature — searching for `sha256`,
`checksum`, `signature` and `verify` in `scripts/bootstrap-rtk.mjs` returns zero
matches. The implication is treated in
[Conflicts and pitfalls](../explanation/conflicts-and-pitfalls.md).
