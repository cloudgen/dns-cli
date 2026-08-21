**file**: docs/requirements/requirement-incorrect-json-format.md  
**Status**: Active (Version 1.4.0) — dest-owned `submit_app` / `submit_version`; MUST NOT fence sibling app or version  
**Area**: architecture  
**Key**: `requirement-incorrect-json-format`  
**Optional RQ-ID**: `RQ-INCORRECT-JSON-FORMAT`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent dest fence** for **incorrect JSON format**. Dest `approve` / `reject` / `interactive` **MUST** fail closed when the waiting file is not dest-legal JSON, display that in ordinary words, and **MUST NOT** ask yes or no for that file.

The dest fence **table** stays on dest who / dest payload files and **points** here. The dest **catalog** owner is `requirement-approval-fencing-condition`. This file owns **what matches**. It is **not** a second dest table and **not** who may dest-approve.

Dest closed schema is **dest-owned**. An unknown key is a key **not** on that dest allowlist. Submitter-local fields that dest does not list are dest format fail. Dest-written `submit_by` is dest-owned **after** this check is clear. Submitter-emitted `submit_app` / `submit_version` are dest-owned on Type 0 emit. Missing or non-string on add/update **is** this fence. Dest **MUST NOT** fence because those values ≠ dest `APP_NAME` / dest `VERSION`.

Every software-development project **MUST review** dest fence conditions. This product’s dest **Fence** row is this file. A JSON-format dest Fence **MUST** ship a Type 0 test subcommand that runs these checks without dest elev and without requiring the waiting folder.

### 1.1 Human-facing

**In one sentence:** If the waiting file is not dest-legal JSON, dest **explains** that and does **not** ask yes or no.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Submitted a JSON dest does not list | unknown key `token`; missing `purpose` |
| Dest | Refuses without a yes/no | `dns-cli interactive` / sibling dest review |
| Not this file | Who dest-approves, or the dest refuse **list** | `requirement-dns-actor-table` · `requirement-approval-fencing-condition` |

| Includes | Excludes |
|----------|----------|
| Parse / dest-owned schema / basename action mismatch | Unix file owner |
| Dest-written `submit_by` as allowed after format | Filename token as the user |
| Type 0 `submit_app` / `submit_version` as dest-known strings | Dest fence because the submitting CLI is a sibling or an older version |
| Dest-legal sudoer `kind` as a **known** key | Asking yes/no on a fenced file; treating `kind` as unexpected |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/dns-cli/dns-request` | Waiting DNS files | This product dest-reviews these |
| `/var/sudoer-cli/sudoer-request` | Waiting sudoer grants | Sibling dest reviews; this product queued them |
| `dns-cli interactive` | DNS dest review | Fence first |
| `dns-cli submit ./req.json` | Type 0 DNS queue | Same dest format check |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Put a `token` key in a DNS file | Dest refuses; no yes/no | `dns-cli submit ./req.json` |
| Test a grant JSON | Check the file against this Fence without becoming `dns-adm` and without putting it in the waiting folder. | `dns-cli test-json-format --file ./20260820-alice-add-1.json` |
| Leave a required field out | Dest refuses | `dns-cli interactive` |
| Queue sudoer JSON with dest-legal `kind` | Dest format **MUST** accept `kind` as known | `sudo dns-cli setup` (hook) / `dns-cli submit-sudoer-request` |
| File is dest-legal | Dest asks yes or no | (login as the dest LPU) |

---

## 2. Core Rules / Requirements (Mandatory)

**IJF-M1.** Dest inbound **Fence** is **incorrect JSON format**. Dest **MUST** fail closed when any of these hold:

| Fail | Why it is format |
|------|------------------|
| Missing, symlink, or not a regular file | Not a request artifact |
| Not one parseable JSON object | Not JSON format |
| `schema_version` ≠ dest integer (DNS / sudoer dest: `1`) | Closed schema |
| Unknown key — key **not** on the dest-owned allowlist for that dest machine | Closed schema |
| Forbidden key (`token`, `CF_API_TOKEN`, `user_id`, `api_token`) | Closed schema |
| Missing required field for that dest machine | Closed schema |
| Field type / enum invalid for that dest machine | Closed schema |
| Basename not that dest machine’s request-id grammar | Artifact name is part of the request |
| Basename **action** ≠ JSON `action` (when JSON has `action`) | Action label is part of the request-id |

**IJF-M2.** Dest **MUST NOT** treat these as this fence: Unix file-ownership; who submitted; dest Type 0 self-scope; JSON username field ≠ dest LPU; filename subject token ≠ JSON username field; dest-written `submit_by` present or missing; dest-legal sudoer `kind` present; `submit_app` ≠ dest `APP_NAME`; `submit_version` ≠ dest `VERSION`.

**IJF-M3.** When this fence matches: dest **MUST** display a human-facing sentence (what happened / what it means / next). Dest **MUST NOT** ask yes or no for that file. Direct `approve` / `reject` **MUST** fail closed with the same sentence. Dest next-step **MUST NOT** send `login-hook-elev` through dest Type 0 `add-sudoer-request`.

**IJF-M4.** User SSOT remains the JSON username field (`subject` on DNS; `username` on sudoer). Dest **MUST NOT** take the user from the filename.

**IJF-M5.** Type 0 `submit` **MUST NOT** include `submit_by`. Dest interactive **MUST** dest-write `submit_by` **after** this format check is clear, set to the original Unix file-ownership dest read **before** taking ownership. Dest **MUST NOT** dest-write `submit_by` when format fails. Dest verify **MUST** treat dest-written `submit_by` as allowed, not unknown.

**IJF-M6.** Dest **MUST NOT** add another dest inbound fence. Extra dest fences stay off this file and off dest tables unless the user confirms a new **Fence** row on `requirement-approval-fencing-condition` **and** a new independent requirement.

**IJF-M7. Dest-owned allowlist (sacred).** Dest closed schema is dest-owned. Submitter emit **MUST** match that allowlist on the **queued** body. Generate fixtures **MAY** keep local fields dest does not list **only** on a non-inbound dest. Queuing a key dest does not list **is** this fence. Incident **INC-20260819-001**.

**IJF-M8. DNS dest allowlist (this product dest).** Submitter-emitted keys dest **MUST** treat as known: `schema_version`, `purpose`, `subject`, `action`, `domain_id`, `subdomain`, `submit_app`, `submit_version`, plus the type extras on `requirement-cloudflare-dns-request`. Required on emit: `purpose`, `subject`, `action`, `domain_id`, `subdomain`, `submit_app`, `submit_version`. `submit_app` / `submit_version` **MUST** be non-empty strings. Type 0 `submit` **MUST** overwrite them from live Config `APP_NAME` / `VERSION`. Dest **MUST NOT** dest-write them. Dest **MUST NOT** fence if their values ≠ dest identity. `action` **MUST** be `add` / `update` / `remove` / `mode`. Basename **MUST** be `YYYYMMDD-subject-action-n.json`. Dest **MUST NOT** treat DNS dest `kind` as a DNS dest key. Dest-written after format: `submit_by`.

**IJF-M9. Sudoer dest allowlist (sibling dest; this product submitter).** Submitter-emitted keys dest **MUST** treat as known: `schema_version`, `kind`, `purpose`, `username`, `service`, `action`, `commands`, `submit_app`, `submit_version`. Required on emit (add/update): all of those except `submit_app` / `submit_version` which **MUST** still be present as strings. `kind` **MUST** be `type-2-switch` or `login-hook-elev`. Remove: `submit_app` / `submit_version` optional. Dest **MUST NOT** treat dest-legal `kind` as unexpected. Dest **MUST NOT** fence if `submit_app` ≠ sibling dest product or `submit_version` ≠ sibling dest version. Dest-written after format: `submit_by`. Command identity stays on `requirement-sudoer-json-file`. Sibling dest source **MUST** allowlist `kind` / `submit_app` / `submit_version` or this product **MUST NOT** queue those keys — dest format and submitter emit **MUST** match. Incident **INC-20260819-001**.

**IJF-M10. `kind` is not file-ownership.** Dest **MUST NOT** infer `kind` from Unix owner or from `submit_by`. Dest **MUST NOT** convert file-ownership into a submitter-emitted field named `kind`. File-ownership dest-writes `submit_by` only (IJF-M5).

**IJF-M11. Type 0 tester.** Dest **MUST** ship Type 0 `test-json-format`. Dest `approve` / `reject` / `interactive` **MUST NOT** count as that verb. The tester **MUST** take stdin **xor** `--file PATH` (a positional path **MAY** stand in for `--file`). It **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d`, **MUST NOT** queue, and **MUST NOT** require the waiting folder. Basename grammar and basename **action** match apply **only** when the input basename already matches request-id grammar.

```sh
dns-cli test-json-format --file ./20260820-alice-add-1.json
```

```sh
dns-cli test-json-format < ./request.json
```

**IJF-M12. Dest `interactive` after a fence match.** Dest **MUST** display the match in people/folder words. **MUST NOT** ask yes or no. Dest **MUST** then move that inbound file to **declined** (snapshot + LPU owner + unlink inbound). **MUST NOT** dest-write Cloudflare. **MUST NOT** stamp `submit_by`. Standalone `approve` / `reject` **MUST** fail closed with the same sentence; that file **stays inbound**.

**IJF-M13. Closed-list tester.** The dest fence **list** tester is Type 0 **test-purpose** `fence-test` (this Fence, then any later dest Fence row). Dual mention and invocation samples live on `requirement-approval-fencing-condition` **and** `requirement-shell-cli-interface`. This file owns the per-row tester `test-json-format`. **MUST NOT** treat dest review as either tester.

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **DNS dest verbs** | `approve` / `reject` / `interactive` |
| **Type 0 tester** | `test-json-format` — `cf_req_test_json_format` (per-row) |
| **List tester** | `fence-test` — dest catalog `requirement-approval-fencing-condition` |
| **Helper** | `cf_req_dest_fence` |
| **Class review** | Converted from dest table **Fence** row |
| **Catalog** | `requirement-approval-fencing-condition` |
| **Dest tables** | `requirement-dns-actor-table` ACT-M8 · `requirement-cloudflare-dns-request` REQ-M9 · `requirement-sudoer-json-file` SJ-M5 |
| **Proof** | **TP-CF-REQ-10** · **TP-CF-REQ-13** · **TP-FENCE-02** · **TP-FENCE-04** · **TP-FENCE-05** · **TP-FENCE-06** |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: One dest refuse reason has one file. Dest-owned keys are listed.  
- **CIAO Principle 5 – SSOT**: Dest tables index; catalog owns the list; this file owns the meaning.  
- **CIAO Principle 1 – Caution**: Fail closed on a broken waiting file.  
- **CIAO Principle 21 – Dual policies**: Portable fence class; filled dest allowlists.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Broken inbound is not offered for yes or no.  
- **Intentional**: Format is this dest fence; owner and submitter are not. `kind` is dest-legal on sudoer dest.  
- **Anti-fragile**: Dest-written `submit_by` does not become a new dest fence.  
- **Over-protect**: Protection Rule forbids extra dest fences and dest-unknown submitter keys.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Ask yes/no on a file this fence matches.  
2. Treat Unix owner, who submitted, or filename token as this fence.  
3. Treat dest-written `submit_by` as unknown.  
3a. Treat Type 0 `submit_app` / `submit_version` as unknown, or fence dest because those values ≠ dest identity.  
3b. Dest-write `submit_app` / `submit_version`, or leave Type 0 add/update without those strings.  
4. Treat dest-legal sudoer `kind` as unexpected, or convert file-ownership into `kind`.  
5. Queue dest inbound JSON with keys dest does not list.  
6. Add a dest inbound fence that dest tables do not name.  
7. Delete dest fence tables after this file exists.  
8. Plant `submit_by` on Type 0 submit.  
9. Count dest `approve` / `reject` / `interactive` as the Type 0 JSON-format tester, or treat dest review as `fence-test`.  
10. Ask yes/no on dest `interactive` after a fence match, or leave a fenced inbound file unmoved.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST review dest fences |
| `docs/requirements/requirement-approval-fencing-condition.md` | Dest fence catalog |
| `docs/requirements/requirement-dns-actor-table.md` | Dest fence table + dest who |
| `docs/requirements/requirement-cloudflare-dns-request.md` | DNS dest schema + dest fence table |
| `docs/requirements/requirement-sudoer-json-file.md` | Sudoer dest schema + dest fence table |
| `docs/requirements/requirement-dns-approver.md` | Login-hook review |
| `./src/dns-cli` | `cf_req_dest_fence` |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-REQ-10** | `tests/test_cf_request.sh` | have | dest fence table is incorrect JSON format |
| **TP-CF-REQ-13** | `tests/test_cf_request.sh` | have | dest fences first; human-facing match |
| **TP-FENCE-02** | `tests/test_cli.sh` | have | independent dest-fence REQ exists and names this fence |
| **TP-FENCE-04** | `tests/test_cli.sh` | have | dest-owned sudoer allowlist includes `kind`; file-ownership dest-writes `submit_by` |
| **TP-FENCE-05** | `tests/test_cf_lpu.sh` | have | queued sudoer body keys ⊆ dest-owned allowlist (IJF-M9) |
| **TP-FENCE-06** | `tests/test_cf_request.sh` | have | DNS dest rejects sudoer `kind` (IJF-M8) |
| **TP-FENCE-07** | `tests/test_cf_lpu.sh` | skip | live dest unknown-key fence (sibling dest; dest 1.8.1 still refuses `kind`) |
| **TP-FENCE-08** | `tests/test_cli.sh` | have | Type 0 `test-json-format` stdin xor `--file`; no queue |
| **TP-FENCE-09..15** | `tests/test_cli.sh` | have | Type 0 `fence-test` list tester (peer catalog) |
| **TP-FENCE-16** | `tests/test_cli.sh` | have | missing `submit_app` is dest format fail |
| **TP-FENCE-17** | `tests/test_cli.sh` | have | sibling `submit_app` is dest-legal |
| **TP-CF-REQ-17** | `tests/test_cf_request.sh` | have | Type 0 submit stamps live `submit_app` / `submit_version`; dest display `queued by` |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-21 | Active 1.4.0 | Dest-owned `submit_app` / `submit_version`; missing/non-string on add/update is this fence; MUST NOT fence sibling app or version |
| 2026-08-21 | Active 1.3.0 | List tester `fence-test` on dest catalog; this file keeps per-row `test-json-format` |
| 2026-08-20 | Active 1.2.0 | Type 0 `test-json-format`; dest `interactive` fence match → declined |
| 2026-08-19 | Active 1.1.0 | Dest-owned allowlist; sudoer `kind` known; file-ownership dest-writes `submit_by` after format; catalog peer |
| 2026-08-19 | Active 1.0.0 | Extracted dest Fence as an independent requirement |

---

**Last Updated**: 2026-08-21  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
