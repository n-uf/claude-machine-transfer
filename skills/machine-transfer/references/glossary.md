# Glossary

Plain terms for a machine transfer, used the same way in every file of this
skill.

## Machines and people

| Term | Meaning |
|---|---|
| **Source machine** | The machine the workspace is on now. |
| **Target machine** | The machine it moves to. |
| **Operator** | The person who owns the workspace. Decides, signs in, moves files the app can't read, and types the steps the app won't take from another session's message. |
| **Workspace** | Everything a person works with in Claude Code: sessions and their sidebar sections, project folders, repos and worktrees, `~/.claude` (config, skills, agents, hooks, memory), MCP servers, scheduled tasks, signed-in tools. |

## Claude Code terms

| Term | Meaning |
|---|---|
| **Remote Control** | A per-session switch in the Claude desktop app that makes a session reachable from your other devices and from sessions on other machines. A session must have run a turn before it can be turned on. The app setting "Connect new sessions to Remote Control" turns it on for every new session. |
| **Remote Control row** | How a session on another machine shows up in `ListAgents`: its title, plus a `[ref]` when two rows share a title. |
| **`ListAgents`** | The tool a session uses to list the sessions and agents it can message. |
| **Sidebar section** | A named group of sessions in the desktop app's sidebar. |

## Roles

| Term | Meaning |
|---|---|
| **Transfer coordinator** | The one session on the source that runs the whole transfer: inventory, plan, briefs, transfer board, check-ins. |
| **Entry session** | The first session on the target, created by the operator and reached over Remote Control. It prepares folders, clones and archives, then starts each successor. |
| **Lead session** | A top-level session that owns a scope (an app, a site, a set of repos) and may run child sessions under it. |
| **Child session** | A session a lead session started and supervises: builders, a release session, side tasks. |
| **Predecessor** | A lead session on the source, once its successor exists. |
| **Successor session** | The lead session's replacement on the target. It takes over from the handoff note, not from session history. |
| **Stay-behind lead session** | A lead session that doesn't move: it stays on the source and is used from the target over Remote Control. |

## The method

| Term | Meaning |
|---|---|
| **Wave** | The set of sessions and repos that move together, normally one sidebar section. |
| **Change freeze** | While a wave moves, its sessions don't ship, merge, push or publish by hand. Self-publishing dated content keeps going. |
| **Safe point** | A moment where nothing is half-done: work is committed, in-flight changes are landed or parked on a branch. |
| **Handoff note** | The written state of a lead session: scope, repos and worktrees, in flight, waiting on the operator, child sessions and how to restart them, sync points. |
| **Branch ledger** | A table of repo, branch and commit, each checked against the remote. The successor compares it with its clones. |
| **Handover message** | The first message a successor gets: where the handoff note is, the branch ledger, what's in flight, what waits on the operator, and the operator steps to expect. It may be a file when it can't be sent. |
| **Restored** | A successor has matched every head in its ledger and restarted its child sessions. |
| **Retire** | After its successor reports ready, the predecessor does nothing more. It stays idle and is not archived. |
| **Background service** | Something that runs on its own outside any session: a macOS LaunchAgent, a cron entry, a login item. Runs on one machine at a time and carries its state over. |
| **Carry-over** | Moving what isn't in git: non-git folders, `~/.claude` config and memory. |
| **File bridge** | The channel files travel over: GitHub (repo or release) or Syncthing, with AirDrop or USB as fallbacks. |
| **Sealed archive** | A tar archive that passed a secret scan and comes with a checksum manifest; optionally `age`-encrypted. |
| **Transfer repo** | A private repo that carries the plan, board, briefs and handoff notes between the machines. |
| **Fresh restart** | This skill's method: successors start new and rebuild from notes. |
| **State copy** | The alternative: copying session history and app data so old sessions resume on the target. Heavier, with strict preconditions. |
| **Transfer board** | The coordinator's table of every side: where it runs, how to reach it, state, what it owes. |
| **Check-in** | The coordinator's periodic pass over every side to refresh the board. |
| **Sync point** | A place where two lead sessions share something: a repo, a release order, a test environment. Successors re-establish them. |
| **Cut over** | The moment the operator works from the target and the source goes quiet. |
