# dns-cli - Cloudflare DNS CLI (local self-managed)

![Version](https://img.shields.io/badge/Version-1.9.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/dns-cli?style=flat-square)](https://github.com/cloudgen/dns-cli)

POSIX `/bin/sh` CLI specialized from **cli-template**: Type 0 lifecycle plus a local Cloudflare vault and IPv4 **A-record** verbs. One vault holds many **domain-ids** (apex names). Each domain-id is one API binding (one token, one zone, one `user_id`) and may hold many subdomains.

Each subdomain has a stored **A-record mode**. The default is **non-round-robin** (one IPv4). **Round-robin** means several distinct IPv4 A rows on the same FQDN. Mode may switch only when `ipv4_count` is 0 or 1. IPv6 / AAAA are out of scope.

Product **law** also defines a **file-based JSON approval** machine (inbound folder + closed JSON + approve by moving the file) and an LPU **`dns-adm`**. On ship unit **1.9.0**, Type 0 specify vault + DNS A CRUD + stored mode + token probe + approver **rc heal** + Type 1 **`setup` / `remove-lpu`** + Type 0 **`print-sudoers`** + Type 0 **JSON sudoer generate/submit** (`type-2-switch`) + **`setup` writes `login-hook-elev` into dest inbound** + default dest **`${dns-adm home}/.local/vaults/dns-cli/`** + Type 2 **`sudo -n -u dns-adm` switch** + inbound **DNS** **`submit` / `approve` / `reject` / `interactive`** **are implemented**. Prompt helpers consume the `TTY` SSOT. `install` (including `sudo … install`) places the program only — it does **not** create Linux user `dns-adm`. Next: `sudo dns-cli setup`.

Install **location** is still **both**:

- **local** → `~/.local/bin/dns-cli` (normal user)
- **global** → `/usr/local/bin/dns-cli` (root / `--global`)

The *channel* is local-only (no online `curl|sh`). Local vs global here means where the binary is placed, not an online vs offline download.

The Cloudflare API token stays in a **0600 file inside the vault**. It is never a CLI flag, never a request-JSON field, and never belongs in this README, reviews, or other public git text.

## Features

- **Self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`
- **Type N empty argv**: no arguments shows help (does not install, submit, or mutate DNS)
- **Managed binary mode 0755**: global install stays readable and runnable
- **Fail-closed**: unknown commands (including trimmed parent verbs) exit non-zero
- **Public IPv4 QA**: `ip` shows the same ipinfo lookup used by `add` / `update` / `status` (no vault)
- **Specify local vault**: `--vault-dir PATH` or `CF_VAULT_DIR` (absolute; not `/tmp` or `/dev/shm`)
- **Zone-slot CRUD**: `vault account` / `vault zone` add \| list \| modify \| remove; list JSON never includes the token
- **Token probe**: adding a zone token creates `_test_<UTC timestamp>` then deletes it; fail closed if the token cannot write DNS; probe label is **not** stored
- **Two A-record modes**: default `non-round-robin`; optional `round-robin`; switch locked when `ipv4_count` ≥ 2
- **Four DNS request types**: inbound JSON `add` / `update` / `remove` / `mode` — **no token in the file**. `submit` / `approve` / `reject` / `interactive` are Implemented (1.9.0)
- **Host LPU**: `sudo dns-cli setup` creates `dns-adm` + `${home}/.local/vaults/dns-cli` + sudoers dest; `remove-lpu` tears it down; `print-sudoers` **prints the sudoer file** (Table A text; does not install dest)
- **JSON sudoer submitter**: two kinds. `generate-sudoer-request` / `submit-sudoer-request` queue **`type-2-switch`** (current login as `dns-adm`). Type 1 `setup` auto-queues **`login-hook-elev`** (`dns-adm` may `sudo -n dns-cli interactive`) when sibling `sudoer-cli` exists. This product does not write `/etc/sudoers.d`
- **CIAO / CIAO-Lite** defensive design (Protection Zones, `out_*` output SSOT)

## Quick Installation

**Local (Type 0 day-to-day):**

```sh
# From this repository checkout
sh src/dns-cli install
# or force refresh after updates
sh src/dns-cli install --force

# Ensure ~/.local/bin is on PATH, then:
dns-cli version
```

**Global (multi-user hosts):**

```sh
sudo sh src/dns-cli install
# or: dns-cli install --global   # needs write access to /usr/local/bin
# Managed binary mode is always 0755 so every user can run the shell ship unit.
```

This product is **local-only** for its install channel (no default `SCRIPT_URL` online install). Global vs local here means install *location*, not an online channel.

`sudo dns-cli install` does **not** create Linux user **`dns-adm`**. After a global install:

```sh
sudo dns-cli setup
```

**Source repository:** [cloudgen/dns-cli](https://github.com/cloudgen/dns-cli)  
Config identity: `REPO_USER=cloudgen`, `REPO_NAME=dns-cli` (override with env if needed; does not enable online install while `SCRIPT_URL` is empty).

## Usage

```sh
dns-cli help
dns-cli about
dns-cli --json about

dns-cli install
dns-cli --vault-dir /path/to/vault vault account add example.com \
  --user-id 0123456789abcdef0123456789abcdef \
  --zone-id 0123456789abcdef0123456789abcdef \
  --account-id 0123456789abcdef0123456789abcdef \
  --subdomain office \
  --token-file /path/to/token   # file mode 0600; never --token
dns-cli --vault-dir /path/to/vault vault account list
dns-cli --vault-dir /path/to/vault --domain example.com --subdomain office add --ip 203.0.113.10
dns-cli --vault-dir /path/to/vault --domain example.com --subdomain office status
dns-cli ip
dns-cli uninstall --force
```

`--user-id` / `--zone-id` / `--account-id` above are **documentation hex**, not live Cloudflare ids. Put the real token only in a **0600 file**; never paste it into chat, argv, JSON, or git.

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `dns-cli`) |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `USER_BIN` | Per-user install destination (default `~/.local/bin`) |
| `GLOBAL_BIN` | Global install destination (default `/usr/local/bin`) |
| `CF_VAULT_DIR` | Override local application vault (absolute; `--vault-dir` wins) |

### Non-round-robin vs round-robin

Cloudflare **round-robin** here is **several type=A rows** on one FQDN, each a **different public IPv4**. It is not Cloudflare Load Balancing and not AAAA.

| | `non-round-robin` (default) | `round-robin` |
|--|-----------------------------|---------------|
| Meaning | This FQDN has **at most one** IPv4 | This FQDN may have **many** distinct IPv4 A rows |
| `add` | No A → create. Same IP → `already`. Different IP → **overwrite** that one A | Absent IP → **append** a new A. Same IP → `already`. Does **not** overwrite others |
| `update` | Overwrite the single A (none → `dns_missing`) | N>1 needs `--from OLD`. Else `dns_target_required` |
| `remove` | Delete the one A (none → success no-op) | N>1 needs `--ip`. Else `ip_required` |
| `status` | Read-only. N>1 is drift (`dns_multi_record`) | Read-only. N≥2 **succeeds** and lists every A |

`ipv4_count` is the number of type=A rows Cloudflare returns for that FQDN. AAAA / CNAME / TXT do not count.

**Switch** (`vault subdomain mode <label> <mode>`) is an explicit stored-mode change. It does **not** create or delete A rows. It is allowed only when `ipv4_count` is **0 or 1**. To leave round-robin when N≥2, remove A rows first, then switch. `--force` collapse is **repair** of non-round-robin drift, not a way to enter round-robin.

Typical sequence to put a second IPv4 on `api`:

1. `vault subdomain mode api --mode round-robin` (only if count is 0 or 1)
2. `add --ip 203.0.113.20` (appends)

### File-based JSON approval (law)

This is the same **folder = state, JSON = proposal** machine used elsewhere in the house: a normal user **drops** a self-scoped JSON file into an **inbound** directory; an approver **re-checks** that JSON and **moves** the file to accepted or declined. The CLI allocates the basename. The submitter does not choose the dest name.

| Piece | Rule |
|-------|------|
| State | Three directories: inbound → accepted \| declined |
| Proposal | One JSON object; closed schema |
| Submit | Type 0 writes the file (self-scope: subject = invoker) |
| Approve | Type 1 / LPU re-validates, then **moves** the file and applies the dest verb |
| Token | **Never** in the JSON. Token stays in the vault. Unknown keys fail closed |
| Basename | `YYYYMMDD-<subject>-<action>-<n>.json` (allocator-owned) |

Exactly **four** request `action` values. Read-only verbs (`status`, `ip`, `show`) are **not** submissions. `vault account add` is **store**, not a public DNS request. `--force` collapse is **repair**, not a type.

| `action` | Proposes | Approve dest |
|----------|----------|--------------|
| `add` | One IPv4 A (create or append per stored mode) | DNS `add` |
| `update` | Overwrite one existing IPv4 A | DNS `update` (round-robin N>1 needs `from_ipv4`) |
| `remove` | Delete one IPv4 A | DNS `remove` (round-robin N>1 needs `ipv4`) |
| `mode` | Switch stored mode only | `vault subdomain mode` — **no** A-row write |

**Ship unit 1.5.0:** operators run `add` / `update` / `remove` / `vault subdomain mode` **directly** (Type 0 `--vault-dir` is enough). `sudo dns-cli setup` creates `dns-adm`. Interactive `dns-adm` **heals** the login-hook rc. The inbound folder + `submit` / `approve` / `reject` / `interactive` review loop are **Gap**. Empty argv still must not submit or approve.

### Actor table (who may submit / approve)

This table is **DNS inbound only**. Sudoer print / JSON submit uses the next table.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Submitter** | **Anyone** — any login (example `alice`; this host `leolio`) | 0 | Drop a self-scoped JSON file into inbound (`submit`) | Submit for someone else; hold the API token |
| **Subject** | Same person as the submitter | — | Appear in the filename and JSON `subject` | Be another login |
| **Approver** | **`dns-adm`** | 1 | Re-check JSON; **move** inbound → accepted/declined; apply dest | Invent a second approver account |
| **Allocator** | `dns-cli` Type 0 `submit` | 0 | Name the file `YYYYMMDD-<subject>-<action>-<n>.json` | Trust a caller-chosen dest name |
| **Type 2 operator** | **`dns-adm`** (same account) | 2 | Day-to-day vault + DNS on the default vault | — |
| **Root session** | euid 0 | 1 | Same Type 1 verbs as `dns-adm` | Submit as another subject |

**Anyone** may submit a **DNS** request (as themselves). Only **`dns-adm`** approves DNS inbound. There is no `dns-apr`.

### Role table (print sudoer file + JSON sudoer submit)

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Printer** | Any login | 0 | `print-sudoers` — print the sudoer **file** (Table A text) | Write `/etc/dns-adm/sudoers` or `/etc/sudoers.d` |
| **Generator** | Same login | 0 | `generate-sudoer-request` — local JSON grant | Write inbound or `/etc` |
| **Submitter** | Same login (self-scope) | 0 | `submit-sudoer-request` — queue **`type-2-switch`** JSON to sibling `sudoer-cli` | Queue `login-hook-elev`; approve; `mkdir` inbound; write `/etc/sudoers.d` |
| **Hook auto-submitter** | Host admin | 1 | `setup` queues **`login-hook-elev`** when sibling exists | Fail setup when sibling is absent; write `/etc/sudoers.d` |
| **Subject** | Same person as the submitter | — | JSON `username` | Be another login |
| **Allocator** | Sibling `sudoer-cli` | 0 | Name the inbound file | Be this product |
| **Sibling approver** | **`sudoer-adm`** | 1 | Move inbound; dest `/etc/sudoers.d/dns-cli-<user>` | Be `dns-adm` |
| **F6 installer** | Host admin (`sudo dns-cli setup`) | 1 | Install the printed sudoer file to `/etc/dns-adm/sudoers` | Write `/etc/sudoers.d` from this product |
| **Type 2 operator** | **`dns-adm`** | 2 | Run the managed binary after a live grant | Approve sudoer JSON |

`dns-cli submit` is DNS inbound (Gap). `dns-cli submit-sudoer-request` is the **`type-2-switch`** JSON queue (Implemented). `setup` auto-queues **`login-hook-elev`**. `dns-adm` ≠ `sudoer-adm`.

### Approval procedure (interactive hook after login)

When implemented:

1. **Anyone** runs `dns-cli submit` (self-scope JSON only).  
2. **`dns-adm`** logs in on a **TTY**.  
3. A `.bashrc` hook runs **once** per session: `sudo -n /usr/local/bin/dns-cli interactive`.  
4. `interactive` shows each inbound file (purpose + body) and prompts **accept** / **decline** / **skip** / **quit**.  
5. Accept or decline **re-validates** the JSON, then **moves** the file. Accept also applies the dest DNS/mode verb.  
6. Empty inbound → exit 0; the login continues to a shell.  
7. `scp` / no TTY → the hook does nothing. `sudo -n` fail → warning; login still succeeds.  
8. `dns-cli` with no arguments remains **help**, not review.

When `dns-adm` runs `dns-cli` **interactively**, the CLI **heals** the hook: it appends the snippet to `~/.bashrc` if missing, and **creates** `~/.profile` (only if that file does not exist) so a login shell sources `.bashrc`. An existing `.profile` is never overwritten.

Until `interactive` is routed, the hook may warn (`sudo -n` / unknown verb). Do not put the token in the JSON, `.bashrc`, `.profile`, or this README.

## Examples

```sh
# Local install (user bin)
sh src/dns-cli install

# Diagnostics (no token)
dns-cli about
dns-cli --json version
dns-cli ip
dns-cli --json ip

# Specify vault — Type 0 as the invoking user (not dns-adm)
dns-cli --json --vault-dir /path/to/vault vault account list
dns-cli --json --vault-dir /path/to/vault --domain example.com \
  --subdomain office add --ip 203.0.113.10
dns-cli --json --vault-dir /path/to/vault --domain example.com \
  vault subdomain mode api --mode round-robin
dns-cli --json --vault-dir /path/to/vault --domain example.com \
  --subdomain api add --ip 203.0.113.20
dns-cli --json --vault-dir /path/to/vault --domain example.com \
  --subdomain api update --from 203.0.113.20 --ip 203.0.113.21
dns-cli --json --vault-dir /path/to/vault --domain example.com \
  --subdomain api --ip 203.0.113.21 remove
```

### DNS request JSON samples (law shape)

Fictional apex `example.com` and documentation IPv4s (`203.0.113.0/24`). **MUST NOT** copy a live token, zone id, account id, or host vault path into a submission or into git.

**`add` — non-round-robin** (default; one IPv4). Basename: `20260817-alice-add-1.json`

```json
{
  "schema_version": 1,
  "purpose": "Point office to this host public IPv4",
  "subject": "alice",
  "action": "add",
  "domain_id": "example.com",
  "subdomain": "office",
  "ipv4": "203.0.113.10",
  "ttl": 300,
  "proxied": false
}
```

**`add` — round-robin** (append a distinct IPv4; stored mode on `api` is already `round-robin`). Basename: `20260817-alice-add-2.json`

```json
{
  "schema_version": 1,
  "purpose": "Add second A for api round-robin",
  "subject": "alice",
  "action": "add",
  "domain_id": "example.com",
  "subdomain": "api",
  "ipv4": "203.0.113.20"
}
```

**`update` — non-round-robin** (overwrite the single A). Basename: `20260817-alice-update-1.json`

```json
{
  "schema_version": 1,
  "purpose": "Move office A to the new egress IPv4",
  "subject": "alice",
  "action": "update",
  "domain_id": "example.com",
  "subdomain": "office",
  "ipv4": "203.0.113.11"
}
```

**`update` — round-robin** (which A, via `from_ipv4`). Basename: `20260817-alice-update-2.json`

```json
{
  "schema_version": 1,
  "purpose": "Replace one api A with a new IPv4",
  "subject": "alice",
  "action": "update",
  "domain_id": "example.com",
  "subdomain": "api",
  "from_ipv4": "203.0.113.20",
  "ipv4": "203.0.113.21"
}
```

**`remove` — non-round-robin**. Basename: `20260817-alice-remove-1.json`

```json
{
  "schema_version": 1,
  "purpose": "Drop office A; host is decommissioned",
  "subject": "alice",
  "action": "remove",
  "domain_id": "example.com",
  "subdomain": "office"
}
```

**`remove` — round-robin** (one IPv4). Basename: `20260817-alice-remove-2.json`

```json
{
  "schema_version": 1,
  "purpose": "Remove one api A after that backend left",
  "subject": "alice",
  "action": "remove",
  "domain_id": "example.com",
  "subdomain": "api",
  "ipv4": "203.0.113.21"
}
```

**`mode` — enter round-robin** (`ipv4_count` must be 0 or 1). Basename: `20260817-alice-mode-1.json`

```json
{
  "schema_version": 1,
  "purpose": "Allow api to hold more than one IPv4",
  "subject": "alice",
  "action": "mode",
  "domain_id": "example.com",
  "subdomain": "api",
  "mode": "round-robin"
}
```

**`mode` — return to non-round-robin** (count still 0 or 1). Basename: `20260817-alice-mode-2.json`

```json
{
  "schema_version": 1,
  "purpose": "api is single-homed again",
  "subject": "alice",
  "action": "mode",
  "domain_id": "example.com",
  "subdomain": "api",
  "mode": "non-round-robin"
}
```

A `mode` file **must not** carry `ipv4`. Do not use `mode` to add a second address — switch first, then `add`.

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `mktemp`, `date`, `curl`, `python3` or `jq` | Required (`python3` for v2 vault JSON) |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [selfmanaged](https://github.com/cloudgen/selfmanaged) — related Type 0 product (online channel); **not** this product’s origin
- [folder-backup](https://github.com/cloudgen/folder-backup) — related product (backup/restore/sudoers); **not** this product’s origin
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/dns-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits (that suite stays **offline**).

**Public-surface leak review (required):** do not commit Cloudflare API tokens, Bearer lines, vault token files, live `--token-file` contents, host SSH vault paths, or real zone/account/user ids copied from a dashboard session. JSON examples use documentation IPv4s only. Reviews and commit-check treat a pasted `cfut_…` / `ghp_…` value on `README.md`, `CHANGELOG.md`, `SECURITY.md`, `reviews/**`, or `docs/requirements/**` as a **Block**. Prefer `--token-file` (mode 0600) and `curl --config`; never `--token` on argv.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-18 — version **1.5.0** (`sudo dns-cli setup` creates `dns-adm`; Type 2 default vault still Gap).
