**file**: docs/requirements/requirement-cloudflare-vault.md  
**Status**: Active (Version 2.4.0) — 1:1 domain↔API↔user-id; zone-slot CRUD + list; 1:N subdomains with mode; ship unit **1.4.0 Implemented** (LPU default dest still Gap)  
**Area**: domain  
**Key**: `requirement-cloudflare-vault`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the Cloudflare **product vault**: on-disk layout, schema, permissions, interactive collect/update/show/clear, precedence, validation, and token transport files.

There is **one** host vault owned by **`dns-adm`**. That LPU **MUST** be able to hold **multiple domains** and therefore **multiple Cloudflare user-ids**. Bindings:

| Relation | Cardinality | Meaning |
|----------|-------------|---------|
| `dns-adm` → domain-id | **1 : N** | many apex zones |
| `dns-adm` → Cloudflare user-id | **1 : N** | many dashboard users (one per domain) |
| domain-id → API token | **1 : 1** | one Bearer secret per zone |
| domain-id → Cloudflare user-id | **1 : 1** | that token’s owning dashboard user |
| domain-id → zone-id | **1 : 1** | one Cloudflare zone |
| domain-id → subdomains | **1 : N** | many host-labels under that zone; each label has a stored [DNS mode](../terminologies/cloudflare-dns-mode.md) |

The on-disk **slot key** remains **domain-id** (apex). User-id is a **required field** on the slot, not a directory name.

The domain SSOT (`requirement-domain-cloudflare-dns.md`) **consumes** the **selected** account’s fields. HTTPS meaning of token / zone-id / account-id is `requirement-cloudflare-api`. Path/specify is `requirement-application-local-vault`. Default dest is the `dns-adm` F5 tree (`requirement-least-privilege-user`). This file is the **schema and store-UX** spec. It is **not** a second `requirement-domain-*` catalog.

This vault is **not** host SSH forge identity and **not** scratch from `util_resolve_storage`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Vault model (normative)

**V-M0.** Cardinality **MUST** be:

| Layer | Count | Key | What it holds |
|-------|-------|-----|----------------|
| Host vault root | **exactly 1** production dest | path from `requirement-application-local-vault` | `index.json` + `accounts/` |
| Zone slot | **N ≥ 0** | **domain-id** = apex DNS name | one token, one user-id, one zone-id, one account-id, subdomain labels |
| API token | **1 : 1** with domain-id | `accounts/<domain-id>/token` | that zone’s Bearer secret only |
| Cloudflare user-id | **1 : 1** with domain-id | field `user_id` | dashboard user that owns that token |
| Subdomain labels | **1 : N** with domain-id | host-label or `@` | names under that zone; FQDN is **derived**; each has `mode` |
| Per-OS-login vault | **0** in production | — | `--vault-dir` is QA only |

```text
dns-adm  (host LPU — one operator, many CF users + many domains)
    └── /etc/dns-adm/vault/                    ← one vault
            ├── index.json
            └── accounts/
                    ├── example.com/          ← domain-id
                    │     user_id   U1        ← 1:1 with this domain
                    │     token     T1        ← 1:1 API for this domain
                    │     zone_id   Z1
                    │     account_id A1
                    │     subdomains: @, www, office   ← 1:N (each has mode)
                    └── other.org/
                          user_id   U2        ← different CF user
                          token     T2
                          zone_id   Z2
                          account_id A2
                          subdomains: api
```

**V-M0a.** `dns-adm` **MUST** support **multiple** Cloudflare user-ids (one stored `user_id` per domain-id). **MUST NOT** create `users/<cloudflare-user-id>/` as the slot key. Slot directory **MUST** stay `accounts/<domain-id>/`.

**V-M0b.** Each domain-id **MUST** store exactly one `user_id` (32-hex). Two domain-ids **MUST NOT** share a `user_id` (domain ↔ user-id is **1 : 1** both ways). Missing `user_id` → `vault_incomplete` / `vault_invalid`.

**V-M0c.** Each domain-id **MUST** have exactly one token file (domain ↔ API **1 : 1**). A subdomain **MUST NOT** be a second slot. FQDN **MUST** be derived: `@` → apex; otherwise `<label>.<apex>`.

**V-M0d.** Two slots **MUST NOT** share a `token` file, the same `zone_id`, or the same `user_id`. Two slots **MAY** share an `account_id` only if that still yields **distinct** `user_id` values (unusual; fail closed if `user_id` collides).

**V-M0e.** `--vault-dir` / `CF_VAULT_DIR` **MUST NOT** be “one vault per host login.” Multiple Cloudflare user-ids live **inside** the one dest.

**Complete sample `index.json`:**

```json
{
  "schema_version": 2,
  "default_domain_id": "example.com",
  "domain_ids": ["example.com", "other.org"]
}
```

**Complete sample `accounts/example.com/vault.json`:**

```json
{
  "schema_version": 2,
  "user_id": "100bf38cc8393103870917dd535e0628",
  "account_id": "372e67954025e0ba6aaa6d586b9e0b59",
  "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
  "domain": "example.com",
  "subdomains": [
    {"label": "@", "mode": "non-round-robin"},
    {"label": "www", "mode": "non-round-robin"},
    {"label": "office", "mode": "round-robin"}
  ]
}
```

**Complete sample `accounts/example.com/token` (shape only — never a real secret in this file):**

```text
<one line; Bearer secret; no JSON; mode 0600>
```

### 2.1 Location and isolation

**V-M1.** Vault **directory resolve and specify** (`--vault-dir` / `CF_VAULT_DIR` / default `/etc/dns-adm/vault/`) are owned by `requirement-application-local-vault`. This file **consumes** that path. **MUST NOT** invent a second default.

Fail closed:

| Condition | Code |
|-----------|------|
| Default dest and `dns-adm` absent (no specify) | `lpu_missing` |
| Specified or resolved vault dir is under `/tmp` or `/dev/shm` | `vault_insecure` |
| `HOME` unset/empty/`/tmp` **and** no specify **and** no usable LPU dest | `vault_no_home` |

**MUST NOT** inherit Type 0 `HOME=/tmp` for secret I/O. **MUST NOT** place vault files under `EFFECTIVE_STORAGE_DIR` or any `util_resolve_storage` tier. On fail-closed, **MUST NOT** `mkdir` the rejected path.

### 2.2 Layout and permissions

**V-M2.** Multi-account layout (schema **2**):

| Path | Mode | Contents |
|------|------|----------|
| vault dir | `0700` | directory (default owner `dns-adm:dns-adm`) |
| `index.json` | `0600` | non-secret catalog only (`schema_version`, `default_domain_id`, `domain_ids`) |
| `accounts/<domain-id>/` | `0700` | one Cloudflare API account |
| `accounts/<domain-id>/vault.json` | `0600` | non-secret fields for that account |
| `accounts/<domain-id>/token` | `0600` | that account’s API token only (single line, no JSON) |

**domain-id** **MUST** be the apex domain name (same string as `domain`). Directory name **MUST** be DNS-safe (no `/`, `..`, spaces).

**V-M3.** If the vault dir or an account dir is not `0700`, or any vault/token/index file is group/other-readable (or world-writable), **MUST** fail `vault_insecure`. Do not continue with a loosened vault.

**V-M11.** Writes **MUST** be atomic temp+rename **inside the account dir** (or vault dir for `index.json`) with `umask 077` and `chmod 0600` on the replacement file.

**MUST NOT** use `util_backup` (dated sibling `.bak`) on secret files.

**V-M15.** A v1 single-account tree (`vault.json` + `token` at the vault root, no `accounts/`) **MUST** fail `vault_invalid` (do not guess a domain-id). Operator re-enters via `vault account add`.

### 2.3 Schema

**V-M4 / V-M12.** `index.json` **MUST** include:

| Field | Rule |
|-------|------|
| `schema_version` | integer `2` only; missing or unknown → `vault_invalid` |
| `domain_ids` | JSON array of apex names (may be empty only before first account) |
| `default_domain_id` | one of `domain_ids`, or JSON `null` when empty / unset |

Per-account `accounts/<domain-id>/vault.json` **MUST** include:

| Field | Rule |
|-------|------|
| `schema_version` | integer `2` only |
| `user_id` | Cloudflare **user-id** (32-hex dashboard user). **1 : 1** with this domain-id |
| `account_id` | Cloudflare 32-hex account id (org; stored even though DNS CRUD does not send it) |
| `zone_id` | Cloudflare 32-hex zone id |
| `domain` | apex DNS name; **MUST** equal the directory domain-id |
| `subdomains` | JSON array of **one or more** objects `{ "label": "<host-label\|@>", "mode": "non-round-robin"\|"round-robin" }`; persisting zero labels is forbidden |

Token **MUST NOT** appear in `index.json` or any `vault.json`. Each account **MUST** have its **own** token file. **MUST NOT** share one token file across domain-ids.

**V-M8.** Validate: token non-empty after trim; `user_id`, `zone_id`, and `account_id` each `^[0-9a-f]{32}$`; apex DNS-safe; each subdomain object has `label` (LDH host-label **or** `@`) and `mode` (`non-round-robin` or `round-robin` only). Reject path separators and spaces. Bare strings in `subdomains` → `vault_invalid`. Duplicate `label` in one slot → `vault_invalid`. Two slots **MUST NOT** share domain-id, `zone_id`, `user_id`, or a token file. Unknown keys (except the required set) → `vault_invalid`. Alias `cloudflare_user_id` is **not** accepted — field name is `user_id` only.

**V-M9.** Multiple named host-labels under **one** domain-id **are** required capability. A-record **mode** (one IPv4 vs many A rows) is **DNS** law (`requirement-cloudflare-dns-mode`), not vault cardinality. `vault subdomain remove` of the **last** remaining label **on that domain-id** **MUST** fail `subdomain_required` (or `vault_incomplete`).

**V-M17.** `vault subdomain add` **MUST** store `mode=non-round-robin` unless `--mode` is given. `vault subdomain mode <label> <mode>` **MUST** apply the switch gate in `requirement-cloudflare-dns-mode` (live `ipv4_count` ∈ {0, 1}; else `dns_mode_locked`). The switch **MUST NOT** mutate DNS records. `vault subdomain list` / `vault show` **MUST** print each label’s `mode`.

**V-M16.** Account / zone-slot selection **MUST** follow: `--domain` / `--domain-id` / operand if given; else `index.json` `default_domain_id` if set and still present; else if exactly one domain-id, use it; else `domain_required`. DNS verbs consume the selected account only.

**V-M18. Zone-slot CRUD (testable).** Each stored Cloudflare **zone API binding** (one domain-id = one zone-id = one token = one user-id) **MUST** have corresponding vault subcommands **add**, **list**, **modify**, and **remove**. Tests **MUST** be able to verify each mutate by **list** (or `show`) JSON — never by reading `token` or by calling Cloudflare `POST /zones`.

| Verb | Canonical | Alias (same handler) | Required effect |
|------|-----------|----------------------|-----------------|
| **add** | `vault account add <domain-id>` | `vault zone add <domain-id>` | Create the slot. Collect missing API fields (`user_id`, `account_id`, `zone_id`, token, ≥1 subdomain). Fail `domain_exists` if present. **MUST NOT** call Cloudflare create-zone. |
| **list** | `vault account list` | `vault zone list` | Print every slot (V-M19). Empty vault → success with empty `accounts` / `domain_ids`. |
| **modify** | `vault account modify <domain-id>` | `vault zone modify <domain-id>` | Rewrite **named** flags on that slot (`--zone-id`, `--account-id`, `--user-id`, `--token-file`). Domain-id / directory name is **immutable** (`vault_invalid` if `--domain` would rename). Unnamed fields stay. |
| **remove** | `vault account remove <domain-id>` | `vault zone remove <domain-id>` | Delete that slot dir + drop from index. Confirm unless `--force`. Last slot **MAY** be removed (vault empty). |

`vault set` / `init` **MUST** remain the **selected-slot** modify (no domain-id operand; selection per V-M16). `vault show` **MUST** remain the selected-slot (or `--all`) redacted read. They do **not** replace `list` as the catalog.

**V-M19. List / show JSON (verification surface).** `--json vault account list` / `--json vault zone list` **MUST** be an `out_json` object that includes:

| Field | Rule |
|-------|------|
| `type` | `vault_account_list` |
| `command` | `vault` |
| `domain_ids` | JSON array of apex names (may be empty) |
| `default_domain_id` | apex or JSON `null` |
| `accounts` | JSON array of slot objects, one per domain-id |

Each `accounts[]` object **MUST** include: `domain_id`, `domain`, `user_id`, `zone_id`, `account_id`, `token_present` (bool), `is_default` (bool), `subdomain_count` (integer), `subdomains` (array of `{label, mode}`). **MUST NOT** include the token value, `--config` path, or `CF_API_TOKEN`.

`--json vault account add` / `modify` / `remove` **MUST** succeed with `type` `vault_account_add` / `vault_account_modify` / `vault_account_remove` and the **same** non-secret slot fields for the affected domain-id (remove: `domain_id` + `removed` true). After add or modify, a following **list** **MUST** show the new or rewritten fields. After remove, **list** **MUST NOT** include that `domain_id`.

`--json vault subdomain list` **MUST** include `domain_id` plus `subdomains` as `{label, mode}` objects (not a bare string array). `--json vault subdomain add` / `modify` / `remove` **MUST** include the affected `label` and `mode` so a following **list** can verify.

**V-M20. Subdomain CRUD (testable).** Host-labels under a zone slot **MUST** have:

| Verb | Subcommand | Required effect |
|------|------------|-----------------|
| **add** | `vault subdomain add <label>` | Append unique label; default `mode=non-round-robin`; `--mode` **MAY** set the other value at create |
| **list** | `vault subdomain list` | All labels + modes on the selected domain-id |
| **modify** | `vault subdomain modify <label>` | `--mode` applies the [mode switch](../terminologies/cloudflare-dns-mode-switch.md) gate (`requirement-cloudflare-dns-mode`); `--label NEW` renames (unique). `vault subdomain mode` remains an allowed alias of `--mode` |
| **remove** | `vault subdomain remove <label>` | Drop that label; last label on the domain-id fail-closed |

**MUST NOT** treat a subdomain as a second zone slot or a second API token.

### 2.4 Precedence and collect

Merge order for a field: **vault file > flags > env**. Flags/env fill **missing** fields only.

**V-M7.** Vault **wins**. A present vault field **MUST NOT** be overwritten by `CF_*` env or flags except on an explicit `vault set` / `init` / `vault account modify` / `vault zone modify` rewrite of that field.

Documented env (non-interactive fill of **empty** fields only):

| Env | Field |
|-----|--------|
| `CF_API_TOKEN` | token for the **selected** domain-id |
| `CF_USER_ID` | `user_id` |
| `CF_ZONE_ID` | zone_id |
| `CF_ACCOUNT_ID` | account_id |
| `CF_DOMAIN` / `CF_DOMAIN_ID` | domain-id (apex) when creating/selecting |
| `CF_SUBDOMAIN` | one host-label when creating/selecting |

**V-M5.** Interactive collect **MUST** use `prompt_*` **only for fields still empty** after merge. Token **MUST** use `prompt_secret` (no echo). `CF_API_TOKEN` is written to disk **only** on `vault set` / `init` / `vault account modify` / `vault zone modify`.

**V-M6.** **MUST NEVER** print the token in `about`, logs, `out_debug`, default JSON, help, README, tests, or `vault show`.

**V-M21. Token write-probe.** When the operator **adds** a zone-slot or supplies a **new** `--token-file` (`vault account add`, `vault zone add`, `vault account modify` / `set` / `input` with a new token), the product **MUST** prove the token can write DNS **before** persisting the slot (or before keeping the new token):

1. Allocate a host-label `_test_{{UTC YYYYMMDDHHMMSS}}` (digits only after `_test_`).  
2. `POST` one type=A row for that FQDN with documentation IPv4 `203.0.113.10`, proxied false.  
3. `DELETE` that row.  
4. **MUST NOT** store the probe label as a vault subdomain.  
5. **MUST NOT** use `@` or `www`.  

If POST or DELETE fails → `token_probe_failed` and **MUST NOT** persist the new slot / new token. Offline tests **MUST** stub curl (D-M10).

**V-M13.** `--token-file PATH` **MUST** be a regular file with mode `0600`; otherwise `vault_insecure`. **MUST NOT** accept `--token` on argv.

### 2.5 Token transport for HTTPS

**V-M14.** Per-invocation `curl --config` / header file **MUST** be created with `mktemp` **inside the vault dir**, mode `0600`, used, and unlinked in the same process (`trap` on EXIT/INT/TERM). **MUST NOT** put the token on `curl` argv. An environment variable passed into `curl -H` is **not** a valid mitigation.

### 2.6 Commands owned here (store UX)

`vault zone …` is an **alias family** of `vault account …` (same slot: one Cloudflare zone API binding). Help **MUST** list both names once the family is routed.

| Subcommand | Behavior |
|------------|----------|
| `vault input` | **Interactive TTY wizard** — select/create domain-id then prompt that account’s fields (Enter keeps current). `--json` / non-TTY **MUST** fail `confirm_required`. Bare `vault` routes here. |
| `vault account add` / `vault zone add` `<domain-id>` | **Add** a zone-slot (V-M18). Fail `domain_exists` if present. **MUST NOT** `POST /zones`. |
| `vault account list` / `vault zone list` | **List** every zone-slot (V-M19). Verification surface for add / modify / remove. |
| `vault account modify` / `vault zone modify` `<domain-id>` | **Modify** named API fields on that slot (V-M18). |
| `vault account remove` / `vault zone remove` `<domain-id>` | **Remove** that slot (V-M18). Confirm unless `--force`. |
| `vault account default` / `vault zone default` `<domain-id>` | Set `default_domain_id` |
| `vault account show` / `vault zone show` `[<domain-id>]` | Alias of `vault show` for that slot (or selected if omitted) |
| `vault set` / `vault init` | Selected-slot modify: collect **missing** fields; named flags rewrite (V-M7). Write that account’s `vault.json` + `token` and refresh index. |
| `vault show` | Redacted view of selected account (or all with `--all`); **MUST** include `user_id` (not a secret); **SHOULD** print file modes (V-S2); **MUST NOT** print token |
| `vault clear` | Delete **all** accounts + index; confirm unless `--force` |
| `vault subdomain add <label>` | **Add** host-label (V-M20) |
| `vault subdomain list` | **List** labels + `mode` (V-M19 / V-M20) |
| `vault subdomain modify <label>` | **Modify** `--mode` and/or `--label` (V-M20) |
| `vault subdomain remove <label>` | **Remove** one label; last label fail-closed |
| `vault subdomain mode <label> <mode>` | Alias of `vault subdomain modify <label> --mode <mode>` |

**V-S3 (SHOULD).** Document `CF_*` as non-interactive fill only.

**V-M10.** Distinct from host SSH forge vaults. **MUST NOT** document host SSH profile or key paths. **MUST NOT** commit secrets.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **APP_NAME (target)** | `dns-cli` |
| **Vault path (target)** | Owned by `requirement-application-local-vault` (default `/etc/dns-adm/vault/`) |
| **Live identity** | Config `APP_NAME="dns-cli"` in `src/dns-cli` — Implemented |
| **Vault code** | v2 multi-account Implemented on `src/dns-cli` **1.4.0**. **Gap:** default dest `/etc/dns-adm/vault/` + Type 2 `dns-adm` |
| **Uninstall** | **MUST NOT** delete the vault |
| **Proof family** | **TP-CF-VAULT-*** (v1 have; v2 todo) |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): 0700/0600; fail closed on `/tmp` `HOME`.  
- **CIAO Principle 2 – Intentional**: Token file split; vault wins over env.  
- **CIAO Principle 3 – Anti-fragile**: Atomic replace; `schema_version` fail-closed.  
- **CIAO Principle 11 – Temps**: Header `--config` lives in the vault dir, not scratch, and is unlinked.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: Never hang in JSON; collect only empty fields.  
- **CIAO Principle 17 – Defensive storage**: Do not assume `HOME` or XDG.  
- **CIAO Principle 22 – File modes**: Explicit 0700/0600.  
- **CIAO Principle 21 – Dual policies**: Portable MUST; filled notes; no secret values in this file.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Secrets never share the scratch resolver.  
- **Intentional**: One layout SSOT; domain law only consumes fields.  
- **Anti-fragile**: Missing `HOME` fails loud instead of writing `/tmp/.config`.  
- **Over-protect**: No argv token; no `.bak` of secrets; last host-label per domain-id cannot be removed; tokens stay per-account.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Merge the vault into `util_resolve_storage` or place secrets under `/dev/shm` / `/tmp`.  
2. Store the token inside `vault.json`.  
3. Echo the token or print it in about/JSON/debug.  
4. Put the token on `curl` argv.  
5. Use `util_backup` on secret files.  
6. Document host SSH vault paths in this product law.  
7. Let env override a present vault field (except explicit `vault set` / `account modify` / `zone modify`).  
8. Inherit `HOME=/tmp` for vault I/O.  
9. Remove the last host-label on a domain-id.  
10. Claim LPU default dest Implemented while `src/dns-cli` still resolves XDG when `dns-adm` is absent.  
11. Store two domains’ tokens in one `token` file.  
12. Treat domain-id as a UUID or integer distinct from the apex name.  
13. Key slot directories as `users/<user-id>/` instead of `accounts/<domain-id>/`.  
14. Omit `user_id` or let two domains share one `user_id` (breaks 1 : 1).  
15. Give one domain two tokens or two domains one token file.  
16. Treat a subdomain as its own account/zone slot.  
17. Invent one production vault per host login.  
18. Store a subdomain as a bare string (omit `mode`) or default a new label to `round-robin`.  
19. Switch `mode` when live `ipv4_count` ≥ 2, or rewrite `mode` from live N.  
20. Ship zone-slot add / modify / remove without a **list** JSON surface tests can assert.  
21. Implement `vault zone add` as Cloudflare `POST /zones` (API-M15). Local slot only.  
22. Omit `vault account modify` / `vault zone modify` and leave rewrite only on undocumented `set` flags.

**Violating this rule is a critical secrets-storage regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-V1 | Vault dir is not under `/dev/shm`, `/tmp`, or `util_resolve_storage` output; `env -u HOME` and `HOME=/tmp` fail `vault_no_home` |
| AC-V2 | `token` key/value is absent from `vault.json` |
| AC-V3 | `--json vault show` has no token value |
| AC-V4 | Mode `0644` on `token` or `--token-file` → fail closed `vault_insecure` |
| AC-V5 | Two host-labels persist **on one domain-id** and are selectable; removing the last remaining label on that id fails closed |
| AC-V6 | Two domain-ids persist with **distinct** tokens; selection N≠1 without `--domain` → `domain_required` |
| AC-V7 | v1 root `vault.json` + `token` → `vault_invalid` |
| AC-V8 | Stay-honest: v2 layout **Implemented** on `src/dns-cli` 1.4.0; LPU default dest still Gap |
| AC-V9 | Two slots **MAY** have different `account_id`; they **MUST** have distinct tokens and distinct `zone_id` |
| AC-V10 | Missing `user_id` or duplicate `user_id` across two domain-ids → `vault_invalid` / `vault_incomplete` |
| AC-V11 | Sample layout: two domain-ids, two user-ids, two tokens; one domain has ≥2 subdomain labels |
| AC-V12 | Each subdomain object has `label` + `mode`; new label defaults `non-round-robin`; `vault subdomain mode` / `modify --mode` follows `requirement-cloudflare-dns-mode` |
| AC-V13 | `vault account add` (or `vault zone add`) then `list`: new `domain_id` appears with `zone_id`, `user_id`, `account_id`, `token_present`, `subdomains` |
| AC-V14 | `vault account modify` / `vault zone modify --zone-id NEW` then `list`: that slot’s `zone_id` is NEW; other slots unchanged |
| AC-V15 | `vault account remove` / `vault zone remove --force` then `list`: that `domain_id` is absent |
| AC-V16 | `vault zone …` is an alias of `vault account …` (same slot, same JSON) |
| AC-V17 | `vault subdomain add` → `list` shows the label; `modify --mode` / `--label` → `list` shows the change; `remove` → `list` omits it |
| AC-V18 | List / add / modify / remove JSON never contain the token value |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-cloudflare-api` | What token / zone-id / account-id **mean** on the wire |
| `requirement-domain-cloudflare-dns` | Consumes **selected** account |
| `requirement-cloudflare-dns-mode` | Per-label `mode` meaning + switch gate |
| `requirement-application-local-vault` | Path + `--vault-dir` / `CF_VAULT_DIR` specify |
| `requirement-least-privilege-user` | Default dest owner `dns-adm` |
| `requirement-three-layer-privilege-model` | Type 2 default-vault vs Type 0 specify |
| `requirement-shell-cli-storage` | Scratch ≠ vault |
| `requirement-project-folder` | Pointer only (no second path SSOT) |
| `requirement-shell-interactive-vs-noninteractive` | Collect / clear confirm |
| `requirement-shell-output-requirements` | Redaction; `out_die_code` |
| `requirement-shell-modular-function-design` | `cf_vault_*` / `prompt_secret` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-VAULT-01** | `tests/test_cf_vault.sh` | have | dir 0700 / files 0600 |
| **TP-CF-VAULT-02** | `tests/test_cf_vault.sh` | have | `env -u HOME` and `HOME=/tmp` → `vault_no_home` |
| **TP-CF-VAULT-03** | `tests/test_cf_vault.sh` | have | token redacted in show/about JSON |
| **TP-CF-VAULT-04** | `tests/test_cf_vault.sh` | have | last-label remove fail-closed |
| **TP-CF-VAULT-05** | `tests/test_cf_vault.sh` | have | `--token-file` 0644 → `vault_insecure` |
| **TP-CF-VAULT-06** | `tests/test_cf_vault.sh` | have | token absent from `vault.json` |
| **TP-CF-VAULT-07** | `tests/test_cf_vault.sh` | have | `vault input --json` → `confirm_required` |
| **TP-CF-VAULT-08** | `tests/test_cf_vault.sh` | have | `vault subdomain add` + `list` |
| **TP-CF-VAULT-09** | `tests/test_cf_vault.sh` | have | `vault clear` needs `--force`; then files gone |
| **TP-CF-VAULT-10** | `tests/test_cf_vault.sh` | have | bad zone_id → `vault_invalid` |
| **TP-CF-VAULT-11** | `tests/test_cf_vault.sh` | have | `CF_*` env does not overwrite; `vault set --zone-id` rewrites |
| **TP-CF-VAULT-12** | `tests/test_cf_vault.sh` | have | `--token` argv rejected |
| **TP-CF-VAULT-13** | `tests/test_cf_vault.sh` | have | `XDG_CONFIG_HOME=/tmp` → `vault_insecure` |
| **TP-CF-VAULT-14** | `tests/test_cf_vault.sh` | have | uninstall does not delete vault |
| **TP-CF-VAULT-15** | `tests/test_cf_vault.sh` | have | vault.json 0644 → `vault_insecure` |
| **TP-CF-VAULT-16** | `tests/test_cf_vault.sh` | have | unknown schema_version → `vault_invalid` |
| **TP-CF-VAULT-17** | `tests/test_cf_vault.sh` | have | `vault subdomain add` path label → `vault_invalid` (v1 ship unit) |
| **TP-CF-VAULT-18** | `tests/test_cf_vault.sh` | have | two domain-ids + distinct tokens |
| **TP-CF-VAULT-19** | `tests/test_cf_vault.sh` | have | omit `--domain` when N≠1 and no default → `domain_required` |
| **TP-CF-VAULT-20** | `tests/test_cf_vault.sh` | have | `vault account add` duplicate → `domain_exists` |
| **TP-CF-VAULT-21** | `tests/test_cf_vault.sh` | have | v1 root layout → `vault_invalid` |
| **TP-CF-VAULT-22** | `tests/test_cf_vault.sh` | have | last subdomain remove still fail-closed **per domain-id** |
| **TP-CF-VAULT-23** | `tests/test_cf_vault.sh` | have | missing `user_id` → `vault_incomplete` / `vault_invalid` |
| **TP-CF-VAULT-25** | `tests/test_cf_vault.sh` | have | two domain-ids with same `user_id` → `vault_invalid` |
| **TP-CF-VAULT-24** | `tests/test_cf_vault.sh` | have | same `zone_id` on two domain-ids → `vault_invalid` |
| **TP-CF-VAULT-26** | `tests/test_cf_vault.sh` | have | `vault subdomain add` stores `mode=non-round-robin` |
| **TP-CF-VAULT-27** | `tests/test_cf_vault.sh` | have | bare-string `subdomains` → `vault_invalid` |
| **TP-CF-VAULT-28** | `tests/test_cf_vault.sh` | have | `account add` then `account list` shows slot fields (no token) |
| **TP-CF-VAULT-29** | `tests/test_cf_vault.sh` | have | `account modify --zone-id` then `list` shows new zone_id |
| **TP-CF-VAULT-30** | `tests/test_cf_vault.sh` | have | `account remove --force` then `list` omits domain-id |
| **TP-CF-VAULT-31** | `tests/test_cf_vault.sh` | have | `vault zone add\|list\|modify\|remove` aliases `vault account` |
| **TP-CF-VAULT-32** | `tests/test_cf_vault.sh` | have | `subdomain add` → `list` → `modify --label` → `list` → `remove` → `list` |
| **TP-CF-VAULT-33** | `tests/test_cf_vault.sh` | have | add/modify/remove/list JSON never include token value |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 2.4.0 | Zone-slot CRUD: `account`/`zone` add\|list\|modify\|remove; list JSON is the test surface |
| 2026-08-17 | Active 2.3.0 | Subdomain objects `{label, mode}`; default non-round-robin; `vault subdomain mode` |
| 2026-08-17 | Active 2.2.0 | 1:1 domain↔token↔user-id; 1:N subdomains; dns-adm holds many user-ids |
| 2026-08-17 | Active 2.1.0 | §2.0 model: one LPU vault; N zone slots; no CF user-id key |
| 2026-08-17 | Active 2.0.0 | Multi-account: domain-id = apex; per-account token; v2 layout |
| 2026-08-17 | Active 1.0.0 | DTV TP-CF-VAULT-08..17; set-flag rewrite; label-append fix |
| 2026-08-16 | Active 1.0.0 | Vault law registered for dns-cli; implementation Gap |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
