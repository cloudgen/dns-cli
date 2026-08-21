**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.13.0) — dest Fence row points at `requirement-incorrect-json-format`; prevention-set + sudo-command pointers  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for dns-cli’s **Type 0 / Type 1 / Type 2** map and for **elev Tables A/B/C**.

It exists because the product now creates LPU **`dns-adm`** and must say **who** may create that account, **who** may run Cloudflare vault/DNS as that account, and **what** a sudoers dest may contain.

Identity F1–F7 live in `requirement-least-privilege-user`. Domain verb semantics live in `requirement-domain-cloudflare-dns`. This file **MUST NOT** invent a second F1–F7 table or a second DNS catalog.

This product is **not** a sudoers-manager. **Absent:** `print-sudoers-install-script`, `remove-project-sudoers`, backup/restore. It **is** a **sudoer-approval-submitter**: Type 0 `generate-sudoer-request` / `submit-sudoer-request` queue a JSON grant into sibling `sudoer-cli`. JSON **body** is `requirement-sudoer-json-file`. Closed **what is blocked vs must stay open** is `requirement-privilege-prevention-set`. In-tool password sudo wrappers are `requirement-shell-sudo-command` (Type 2 `sudo -n -u` stays **this** file P-M4).

### 1.1 Human-facing

**In one sentence:** This file says **who may run which dns-cli commands** — a normal login, a root/setup login, or work **as** `dns-adm` — and what a printed sudoers fragment may contain.

| Box | Meaning | Example |
|-----|---------|---------|
| Normal login | Help, install, submit, generate | `dns-cli help` |
| Host admin | Create `dns-adm` | `sudo dns-cli setup` |
| As `dns-adm` | Default vault / DNS | `sudo -u dns-adm dns-cli status` |

| Includes | Excludes |
|----------|----------|
| Command map + elev tables A/B/C | Being a sudoers-manager |
| Print fragment to stdout | Writing `/etc/sudoers.d` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `dns-cli print-sudoers` | Command | Table A text |
| `dns-cli help` | Command | Which verbs exist |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the fragment | Does not install it | `dns-cli print-sudoers` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Actor | Responsibilities |
|-------|-----------|-------|------------------|
| **Type 0** | Invoking user | Any login | **Operational:** `help`, `version`, `about`, `install`, `uninstall`, `where-is-me`, `ip`, `print-sudoers` (stdout/draft only), `generate-sudoer-request`, `submit-sudoer-request`, vault/DNS **when** `--vault-dir` / `CF_VAULT_DIR` is specified. **Test-purpose (unit test; local test folder):** `test-json-format` / `fence-test`. Type 0 does **not** mean “unit test.” Testers **MUST NOT** queue or dest-write. |
| **Type 1** | Elevated (password `sudo` / already-root) | Host admin | `setup` (create `dns-adm` + F3/F5/F6), `remove-lpu` |
| **Type 2** | Dedicated LPU | `dns-adm` | Default-vault `vault` + `add` / `update` / `remove` / `status` / `show` |

### 2.1a Role table (print sudoer file + JSON submit)

**P-M0.** This file **MUST** publish the privilege role table. Full actor rows for the JSON grant live in `requirement-sudoer-json-file` §2.0. DNS inbound roles live in `requirement-dns-actor-table`. **MUST NOT** merge those three tables into one account.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Printer** | Any login | **0** | `print-sudoers` — print the **sudoer file** (Table A `sudoers(5)` text) to stdout or a user-writable path | Write F6 dest `/etc/dns-adm/sudoers`; write `/etc/sudoers.d`; write `/etc/passwd` |
| **Generator** | Any login | **0** | `generate-sudoer-request` — independent JSON sudoer file | Write inbound or `/etc` |
| **Submitter** | Same login as JSON `username` | **0** | `submit-sudoer-request` — queue **`type-2-switch`** JSON to sibling `sudoer-cli`. **No sudo.** | Queue `login-hook-elev`; `mkdir` inbound; approve; write `/etc/sudoers.d` |
| **Hook auto-submitter** | Host admin | **1** | `setup` (password `sudo`) **writes** **`login-hook-elev`** inbound when sibling exists. Dest Type 0 self-scope **MUST NOT** apply. **MUST NOT** `chown` inbound | Fail setup when sibling is absent; write `/etc/sudoers.d`; `chown` inbound to `dns-adm`; call dest Type 0 `add-sudoer-request` |
| **Subject** | Same person as the submitter | — | Appear in JSON `username` | Be another login |
| **Sibling approver** | `sudoer-adm` | **1** (sibling product) | Take ownership of inbound JSON; then move; dest `/etc/sudoers.d/dns-cli-<user>` | Be `dns-adm`; be this CLI |
| **F6 installer** | Host admin | **1** | `setup` writes the printed sudoer file to `/etc/dns-adm/sudoers` | Write `/etc/sudoers.d` from this product |
| **Type 2 operator** | `dns-adm` | **2** | Default-vault vault/DNS after a live grant | Print/submit as dest writer; approve sibling inbound |
| **DNS approver** | `dns-adm` | **1** | `chown` to `dns-adm` then move DNS inbound — `requirement-dns-actor-table` ACT-M6 | Approve sudoer JSON; move without taking ownership |

**Account map:** printer/generator/submitter = invoking login; Type 2 + DNS approver = `dns-adm`; sibling approver = `sudoer-adm`; F6 installer = euid 0.

**P-M1.** Every routed command **MUST** sit in exactly one layer (or document a Type 0 entry with an explicit Type 1/2 sub-step).

**P-M2.** Prefer the lowest safe layer. Cloudflare HTTPS is not a reason to run as root.

**P-M3.** Type 1 **MUST** use in-tool password `sudo` (or already-root) for Table C jobs. **MUST NOT** be `sudo -n` for `setup` / `remove-lpu`. **MUST NOT** require `SUDO_USER` to be `dns-adm` (**T1-BOOTSTRAP-N**).

**P-M4.** Type 2 default-vault ops: if euid is not `dns-adm`, the CLI **MUST** re-exec `sudo -u dns-adm` of the **managed global** binary (Table A). If that sudo is unavailable → `lpu_required`. Specified `--vault-dir` **MUST NOT** force this switch.

### 2.2 Table A — Sudoers Cmnd set (fragment contents only)

Not a live-command whitelist. `print-sudoers` and dest `/etc/dns-adm/sudoers` **MUST** be ⊆ these rows.

| ID | Job | Binary (absolute) | Fixed args | Source | Dest | Invoker CLI | Run-as | NOPASSWD? | Sudoers line shape |
|----|-----|-------------------|------------|--------|------|-------------|--------|-----------|--------------------|
| **ELEV-CF-01** | Run managed dns-cli as `dns-adm` | `${GLOBAL_BIN}/dns-cli` (`/usr/local/bin/dns-cli`) | (none — argv follows) | — | F6 dest `/etc/dns-adm/sudoers` **and** sibling dest `/etc/sudoers.d/dns-cli-<user>` | Type 2 context-switch; operator `sudo -u dns-adm dns-cli …` | `dns-adm` | yes | `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` (F6 group) · `<user> ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` (`type-2-switch` JSON) |
| **ELEV-CF-02** | Login hook `sudo -n` review verb | `${GLOBAL_BIN}/dns-cli` | `interactive` | — | Sibling dest `/etc/sudoers.d/dns-cli-dns-adm` (not F6) | Type 1 `interactive` after TTY login as `dns-adm` | `root` | yes | `dns-adm ALL=(root) NOPASSWD: /usr/local/bin/dns-cli interactive` (`login-hook-elev` JSON) |

**P-M5.** Production fragment **MUST NOT** elevate `${USER_BIN}/dns-cli`. Local-only install is **test_local** — `setup` **SHOULD** refuse to install F6 dest unless a global managed binary exists, or warn TEST MODE and require `--force`.

### 2.3 Table B — Forbidden in sudoers

| ID | Forbidden | Why |
|----|-----------|-----|
| **FORB-01** | `ALL=(ALL) ALL` / `NOPASSWD: ALL` | Broad admin |
| **FORB-02** | Bare `/bin/sh` / `/bin/bash` / `su` as Cmnd | Residual shell |
| **FORB-03** | `useradd` / `userdel` / `visudo` / package managers | Table C / wrong surface |
| **FORB-04** | Write `/etc/sudoers.d` or `/etc/passwd` | Dest is `/etc/dns-adm/sudoers` |
| **FORB-05** | Elevate `/tmp/…` or `${USER_BIN}/dns-cli` under production Pass | Trust tier |

### 2.4 Table C — Script jobs (not sudoers)

| Job | Tool | When |
|-----|------|------|
| Create account + home | `sudo useradd` | Type 1 `setup` |
| Create group if needed | `sudo groupadd` | Type 1 `setup` |
| Install F6 dest | `visudo -c` then `install -m 0440` as root | Type 1 `setup` |
| Backup F6 | copy → `/etc/sudoer-backup/` | `setup` rewrite / `remove-lpu` |
| Remove account | `sudo userdel -r` | Type 1 `remove-lpu` |

Unlisted live tools are **not** forbidden. **MUST NOT** copy Table C into the fragment.

### 2.5 Commands owned here

| Command | Type | Behavior |
|---------|------|----------|
| `setup` | Type 1 | Create `dns-adm` + F3 + F5 + F6 dest. Heal login-hook rc. **Auto-queue** `login-hook-elev` when sibling `sudoer-cli` + `sudoer-adm` + inbound exist; skip when missing. Idempotent. Password `sudo` / already-root |
| `remove-lpu` | Type 1 | F7 order in LPU law. Confirm unless `--force` |
| `print-sudoers` | Type 0 | **Print the sudoer file** (Table A ELEV-CF-01 `sudoers(5)` text) to stdout or a user-writable path. **MUST NOT** write F6 dest or `/etc/sudoers.d`. Human output **MUST** include admin steps: `visudo -c`, mode `0440`, dest `/etc/dns-adm/sudoers` |
| `generate-sudoer-request` | Type 0 | Independent JSON dest. Default `kind=type-2-switch`. `--kind login-hook-elev` writes the hook fixture only. **MUST NOT** write inbound or `/etc`. Body: `requirement-sudoer-json-file` |
| `submit-sudoer-request` | Type 0 | Detect sibling `sudoer-cli` + inbound; queue **`type-2-switch` only**. **MUST NOT** queue `login-hook-elev`. **MUST NOT** `mkdir` inbound or write `/etc/sudoers.d` |
| `submit` | Type 0 | Inbound **DNS** JSON drop — **Implemented** 1.9.0 (`requirement-dns-actor-table`). Not the sudoer submit verb |
| `approve` / `reject` / `interactive` | Type 1 | Approver `chown` to `dns-adm` then move; login-hook one-off yes/no approval question — **Implemented** 1.9.3; runas **`dns-adm`** after F6 (same LPU as Type 2 vault/DNS)

**P-M6.** `print-sudoers` **MUST** end with a newline plus extra blank line. **MUST NOT** contain tokens, keys, or passwords.

**P-M7.** Trimmed parent verbs `print-sudoers-install-script` and `remove-project-sudoers` **MUST** remain unknown. `generate-sudoer-request` and `submit-sudoer-request` **MUST** stay routed.

**P-M8.** Generate dest default `${HOME}/.config/dns-cli/sudoer-request-<user>.json`. Path operand overrides. **MUST** refuse `/etc` and `/var/sudoer-cli`. `--json` **MUST** include `path`.

**P-M9.** Type 0 submit default action is **update** when `/etc/sudoers.d/dns-cli-<user>` exists; else **add**. `--add` / `--update` override. F6 dest **MUST NOT** count as that probe. Missing dest CLI / approver / inbound → fail closed; next `sudo sudoer-cli setup`. Type 0 **MUST** refuse `kind=login-hook-elev`.

**P-M10.** Type 1 `setup` **MUST** auto-queue `login-hook-elev` when sibling CLI + `sudoer-adm` + writable inbound exist (action **update** when `/etc/sudoers.d/dns-cli-dns-adm` exists). **MUST** write inbound with dest request-id grammar. **MUST NOT** call dest Type 0 `add-sudoer-request`. Dest Type 0 self-scope (`username` == `id -un`) **MUST NOT** apply to `setup` — that check is a **blockage**, not dest approval. Missing sibling → skip; setup still succeeds. **MUST NOT** `mkdir` inbound, **`chown` inbound**, or write `/etc/sudoers.d`. `--json` **MUST** include `login_hook_sudoer`.

**P-M11. Submit vs setup door.** `submit-sudoer-request` is Type 0: current login, **no sudo**, `type-2-switch` only. `setup` is Type 1: host admin, **password `sudo` / already root**. Dest approval reviews the JSON and does **not** test who submitted. **MUST NOT** confuse these doors.

**P-M12. Three dests.** After sibling approve: Type 0 switch dest is `/etc/sudoers.d/dns-cli-<user>` (invoker). Setup hook dest is `/etc/sudoers.d/dns-cli-dns-adm`. F6 is `/etc/dns-adm/sudoers`. Type 2 default-ops re-exec uses F6 **or** the **invoker** sibling dest — **not** `dns-cli-dns-adm` (that dest is hook `interactive` only). **MUST NOT** describe `setup` as writing `dns-cli-<invoker>`. Portable: **`LM-SUDOER-JSON-FILE`** §3.4c · **`LM-THREE-LAYER-PRIVILEGE-MODEL`** 2.13.0.

**P-M13. Queue ownership.** Type 1 `setup` and Type 0 `submit-sudoer-request` **MUST NOT** `chown` dest inbound JSON. Dest **`sudoer-adm`** takes ownership, then moves. DNS `approve` / `reject` **MUST** take file-ownership as `dns-adm` **before** any inbound → accepted/declined move. Login-hook `interactive` (`dns-adm` via `sudo -n`) **MUST** take file-ownership of inbound as `dns-adm` **at the beginning**, then review. JSON username field ≠ Unix owner. Incident **INC-20260818-003**.

**Dest approval fencing conditions (closed).** Dest `approve` / `reject` / review **MUST** fail closed on inbound **only** for **incorrect JSON format**. Dest **MUST NOT** add extra fencing conditions. Catalog owner: `requirement-approval-fencing-condition`. Fence meaning: `requirement-incorrect-json-format`.

| Condition | Dest approve / reject / review |
|-----------|--------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — take ownership as dest LPU |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON username field ≠ dest LPU | **MUST NOT** fence |
| Filename subject token ≠ JSON username field | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it after format check |
| `submit_app` ≠ dest `APP_NAME` / `submit_version` ≠ dest `VERSION` | **MUST NOT** fence — Type 0 stamps live Config; sibling submitters and mixed versions are dest-legal JSON |

**Incorrect JSON format** includes: not a regular file; not one parseable JSON object; closed-schema fail; field types/enums invalid; basename grammar fail; basename **action** ≠ JSON `action`. Dest **MUST NOT** take the user from the filename; user SSOT is the JSON username field. Type 0 submit self-scope and Type 1 **authz** are **not** dest inbound-file fences. Peer: `requirement-dns-actor-table` ACT-M8 · `requirement-sudoer-json-file` SJ-M5.

### 2.5a Sample invocations (CI-M1a)

```sh
dns-cli setup
sudo dns-cli setup
dns-cli remove-lpu
sudo dns-cli remove-lpu
sudo dns-cli remove-lpu --force
dns-cli print-sudoers
dns-cli print-sudoers "${HOME}/.config/dns-cli/sudoers.draft"
dns-cli generate-sudoer-request
dns-cli generate-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli generate-sudoer-request --kind login-hook-elev
dns-cli submit-sudoer-request
dns-cli submit-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli submit-sudoer-request --add
dns-cli submit-sudoer-request --update
sudo -n -u dns-adm dns-cli vault show
sudo -n -u dns-adm dns-cli status home
```

`print-sudoers` does **not** write `/etc/dns-adm/sudoers`. `generate-sudoer-request` does **not** write inbound. `submit-sudoer-request` does **not** write `/etc/sudoers.d`. DNS inbound `submit` is **not** this family.

### 2.6 Example fragment (product — review before dest install)

```sudoers
# dns-cli — run managed CLI as dns-adm (review before install)
# Generated: dns-cli print-sudoers
# Dest: /etc/dns-adm/sudoers
# Admin: visudo -c -f DEST && install -m 0440 DEST /etc/dns-adm/sudoers
# Trust: production only when /usr/local/bin/dns-cli is the managed binary

%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli

```

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Type 2 user** | `dns-adm` |
| **Print command** | `print-sudoers` |
| **Generate command** | `generate-sudoer-request` |
| **Generate dest** | `${HOME}/.config/dns-cli/sudoer-request-<user>.json` |
| **Submit command** | `submit-sudoer-request` |
| **Approval dest** | `sudoer-cli` / inbound `/var/sudoer-cli/sudoer-request` |
| **Admin install-script** | **N/A** — Type 1 `setup` writes F6 dest; sibling approve writes `/etc/sudoers.d/dns-cli-<user>` |
| **Draft path** | stdout, or optional user-writable path argument |
| **Installed dest (F6)** | `/etc/dns-adm/sudoers` |
| **JSON body SSOT** | `requirement-sudoer-json-file` |
| **Elev-table SSOT** | **this file** |
| **Trust tier** | production = global managed binary; USER_BIN = test_local (`--allow-test-local`) |
| **Handlers (target)** | `lpu_setup`, `lpu_remove`, `lpu_print_sudoers`, `lpu_generate_sudoer_request`, `lpu_submit_sudoer_request`, `lpu_submit_login_hook_sudoer_request`, `lpu_type2_maybe_reexec` |
| **Ship unit** | **Implemented** Type 1 + print + generate/submit on **1.6.0**; Type 2 switch **1.8.2** |
| **Proof family** | **TP-PRIV-01..08** + **TP-SUDOER-JSON-01..03/08** have |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: Explicit Type 0/1/2.  
- **CIAO Principle 10 – Least privilege**: Fragment runas `dns-adm`, never root ALL.  
- **CIAO Principle 1 – Caution**: Password `sudo` is approval for `setup`.  
- **CIAO Principle 21 – Dual policies**: Filled tables; no hollow “uses sudo.”

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Table A is fragment lines only.  
- **Intentional:** Bootstrap vs day-to-day are different layers.  
- **Anti-fragile:** Specify-vault QA stays Type 0.  
- **Over-protect:** No `/etc/sudoers.d`; dest backups under `/etc/sudoer-backup/`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Collapse Type 0/1/2 into “just run as root.”  
2. Put `useradd` in sudoers.  
3. Write `/etc/passwd` or `/etc/sudoers.d`.  
4. Elevate `${USER_BIN}/dns-cli` under a production Pass.  
5. Reintroduce `print-sudoers-install-script` / `remove-project-sudoers` / backup / restore without a new user order. Do **not** treat generate/submit as those extras.  
6. Invent a live-command denylist beyond Table B.  
7. Claim Type 1 Implemented while `setup` is absent.  
8. Duplicate Tables A/B/C in the domain or LPU files.  
9. Drop the §2.1a role table or merge printer/submitter/`sudoer-adm` into the DNS actor table.  
10. `chown` dest inbound JSON from Type 1 `setup` or Type 0 submit. Dest **`sudoer-adm`** takes ownership.  
11. Move DNS inbound → accepted/declined **without** a prior `chown` to `dns-adm`.  
12. Add a dest inbound fence that is not **incorrect JSON format** (who submitted, dest Type 0 self-scope, JSON username ≠ dest LPU).

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-P1 | Help (when routed) lists `setup` / `remove-lpu` / `print-sudoers` / `generate-sudoer-request` / `submit-sudoer-request` and does not list backup/restore/install-script |
| AC-P2 | `print-sudoers` writes no dest and matches Table A |
| AC-P3 | `setup` uses password `sudo` or already-root — not `sudo -n` |
| AC-P10 | Submit vs setup door: Type 0 submit ≠ Type 1 setup; dest Type 0 self-scope MUST NOT apply to setup |
| AC-P4 | Default-vault DNS as a non-`dns-adm` user needs Table A or fails `lpu_required` |
| AC-P5 | Stay-honest: Type 1 + generate/submit Implemented on 1.6.0; Type 2 default-vault switch Implemented on 1.8.2 |
| AC-P6 | Independent generate dest is invoking-user readable; submit does not write `/etc/sudoers.d` |
| AC-P7 | Role table present (printer / generator / submitter / sibling approver / F6 installer / Type 2); not merged with the DNS actor table |
| AC-P11 | Three dests named: `/etc/sudoers.d/dns-cli-<user>` (switch), `/etc/sudoers.d/dns-cli-dns-adm` (hook), `/etc/dns-adm/sudoers` (F6) |
| AC-P12 | Setup/submit MUST NOT `chown` dest inbound; DNS queue move `chown`s to `dns-adm` first (P-M13) |
| AC-P13 | Dest approval fencing conditions closed: dest inbound fence is incorrect JSON format only (P-M13) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-least-privilege-user` | F1–F7 identity |
| `requirement-sudoer-json-file` | JSON grant body + generate dest shape |
| `requirement-shell-cli-interface` | Dispatch + privilege column |
| `requirement-domain-cloudflare-dns` | Type 2 verb catalog |
| `requirement-application-local-vault` | Specify stays Type 0 |
| `requirement-bootstrap-chain` | Backup/restore still absent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-PRIV-01** | `tests/test_cf_lpu.sh` | have | `print-sudoers` ⊆ Table A; no dest write |
| **TP-PRIV-02** | `tests/test_cf_lpu.sh` | have | unknown: install-script / remove-project-sudoers / backup / restore |
| **TP-PRIV-03** | `tests/test_cf_lpu.sh` | have | `setup` without root/sudo fails closed |
| **TP-PRIV-04** | `tests/test_cf_lpu.sh` | have | fragment has no ALL / no shell |
| **TP-PRIV-05..08** | `tests/test_cf_lpu.sh` | have | generate dest / submit fail-closed / stub inbound / refuse OS-tool |
| **TP-SUDOER-JSON-01..03,08,10..15** | `tests/test_cf_lpu.sh` | have | JSON body identity + two kinds + setup auto-submit |
| **TP-PRIV-09** | `tests/test_cf_lpu.sh` | have | §2.1a role table (printer / generator / submitter) |
| **TP-PRIV-10** | `tests/test_cf_lpu.sh` | have | P-M13 dest inbound fence is incorrect JSON format only |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.12.0 | Dest Fence row points at `requirement-incorrect-json-format` |
| 2026-08-19 | Active 1.11.0 | P-M13 user SSOT is the JSON username field, not the filename token |
| 2026-08-19 | Active 1.10.0 | P-M13 login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-18 | Active 1.9.0 | P-M13 dest approval fencing conditions closed: incorrect JSON format only |
| 2026-08-18 | Active 1.8.0 | P-M13 setup/submit MUST NOT `chown` dest inbound; DNS queue move `chown`s first (INC-20260818-003) |
| 2026-08-18 | Active 1.7.0 | P-M12 three dests: switch=`dns-cli-<user>`; hook=`dns-cli-dns-adm`; F6 group |
| 2026-08-18 | Active 1.6.0 | Type 2 default-vault switch Implemented (1.8.2 / TP-LPU-03) |
| 2026-08-18 | Active 1.5.0 | P-M11 submit-vs-setup door; dest Type 0 self-scope MUST NOT apply to setup |
| 2026-08-18 | Active 1.4.0 | Two JSON kinds; ELEV-CF-02 login-hook; setup auto-queue; Type 0 submit stays type-2-switch |
| 2026-08-18 | Active 1.3.0 | CI-M1a sample invocations for setup / remove-lpu / print / generate / submit |
| 2026-08-18 | Active 1.2.0 | Role table for print sudoer file + JSON submit; `print-sudoers` named as print-file |
| 2026-08-18 | Active 1.1.0 | generate/submit JSON sudoer Implemented (1.6.0); still not a sudoers-manager |
| 2026-08-18 | Active 1.0.0 | Type 1 + print-sudoers Implemented (1.5.0); Type 2 Gap |
| 2026-08-17 | Active 1.0.0 | Type map + Tables A/B/C for `dns-adm`; implementation Gap |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
