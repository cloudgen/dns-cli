# What to review — folder-backup

**Living checklist** (review plan). Product: **folder-backup** local self-managed CLI + domain backup/restore + narrow sudo deposit.  
**Class:** software-development · domain SSOT present · **local-only** install channel (online package intentionally absent).  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-09  
**Ship unit VERSION:** 1.4.1  
**Suite baseline:** PASS=131 (see `reviews/test-plan.md`)

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + domain + three-layer |
| P2 | Confirm ship unit `src/folder-backup` | `APP_NAME` / `VERSION` hard-assign (**1.4.1+**) |
| P3 | Load `reviews/lessons.md` and re-check every open L-* | Mandatory (esp. **L-SUDOERS-01/02**) |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Privilege law version | `requirement-three-layer-privilege-model` **≥1.2.1** (S13 + §2.3.3a/b) |
| P7 | Host elev posture (if reviewing runtime) | Global vs local binary; trust tier; `/etc/sudoers.d/` status |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | A=selfmanaged → B trim online |
| Project folder | `requirement-project-folder.md` | `src/`, bins, `/var/backup` |
| **Privilege / sudoers** | `requirement-three-layer-privilege-model.md` | Type 0/1; **trust tiers S13**; print-sudoers; **install-script**; **remove-project-sudoers**; no ALL ALL |
| CLI interface | `requirement-shell-cli-interface.md` | Commands, flags, dispatch |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; global preferred for elev |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | `fb_*` domain prefix |
| Idempotency | `requirement-shell-idempotency.md` | Re-install; next-N archives |
| Interactive modes | `requirement-shell-interactive-vs-noninteractive.md` | Uninstall / remove-project-sudoers confirm |
| CLI storage | `requirement-shell-cli-storage.md` | Per-user staging isolation |
| Domain | `requirement-domain-folder-backup.md` | Four pillars; sudoers verbs |
| Ops backup | `requirement-folder-archive-backup.md` | backup/restore/verify |

**Harness (not product source law — load when elev/agent create in scope):**

| Surface | Path | Review focus |
|---------|------|--------------|
| Skill create sudoers | `docs/skills/skill-create-sudoers-file.md` | **S11–S12** elev tables; **S13** trust |
| Checklist | `docs/templates/checklists/checklist-create-sudoers-security.md` | Pre-emit gate |
| Mold | `docs/templates/requirements/template-three-layer-privilege-model.md` | §2.3.1a, §2.3.3a/b |
| Terms | `project-sudoers-file` · `sudoers-fragment` | Draft vs installed vs admin script |

**Intentionally absent (do not “restore” without owner order):** online-install, remote self-management, companion channel checksum.

---

## High-risk paths (ship unit)

| Path / symbol | Risk | Lesson / TP |
|--------------|------|-------------|
| Empty argv branch | Type O install leak from parent | L-TYPE-N-01 · TP-CLI-07 |
| Online command names | Half-live channel | L-ONLINE-01 · TP-CLI-04/10 |
| `inst_local_uninstall` | Fake success without force | L-UNIN-01 · TP-LC-05 |
| `inst_local_install` | Mode `0711` / `chmod +x` only (non-owners cannot run shell unit) | L-INST-MODE-01 · TP-LC-09/10 |
| `fb_deposit_archive` | Silent success without sudo | L-DEPOSIT-01 · TP-FOLDER-BACKUP-05 |
| `fb_print_sudoers` | Broad sudoers; Type 0 `/etc` write; local=production | L-SUDOERS-01/02 · TP-01/01b/02 |
| `fb_print_sudoers_install_script` | Silent `/etc` install; wrong user in fragment; shared installed basename overwrites other users | TP-FOLDER-BACKUP-14 · user=`id -un` · L-SUDOERS-04 |
| `fb_remove_project_sudoers` | Deletes `/etc` as Type 0; silent without force; multi-draft wrong pick | TP-FOLDER-BACKUP-15 · **15b** |
| `fb_next_archive_name` | Overwrite archives | L-OVERWRITE-01 · TP-08 |
| `util_resolve_storage` | Isolation break / stage mismatch vs sudoers | L-STOR-01 · TP-CLI-12 · TP-02 |
| Config `HOME` under `set -u` | nounset crash | L-SETU-01 · TP-CLI-11 |

---

## Type 1 elevation + project-sudoers-file — review plan gate

Product claims **narrow Type 1** (allowlisted OS tools only), **not** full host package Type 1.  
**User lines** in fragments are generated from **`id -un`** (invoking login); stage roots are per-user.

| Gate | Requirement | TP |
|------|-------------|-----|
| Negative fail-closed deposit | Without working allowlisted sudo → non-zero + hint | TP-FOLDER-BACKUP-05 |
| No Type 0 `/etc` auto-write | print-sudoers / install-script only emit draft+script | TP-01, 14 |
| Fragment narrowness | No `NOPASSWD: ALL` | TP-02 |
| Trust tier test_local | Refuse emit without `--allow-test-local`; TEST MODE banner | TP-01, **01b** |
| Admin install-script | Draft refresh + `/dev/shm` script; install needs root | TP-**14** |
| Remove draft only | Confirm/`--force`; refuse `/etc`; warn host fragment; multi-draft list/choose | TP-**15** · **15b** |
| Per-user host path | Installed `/etc/sudoers.d/{{APP_NAME}}-<user>` (no multi-user overwrite) | TP-**14** · L-SUDOERS-04 |
| Positive full deposit | Host sudoers or root | TP-07/08 |
| Installed fragment ≠ draft only | Host may still elevate after draft removed | Honesty in remove-project-sudoers |
| Full interactive password-sudo package ladder | **n/a** | deposit uses `sudo -n` after admin fragment |
| TTY package Type 1 traps | **n/a** | no package elev claimed |

**CL-SHELL-TTY-PRIVILEGE-TRAPS:** N/A for package elevation.  
**CL-CREATE-SUDOERS-SECURITY:** Required for agent-authored fragment create (**S11–S13**).

### Trust tier (S13) — must re-check

| Tier | Binary | Emit print-sudoers | Production claim |
|------|--------|--------------------|------------------|
| production | Global managed present | Without allow flag | Allowed after review |
| test_local | Local only | Needs `--allow-test-local` + warnings | **Forbidden** |
| unmanaged | Neither | Needs allow + warnings | **Forbidden** |

---

## Tests surface

| Check | Path |
|-------|------|
| Suite entry | `tests/run.sh` |
| CLI | `tests/test_cli.sh` |
| Local lifecycle | `tests/test_local_lifecycle.sh` |
| Domain + privilege | `tests/test_domain_folder_backup.sh` |
| TP map | `reviews/test-plan.md` |
| REQ ↔ TP matrix | `reviews/requirement-test-matrix.md` |

---

## Product user docs

| Check | Path |
|-------|------|
| README install + sudoers handoff honesty | `README.md` |
| SECURITY trust tiers + install-script | `SECURITY.md` |
| CHANGELOG current VERSION | `CHANGELOG.md` |

---

## Explicit non-goals for default review

- Online install / curl\|sh channel  
- Companion `.sha256` channel integrity  
- Full root package Type 1 elevation suite  
- Cloud upload domain  
- Auto-writing `/etc/sudoers.d` from Type 0 or agents  
