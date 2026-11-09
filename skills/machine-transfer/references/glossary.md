# Glossary

Plain terms for a machine transfer. The right column lists informal words
people tend to use for the same thing, so you can map your own notes.

| Term | Meaning | Also called |
|---|---|---|
| **Source machine** | The machine the workspace is on now. | old Mac |
| **Target machine** | The machine it moves to. | new Mac |
| **Workspace** | Everything a person works with in Claude Code: sessions and their sidebar sections, project folders, repos and worktrees, `~/.claude` (config, skills, agents, hooks, memory), scheduled tasks, signed-in tools. | setup |
| **Transfer coordinator** | The one session on the source that runs the whole transfer: inventory, plan, briefs, transfer board, check-ins. | machine transfer session |
| **Entry session** | The first session on the target, reached over Remote Control. It prepares folders, clones and archives, then starts each successor. | landing session, sessions transfer |
| **Lead session** | A top-level session that owns a scope (an app, a site, a set of repos) and may run child sessions under it. | hub, orchestrator |
| **Child session** | A session a lead session started and supervises: builders, a release session, side tasks. | builder, worker, nested session |
| **Predecessor** | A lead session on the source, once its successor exists. | old hub |
| **Successor session** | The lead session's replacement on the target. It takes over from the handoff note, not from session history. | twin, new hub |
| **Wave** | The set of sessions and repos that move together, normally one sidebar section. | group, batch |
| **Change freeze** | While a wave moves, its sessions don't ship, merge, push or publish. | freeze |
| **Safe point** | A moment where nothing is half-done: work is committed, in-flight changes are landed or parked on a branch. | |
| **Handoff note** | The written state of a lead session: scope, repos and worktrees, in flight, waiting on the operator, child sessions and how to restart them, sync points. | hub.md |
| **Branch ledger** | A table of repo, branch and commit, each checked against the remote. The successor compares it with its clones. | branches.md |
| **Handover message** | The first message a successor gets: where the handoff note is, the branch ledger, what's in flight, what waits on the operator. It may be a file when it can't be sent. | init |
| **Restored** | A successor has matched every head in its ledger and restarted its child sessions. | rebuilt |
| **Retire** | After its successor reports ready, the predecessor does nothing more. It stays idle and is not archived. | |
| **Carry-over** | Moving what isn't in git: non-git folders, `~/.claude` config and memory. | carry |
| **File bridge** | The channel files travel over: GitHub (repo or release) or Syncthing, with AirDrop or USB as fallbacks. | |
| **Sealed archive** | A tar archive that passed a secret scan and comes with a checksum manifest; optionally `age`-encrypted. | airdrop archive |
| **Fresh restart** | This skill's method: successors start new and rebuild from notes. | |
| **State copy** | The alternative: copying session history and app data so old sessions resume on the target. Heavier, with strict preconditions. | session carry |
| **Transfer board** | The coordinator's table of every side: where it runs, how to reach it, state, what it owes. | status board |
| **Check-in** | The coordinator's periodic pass over every side to refresh the board. | |
| **Sync point** | A place where two lead sessions share something: a repo, a release order, a test environment. Successors re-establish them. | |
| **Cut over** | The moment the operator works from the target and the source goes quiet. | switch |
