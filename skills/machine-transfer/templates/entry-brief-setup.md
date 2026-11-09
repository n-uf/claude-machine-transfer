# Brief for the entry session: folder skeleton and sidebar sections

You're preparing this machine to mirror the source. This step makes empty
folders and sidebar sections only. No repos, files or config yet, apart from
what the operator did by hand in step 0 (app, this session, the skill, `gh`
sign-in, the transfer repo clone).

The operator pastes this brief into the entry session; later briefs arrive as
files in the transfer repo.

## 0. Look first, report, change nothing

- Does `/opt/work` exist? Who owns it? List it two levels deep.
- Can you write to it without `sudo`?
- Which sidebar tools do you have? List the current sections and sessions.

If `/opt/work` holds anything besides the transfer repo, stop after this
report and wait. If creating it needs `sudo`, give the exact command for the
operator and wait.

## 1. Folder skeleton (empty folders only)

```
/opt/work/web-app
/opt/work/docs-site
/opt/work/tools
/opt/work/_inbox
```

`mkdir -p` only. Never delete, move or overwrite. Don't clone or `git init`.

## 2. Sidebar sections, in this order

Create them top to bottom: new sections go to the bottom, so creation order is
the final order.

| # | Section | Will hold |
|---|---|---|
| 1 | web-app | `/opt/work/web-app*` |
| 2 | docs-site | `/opt/work/docs-site*` |
| 3 | tools | `/opt/work/tools`, workspace setup, this transfer |

File this machine's existing sessions into a section; list anything you can't
place. Never archive, delete or rename a session.

## 3. Report back

- `find /opt/work -maxdepth 2 -type d`
- The section list in order, with the session count in each.
- Anything skipped, and why.
