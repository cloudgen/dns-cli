# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.5.0 (current) | Yes |
| 1.4.x | Best-effort |
| 1.3.x | Best-effort |
| 1.2.x | Best-effort |
| Older releases | Best-effort only |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wongcf22@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).  
- Prefer email (or private GitHub security advisories when enabled) for vulnerability details, reproduction steps, and impact.  
- Do not include exploit weaponization guides in public channels.

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **[CIAO-Lite](https://github.com/cloudgen/ciao-lite)** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Fail closed without working allowlisted sudo for deposit; restore dest **whitelist** (W-ETC-USER `/etc/{{username}}`; never `/etc/passwd`); validate sources and archives. |
| **I** | **Intentional** | Type 0 archive create vs Type 1 deposit/restore-stage copy are separate; `print-sudoers` never writes `/etc`. |
| **A** | **Anti-fragile** | Staging + traps; clear admin install path; hard-disk default restore dest avoids accidental RAM-only recovery assumptions. |
| **O** | **Over-protect** | Narrow Cmnds only (no `NOPASSWD: ALL`); Protection Zones; count/size verification before success. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Scope notes

- Elevation is limited to allowlisted deposit and restore-stage operations under product law.  
- Operators must admin-install sudoers fragments after review (`visudo -c`, mode `0440`).  
- **Install trust tiers for elevation:**
  - **Production:** global managed binary (`/usr/local/bin/folder-backup`, typically root-owned). Prefer `sudo folder-backup install` before durable sudoers.  
  - **Test mode only:** local `~/.local/bin/folder-backup` is **user-rewritable**. A local user can change the CLI and stage content after a review; do **not** treat local-only sudoers as production-secure.  
  - `print-sudoers` refuses non-production tiers unless `--allow-test-local` / `ALLOW_TEST_LOCAL_SUDOERS=1`, and embeds **TEST MODE / uninstall soon** warnings.  
  - **`print-sudoers-install-script`** writes a **Type 0 admin handoff script** under `/dev/shm` (or temp) that a sudo-capable account runs for `install` / `uninstall` / `replace` of the **project-sudoers-file** — the CLI never writes `/etc` itself.  
  - **Per-user host paths:** draft `~/.config/folder-backup/sudoers.fragment-<user>` installs to `/etc/sudoers.d/folder-backup-<user>` so multi-user admin installs do not overwrite each other.  
  - Uninstall of the binary does **not** remove `/etc/sudoers.d/folder-backup-<user>` — use `sudo sh <admin-script> uninstall` (or admin `rm`) when leaving test elevation.  
  - **`remove-project-sudoers`** deletes drafts only; when multiple drafts exist it lists them for interactive choice (non-interactive needs an explicit path).  
- Residual: even with OS-tool-only Cmnds, **stage trees are user-writable**; deposit grants write of staged archives into `/var/backup/folder-backup/` only (not a root shell).  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md), `docs/requirements/requirement-three-layer-privilege-model.md`, `reviews/reports/2026-08-09-sudoers-security-folder-backup.md`.
