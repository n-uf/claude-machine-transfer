#!/usr/bin/env bash
# Stage a copy of ~/.claude for a sealed archive: config, skills, agents,
# commands, hooks, plugin settings and memory. Leaves out session history,
# caches, credentials and scheduled tasks.
#
#   stage-claude-home.sh <stage-dir> [--memory-only] [--skip-project GLOB]... [--include NAME]...
#
# The result is <stage-dir>/.claude/…, so seal it with
#   seal-archive.sh claude-home <stage-dir> .claude <out-dir>
# and unpack it on the target into "$HOME".
#
# --memory-only        only projects/*/memory (to re-send memory between waves)
# --skip-project GLOB  leave out memory of project folders matching GLOB
#                      (folder names under ~/.claude/projects, e.g. '-opt-work-private*')
# --include NAME       also copy ~/.claude/NAME (file or folder)
# CLAUDE_HOME          source folder (default ~/.claude)
set -euo pipefail

stage=${1:?usage: stage-claude-home.sh <stage-dir> [--memory-only] [--skip-project GLOB]... [--include NAME]...}
shift
src=${CLAUDE_HOME:-$HOME/.claude}
memory_only=0
skips=()
extra=()
while [ $# -gt 0 ]; do
  case $1 in
    --memory-only) memory_only=1; shift ;;
    --skip-project) skips+=("${2:?--skip-project needs a glob}"); shift 2 ;;
    --include) extra+=("${2:?--include needs a name}"); shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -d "$src" ] || { echo "no $src" >&2; exit 1; }
dst=$stage/.claude
if [ -e "$dst" ] && [ -n "$(ls -A "$dst")" ]; then
  echo "STOP: $dst is not empty" >&2; exit 1
fi
mkdir -p "$dst"
rs() { rsync -a --exclude .DS_Store --exclude node_modules --exclude __pycache__ "$@"; }

if [ $memory_only = 0 ]; then
  # Files: user-level instructions and settings (no credentials live here).
  for f in CLAUDE.md settings.json settings.local.json keybindings.json; do
    [ -f "$src/$f" ] && cp -p "$src/$f" "$dst/"
  done
  # Folders: your own building blocks.
  for d in agents commands hooks skills output-styles bin; do
    [ -d "$src/$d" ] && rs "$src/$d" "$dst/"
  done
  # Plugins: only the settings files; plugins themselves reinstall from their marketplaces.
  if [ -d "$src/plugins" ]; then
    mkdir -p "$dst/plugins"
    find "$src/plugins" -maxdepth 1 -type f -name '*.json' -exec cp -p {} "$dst/plugins/" \;
  fi
  for x in ${extra[@]+"${extra[@]}"}; do
    case $x in /*|*..*) echo "STOP: --include takes a name inside $src: $x" >&2; exit 1 ;; esac
    [ -e "$src/$x" ] || { echo "skip: no $src/$x" >&2; continue; }
    mkdir -p "$dst/$(dirname "$x")"
    rs "$src/$x" "$dst/$(dirname "$x")/"
  done
fi

# Memory, per project folder. Folder names encode absolute paths, which is why
# both machines need the same paths.
n=0
for m in "$src"/projects/*/memory; do
  [ -d "$m" ] || continue
  proj=$(basename "$(dirname "$m")")
  for g in ${skips[@]+"${skips[@]}"}; do
    # shellcheck disable=SC2254
    case $proj in $g) continue 2 ;; esac
  done
  mkdir -p "$dst/projects/$proj"
  rs "$m" "$dst/projects/$proj/"
  n=$((n + 1))
done

echo "staged $dst: $(find "$dst" -type f | wc -l | tr -d ' ') files, memory of $n projects"
echo "not staged on purpose: session history (projects/*.jsonl), todos, caches, credentials, scheduled-tasks"
