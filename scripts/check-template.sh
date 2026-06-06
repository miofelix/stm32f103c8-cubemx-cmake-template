#!/usr/bin/env bash

set -euo pipefail

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="$(sed -n 's/^[[:space:]]*set(CMAKE_PROJECT_NAME[[:space:]][[:space:]]*\([A-Za-z0-9_-][A-Za-z0-9_-]*\).*/\1/p' CMakeLists.txt)"
[ -n "$PROJECT" ] || die "could not read CMAKE_PROJECT_NAME from CMakeLists.txt"

IOC="$PROJECT.ioc"
[ -f "$IOC" ] || die "CubeMX project is missing: $IOC"
[ -f cmake/stm32cubemx/CMakeLists.txt ] || die "CubeMX CMake target is missing"

require_ioc_setting() {
  grep -Fqx "$1" "$IOC" || die "$IOC must contain '$1'"
}

require_ioc_setting "ProjectManager.KeepUserCode=true"
require_ioc_setting "ProjectManager.DeletePrevious=true"
require_ioc_setting "ProjectManager.LibraryCopy=1"
require_ioc_setting "ProjectManager.TargetToolchain=CMake"

for local_path in "/.mxproject" "/.vscode/" "/docs/"; do
  grep -Fqx "$local_path" .gitignore || die "$local_path must be ignored"
done

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [ -z "$(git ls-files .mxproject .vscode docs)" ] ||
    die ".mxproject, .vscode/, and docs/ are local-only and must not be tracked"
fi

if grep -Eq 'get_target_property\(.*STM32_Drivers|set_property\(TARGET STM32_Drivers|Drivers/STM32F1xx_HAL_Driver/Src/\*' CMakeLists.txt; then
  die "root CMakeLists.txt must not override CubeMX HAL source selection"
fi

printf 'template contract OK: %s\n' "$PROJECT"
