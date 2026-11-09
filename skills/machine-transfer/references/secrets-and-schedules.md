# Credentials and scheduled tasks

## Credentials never travel

- Don't copy keychain items, tokens, service-account keys, application
  default credentials, `.env` files with live values, or `~/.npmrc` lines with
  literal tokens.
- Don't print them in a session, a brief or a handoff note.
- Every sealed archive passes a secret scan; stop on any finding.
- On the target, the operator signs in again (`gh`, cloud SDKs, secret
  managers). Service keys are made fresh there.
- Handoff notes list **which** credentials a successor needs and who makes
  them, never their values.

## OAuth grants: revoke first, then create

Some providers track a grant per user and app, not per machine. Revoking the
old machine's grant after creating the new one revokes both.

1. On the source (or the provider's account page), revoke the app's grant.
2. On the target, create the new grant (for example a cloud SDK's
   application-default login).
3. Check the target's credential works; the source's no longer does.

**When:** the grant belongs to the user, not to a session. Revoking it cuts
off every session on the source that still uses it, including later waves and
stay-behind sessions. So swap it at cut-over (stage 8), unless only the wave
being moved uses it; then swap it during that wave's restore.

Write this order and timing into the handoff note of the session that owns
the credential, with the exact click path or command for the operator.

## Scheduled tasks run on one machine only

- In stage 5, each lead session lists its scheduled tasks
  (`~/.claude/scheduled-tasks/*`) and says, for each: keep running, move,
  or leave disabled.
- **Move** = the successor recreates the task on the target from its
  definition (copied next to the handoff note), **disabled**; the coordinator
  or the operator disables it on the source; then the target's copy is
  enabled. Never both enabled. (The predecessor is retired by then.)
- The successor can't create a scheduled task from a turn that another
  session's message began (its handover, for example): the app refuses. The
  operator asks for it in the successor's own session. List these tasks under
  "operator steps" in the handover message.
- A stay-behind lead session keeps its tasks on the source; if a successor
  had already recreated them, it deletes its copies and the source's are
  re-enabled.
- A one-off task due before the successor is up stays on the source; keep the
  source awake for it, and recreate it on the target only if it didn't run.
- Tasks that were already disabled stay disabled on the source; don't move
  them unless asked.
- Recreated tasks that were disabled on the source start disabled on the
  target too.
