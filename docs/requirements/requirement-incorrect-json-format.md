**file**: docs/requirements/requirement-incorrect-json-format.md  
**Status**: Active (Version 1.0.0) — dest Fence extracted as an independent requirement  
**Area**: architecture  
**Key**: `requirement-incorrect-json-format`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent dest fence** for **incorrect JSON format** on `dns-cli` inbound DNS request files. Dest `approve` / `reject` / `interactive` **MUST** fail closed when the waiting file is not a well-formed request, display that in ordinary words, and **MUST NOT** ask yes or no for that file.

The dest fence **table** stays on `requirement-dns-actor-table` and `requirement-cloudflare-dns-request`. This file owns **what matches**. It is **not** a second dest table and **not** who may dest-approve.

Every software-development project **MUST review** dest fence conditions. This product’s dest **Fence** row is this file.

### 1.1 Human-facing

**In one sentence:** If the waiting DNS file is not a real, well-formed request, dest **explains** that and does **not** ask yes or no.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Submitted a broken JSON | unknown key `token` |
| Dest | Refuses without a yes/no | `dns-cli interactive` |
| Not this file | Who dest-approves | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Parse / schema / basename action mismatch | Unix file owner |
| Dest-written `submit_by` as allowed | Filename token as the user |
| Human-facing refuse sentence | Asking yes/no on a fenced file |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/dns-cli/dns-request` | Waiting files | Dest reviews these |
| `dns-cli interactive` | Review | Fence first |
| `dns-cli submit ./req.json` | Type 0 queue | Same format check |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Put a `token` key in the file | Dest refuses; no yes/no | `dns-cli submit ./req.json` |
| Leave a required field out | Dest refuses | `dns-cli interactive` |
| File is well-formed | Dest asks yes or no | (login as `dns-adm`) |

---

## 2. Core Rules / Requirements (Mandatory)

**IJF-M1.** Dest inbound **Fence** is **incorrect JSON format**. Dest **MUST** fail closed when any of these hold:

| Fail | Why it is format |
|------|------------------|
| Missing, symlink, or not a regular file | Not a request artifact |
| Not one parseable JSON object | Not JSON format |
| `schema_version` ≠ 1 | Closed schema |
| Unknown key or forbidden key (`token`, `CF_API_TOKEN`, `user_id`, `api_token`) | Closed schema |
| Missing required field (`purpose`, `subject`, `action`, `domain_id`, `subdomain`) | Closed schema |
| `action` not `add` / `update` / `remove` / `mode` | Closed schema |
| Basename not `YYYYMMDD-subject-action-n.json` | Artifact name is part of the request |
| Basename **action** ≠ JSON `action` | Action label is part of the request-id |
| IPv4 fields invalid / IPv6 present; type extras forbidden | Closed schema |

**IJF-M2.** Dest **MUST NOT** treat these as this fence: Unix file-ownership; who submitted; dest Type 0 self-scope; JSON `subject` ≠ `dns-adm`; filename subject token ≠ JSON `subject`; dest-written `submit_by` present or missing.

**IJF-M3.** When this fence matches: dest **MUST** display a human-facing sentence (what happened / what it means / next). Dest **MUST NOT** ask yes or no for that file. Direct `approve` / `reject` **MUST** fail closed with the same sentence.

**IJF-M4.** User SSOT remains JSON `subject`. Dest **MUST NOT** take the user from the filename.

**IJF-M5.** Type 0 `submit` **MUST NOT** include `submit_by`. Dest interactive **MAY** dest-write `submit_by` **after** this format check is clear. Dest verify **MUST** treat dest-written `submit_by` as allowed, not unknown.

**IJF-M6.** Dest **MUST NOT** add another dest inbound fence. Extra dest fences stay off this file and off dest tables unless the user confirms a new **Fence** row **and** a new independent requirement.

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Dest verbs** | `approve` / `reject` / `interactive` |
| **Helper** | `cf_req_dest_fence` |
| **Class review** | Converted from dest table **Fence** row |
| **Dest tables** | `requirement-dns-actor-table` ACT-M8 · `requirement-cloudflare-dns-request` REQ-M9 |
| **Proof** | **TP-CF-REQ-10** · **TP-CF-REQ-13** · **TP-FENCE-02** |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: One dest refuse reason has one file.  
- **CIAO Principle 5 – SSOT**: Dest tables index; this file owns the meaning.  
- **CIAO Principle 1 – Caution**: Fail closed on a broken waiting file.  
- **CIAO Principle 21 – Dual policies**: Portable fence class; filled dest checks.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Broken inbound is not offered for yes or no.  
- **Intentional**: Format is this dest fence; owner and submitter are not.  
- **Anti-fragile**: Dest-written `submit_by` does not become a new dest fence.  
- **Over-protect**: Protection Rule forbids extra dest fences.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Ask yes/no on a file this fence matches.  
2. Treat Unix owner, who submitted, or filename token as this fence.  
3. Treat dest-written `submit_by` as unknown.  
4. Add a dest inbound fence that dest tables do not name.  
5. Delete dest fence tables after this file exists.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST review dest fences |
| `docs/requirements/requirement-dns-actor-table.md` | Dest fence table + dest who |
| `docs/requirements/requirement-cloudflare-dns-request.md` | Schema + dest fence table |
| `docs/requirements/requirement-dns-approver.md` | Login-hook review |
| `./src/dns-cli` | `cf_req_dest_fence` |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-REQ-10** | `tests/test_cf_request.sh` | have | dest fence table is incorrect JSON format |
| **TP-CF-REQ-13** | `tests/test_cf_request.sh` | have | dest fences first; human-facing match |
| **TP-FENCE-02** | `tests/test_cli.sh` | have | independent dest-fence REQ exists and names this fence |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.0.0 | Extracted dest Fence as an independent requirement |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
