# Report: product-gap — dns-cli 1.5.0

**Date:** 2026-08-18  
**Mode:** product-gap / LPU create-path (INC-20260818-001)  
**Status:** open items  
**Ship unit:** `src/dns-cli` `VERSION=1.5.0`  
**Host global:** `/usr/local/bin/dns-cli` **1.4.1**  
**Suite:** last `sh tests/run.sh` **PASS=317 FAIL=0 SKIP=0** (this session)  
**Lessons loaded:** `reviews/lessons.md` (re-checked L-LPU-MISSING-01, L-TRIM-01, L-TOKEN-PUB-01, L-TYPE-N-01)  
**Incident:** `docs/incidents/incident-20260818-001-user-dns-adm-not-found.md`  
**Method:** disk read of law + ship + incident; host probe `id dns-adm`; `sh src/dns-cli --json setup`; help/version; no `useradd` this review

## Summary

The **create-path product gap** named in INC-20260818-001 is **closed on the ship unit** (1.5.0 routes `setup` / `remove-lpu` / `print-sudoers`). It was never a failed `install`: `sudo dns-cli install` only places the binary. **Two product gaps remain** and still fail stay-honest for production dest: unspecified vault I/O still uses the invoking user’s XDG tree (no `lpu_missing`), and there is no Type 2 `sudo -u dns-adm` switch. **Host apply is unrun:** `id dns-adm` is still `no such user`; global binary is still 1.4.1. Verdict: **Revise** — do not claim the LPU model live; do not treat create-path as still Gap.

## LPU / LPA review fold (SK-CREATE-LEAST-PRIVILEGE-SYSTEM-USER §4.4)

| Field | Score | Evidence |
|-------|--------|----------|
| F1 / F2 | Pass | Distro-assigned; collision `lpu_exists`; test stub UID 1701 is CI-only |
| Shell | Pass | `/bin/bash`; locked password (`passwd -l`) on host create |
| F3 home | Pass | Prefer `/etc/dns-adm`; fallback `/home/dns-adm`; `--home` override |
| F4 | Pass | none |
| F5 | Pass | `${home}/vault` `0700`; bare home not listed as affected |
| F6 | Pass (dest file) | `/etc/dns-adm/sudoers` `0440`; Table A only; backup `/etc/sudoer-backup/`; never `/etc/sudoers.d` |
| F7 | Pass | `remove-lpu`; `uninstall` does not `userdel` (TP-LPU-05) |
| Host apply | **Gap** | Ship has `setup`; this host has no account (`id: ‘dns-adm’: no such user`) |
| LPA extras | **Gap** | Approver identity is `dns-adm`; inbound `submit` / `approve` / `interactive` still unknown |
| Verdict | **Gap** | Create path Implemented; dest/switch/inbound/host-run not live |

## Type 1 TTY / elev (CL-SHELL-TTY-PRIVILEGE-TRAPS, scoped)

| Check | Result |
|-------|--------|
| Helpers consume `TTY` SSOT (no `[ -t` inside `lpu_require_elev`) | Pass |
| JSON / non-TTY fail closed, no password hang | Pass (`--json setup` → `lpu_required`) |
| Not `sudo -n` for `setup` | Pass (`exec sudo -p` or fail closed) |
| `SUDO_USER` need not be `dns-adm` | Pass |
| Negative TP | Pass **TP-PRIV-03** |
| Positive interactive password-sudo TP | **Missing** (plan hole, not a ship crash) |

## Operator-readable errors (CL-OPERATOR-READABLE-ERROR, scoped fatals)

Quoted: `setup must run as root. You are leolio (not root). Next: sudo dns-cli setup`

| Slot | Verdict |
|------|---------|
| E1 what happened | Pass |
| E2 meaning / who | Pass (`leolio` not root) |
| E3 next | Pass (`sudo dns-cli setup`) |
| E7 JSON same sentence | Pass (`code":"lpu_required"`) |
| Jargon-only Type 0/1/euid | Pass (not the only text) |

## Issues

### Issue 1 -- Severity: bug
- File: `src/dns-cli:1201`
- Description: Unspecified `cf_vault_dir` still resolves to `$HOME/.config/dns-cli` (or `$XDG_CONFIG_HOME/dns-cli`). Law: default dest is `/etc/dns-adm/vault/`; no specify + no `dns-adm` → `lpu_missing`. After `setup` this still writes the invoking user’s XDG tree unless `--vault-dir` is set. Silent dest is the remaining production identity gap.
- Suggestion: Resolve default to LPU F5; if account absent and no specify, `out_die_code lpu_missing` with next `sudo dns-cli setup` (or `--vault-dir` for QA). Keep specify Type 0.
- Lesson: L-LPU-MISSING-01 · new **L-LPU-DEST-01**
- Test: **TP-AV-07** (todo)
- Status: open

### Issue 2 -- Severity: bug
- File: `src/dns-cli:1201` (no Type 2 re-exec)
- Description: Law P-M4: default-vault ops as non-`dns-adm` must `sudo -u dns-adm` of the **global** binary or fail `lpu_required`. Ship unit never switches. Even after a successful host `setup`, day-to-day default vault as `leolio` would still be wrong.
- Suggestion: After dest resolve, if unspecified and `id -un` ≠ `dns-adm`, re-exec `sudo -u dns-adm` `${GLOBAL_BIN}/dns-cli` … or `lpu_required`. Specify path must not switch.
- Lesson: L-LPU-MISSING-01
- Test: **TP-LPU-03** (todo)
- Status: open

### Issue 3 -- Severity: suggestion
- File: host `/usr/local/bin/dns-cli` (VERSION 1.4.1)
- Description: Workspace ship is 1.5.0 (`setup` routed). Global install is still 1.4.1 (`setup` unknown on that binary). Operator running `sudo dns-cli setup` against PATH hits the old binary and will still see unknown command.
- Suggestion: Document and run `sudo sh src/dns-cli install --force` then `sudo dns-cli setup`. Do not tell the operator only `sudo dns-cli setup` while PATH is 1.4.1.
- Lesson: L-LPU-MISSING-01
- Test: n/a (ops)
- Status: open

### Issue 4 -- Severity: suggestion
- File: `docs/requirements/requirement-three-layer-privilege-model.md:43` · `src/dns-cli` F6 dest
- Description: F6 dest is `/etc/dns-adm/sudoers`. Law forbids writing `/etc/sudoers.d`. After `setup`, `sudo` will **not** load that dest unless an admin `@include`s it. Table A grant (`%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli`) is therefore file-on-disk, not necessarily live elev. Stay-honest: `setup` Implemented ≠ Type 2 switch works.
- Suggestion: Keep dest law. Print a post-setup admin include step (human-only). Do not write `/etc/sudoers.d` to “make it work.”
- Test: n/a (document)
- Status: open

### Issue 5 -- Severity: suggestion
- File: `reviews/what-to-review.md:8`
- Description: Living checklist still says ship **1.4.0**. Create path and help now claim 1.5.0. Stale plan invites “setup still Gap” false inventory.
- Suggestion: Rebind VERSION / last plan date to 1.5.0 (this review).
- Test: n/a
- Status: open (fixed in this review publish)

### Issue 6 -- Severity: nit
- File: `src/dns-cli:3120`
- Description: Interactive `exec sudo` re-invokes only `setup`/`remove-lpu` plus `--force`/`--home`. `--json` and other flags are dropped on the password-sudo retry. JSON path already fail-closes (does not exec), so impact is TTY-only.
- Suggestion: Forward the original argv (or at least `--json` if ever used with TTY).
- Test: optional TP-ELEV positive
- Status: open

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| `sudo install` ≠ `useradd` | Intentional. Not a defect. Honesty line present. |
| Create-path Gap on 1.4.1 | Closed on **1.5.0** (`setup` / `remove-lpu` / `print-sudoers` routed). |
| `print-sudoers` writes dest | Absent (`/etc/dns-adm/sudoers` not created by print). TP-PRIV-01. |
| `useradd` in sudoers fragment | Absent. Table C only. TP-PRIV-04. |
| Trimmed parent verbs | `backup` / `restore` / `print-sudoers-install-script` still unknown. L-TRIM-01 hold. |
| Type N empty argv | Still help. L-TYPE-N-01 hold. |
| Ad-hoc `useradd` this session | Not run. |
| Inbound JSON token field | Still out of scope for this gap; L-TOKEN-PUB-01 hold. |

## Priority remediation order

1. **Issue 1** — default dest + `lpu_missing` (TP-AV-07).  
2. **Issue 2** — Type 2 switch or `lpu_required` (TP-LPU-03).  
3. **Issue 3** — operator: `install --force` then `setup` on this host.  
4. **Issue 4** — stay-honest include step after `setup`.  
5. Inbound `submit` / `approve` / `interactive` (known actor-table Gap; not this incident’s create path).

## Related

| Artifact | Role |
|----------|------|
| INC-20260818-001 | Product-gap narrative |
| `requirement-least-privilege-user` | F1–F7; `setup` Implemented 1.5.0 |
| `requirement-three-layer-privilege-model` | Type map; Type 2 still Gap |
| `requirement-application-local-vault` | Default dest / `lpu_missing` |
| TP-AV-07 · TP-LPU-03 | Remaining proof |

**Verdict:** **Revise**  
**Written by:** Review (single-agent; SK-PRODUCT-REVIEW + LPU review-mode fold)  
**Review status:** Create-path closed; dest/switch/host-run open
