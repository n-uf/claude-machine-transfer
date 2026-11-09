# Freeze brief: the <section name> wave moves to the target (<date>)

Method: fresh restart. Freeze → handoff → successor on the target → handover
→ restore → the freeze lifts. Flow: <path>/restart.md.

## Your part (each lead session in this wave)

1. **Reach a safe point.** Land or park what's in flight. Push every branch
   whose commits exist only on this machine, in one push, no force. Unfinished
   work goes on its branch as-is or on `wip/<slug>`. Nothing merges without
   its normal checks.
2. **Write your handoff** in `<handoffs path>/<slug>/`:
   - `handoff-note.md`: scope, repos and worktrees, in flight, waiting on the
     operator, child sessions with restart briefs, sync points.
   - `branch-ledger.md`: repo path, branch, full commit, checked against
     `git ls-remote`.
   - `handover.md`: your handover message, ready to send or to be read.
   - No secrets, tokens or keys.
3. **Scheduled tasks:** list yours and say whether each keeps running. They
   move to the target and are disabled here, never both.
4. **Freeze:** after the handoff, nothing ships, merges, pushes or publishes
   until the transfer coordinator says the wave is restored. Scheduled
   publishing that runs on a remote service keeps going.
5. **Report** to the transfer coordinator (`<address>`) in a few lines:
   handoff path, anything left unpushed and why, your scheduled tasks,
   anything waiting on the operator.
