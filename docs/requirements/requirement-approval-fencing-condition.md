**file**: docs/requirements/requirement-approval-fencing-condition.md  
**Status**: Active (Version 1.1.0) — Type 0 test-purpose `fence-test` (closed dest fence list)  
**Area**: architecture  
**Key**: `requirement-approval-fencing-condition`  
**Optional RQ-ID**: `RQ-APPROVAL-FENCING-CONDITION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **dest approval fencing condition catalog** for `dns-cli`. It names **which dest refuse reasons exist**. Dest `approve` / `reject` / `interactive` **MUST** run this list **before** any yes/no. Dest **MUST** refuse an inbound file **only** when a listed **Fence** holds.

This product has **one** dest **Fence**: **incorrect JSON format**. Meaning of that Fence lives on `requirement-incorrect-json-format`. Dest tables still **print** this catalog and **point** the Fence row at that file.

This file is **not** a dest Fence. Dest **MUST NOT** fence rows stay here **and** on dest tables — they are **not** independent fence REQs. Who dest-approves stays on `requirement-actor-role-subject-approver` and dest actor tables. Dest login-hook procedure stays on dest who files.

Every software-development project **MUST review** dest fence conditions. This product **publishes** the catalog here (not residual **none**).

### 1.1 Human-facing

**In one sentence:** Dest may refuse a waiting file only for **listed** reasons — on this product the only refuse reason is a **broken dest JSON** — and dest then **explains** that instead of asking yes or no.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Dropped a waiting JSON | `/var/dns-cli/dns-request` or sibling `/var/sudoer-cli/sudoer-request` |
| Dest | Refuses only if the list matches | Broken JSON — no yes/no |
| Not this file | What “broken JSON” means, or who dest-approves | `requirement-incorrect-json-format` · `requirement-actor-role-subject-approver` |

| Includes | Excludes |
|----------|----------|
| Closed dest refuse list | Unix file owner as a dest refuse |
| One dest Fence row → its own REQ | Who submitted / dest Type 0 self-scope as dest refuse |
| Honest **MUST NOT** fence rows | Inventing a dest fence; treating `kind` or file-ownership as dest fences |

| Surface | What you open | What for |
|---------|---------------|----------|
| This file | Catalog | Which dest refuses exist |
| `requirement-incorrect-json-format` | Dest Fence meaning | Dest-owned JSON allowlist |
| Dest tables | Same catalog reprinted | Index that **points** here and at the Fence REQ |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask why dest said no | Read this list, then the Fence file | `dns-cli interactive` |
| Test dest fences | Point at a JSON file. No `sudo`. Does not queue. | `dns-cli fence-test --file tests/fixtures/fence-test/pass/20260821-alice-add-1.json` |
| See owner `root` on the waiting file | **Not** a dest refuse — dest takes ownership | (login as `dns-adm` / `sudoer-adm`) |
| See JSON field `kind` on a sudoer grant | **Not** a dest refuse — dest format allowlists it | (sibling dest review) |

---

## 2. Core Rules / Requirements (Mandatory)

**AFC-M1.** This catalog **MUST** stay Active while dest review **or** dest submit exists. A software-development project **without** dest refuse **MUST** still review dest fences (this file **or** class residual **considered — no dest fence conditions**). **MUST NOT** skip the review. **MUST NOT** invent a dest fence so the set looks complete.

**AFC-M2.** Product law **MUST** print this closed dest table (dest tables **MUST** reprint it and **point**):

| Condition | Dest `approve` / `reject` / `interactive` |
|-----------|-------------------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — dest takes ownership as the dest LPU, then moves |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON username field ≠ dest LPU | **MUST NOT** fence |
| Filename subject token ≠ JSON username field | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it **after** format check |
| `submit_app` ≠ dest `APP_NAME` / `submit_version` ≠ dest `VERSION` | **MUST NOT** fence — Type 0 stamps live Config; sibling submitters and mixed versions are dest-legal JSON. Missing / non-string on add/update is **incorrect JSON format** |

**AFC-M3. One dest Fence.** The only dest inbound **Fence** is **incorrect JSON format**. **MUST NOT** fold a second dest Fence into this catalog or into `requirement-incorrect-json-format`. Extra dest fences need explicit user order, a new named row **here**, **and** a new independent Fence REQ.

**AFC-M4. MUST NOT rows are not Fence REQs.** File-ownership, who submitted, dest Type 0 self-scope, JSON username ≠ dest LPU, filename token, and dest-written `submit_by` **MUST NOT** become `requirement-*.md` dest Fence files.

**AFC-M5. Two dest machines, one catalog.** Dest refuse reasons are the **same list** on:

| Dest machine | Dest LPU | Waiting folder | This product |
|--------------|----------|----------------|--------------|
| Cloudflare DNS request | `dns-adm` | `/var/dns-cli/dns-request` | dest (reviews) |
| Sudoer grant | `sudoer-adm` (sibling) | `/var/sudoer-cli/sudoer-request` | submitter (queues; **MUST NOT** dest-approve) |

**MUST NOT** give DNS dest a different dest-fence list than sudoer dest. Dest **who** stays split (`dns-adm` vs `sudoer-adm`).

**AFC-M6. File-ownership is not a dest fence and is not `kind`.** Dest **MUST** read original Unix file-ownership, take ownership as the dest LPU, then format-check. **If** format is clear, dest **MUST** dest-write `submit_by` to that original owner. Dest **MUST NOT** dest-write `submit_by` when format fails. Type 0 submit **MUST NOT** include `submit_by`. Dest **MUST NOT** convert file-ownership into submitter-emitted `kind`. Incident **INC-20260818-003** · **INC-20260819-001**.

**AFC-M7. `kind` is not a dest fence.** JSON `kind` (`type-2-switch` \| `login-hook-elev`) is the sudoer **grant discriminator**. Dest format allowlist (owned by `requirement-incorrect-json-format`) **MUST** treat dest-legal `kind` as a **known** dest sudoer key, not as unexpected. Dest **MUST NOT** add a dest Fence named `kind`. Dest Type 0 self-scope **MUST NOT** apply to Type 1 `setup` queue of `login-hook-elev` (blockage, not dest approval).

**AFC-M8.** Dest fence tables **MUST** still print. Each dest **Fence** row **MUST** point at `requirement-incorrect-json-format`. Dest tables **MUST** point this catalog as the dest-list owner.

**AFC-M9.** Type 0 submit self-scope and Type 1 **authz** (who may run dest verbs) are **not** dest inbound-file fences.

**AFC-M10.** Dest **MUST** display a human-facing sentence when a Fence matches and **MUST NOT** ask yes/no for that file.

**AFC-M11. Type 0 list tester (`fence-test`).** Dest **MUST** ship Type 0 **test-purpose** `fence-test`: **unit test** of dest fence **functions** against a JSON **file location** in a **local test folder**. Input: stdin **xor** `--file PATH` **xor** `--dir DIR` of regular `*.json`. `--dir` continues after a match. `--expect-match` with `--dir` succeeds only when every file matches a dest Fence. Dual mention: `requirement-shell-cli-interface` **and** this catalog (domain SSOT also names it). Per-row testers **MAY** also exist (`test-json-format`) and are also test-purpose. **MUST NOT** require `sudo` to run. The only allowed in-tool elev is wrapping **chmod** / **chown** of that folder (check before sudo). **MUST NOT** require a sudoers fragment. **MUST NOT** submit, queue, dest-write, `setup`, or `approve`. Dest `approve` / `reject` / `interactive`, host install, and queue presence **MUST NOT** count as this tester. Help **MUST** list testers **apart** from operational verbs.

```sh
dns-cli fence-test --file tests/fixtures/fence-test/pass/20260821-alice-add-1.json
```

```sh
dns-cli fence-test --dir tests/fixtures/fence-test/pass
```

```sh
dns-cli fence-test --dir tests/fixtures/fence-test/match --expect-match
```

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Class review** | Published this catalog (not residual none) |
| **Dest Fence** | `requirement-incorrect-json-format` — Implemented |
| **DNS dest** | `dns-adm` · `/var/dns-cli/dns-request` — Implemented |
| **Sudoer dest** | sibling `sudoer-adm` · `/var/sudoer-cli/sudoer-request` — this product submits only |
| **Dest tables** | `requirement-dns-actor-table` ACT-M8 · `requirement-cloudflare-dns-request` REQ-M9 · `requirement-sudoer-json-file` SJ-M5 · `requirement-three-layer-privilege-model` P-M13 · `requirement-least-privilege-user` L-M13 · `requirement-domain-cloudflare-dns` |
| **List tester** | `fence-test` — `cf_req_fence_test`; stdin xor `--file` xor `--dir` |
| **Proof** | **TP-FENCE-01** · **TP-FENCE-03** · **TP-FENCE-05** · **TP-FENCE-06** · **TP-FENCE-09..15** |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Dest refuse reasons are a printed catalog, not implied walls.  
- **CIAO Principle 5 – SSOT**: Catalog here; Fence meaning on the Fence REQ; dest tables index.  
- **CIAO Principle 1 – Caution**: Fail closed only on listed Fences.  
- **CIAO Principle 21 – Dual policies**: Portable closed list; filled dest machines for this product.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Dest does not invent owner / submitter / `kind` walls.  
- **Intentional**: One Fence; MUST NOT rows stay non-fences.  
- **Anti-fragile**: File-ownership becomes dest-written `submit_by` after format, not a dest fence.  
- **Over-protect**: Protection Rule forbids extra dest fences and collapsing `kind` into file-ownership.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Leave dest **approval fencing conditions** as only terminology or only dest-table cells.  
2. Convert a **MUST NOT** fence row into a dest Fence REQ.  
3. Fence dest on Unix file-ownership, who submitted, dest Type 0 self-scope, JSON username ≠ dest LPU, or filename token.  
4. Treat `kind` as a dest Fence, or convert file-ownership into submitter-emitted `kind`.  
5. Ask yes/no on a file the dest Fence matches.  
6. Invent a dest fence so the catalog looks complete.  
7. Delete dest fence tables after this file exists.  
8. Collapse DNS dest and sudoer dest **who** while sharing this refuse list.  
9. Leave dest Fences without Type 0 `fence-test`, treat dest review / queue / `sudo` / a sudoers fragment as that tester, group testers with operational verbs in help, or `sudo` except wrapping chmod/chown of the local test folder.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST review dest fences |
| `docs/requirements/requirement-incorrect-json-format.md` | Dest Fence meaning |
| `docs/requirements/requirement-actor-role-subject-approver.md` | Dest who catalog |
| `docs/requirements/requirement-dns-actor-table.md` | DNS dest table reprint |
| `docs/requirements/requirement-sudoer-json-file.md` | Sudoer dest table reprint |
| `./src/dns-cli` | DNS dest fence helper `cf_req_dest_fence` |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-FENCE-01** | `tests/test_cli.sh` | have | class MUST review dest fences |
| **TP-FENCE-03** | `tests/test_cli.sh` | have | this catalog prints the closed dest table |
| **TP-FENCE-05** | `tests/test_cf_lpu.sh` | have | queued sudoer body keys ⊆ dest-owned allowlist |
| **TP-FENCE-06** | `tests/test_cf_request.sh` | have | dest-legal sudoer `kind` is not a DNS dest key |
| **TP-FENCE-07** | `tests/test_cf_lpu.sh` | skip | live dest unknown-key fence (sibling dest) |
| **TP-FENCE-09..15** | `tests/test_cli.sh` | have | Type 0 `fence-test` `--file` / `--dir` / `--expect-match`; testers listed apart |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-21 | Active 1.1.0 | Type 0 **test-purpose** `fence-test` (closed dest fence list; local test folder) |
| 2026-08-19 | Active 1.0.0 | Extracted dest fence catalog; dest-owned `kind` is not a dest fence; file-ownership dest-writes `submit_by` after format |

---

**Last Updated**: 2026-08-21  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
