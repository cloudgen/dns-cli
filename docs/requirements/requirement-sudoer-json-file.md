**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 1.2.0) — generate/submit **Implemented** (1.6.0); `print-sudoers` text file **Implemented** (1.5.0); CI-M1a samples; sibling approve dest is not this product  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**Optional RQ-ID**: `RQ-SUDOER-JSON-FILE`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of dns-cli’s Type 2 elevation grant (the body Type 0 `generate-sudoer-request` writes and `submit-sudoer-request` hands to the sibling allocator).

dns-cli **is** a **sudoer-approval-submitter**. It **is not** a sudoers-manager. Sibling dest (`sudoer-cli` / `sudoer-adm`) owns inbound, approve, and any write under `/etc/sudoers.d`. This product **MUST NOT** `mkdir` that inbound, approve, or write `/etc/sudoers.d`.

The grant **MUST** name only the project command **`dns-cli`**. It **MUST NOT** allowlist other shell or OS tools. It **MUST NOT** grant Type 1 `setup` / `remove-lpu` (password `sudo` stays the approval) or Type 0 verbs.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, `print-sudoers` text, F6 dest `/etc/dns-adm/sudoers`, submit **workflow** | `requirement-three-layer-privilege-model` |
| Domain DNS catalog / inbound DNS JSON | `requirement-domain-cloudflare-dns` · `requirement-cloudflare-dns-request` |
| Dispatcher / help rows | `requirement-shell-cli-interface` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity and JSON body shape**.

DNS inbound (`submit` a Cloudflare request) **is a different machine**. Do not mix those JSON types.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Role table (print sudoer file + JSON submit)

This product runs **two** Type 0 sudoer surfaces. They share Table A (`dns-cli` as `dns-adm`) and **MUST NOT** be collapsed into the DNS actor table (`requirement-dns-actor-table`).

| Surface | Verb | Artifact | Dest this product may write |
|---------|------|----------|-----------------------------|
| **Print sudoer file** | `print-sudoers` | `sudoers(5)` text (Table A / F6 dual) | stdout, or one user-writable path. **MUST NOT** write F6 dest or `/etc/sudoers.d` |
| **JSON sudoer file** | `generate-sudoer-request` | closed-schema JSON grant | invoking-user-readable path (default `${HOME}/.config/dns-cli/sudoer-request-<user>.json`) |
| **JSON submit** | `submit-sudoer-request` | same JSON body | none — sibling allocator writes inbound |

**SJ-M1.** Product law **MUST** publish this role table. Roles **MUST NOT** be collapsed.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Printer** | Any login (`id -un`) | **0** | `print-sudoers` — print the sudoer **file** (Table A text) to stdout or a user-writable path | Write F6 dest `/etc/dns-adm/sudoers`; write `/etc/sudoers.d`; write `/etc/passwd`; treat CLI `--json` status as the sudoer file |
| **Generator** | Same login | **0** | `generate-sudoer-request` — write the JSON sudoer file to a dest the invoker can `cat` without sudo | Write inbound; write `/etc`; `mkdir` sibling inbound |
| **Submitter** | Same login (self-scope) | **0** | `submit-sudoer-request` — hand the JSON file to sibling `sudoer-cli` | Submit for another login; approve; invent the queued basename; write `/etc/sudoers.d` |
| **Subject** | Same person as the submitter | — | Appear as JSON `username` | Be another login |
| **Allocator** | Sibling `sudoer-cli` Type 0 path | **0** | Allocate `sudoer-YYYYMMDD-dns-cli-<user>-<action>-<n>.json` into inbound | Be this product |
| **Sibling approver** | LPU **`sudoer-adm`** (not `dns-adm`) | **1** | Re-check JSON; **move** inbound; on accept, write `/etc/sudoers.d/dns-cli-<user>` | Be invented or operated by this product |
| **F6 installer** | Host admin via `sudo dns-cli setup` | **1** | Install the **printed** sudoer file to `/etc/dns-adm/sudoers` after `visudo -c` | Write `/etc/sudoers.d` from this product |
| **Type 2 operator** | LPU **`dns-adm`** | **2** | Run the managed binary after a live grant | Approve sudoer JSON; print/submit as a dest writer |

**Account map**

| Role | Account |
|------|---------|
| Printer / generator / submitter / subject | Invoking login (`id -un`) |
| Type 2 operator | `dns-adm` |
| Sibling approver | `sudoer-adm` |
| Allocator | `sudoer-cli` |
| F6 installer | euid 0 / password `sudo` |
| Root session | euid 0 — may `setup`; **MUST NOT** submit a JSON body whose `username` is someone else |

**SJ-M2.** `dns-adm` **is not** `sudoer-adm`. DNS inbound approve (`requirement-dns-actor-table`) **is not** this table.

**When Type 0 may print / generate / submit** — all must hold:

1. Invoker is a login user.  
2. **Print:** dest is stdout or an absolute user-writable path ≠ F6 dest ≠ `/etc/sudoers.d`.  
3. **Generate / submit:** self-scope (`username` = `id -un`); body matches §2.2–2.3.  
4. **Submit:** sibling CLI + `sudoer-adm` + inbound exist and inbound is writable. Type 0 **MUST NOT** `mkdir` inbound.  
5. Allocator (sibling) owns the queued basename.

**Not a print / not a submit:** wanting `/etc/sudoers.d` written immediately; `print-sudoers` of the F6 dest path; DNS `submit`; `setup` as a Type 0 substitute for print; on-behalf-of JSON.

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status. It is **not** a Cloudflare DNS request.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands.  
4. Pretty-printed and compact JSON are the **same** grant.  
5. `print-sudoers` text (`%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` → F6 dest) is a **group** dual for Type 1 `setup`. This JSON is the **per-user** dual queued to the sibling (`username` = invoker, `runas` = `dns-adm`). They are the same **binary + runas**; they are **not** the same dest file.

### 2.2 Command identity — `dns-cli` only (sacred)

| Rule | Detail |
|------|--------|
| **Identity** | Every `commands[].path` **MUST** be `/usr/local/bin/dns-cli` |
| **Basename** | `basename(path)` **MUST** equal `dns-cli` |
| **Service** | JSON `service` **MUST** equal `dns-cli` |
| **One program** | **MUST NOT** list any other executable |
| **No local binary** | **MUST NOT** elevate `${HOME}/.local/bin/dns-cli` |
| **No OS tools** | **MUST NOT** list `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `ln`, `mv`, `chown`, `dd`, or shells |
| **No ALL** | **MUST NOT** use `ALL`, `NOPASSWD: ALL`, or an empty command set (empty **args** is allowed; empty `commands` is not) |
| **Runas** | **MUST** be `dns-adm` (Type 2 switch). **MUST NOT** be `root` |

**Why empty `args`:** Table A is the whole managed binary as `dns-adm` so `sudo -u dns-adm dns-cli --json vault …` still matches. Verb-bound `dns-cli vault` would miss global flags before the verb. Whole-CLI-as-**root** remains forbidden.

### 2.3 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` |
| `purpose` | string | yes | Human; no secrets / tokens |
| `username` | string | yes | Invoking login; not `ALL`; self-scope |
| `service` | string | yes | `dns-cli` |
| `action` | string | yes | `add` or `update` |
| `commands` | array | yes | Exactly one object |
| `commands[].runas` | string | yes | `dns-adm` |
| `commands[].tags` | array | yes | `["NOPASSWD"]` |
| `commands[].path` | string | yes | `/usr/local/bin/dns-cli` |
| `commands[].args` | array | yes | `[]` |

**MUST NOT** include `token`, `CF_API_TOKEN`, `setup`, `remove-lpu`, `install`, or OS-tool paths.

### 2.4 Filename grammar (queued artifact — sibling allocator)

This product **MUST NOT** invent the dest basename. Sibling grammar (informative):

```text
sudoer-{{YYYYMMDD}}-dns-cli-{{username}}-{{action}}-{{n}}.json
```

**Worked sample (add):** `sudoer-20260818-dns-cli-alice-add-1.json`  
**Worked sample (update):** `sudoer-20260818-dns-cli-alice-update-1.json`

### 2.5 Complete sample bodies

Normative **add** JSON:

```json
{
  "schema_version": 1,
  "purpose": "Allow alice to run dns-cli as dns-adm.",
  "username": "alice",
  "service": "dns-cli",
  "action": "add",
  "commands": [
    {
      "runas": "dns-adm",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/dns-cli",
      "args": []
    }
  ]
}
```

Normative **update** JSON: same object; `"action": "update"` only.

Equivalent **text dual** of the **per-user** grant (sibling dest after approve — not F6):

```text
# Purpose: Allow alice to run dns-cli as dns-adm.
alice ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli
```

F6 text dual (Type 1 `setup` / `print-sudoers`; **not** this JSON’s dest):

```text
%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli
```

**Withdrawn:** `"path": "/usr/bin/mkdir"` · `runas: "root"` · `args: ["setup"]`.

### 2.6 Generate / submit honesty

1. `generate-sudoer-request` **MUST** write this JSON to an invoking-user-readable dest **without** submit, inbound, or `/etc`. Default dest: `${HOME}/.config/dns-cli/sudoer-request-<user>.json`. Path operand overrides. **MUST NOT** write `/etc`, `/etc/sudoers.d`, or `/var/sudoer-cli/…`.  
2. `submit-sudoer-request` **MUST** detect `sudoer-cli` + `sudoer-adm` + inbound; fail closed if missing (next: `sudo sudoer-cli setup`). **MUST NOT** `mkdir` inbound.  
3. Prefer a file from generate. No file → same compact body.  
4. Default action: **update** when `/etc/sudoers.d/dns-cli-<user>` exists; else **add**. `--add` / `--update` override. F6 dest `/etc/dns-adm/sudoers` **MUST NOT** count as that probe.  
5. **MUST** fail closed if an input file’s `commands` contain a forbidden path, `runas` ≠ `dns-adm`, or `service` ≠ `dns-cli`.  
6. When inbound `${request_id}` is readable, **MUST** fail closed if `service`, `path`, or `runas` is missing.  
7. Trust-tier: production requires global managed `/usr/local/bin/dns-cli`. Otherwise `--allow-test-local` / `ALLOW_TEST_LOCAL_SUDOERS=1`.

### 2.6a Sample invocations (CI-M1a)

```sh
dns-cli print-sudoers
dns-cli generate-sudoer-request
dns-cli generate-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli submit-sudoer-request
dns-cli submit-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli submit-sudoer-request --add
dns-cli submit-sudoer-request --update
```

`print-sudoers` is Table A **text**. The JSON dest is generate only. `submit-sudoer-request` is **not** DNS `submit`.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `dns-cli` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/dns-cli` |
| **`{{RUNAS}}`** | `dns-adm` |
| **Allowed args** | `[]` (Table A whole-binary Type 2) |
| **Submit verb** | `submit-sudoer-request` → `lpu_submit_sudoer_request` |
| **Generate verb** | `generate-sudoer-request` → `lpu_generate_sudoer_request` |
| **Generate dest (default)** | `${HOME}/.config/dns-cli/sudoer-request-<user>.json` |
| **Approval dest** | `sudoer-cli` (env `SUDOER_CLI`) |
| **Approver** | `sudoer-adm` (env `SUDOER_ADM_USER`) |
| **Inbound** | `/var/sudoer-cli/sudoer-request` (env `SUDOER_QUEUE_INBOUND`) |
| **Sibling dest after approve** | `/etc/sudoers.d/dns-cli-<user>` — written by **sudoer-cli**, not this product |
| **F6 dest** | `/etc/dns-adm/sudoers` — Type 1 `setup`; not this JSON’s dest |
| **Privilege / workflow peer** | `requirement-three-layer-privilege-model` |
| **Ship unit** | **1.6.0** generate + submit Implemented; `print-sudoers` file Implemented (1.5.0) |
| **Role table** | §2.0 (this file) |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege**: Grant is one managed binary as `dns-adm`, not root and not OS tools.  
- **CIAO Principle 1 – Caution**: Type 0 never writes `/etc/sudoers.d`; sibling re-validates.  
- **CIAO Principle 2 – Intentional**: JSON means “this user may run `dns-cli` as `dns-adm`.”  
- **CIAO Principle 9 – Type 0 / 1 / 2**: Submit is Type 0; approve is sibling Type 1; day-to-day is Type 2.  
- **CIAO Principle 21 – Dual policies**: Placeholders in the mold; this file fills `dns-cli` / `dns-adm`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Refuse OS-tool JSON and `runas: root`.  
- **Intentional:** Submitter ≠ dest ≠ F6 dest.  
- **Anti-fragile:** Independent generate dest is the review fixture.  
- **Over-protect:** Empty argv still help; generate/submit never install dest.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, or a shell in this JSON.  
2. Set `runas` to `root` or grant `setup` / `remove-lpu` / Type 0 verbs.  
3. Elevate `USER_BIN/dns-cli`.  
4. Write `/etc/sudoers.d` or `mkdir` inbound from this product.  
5. Treat DNS inbound JSON (`add`/`update`/`remove`/`mode`) as this grant.  
6. Claim generate/submit are trimmed sudoers-manager extras.  
7. Make submit, inbound, or a deleted temp the only way to obtain this JSON.  
8. Store tokens in the JSON body.  
9. Cite templates or skills as product-source authority.  
10. Drop the §2.0 role table or treat `print-sudoers` as dest install.

**Violating this rule is a critical privilege / dest-collapse regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `/usr/local/bin/dns-cli` |
| AC-2 | `service` equals `dns-cli`; `runas` equals `dns-adm` |
| AC-3 | `args` is `[]` |
| AC-4 | No OS-tool basename in `path` or `args` |
| AC-5 | Add and update samples differ only by `action` |
| AC-6 | Generate dest is invoking-user readable; suite `cat`s without sudo |
| AC-7 | Generate refuses `/etc` and sibling inbound dests |
| AC-8 | Submit of a forbidden file fails closed |
| AC-9 | Submit without dest CLI / inbound / approver fails closed (no `mkdir`) |
| AC-10 | Submit does not write `/etc/sudoers.d` |
| AC-11 | Role table present (printer / generator / submitter / subject / allocator / sibling approver / F6 installer / Type 2) |
| AC-12 | `print-sudoers` prints the sudoer file (Table A text) and does not write F6 dest |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Workflow; Table A text; F6 dest |
| `requirement-least-privilege-user` | `dns-adm` identity |
| `requirement-shell-cli-interface` | Verb routing |
| `requirement-domain-cloudflare-dns` | Type 2 verbs after elev — not this JSON |
| `requirement-cloudflare-dns-request` | Different inbound JSON family |
| `requirement-class-software-dev` | Residual points here |
| `docs/requirements/index.md` | Registry |
| `./src/dns-cli` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-SUDOER-JSON-01** | `tests/test_cf_lpu.sh` | have | path is only `/usr/local/bin/dns-cli` |
| **TP-SUDOER-JSON-02** | same | have | no mkdir/cp/tar/rm/install/chmod |
| **TP-SUDOER-JSON-03** | same | have | runas is `dns-adm`; args `[]` |
| **TP-SUDOER-JSON-08** | same | have | generate dest readable without sudo |
| **TP-PRIV-05** | same | have | generate refuses `/etc` |
| **TP-PRIV-06** | same | have | submit missing dest CLI fail-closed |
| **TP-PRIV-07** | same | have | submit stub inbound; no `/etc/sudoers.d` write |
| **TP-PRIV-08** | same | have | refuse OS-tool input file |
| **TP-SUDOER-JSON-09** | same | have | §2.0 role table (printer / generator / submitter / `sudoer-adm`) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-18 | Active 1.2.0 | CI-M1a sample invocations for print / generate / submit |
| 2026-08-18 | Active 1.1.0 | Role table: print sudoer file + JSON generate/submit; sibling approver ≠ `dns-adm` |
| 2026-08-18 | Active 1.0.0 | JSON sudoer file + generate/submit; Type 2 `runas=dns-adm`; empty args |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
