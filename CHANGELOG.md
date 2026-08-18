# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.4.1] - 2026-08-18

### Fixed

- Interactive helpers and vault confirm gates consume the `TTY` SSOT measured in `app_main` (no live `[ -t` retest inside `prompt_*`).
- Requirement Implementation Notes aligned to ship unit **1.4.1** (vault v2 / stored mode Implemented; inbound and LPU dest remain Gap).
- Dispatcher comment leftover `cf-cli` renamed to `dns-cli`.

## [1.4.0] - 2026-08-17

### Added (ship unit 1.4.0)

- Approver rc heal: when interactive and `id -un` is `dns-adm`, ensure `~/.bashrc` has the login hook; if `~/.profile` is missing, create one that sources `.bashrc`.

### Fixed

- Heal rewrites `.bashrc` via `mktemp` (not a predictable sidecar), preserves an existing rc mode, and treats the hook as present only when both BEGIN and END markers exist.

### Added (law)

- **`requirement-dns-approver`** **1.0.0**: approver is `dns-adm`; interactive hook after login; heal `.bashrc` / create `.profile`. **TP-CF-APR-01..06**. Mold **LM-ACTOR-TABLE** 1.1.0.
- **Actor table** `requirement-dns-actor-table` **1.0.1** (Gap): **anyone** may `submit`; **`dns-adm`** approves (no `dns-apr`); login-time `interactive` hook on `dns-adm`. README table + procedure. **TP-CF-ACTOR-01..06**.

## [1.3.0] - 2026-08-17

### Changed (ship unit 1.3.0)

- Product renamed **dns-cli** (`src/dns-cli`, `APP_NAME=dns-cli`). LPU name in law is **dns-adm** (default dest `/etc/dns-adm/vault/`; host create still Gap). Workspace folder may still be named `cf-cli`.
- `vault account` / `vault zone` **add** (and set/modify/input with a new `--token-file`) **probes** `_test_<UTC timestamp>` (create A `203.0.113.10`, then delete). Fail `token_probe_failed` if the token cannot write. Probe label is not stored.

### Changed (docs)

- Product `README.md` **1.2.0**: file-based JSON approval, four DNS request samples (no token field), non-round-robin vs round-robin, stay-honest Gap on submit/approve.
- Public-surface token leak review: `skill-file-leaks-check` **C5**, `skill-product-review` §2.6, commit-check / write-readme / write-review compose. Lesson **L-TOKEN-PUB-01**.

### Added (ship unit 1.2.0)

- v2 vault: `accounts/<domain-id>/` slots, `index.json`, required `user_id`, subdomain `{label, mode}`.
- `vault account` / `vault zone` **add / list / modify / remove / default / show**; list JSON is the test surface (no token).
- `vault subdomain modify` / `mode`; default **non-round-robin**; round-robin `add` appends a distinct IPv4; switch locked when `ipv4_count` ≥ 2.
- Suites **TP-CF-VAULT-18..33** and **TP-CF-MODE-01..08**.

### Added (law)

- Live Type 0 specify verify as the invoking user (`crms.hk` / `leolio`): D-M15/D-M16. Not `dns-adm`. Default suite stays offline.
- **DNS request types** `requirement-cloudflare-dns-request` **1.0.0** (Gap): exactly four inbound actions — `add`, `update`, `remove`, `mode` — with eight complete JSON examples (non-RR and RR variants).
- Glossary: `cloudflare-dns-request`, `cloudflare-dns-request-type`, `cloudflare-dns-request-basename`.
- Molds: **`LM-CLOUDFLARE-DNS-REQUEST`**, **`PM-CLOUDFLARE-DNS-REQUEST-TEST-PLAN`**, **`CL-CLOUDFLARE-DNS-REQUEST`**.

### Added (law, earlier)

- **Vault model §2.0** on `requirement-cloudflare-vault` **2.2.0**: `dns-adm` holds many domains and many Cloudflare user-ids; **1 : 1** domain↔token and domain↔`user_id`; **1 : N** domain↔subdomains.
- **Cloudflare API capability** `requirement-cloudflare-api` — Bearer token, envelope, zone GET, DNS A CRUD (PUT not PATCH).
- Glossary family: `cloudflare-api`, `cloudflare-api-envelope`, `cloudflare-api-token`, `cloudflare-api-key`, `cloudflare-zone`, `cloudflare-zone-id`, `cloudflare-account-id`, `cloudflare-user-id`, `cloudflare-dns-record`, `cloudflare-dns-record-id`.
- **Vault zone-slot CRUD** on `requirement-cloudflare-vault` **2.4.0**: `vault account` / alias `vault zone` **add / list / modify / remove**; `vault subdomain modify`; `--json` **list** is the test verification surface (no token).
- **A-record mode** `requirement-cloudflare-dns-mode` **1.0.0** (Gap): default **non-round-robin** (one IPv4 per subdomain); optional **round-robin** (many distinct IPv4 A rows); switch only when `ipv4_count` is 0 or 1; IPv4 only / no AAAA.
- Glossary family: `cloudflare-dns-mode`, `cloudflare-dns-non-round-robin-mode`, `cloudflare-dns-round-robin-mode`, `cloudflare-dns-mode-switch`, `subdomain-ipv4-count`.
- Molds: **`LM-CLOUDFLARE-DNS-MODE`**, **`PM-CLOUDFLARE-DNS-MODE-TEST-PLAN`**, **`CL-CLOUDFLARE-DNS-MODE`**.

### Changed (law — ship unit still 1.1.0)

- **LPU `dns-adm`:** new `requirement-least-privilege-user` + `requirement-three-layer-privilege-model`. Type 1 `setup` / `remove-lpu`; Type 0 `print-sudoers`; Type 2 default-vault DNS. Host create is **Gap**.
- **Multi-account vault:** each **domain-id** (apex domain name) is one Cloudflare API account with its own token; each domain-id **may** hold many subdomains (`requirement-cloudflare-vault` 2.0.0).
- Default vault dest is `/etc/dns-adm/vault/` (not the invoking user’s XDG tree). `--vault-dir` remains the QA specify path.
- Domain catalog **2.1.0** consumes mode law (no longer “always single A”). Vault **2.4.0** stores subdomain objects `{label, mode}` and requires zone-slot **add / list / modify / remove** (`vault account` / alias `vault zone`) so tests verify via **list** JSON. API **1.2.0** forbids AAAA and forbids mapping `vault zone add` to `POST /zones`. External-IPv4 **1.1.0** rejects IPv6 literals.

## [1.1.0] - 2026-08-16

### Added

- Product rename to **dns-cli** (`src/dns-cli`, `APP_NAME=dns-cli`, forge `cloudgen/dns-cli`).
- Cloudflare vault (`vault set|show|clear|subdomain`) at XDG config, 0700/0600, token file split.
- DNS verbs `add` / `update` / `remove` / `status` — one A record per FQDN; public IPv4 from ipinfo.io (`--ip` override).
- Suites **TP-CF-VAULT-01..07**, **TP-CF-DNS-01..07**, and **TP-CF-IP-01..04** (offline curl stub).
- Domain SSOT `requirement-domain-cloudflare-dns` and vault law `requirement-cloudflare-vault`.
- `ip` — print public IPv4 from ipinfo (or `--ip`) without vault or Cloudflare (QA).
- Vault suite **TP-CF-VAULT-08..17** (clear, subdomain add/list, schema, env vs set rewrite, uninstall).
- `requirement-external-ipv4` — public IPv4 lookup SSOT (`ip` verb; domain catalog consumes it).
- `requirement-application-local-vault` — declare + specify the local application vault (`--vault-dir` / `CF_VAULT_DIR`; **TP-AV-01..06**).

### Fixed

- `vault subdomain add` concatenated the last stored label (`home` + `office` → `homeoffice`) because `$(…)` strips trailing newlines.
- `vault set --zone-id` (and peer flags) now rewrite stored fields (V-M7 explicit set).
- Leftover `APP_NAME:=cli-template` defaults in install/uninstall/where-is-me/about.

### Changed

- Bootstrap chain: this tree is hop 1 (B); origin A remains cli-template.
- `out_die_code` for stable JSON error codes.

## [1.0.0] - 2026-08-13

### Added

- **cli-template** as a Type 0 template bootstrap origin (no live parent).
- Type 0 local self-managed CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.
- Empty argv **Type N** help (local-only; no curl|sh).
- Suite **TP-CLI-01..13** and **TP-LC-01..10**.
- Law: class software-dev + bootstrap-chain (this product is hop 0) + Type 0 shell family.

### Removed (not this origin’s surfaces)

- Domain verbs: `backup`, `restore`
- Sudoers-file verbs: `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`
- Durable `/var/backup` deposit, retention, restore dest whitelist
- `requirement-domain-folder-backup`, `requirement-folder-archive-backup*`, `requirement-three-layer-privilege-model`
- Product incidents INC-20260811-001 (sudoers grantee) and INC-20260812-001 (restore dest) — remain on sibling **folder-backup**
- Domain suite **TP-FOLDER-BACKUP-***

### Changed

- Identity SSOT: `APP_NAME=cli-template`, `REPO_NAME=cli-template`, `VERSION=1.0.0` (working names `hostmanaged` / `climanaged` dropped so this is not read as host-OS setup)
- Live parent hops **retired** — this product is hop 0; **selfmanaged** and **folder-backup** are not origins
- Ship unit path: `src/cli-template`
- About: Type 0 diagnostics only (no backup/sudoers fields)
- **No domain SSOT** and **no `setup` verb** — Type 0 template only (`version`, `install`, `about`, `help`)
- Install **locations unchanged**: local `${USER_BIN}` **and** global `${GLOBAL_BIN}` (`install --global` / root). “Local-only” still means **no online channel**, not “user-bin only.”
- Forge identity: repository-user **cloudgen**, author-email **wongcf22@gmail.com**, project-repository **cloudgen/cli-template**, product version **1.0.0**
