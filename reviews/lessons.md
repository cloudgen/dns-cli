# Lessons — folder-backup

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-DEPOSIT-01 | Unprivileged write to `/var/backup` or silent deposit success without sudo | fail-closed + print-sudoers; TP-FOLDER-BACKUP-05 | open watch |
| L-SUDOERS-01 | Auto-write `/etc/sudoers.d` or `NOPASSWD: ALL` fragment | print-only + narrow Cmnd; TP-FOLDER-BACKUP-01/02 | open watch |
| L-OVERWRITE-01 | Same-day archive overwrite without next-N | naming allocator; TP-FOLDER-BACKUP-08 when root | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage / dead resolver | util_resolve_storage; TP-CLI-12 | open watch |

**Bootstrap parent lessons (selfmanaged) still relevant for kept surfaces:** output SSOT, no basename gate on entry, storage isolation.
