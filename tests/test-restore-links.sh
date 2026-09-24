#!/usr/bin/env bash
# Test for the links that `bin/restore-env.sh` makes: the skills in
# `~/.claude/skills/` and the memory in `~/.claude/projects/<folder>/memory`.
#
# The script is loaded only for its functions, with RESTORE_ENV_FUNCTIONS_ONLY=1, in a
# fabricated HOME: nothing here touches the machine.
set -u

R="${TESTS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home"
mkdir -p "$HOME/.claude/skills" "$T/space/skills/documentation" "$T/space/records/memory" \
         "$T/space/projects/game"
touch "$T/space/skills/documentation/SKILL.md" "$T/space/records/memory/MEMORY.md"

failed=0
check() {  # condition message
  if eval "$1"; then printf '  ✓ %s\n' "$2"; else failed=$((failed + 1)); printf '  ✗ %s\n' "$2"; fi
}

# shellcheck disable=SC1090
RESTORE_ENV_FUNCTIONS_ONLY=1 source "$R/bin/restore-env.sh"
check 'declare -F link_skill >/dev/null && declare -F link_memory >/dev/null' \
  "the script lets itself be loaded for its functions only, without restoring anything"

# ── the skills ───────────────────────────────────────────────────
link_skill "$T/space/skills/documentation" "$HOME/.claude/skills/documentation" >/dev/null
check '[ "$(readlink "$HOME/.claude/skills/documentation")" = "$T/space/skills/documentation" ]' \
  "a missing link is created"

ln -sfn "$T/elsewhere" "$HOME/.claude/skills/documentation"
link_skill "$T/space/skills/documentation" "$HOME/.claude/skills/documentation" >/dev/null
check '[ "$(readlink "$HOME/.claude/skills/documentation")" = "$T/space/skills/documentation" ]' \
  "an old link is replaced"

# ⚠ A REAL folder with the skill's name belongs to the human. `ln -sfn` does not
#   replace it: it puts the link inside it, and the old skill stays active, silently.
rm "$HOME/.claude/skills/documentation"
mkdir -p "$HOME/.claude/skills/documentation"; touch "$HOME/.claude/skills/documentation/SKILL.md"
if link_skill "$T/space/skills/documentation" "$HOME/.claude/skills/documentation" 2>"$T/err" >/dev/null; then code=0; else code=$?; fi
check '[ "$code" -ne 0 ]' "a real folder in place of the link is refused, not overwritten (code $code)"
check '[ ! -e "$HOME/.claude/skills/documentation/documentation" ]' \
  "the link is not put inside the real folder"
check '[ -f "$HOME/.claude/skills/documentation/SKILL.md" ]' "the real folder stays untouched"
check 'grep -q "documentation" "$T/err"' "the refusal is said on stderr, with the skill's name"

# ── the memory ───────────────────────────────────────────────────
mem_root="$HOME/.claude/projects/$(printf '%s' "$T/space" | tr '/' '-')/memory"
mem_game="$HOME/.claude/projects/$(printf '%s' "$T/space/projects/game" | tr '/' '-')/memory"

link_memory "$T/space" "$T/space/records/memory" >/dev/null
check '[ "$(readlink "$mem_root")" = "$T/space/records/memory" ]' \
  "the root's memory is linked from records/memory, in a fresh HOME"

link_memory "$T/space/projects/game" "$T/space/records/memory" >/dev/null
check '[ "$(readlink "$mem_game")" = "$T/space/records/memory" ]' \
  "a project's memory is linked from the same records/memory"

link_memory "$T/space/projects/game" "$T/space/records/memory" >/dev/null
check '[ "$(readlink "$mem_game")" = "$T/space/records/memory" ]' "an existing link stays as it is"

mkdir -p "$T/space/projects/old"
mem_old="$HOME/.claude/projects/$(printf '%s' "$T/space/projects/old" | tr '/' '-')/memory"
mkdir -p "$mem_old"; echo "someone else's" > "$mem_old/MEMORY.md"
link_memory "$T/space/projects/old" "$T/space/records/memory" 2>"$T/err" >/dev/null || true
check '[ ! -L "$mem_old" ] && [ "$(cat "$mem_old/MEMORY.md")" = "someone else'"'"'s" ]' \
  "a real memory, with files, is not covered by the link"
check 'grep -q "files" "$T/err"' "and it is said on stderr"

echo
if [ "$failed" -eq 0 ]; then echo "  ✓ all tests pass"; else echo "  ✗ $failed tests failed"; exit 1; fi
