**file**: docs/requirements/requirement-cloudflare-dns-mode.md  
**Status**: Active (Version 1.0.0) — capability law; ship unit **Gap** (v1 still implicit non-round-robin)  
**Area**: domain  
**Key**: `requirement-cloudflare-dns-mode`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for **per-subdomain A-record mode**: the two modes, the default, the IPv4-only fence, and when a normal subdomain may switch mode.

`requirement-domain-cloudflare-dns.md` **consumes** this file for `add` / `update` / `remove` / `status` cardinality. A queued `mode` JSON request is owned by `requirement-cloudflare-dns-request` and **MUST** obey MODE-M7 / MODE-M8. `requirement-cloudflare-vault.md` **stores** the mode on each subdomain object. `requirement-cloudflare-api.md` **transports** type=A rows only. `requirement-external-ipv4.md` **supplies** IPv4 `content`. This file is **not** a second `requirement-domain-*` catalog, **not** vault layout, and **not** Cloudflare Load Balancing.

Terms: [`cloudflare-dns-mode`](../terminologies/cloudflare-dns-mode.md) · [`cloudflare-dns-non-round-robin-mode`](../terminologies/cloudflare-dns-non-round-robin-mode.md) · [`cloudflare-dns-round-robin-mode`](../terminologies/cloudflare-dns-round-robin-mode.md) · [`cloudflare-dns-mode-switch`](../terminologies/cloudflare-dns-mode-switch.md) · [`subdomain-ipv4-count`](../terminologies/subdomain-ipv4-count.md).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Two modes and default

**MODE-M1.** Every managed subdomain **MUST** have exactly one stored [Cloudflare DNS mode](../terminologies/cloudflare-dns-mode.md). Canonical values:

| Stored `mode` | Meaning |
|---------------|---------|
| `non-round-robin` | Default. One FQDN → **at most one** IPv4. |
| `round-robin` | One FQDN → **several** type=A rows with **distinct** IPv4s. |

**MUST NOT** invent a third mode. **MUST NOT** infer mode from live N. Input aliases (if accepted) **MUST** canonicalize to the two strings above.

**MODE-M2.** Default for a **new** subdomain **MUST** be `non-round-robin`. Missing `mode` on write **MUST** be stored as `non-round-robin`. A v1 ship unit with no mode field **MUST** be treated as implicit `non-round-robin` (stay-honest: that is today’s `1.1.0` behavior).

### 2.2 IPv4 only

**MODE-M3.** This product **MUST** handle **IPv4 / type=A only**. **MUST NOT**:

- create, update, or delete AAAA records  
- accept an IPv6 literal as `--ip` or as A `content`  
- add AAAA (or any non-A type) into [subdomain IPv4 count](../terminologies/subdomain-ipv4-count.md)  
- document IPv6 as a DNS target  

Peer: `requirement-external-ipv4` **IP-M9**. Lookup and override remain IPv4.

### 2.3 Subdomain IPv4 count

**MODE-M4.** `ipv4_count` **MUST** be the number of type=A records returned for that FQDN (`GET /zones/{zone_id}/dns_records?type=A&name={fqdn}`, pagination per API-M9). **MUST NOT** count AAAA, CNAME, TXT, MX, or resolver answers.

### 2.4 Non-round-robin mode

**MODE-M5.** In `non-round-robin`, the FQDN **MUST** map to a **single** IPv4: `ipv4_count` ∈ {0, 1}.

| Verb | Required behavior |
|------|-------------------|
| `add` | N=0 → create one A. N=1 same IP → success `already`. N=1 different IP → overwrite that A. N>1 → MODE-M8. Adding a **second distinct** IPv4 while still this mode **MUST** fail `dns_mode_locked` (operator **MUST** [switch](../terminologies/cloudflare-dns-mode-switch.md) first). |
| `update` | N=0 → `dns_missing`. N=1 → overwrite. N>1 → MODE-M8. |
| `remove` | Delete the one A (N=0 → success no-op). N>1 → MODE-M8. |
| `status` / `show` | Read-only. N>1 → `dns_multi_record` (or `dns_mode_mismatch`). **MUST NOT** mutate. |

### 2.5 Round-robin mode

**MODE-M6.** In `round-robin`, several type=A rows **MAY** share the FQDN. Each `content` **MUST** be a **distinct** validated public IPv4. Duplicate same IPv4 **MUST** be success `already` (no second row).

| Verb | Required behavior |
|------|-------------------|
| `add` | POST a new A for the target IP if absent; present → `already`. **MUST NOT** overwrite a different existing A. |
| `update` | N=0 → `dns_missing`. N=1 → overwrite that A. N>1 → require `--from OLD` (or equivalent) identifying which A to overwrite; else `dns_target_required`. |
| `remove` | N>1 without `--ip` → `ip_required`. With `--ip` → delete that A only. N=0 → success no-op. `remove --force` **MAY** delete **all** A for the FQDN (mode stays `round-robin`; count becomes 0). |
| `status` / `show` | Read-only. **MUST** succeed for N≥2 and list every A IPv4, `ipv4_count`, and stored `mode`. **MUST NOT** emit `dns_multi_record` solely because N>1. |

N∈{0, 1} while still stored as `round-robin` is a **reduced** set — **not** an automatic switch to non-round-robin.

### 2.6 Mode switch

**MODE-M7.** A [mode switch](../terminologies/cloudflare-dns-mode-switch.md) **MUST** be an **explicit** operator action (`vault subdomain mode <label> <mode>` or documented equivalent). **MUST NOT** happen as a side effect of `add` / `update` / `remove`.

**MODE-M8.** Switch **MUST** fail `dns_mode_locked` unless `ipv4_count` ∈ {0, 1}. A **normal** subdomain with two or more IPv4s **cannot** change mode. To leave round-robin when N≥2, first remove A rows until count is 0 or 1, **then** switch.

The switch **MUST** rewrite only the stored `mode`. **MUST NOT** create, delete, or overwrite DNS records.

**MODE-M9.** `--force` collapse (delete extra A rows until N=1 under **non-round-robin**) is **repair of drift**, **not** a mode switch. After collapse, mode **stays** `non-round-robin`. **MUST NOT** use `--force` to enter round-robin.

**MODE-M10.** Live N vs stored mode:

| Stored mode | Live `ipv4_count` | Action |
|-------------|-------------------|--------|
| `non-round-robin` | 0 or 1 | Proceed |
| `non-round-robin` | ≥ 2 | Fail `dns_multi_record` / `dns_mode_mismatch` on mutate unless `--force` collapse (MODE-M9). `status` fail-closed (no mutate). |
| `round-robin` | any | Proceed per MODE-M6 |

**MUST NOT** silently rewrite stored mode to match live N.

### 2.7 Storage and surface

**MODE-M11.** Mode **MUST** be stored per subdomain on the vault slot (`requirement-cloudflare-vault`). **MUST NOT** be a zone-wide or token-wide flag.

**MODE-M12.** Empty argv **MUST NOT** switch mode or query Cloudflare.

**MODE-M13.** User output via `out_*`. JSON for DNS verbs **SHOULD** include `mode` and `ipv4_count`. **MUST NOT** print the API token.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` **1.2.0** — stored mode **Implemented**; inbound `mode` JSON request **Gap** |
| **Default mode** | `non-round-robin` |
| **Store** | `accounts/<domain-id>/vault.json` subdomain objects (`label` + `mode`) |
| **Switch verb** | `vault subdomain mode <label> <mode>` |
| **IPv6 / AAAA** | Out of scope |
| **Proof** | **TP-CF-MODE-01..08** have; **06/09/10** todo |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Do not switch a live multi-A name; do not write AAAA.  
- **CIAO Principle 2 – Intentional**: Two named modes; switch is explicit.  
- **CIAO Principle 3 – Anti-fragile**: Idempotent `add` of an already-present IPv4.  
- **CIAO Principle 5 – SSOT of output**: `mode` / `ipv4_count` on JSON.  
- **CIAO Principle 21 – Dual policies**: Portable MUST; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Count is live A rows; mode is stored policy.  
- **Intentional:** Domain verbs consume this file; they do not re-specify the enum.  
- **Anti-fragile:** Switch does not mutate records; collapse is repair only.  
- **Over-protect:** IPv6 never enters the count or the wire.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Default a new subdomain to round-robin.  
2. Switch mode when `ipv4_count` ≥ 2.  
3. Treat `--force` collapse as a mode switch or as entering round-robin.  
4. Infer or rewrite stored mode from live N.  
5. Create, update, delete, or count AAAA / IPv6.  
6. Treat Cloudflare Load Balancing as this product’s round-robin.  
7. Fail `status` solely because N>1 when stored mode is `round-robin`.  
8. Register this file as `requirement-domain-*`.  
9. Claim mode Implemented while the ship unit has no stored `mode` and no `vault subdomain mode`.

**Violating this rule is a critical DNS-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-MODE1 | New subdomain stores `mode=non-round-robin` |
| AC-MODE2 | `add` of a second distinct IPv4 while non-round-robin exits `dns_mode_locked` |
| AC-MODE3 | `vault subdomain mode … round-robin` succeeds when `ipv4_count` is 0 or 1 |
| AC-MODE4 | After switch to round-robin, `add --ip` of a second distinct IPv4 creates a second A |
| AC-MODE5 | Switch when `ipv4_count` ≥ 2 exits `dns_mode_locked` |
| AC-MODE6 | Switch when count is 0 or 1 from round-robin → non-round-robin succeeds and does not delete the remaining A |
| AC-MODE7 | `--ip` IPv6 literal and any AAAA path fail closed; `ipv4_count` ignores AAAA |
| AC-MODE8 | `status` in round-robin with N=2 exits 0 and lists both IPv4s (not `dns_multi_record`) |
| AC-MODE9 | `add --force` under non-round-robin collapses to one A and leaves mode `non-round-robin` |
| AC-MODE10 | Empty argv does not switch mode or call Cloudflare |
| AC-MODE11 | Stay-honest: ship unit `1.1.0` remains implicit non-round-robin — **Gap** |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-cloudflare-dns` | Consumes this file for verb cardinality |
| `requirement-cloudflare-dns-request` | `mode` request-type; no IPv4 on that body |
| `requirement-cloudflare-vault` | Stores `mode` on each subdomain object |
| `requirement-cloudflare-api` | type=A CRUD only; no AAAA |
| `requirement-external-ipv4` | IPv4 `content` + IP-M9 |
| `requirement-shell-cli-interface` | `--mode` / `--from` argv grammar |
| `requirement-shell-idempotency` | Re-run of add/remove per mode |
| `requirement-shell-output-requirements` | `out_*` / `out_die_code` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-MODE-01** | `tests/test_cf_dns.sh` | todo | new label defaults `non-round-robin` |
| **TP-CF-MODE-02** | `tests/test_cf_dns.sh` | todo | second IP while non-RR → `dns_mode_locked` |
| **TP-CF-MODE-03** | `tests/test_cf_dns.sh` | todo | switch to RR when count=1 |
| **TP-CF-MODE-04** | `tests/test_cf_dns.sh` | todo | RR add second distinct IP |
| **TP-CF-MODE-05** | `tests/test_cf_dns.sh` | todo | switch when count=2 → `dns_mode_locked` |
| **TP-CF-MODE-06** | `tests/test_cf_dns.sh` | todo | RR → non-RR when count=0 or 1 |
| **TP-CF-MODE-07** | `tests/test_cf_dns.sh` | todo | IPv6 / AAAA rejected; not counted |
| **TP-CF-MODE-08** | `tests/test_cf_dns.sh` | todo | RR status N=2 succeeds |
| **TP-CF-MODE-09** | `tests/test_cf_dns.sh` | todo | `--force` collapse is not a switch |
| **TP-CF-MODE-10** | `tests/test_cf_dns.sh` | todo | empty argv does not switch |
| **TP-CF-DNS-03** | `tests/test_cf_dns.sh` | have | implicit non-RR N>1 → `dns_multi_record` (1.1.0) |
| **TP-CF-DNS-04** | `tests/test_cf_dns.sh` | have | `add --force` collapse (1.1.0) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.0.0 | Independent mode SSOT; default non-RR; switch only when ipv4_count ∈ {0,1}; IPv4 only |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
