# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.11.0 (current) | Yes |
| 1.10.0 | Yes |
| 1.9.x | Yes |
| 1.8.x | Yes |
| 1.6.x–1.7.x | Limited |
| 1.5.0 and older | Limited |

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
| **C** | **Caution** | Unknown commands fail closed; install fails loud if the target is not writable. |
| **I** | **Intentional** | Type 0 lifecycle + Type 1 `setup`/`remove-lpu`; Type 0 JSON sudoer `type-2-switch` generate/submit; `setup` auto-queue of `login-hook-elev` (no `/etc/sudoers.d` write). |
| **A** | **Anti-fragile** | Isolated scratch (`APP_NAME` + `USERNAME`); atomic install place with mode **0755**. |
| **O** | **Over-protect** | Protection Zones on `out_*` and install; no online channel UX. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Secrets (Cloudflare API token)

- Store the API token only in a **0600** vault token file (`--token-file`). **Never** `--token` on argv.  
- HTTPS uses `curl --config` so the Bearer line is not on `ps`.  
- Inbound DNS request JSON **MUST NOT** include a `token` key.  
- Do **not** commit tokens, Bearer lines, vault token files, or live dashboard ids into `README.md`, `CHANGELOG.md`, this file, `reviews/**`, or `docs/requirements/**`. Reviews treat a pasted `cfut_…` value as a Block (`skill-file-leaks-check` C5).  
- Report token exposure privately (email / GitHub security advisory), then **revoke** the token in the Cloudflare dashboard.

## Scope notes

- This product does **not** write `/etc/sudoers.d`. `print-sudoers` / `generate-sudoer-request` stay user-readable; `submit-sudoer-request` queues JSON to sibling inbound only.  
- This product does **not** write under `/var/backup` or restore archives.  
- Uninstall removes only the managed binary.  
- Local `~/.local/bin` install is user-rewritable; prefer global install on multi-user hosts when a shared CLI is desired.  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).
