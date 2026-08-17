**file**: docs/requirements/requirement-cloudflare-api.md  
**Status**: Active (Version 1.2.0) — capability law; subset **Implemented** on `src/dns-cli`  
**Area**: domain  
**Key**: `requirement-cloudflare-api`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for how dns-cli **talks to the Cloudflare HTTPS API**: base URL, authentication scheme, response envelope, zone identity check, and DNS-record CRUD.

`requirement-domain-cloudflare-dns.md` **consumes** these calls as the dest for `add` / `update` / `remove` / `status`. `requirement-cloudflare-vault.md` **supplies** token, zone id, and account id. This file is **not** a second `requirement-domain-*` catalog, **not** vault layout, and **not** public-IPv4 lookup.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Transport

**API-M1.** Base URL **MUST** be `https://api.cloudflare.com/client/v4`. **MUST NOT** invent a second host or a v1 path.

**API-M2.** Client **MUST** be `curl` (or `CF_CURL` in tests). JSON extract **MUST** use `python3` or `jq`; neither present → `json_tool_missing`.

**API-M3.** Token transport **MUST** follow vault V-M14: `0600` `curl --config` inside the vault dir; **MUST NOT** put the token on argv (including `-H "Authorization: Bearer …"`).

### 2.2 Authentication

**API-M4.** Authenticate **only** with a **scoped API token**:

```http
Authorization: Bearer <token>
```

**MUST NOT** use Global API key headers (`X-Auth-Email` / `X-Auth-Key`).

**API-M5.** Recommended token permission: **Zone → DNS → Edit** (CRUDL) bound to **that** zone. A token scoped to another zone **MUST** fail closed (`dns_api_failed` / `zone_mismatch`). **Edit zone DNS** **MAY** `GET /zones/:zone_id` (API-M10).

**API-M6.** **MUST NOT** print, log, or JSON-emit the token. **MUST NOT** persist it in `vault.json` or request files.

### 2.3 Envelope

**API-M7.** Every parsed body **MUST** be treated as the Cloudflare envelope: `success`, `errors`, `messages`, `result`, optional `result_info`.

| Condition | Product action |
|-----------|----------------|
| curl fail / timeout | `dns_api_failed` |
| HTTP not 2xx | `dns_api_failed` |
| Body not JSON | `dns_api_failed` |
| `success` missing or not true | `dns_api_failed` (even if HTTP 200) |

**API-M8.** List `result` is an **array**. Single-resource `result` is an **object**. **MUST NOT** assume the other.

**API-M9.** List calls **MUST** honor pagination (`result_info.page` / `total_pages`) or document a safe `per_page` that is re-fetched until complete when counting records for one FQDN. **MUST NOT** treat a single page as “all records in the zone” when deciding N for a name.

### 2.4 Zone identity

**API-M10.** Every networked DNS command **MUST** first:

```http
GET /zones/{zone_id}
```

Compare `result.account.id` to vault `account_id` **and** `result.name` to vault apex `domain` (domain-id). Mismatch → `zone_mismatch`. **MUST NOT** skip this GET.

`zone_id` **MUST** be 32-hex (`^[0-9a-f]{32}$`). Apex **MUST NOT** be substituted for `zone_id` in the path.

### 2.5 DNS record CRUD (product subset)

**API-M11.** Dest family **MUST** be only:

| Job | Method | Path |
|-----|--------|------|
| List / find | `GET` | `/zones/{zone_id}/dns_records?type=A&name={fqdn}` |
| Create | `POST` | `/zones/{zone_id}/dns_records` |
| Overwrite | `PUT` | `/zones/{zone_id}/dns_records/{record_id}` |
| Delete | `DELETE` | `/zones/{zone_id}/dns_records/{record_id}` |

**MUST NOT** use `PATCH` for overwrite. **MUST NOT** call Workers, R2, Tunnel, WAF, or `/accounts/…` dests.

**API-M12.** `{fqdn}` **MUST** be the full name (apex, or `<label>.<apex>`). `{record_id}` **MUST** come from list or create `result.id` — **MUST NOT** be invented.

**API-M13.** Create / overwrite JSON for this product **MUST** be an **IPv4 A** record (**MUST NOT** be AAAA):

| Field | Rule |
|-------|------|
| `type` | `"A"` |
| `name` | full FQDN |
| `content` | validated public IPv4 (external-IPv4 law) |
| `ttl` | default **300** (not `1` unless product later documents automatic) |
| `proxied` | default **false** |

**API-M14.** A **MUST NOT** be created on a name that already has a CNAME (API rejects; product fail-closed). Several A records on one name **MAY** exist at Cloudflare; **cardinality / mode policy** is owned by `requirement-cloudflare-dns-mode` (default non-round-robin; round-robin = many distinct IPv4 A rows). **MUST NOT** create, update, delete, or list-as-target any AAAA / IPv6 record. List filters for product decisions **MUST** use `type=A` only.

### 2.6 Out of scope on the wire

**API-M15.** **MUST NOT** create/delete zones, change nameservers, or manage accounts as required production paths. `vault zone add` / `vault account add` are **local slot** writes (`requirement-cloudflare-vault` V-M18) — **MUST NOT** map them to `POST /zones`. `/user/tokens/verify` is optional diagnostic only. Vault **MUST** store `user_id` **1 : 1** with domain-id (`requirement-cloudflare-vault` §2.0). **MUST NOT** treat `user_id` as `account_id` or as the slot directory name.

**API-M16.** Empty argv **MUST NOT** call the API.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` — `cf_api_curl`, `cf_dns_*` |
| **Auth** | Bearer token via vault `token` + `--config` |
| **Zone GET** | Implemented |
| **DNS GET/POST/PUT/DELETE** | Implemented (v1 single account) |
| **Pagination** | List filtered by `name` + `type=A` (one FQDN); stay-honest: multi-page same name is rare; **SHOULD** still loop if `total_pages` > 1 |
| **Global API key** | Absent |
| **Cloudflare user-id** | Stored in vault as `user_id` — 1 : 1 with domain-id |
| **Proof** | **TP-CF-DNS-*** (have); **TP-CF-API-01..03** (todo — envelope / key rejected / pagination) |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Envelope `success` and zone mismatch fail closed.  
- **CIAO Principle 2 – Intentional**: Token only; PUT not PATCH; A only.  
- **CIAO Principle 5 – SSOT of output**: Vendor envelope ≠ CLI `--json`.  
- **CIAO Principle 10 – Least privilege**: Zone-scoped token; no Global key.  
- **CIAO Principle 21 – Dual policies**: Portable MUST; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not treat HTTP 200 as success.  
- **Intentional:** Domain verbs consume this file; they do not re-specify URLs.  
- **Anti-fragile:** `CF_CURL` stub; no live SaaS in default tests.  
- **Over-protect:** Token never on argv; `user_id` is not `account_id`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Switch to `X-Auth-Email` + Global API key.  
2. Put the token on `curl` argv.  
3. Skip `GET /zones/:zone_id` before DNS mutate/status.  
4. Create or count AAAA / IPv6 as if they were A / `ipv4_count`.  
5. Use PATCH when replacing a known record.  
6. Put apex name in the `{zone_id}` path segment.  
7. Store Cloudflare user-id as if it were `account_id`, or omit `user_id` from a zone slot.  
8. Register this file as `requirement-domain-*`.  
9. Call undocumented `/accounts/…` dests “because the API can.”  
10. Claim API Implemented while `cf_api_curl` is absent.

**Violating this rule is a critical API-law regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-API1 | Networked DNS uses only `/client/v4/zones/…` paths above |
| AC-API2 | Auth is Bearer via `--config`; `--token` argv rejected (peer vault) |
| AC-API3 | `success` false → `dns_api_failed` |
| AC-API4 | Zone GET account id or name mismatch → `zone_mismatch` |
| AC-API5 | Overwrite uses PUT + record id from list/create |
| AC-API6 | Empty argv does not call Cloudflare |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-cloudflare-dns` | Consumes these calls |
| `requirement-cloudflare-dns-mode` | Owns A-record cardinality / mode (not this file) |
| `requirement-cloudflare-vault` | Token, zone id, account id |
| `requirement-application-local-vault` | Vault path for `--config` file |
| `requirement-external-ipv4` | A `content` source |
| `requirement-shell-output-requirements` | `out_die_code` |
| `requirement-class-software-dev` | `curl` + `python3`/`jq` residual |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-DNS-01..07** | `tests/test_cf_dns.sh` | have | CRUD via stub; consumes this law |
| **TP-CF-API-01** | `tests/test_cf_dns.sh` | todo | envelope `success` false → `dns_api_failed` |
| **TP-CF-API-02** | `tests/test_cf_vault.sh` | have | `--token` argv rejected (peer) |
| **TP-CF-API-03** | `tests/test_cf_dns.sh` | todo | `total_pages` > 1 still counts all A for the name |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.2.0 | `vault zone add` is local slot only — not `POST /zones` |
| 2026-08-17 | Active 1.1.0 | Cardinality owned by `requirement-cloudflare-dns-mode`; AAAA forbidden |
| 2026-08-17 | Active 1.0.0 | API capability SSOT; token/envelope/zone/DNS subset |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
