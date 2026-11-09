#!/usr/bin/env bash
# Build a sealed archive: secret scan -> sha256 manifest -> tar.gz of one
# named member -> optional age encryption.
#
#   seal-archive.sh <name> <root> <member> <out-dir> [--age RECIPIENT]...
#
# The archive holds <root>/<member>/… as <member>/…, and is unpacked on the
# target with check-archive.sh into the matching root (e.g. "$HOME").
# Writes <out-dir>/<name>.tar.gz (or .tar.gz.age) and <out-dir>/<name>.manifest.txt.
# Needs gitleaks; with --age, needs age. Stops on any secret finding.
set -euo pipefail

usage='usage: seal-archive.sh <name> <root> <member> <out-dir> [--age RECIPIENT]...'
name=${1:?$usage}; root=${2:?$usage}; member=${3:?$usage}; out=${4:?$usage}
shift 4
recipients=()
while [ $# -gt 0 ]; do
  case $1 in
    --age) recipients+=(-r "${2:?--age needs a recipient (age1…)}"); shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

# Only a named member, never "." or "./": unpacking "./" would rewrite the
# permissions and owner of the unpack root itself (e.g. $HOME).
case $member in
  .|./|/*|*..*|-*|'') echo "STOP: member must be a relative name inside <root>, not '$member'" >&2; exit 1 ;;
esac
member=${member%/}
[ -e "$root/$member" ] || { echo "STOP: no $root/$member" >&2; exit 1; }
command -v gitleaks >/dev/null || { echo "STOP: gitleaks not installed (brew install gitleaks)" >&2; exit 1; }
if [ ${#recipients[@]} -gt 0 ]; then
  command -v age >/dev/null || { echo "STOP: age not installed (brew install age)" >&2; exit 1; }
fi
mkdir -p "$out"
out=$(cd "$out" && pwd)

# Symlinks would travel in the tar without being scanned or listed in the
# manifest. Stage with real files instead (stage-claude-home.sh does).
links=$(cd "$root" && find "$member" -type l)
if [ -n "$links" ]; then
  echo "STOP: symlinks in $root/$member (replace them with the files they point to):" >&2
  printf '%s\n' "$links" | head -20 >&2
  exit 1
fi

echo "== $name: scanning $root/$member for secrets"
rc=0
gitleaks dir "$root/$member" --no-banner --redact --exit-code 3 >/dev/null 2>&1 || rc=$?
if [ $rc = 3 ]; then
  gitleaks dir "$root/$member" --no-banner --redact -v 2>&1 | grep -E 'RuleID|File:' || true
  echo "STOP: gitleaks found something in $name. Remove it from the staged copy and run again." >&2
  exit 1
elif [ $rc != 0 ]; then
  echo "STOP: gitleaks failed (exit $rc). 'gitleaks dir' needs gitleaks 8.19 or newer." >&2
  exit 1
fi

manifest=$out/$name.manifest.txt
count=$(cd "$root" && find "$member" -type f ! -name .DS_Store | wc -l | tr -d ' ')
[ "$count" -gt 0 ] || { echo "STOP: $root/$member holds no files" >&2; exit 1; }
(cd "$root" && find "$member" -type f ! -name .DS_Store -print0 | sort -z | xargs -0 shasum -a 256) >"$manifest"

tarball=$out/$name.tar.gz
COPYFILE_DISABLE=1 tar -czf "$tarball" --exclude .DS_Store -C "$root" -- "$member"

if [ ${#recipients[@]} -gt 0 ]; then
  age "${recipients[@]}" -o "$tarball.age" "$tarball"
  rm -f "$tarball"
  tarball=$tarball.age
fi

echo "$name: $count files, $(du -h "$tarball" | cut -f1) -> $tarball"
echo "manifest: $manifest"
