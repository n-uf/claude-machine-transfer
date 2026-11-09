# Freeze brief: the <section name> wave moves to the target (<date>)

Method: fresh restart. Freeze → handoff → successor on the target → handover
→ restore → the freeze lifts. Flow: <path>/restart.md.

## Your part (each lead session in this wave)

1. **Reach a safe point.** Land or park what's in flight. Push every branch
   whose commits exist only on this machine, in one push, no force. Unfinished
   work goes on its branch as-is or on `wip/<slug>`. Nothing merges without
   its normal checks.
   Then run `scripts/scan-unpushed.sh` over your folders: it must list
   nothing (or only what you explain in your report).
2. **Write your handoff** in `<handoffs path>/<slug>/`:
   - `handoff-note.md`: scope, repos and worktrees, in flight, waiting on the
     operator, child sessions with restart briefs, sync points.
   - `branch-ledger.md`: repo path, branch, full commit, checked against
     `git ls-remote`.
   - `handover.md`: your handover message, ready to send or to be read.
   - Copy anything that lives only in a scratchpad or temporary notes folder
     into the same folder: those don't move.
   - No secrets, tokens or keys.
3. **Scheduled tasks:** list yours and say whether each keeps running. They
   move to the target and are disabled here, never both.
4. **Freeze:** stop your own dev servers by PID and go idle. After the
   handoff, nothing ships, merges, pushes or publishes
   until the transfer coordinator says the wave is restored. Dated content
   that publishes itself on a remote schedule (a GitHub Actions cron) keeps
   going; only manual ship, merge, push and publish stop.
   If your session should stay on this machine instead of moving, say so now.
5. **Report** to the transfer coordinator (`<address>`) in a few lines:
   handoff path, anything left unpushed and why, your scheduled tasks,
   anything waiting on the operator.
