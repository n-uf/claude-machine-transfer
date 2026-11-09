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

Write this order into the handoff note of the session that owns the
credential, with the exact click path or command for the operator.

## Scheduled tasks run on one machine only

- In stage 4, each lead session lists its scheduled tasks
  (`~/.claude/scheduled-tasks/*`) and says, for each: keep running, move,
  or leave disabled.
- **Move** = the successor recreates the task on the target from its
  definition (copied next to the handoff note), then the predecessor disables
  it on the source. Never both enabled.
- A one-off task due before the successor is up stays on the source; keep the
  source awake for it, and recreate it on the target only if it didn't run.
- Tasks that were already disabled stay disabled on the source; don't move
  them unless asked.
- Recreated tasks that were disabled on the source start disabled on the
  target too.
