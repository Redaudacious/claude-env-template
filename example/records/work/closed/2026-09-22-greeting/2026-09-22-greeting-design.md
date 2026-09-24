# The greeting: the spec

Written on 2026-09-22, in the spec session, from the [request](request.md). The
requirements are settled there, so this document does not reopen them: it decides only
what the request leaves unsaid, so that the plan has nothing left to choose.

## What the script does and why

`greeting.sh` takes a name as its argument and prints `hello, <name>` on standard
output. It does nothing else: it is the tutorial's exercise project, and its purpose is
to go through the four sessions of the house, not to be useful.

Its test, `tests/test-greeting.sh`, calls it with the name `Ana` and asks for exactly
`hello, Ana`. It sits in `tests/`, because the framework's `./test` collector (the script
that finds and runs every test in the workspace) looks there.

## The edge case: the call without a name

The request does not say what happens when the script is called without a name. The
decision: the script prints on standard error how it is used, `usage: greeting.sh <name>`,
and exits with code 2. The test checks this case too, so it has two checks, not one.

Code 2 is the one the system's ordinary tools use for "wrong arguments", to set it apart
from 1, "it ran, but failed".

## The rejected alternative: without a name, greet the world

A `hello, world` on a call without an argument is friendly, but it hides a wrong call: a
script that forgets to pass the name would get a valid greeting and nobody would find
out. An exit code other than 0 stops the chain that called it, and the message says what
was missing.

## What this session leaves

This spec and the handoff (the note in `STATE.md` for the next session) to the plans
session, which writes the plan and the folder's `README.md`. No local worker, as the
request asks: every task of the plan is done in the session.
