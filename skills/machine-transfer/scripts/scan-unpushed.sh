#!/usr/bin/env bash
# List everything under a projects root that exists only on this machine:
#   NO-REMOTE  a git checkout with no remote at all
#   WORKTREE   a checkout with uncommitted files or commits on no remote
#   BRANCH     a local branch whose tip is on no remote (+N commits)
# Silent for anything fully on a remote. Exit 1 if anything was listed.
#
#   scan-unpushed.sh <root> [--depth N] [--fetch]
#
# --depth N  how deep to look for checkouts (default 3)
# --fetch    fetch every remote first, so "on a remote" is current
# Read-only apart from --fetch.
set -u

root=${1:?usage: scan-unpushed.sh <root> [--depth N] [--fetch]}
root=${root%/}
shift
depth=3 fetch=0
while [ $# -gt 0 ]; do
  case $1 in
    --depth) depth=${2:?--depth needs a number}; shift 2 ;;
    --fetch) fetch=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

found=0
while IFS= read -r gitpath; do
  p=$(dirname "$gitpath")
  rel=${p#"$root"/}; [ "$p" = "$root" ] && rel=.
  if [ -z "$(git -C "$p" remote 2>/dev/null)" ]; then
    echo "NO-REMOTE  $rel"; found=1; continue
  fi
  # Branches are shared by a clone and its worktrees: check them once, from the clone.
  if [ -d "$gitpath" ]; then
    [ $fetch = 1 ] && git -C "$p" fetch -q --all 2>/dev/null
    while IFS= read -r b; do
      n=$(git -C "$p" rev-list --count "refs/heads/$b" --not --remotes 2>/dev/null)
      if [ "${n:-0}" != 0 ]; then printf 'BRANCH     %s  %s  +%s\n' "$rel" "$b" "$n"; found=1; fi
    done < <(git -C "$p" for-each-ref --format='%(refname:short)' refs/heads)
  fi
  up=$(git -C "$p" rev-list --count HEAD --not --remotes 2>/dev/null || echo 0)
  dirty=$(git -C "$p" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$up" != 0 ] || [ "$dirty" != 0 ]; then
    br=$(git -C "$p" branch --show-current 2>/dev/null); [ -n "$br" ] || br=detached
    printf 'WORKTREE   %s  [%s]  unpushed=%s dirty=%s\n' "$rel" "$br" "$up" "$dirty"; found=1
  fi
done < <(find "$root" -maxdepth "$depth" \( -name node_modules -o -name .venv \) -prune -o -name .git -print | sort)

exit $found
