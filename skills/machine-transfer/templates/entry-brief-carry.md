# Brief for the entry session: carry over the <section name> wave

Rules: same absolute paths as the source. Don't change system or security
settings. Don't print secrets. Don't start dev servers, ship, merge or push.
Ask before overwriting anything not listed here.

## 0. Sign-in

`gh auth status` shows the operator's account over HTTPS, with the
`read:packages` scope if projects install from GitHub Packages. If not, ask
the operator to run `gh auth login` and `gh auth setup-git`. Don't sign in
yourself.

## 1. Pull the transfer repo

`git -C /opt/work/tools/workspace-ops pull --ff-only` (needs at least `<commit>`).

## 2. Clones (same paths; skip a folder that already holds that clone)

| Path | Repo | Branch |
|---|---|---|
| /opt/work/docs-site | your-org/docs-site | main |

Set the git identity in each clone if it isn't global. No installs, no
worktrees: successors do those.

## 3. Sealed archives

1. Back up: `cp -p ~/.claude/settings.json ~/.claude/settings.json.pre-transfer`
   (and `CLAUDE.md`).
2. Fetch: `gh release download <tag> --repo your-org/workspace-ops --dir /opt/work/_inbox`
   (or the operator moves the AirDrop/USB file into `/opt/work/_inbox`).
3. Check and unpack:
   `scripts/check-archive.sh /opt/work/_inbox/<name>.tar.gz[.age] /opt/work/_inbox/<name>.manifest.txt <unpack root> [--identity <key>]`
4. Report whether absolute paths in `~/.claude/settings.json` exist here.
5. Delete the archives from `/opt/work/_inbox`.

## 4. Report

Each clone's `git rev-parse HEAD`, the archive checks (they print nothing on
success), and anything skipped.
