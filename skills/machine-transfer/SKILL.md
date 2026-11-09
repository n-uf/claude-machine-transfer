---
name: machine-transfer
description: "Move a multi-session Claude Code workspace (desktop app sessions and sidebar sections, repos and worktrees, ~/.claude config, skills and memory, scheduled tasks) from one Mac to another without losing work: take stock, freeze one wave at a time, write handoff notes, push everything to remotes, carry over the rest through GitHub or Syncthing, then restart each lead session as a fresh successor on the target that checks its branch heads before it resumes. Use when someone asks to move, migrate or transfer their Claude Code setup, sessions or projects to a new or second machine, to plan or run such a move, to write a handoff note or handover message for a successor session, to restart sessions on another Mac, or to check a move's progress."
---

# machine-transfer: move a Claude Code workspace to another Mac

A busy Claude Code workspace is more than files. It has lead sessions with
child sessions, work on unpushed branches, sidebar sections, memory, skills,
scheduled tasks and signed-in tools. Copying the disk moves the files and
loses the rest. This skill moves the workspace **by fresh restarts**: every
lead session writes down its state, a successor starts on the target machine,
checks that state against git, and takes over. The old session goes idle.

Words used below are defined in [references/glossary.md](references/glossary.md).
The short version: the **source** machine is where you are, the **target** is
where you're going, a **lead session** owns a scope, its **successor** takes it
over on the target, and a **wave** is one sidebar section moved at a time.

## Principles

1. **Same absolute paths on both machines.** Project folders, worktrees and
   `~/.claude` sit at the same paths, ideally under the same user name.
   Memory folders, handoff notes, scripts and hooks all name absolute paths;
   identical paths let them work unchanged.
2. **Nothing exists on one machine only.** Every commit is on a remote (a
   private repo or a bundle if it has no home) before anything is copied.
3. **Fresh restart, not a state copy.** Sessions restart from handoff notes.
   Copying session history is a separate, heavier option with its own
   preconditions: [references/state-copy.md](references/state-copy.md).
4. **One wave at a time, frozen until restored.** A wave stops shipping,
   merging, pushing and publishing when it starts to move, and stays frozen
   until every successor in it reports restored.
5. **One owner per piece.** The transfer coordinator owns machine-level work,
   the entry session starts successors, each lead session owns its own
   handoff and restart.
6. **Old sessions retire, they are not archived.** They stay as history.
7. **Credentials never travel.** Keys, tokens and keychain items are made
   fresh on the target. See [references/secrets-and-schedules.md](references/secrets-and-schedules.md).
8. **Evidence over reports.** When two sides disagree, settle it with command
   output (`git rev-parse`, `gh auth status`), not by trusting either report.

## Roles

| Role | Where | Does |
|---|---|---|
| Operator | both machines | Decides, signs in to tools, moves files that need a human, types the go for new sessions on the target, says when to switch. |
| Transfer coordinator | source | One session that runs the move: inventory, plan, briefs, the transfer board, check-ins, carry-over. |
| Entry session | target | The first session on the target, reached over Remote Control. Builds folders, clones, unpacks, then starts each successor. Starts no child sessions of its own. |
| Lead session (predecessor) | source | Reaches a safe point, writes its handoff note, sends the handover message, retires. |
| Successor session | target | Checks the heads in the handover, restarts its child sessions, reports restored. |

## The eight stages

Stages 1–4 run once. Stages 5–7 repeat for each wave. Stages 3 and 4 can run
side by side. Details, checks and the "ends with" for each stage:
[references/stages.md](references/stages.md). `scripts/…` below means this
skill's own `scripts` folder; install the skill on the target too (stage 3,
step 0), so both machines have the same scripts.

1. **Take stock.** Inventory sessions (open, nested, by sidebar section),
   folders, repos, worktrees, unpushed commits and stashes, folders with no
   remote, gitignored local files, MCP servers, and the `~/.claude` setup.
   Run `scripts/scan-workspace.sh` and `scripts/scan-unpushed.sh`.
2. **Agree the layout.** What moves now, later or never; the folder layout on
   the target; the waves and their order; who stays behind; how files travel.
   Record each decision with its letter on the transfer board.
3. **Prepare the target.** The operator installs the app, creates the entry
   session with Remote Control on, installs this skill, signs in to `gh` and
   clones the transfer repo. Then the entry session builds the folder
   skeleton, sidebar sections and tools.
   Checklist: [references/target-setup.md](references/target-setup.md).
4. **Push everything to remotes.** Private repos for folders with no remote,
   `git bundle` for branches that can't be pushed, a secret scan first.
5. **Freeze and hand off (per wave).** Send the freeze brief
   ([templates/freeze-brief.md](templates/freeze-brief.md)). Each lead
   session reaches a safe point, pushes its branches, writes a handoff note,
   a branch ledger and a handover message, then freezes.
   `scripts/scan-unpushed.sh` must come back empty for the wave.
6. **Carry over (per wave).** The entry session clones every repo at the same
   path. Non-git files and `~/.claude` travel over a file bridge as sealed
   archives with a manifest: [references/file-bridges.md](references/file-bridges.md).
7. **Restart lead sessions (per wave).** Spawn → handover → verify → restore →
   retire: [references/restart.md](references/restart.md).
8. **Verify and cut over.** Run a real check end to end on the target, lift
   the freeze, then the next wave starts at stage 5. When the last wave is
   done, the operator switches machines.

## Coordination

The transfer coordinator keeps a transfer board
([templates/transfer-board.md](templates/transfer-board.md)): one row per
side with where it runs, how to reach it, its state and what it still owes.
It checks in with every side on a schedule, reports only changes and gaps to
the operator, and reconciles contradictions with evidence. Rules and message
patterns: [references/coordination.md](references/coordination.md).

## Claude Code specifics to know before you start

- **The app won't start sessions or create scheduled tasks from a turn
  another session began.** The operator types the go in the entry session
  to start successors. A successor's first turns come from the handover
  message, so its child sessions and scheduled tasks are operator steps too
  (typed in its own session, or cards to click); the handover lists them.
- **Sessions start on their own machine only** (or in the cloud, or on a saved
  SSH host). Nothing on the source starts sessions on the target; the
  operator steers either side over Remote Control.
- **A lead session can stay behind** on the source and be used from the
  target over Remote Control: see "A lead session that stays behind" in
  [references/restart.md](references/restart.md).
- **Remote Control off means no Remote Control rows.** A lead session with
  Remote Control off can't see or message sessions on the target. Write the
  handover message to a file; the successor reads it, or the coordinator
  relays it.
- **Duplicate titles.** A successor usually has its predecessor's title. When
  `ListAgents` shows two rows with one title, address by the row's `[ref]`.
- **Session id is not transcript id.** A session's `local_…` id and the file
  name of its transcript differ. Record the session id on the board.
- **Memory keeps changing.** Memory written after the first `~/.claude`
  archive must be sent again before each wave's successors start:
  `scripts/stage-claude-home.sh <dir> --memory-only --only-project '<glob>'`
  for that wave's projects, then seal and check. Never unpack it over a
  project whose successor is already restored.
- **Settings arrive set aside.** `settings.json` is staged as
  `settings.json.from-source`, so the source's hooks and paths don't act on
  the target before their paths are checked and the operator merges them.
- **Scheduled tasks run on one machine only.** Recreate on the target
  disabled, disable on the source, then enable on the target; never both
  enabled.
- **MCP servers live in `~/.claude.json`,** which isn't copied (it holds
  account state). Add the servers again on the target with fresh keys.
- **macOS privacy.** The app can't read `~/Downloads` (or Desktop and
  Documents) without a privacy grant. Have the operator move incoming files
  to a folder under the project root rather than changing security settings.

## Files in this skill

| Path | What |
|---|---|
| `references/glossary.md` | The terms used throughout |
| `references/stages.md` | Each stage: what gets built, the operator's part, what it ends with |
| `references/restart.md` | How a lead session comes back on the target |
| `references/file-bridges.md` | GitHub and Syncthing as primary bridges; AirDrop/USB fallbacks; sealed archives |
| `references/target-setup.md` | Target prerequisites learned the hard way |
| `references/secrets-and-schedules.md` | Credentials, OAuth order, scheduled tasks |
| `references/coordination.md` | Transfer board, check-ins, reconciling reports |
| `references/state-copy.md` | The heavier alternative: copying session state |
| `templates/*.md` | Freeze brief, handoff note, branch ledger, handover message, restored note, entry briefs, transfer board |
| `scripts/scan-workspace.sh` | Inventory of a projects root as TSV |
| `scripts/scan-unpushed.sh` | Everything not on a remote; silent when clean |
| `scripts/stage-claude-home.sh` | Stage `~/.claude` config and memory, without history or secrets |
| `scripts/seal-archive.sh` | Secret scan → manifest → tar (optionally `age`-encrypted) |
| `scripts/check-archive.sh` | Safe unpack plus manifest check on the target |
| `scripts/check-heads.sh` | Compare a branch ledger with the local clones |

## Don'ts

- Don't copy credentials, keychain items, `.env` files with live values, or
  tokens in `~/.npmrc`.
- Don't open SSH or Remote Login between the machines by default: it exposes
  the whole OS user account. If you must, follow the hardened setup in
  [references/restart.md](references/restart.md).
- Don't archive or delete old sessions; they retire idle.
- Don't lift a wave's freeze before every successor in it reports restored.
- Don't change system or security settings from a session; give the
  operator the exact command or click path.
- Don't run a scheduled task on both machines.
