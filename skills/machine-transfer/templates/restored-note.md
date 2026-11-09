# Restored: <lead session title> (target, `<local_…>`)

Handover received <date> (directly / relayed / from file). "ready" sent.

## Checks
- `check-heads.sh --fetch` on the ledger: all MATCH, no WARN (paste the summary line).
- Anything else checked against the handoff note: open PRs, last CI run.

## Restore
- Worktrees recreated: paths and heads.
- Dependencies installed: where.
- Child sessions restarted: titles and new ids.
- Scheduled tasks recreated: names, enabled or disabled.
- Fixes made on the way (stale paths and the like), with commits.

## Waits on the operator
- Tool sign-ins or installs still missing, and which step needs them.

## Mine next
- What this session does after the freeze lifts.
