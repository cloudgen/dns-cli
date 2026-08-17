# Requirements index

**Product:** dns-cli (POSIX `/bin/sh` local self-managed Cloudflare DNS CLI — Type 0/1/2 + LPU `dns-adm` + domain)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; **B = `dns-cli` hop 1** specialized from **A = `cli-template` hop 0**. Online / Type O / backup / restore **intentionally absent**. LPU **`dns-adm`** + Type 1 `setup` **in scope** (ship unit Gap).  
**Updated:** 2026-08-17

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only, curl + python3/jq); LPU residual owner | class | Active (1.5.0) | `requirement-class-software-dev.md` | 2026-08-17 |
| requirement-bootstrap-chain | Bootstrap origin A = cli-template (hop 0); this product B = dns-cli (hop 1); LPU on B | architecture | Active (5.1.0) | `requirement-bootstrap-chain.md` | 2026-08-17 |
| requirement-project-folder | Project layout (`src/dns-cli`), install bins; LPU home + vault pointer | architecture | Active (2.2.0) | `requirement-project-folder.md` | 2026-08-17 |
| requirement-least-privilege-user | LPU `dns-adm` F1–F7; owns default multi-account vault | architecture | Active (1.0.0) Gap | `requirement-least-privilege-user.md` | 2026-08-17 |
| requirement-three-layer-privilege-model | Type 0/1/2 map + Tables A/B/C; `setup` / `remove-lpu` / `print-sudoers` | architecture | Active (1.0.0) Gap | `requirement-three-layer-privilege-model.md` | 2026-08-17 |
| requirement-shell-cli-interface | Shell CLI interface (Type 0/1/2 + `--mode` / `--from` + `vault zone`) | shell | Active (3.2.0) | `requirement-shell-cli-interface.md` | 2026-08-17 |
| requirement-shell-cli-zero-arguments | Empty argv Type N help (local-only; no DNS/vault mutate) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-08-16 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755**; uninstall does not wipe vault or `dns-adm` | shell | Active (1.5.0) | `requirement-shell-local-self-management.md` | 2026-08-17 |
| requirement-shell-output-requirements | Central `out_*` output SSOT + `out_die_code` | shell | Active (1.1.0) | `requirement-shell-output-requirements.md` | 2026-08-16 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`/`cf_`/`lpu_`) | shell | Active (2.2.0) | `requirement-shell-modular-function-design.md` | 2026-08-17 |
| requirement-shell-idempotency | Re-run safety for install / uninstall / vault / DNS / mode switch | shell | Active (1.5.0) | `requirement-shell-idempotency.md` | 2026-08-17 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm / vault collect / remove-lpu | shell | Active (1.3.0) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-17 |
| requirement-shell-cli-storage | Scratch/cache resolve (not vault) | shell | Active (1.2.0) | `requirement-shell-cli-storage.md` | 2026-08-16 |
| requirement-domain-cloudflare-dns | **Domain SSOT** — A-record verbs; Type 0 live specify as invoking user | domain | Active (2.4.0) | `requirement-domain-cloudflare-dns.md` | 2026-08-17 |
| requirement-cloudflare-dns-mode | Per-subdomain A-record mode (default non-RR; RR multi-A; switch only when ipv4_count ∈ {0,1}; IPv4 only) | domain | Active (1.0.0) | `requirement-cloudflare-dns-mode.md` | 2026-08-17 |
| requirement-cloudflare-dns-request | Four inbound JSON types (`add`/`update`/`remove`/`mode`) + complete examples | domain | Active (1.0.0) Gap | `requirement-cloudflare-dns-request.md` | 2026-08-17 |
| requirement-external-ipv4 | External/public IPv4 lookup, `--ip`, vault-free `ip` display; IPv6 MUST NOT | shell | Active (1.1.0) | `requirement-external-ipv4.md` | 2026-08-17 |
| requirement-application-local-vault | Local application vault path; default `/etc/dns-adm/vault/`; `--vault-dir` / `CF_VAULT_DIR` specify | shell | Active (2.1.0) | `requirement-application-local-vault.md` | 2026-08-17 |
| requirement-cloudflare-vault | One LPU vault; zone-slot `account`/`zone` add\|list\|modify\|remove; `{label, mode}` | domain | Active (2.4.0) Implemented (LPU dest Gap) | `requirement-cloudflare-vault.md` | 2026-08-17 |
| requirement-cloudflare-api | Cloudflare HTTPS API (token, envelope, zone GET, DNS A CRUD; no AAAA) | domain | Active (1.2.0) | `requirement-cloudflare-api.md` | 2026-08-17 |

## Intentionally absent (by design)

| Surface | Status on dns-cli |
|---------|------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Sudoers-manager extras (`print-sudoers-install-script`, `remove-project-sudoers`) | **Absent** |
| Type 1 elevated deposit / restore-stage | **Absent** |

**Domain SSOT:** `requirement-domain-cloudflare-dns` (exactly one Active `requirement-domain-*`). Local vault **path/specify** is `requirement-application-local-vault`. Cloudflare **schema** is `requirement-cloudflare-vault`. Cloudflare **HTTPS API** is `requirement-cloudflare-api`. **A-record mode** is `requirement-cloudflare-dns-mode`. **DNS request JSON** is `requirement-cloudflare-dns-request`. Public IPv4 is `requirement-external-ipv4`. LPU identity is `requirement-least-privilege-user`. Elev tables are `requirement-three-layer-privilege-model`. None of those is a second `requirement-domain-*`.

**Install mode:** **local-only** (`install` + `uninstall` + `where-is-me`). Not dual-mode.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for dns-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only**.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active `requirement-domain-*` (`requirement-domain-cloudflare-dns`). Do not add a second Active domain catalog.  
8. **Do not reintroduce** backup, restore, sudoers-manager extras, or online install without explicit user order and registry update. `print-sudoers` + `setup` are **authorized** via the LPU / three-layer rows.  
9. v1 single-account vault/DNS on `src/dns-cli` is **Implemented** (implicit non-round-robin). LPU create, Type 2 default-vault, v2 multi-account layout, and stored A-record mode are **Gap** — do not claim those Implemented.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
