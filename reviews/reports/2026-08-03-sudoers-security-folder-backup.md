# Sudoers security review — folder-backup

**Date:** 2026-08-03  
**Target user:** grok-agent (source: **current user**)  
**Procedure:** SK-CREATE-SUDOERS-FILE · CL-CREATE-SUDOERS-SECURITY  
**Verdict:** **Pass**

## Managed binary

| Class | Path | Exists | Mode | Owner | Symlink |
|-------|------|--------|------|-------|---------|
| global | /usr/local/bin/folder-backup | **no** | — | — | — |
| local | /var/www/grok.dr-sense.com/.local/bin/folder-backup | **yes** | 711 | grok-agent:www-data | no |

**Gate:** At least one managed install present (**local**). Global not required for Pass.

## Allowlisted commands (proposed)

Elevated surface matches product deposit path (Type 1 narrow copy into backup notation dir).  
Product does **not** run the whole CLI as root; deposit uses absolute OS tools + fixed destination.

| Cmnd absolute path | Operands / dest | Rationale |
|--------------------|-----------------|-----------|
| /usr/bin/mkdir | -p /var/backup/folder-backup | Create deposit directory only |
| /bin/mkdir | -p /var/backup/folder-backup | Alternate mkdir path if present |
| /usr/bin/install | -m 0640 &lt;stage&gt; /var/backup/folder-backup/… | Atomic-ish deposit with mode |
| /usr/bin/cp | &lt;stage&gt; /var/backup/folder-backup/ | Fallback deposit |
| /bin/cp | same | Fallback if /bin/cp used |
| /usr/bin/chmod | 0640 /var/backup/folder-backup/* | Mode on deposited archive only |
| /bin/chmod | same | Alternate |

**Stage sources (read-only from invoker-owned trees):**  
`/dev/shm/folder-backup-grok-agent/*`, `/tmp/folder-backup-grok-agent/*`, `/var/www/grok.dr-sense.com/.cache/folder-backup-grok-agent/*`

**Managed binary proof (install gate):** `/var/www/grok.dr-sense.com/.local/bin/folder-backup` executable; version 1.0.0 verified.

## Checklist CL-CREATE-SUDOERS-SECURITY

| ID | Result | Notes |
|----|--------|-------|
| S1 Target user | **Pass** | grok-agent = current user |
| S2 Managed binary | **Pass** | Local install only; global absent |
| S3 Absolute Cmnd paths | **Pass** | /usr/bin and /bin tools absolute |
| S4 No broad rights | **Pass** | No ALL / no shell Cmnd |
| S5 Destination bound | **Pass** | Only /var/backup/folder-backup |
| S6 Binary not world-writable | **Pass** | mode 711 (no o+w) |
| S7 No secrets | **Pass** | None in fragment/review |
| S8 Draft path safe | **Pass** | /var/www/grok.dr-sense.com/.config/folder-backup/sudoers.fragment — not /etc |
| S9 Product law | **Pass** | requirement-domain-folder-backup + three-layer privilege |
| S10 Residual risk | **Pass** | Documented below |

## Residual risk

1. **Sudoers wildcards** for stage paths are host-layout sensitive; admin must run `visudo -c` on this host.  
2. **NOPASSWD** used so non-interactive `sudo -n` deposit works after admin install (matches product `fb_deposit_archive`). Residual: compromised user account can write archives only under `/var/backup/folder-backup/` via allowlisted cp/install — not full root shell.  
3. **Others+x on binary** (711): not world-writable; acceptable for this review.  
4. Full deposit success not proven in this session (admin install pending).

## Decision

- **Pass** → may emit draft at `/var/www/grok.dr-sense.com/.config/folder-backup/sudoers.fragment`  
- Agent **must not** install to `/etc/sudoers.d/`  
- Operator will use **admin account** for install

## Admin install steps (for human)

```bash
# As admin (example):
sudo visudo -c -f /var/www/grok.dr-sense.com/.config/folder-backup/sudoers.fragment
sudo install -m 0440 /var/www/grok.dr-sense.com/.config/folder-backup/sudoers.fragment /etc/sudoers.d/folder-backup
sudo visudo -c -f /etc/sudoers.d/folder-backup
# Optional: ensure deposit dir exists
sudo mkdir -p /var/backup/folder-backup
sudo chown root:root /var/backup/folder-backup
sudo chmod 0755 /var/backup/folder-backup
```

## After admin install (as grok-agent)

```bash
/var/www/grok.dr-sense.com/.local/bin/folder-backup backup /path/to/folder
```
