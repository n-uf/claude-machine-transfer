# Background services

A background service runs on its own, outside any session: a macOS
LaunchAgent, a cron entry, a login item. Like a scheduled task it must run on
one machine only, and its state (where it left off) has to travel with it.
This order was tested in a real move, with a gap of about six minutes
between the stop on the source and the first run on the target.

Sample used below: a mail-filter agent with the label
`com.example.mail-filter`, plist
`~/Library/LaunchAgents/com.example.mail-filter.plist`, state file
`~/.local/state/mail-filter/last-id` (the last message it processed).

## Find them (stage 1)

```bash
launchctl list | grep -v com.apple          # loaded agents not from Apple
ls ~/Library/LaunchAgents                   # their plists
crontab -l                                  # cron entries
```

Login items: System Settings → General → Login Items. For each service, note
the label, the program and the tool paths its plist calls, the credentials it
reads (which Keychain items, never their values), its state files and its log
path (`StandardOutPath` in the plist).

## Move one

1. **Prepare the target first.**
   - The tools at the exact paths the plist names (a Homebrew binary, a
     script in a project folder).
   - Credentials stored in the target's Keychain by the operator: copied, or,
     cleaner, minted fresh for that machine. A session never handles the
     values.
   - A read-only check that signs in with them (the service's dry-run or
     list command), so a bad credential shows up before the stop.
2. **Stop on the source, and make sure it can't start again.**
   ```bash
   launchctl bootout gui/"$(id -u)" ~/Library/LaunchAgents/com.example.mail-filter.plist
   ```
   Then move the plist out of `~/Library/LaunchAgents` (keep a copy beside
   the handoff note) and check that nothing is left: no job in
   `launchctl list`, no process (`pgrep -fl mail-filter`), no plist, no cron
   entry, no scheduled task, no login item that starts it.
3. **Seal the state, restore it, check it.**
   ```bash
   scripts/seal-archive.sh mail-filter-state ~/.local/state mail-filter <out-dir>
   ```
   On the target, `scripts/check-archive.sh … ~/.local/state` and check it
   ends with `ok:`.
4. **Install and start on the target.**
   ```bash
   launchctl bootstrap gui/"$(id -u)" ~/Library/LaunchAgents/com.example.mail-filter.plist
   ```
   The permission check treats installing a LaunchAgent as persistence and
   refuses an approval relayed from another session: the operator approves
   it in the session that installs it, or runs the command in Terminal.
5. **Check it runs.** `launchctl print gui/"$(id -u)"/com.example.mail-filter`
   shows it loaded with a clean last exit, and the first log lines look
   normal. With the state carried over, it works through the backlog from
   the gap.

## Keep the gap short

- Do step 1, and step 3 as a dry run, before step 2.
- Seal the state again right after the stop: that copy is the one restored.
- Keep the operator at hand for step 4, so nothing waits on an approval.

## Rules

- One machine at a time: never both running, as with scheduled tasks
  ([secrets-and-schedules.md](secrets-and-schedules.md)).
- Credentials don't travel in archives or handoff notes; the handoff note
  names the Keychain items and who makes them.
- A service that should stay on the source goes on the transfer board, like
  a stay-behind lead session.
