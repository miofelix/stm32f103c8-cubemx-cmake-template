#!/usr/bin/env bash
#
# Rename this template's project name everywhere it appears:
#   - CMakeLists.txt   (CMAKE_PROJECT_NAME -> the build target & artifact names)
#   - the CubeMX .ioc  (ProjectName / ProjectFileName fields AND the filename)
#   - tracked template files containing build artifact paths
#
# Safe to re-run: the current name is read from CMakeLists.txt, not hard-coded.
# Does NOT retarget the MCU (startup_*.s, *.ld linker script, STM32F103xB define,
# -mcpu) -- that is a separate manual step for a different chip.
#
# Usage:
#   scripts/rename.sh <new_project_name>
#
# <new_project_name>: letters, digits, '_' and '-', starting with a letter or '_'.

set -euo pipefail

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ "$#" -eq 1 ] || die "usage: $(basename "$0") <new_project_name>"
NEW="$1"

case "$NEW" in
  "")               die "name is empty" ;;
  *[!A-Za-z0-9_-]*) die "name may contain only letters, digits, '_' and '-': '$NEW'" ;;
  [!A-Za-z_]*)      die "name must start with a letter or underscore: '$NEW'" ;;
esac

# Always operate from the repository root, regardless of the caller's CWD.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# The current project name is the single source of truth in CMakeLists.txt.
OLD="$(sed -n 's/^[[:space:]]*set(CMAKE_PROJECT_NAME[[:space:]][[:space:]]*\([A-Za-z0-9_-][A-Za-z0-9_-]*\).*/\1/p' CMakeLists.txt)"
[ -n "$OLD" ] || die "could not read CMAKE_PROJECT_NAME from CMakeLists.txt"

if [ "$OLD" = "$NEW" ]; then
  printf 'project is already named "%s"; nothing to do\n' "$NEW"
  exit 0
fi

printf 'renaming project "%s" -> "%s"\n' "$OLD" "$NEW"

# Are we inside a git work tree? Enables git grep / git mv (keeps history clean).
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  IN_GIT=1
else
  IN_GIT=0
fi

# Files that contain the token, excluding the vendored HAL and this script dir.
# "<name>" never collides with the MCU identifiers (STM32F103xB,
# startup_stm32f103xb.s, ...), so a literal whole-token replace is safe.
if [ "$IN_GIT" -eq 1 ]; then
  FILE_LIST="$(git grep -lI -F "$OLD" -- ':!Drivers' ':!scripts' ':!docs' ':!.vscode' || true)"
else
  FILE_LIST="$(grep -rlI --exclude-dir=Drivers --exclude-dir=scripts \
    --exclude-dir=build --exclude-dir=.git --exclude-dir=docs \
    --exclude-dir=.vscode -F "$OLD" . || true)"
fi

# Edit each file in place. The "-i.bak" + rm form is portable across GNU and
# BSD/macOS sed. This edits the .ioc CONTENT while it still has its old name;
# the file itself is renamed afterwards.
printf '%s\n' "$FILE_LIST" | while IFS= read -r f; do
  [ -n "$f" ] || continue
  sed -i.bak "s/$OLD/$NEW/g" "$f"
  rm -f "$f.bak"
  printf '  edited %s\n' "$f"
done

# Rename the CubeMX project file to match the new name.
if [ -f "$OLD.ioc" ]; then
  if [ "$IN_GIT" -eq 1 ] && git ls-files --error-unmatch "$OLD.ioc" >/dev/null 2>&1; then
    git mv "$OLD.ioc" "$NEW.ioc"
  else
    mv "$OLD.ioc" "$NEW.ioc"
  fi
  printf '  renamed %s.ioc -> %s.ioc\n' "$OLD" "$NEW"
fi

printf '\ndone. Next steps:\n'
printf '  1. review:       git status && git diff\n'
printf '  2. clean build:  rm -rf build\n'
printf '  3. reconfigure:  cmake --preset Debug\n'
