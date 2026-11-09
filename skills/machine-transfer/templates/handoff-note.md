# Handoff note: <lead session title>

Written <date> on the source. Predecessor session id: `<local_…>`. Model and
effort: <…>. Working folder: `<absolute path>`.

## Status

One line: nothing in flight / what is in flight and where it stopped.

## Scope

What this session owns: apps, sites, packages, repos. Link the plan of record
(a file in the repo), not a copy of it.

## Repos and worktrees

| Path | Repo | Branch | Head | Note |
|---|---|---|---|---|
| /opt/work/web-app | your-org/web-app | main | `0123456` | shared clone |
| /opt/work/web-app-checkout-retry | your-org/web-app | feat/checkout-retry | `89abcde` | worktree; recreate on the target |

Full commits for the main clones: `branch-ledger.md` beside this note.
Worktrees are listed only here; the successor recreates them after it has
checked the ledger.

## In flight

For each piece of work: what it is, its branch and head, what's built, what's
reviewed (on which head), what's tested, what's next, and what it waits on.

## Waiting on the operator

Exact decisions or actions, each with the words the operator would reply.

## Child sessions

| Title | Role | Old session id | Restart |
|---|---|---|---|
| Checkout retry | builder | `<local_…>` | brief below |

### Restart brief: Checkout retry

A paste-ready brief under 40 lines for a fresh session: task, branch,
worktree path, current head, the next step, the checks it runs, and what it
must not do while the wave is frozen.

## Scheduled tasks

| Task | Schedule | Decision |
|---|---|---|
| weekly-report | Mondays 08:00 | move: definition in `scheduled-tasks/weekly-report/`; successor recreates it disabled, the coordinator disables it here, then it's enabled there |

## Local-only files

Files git ignores that the work needs: `.env`, local config, test data.
Names and paths only, and how the successor recreates each (fresh secrets,
copied from an example file, regenerated, or sent as one private file and
waiting in the target's inbox to be moved in after its worktree exists).
Never their secret values.

## MCP servers

The servers this session uses (`claude mcp list`), their scope, and where
their keys come from on the target.

## Credentials the successor needs

Names only, and who makes them on the target (never values). Note any
revoke-then-create order, and whether it waits for cut-over because other
sessions share the grant.

## Sync points

Other lead sessions this one shares a repo, release order or environment
with, and what to agree with them after the restart.

## Files beside this note

Anything that lived only in a scratchpad or temporary notes folder, copied
here, because those folders don't move.
