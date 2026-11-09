# Branch ledger: <lead session title>

Checked with `git ls-remote` on <date>. One row per branch the successor needs.
`scripts/check-heads.sh` reads this table: keep the four columns, the full
40-character commit, and the absolute path of the **main clone**. Worktrees
don't go here: the successor checks heads before it recreates them, so list
them in the handoff note instead.

| Repo path | Branch | Commit | On remote |
|---|---|---|---|
| /opt/work/web-app | main | 0123456789abcdef0123456789abcdef01234567 | yes |
| /opt/work/web-app | feat/checkout-retry | 89abcdef0123456789abcdef0123456789abcdef | yes |

Nothing unpushed. (Or: list each branch that isn't on the remote, why, and
where its bundle is.)
