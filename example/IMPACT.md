# The impact and dependency map

Measured on 2026-09-22, reading `greeting.sh` and its test. What breaks is read from the
code, not assumed.

## Verifiable

The command in the fourth column exits with 0 as long as the row is true; the framework's
`check-maps.sh` runs it from this folder.

| what changes | what breaks | what it depends on | verification |
|---|---|---|---|
| `greeting.sh` | the greeting, or code 2 on a call without a name | the test `tests/test-greeting.sh`, which asks for both | `bash tests/test-greeting.sh >/dev/null` |

## Not verifiable

No row: the project has no conceptual dependencies, only the script and its test.
