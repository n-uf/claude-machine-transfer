# File bridges

Repos travel as clones from their remote. Everything else (non-git folders,
`~/.claude` config and memory, bundles) needs a file bridge. Two bridges are
primary; two are fallbacks; one is ruled out.

| Bridge | Use for | Notes |
|---|---|---|
| **GitHub, private repo** | Small, non-secret files: handoff notes, briefs, scripts, carry-over folders without secrets | Primary. Both machines already have `gh`. History shows what changed. |
| **GitHub, private release + `age`** | Private files: `~/.claude` archives, memory, bundles | Primary. Encrypted to a key made on the target. |
| **Syncthing** | Large or recurring transfers | Primary. Paired by device ID, LAN-only, one direction. |
| AirDrop | A one-off large file when Syncthing isn't set up | Fallback. Lands in `~/Downloads`, which the app can't read. |
| USB drive | A one-off when there's no network between the machines | Fallback. Encrypt with `age` first. |
| ~~SSH / Remote Login~~ | — | **Not for files.** It opens the whole OS user account (files, signed-in CLIs, any program) to the network. If you need SSH to start sessions, see [restart.md](restart.md) for the hardened setup. |

## GitHub: a private repo for small non-secret files

- One private repo (for example `your-org/workspace-ops`) holds the transfer
  folder: plan, board, briefs, handoff notes, small carry-over folders.
- Secret-scan before every push: `gitleaks git .` (or `gitleaks dir <folder>`
  for a folder not yet committed).
- Keep screenshots, large binaries and build output out of git with
  `.gitignore`; send those over Syncthing if they must move.
- On the target, the entry session clones it once and `git pull --ff-only`
  per wave.

## GitHub: `age`-encrypted archives on a private release

The private key is made on the target and never leaves it.

On the target:

```bash
age-keygen -o ~/.config/age/transfer.key   # prints "Public key: age1…"
```

Send the public key (`age1…`) to the source through the private repo or a
message; it isn't secret.

On the source:

```bash
scripts/seal-archive.sh claude-home /tmp/stage .claude ./out --age age1examplepublickey
gh release create transfer-wave-1 --repo your-org/workspace-ops --title "transfer wave 1" \
  --notes "sealed archives, see manifests" ./out/claude-home.tar.gz.age ./out/claude-home.manifest.txt
```

On the target:

```bash
gh release download transfer-wave-1 --repo your-org/workspace-ops --dir /opt/work/_inbox
scripts/check-archive.sh /opt/work/_inbox/claude-home.tar.gz.age /opt/work/_inbox/claude-home.manifest.txt "$HOME" \
  --identity ~/.config/age/transfer.key
```

Delete the release after the check passes:
`gh release delete transfer-wave-1 --repo your-org/workspace-ops --yes --cleanup-tag`.

## Syncthing: large or recurring transfers

Use it when files are large (asset folders, sample data) or change during the
transfer (a folder you keep working in until cut over).

1. Install on both: `brew install syncthing`, then `brew services start syncthing`.
   The web UI is at `http://127.0.0.1:8384`.
2. **Pair by device ID.** Each machine shows its ID under Actions → Show ID.
   Add the other machine's ID by hand; don't accept unknown devices.
3. **LAN only.** In Settings → Connections on both machines, turn off
   *Enable Relaying*, *Global Discovery* and *Enable NAT traversal*; keep
   *Local Discovery* on. (CLI: `syncthing cli config options relays-enabled set false`,
   `… global-ann-enabled set false`, `… natenabled set false`.)
4. **One direction.** Share the folder from the source as *Send Only*; accept
   it on the target as *Receive Only*, at the **same absolute path**.
5. Add a `.stignore` before the first sync:

   ```
   node_modules
   .next
   dist
   build
   .turbo
   .venv
   .DS_Store
   ```

6. Don't sync `.git` folders, secrets or `~/.claude` live: git has its own
   remote, and `~/.claude` goes as a sealed archive.
7. When the transfer is done, remove the shared folder on both sides and stop
   the service if you don't need it.

## Fallbacks: AirDrop and USB

- Build the archive with `scripts/seal-archive.sh` exactly as for GitHub; use
  `--age` for anything private.
- **AirDrop** lands in `~/Downloads`. macOS privacy controls block the app
  from reading `~/Downloads`, Desktop and Documents without a grant. Don't
  change the grant from a session. Ask the operator to move the file:
  `mv ~/Downloads/claude-home.tar.gz /opt/work/_inbox/`.
- **USB**: copy the encrypted archive and its manifest; eject; on the target,
  copy into `/opt/work/_inbox/` and run `scripts/check-archive.sh`.
- Delete the archive from the inbox after the check passes.

## Sealed archives

Every archive that isn't a git clone is sealed:

1. **Stage** a copy of exactly what moves (for `~/.claude`:
   `scripts/stage-claude-home.sh`), so nothing extra slips in.
2. **Scan** the staged copy for secrets (`gitleaks dir`). Stop on any finding.
3. **Manifest**: one `sha256  path` line per file, paths relative to the
   unpack root.
4. **Tar the member by name**, never `./`: unpacking `./` rewrites the
   permissions and owner of the unpack root itself (for example `$HOME`).
5. **Check on unpack**: `scripts/check-archive.sh` lists the members first,
   refuses absolute paths and `..`, unpacks, then runs the manifest with
   `shasum -a 256 -c --quiet` (prints nothing on success).
