# Sudoers security review — folder-backup

**Date:** 2026-08-09  
**Target user:** grok-agent (source: **current user**)  
**Procedure:** SK-CREATE-SUDOERS-FILE v1.1.0 · CL-CREATE-SUDOERS-SECURITY (S11)  
**Trust tier:** **test_local** (global managed binary not present on this host at review time)  
**Verdict:** **Pass (test only)** — **not** production-secure  

**Path note (product 1.4.4+):** default draft is `sudoers.fragment-<user>` and installed host path is `/etc/sudoers.d/folder-backup-<user>` (multi-user safe). Examples below may still show pre-1.4.4 un-suffixed names as historical apply paths.

## Supersedes

`reviews/reports/2026-08-03-sudoers-security-folder-backup.md` claimed **Pass** with **local-only** managed binary. That verdict is **insufficient under current law**: local install is user-rewritable and must not be treated as production-secure for durable `/etc/sudoers.d/` elevation.

## Managed binary

| Class | Path | Exists | Mode | Owner | User-writable? | Symlink |
|-------|------|--------|------|-------|----------------|---------|
| global | /usr/local/bin/folder-backup | check at apply time | — | — | — | — |
| local | `${HOME}/.local/bin/folder-backup` (host-specific) | typical yes for Type 0 | user-owned | target user | **yes** | no |

**Gate:** Managed local install may exist for Type 0 use. **Production Pass requires global** (`/usr/local/bin/folder-backup`) not writable by the target user.

## Allowlisted commands (product print-sudoers shape)

Elevated surface is **OS-tool-only** deposit into `/var/backup/folder-backup/` (product does **not** elevate the managed CLI binary).

| Cmnd absolute path | Operands / dest | Rationale |
|--------------------|-----------------|-----------|
| /usr/bin/mkdir, /bin/mkdir | -p /var/backup/folder-backup | Create deposit dir only |
| /usr/bin/cp, /bin/cp | per-user stage → deposit | Deposit staged archive |
| /usr/bin/install | -m 0640 stage → deposit | Deposit with mode |
| /usr/bin/chmod, /bin/chmod | 0640 deposit/* | Mode on deposited archives |
| /usr/bin/tar, /bin/tar | -tzf deposit/* | List-only verify |
| reverse cp | deposit → per-user stage | Restore stage fetch |

**Stage sources (per-user only):**  
`/dev/shm/folder-backup-<user>/*`, `/tmp/folder-backup-<user>/*`, `${HOME}/.cache/folder-backup-<user>/*`  
(no broad `folder-backup-*` cross-user wildcards)

## Checklist CL-CREATE-SUDOERS-SECURITY

| ID | Result | Notes |
|----|--------|-------|
| S1 Target user | **Pass** | current user |
| S2 Managed binary | **Pass** | local acceptable for test emit; global preferred |
| S3 Absolute Cmnd paths | **Pass** | OS tools absolute |
| S4 No broad rights | **Pass** | No ALL / no shell Cmnd |
| S5 Destination bound | **Pass** | Only /var/backup/folder-backup |
| S6 Binary integrity | **Pass** | CLI binary not elevated; local still user-rewritable |
| S7 No secrets | **Pass** | None |
| S8 Draft path safe | **Pass** | user config draft only |
| S9 Product law | **Pass** | three-layer v1.2.0 + domain |
| S10 Residual risk | **Pass** | Documented below |
| S11 Trust tier | **Pass (test only)** | local-only → TEST MODE; uninstall plan required |

## Residual risk

1. **Local binary rewrite:** User can change `~/.local/bin/folder-backup` after review; product does not elevate that path, but user controls **stage content** deposited via allowlisted `cp`/`install`.  
2. **Stage content trust:** Per-user stages are user-writable; compromised user can deposit arbitrary tar.gz content into `/var/backup/folder-backup/` (not full root shell).  
3. **NOPASSWD** for non-interactive `sudo -n` deposit.  
4. **Existing host fragment** (if applied under old local-only Pass) should be treated as **test / to-uninstall** until global install + re-emit + re-review.

## Uninstall plan (required for test_local)

```bash
# Admin — remove test elevation when leaving test mode:
sudo rm -f /etc/sudoers.d/folder-backup-grok-agent
# legacy shared name if still present:
# sudo rm -f /etc/sudoers.d/folder-backup
sudo visudo -c

# Production path:
sudo sh src/folder-backup install   # → /usr/local/bin/folder-backup
folder-backup print-sudoers ~/.config/folder-backup/sudoers.fragment-grok-agent
# re-review with trust_tier=production, then:
sudo visudo -c -f ~/.config/folder-backup/sudoers.fragment-grok-agent
sudo install -m 0440 ~/.config/folder-backup/sudoers.fragment-grok-agent /etc/sudoers.d/folder-backup-grok-agent
```

## Decision

- **Pass (test only)** → may emit draft with **TEST MODE ONLY** banner when `--allow-test-local` / `ALLOW_TEST_LOCAL_SUDOERS=1`  
- **Not** production Pass until global managed binary is present and review re-run  
- Agent **must not** install to `/etc/sudoers.d/`  
- WS- record status: **test / to-uninstall** if applied on host under local-only conditions  

## Product CLI gates (1.3.0+)

- `print-sudoers` refuses non-production tier without `--allow-test-local`  
- Fragment headers carry TEST MODE / uninstall-soon when test_local  
- Stage wildcards are per-user  
- `install --global` / root install for production path  
- `uninstall` warns that `/etc/sudoers.d/folder-backup-<user>` is not removed  
