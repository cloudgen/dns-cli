**file**: docs/requirements/requirement-cloudflare-dns-request.md  
**Status**: Active (Version 1.6.0) — dest-written `submit_by` after interactive format check  
**Area**: domain  
**Key**: `requirement-cloudflare-dns-request`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for **Cloudflare DNS request** JSON: how many types exist, the closed schema, and **complete examples** for each type (and its mode-specific variants). Dest review of those files is the **[cloudflare-dns-approval-system](../terminologies/cloudflare-dns-approval-system.md)** leaf.

There are **exactly four** [request-types](../terminologies/cloudflare-dns-request-type.md): `add`, `update`, `remove`, `mode`.

`requirement-domain-cloudflare-dns.md` **consumes** these bodies when a submit/approve surface exists. Approve **maps** to existing verbs (`add` / `update` / `remove` / `vault subdomain mode`) and **MUST** follow `requirement-cloudflare-dns-mode` + `requirement-cloudflare-api`. This file is **not** a second `requirement-domain-*`, **not** vault layout, and **not** zone create.

Terms: [`cloudflare-dns-request`](../terminologies/cloudflare-dns-request.md) · [`cloudflare-dns-request-type`](../terminologies/cloudflare-dns-request-type.md) · [`cloudflare-dns-request-basename`](../terminologies/cloudflare-dns-request-basename.md).

### 1.1 Human-facing

**In one sentence:** A waiting request is a **JSON file** with exactly one action — `add`, `update`, `remove`, or `mode` — and **no API token** in the file.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Write a self-scoped JSON and `submit` | `dns-cli submit ./req.json` |
| Approver | Re-checks the same schema | `dns-cli approve` |
| Not this | Who may approve | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Four actions + complete examples | A fifth action |
| Closed keys / IPv4 only | `token` key / IPv6 |

| Surface | What you open | What for |
|---------|---------------|----------|
| Inbound folder | `/var/dns-cli/dns-request` | Waiting files |
| This file §2.5 | Examples | Copy-paste bodies |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Queue a change | File must match these examples | `dns-cli submit ./home-add.json` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Four types (closed)

**REQ-M1.** Every inbound file **MUST** have `action` equal to exactly one of:

| `action` | What it proposes | Approve dest |
|----------|------------------|--------------|
| `add` | Create or append **one** IPv4 A for the FQDN | DNS `add` (POST or no-op `already`) |
| `update` | Overwrite **one** existing IPv4 A | DNS `update` (PUT; RR N>1 needs `from_ipv4`) |
| `remove` | Delete **one** IPv4 A (or the single A) | DNS `remove` (DELETE; RR N>1 needs `ipv4`) |
| `mode` | Switch stored A-record mode | `vault subdomain mode` — **no** DNS row mutate |

**MUST NOT** invent `status`, `show`, `ip`, `aaaa`, `cname`, `collapse`, `create-zone`, or `account-add` as a DNS request-type. Read-only verbs are not submissions. `--force` collapse is **repair**, not a type. `vault account add` is **store**, not a public DNS request.

**REQ-M2.** JSON `action` **MUST** equal the basename `type` field (`requirement` of [`cloudflare-dns-request-basename`](../terminologies/cloudflare-dns-request-basename.md)). Mismatch → `request_invalid`.

### 2.2 Envelope (every type)

**REQ-M3.** Body **MUST** be one JSON object. Required keys on **every** type:

| Field | Rule |
|-------|------|
| `schema_version` | integer `1` only |
| `purpose` | non-empty one-line reason |
| `subject` | submitting OS login (path-safe); self-scope = invoker |
| `action` | `add` \| `update` \| `remove` \| `mode` |
| `domain_id` | apex DNS name (vault slot key) |
| `subdomain` | LDH host-label or `@` |

**MUST NOT** include `token`, `CF_API_TOKEN`, `user_id` secrets, or any AAAA / IPv6 field. Unknown keys → `request_invalid`. Token stays in the vault.

**REQ-M3a.** Type 0 `submit` **MUST NOT** include `submit_by`. Dest login-hook `interactive`, while taking file-ownership, **MUST** read original Unix file-ownership, take ownership as `dns-adm`, review JSON format, and if the JSON is correct **MUST** add `submit_by` (human: submit by) set to that original owner. Dest **MUST NOT** add `submit_by` when format fails. Dest verify **MUST** treat dest-written `submit_by` as an allowed key, not unknown.

**REQ-M4.** IPv4 fields (`ipv4`, `from_ipv4`) **MUST** be dotted-quad public IPv4 per `requirement-external-ipv4` IP-M4. IPv6 literal → `ip_lookup_failed` / `request_invalid`.

**REQ-M5.** Optional keys allowed **only** where the type table says so: `ipv4`, `from_ipv4`, `mode`, `ttl`, `proxied`. `ttl` default **300**. `proxied` default **false**.

### 2.3 Per-type fields

| `action` | Required extra | Optional | Forbidden extra | Approve-time gate |
|----------|----------------|----------|-----------------|-------------------|
| `add` | `ipv4` | `ttl`, `proxied` | `from_ipv4`, `mode` | Stored mode: non-RR → ensure one A; RR → append if absent |
| `update` | `ipv4` | `from_ipv4`, `ttl`, `proxied` | `mode` | RR + `ipv4_count`>1 **MUST** have `from_ipv4`; else `dns_target_required` |
| `remove` | — | `ipv4` | `from_ipv4`, `mode`, `ttl`, `proxied` | RR + `ipv4_count`>1 **MUST** have `ipv4`; else `ip_required` |
| `mode` | `mode` (`non-round-robin` \| `round-robin`) | — | `ipv4`, `from_ipv4`, `ttl`, `proxied` | `ipv4_count` ∈ {0, 1}; else `dns_mode_locked`. Does **not** write A rows |

A `mode` request **MUST NOT** be used to add a second IPv4. Operator submits `mode` first (count 0 or 1), then a later `add`.

### 2.4 Basename

**REQ-M6.** Allocated name **MUST** be `{{YYYYMMDD}}-{{subject}}-{{action}}-{{n}}.json` (host local date; `n` over inbound+accepted+declined). Submitter **MUST NOT** supply `--name`.

### 2.5 Complete examples (normative shape)

Examples use fictional IDs and documentation IPv4s (`203.0.113.0/24`). **MUST NOT** copy live tokens.

#### Type `add` — non-round-robin (default; one IPv4)

Basename: `20260817-alice-add-1.json`

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

#### Type `add` — round-robin (append a distinct IPv4)

Stored mode on `api` is already `round-robin`. Basename: `20260817-alice-add-2.json`

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

#### Type `update` — non-round-robin (overwrite the single A)

Basename: `20260817-alice-update-1.json`

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

#### Type `update` — round-robin (which A, via `from_ipv4`)

Basename: `20260817-alice-update-2.json`

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

#### Type `remove` — non-round-robin (the one A)

Basename: `20260817-alice-remove-1.json`

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

#### Type `remove` — round-robin (delete one IPv4)

Basename: `20260817-alice-remove-2.json`

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

#### Type `mode` — enter round-robin (count must be 0 or 1)

Basename: `20260817-alice-mode-1.json`

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

#### Type `mode` — return to non-round-robin (count must be 0 or 1)

Basename: `20260817-alice-mode-2.json`

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

### 2.6 Verify (when submit/approve is implemented)

**REQ-M7.** Verify **MUST** fail closed on: unknown `action`; `action` ≠ basename type; missing required field; forbidden extra; invalid IPv4; IPv6; unknown key; `mode` value not the two canonical strings; token present; `schema_version` ≠ 1. Dest **MUST NOT** fail because the filename subject token ≠ JSON `subject` — user SSOT is JSON `subject`.

**REQ-M8.** Approve **MUST** re-run verify, then apply the dest in §2.1. **MUST NOT** `POST /zones`. Empty argv **MUST NOT** submit or approve.

**REQ-M9. Queue move assumes prior ownership change.** Type 0 `submit` **MUST NOT** `chown` inbound. `approve` / `reject` **MUST** take file-ownership as `dns-adm` **before** any inbound → accepted/declined move. Login-hook `interactive` (`dns-adm` via `sudo -n`) **MUST**, at the beginning, read original file-ownership, take ownership as `dns-adm`, review JSON format, and if correct add `submit_by` = that original owner, then **fence first** for the yes/no walk (this file-based JSON system **MUST** include incorrect JSON format). A fence match **MUST** be displayed in human-facing words; dest **MUST NOT** ask yes/no for that file. Queue move assumes that previous ownership change. Fail closed if that `chown` fails (CI stub `CF_TEST_LPU=1` **MAY** skip live `chown`). Peer: `requirement-dns-actor-table` ACT-M4 / ACT-M6 / ACT-M7.

**Dest approval fencing conditions (closed).** Dest `approve` / `reject` / `interactive` **MUST** fail closed on inbound **only** for **incorrect JSON format**. Dest **MUST NOT** add extra fencing conditions.

| Condition | Dest approve / reject / interactive |
|-----------|-------------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — take ownership as `dns-adm` |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON `subject` ≠ `dns-adm` | **MUST NOT** fence |
| Filename subject token ≠ JSON `subject` | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it after format check |

**Incorrect JSON format** includes: not a regular file; not one parseable JSON object; closed-schema fail (`schema_version` 1, unknown keys, missing required, forbidden keys including `token`); field types/enums invalid; basename not `YYYYMMDD-subject-action-n.json`; basename `action` ≠ JSON `action`. Dest **MUST NOT** take the user from the filename; user SSOT is JSON `subject`. Type 0 submit self-scope and Type 1 **authz** are **not** dest inbound-file fences. Peer: ACT-M8.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` **1.9.7** — dest interactive dest-writes `submit_by` after format check |
| **Types** | 4: `add` `update` `remove` `mode` |
| **Inbound** | `/var/dns-cli/dns-request` (public 3773); JSON only |
| **Proof** | **TP-CF-REQ-01..09** have |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Closed enum; no AAAA; no token in the file.  
- **CIAO Principle 2 – Intentional**: Four named types; complete examples.  
- **CIAO Principle 21 – Dual policies**: Portable MUST; filled examples.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Four types only.  
- **Intentional:** Examples are law, not comments.  
- **Over-protect:** Mode switch cannot smuggle an IPv4.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add a fifth DNS request-type without updating this file’s table **and** examples.  
2. Put a token or AAAA in a request example.  
3. Treat `status` / `ip` / `--force` collapse / `vault account add` as a request-type.  
4. Use a `mode` request to create or delete A rows.  
5. Register this file as `requirement-domain-*`.  
6. Claim request submit/approve Implemented while the ship unit has no inbound queue.  
7. Move inbound → accepted/declined **without** a prior `chown` to `dns-adm`.  
8. `chown` inbound DNS JSON from Type 0 `submit`.  
9. Add a dest inbound fence that is not **incorrect JSON format** (who submitted, dest Type 0 self-scope, JSON `subject` ≠ `dns-adm`).  
10. Start login-hook `interactive` review **without** first taking inbound file-ownership as `dns-adm`.

**Violating this rule is a critical request-schema regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-REQ1 | Verify accepts the eight complete examples in §2.5 (when implemented) |
| AC-REQ2 | Unknown `action` or `action` ≠ basename type → `request_invalid` |
| AC-REQ3 | `add` without `ipv4` → `request_invalid` |
| AC-REQ4 | RR `update` without `from_ipv4` when count>1 → `dns_target_required` |
| AC-REQ5 | RR `remove` without `ipv4` when count>1 → `ip_required` |
| AC-REQ6 | `mode` with `ipv4` present → `request_invalid` |
| AC-REQ7 | `mode` when `ipv4_count`≥2 → `dns_mode_locked` |
| AC-REQ8 | IPv6 in `ipv4` / `from_ipv4` → fail closed |
| AC-REQ9 | Stay-honest: inbound submit/approve **Implemented** on 1.9.0; queue-move `chown` on 1.9.1; login-hook take-ownership-at-beginning on 1.9.2 |
| AC-REQ10 | Approve/reject `chown` to `dns-adm` before move; login-hook `interactive` takes inbound ownership **at the beginning**; submit does not (REQ-M9) |
| AC-REQ11 | Dest approval fencing conditions closed: dest inbound fence is incorrect JSON format only (REQ-M9) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-cloudflare-dns` | Consumes types when submit/approve is routed |
| `requirement-dns-actor-table` | Who may submit / approve |
| `requirement-cloudflare-dns-mode` | Mode values + switch gate |
| `requirement-cloudflare-api` | Approve dest is type=A only |
| `requirement-cloudflare-vault` | `domain_id` + stored `mode` |
| `requirement-external-ipv4` | IPv4 validation |
| `requirement-shell-cli-interface` | Future submit/approve argv |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-REQ-01** | `tests/test_cf_dns.sh` | todo | parse/accept `add` non-RR example |
| **TP-CF-REQ-02** | `tests/test_cf_dns.sh` | todo | parse/accept `add` RR example |
| **TP-CF-REQ-03** | `tests/test_cf_dns.sh` | todo | parse/accept `update` + RR `from_ipv4` |
| **TP-CF-REQ-04** | `tests/test_cf_dns.sh` | todo | parse/accept `remove` variants |
| **TP-CF-REQ-05** | `tests/test_cf_dns.sh` | todo | parse/accept both `mode` examples |
| **TP-CF-REQ-06** | `tests/test_cf_dns.sh` | todo | unknown action / extra key fail |
| **TP-CF-REQ-07** | `tests/test_cf_dns.sh` | todo | IPv6 / token in body fail |
| **TP-CF-REQ-08** | `tests/test_cf_request.sh` | have | `mode` + ipv4 extra fail |
| **TP-CF-REQ-09** | `tests/test_cf_request.sh` | have | `cf_req_move` `chown`s to LPU before `mv`; skip in test mode |
| **TP-CF-REQ-10** | `tests/test_cf_request.sh` | have | REQ-M9 dest inbound fence is incorrect JSON format only |
| **TP-CF-REQ-11** | `tests/test_cf_request.sh` | have | login-hook `interactive` takes inbound ownership at the beginning |
| **TP-CF-REQ-14** | `tests/test_cf_request.sh` | have | user SSOT is JSON `subject`; dest MUST NOT fence on filename token |
| **TP-CF-REQ-15** | `tests/test_cf_request.sh` | have | interactive records original owner; dest-writes `submit_by` if format is clear |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.6.0 | REQ-M3a dest-written `submit_by` after interactive format check |
| 2026-08-19 | Active 1.5.0 | REQ-M9 user SSOT is JSON `subject`, not the filename token |
| 2026-08-19 | Active 1.4.0 | REQ-M9 login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-18 | Active 1.3.0 | REQ-M9 dest approval fencing conditions closed: incorrect JSON format only |
| 2026-08-18 | Active 1.2.0 | REQ-M9 queue move `chown`s to `dns-adm` first; submit MUST NOT (INC-20260818-003) |
| 2026-08-18 | Active 1.1.0 | submit / approve Implemented (1.9.0) |
| 2026-08-17 | Active 1.0.0 | Four request-types + eight complete JSON examples |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
