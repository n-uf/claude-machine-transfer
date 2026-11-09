# State copy: the heavier alternative

This skill moves sessions by **fresh restart**: successors start new and
rebuild from handoff notes. The alternative, a **state copy**, carries the
session history and app data so that old sessions show up on the target and
can be resumed. It is not part of this skill's method. It's described here so
you can choose knowingly.

## What a state copy needs

- **The app quit on both machines** for the whole copy. Copying a live data
  folder gives a torn copy.
- **Identical absolute paths and user name.** Session records name working
  folders and worktrees by absolute path.
- **Everything that holds state**, at minimum:
  - `~/.claude/projects/` including the session transcripts, not only memory;
  - `~/.claude.json` (per-project settings, MCP server config);
  - the desktop app's data folder (`~/Library/Application Support/Claude/`),
    often several GB;
  - every extra config directory you use (`CLAUDE_CONFIG_DIR` profiles) and
    its own `.claude.json`.
- **Every worktree and branch** a session refers to, at the same commit.

## What it can't carry

- Keychain items and sign-ins: the app and every tool sign in again anyway.
- Running processes: dev servers, background jobs, Remote Control links.
- Anything machine-bound in the app's data.

## When to prefer it

- A few long sessions whose history you need to scroll and resume, and
  nothing in flight.

## When not to

- Many sessions with child sessions and work in flight: a fresh restart
  gives each successor a checked, written state, and a broken copy fails
  silently.
- A target that already has sessions of its own: copying app data over them
  can lose them.

A state copy is all-or-nothing per data folder and has to be done in one
sitting. A fresh restart can go one wave at a time while the rest of the
workspace keeps working.
