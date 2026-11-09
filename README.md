# claude-machine-transfer

A Claude Code skill for moving a busy Claude Code workspace from one Mac to
another without losing work in flight.

A workspace with many sessions is more than files: lead sessions run child
sessions, branches hold unpushed commits, sidebar sections group the work,
memory and skills live in `~/.claude`, scheduled tasks fire on their own,
and tools are signed in. Copying the disk moves the files and loses the rest.

`/machine-transfer` moves it by **fresh restarts**, one sidebar section (a
*wave*) at a time:

1. **Take stock** of sessions, repos, worktrees, unpushed work and `~/.claude`.
2. **Agree the layout**: what moves, in which waves, how files travel.
3. **Prepare the target**: same paths, tools, sign-ins, sidebar sections.
4. **Freeze and hand off**: each lead session reaches a safe point, pushes,
   and writes a handoff note, a branch ledger and a handover message.
5. **Push everything to remotes**: nothing exists on one machine only.
6. **Carry over**: clones from GitHub; the rest over GitHub or Syncthing as
   sealed (secret-scanned, checksummed, optionally `age`-encrypted) archives.
7. **Restart lead sessions**: a successor starts on the target, checks every
   branch head against the ledger, restarts its child sessions; the old
   session retires idle.
8. **Verify and cut over**, then the next wave.

It came out of a real move of a few dozen sessions across five sidebar
sections, and encodes what went wrong along the way: missing package scopes,
a headless browser that won't start until it's opened once, OAuth grants that
must be revoked before they're re-created, the app's refusal to start
sessions from another session's turn, and more.

## Install

As a plugin, from inside Claude Code:

```
/plugin marketplace add n-uf/claude-machine-transfer
/plugin install machine-transfer@n-uf-machine-transfer
```

Or copy the skill folder into your own skills:

```bash
git clone https://github.com/n-uf/claude-machine-transfer.git
cp -R claude-machine-transfer/skills/machine-transfer ~/.claude/skills/
```

## Use

In the session that will coordinate the move, on the source machine:

```
/machine-transfer plan a move of this workspace to my new Mac
```

The skill walks through the stages, writes the briefs for the target's entry
session, and gives each lead session the freeze brief and templates for its
handoff.

## What's inside

| Path | What |
|---|---|
| `skills/machine-transfer/SKILL.md` | The method, roles, stages and rules |
| `skills/machine-transfer/references/` | Glossary, stage details, the restart protocol, file bridges, target setup, credentials and scheduled tasks, coordination, and the state-copy alternative |
| `skills/machine-transfer/templates/` | Freeze brief, handoff note, branch ledger, handover message, restored note, entry-session briefs, transfer board |
| `skills/machine-transfer/scripts/` | `scan-workspace.sh`, `scan-unpushed.sh`, `stage-claude-home.sh`, `seal-archive.sh`, `check-archive.sh`, `check-heads.sh` |

The scripts are plain bash for macOS (they run on the stock bash 3.2). They
need `git`; `seal-archive.sh` needs [`gitleaks`](https://github.com/gitleaks/gitleaks),
and encryption needs [`age`](https://github.com/FiloSottile/age).

## Scope

- macOS to macOS, with the Claude desktop app and Remote Control. Most stages
  apply elsewhere too; the restart protocol assumes the desktop app.
- It moves sessions by fresh restart. Copying session history so old
  sessions resume is a different, heavier job; `references/state-copy.md`
  says what it takes.
- Credentials never travel; they are made fresh on the target.

## License

[PolyForm Perimeter 1.0.1](./LICENSE).
