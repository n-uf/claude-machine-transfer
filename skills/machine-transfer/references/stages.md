# The stages in detail

Each stage lists what gets done, the operator's part and what it ends with.
Stages 1–3 run once. Stages 4–7 repeat per wave. Stage 8 closes each wave and,
after the last one, the whole transfer.

Sample values used below: projects root `/opt/work`, sidebar sections
`web-app`, `docs-site` and `tools`, GitHub owner `your-org`.

## 1. Take stock

**Done by:** the transfer coordinator, on the source.

- Sessions: list every open session with its title, sidebar section, model,
  working folder, and which sessions it started (nesting). Note which have
  Remote Control on.
- Folders: run `scripts/scan-workspace.sh /opt/work` for a TSV of every folder
  two levels down (clone, worktree, plain folder, size, last change).
- Git: run `scripts/scan-unpushed.sh /opt/work`. It lists folders with no
  remote, working copies with uncommitted files or commits on no remote, and
  local branches whose tip is on no remote.
- Size: most of a large tree is usually `node_modules` and build output.
  Measure without them; dependencies get reinstalled, not copied.
- `~/.claude`: `CLAUDE.md`, `settings.json`, agents, commands, hooks, skills,
  plugins, memory per project, scheduled tasks, and any extra config
  directories you use (`CLAUDE_CONFIG_DIR` profiles).
- Tools and versions: `node -v`, `python3 --version`, your package manager,
  `gh`, and anything the projects call (cloud SDKs, database clients,
  secret managers, a browser for tests).

**Ends with:** an inventory file and the scan output, kept next to the plan.

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
- How files travel ([file-bridges.md](file-bridges.md)).
- Who owns the folders that have no remote today (which GitHub owner, private).

**Operator's part:** a yes to each decision.

**Ends with:** decisions recorded on the board and, where they change how
sessions work, in memory.

## 3. Prepare the target

**Done by:** the entry session, from a brief
([../templates/entry-brief-setup.md](../templates/entry-brief-setup.md)).

- Report first, change nothing: does the projects root exist, who owns it,
  what's inside, can it be written without `sudo`, which sidebar tools exist.
- Folder skeleton with `mkdir -p` only. Never delete, move or overwrite.
- Sidebar sections in the source's order. New sections are added at the
  bottom, so creation order is the final order.
- Tools at the source's versions, then the prerequisites in
  [target-setup.md](target-setup.md).

**Operator's part:** sign in to `gh` and other tools on the target; anything
that needs `sudo` or a password.

**Ends with:** skeleton, sections and tools in place; `gh auth status` shows
the right account and scopes.

## 4. Freeze and hand off (per wave)

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

Dated content that publishes itself on a remote schedule (a GitHub Actions
cron, for example) keeps running; it doesn't depend on either machine. Only
manual ship, merge, push and publish stop.

A lead session that should stay on the source (it needs a tool or device
only the source has) says so here; it keeps running and is used from the
target over Remote Control ([restart.md](restart.md), "A lead session that
stays behind").

**Ends with:** every lead session in the wave idle, every head in every ledger
equal to the remote.

## 5. Push everything to remotes

**Done by:** the transfer coordinator.

- Folders with no remote: create a private repo, add a `.gitignore` that keeps
  out screenshots, large binaries and build output, run a secret scan
  (`gitleaks git .` or `gitleaks dir .`), then push.
- Branches that can't be pushed (a repo you can't write to, or work you don't
  want on the shared remote): `git bundle create <name>.bundle <branch>…`, then
  carry the bundle as a private file.
- Small local config tweaks that aren't committed: write them down in a note
  beside the handoffs rather than committing them to a shared repo.
- Fix stale absolute paths in memory and scripts before the copy.

**Ends with:** `scripts/scan-unpushed.sh` prints nothing for the wave's folders.

## 6. Carry over (per wave)

**Done by:** the transfer coordinator builds, the entry session unpacks
([../templates/entry-brief-carry.md](../templates/entry-brief-carry.md)).

- Clone every repo at the same path, over HTTPS. Set the git identity. Skip a
  folder that already holds that clone; ask before anything that would
  overwrite.
- Don't install dependencies or create worktrees here: successors do that.
- Non-git files and `~/.claude`: `scripts/stage-claude-home.sh` and
  `scripts/seal-archive.sh` on the source; `scripts/check-archive.sh` on the
  target. Back up the target's `settings.json` and `CLAUDE.md` first.
- Check absolute paths inside `settings.json` (an SSH agent socket, a tool
  path) exist on the target. Report rather than edit.
- After the first wave, send only what changed, memory above all.

**Operator's part:** sign-ins, and moving files the app can't read.

**Ends with:** the same tree on both machines for the wave's folders; a
manifest check that prints nothing; your own scripts and hooks run on the
target.

## 7. Restart lead sessions (per wave)

Spawn → handover → verify → restore → retire. See [restart.md](restart.md).

**Operator's part:** type the go for the entry session to start successors;
approve held messages, if any.

**Ends with:** every successor in the wave reports restored; every predecessor
is idle.

## 8. Verify and cut over

- Run one real flow end to end on the target: a test suite, a dev server, a
  release dry run, whatever the wave's work depends on.
- Lift the wave's freeze: the coordinator tells every successor, and each
  confirms.
- Move the next wave (back to stage 4).
- After the last wave: the operator works from the target. The source's
  sessions stay idle as history. Scheduled tasks are disabled there.

**Ends with:** all work on the target, nothing running twice.
