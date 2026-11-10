# Changelog

Versions are dates (YY.M.R): the year, the month, and the release within
that month. Any release may change how a move runs.

## 26.11.2

- Stage 4, stashes: `git stash branch` restores a stash without committing
  it, so pushing right after left the changes on no remote. The step now
  commits the restored changes before the push.

## 26.11.1

- Remote Control on successors: a session's call to turn it on for another
  can be blocked by a hook without an error. Use the app setting "Connect
  new sessions to Remote Control", or make flipping the toolbar switch an
  operator step in the entry brief and the handover.
- Background services: new `references/services.md` on moving a macOS
  LaunchAgent, cron entry or login item with its state (prepare the target,
  stop on the source for good, carry the state, install on the target,
  check its log). Stage 1 now inventories services; the handoff note lists
  them next to scheduled tasks.

## 26.11.0

First public release: the method (fresh restarts, one wave at a time,
change freeze), roles and eight stages; references for restarts, file
bridges, target setup, credentials and scheduled tasks, coordination and
the state-copy alternative; templates for briefs, handoff notes, branch
ledgers and handovers; scripts to scan the workspace, find unpushed work,
stage `~/.claude`, seal and check archives, and compare branch heads.
