# Lessons — folder-backup

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-DEPOSIT-01 | Unprivileged write to `/var/backup` or silent deposit success without sudo | fail-closed + print-sudoers; TP-FOLDER-BACKUP-05 | open watch |
| L-SUDOERS-01 | Auto-write `/etc/sudoers.d` or `NOPASSWD: ALL` fragment | print-only + install-script handoff; narrow Cmnd; TP-FOLDER-BACKUP-01/02/14 | open watch |
| L-SUDOERS-02 | Local `~/.local/bin` treated as production-secure for sudoers (user rewrites binary/stage → jailbreak) | trust tier **S13**; `--allow-test-local`; global preferred; TP-FOLDER-BACKUP-01/01b | open watch |
| L-SUDOERS-03 | Confuse draft removal with host elev removal (or Type 0 delete under `/etc`) | `remove-project-sudoers` draft-only + admin script uninstall; TP-FOLDER-BACKUP-15 | open watch |
| L-SUDOERS-04 | Shared `/etc/sudoers.d/{{APP_NAME}}` basename overwrites another user’s fragment on multi-user host | Per-user draft + installed `{{APP_NAME}}-<user>`; multi-draft list/choose; TP-FOLDER-BACKUP-14/15/15b | open watch |
| L-SUDOERS-04 | Generate fragment as wrong user (`id -un` mismatch with backup operator) | Generate as elevating login; User lines = invoking user; review fragment before install | open watch |
| L-OVERWRITE-01 | Same-day archive overwrite without next-N | naming allocator; TP-FOLDER-BACKUP-08 when root | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage / stage roots not matching sudoers wildcards | util_resolve_storage; per-user stage; TP-CLI-12 · TP-FOLDER-BACKUP-02 | open watch |

**Bootstrap parent lessons (selfmanaged) still relevant for kept surfaces:** output SSOT, no basename gate on entry, storage isolation.
