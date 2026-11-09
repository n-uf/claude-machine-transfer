# Handover message: <lead session title>

Paste as the successor's first message, or save as `handover.md` beside the
handoff note when the predecessor can't reach the successor.

---

You are the successor of **<lead session title>** on the target machine.
Working folder: `<absolute path>`.

Read first:
- `<path>/handoff-note.md` (scope, in flight, child sessions, sync points)
- `<path>/branch-ledger.md` (every branch and its commit)

State in one line: <nothing in flight / what's in flight>.

Do now:
1. Verify: run `scripts/check-heads.sh <path>/branch-ledger.md`. Every row
   must print MATCH. On any mismatch, stop and send the output to
   <predecessor or transfer coordinator>.
2. Reply "ready" to <predecessor or transfer coordinator>.
3. Restore: install dependencies, recreate the worktrees in the handoff note,
   restart the child sessions from their restart briefs, nested under you.
4. Report "restored" to the transfer coordinator with a short note.

Operator steps to expect (the app won't do these from a turn another
session's message began; the operator types them in this session or clicks
the cards):
- Start child sessions: <titles>.
- Create scheduled tasks: <names, enabled or disabled>.

The wave is frozen: nothing ships, merges, pushes or publishes until the
transfer coordinator lifts the freeze.

Waiting on the operator: <items, or "nothing">.
