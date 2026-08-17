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
| LPU | `dns-adm` — `requirement-least-privilege-user` — **Gap** |
| Type map / elev | `requirement-three-layer-privilege-model` — **Gap** |
| Domain SSOT | `requirement-domain-cloudflare-dns` — v1 Implemented; v2 domain-id **Gap** |
| A-record mode | `requirement-cloudflare-dns-mode` — default non-round-robin; stored mode **Implemented** |
| DNS request JSON | `requirement-cloudflare-dns-request` — four types + examples; inbound **Gap** |
| External IPv4 | `requirement-external-ipv4` — Implemented (IPv6 MUST NOT) |
| Application local vault (path + specify) | `requirement-application-local-vault` — specify Implemented; default `/etc/dns-adm/vault/` **Gap** |
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

v2 vault CRUD, stored A-record mode, and implicit/default non-round-robin DNS are **Implemented** on `src/dns-cli` **1.2.0**. LPU `dns-adm`, Type 1 `setup`, and default `/etc/dns-adm/vault/` are **Gap**.
