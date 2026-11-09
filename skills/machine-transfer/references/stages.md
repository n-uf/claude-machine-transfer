# The stages in detail

Each stage lists what gets done, the operator's part and what it ends with.
Stages 1–4 run once (stage 4's check runs again before each wave). Stages 5–7
repeat per wave. Stage 8 closes each wave and, after the last one, the whole
transfer.

Sample values used below: projects root `/opt/work`, sidebar sections
`web-app`, `docs-site` and `tools`, GitHub owner `your-org`, transfer repo
`your-org/workspace-ops` cloned at `/opt/work/tools/workspace-ops`.
`scripts/…` means this skill's `scripts` folder.

## 1. Take stock

**Done by:** the transfer coordinator, on the source.

- Sessions: list every open session with its title, sidebar section, model,
  working folder, and which sessions it started (nesting). Note which have
  Remote Control on.
- Folders: `scripts/scan-workspace.sh /opt/work` writes a TSV of the first
  level, and of the inside of folders that aren't git checkouts (kind, branch,
  uncommitted files, size without dependencies, last change).
- Git: `scripts/scan-unpushed.sh /opt/work` lists folders with no remote,
  working copies with uncommitted files or commits on no remote, local
  branches whose tip is on no remote, and stashes.
- Local-only files git ignores: `.env` files, local config, keys. List them per
  repo (`git status --ignored --short`, minus dependencies and build output).
  They don't travel as they are: secrets are made fresh, and the rest goes in
  the handoff note.
- Size: most of a large tree is usually `node_modules` and build output.
  Dependencies get reinstalled, not copied.
- `~/.claude`: `CLAUDE.md`, `settings.json`, agents, commands, hooks, skills,
  plugins, memory per project, scheduled tasks, and any extra config
  directories you use (`CLAUDE_CONFIG_DIR` profiles).
- `~/.claude.json`: user-scope MCP servers and per-project settings
  (`claude mcp list` shows the servers). It also holds account state, so it
  isn't copied; the servers are added again on the target.
- Tools and versions: `node -v`, `python3 --version`, your package manager,
  `git --version`, `gh`, and anything the projects call (cloud SDKs, database
  clients, secret managers, a browser for tests).

**Ends with:** an inventory file and the scan output, kept in the transfer
repo next to the plan.

## 2. Agree the layout

**Done by:** the transfer coordinator proposes, the operator decides.

Decide and record, each with a letter (A, B, C…) on the transfer board:

- What moves now, what later, what never (old experiments, archives).
- The folder layout on the target. Keep it identical to the source unless you
  have a reason; any rename means fixing every note, memory and script that
  names the old path. Tidy loose files before the move, not during it.
- Where worktrees live. Keep them where handoff notes and tools expect them;
  move them later, when nothing is in flight.
- The waves and their order. One sidebar section per wave works well. Move a
  quiet wave first to prove the method.
- Which lead sessions stay behind on the source, if any
  ([restart.md](restart.md), "A lead session that stays behind").
- How files travel ([file-bridges.md](file-bridges.md)).
- Who owns the folders that have no remote today (which GitHub owner, private),
  and the private transfer repo that carries plan, board, briefs and handoffs.

**Operator's part:** a yes to each decision.

**Ends with:** decisions recorded on the board and, where they change how
sessions work, in memory.

## 3. Prepare the target

### Step 0: the operator, by hand

Nothing on the target can read a brief until these are done:

1. Install the Claude desktop app and sign in to the same account.
2. Create the entry session in the sidebar (any folder, for example
   `/opt/work`), send it one message, then turn its Remote Control on. Remote
   Control can be turned on only for a session that has run a turn.
3. Install this skill there (see the README), so the target has the same
   `scripts/`.
4. `gh auth login` (HTTPS) and `gh auth setup-git`, plus
   `gh auth refresh -h github.com -s read:packages` if projects use GitHub
   Packages.
5. Clone the transfer repo:
   `git clone https://github.com/your-org/workspace-ops.git /opt/work/tools/workspace-ops`.
   If the projects root doesn't exist yet, the entry session's first report
   (below) says how to make it.
6. Paste the first brief into the entry session. Later briefs can be files in
   the transfer repo, named in a one-line message.

### Then the entry session

**Done by:** the entry session, from a brief
([../templates/entry-brief-setup.md](../templates/entry-brief-setup.md)).

- Report first, change nothing: does the projects root exist, who owns it,
  what's inside, can it be written without `sudo`, which sidebar tools exist.
- Folder skeleton with `mkdir -p` only. Never delete, move or overwrite.
- Sidebar sections in the source's order. New sections are added at the
  bottom, so creation order is the final order.
- Tools at the source's versions, then the prerequisites in
  [target-setup.md](target-setup.md).

**Operator's part:** step 0; other sign-ins; anything that needs `sudo` or a
password.

**Ends with:** skeleton, sections and tools in place; `gh auth status` shows
the right account and scopes; the entry session reachable over Remote Control.

Stages 3 and 4 can run side by side.

## 4. Push everything to remotes

**Done by:** the transfer coordinator, once, before the first wave freezes.

- Folders with no remote: create a private repo, add a `.gitignore` that keeps
  out screenshots, large binaries and build output, run a secret scan
  (`gitleaks git .` or `gitleaks dir .`), then push.
- Branches that can't be pushed (a repo you can't write to, or work you don't
  want on the shared remote): `git bundle create <name>.bundle <branch>…`, then
  carry the bundle as a private file.
- Stashes: turn each into a branch (`git stash branch <name>`) and push it, or
  drop it on purpose.
- Small local config tweaks that aren't committed: write them down in a note
  in the transfer repo rather than committing them to a shared repo.
- Fix stale absolute paths in memory and scripts before the copy.

**Ends with:** every folder in scope has a remote. Before each wave freezes,
`scripts/scan-unpushed.sh` is run again over that wave's folders; whatever it
lists is pushed by the lead session that owns it, in stage 5.

## 5. Freeze and hand off (per wave)

**Done by:** each lead session in the wave, from the freeze brief
([../templates/freeze-brief.md](../templates/freeze-brief.md)).

1. Reach a safe point. Land or park what's in flight. Commit work in progress
   on its branch or on `wip/<slug>`. Nothing merges without its normal checks.
2. Push every branch whose commits exist only on the source, in one push, with
   no force. Check each local head equals the remote head.
3. Write the handoff note, branch ledger and handover message
   ([../templates/handoff-note.md](../templates/handoff-note.md),
   [../templates/branch-ledger.md](../templates/branch-ledger.md),
   [../templates/handover-message.md](../templates/handover-message.md)).
   Copy anything that lives only in a scratchpad or temporary notes folder
   next to the handoff note: those don't move.
4. List its scheduled tasks and say which must keep running.
5. Stop its own dev servers by PID. Go idle.
6. Report to the coordinator: handoff path, anything unpushed and why,
   scheduled tasks, anything waiting on the operator.

Then the freeze holds: no ship, merge, push or publish in the wave's repos.
The pushes in step 2 come before it. The transfer repo isn't frozen: handoffs,
board and briefs keep flowing through it.

Dated content that publishes itself on a remote schedule (a GitHub Actions
cron, for example) keeps running; it doesn't depend on either machine. Only
manual ship, merge, push and publish stop.

A lead session that should stay on the source (it needs a tool or device
only the source has) says so here; it isn't frozen, and is used from the
target over Remote Control ([restart.md](restart.md), "A lead session that
stays behind").

**Ends with:** every lead session in the wave idle; `scripts/scan-unpushed.sh`
lists nothing for the wave's folders; every head in every ledger equals the
remote.

## 6. Carry over (per wave)

**Done by:** the transfer coordinator builds, the entry session unpacks
([../templates/entry-brief-carry.md](../templates/entry-brief-carry.md)).

- Clone every repo at the same path, over HTTPS. Set the git identity. Skip a
  folder that already holds that clone; ask before anything that would
  overwrite.
- Don't install dependencies or create worktrees here: successors do that.
- Non-git files: `scripts/seal-archive.sh` on the source,
  `scripts/check-archive.sh` on the target.
- `~/.claude`, first wave: `scripts/stage-claude-home.sh` then
  `scripts/seal-archive.sh` on the source. On the target:
  1. `check-archive.sh … --list` to see what it holds.
  2. Back up the target's whole `~/.claude`:
     `cp -Rp ~/.claude ~/.claude.pre-transfer`.
  3. Unpack and check. The archive replaces files with the same name (skills,
     hooks, memory) and adds the rest.
  4. Settings arrive as `settings.json.from-source` (and
     `settings.local.json.from-source`), so the source's hooks and paths don't
     act on the target yet. Check every absolute path in them (an SSH agent
     socket, a hook script, a tool path) exists on the target, then the
     operator merges them into `settings.json`.
- MCP servers: add the user-scope servers again on the target
  (`claude mcp add …`); their keys are made fresh.
- Memory, later waves: memory keeps changing on the source. Before each wave's
  successors start, re-send that wave's projects only:
  `stage-claude-home.sh <dir> --memory-only --only-project '<glob>'`, then seal
  and check as above. Never unpack memory over a project whose successor is
  already restored: it would overwrite what the successor wrote.

**Operator's part:** sign-ins, the settings merge, and moving files the app
can't read.

**Ends with:** the same tree on both machines for the wave's folders; every
archive check ends with `ok:` and exit 0; your own scripts and hooks run on
the target.

## 7. Restart lead sessions (per wave)

Spawn → handover → verify → restore → retire. See [restart.md](restart.md).

**Operator's part:** type the go for the entry session to start successors;
then, in each successor's own session, the steps its handover lists (child
sessions, scheduled tasks); approve held messages, if any.

**Ends with:** every successor in the wave reports restored; every predecessor
is idle.

## 8. Verify and cut over

- Run one real flow end to end on the target: a test suite, a dev server, a
  release dry run, whatever the wave's work depends on.
- Lift the wave's freeze: the coordinator tells every successor, and each
  confirms.
- Move the next wave (back to stage 5).
- After the last wave: swap the OAuth grants that every wave shared
  ([secrets-and-schedules.md](secrets-and-schedules.md)); the operator works
  from the target. The source's sessions stay idle as history, apart from
  stay-behind lead sessions. Scheduled tasks are disabled there, apart from
  those a stay-behind session keeps.

**Ends with:** all work on the target (or reached from it), nothing running
twice.
