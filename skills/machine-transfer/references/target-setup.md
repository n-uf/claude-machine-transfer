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
  //npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
  ```

  and set the variable only for the install:
  `NODE_AUTH_TOKEN=$(gh auth token) pnpm install` (or npm, yarn). Without the
  line, installs get a 401. Don't export `GITHUB_TOKEN` globally for this:
  `gh` then uses it instead of its stored login. Don't copy the source's
  `~/.npmrc` if it holds a literal token.

  Package install scripts can read `NODE_AUTH_TOKEN`, and `gh auth token`
  carries every scope your login has. Safer: a fine-grained or classic token
  with `read:packages` only, used just for installs; or install with scripts
  off first (`pnpm install --ignore-scripts`) and run the scripts you trust
  without the token set.
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

- The desktop app is installed and signed in to the same account; the entry
  session exists with Remote Control on; this skill is installed (stage 3,
  step 0).
- **Remote Control for new sessions.** Turn on the app setting "Connect new
  sessions to Remote Control", or plan for the operator to flip each
  successor's switch in its toolbar. A session's own call to turn it on can
  be rewritten by a hook (no verdict, no denial), and a successor without
  Remote Control can't reach the source.
- Sidebar sections exist in the source's order.
- `~/.claude` is unpacked and checked (stage 6), after a backup of the whole
  folder (`cp -Rp ~/.claude ~/.claude.pre-transfer`).
- `settings.json.from-source`: every absolute path in it (an SSH agent
  socket, a hook script, a tool path) exists on the target, and `hooks`,
  `permissions` (`defaultMode`), `env` and `apiKeyHelper` have been read.
  Then the operator merges it into `settings.json`. Report paths that don't exist; don't edit
  blindly.
- MCP servers from the source's `claude mcp list` are added again
  (`claude mcp add …`), with fresh keys.
- Your own skills and scripts run: try one command from each.

## Versions the scripts need

- git 2.31 or newer (`check-heads.sh` and `scan-workspace.sh` use
  `rev-parse --path-format=absolute`).
- gitleaks 8.19 or newer (`gitleaks dir`), and `age` for encrypted archives.

## The target's own sessions

- File any sessions already on the target into the right sidebar section.
  Never archive, delete or rename them.
