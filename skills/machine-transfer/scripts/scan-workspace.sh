#!/usr/bin/env bash
# Inventory of a projects root: one TSV row per entry at the first level, and
# one per entry inside first-level folders that aren't git checkouts.
# Sizes leave out node_modules and common build output (they get reinstalled).
# Columns: path, kind (clone|worktree|plain|file), main repo (for worktrees),
# branch, dirty file count, last commit date, size, last modified.
#
#   scan-workspace.sh <root> [out.tsv]
#
# Read-only. Writes the TSV to out.tsv (default: stdout).
set -u

root=${1:?usage: scan-workspace.sh <root> [out.tsv]}
root=${root%/}
out=${2:-/dev/stdout}

skip() { # names that are noise at the top two levels
  case $1 in
    .DS_Store|.git|.idea|.vscode|.claude|node_modules|.pytest_cache|.ruff_cache) return 0 ;;
  esac
  return 1
}

entries() { # first-level entries, plus the children of plain (non-git) folders
  find "$root" -mindepth 1 -maxdepth 1 | sort | while IFS= read -r p; do
    skip "$(basename "$p")" && continue
    echo "$p"
    if [ -d "$p" ] && [ ! -e "$p/.git" ]; then
      find "$p" -mindepth 1 -maxdepth 1 | sort | while IFS= read -r c; do
        skip "$(basename "$c")" || echo "$c"
      done
    fi
  done
}

size_wo_deps() { # KB without dependencies and build output
  du -sk -I node_modules -I .next -I dist -I build -I .turbo -I .venv -I target "$1" 2>/dev/null | cut -f1
}

{
  printf 'path\tkind\tmain\tbranch\tdirty\tlast_commit\tsize_mb\tmodified\n'
  entries | while IFS= read -r p; do
    rel=${p#"$root"/}
    kb=$(size_wo_deps "$p"); size=$(( ${kb:-0} / 1024 ))
    mod=$(stat -f %Sm -t %F "$p" 2>/dev/null || date -r "$p" +%F)
    if [ -f "$p" ]; then
      printf '%s\tfile\t\t\t\t\t%s\t%s\n' "$rel" "$size" "$mod"
      continue
    fi
    kind=plain main='' branch='' dirty='' lc=''
    if [ -d "$p/.git" ]; then
      kind=clone
    elif [ -f "$p/.git" ]; then
      kind=worktree
      main=$(git -C "$p" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
      main=${main%/.git}; main=${main#"$root"/}
    fi
    if [ "$kind" != plain ]; then
      branch=$(git -C "$p" branch --show-current 2>/dev/null)
      [ -n "$branch" ] || branch=detached
      dirty=$(git -C "$p" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      lc=$(git -C "$p" log -1 --format=%cs 2>/dev/null)
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$rel" "$kind" "$main" "$branch" "$dirty" "$lc" "$size" "$mod"
  done
} >"$out"

[ "$out" = /dev/stdout ] || echo "wrote $out ($(($(wc -l <"$out") - 1)) rows)" >&2
