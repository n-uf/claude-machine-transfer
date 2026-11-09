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
The operator cloned it in step 0; if it's missing, stop and ask.

## 2. Clones (same paths; skip a folder that already holds that clone)

| Path | Repo | Branch |
|---|---|---|
| /opt/work/docs-site | your-org/docs-site | main |

Set the git identity in each clone if it isn't global. No installs, no
worktrees: successors do those.

## 3. Sealed archives

`scripts/` is this skill's scripts folder (the operator installed the skill
here in step 0).

1. Fetch: `gh release download <tag> --repo your-org/workspace-ops --dir /opt/work/_inbox`
   (or the operator moves the AirDrop/USB file and its manifest into
   `/opt/work/_inbox`).
2. Look first:
   `scripts/check-archive.sh /opt/work/_inbox/<name>.tar.gz[.age] /opt/work/_inbox/<name>.manifest.txt <unpack root> [--identity <key>] --list`
3. Back up what it will replace. For `~/.claude`: `cp -Rp ~/.claude ~/.claude.pre-transfer`.
   For memory re-sends in later waves: check none of its projects belongs to
   a successor that's already restored; if one does, stop and ask.
4. Unpack and check: the same command without `--list`. It must end with
   `ok:` and exit 0.
5. `~/.claude/settings.json.from-source`: report every absolute path in it
   that doesn't exist here. Don't merge it; the operator does.
6. Delete the archives from `/opt/work/_inbox`.

## 4. Report

Each clone's `git rev-parse HEAD`, each archive check's last line, the
missing paths from step 5, and anything skipped.
