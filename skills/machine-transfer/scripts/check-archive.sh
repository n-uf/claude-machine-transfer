#!/usr/bin/env bash
# Unpack a sealed archive safely and check it against its manifest.
#
#   check-archive.sh <archive.tar.gz[.age]> <manifest.txt> <unpack-root> [--identity KEY] [--list]
#
# 1. Decrypts an .age archive with --identity (to a temp file, removed after).
# 2. Lists the members and refuses: absolute paths, '..', a bare '.'/'./',
#    anything outside the manifest's one top-level name, symlinks, hardlinks
#    and special files, and any difference between the archive's files and
#    the manifest's.
# 3. Unpacks into <unpack-root> (files with the same name are replaced: run
#    --list first and back up the root's copy of those members).
# 4. Runs the manifest with shasum. Ends with "ok: …" and exit 0 on success.
# --list  stop after step 2 (shows the top-level members, changes nothing).
set -euo pipefail

usage='usage: check-archive.sh <archive> <manifest> <unpack-root> [--identity KEY] [--list]'
archive=${1:?$usage}; manifest=${2:?$usage}; dest=${3:?$usage}
shift 3
identity='' list_only=0
while [ $# -gt 0 ]; do
  case $1 in
    --identity) identity=${2:?--identity needs a key file}; shift 2 ;;
    --list) list_only=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -f "$archive" ] || { echo "STOP: no $archive" >&2; exit 1; }
[ -f "$manifest" ] || { echo "STOP: no $manifest" >&2; exit 1; }
[ -d "$dest" ] || { echo "STOP: unpack root $dest does not exist" >&2; exit 1; }
manifest=$(cd "$(dirname "$manifest")" && pwd)/$(basename "$manifest")

tmp=
cleanup() { if [ -n "$tmp" ]; then rm -f "$tmp"; fi; return 0; }
trap cleanup EXIT
case $archive in
  *.age)
    [ -n "$identity" ] || { echo "STOP: $archive is encrypted; pass --identity <key>" >&2; exit 1; }
    tmp=$(mktemp "${TMPDIR:-/tmp}/check-archive.XXXXXX")
    age -d -i "$identity" -o "$tmp" "$archive"
    archive=$tmp ;;
esac

stop() { echo "STOP: $1" >&2; [ -n "${2:-}" ] && printf '%s\n' "$2" | head -20 >&2; exit 1; }

members=$(tar -tzf "$archive")
bad=$(printf '%s\n' "$members" | grep -E '^/|(^|/)\.\.(/|$)|^\./?$' || true)
[ -z "$bad" ] || stop "unsafe members in the archive:" "$bad"

# The manifest names one top-level member; every archive member must be under it.
paths=$(sed -E 's/^[0-9a-f]{64}  //' "$manifest")
tops=$(printf '%s\n' "$paths" | sed 's#/.*##' | sort -u)
[ "$(printf '%s\n' "$tops" | wc -l | tr -d ' ')" = 1 ] || stop "the manifest names more than one top-level member:" "$tops"
outside=$(printf '%s\n' "$members" | grep -vE "^$(printf '%s' "$tops" | sed 's/[.[\*^$]/\\&/g')(/|$)" || true)
[ -z "$outside" ] || stop "members outside '$tops':" "$outside"

# Only regular files and folders: no symlinks, hardlinks, devices or fifos.
odd=$(tar -tvzf "$archive" | grep -E '^[^-d]| link to | -> ' || true)
[ -z "$odd" ] || stop "links or special files in the archive:" "$odd"

# The archive's files are exactly the manifest's files.
diffs=$(diff <(printf '%s\n' "$members" | grep -v '/$' | sort) <(printf '%s\n' "$paths" | sort) || true)
[ -z "$diffs" ] || stop "archive files and manifest differ (< archive only, > manifest only):" "$diffs"

echo "top-level member: $tops"
echo "files: $(printf '%s\n' "$paths" | wc -l | tr -d ' '), all listed in the manifest"
[ $list_only = 1 ] && exit 0

tar -xzf "$archive" -C "$dest"
if (cd "$dest" && shasum -a 256 -c --quiet "$manifest"); then
  echo "ok: every file matches the manifest"
else
  echo "FAIL: files above differ from the manifest" >&2
  exit 1
fi
