# Security review — folder-backup (current state)

**Date:** 2026-08-09  
**Scope:** Product elevation model, ship unit 1.3.0, harness sudoers gates, **this host** runtime posture  
**Procedure:** CL-SECURITY-REVIEW · CL-CREATE-SUDOERS-SECURITY (S11) · policy-least-privilege · L-SUDOERS-*  
**Product version SSOT (repo):** 1.3.0  
**Companion sudoers review:** `reviews/reports/2026-08-09-sudoers-security-folder-backup.md`  

## Verdict

| Layer | Verdict | Notes |
|-------|---------|-------|
| **Design / product law (repo)** | **Pass with residual risk** | Trust tiers, fail-closed deposit, narrow OS-tool Cmnds, no ALL |
| **Harness (skills/checklist/molds)** | **Pass** | S11 closes local=production false confidence |
| **Ship unit (src 1.3.0)** | **Pass with residual risk** | Gates implemented; suite green (111) |
| **This host (runtime)** | **Revise (ops)** | Still **test_local**; stale local binary; installed sudoers incomplete vs draft; production path not applied |

**Overall (honest):** Architecture is in good shape after 1.3.0. **Host is not production-secure.** Residual elevation risk is real and expected under Type 1 deposit-from-user-stage; ops debt is the main gap.

---

## Scope (CL-SECURITY-REVIEW)

| Field | Value |
|-------|--------|
| Paths / features | Install/uninstall, `print-sudoers`, `backup` deposit, `restore` stage fetch, `/etc/sudoers.d/folder-backup` |
| REQ keys | `requirement-three-layer-privilege-model` 1.2.0 · `requirement-folder-archive-backup` · `requirement-shell-local-self-management` 1.1.0 |
| Data classes | Internal project trees; durable archives under `/var/backup/folder-backup/` (root-owned 0640) |
| Secrets | None expected in fragments/reviews; none observed in ship unit SSOT |

---

## Host facts (probe 2026-08-09)

| Check | Result |
|-------|--------|
| Global `/usr/local/bin/folder-backup` | **Absent** |
| Local managed binary | Present: `~/.local/bin/folder-backup` · **VERSION 1.2.0 (stale)** · mode `711` · owner `grok-agent` (user-rewritable) |
| Repo ship unit | `src/folder-backup` · **VERSION 1.3.0** |
| Trust tier (`about` on src) | **`test_local`** |
| `/etc/sudoers.d/folder-backup` | Present · mode `0440` · owner `root:root` |
| Live allowlist (`sudo -n -l`) | mkdir deposit · cp/install stage→deposit · chmod deposit/* **only** |
| Live allowlist: `tar -tzf` | **Not listed** |
| Live allowlist: deposit→stage reverse `cp` | **Not listed** (probe reverse-cp → password required / fail) |
| User draft fragment | `~/.config/folder-backup/sudoers.fragment` (older shape; includes `folder-backup-*` wildcards + tar + restore) |
| Deposit dir | `/var/backup/folder-backup` · `root:root` `0755`; archives `0640` root:root |
| Stage dir example | `/dev/shm/folder-backup-grok-agent` · `755` user-owned |

---

## What is working (controls that hold)

### Elevation design

1. **Type 0 vs Type 1 split** — tar create is unprivileged; deposit is allowlisted `sudo -n` only.  
2. **No elevation of the CLI binary** — Cmnds are OS tools (`mkdir`/`cp`/`install`/`chmod`/`tar`), not `NOPASSWD: …/folder-backup`. Reduces “rewrite the binary → root runs it” for **this** fragment shape.  
3. **Destination bound** — writable elevated target is `/var/backup/folder-backup` only (not host-wide).  
4. **Fail-closed deposit** — missing/unauthorized sudo dies; does not claim success (`L-DEPOSIT-01`).  
5. **No secrets** in fragments, reviews, or ship unit identity block.  
6. **`print-sudoers` never writes `/etc`** (`L-SUDOERS-01`).  
7. **Restore dest denylist** — refuses `/`, `/etc`, `/usr`, deposit tree, etc.  
8. **Per-user storage isolation** — `util_resolve_storage` uses `${APP_NAME}-${USERNAME}` tiers.  
9. **1.3.0 trust gates** — non-production `print-sudoers` requires `--allow-test-local` / env; TEST MODE banner; S11 in harness.  
10. **Suite** — 111 pass including refuse-without-allow and per-user stage strings in new fragments.

### Harness

- Local-only install is no longer a silent “production Pass” path.  
- Residual risks (binary rewrite, stage content) are named in skill, checklist, SECURITY.md, WS record (**test / to-uninstall**).

---

## Findings

### Finding 1: Host remains test_local with durable sudoers installed
- **Severity**: **high** (ops / residual privilege)  
- **Category**: Configuration and privileges · **E-PRIV-04** class residual (narrow but durable elevation under weak install trust)  
- **Location**: Host `/etc/sudoers.d/folder-backup` + `~/.local/bin/folder-backup`  
- **Description**: Global managed binary is absent. Local binary is user-owned and **stale (1.2.0)**. Sudoers fragment is still installed and grants passwordless root **copy/install into durable storage**. Under product law this is **test mode**, not production.  
- **Impact**: Compromised or malicious local user (or anything that can write stage trees) can deposit arbitrary archives as root into `/var/backup/folder-backup/`. Local binary age also means PATH users miss 1.3.0 gates/warnings.  
- **Reproduction**: `about` → trust_tier=test_local; `ls /usr/local/bin/folder-backup` missing; `sudo -n -l` shows NOPASSWD deposit Cmnds.  
- **Remediation**:  
  1. `sudo sh src/folder-backup install` (global 1.3.0), **or** remove elevation: `sudo rm /etc/sudoers.d/folder-backup`.  
  2. Refresh local with `sh src/folder-backup install --force` if local remains for Type 0.  
  3. Re-emit fragment from 1.3.0, re-review as production, reinstall fragment.  
- **Status**: open  

### Finding 2: Installed sudoers drift vs product draft / 1.3.0 shape
- **Severity**: **medium**  
- **Category**: Authorization surface integrity  
- **Location**: Live `sudo -n -l` vs `~/.config/.../sudoers.fragment` vs `src` `print-sudoers`  
- **Description**: Live allowlist is **deposit-only** (mkdir/cp/install/chmod). User draft includes **tar -tzf** and **restore reverse-cp** and older **`folder-backup-*`** wildcards. Live probe: reverse `cp` deposit→stage **fails** (password required).  
- **Impact**:  
  - Restore of root-owned 0640 archives may **fail closed** for non-root (feature gap / incomplete elev).  
  - Post-deposit **dest_tar_list** verify falls back to stage counts (weaker than re-list).  
  - Operators may think draft == installed.  
- **Reproduction**: `sudo -n -l`; reverse-cp probe exit ≠ 0; draft file still has restore lines.  
- **Remediation**: Admin single source: re-emit from current ship unit, `visudo -c`, reinstall **one** fragment; document whether restore elev is intentional.  
- **Status**: open  

### Finding 3: Stage content is user-controlled elevated write (by design residual)
- **Severity**: **medium** (accepted residual if understood; **high** if operators treat deposit as “trusted root store of clean content”)  
- **Category**: Input / least privilege residual  
- **Location**: `fb_deposit_archive` + sudoers stage→deposit Cmnds  
- **Description**: Product intentionally elevates **copy of user-writable stage files** into root-owned durable storage. Global binary does **not** remove this residual. Compromised account can plant malicious or oversized payloads in stage and deposit them.  
- **Impact**: Integrity of `/var/backup/folder-backup/` as “admin-trusted backup corpus” is only as strong as the **invoking user’s integrity**, not as strong as root. Not a full root shell if Cmnds stay narrow.  
- **Remediation**: Document operational trust model; optional later: checksum policy, size caps, virus scan hook, or dedicated helper that validates archive before deposit. Do not claim “root-trusted content.”  
- **Status**: open (accepted residual under current law)  

### Finding 4: Stale local binary (1.2.0) vs repo (1.3.0)
- **Severity**: **medium** (ops)  
- **Category**: Supply chain / install integrity  
- **Location**: `~/.local/bin/folder-backup`  
- **Description**: On-PATH binary lacks trust-tier refuse, TEST MODE banners, tighter stage wildcards, `--global` install path messaging.  
- **Impact**: Users/agents running `folder-backup` from PATH get weaker security UX than repo law claims.  
- **Remediation**: `sh src/folder-backup install --force` (and/or global install).  
- **Status**: open  

### Finding 5: User draft still uses broad `folder-backup-*` wildcards
- **Severity**: **low–medium**  
- **Category**: Fragment hygiene  
- **Location**: `~/.config/folder-backup/sudoers.fragment`  
- **Description**: Draft still allows `…/folder-backup-*/*` which is wider than per-user `folder-backup-<login>/`. Live installed fragment appears tighter (per-user). New 1.3.0 emit uses per-user.  
- **Impact**: If draft were reinstalled without review, elevation surface widens across similarly named stage dirs.  
- **Remediation**: Regenerate draft with 1.3.0 + `--allow-test-local` (or production after global); discard old draft.  
- **Status**: open  

### Finding 6: Stage directory mode `755` on shared `/dev/shm`
- **Severity**: **low**  
- **Category**: Data exposure  
- **Location**: `/dev/shm/folder-backup-grok-agent`  
- **Description**: Directory world-readable; staged archives default `0600` after create (good), but intermediate files or mis-chmod could leak to other local users.  
- **Impact**: Local multi-user read of staged content if modes slip.  
- **Remediation**: Prefer `mkdir -m 700` for stage roots; audit after create.  
- **Status**: open  

### Finding 7: `about` sudo probe honesty residual
- **Severity**: **informational**  
- **Category**: Diagnostics honesty  
- **Location**: `app_about` (`sudo -n true` style probe)  
- **Description**: Reports `sudo_needs_auth_or_denied` even when narrow deposit Cmnds work (product law already warns against this class of false negative).  
- **Impact**: Operator confusion; not a privilege expansion.  
- **Remediation**: Probe allowlisted `mkdir -p` deposit dir instead of `true`.  
- **Status**: open  

### Finding 8: Sudoers `install … stage/* dest/*` wildcard pattern
- **Severity**: **low** (known sudoers class)  
- **Category**: Allowlist precision  
- **Location**: fragment install lines  
- **Description**: Shell-style wildcards in sudoers are not shell glob semantics; admin must re-validate with `visudo -c` and host sudo version behavior.  
- **Impact**: Mis-understanding can over/under-grant.  
- **Remediation**: Prefer single-file exact paths if product can pass fixed names only; keep admin review.  
- **Status**: open  

---

## Checklist roll-up

### Authentication / authorization
- [x] No network auth surface (local CLI)  
- [x] Type 1 only via named sudoers user + absolute Cmnds  
- [ ] Host fragment fully aligned with intended restore/verify surface (**Finding 2**)  

### Secrets / data
- [x] No hardcoded secrets  
- [x] Deposit archives 0640 root-owned  
- [ ] Stage dir modes not fully least (`755`) (**Finding 6**)  

### Input / injection
- [x] Restore dest denylist  
- [x] Fail closed on bad source / deposit  
- [x] Stage content treated as untrusted elevated input (**Finding 3** residual)  

### Configuration / privileges
- [x] CL-CREATE-SUDOERS-SECURITY S11 in harness  
- [x] print-sudoers test gate in 1.3.0  
- [ ] Host production trust tier (**Finding 1**)  
- [ ] Local binary current (**Finding 4**)  
- [x] CL-LEAST-PRIVILEGE: design OK; host residual elevation accepted as test  
- [x] CL-LLM-ESCAPE: no broad ALL; no unapproved egress by product  
- [x] CL-SHELL-TTY-PRIVILEGE-TRAPS: N/A (static fragment, not interactive package ensure)  

### Dependencies / supply chain
- [x] Local-only install channel (no curl|sh)  
- [ ] Installed binary version lag (**Finding 4**)  

---

## Severity summary

| Severity | Count | IDs |
|----------|-------|-----|
| critical | 0 | — |
| high | 1 | F1 host test_local + durable sudoers |
| medium | 3 | F2 drift, F3 stage residual, F4 stale binary |
| low | 2 | F5 draft wildcards, F6 stage perms |
| informational | 2 | F7 probe honesty, F8 sudoers wildcard class |

---

## Recommended actions (priority)

1. **Ops now:** Either **global install + re-emit + reinstall fragment** (production path) **or** **remove** `/etc/sudoers.d/folder-backup` if elevation not needed.  
2. **Ops now:** `install --force` local binary to 1.3.0 so PATH matches law.  
3. **Ops:** Align live sudoers with whether restore/tar-verify elev is required; drop orphan draft or regenerate.  
4. **Product backlog (optional):** stage `mkdir -m 700`; smarter `about` sudo probe; archive size caps / content policy if deposit is “compliance store.”  
5. **Do not** claim production-secure until F1 closed and a **Pass** (not Pass test only) sudoers review is filed against global binary.

---

## Mapping to prior lessons

| Lesson | Status after this review |
|--------|---------------------------|
| L-DEPOSIT-01 fail-closed | Holds in code + suite |
| L-SUDOERS-01 no ALL / no auto /etc | Holds |
| L-SUDOERS-02 local ≠ production | **Law fixed; host still open (F1)** |

---

## Decision

| Audience | Decision |
|----------|----------|
| **Ship unit / harness design** | Accept residual F3; continue 1.3.0 trust model |
| **This host** | **Revise** — treat elevation as **test**; remediate F1/F2/F4 before any production claim |
| **Agent create of new fragment** | Follow SK-CREATE-SUDOERS-FILE; no production Pass without global |

**Status of findings:** all open (ops-owned unless product backlog marked).
