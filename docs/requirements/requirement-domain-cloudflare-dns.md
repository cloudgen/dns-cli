**file**: docs/requirements/requirement-domain-cloudflare-dns.md  
**Status**: Active (Version 2.6.0)  
**Area**: domain  
**Key**: `requirement-domain-cloudflare-dns`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **current domain SSOT** for dns-cli: specialized CLI subcommands, features, help items, and about items for managing Cloudflare DNS **A records** on a **vault-selected domain-id** and subdomain. **A-record mode** is owned by `requirement-cloudflare-dns-mode`. **Inbound JSON request types** (`add` / `update` / `remove` / `mode`) are owned by `requirement-cloudflare-dns-request`. This catalog **consumes** both. **Who** may submit or approve is `requirement-dns-actor-table`.

It **consumes** the **selected** account’s vault fields (API token, zone id, account id, apex domain, host-labels). One vault holds **many** Cloudflare API accounts; each **domain-id** (apex domain name) is one account and **MAY** hold many subdomains. Layout/schema live in `requirement-cloudflare-vault.md`. Default operator is LPU **`dns-adm`** (`requirement-least-privilege-user`).

This is the **only** Active `requirement-domain-*` file. `requirement-cloudflare-vault.md` is vault law, not a second domain catalog.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Named machine + actor table

**Folder = state. JSON = the checkable proposal.** **Anyone** (any login) may drop self-scoped request JSON into inbound; **`dns-adm`** re-checks that JSON and **moves** the file. Dest on accept is a DNS / mode apply via the vault — not a host `/etc` grant file.

The **actor table** (anyone submits; `dns-adm` approves; allocator / root) and the **login-hook procedure** are owned by `requirement-dns-actor-table`. This catalog **MUST NOT** invent a second table or a second approver account.

Submit-when, not-a-submit, verify-at-submit-and-approve, and the complete `.bashrc` snippet live in that file. Inbound / `submit` / `approve` / `reject` / `interactive` are **Implemented** on ship unit 1.9.0. Login-hook **rc heal** is **Implemented** (`requirement-dns-approver`). Help **MUST** list those verbs now that they are routed (D-M7).

### 2.1 Specialized CLI subcommands (pillar 1)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| `vault` | Type 2 (default vault) / Type 0 (specified `--vault-dir`) | `cf_vault_*` (routed here; **store semantics** in vault law) | Subcommands `input` (TTY wizard), `account`/`zone` `add\|list\|modify\|remove\|default\|show`, `set`/`init`, `show`, `clear`, `subdomain add\|list\|modify\|remove\|mode`. Bare `vault` → `input`. |
| `ip` | Type 0 | `cf_ip_*` | **Display public IPv4** (same lookup as D-M2). **MUST NOT** require vault or `dns-adm`. **MUST NOT** call Cloudflare or resolve the FQDN. QA/diagnostic only. |
| `add` | Type 2 / Type 0 specify | `cf_dns_*` | Ensure A record(s) per stored mode (`requirement-cloudflare-dns-mode`) |
| `update` | Type 2 / Type 0 specify | `cf_dns_*` | Change an existing A; fail if none exists (round-robin N>1 needs `--from`) |
| `remove` | Type 2 / Type 0 specify | `cf_dns_*` | Delete the targeted A; absent → success no-op (round-robin N>1 needs `--ip`) |
| `status` | Type 2 / Type 0 specify | `cf_dns_*` | **Read-only**: public IPv4 + **real resolver A lookup** + Cloudflare A set + `mode` / `ipv4_count` |
| `show` | Type 2 / Type 0 specify | `cf_dns_*` | Alias of `status` |
| `submit` | Type 0 | Implemented | Drop request JSON into inbound (`requirement-dns-actor-table`) |
| `approve` / `reject` | Type 1 | Implemented | Re-validate and move inbound → accepted/declined |
| `interactive` | Type 1 | Implemented | TTY review loop; login hook target |

### 2.1a Sample invocations (CI-M1a)

Documentation IPv4s only (`203.0.113.0/24`). Specify-vault samples stay Type 0.

```sh
dns-cli vault
dns-cli ip
dns-cli --json ip
dns-cli ip --ip 203.0.113.10
dns-cli add
dns-cli add --ip 203.0.113.10
dns-cli add --subdomain home --ip 203.0.113.10
dns-cli add --domain example.com --subdomain home --ip 203.0.113.10
dns-cli --vault-dir /home/alice/.config/dns-cli/vault add --ip 203.0.113.10
dns-cli update
dns-cli update --ip 203.0.113.20
dns-cli update --from 203.0.113.10 --ip 203.0.113.20
dns-cli remove
dns-cli remove --ip 203.0.113.10
dns-cli status
dns-cli --json status
dns-cli show
dns-cli --json show
dns-cli submit
dns-cli approve
dns-cli reject
dns-cli interactive
```

`submit` / `approve` / `reject` / `interactive` are **Implemented** (1.9.0). They are **not** `submit-sudoer-request`. Help **MUST** list them now that `app_main` routes them.

**D-M1.** Default-vault DNS/vault verbs **MUST** run as `dns-adm` (Type 2). Specified `--vault-dir` **MAY** stay Type 0. **MUST NOT** require sudo for Cloudflare HTTPS itself, write `/etc` from DNS verbs, or mutate host resolver config. `setup` / `remove-lpu` are **not** domain verbs (privilege law).

**D-M8.** **Domain-id** then **subdomain** selection. Domain-id: `--domain` / `--domain-id` / operand if given; else vault default; else unique account; else `domain_required`. Subdomain: operand or `--subdomain` if given; if omitted and the **selected** account has exactly one host-label, use that label; if omitted and N≠1 labels → `subdomain_required`. FQDN is **derived** (never stored): `@` → apex; otherwise `<label>.<apex>`.

**D-M10.** Default automated tests (`./tests/run.sh`) **MUST NOT** call live Cloudflare or ipinfo. Network fixtures only.

**D-M15. Live operator verify (Type 0 specify).** A temporary real-zone check (this workspace: apex `crms.hk`) **MUST** run as the **invoking login** (`id -un`) with `--vault-dir` / `CF_VAULT_DIR`. **MUST NOT** require `dns-adm` or Type 2. **MUST NOT** use the default LPU dest. The specify dir **MUST** be gitignored and **MUST NOT** be under `/tmp` or `/dev/shm`.

**D-M16. Probe + teardown.** Live mutate **MUST** use a dedicated host-label (default `dns-cli-tmp`), **not** `@` or `www`. After the session the operator **MUST**: delete the probe A, `vault account remove` that domain-id, remove the specify dir, and **revoke** the temporary API token in the Cloudflare dashboard. The product **MUST NOT** keep the token after teardown. Default suite **MUST NOT** run D-M15/D-M16.

### 2.2 Specialized features (pillar 2)

**D-M2. Public IPv4.** Lookup, validation, `--ip` override, fail codes, temps, and the vault-free `ip` display verb are owned by `requirement-external-ipv4`. This domain SSOT **consumes** that helper: `add` / `update` / `status` **MUST** call the same `cf_ip_lookup`. **MUST NOT** duplicate a second echo URL here.

**D-M3. Cloudflare DNS API.** Transport, auth, envelope, zone GET, and DNS CRUD **MUST** follow `requirement-cloudflare-api`. This domain SSOT **consumes** that file: it does **not** invent a second base URL, auth scheme, or record JSON.

**D-M14. DNS request JSON.** When a submit/approve surface is routed, inbound bodies **MUST** follow `requirement-cloudflare-dns-request` (exactly four types; complete examples there). This catalog **MUST NOT** invent a fifth type. Actors and the login hook **MUST** follow `requirement-dns-actor-table`. Submit/approve/`interactive` are **Implemented** on 1.9.0. Rc heal is **Implemented**.

**D-M4. A-record mode.** Verb **cardinality** **MUST** follow `requirement-cloudflare-dns-mode` (default `non-round-robin`; `round-robin` = many distinct IPv4 A rows; switch only when `ipv4_count` ∈ {0, 1}; IPv4 only). This catalog **MUST NOT** re-specify the enum. Query matching A records by `name`.  
- Stored `non-round-robin` + N>1 on mutate: fail `dns_multi_record` unless `--force` **repairs** (collapse to one A; mode stays non-round-robin).  
- Stored `round-robin` + N>1: `status` **succeeds**; `add` appends a distinct IP; `remove` / `update` need `--ip` / `--from`.  
- `status` / `show` are **read-only**. `--force` is **ignored** on status.

**D-M5. `add` ensure.** Per stored mode (`requirement-cloudflare-dns-mode` MODE-M5 / MODE-M6). Implicit v1 (no stored mode) = `non-round-robin`: N=0 → create; N=1 same IP → `already`; N=1 different IP → update in place; N>1 → D-M4.

**D-M6.** Fail closed on curl failure, non-2xx, malformed JSON, or Cloudflare envelope `success` not true.

**D-M9.** All user output via `out_*`. Success via `out_json` (`type` first; `@` prefix for raw JSON numbers/bools/arrays). Errors via `out_die_code CODE MESSAGE` (see `requirement-shell-output-requirements`).

**D-M11.** Every networked DNS command **MUST** `GET /zones/:zone_id` and compare `result.account.id` to vault `account_id` **and** `result.name` to vault apex `domain`. Mismatch → `zone_mismatch`. A DNS Write / Edit zone DNS token **MAY** perform this GET.

**D-M12.** JSON extract **MUST** use `python3` or `jq`. If neither is present → `json_tool_missing`.

**D-S2 (SHOULD).** `--ttl` and `--proxied` **MAY** be documented escapes; default proxied remains false.

**D-S3 (SHOULD).** Human `status` **SHOULD** show public IP, **resolver A**, Cloudflare API A set, stored `mode`, `ipv4_count`, ttl, proxied, and record id(s) (never token).

**D-M13.** `status` / `show` **MUST** perform a real DNS A lookup of the derived FQDN via the system resolver (`getent ahostsv4`, else `dig`, else `host`, else `nslookup`). Tests **MAY** set `CF_TEST_RESOLVE_IP` instead of public DNS. Missing/NXDOMAIN **MUST** be reported as empty `resolved_ip` (not a crash). `in_sync` is true only when resolver A equals public IP.

**Non-goals:** AAAA / IPv6, CNAME, TXT, MX; orange-cloud as default; online install; host `/etc` DNS; Cloudflare Load Balancing. **Multi-account / multi-domain-id is in scope** (vault law). **A-record mode** is in scope (`requirement-cloudflare-dns-mode`). Each domain-id is **one** Cloudflare zone; the product does **not** store two zones under one domain-id.

### 2.3 Specialized project help items (pillar 3)

**D-M7.** Human `help` **MUST** list every **routed** domain verb plus Type 0 lifecycle. **MUST NOT** list a domain verb that `app_main` does not route. **MUST NOT** list backup, restore, or sudoers-manager extras. `setup` / `remove-lpu` / `print-sudoers` / `generate-sudoer-request` / `submit-sudoer-request` **MUST** appear only when routed. Those sudoer verbs are privilege/submitter law — not a fifth DNS request-type.

Staging honesty (implementation):

| Stage | Help **MUST** list | Help **MUST NOT** list |
|-------|--------------------|------------------------|
| Vault implemented, DNS not yet routed | `vault` (+ subcommands) + Type 0 | `add` / `update` / `remove` / `status` / `show` |
| DNS routed | `vault`, `ip`, `add`, `update`, `remove`, `status`/`show` + Type 0 | unrouted extras |

Help **SHOULD** mention `--ip`, `--domain` / `--domain-id`, `--subdomain`, `--mode` / `vault subdomain mode`, `--from` (round-robin `update`), `--force` (non-round-robin **repair** only, not a mode switch), verb `ip` (public IPv4, no vault), `vault account` / `vault zone` (`add`/`list`/`modify`/`remove` of a zone API binding), default **non-round-robin**, and that empty argv is Type N help (no Cloudflare / ipinfo call).

### 2.4 Specialized project about items (pillar 4)

`about` **MUST** keep Type 0 diagnostics and **MUST** add domain fields:

| Field (human + JSON) | Rule |
|----------------------|------|
| `vault_dir` | Resolved vault directory or honest absent |
| `lpu_user` | `dns-adm` (constant) |
| `lpu_present` | boolean — `id dns-adm` / passwd probe; **not** a live create |
| `token_present` | boolean for the **selected** account — never the token value |
| `domain_count` | integer — number of domain-ids |
| `domain` / `default_domain_id` | selected or default apex; **not** secrets |
| `zone_id_set` / `account_id_set` / `user_id_set` | present/absent for the selected account (`user_id` is not a secret) |
| `subdomain_count` | integer for the selected account |

**MUST NOT** print the API token, `--config` header file contents, or `CF_API_TOKEN`.

### 2.5 Stable error codes

| Code | When |
|------|------|
| `vault_incomplete` | Required vault field missing after merge |
| `vault_no_home` / `vault_insecure` / `vault_invalid` | Vault resolver / mode / schema (owned with vault law) |
| `lpu_missing` / `lpu_required` | Default vault but `dns-adm` absent / context-switch failed |
| `domain_required` | Account selection N≠1 and no `--domain` |
| `domain_exists` | `vault account add` of an existing domain-id |
| `subdomain_required` | Selection N≠1 and no operand |
| `ip_lookup_failed` | ipinfo failure, 429, or invalid IPv4 |
| `json_tool_missing` | Neither `python3` nor `jq` |
| `zone_mismatch` | Zone GET account id or name disagrees with vault |
| `dns_multi_record` | Non-round-robin (or implicit v1) and more than one A (and not a permitted collapse) |
| `dns_mode_locked` | Mode switch when `ipv4_count` ≥ 2, or second distinct IP while non-round-robin |
| `dns_mode_mismatch` | Stored mode vs live A-count illegal (peer of `dns_multi_record`) |
| `dns_target_required` | Round-robin `update` when N>1 and no `--from` |
| `ip_required` | Round-robin `remove` when N>1 and no `--ip` |
| `dns_missing` | `update` when N=0 |
| `dns_api_failed` | Cloudflare HTTP/JSON/`success` failure |
| `confirm_required` | Destructive confirm required (vault clear; see interactive REQ) |

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Target ship unit** | `src/dns-cli` |
| **Live ship unit** | `src/dns-cli` — Implemented |
| **Domain code** | v2 domain-id selection + mode Implemented (`cf_dns_*` / `cf_ip_*` / `cf_api_*` / `cf_vault_*`). Type 2 as `dns-adm` **Implemented** 1.8.2 |
| **API** | `https://api.cloudflare.com/client/v4/zones/:zone_id/dns_records` |
| **IP lookup** | `https://ipinfo.io` field `ip` (`--ip` override; `CF_CURL` stub for tests) |
| **Record type** | A only (IPv4). AAAA out of scope |
| **A-record mode** | `requirement-cloudflare-dns-mode` — default non-round-robin; stored mode **Implemented** on 1.4.0 (inbound `mode` JSON still Gap) |
| **VERSION** | `1.4.0` (ship unit; LPU dest + inbound machine still Gap; rc heal Implemented) |
| **Proof family** | **TP-CF-DNS-*** |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Fail closed on illegal multi-A (non-round-robin), bad IP, and API errors.  
- **CIAO Principle 2 – Intentional**: `add` vs `update` vs `remove` vs read-only `status` are distinct.  
- **CIAO Principle 3 – Anti-fragile**: Idempotent `add` / `remove`.  
- **CIAO Principle 5 – Single Source of Output**: `out_*` / `out_die_code` only.  
- **CIAO Principle 9 – Command types**: Domain remains Type 0.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang under `--json`.  
- **CIAO Principle 21 – Dual policies**: Portable MUST table; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Default one A per name; never “update the first” of a multi-A set; never switch mode when `ipv4_count` ≥ 2.  
- **Intentional**: Domain catalog lives here, not duplicated in Type 0 interface.  
- **Anti-fragile**: `--ip` for offline tests; fixtures not live SaaS.  
- **Over-protect**: Token never on argv, never in about/JSON.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Print API tokens in about, logs, debug, default JSON, help, or tests.  
2. Put the token on `curl` argv (including `-H "Authorization: Bearer …"`).  
3. Treat multi-A as “update the first” without `--force` (non-round-robin) or `--from` (round-robin).  
4. Mutate DNS from `status` / `show`.  
5. Add AAAA/CNAME/TXT as silent extras, or count AAAA as `ipv4_count`.  
6. Switch mode when `ipv4_count` ≥ 2, or treat `--force` as a mode switch.  
7. Move the DNS verb catalog into Type 0 interface as a second SSOT.  
8. Call Cloudflare or ipinfo when argv is empty.  
9. Register a second Active `requirement-domain-*` file.  
10. Claim domain Implemented while the ship unit has no `cf_dns_*` routes.  
11. Call live Cloudflare from `./tests/run.sh`.  
12. Require `dns-adm` for `--vault-dir` live verify, or leave a temp token in a tracked path.

**Violating this rule is a critical domain-law regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-D1 | When DNS is routed, help lists vault / ip / add / update / remove / status / show and Type 0 lifecycle; `setup` / `remove-lpu` / `print-sudoers` / `generate-sudoer-request` / `submit-sudoer-request` only when those routes exist |
| AC-D12 | §2.1a holds a complete `dns-cli …` sample for every domain verb in §2.1 (CI-M1a) |
| AC-D7 | `ip` prints public IPv4 without vault or Cloudflare; `--ip` override and disallowed IPv4 fail as `ip_lookup_failed` |
| AC-D2 | `--json add` with fixture of one A + same IP exits 0 with status `already` |
| AC-D3 | Implicit / stored non-round-robin + two A records: `add` without `--force` and `status` (with or without `--force`) exit non-zero `dns_multi_record` (`out_json_error` `code` field) |
| AC-D9 | Mode switch and second-IP rules follow `requirement-cloudflare-dns-mode` (when implemented) |
| AC-D4 | About JSON has `vault_dir` and `token_present` and never the raw token |
| AC-D5 | Empty argv still help; does not call Cloudflare or ipinfo |
| AC-D6 | Identity `src/dns-cli` and v1 DNS routes Implemented (2026-08-16) |
| AC-D8 | Two vault accounts: `add` without `--domain` exits `domain_required` (when v2 implemented) |
| AC-D10 | `./tests/run.sh` does not call live Cloudflare or ipinfo |
| AC-D11 | With specify + token file, invoking user (not `dns-adm`) can `status` / probe `add` / `remove` for the live apex; teardown removes the slot |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-cloudflare-dns-mode` | Two A-record modes, default, switch gate, IPv4-only fence |
| `requirement-cloudflare-dns-request` | Four inbound JSON types + examples |
| `requirement-dns-actor-table` | Actor table + login-hook procedure |
| `requirement-external-ipv4` | Public IPv4 lookup + `ip` display SSOT |
| `requirement-cloudflare-api` | HTTPS transport, Bearer token, envelope, zone GET, DNS CRUD |
| `requirement-cloudflare-vault` | Multi-account fields, modes, token transport file |
| `requirement-least-privilege-user` | Default operator `dns-adm` |
| `requirement-three-layer-privilege-model` | Type 2 vs specify Type 0 |
| `requirement-shell-cli-interface` | Dispatch pointer + argv grammar |
| `requirement-shell-interactive-vs-noninteractive` | Collect / confirm matrix |
| `requirement-shell-idempotency` | `add` / `update` / `remove` re-run |
| `requirement-shell-output-requirements` | `out_*` / `out_die_code` |
| `requirement-shell-modular-function-design` | `cf_*` prefix |
| `requirement-class-software-dev` | Residual `curl` + `python3`/`jq` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-DNS-01** | `tests/test_cf_dns.sh` | have | add no-op same IP |
| **TP-CF-DNS-02** | `tests/test_cf_dns.sh` | have | add-implies-update different IP |
| **TP-CF-DNS-03** | `tests/test_cf_dns.sh` | have | implicit non-RR N>1 fail `dns_multi_record`; `status --force` still fail |
| **TP-CF-DNS-04** | `tests/test_cf_dns.sh` | have | `add --force` collapse (repair, not switch) |
| **TP-CF-MODE-01..10** | `tests/test_cf_dns.sh` | todo | Owned by `requirement-cloudflare-dns-mode` |
| **TP-CF-DNS-05** | `tests/test_cf_dns.sh` | have | empty argv does not network |
| **TP-CF-DNS-06** | `tests/test_cf_dns.sh` | have | `--ip` override; reject 127/8 |
| **TP-CF-DNS-07** | `tests/test_cf_dns.sh` | have | status `resolved_ip` + `in_sync` from resolver (stub) |
| **TP-CF-IP-*** | `tests/test_cf_ip.sh` | have | Owned by `requirement-external-ipv4` |
| **TP-CLI-07** | `tests/test_cli.sh` | have | Type N empty argv (peer) |
| **TP-CF-DNS-08** | `tests/test_cf_dns.sh` | todo | two domain-ids → `domain_required` without `--domain` |
| **TP-CF-LIVE-01..05** | `tests/test_cf_live.sh` | skip | Live `crms.hk` as invoking user; off unless `CF_LIVE=1` |
| **TP-CF-ACTOR-01..06** | `tests/test_cli.sh` | have | Unrouted submit/approve/reject/interactive fail closed |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-18 | Active 2.6.0 | CI-M1a sample invocations for every domain verb (§2.1a) |
| 2026-08-17 | Active 2.5.0 | Consumes `requirement-dns-actor-table` (named machine + login hook) |
| 2026-08-17 | Active 2.4.0 | Live Type 0 specify verify as invoking user (`crms.hk`); not dns-adm-only |
| 2026-08-17 | Active 2.3.0 | Consumes `requirement-cloudflare-dns-request` (four types) |
| 2026-08-17 | Active 2.2.0 | Vault catalog: `account`/`zone` add\|list\|modify\|remove; `subdomain modify` |
| 2026-08-17 | Active 2.1.0 | Consumes `requirement-cloudflare-dns-mode` (default non-RR; RR multi-A; switch only when ipv4_count ∈ {0,1}) |
| 2026-08-17 | Active 2.0.0 | Multi-account domain-id selection; Type 2 as `dns-adm` |
| 2026-08-17 | Active 1.1.0 | Verb `ip` — vault-free public IPv4 display for QA |
| 2026-08-16 | Active 1.0.0 | Domain SSOT registered for dns-cli; implementation Gap |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
