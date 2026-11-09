#!/usr/bin/env bash
# Compare a branch ledger with the local clones.
#
#   check-heads.sh <branch-ledger.md> [--fetch] [--remote NAME]
#
# Reads every Markdown table row whose first cell is an absolute path:
#   | /abs/repo/path | branch | commit | … |
# and prints one line per row:
#   MATCH    local branch (if any) and <remote>/branch both equal the commit
#   DIFF     the local branch or <remote>/branch points elsewhere
#   MISSING  no such path, repo, local branch or remote branch
# A fresh clone has only its default branch locally; a row then matches on
# the remote-tracking branch alone. Exit 1 unless every row is MATCH.
# Run it only over your own clones: a repo's git config can run programs
# when git reads it, so don't point it at a checkout you don't trust.
# --fetch  fetch the remote in each repo first (read-only for your branches).
set -u

ledger=${1:?usage: check-heads.sh <branch-ledger.md> [--fetch] [--remote NAME]}
shift
fetch=0 remote=origin
while [ $# -gt 0 ]; do
  case $1 in
    --fetch) fetch=1; shift ;;
    --remote) remote=${2:?--remote needs a name}; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
[ -f "$ledger" ] || { echo "no $ledger" >&2; exit 2; }

trim() { local s=$1; s=${s#"${s%%[![:space:]]*}"}; s=${s%"${s##*[![:space:]]}"}; s=${s//\`/}; printf '%s' "$s"; }

match=0 diff=0 missing=0 fetched=" "
while IFS='|' read -r _ c1 c2 c3 _; do
  path=$(trim "$c1"); branch=$(trim "$c2"); want=$(trim "$c3")
  case $path in /*) ;; *) continue ;; esac
  if [ -z "$branch" ] || [ -z "$want" ]; then
    echo "MISSING  $path  (row has no branch or commit)"; missing=$((missing + 1)); continue
  fi
  if ! git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
    echo "MISSING  $path  $branch  (not a git checkout)"; missing=$((missing + 1)); continue
  fi
  if [ $fetch = 1 ]; then
    common=$(git -C "$path" rev-parse --path-format=absolute --git-common-dir)
    case $fetched in
      *" $common "*) ;;
      *)
        git -C "$path" fetch -q "$remote" 2>/dev/null ||
          echo "WARN     $path  fetch from $remote failed: $remote/* may be stale"
        fetched="$fetched$common " ;;
    esac
  fi
  loc=$(git -C "$path" rev-parse -q --verify "refs/heads/$branch^{commit}" 2>/dev/null || true)
  rem=$(git -C "$path" rev-parse -q --verify "refs/remotes/$remote/$branch^{commit}" 2>/dev/null || true)
  ok() { [ -n "$1" ] && case $1 in "$want"*) true ;; *) false ;; esac; }
  if [ -z "$loc" ] && [ -z "$rem" ]; then
    echo "MISSING  $path  $branch  (no local or $remote branch)"; missing=$((missing + 1))
  elif { [ -z "$loc" ] || ok "$loc"; } && { [ -z "$rem" ] || ok "$rem"; }; then
    note=
    [ -z "$loc" ] && note="  ($remote only)"
    [ -z "$rem" ] && note="  (local only: not on $remote)"
    echo "MATCH    $path  $branch  ${want:0:12}$note"; match=$((match + 1))
  else
    echo "DIFF     $path  $branch  want ${want:0:12}  local ${loc:0:12}  $remote ${rem:0:12}"; diff=$((diff + 1))
  fi
done <"$ledger"

total=$((match + diff + missing))
echo "$total rows: $match match, $diff differ, $missing missing"
[ $total -gt 0 ] && [ $match = $total ]
