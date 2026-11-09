# Coordination: the transfer board and check-ins

## The transfer board

The transfer coordinator keeps one board
([../templates/transfer-board.md](../templates/transfer-board.md)), in the
private repo that carries the handoffs, so both machines can read it.

One row per side: the entry session, every predecessor and every successor.
Columns:

- **Side**: the session's title (and "source" or "target").
- **Address**: how to reach it: its session id, or its Remote Control row
  name plus `[ref]` when titles repeat. Record the session id from the
  session list, not a transcript file name.
- **State**: frozen, handed over, ready, restored, retired, idle.
- **Owes**: what that side still has to send or do. "Nothing" is a valid
  answer and the goal.

Below the table: the decisions (A, B, C…), what waits on the operator, and
what's done.

## Check-ins

- The coordinator checks in with every side on a schedule (every hour or two
  during an active wave), not only when it's messaged.
- To the operator it reports only changes and gaps, never the whole board.
- A side that went quiet gets one nudge with the exact thing it owes.

## Reconciling contradictory reports

Two sides will sometimes disagree: "signed in" vs "401", "pushed" vs
"missing on the remote", two different session ids for one successor.

1. Don't pick a side. Ask each for the command output that shows it:
   `gh auth status`, `git ls-remote origin <branch>`, `git rev-parse <branch>`,
   the session list row.
2. Record the reconciled fact and its evidence on the board.
3. Correct whichever report was wrong, and tell that side.

## Message patterns

- **Briefs** go as files in the private repo plus a one-line message that
  names the file. Long briefs in a message get cut or misread.
- **First line first:** the recipient often sees only the first line until it
  opens the message. Make it say what the message is.
- **Approvals don't travel.** An approval the operator gave to one session
  doesn't authorize another. The operator types it where the action runs:
  starting sessions, merging, publishing, credential changes.
- **Remote Control off** means a session can't see target rows. Relay for it,
  or have it write to a file.

## Freeze discipline

- The freeze brief says exactly what stops (ship, merge, push, publish) and
  what keeps running (remote scheduled publishing, CI on already-open PRs).
- Only the coordinator lifts a wave's freeze, after every successor in it
  reports restored. It tells each successor, and each confirms.
