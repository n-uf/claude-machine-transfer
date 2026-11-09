# Preparing the target

Each item below failed at least once in a real transfer before it went on
this list. Check them before the first successor starts.

## Paths and user

- The projects root (sample: `/opt/work`) exists, is owned by the operator's
  user and is writable without `sudo`. If creating it needs `sudo`, give the
  operator the exact command:
  `sudo mkdir -p /opt/work && sudo chown "$USER":staff /opt/work`.
- The same user name as the source, if you can. `~/.claude/projects/` names
  memory folders after absolute paths; a different home path means renamed
  memory folders and broken references.

## Git and GitHub

- **HTTPS only.** `gh auth login` (GitHub.com, HTTPS, browser), then
  `gh auth setup-git`. No SSH keys needed on the target.
- **`read:packages` scope**, if any project installs packages from GitHub
  Packages: `gh auth refresh -h github.com -s read:packages`. A fresh
  `gh auth login` lacks it, and every install from `npm.pkg.github.com` then
  fails with a 403.
- **`~/.npmrc` without secrets.** For GitHub Packages, a line that reads the
  token from the environment, never a literal token:

  ```
  //npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
  ```

  and export `GITHUB_TOKEN` from `gh auth token` where installs run. Without
  the line, installs get a 401. Don't copy the source's `~/.npmrc` if it holds
  a literal token.
- Git identity: `git config --global user.name` and `user.email`, or per
  clone if you use different identities per project.

## Runtimes and tools

- Match the source's versions: compare `node -v`, `python3 --version` and
  your package manager on both machines. Drift breaks lockfiles and native
  modules. Pin the package manager with `corepack enable && corepack prepare
  <pm>@<version> --activate` if the project declares one.
- Install the tools projects call: `gitleaks`, `age`, cloud SDKs, database
  clients, secret-manager CLIs. Sign-ins are the operator's.
- **Open Google Chrome once from Finder** and accept the first-run prompt.
  Until then headless Chrome dies with `path_service … Failed to get the path
  for 1001`, and every Playwright check fails.

## Claude Code

- The desktop app is installed and signed in to the same account.
- Sidebar sections exist in the source's order.
- `~/.claude` is unpacked and checked (stage 6). Back up the target's own
  `settings.json` and `CLAUDE.md` first.
- Absolute paths in `settings.json` (an SSH agent socket, a hook script, a
  tool path) exist on the target. Report any that don't; don't edit blindly.
- Your own skills and scripts run: try one command from each.

## The target's own sessions

- File any sessions already on the target into the right sidebar section.
  Never archive, delete or rename them.
