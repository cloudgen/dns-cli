# What to review — folder-backup

**Living checklist** (review plan). Product: **folder-backup** local self-managed CLI + domain backup.  
**Class:** software-development · domain SSOT present · **local-only** install (online package intentionally absent).  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-03

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + domain |
| P2 | Confirm ship unit `src/folder-backup` | `APP_NAME` / `VERSION` hard-assign |
| P3 | Load `reviews/lessons.md` and re-check every open L-* | Mandatory |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install mode still **local-only** | No SCRIPT_URL product UX |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | A=selfmanaged → B trim online |
| Project folder | `requirement-project-folder.md` | `src/`, bins, `/var/backup` |
| Privilege / sudoers | `requirement-three-layer-privilege-model.md` | Type 0 + narrow Type 1 deposit; no ALL ALL |
| CLI interface | `requirement-shell-cli-interface.md` | Commands, flags, dispatch |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install / uninstall / where-is-me |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | `fb_*` domain prefix |
| Idempotency | `requirement-shell-idempotency.md` | Re-install; next-N archives |
| Interactive modes | `requirement-shell-interactive-vs-noninteractive.md` | Uninstall confirm |
| CLI storage | `requirement-shell-cli-storage.md` | Staging isolation |
| Domain | `requirement-domain-folder-backup.md` | Four pillars |

**Intentionally absent (do not “restore” without owner order):** online-install, remote self-management, companion channel checksum.

---

## High-risk paths (ship unit)

| Path / symbol | Risk | Lesson |
|--------------|------|--------|
| Empty argv branch | Type O install leak from parent | L-TYPE-N-01 |
| Online command names | Half-live channel | L-ONLINE-01 |
| `inst_local_uninstall` | Fake success without force | L-UNIN-01 |
| `fb_deposit_archive` | Silent success without sudo | L-DEPOSIT-01 |
| `fb_print_sudoers` | Broad sudoers / /etc write | L-SUDOERS-01 |
| `fb_next_archive_name` | Overwrite archives | L-OVERWRITE-01 |
| `util_resolve_storage` | Isolation break | L-STOR-01 |
| Config `HOME` under `set -u` | nounset crash | L-SETU-01 |

---

## Type 1 elevation (narrow deposit) — review plan gate

Product claims **narrow Type 1** (allowlisted sudo copy only), **not** full host package Type 1.

| Gate | Requirement |
|------|-------------|
| Negative fail-closed | Deposit without sudoers → non-zero + hint (`TP-FOLDER-BACKUP-05`) |
| No `/etc` auto-write | `print-sudoers` only (`TP-FOLDER-BACKUP-01`) |
| Fragment narrowness | No `NOPASSWD: ALL` (`TP-FOLDER-BACKUP-02`) |
| Positive full deposit | **SKIP in non-root CI** (`TP-FOLDER-BACKUP-07/08`); admin host dry-run |
| Full interactive password-sudo ladder | **n/a** for package Type 1; deposit uses `sudo -n` after admin fragment |
| TTY subshell false fail-closed package class | **n/a** — no package Type 1 claimed |

**CL-SHELL-TTY-PRIVILEGE-TRAPS:** N/A for package elevation; deposit path covered by domain TP rows.

---

## Tests surface

| Check | Path |
|-------|------|
| Suite entry | `tests/run.sh` |
| CLI | `tests/test_cli.sh` |
| Local lifecycle | `tests/test_local_lifecycle.sh` |
| Domain | `tests/test_domain_folder_backup.sh` |
| TP map | `reviews/test-plan.md` |

---

## Product user docs (when present)

| Check | Path |
|-------|------|
| README install honesty (local, not curl\|sh) | `README.md` (may still be absent) |
| SECURITY reporting | `SECURITY.md` (may still be absent) |

---

## Explicit non-goals for default review

- Online install / curl\|sh channel  
- Companion `.sha256` channel integrity  
- Full root package Type 1 elevation suite  
- Restore / cloud upload domain  
