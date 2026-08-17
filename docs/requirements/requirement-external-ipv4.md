**file**: docs/requirements/requirement-external-ipv4.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-external-ipv4`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for **external (public) IPv4**: how dns-cli obtains, validates, overrides, and **displays** the address used as the A-record target.

`requirement-domain-cloudflare-dns.md` **consumes** this lookup for `add` / `update` / `status`. This file is **not** a second `requirement-domain-*` catalog and **not** vault law.

---

## 2. Core Rules / Requirements (Mandatory)

**IP-M1.** A single helper (`cf_ip_lookup`) **MUST** resolve the public IPv4. `add`, `update`, `status`/`show`, and `ip` **MUST** call it. **MUST NOT** open a second HTTPS echo path.

**IP-M2.** Unless `--ip` is given, resolve via HTTPS `GET https://ipinfo.io` JSON field `ip`. **MUST NOT** invent another echo host.

**IP-M3.** `--ip V4` **MUST** skip the network, validate the operand, and set source `override`.

**IP-M4.** Accept only dotted-quad IPv4. **MUST** reject `127.0.0.0/8`, `0.0.0.0`, `255.255.255.255`, multicast (`224.0.0.0/4`), and link-local (`169.254.0.0/16`).

**IP-M5.** HTTP not 200, HTTP 429, missing/invalid field → `ip_lookup_failed` via `out_die_code`. **MUST NOT** retry 429 in a loop.

**IP-M6.** Verb `ip` **MUST** display the same lookup (human + `--json`) **without** the vault and **without** Cloudflare or FQDN resolver calls. JSON **MUST** include `command=ip`, `public_ip`, and `source` (`ipinfo` or `override`).

**IP-M7.** Lookup response temps **MUST** use scratch (`EFFECTIVE_STORAGE_DIR` / `TMPDIR`), mode `0600`. **MUST NOT** require the vault directory.

**IP-M8.** Empty argv **MUST NOT** perform the lookup (Type N help).

**IP-M9.** IPv6 / AAAA **MUST NOT** be looked up, accepted as `--ip`, displayed as a DNS target, or counted as [subdomain IPv4 count](../terminologies/subdomain-ipv4-count.md). This product is **IPv4-only**. An IPv6 literal **MUST** fail `ip_lookup_failed`. Peer: `requirement-cloudflare-dns-mode` MODE-M3.

**IP-M10.** All user output via `out_*`. The lookup GET **MUST NOT** carry the API token (no `curl --config` vault header on ipinfo).

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | dns-cli |
| **Ship unit** | `src/dns-cli` |
| **Lookup URL** | `https://ipinfo.io` |
| **JSON field** | `ip` |
| **Override** | `--ip` |
| **Display verb** | `ip` → `cf_ip_show` |
| **Helper** | `cf_ip_lookup` → `CF_PUBLIC_IP`, `CF_IP_SOURCE` |
| **Fail code** | `ip_lookup_failed` |
| **Stub** | `tests/fixtures/cf_curl_stub.sh` (`CF_CURL`) |
| **VERSION** | `1.1.0` |
| **Proof** | **TP-CF-IP-01..04** in `tests/test_cf_ip.sh` |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Reject non-public addresses; fail 429 closed.  
- **CIAO Principle 2 – Intentional**: One helper; `ip` is display, not DNS mutate.  
- **CIAO Principle 3 – Anti-fragile**: `--ip` for offline QA.  
- **CIAO Principle 5 – Single Source of Output**: `out_*` / `out_die_code`.  
- **CIAO Principle 9 – Command types**: Type 0 only.  
- **CIAO Principle 10 – Least privilege**: One documented GET; no token on that path.  
- **CIAO Principle 11 – Temporary files**: Scratch, not vault.  
- **CIAO Principle 21 – Dual policies**: Portable MUST table; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not publish loopback or link-local as a global A target.  
- **Intentional:** Domain catalog does not own the lookup table.  
- **Anti-fragile:** Stub + `--ip` keep Core offline.  
- **Over-protect:** Display never needs credentials.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add a second public-IP host without updating this file’s Implementation Notes.  
2. Treat LAN / `hostname -I` / loopback as external IPv4.  
3. Require the vault for `ip`.  
4. Call Cloudflare or resolve the FQDN from `ip`.  
5. Retry ipinfo 429 in a loop.  
6. Put the API token on the ipinfo request.  
7. Look up on empty argv.  
8. Register this file as `requirement-domain-*` or as a second domain catalog.  
9. Claim Implemented while `cf_ip_lookup` / `ip` are missing.  
10. Accept or publish IPv6 / AAAA as the lookup or A-record target.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-IP1 | `--json ip --ip 203.0.113.10` exits 0 with `public_ip` and `source=override`; no network |
| AC-IP2 | `--json ip` (stub) hits only ipinfo; not `api.cloudflare.com` |
| AC-IP3 | `ip --ip 127.0.0.1` exits non-zero `ip_lookup_failed` |
| AC-IP4 | Stub HTTP 429 → `ip_lookup_failed` |
| AC-IP5 | Help lists routed `ip`; empty argv still help |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-cloudflare-dns` | Consumes this lookup for A-record verbs |
| `requirement-cloudflare-dns-mode` | IPv4-only fence; AAAA never in `ipv4_count` |
| `requirement-cloudflare-vault` | Distinct; lookup must not require vault |
| `requirement-shell-cli-zero-arguments` | Empty argv = help; no lookup |
| `requirement-shell-cli-storage` | Scratch root for lookup temps |
| `requirement-shell-output-requirements` | `out_*` / `out_die_code` |
| `requirement-shell-cli-interface` | Routes `ip` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-IP-01** | `tests/test_cf_ip.sh` | have | `--json ip --ip` without vault |
| **TP-CF-IP-02** | `tests/test_cf_ip.sh` | have | ipinfo stub only |
| **TP-CF-IP-03** | `tests/test_cf_ip.sh` | have | loopback rejected |
| **TP-CF-IP-04** | `tests/test_cf_ip.sh` | have | HTTP 429 |
| **TP-CLI-04** | `tests/test_cli.sh` | have | help lists `ip` |
| **TP-CF-DNS-05** | `tests/test_cf_dns.sh` | have | empty argv does not network |

**Map:** `reviews/test-plan.md`  
**Matrix:** `reviews/requirement-test-matrix.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.1.0 | IPv6 / AAAA MUST NOT (not merely out of scope) |
| 2026-08-17 | Active 1.0.0 | Split lookup/display law from domain catalog; `ip` already Implemented |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
