#!/usr/bin/env bash
# Stage a copy of ~/.claude for a sealed archive: config, skills, agents,
# commands, hooks, plugin settings and memory. Leaves out session history,
# caches, credentials and scheduled tasks.
#
#   stage-claude-home.sh <stage-dir> [--memory-only] [--only-project GLOB]... [--skip-project GLOB]... [--include NAME]...
#
# The result is <stage-dir>/.claude/…, so seal it with
#   seal-archive.sh claude-home <stage-dir> .claude <out-dir>
# and unpack it on the target into "$HOME".
#
# settings.json and settings.local.json are staged as *.from-source, so the
# source's hooks and paths don't take effect on the target before someone
# has checked them. Merge them by hand after the path check.
# Symlinks are replaced by the files they point to, so the scan sees them.
#
# --memory-only        only projects/*/memory (to re-send memory between waves)
# --only-project GLOB  only memory of project folders matching GLOB (repeatable)
# --skip-project GLOB  leave out memory of project folders matching GLOB
#                      (folder names under ~/.claude/projects, e.g. '-opt-work-docs-site*')
# --include NAME       also copy ~/.claude/NAME (file or folder)
# CLAUDE_HOME          source folder (default ~/.claude)
set -euo pipefail

stage=${1:?usage: stage-claude-home.sh <stage-dir> [--memory-only] [--only-project GLOB]... [--skip-project GLOB]... [--include NAME]...}
shift
src=${CLAUDE_HOME:-$HOME/.claude}
memory_only=0
onlys=()
skips=()
extra=()
while [ $# -gt 0 ]; do
  case $1 in
    --memory-only) memory_only=1; shift ;;
    --only-project) onlys+=("${2:?--only-project needs a glob}"); shift 2 ;;
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
rs() { # copy with symlinks replaced by their files; stop on broken links first
  local src_path=$1 broken
  broken=$(find -L "$src_path" -type l 2>/dev/null || true)
  if [ -n "$broken" ]; then
    echo "STOP: broken symlinks (fix or remove them, then run again):" >&2
    printf '%s\n' "$broken" | head -20 >&2
    exit 1
  fi
  rsync -aL --exclude .DS_Store --exclude node_modules --exclude __pycache__ "$@"
}

if [ $memory_only = 0 ]; then
  # Files: user-level instructions and settings. settings.json can hold an
  # `env` block, MCP headers or an apiKeyHelper: read it before sealing.
  for f in CLAUDE.md keybindings.json; do
    if [ -f "$src/$f" ]; then cp -pL "$src/$f" "$dst/"; fi
  done
  for f in settings.json settings.local.json; do
    if [ -f "$src/$f" ]; then cp -pL "$src/$f" "$dst/$f.from-source"; fi
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
  if [ ${#onlys[@]} -gt 0 ]; then
    keep=0
    for g in "${onlys[@]}"; do
      # shellcheck disable=SC2254
      case $proj in $g) keep=1 ;; esac
    done
    [ $keep = 1 ] || continue
  fi
  for g in ${skips[@]+"${skips[@]}"}; do
    # shellcheck disable=SC2254
    case $proj in $g) continue 2 ;; esac
  done
  mkdir -p "$dst/projects/$proj"
  rs "$m" "$dst/projects/$proj/"
  n=$((n + 1))
done

echo "staged $dst: $(find "$dst" -type f | wc -l | tr -d ' ') files, memory of $n projects"
echo "not staged on purpose: session history (projects/*.jsonl), todos, caches, credentials, scheduled-tasks, ~/.claude.json"
if [ $memory_only = 0 ]; then
  echo "settings staged as settings*.json.from-source: merge them on the target after checking their paths"
fi
