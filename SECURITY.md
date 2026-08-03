# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.2.0 (current) | Yes |
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
| **C** | **Caution** | Fail closed without working allowlisted sudo for deposit; refuse dangerous restore destinations; validate sources and archives. |
| **I** | **Intentional** | Type 0 archive create vs Type 1 deposit/restore-stage copy are separate; `print-sudoers` never writes `/etc`. |
| **A** | **Anti-fragile** | Staging + traps; clear admin install path; hard-disk default restore dest avoids accidental RAM-only recovery assumptions. |
| **O** | **Over-protect** | Narrow Cmnds only (no `NOPASSWD: ALL`); Protection Zones; count/size verification before success. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Scope notes

- Elevation is limited to allowlisted deposit and restore-stage operations under product law.  
- Operators must admin-install sudoers fragments after review (`visudo -c`, mode `0440`).  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).
