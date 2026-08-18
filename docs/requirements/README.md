# Requirements

Authoritative specialized product law for **dns-cli** lives here.

**Current state (2026-08-17):** Specialized **software-development** product. **B = `dns-cli` (hop 1)** from **A = `cli-template` (hop 0)**. Registry is populated — see `index.md`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` (law) | `dns-cli` |
| Live Config | `APP_NAME="dns-cli"` in `src/dns-cli` — Implemented |
| Version SSOT | `1.2.0` |
| Ship unit (live) | `src/dns-cli` |
| Default install | `~/.local/bin/dns-cli` |
| Install mode | **Local-only** |
| LPU | `dns-adm` — `requirement-least-privilege-user` — **Implemented** |
| Type map / elev | `requirement-three-layer-privilege-model` — **Implemented** |
| Domain SSOT | `requirement-domain-cloudflare-dns` — v2 Implemented |
| A-record mode | `requirement-cloudflare-dns-mode` — default non-round-robin; stored mode **Implemented** |
| DNS request JSON | `requirement-cloudflare-dns-request` — four types + examples; inbound **Implemented** (1.9.0) |
| External IPv4 | `requirement-external-ipv4` — Implemented (IPv6 MUST NOT) |
| Application local vault (path + specify) | `requirement-application-local-vault` — specify + default `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` **Implemented** (1.8.0) |
| Vault law (schema / verbs) | `requirement-cloudflare-vault` 2.4.0 — zone-slot add/list/modify/remove; `{label, mode}`; v2 **Implemented** (1.2.0) |
| Cloudflare API | `requirement-cloudflare-api` 1.2.0 — Implemented (ship-unit subset; A only) |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

v2 vault CRUD, stored A-record mode, Type 1 `setup`, default `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`, Type 2 `sudo -u dns-adm` switch, and inbound DNS `submit` / `approve` / `reject` / `interactive` are **Implemented**.
