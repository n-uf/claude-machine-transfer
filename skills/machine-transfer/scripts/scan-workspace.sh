#!/usr/bin/env bash
# Inventory of a projects root: one TSV row per entry, two levels down.
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

{
  printf 'path\tkind\tmain\tbranch\tdirty\tlast_commit\tsize\tmodified\n'
  find "$root" -mindepth 1 -maxdepth 2 | sort | while IFS= read -r p; do
    skip "$(basename "$p")" && continue
    # Skip entries inside a skipped first-level folder (e.g. root/node_modules/x).
    first=${p#"$root"/}; first=${first%%/*}
    skip "$first" && continue
    rel=${p#"$root"/}
    size=$(du -sh "$p" 2>/dev/null | cut -f1)
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
