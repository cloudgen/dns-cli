**file**: docs/requirements/requirement-dns-actor-table.md  
**Status**: Active (Version 1.9.0) — interactive records original owner then dest-writes `submit_by`  
**Area**: architecture  
**Key**: `requirement-dns-actor-table`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **dns-cli dest actor table**: who may **submit** a DNS request JSON file, who may **approve** or reject it, and the **login-time interactive review** procedure (hook after TTY login). Dest is the Cloudflare DNS dest leaf. It is **not** the sudoer dest and **not** the nginx-conf dest. The product-wide actor / role / subject / approver catalog (including honest **None**) is `requirement-actor-role-subject-approver`.

The **machine** (folder = state, JSON = proposal, four request types) is owned with `requirement-domain-cloudflare-dns` and `requirement-cloudflare-dns-request`. This file owns **who** and the **approval procedure**. Privilege Types are `requirement-three-layer-privilege-model`. Type 2 vault operator identity is `requirement-least-privilege-user` (`dns-adm`).

This is **not** a second `requirement-domain-*`. It is **not** the sudoer print/submit role table (`requirement-sudoer-json-file` §2.0 / `requirement-three-layer-privilege-model` §2.1a). DNS `submit` ≠ `submit-sudoer-request`. Approver `dns-adm` ≠ sibling `sudoer-adm`.

### 1.1 Human-facing

**In one sentence:** **Anyone** may drop a request JSON for **themselves**; only **`dns-adm`** may accept or decline it after login review.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Submit a file about your own login | `dns-cli submit ./req.json` |
| Approver | `dns-adm` moves the file | `dns-cli approve` / `interactive` |
| Not this | Sudoer JSON to sibling `sudoer-cli` | `dns-cli submit-sudoer-request` |

| Includes | Excludes |
|----------|----------|
| Actor table + login review procedure | Second approver account |
| Dest fence = incorrect JSON format | Fence on Unix file owner or filename token as user |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/dns-cli/dns-request` | Waiting folder | Inbound |
| `dns-cli interactive` | Review | After `dns-adm` login |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Queue a DNS change | You cannot apply Cloudflare yourself | `dns-cli submit ./req.json` |
| Approve as `dns-adm` | Re-check JSON, take ownership, move | `dns-cli approve` |
| Log in as `dns-adm` | Review takes ownership, then asks **one** yes/no per file | (login hook → `interactive`) |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Actor table

**ACT-M1.** Product law and the product README **MUST** publish this actor table. Roles **MUST NOT** be collapsed.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Submitter** | **Anyone** — any login (`id -un`; example `alice`) | **0** | `submit` a self-scoped JSON file into inbound | Submit for another identity; approve/reject (unless this login is `dns-adm` using Type 1 verbs); write Cloudflare dest; choose the dest basename; hold or print the API token |
| **Subject** | Same person as the submitter | — | Appear in basename `subject` and JSON `subject` | Be another login |
| **Approver** | LPU **`dns-adm`** | **1** (after F6, or euid 0) | Re-check JSON + name; **`chown` to `dns-adm` first**, then **move** inbound → accepted/declined; on accept, apply dest (`add` / `update` / `remove` / `mode`) | Invent a second approver account; store the token in the request; move without taking ownership |
| **Allocator** | `dns-cli` Type 0 `submit` path | **0** | Allocate `YYYYMMDD-<subject>-<action>-<n>.json` | Trust `--name` / caller dest basename |
| **Root session** | euid 0 | **1** | Same Type 1 verbs as `dns-adm` | Submit a body whose subject is someone else |

**ACT-M2.** **`dns-adm` is the approver.** The same LPU is Type 2 for default-vault DNS and Type 1 for approve / `interactive`. **MUST NOT** invent a second account (`dns-apr` or similar).

**ACT-M3.** The API token **MUST** stay in the vault (0600 file). Request JSON **MUST NOT** include a `token` key (`requirement-cloudflare-dns-request`).

**ACT-M3a.** This table **MUST NOT** absorb printer / generator / `submit-sudoer-request` / `sudoer-adm`. Those roles stay on `requirement-sudoer-json-file` §2.0.

**ACT-M6. Queue move assumes prior ownership change (sacred).** Type 0 `submit` **MUST NOT** `chown` inbound JSON. `approve` / `reject` / `interactive` (login hook: `dns-adm` via `sudo -n`, process euid 0) **MUST** `chown` to **`dns-adm` first**, then move. Fail closed if that `chown` fails. CI stub (`CF_TEST_LPU=1`) **MAY** skip live `chown`. Term: `approval-queue-move`. Incident **INC-20260818-003**.

**ACT-M7. File-ownership is not a dest wall (sacred).** Dest `approve` / `reject` / `interactive` **MUST NOT** fence on Unix file-ownership (owner ≠ JSON `subject`, or owner ≠ `dns-adm`). JSON `subject` is the body identity key. When this app runs as **`dns-adm`**, it **MUST take** file-ownership, then move (ACT-M6). Self-scope is **submit-only** (`subject` = `id -un`).

**ACT-M8. Approval fencing conditions (closed, sacred).** Dest **MUST** run fencing **before** any approval question. This file-based JSON system **MUST** include **incorrect JSON format**. Dest `approve` / `reject` **MUST** fail closed on inbound **only** for that listed fence, with a **human-facing** sentence. Dest `interactive` **MUST** display the same sentence and **MUST NOT** ask yes/no for that file. Dest **MUST NOT** add extra fencing conditions.

| Condition | Dest approve / reject / interactive |
|-----------|-------------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — take ownership as `dns-adm` |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON `subject` ≠ `dns-adm` | **MUST NOT** fence |
| Filename subject token ≠ JSON `subject` | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it after format check |

**Incorrect JSON format** includes: not a regular file; not one parseable JSON object; closed-schema fail (`schema_version` 1, unknown keys, missing required, forbidden keys including `token`); field types/enums invalid; basename not `YYYYMMDD-subject-action-n.json`; basename `action` ≠ JSON `action`. Dest **MUST NOT** take the user from the filename; user SSOT is JSON `subject`. Type 0 submit self-scope is **not** a dest fencing condition. Who may run dest verbs is **authz**, not an inbound-file fence.

### 2.2 Account map

| Role | Account |
|------|---------|
| Submitter / subject | **Anyone** — any ordinary login (`id -un`) |
| Approver | `dns-adm` |
| Type 2 operator | `dns-adm` (same account; different command Type) |
| Root session | euid 0 |

### 2.3 When a normal user may submit

Type 0 `submit` is allowed **only when all** hold:

1. Invoker is **any** login user (including `dns-adm`).  
2. **Self-scope:** JSON `subject` equals `id -un`. That field is the **user SSOT**. On-behalf-of → fail closed. **MUST NOT** take the user from the filename. **MUST NOT** treat file-ownership as part of this fence.  
3. Body `action` is one of `add` / `update` / `remove` / `mode` (`requirement-cloudflare-dns-request`).  
4. Inbound exists and is writable. Type 0 **MUST NOT** `mkdir` production inbound.  
5. Allocator owns the basename.  
6. No `token` / IPv6 / unknown keys.

**Not a submit:** a change for a colleague; wanting Cloudflare written immediately; `approve` as a normal user; `status` / `show` / `ip`; `vault account add`.

### 2.4 Verify at submit and again at approve

| Check | Rule |
|-------|------|
| Closed schema | `schema_version` 1; unknown keys fail |
| Identity match | User SSOT is JSON `subject`, **not** the filename token. Basename **action** MAY still match JSON `action` |
| Self-scope | JSON `subject` = invoker at submit. Dest **MUST** read the user from JSON `subject`. **MUST NOT** require file-ownership = `subject` |
| File-ownership | Dest **MUST NOT** fence on Unix owner (ACT-M7). When run as `dns-adm`, **take** ownership, then move |
| Payload | IPv4 fields per `requirement-cloudflare-dns-request` + `requirement-external-ipv4` |
| Token | Body **MUST NOT** contain a token |
| Dest | Accept maps to DNS `add` / `update` / `remove` / `vault subdomain mode` using the **vault** token. **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d` |
| Re-validate | Approve **re-runs** format checks (ACT-M8). Dest inbound fence is **incorrect JSON format** only |

CLI `--json` is status only. It is **not** the request file.

### 2.5 Approval procedure (interactive hook after login)

**ACT-M4.** When implemented, TTY login as **`dns-adm`** **MUST** start review **once** per session via an rc hook. Empty argv of `dns-cli` **MUST** remain help.

Procedure:

1. `dns-adm` logs in on a keyboard TTY (SSH/console).  
2. Interactive rc (`.bashrc` only unless `.profile` exists and does **not** source `.bashrc`) runs the snippet in §2.6.  
3. Guards pass → `sudo -n /usr/local/bin/dns-cli interactive` (global binary only). The live grant is **`login-hook-elev`** (sibling dest after approve), **not** the Type 0 `type-2-switch` JSON and **not** F6 `%sudo ALL=(dns-adm)`.  
4. **At the beginning** of `interactive` (this login hook), dest **MUST** take file-ownership of inbound JSON as **`dns-adm`**. **Before** that `chown`, dest **MUST** read the original Unix file-ownership. Then dest **MUST** take ownership as `dns-adm`. Then dest **MUST** review JSON format. If the JSON is correct, dest **MUST** add `submit_by` (human: submit by) whose value is that original file-ownership. Dest **MUST NOT** add `submit_by` when format fails. Fail closed if that `chown` fails (CI stub `CF_TEST_LPU=1` **MAY** skip live `chown`). Type 0 `submit` **MUST NOT** include `submit_by`.  
5. Then `interactive` lists inbound JSON, one file at a time. Dest **MUST** handle **fencing first** (this file-based JSON system **MUST** include incorrect JSON format). Dest **MUST NOT** treat dest-written `submit_by` as an unknown key.  
6. If a fence **matches**: display the match in human-facing words (what happened / what it means / next). **MUST NOT** ask the approval question for that file. Continue to the next file.  
7. If **no** fence matched: show purpose + body; ask the **approval question** (term `approval-question`): **one-off yes/no**. **Yes** = approve. **No** (including Enter) = reject. **MUST NOT** offer skip / quit / maybe.  
8. Yes / no **MUST** then **move** (queue move **MUST** assume that previous ownership change — ACT-M6). Yes also applies the dest DNS/mode verb.  
9. Empty inbound → exit 0; login continues to a shell.  
10. `scp` / `SSH_ORIGINAL_COMMAND` / no TTY → hook **does nothing**.  
11. `sudo -n` fail → warning; login **continues**.  
12. `--force` **MUST NOT** auto-accept. `--json` / non-TTY `interactive` → fail closed.

**ACT-M5.** `submit` / `approve` / `reject` / `interactive` **MUST NOT** appear in `help` until `app_main` routes them. Until then they **MUST** fail as unknown (fail closed).

### 2.5a Sample invocations (CI-M1a)

These verbs are **Implemented** on ship unit **1.9.4**. They are **not** `submit-sudoer-request`.

```sh
dns-cli submit
dns-cli submit /home/alice/.config/dns-cli/dns-request.json
dns-cli approve
dns-cli reject
dns-cli interactive
sudo -n /usr/local/bin/dns-cli interactive
```

`submit` is Type 0 self-scope. `approve` / `reject` / `interactive` are Type 1 as `dns-adm` (or euid 0). Empty argv remains help.

### 2.6 Complete login-hook snippet (normative sample)

Markers: `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. Session guard **MUST** be set **before** `sudo -n`.

```sh
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ] \
    && [ -n "${PS1:-}" ] \
    && [ -t 0 ] && [ -t 1 ] \
    && case "$-" in *i*) true ;; *) false ;; esac \
    && [ "$(id -un)" = "dns-adm" ] \
    && [ -z "${SSH_ORIGINAL_COMMAND:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/dns-cli interactive; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed)" >&2
    fi
fi
# END dns-cli login hook
```

F7 **MUST** strip this block from whichever rc files contain it.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` **1.9.4** — approval system: fence first, human-facing match, then yes/no |
| **Inbound** | `/var/dns-cli/dns-request` (`3773`); archives `dns-accepted` / `dns-declined` (`0700`); F4 `${LPU_HOME}/dns-request` |
| **Submitter** | **Anyone** — any login (`id -un`; example `alice`) |
| **Approver** | `dns-adm` |
| **Type 2 operator** | `dns-adm` (same leaf) |
| **Review verb** | `interactive` |
| **Hook variable** | `DNS_CLI_HOOK_RAN` |
| **Inbound create** | Type 1 `setup` creates the trio; Type 0 does not `mkdir` |
| **Dest** | Cloudflare A / mode apply via vault — not `/etc/<subject>/dns` |
| **Proof** | **TP-CF-ACTOR-01..07** · **TP-CF-REQ-01..09** |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Hostile inbound; re-validate at approve; no token in the file.  
- **CIAO Principle 2 – Intentional**: Named actors; login hook is explicit `interactive`, not empty argv.  
- **CIAO Principle 9 – Three types**: Type 0 submit / Type 1 approve.  
- **CIAO Principle 10 – Least privilege**: One LPU `dns-adm` approves; any login may submit; token stays in the vault.  
- **CIAO Principle 16 – Interactive**: Hook skips scp/CI; `sudo -n` never blocks login.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not trust inbound inodes; skip non-TTY.  
- **Intentional:** One table for who; one hook for when.  
- **Anti-fragile:** `sudo -n` fail does not lock the approver out.  
- **Over-protect:** Help does not advertise unrouted verbs.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Invent a second approver account (`dns-apr` or similar). `dns-adm` **is** the approver.  
2. Restrict submit to a special submitter login — **anyone** may submit (self-scope).  
3. Claim submit / approve / interactive **Implemented** while `app_main` does not route them.  
4. Hijack empty argv as review.  
5. Hang `scp` / CI on the hook.  
6. Put a token in the actor table, hook snippet, or request JSON.  
7. Register this file as `requirement-domain-*`.  
8. Move inbound → accepted/declined **without** a prior `chown` to `dns-adm`.  
9. `chown` inbound DNS JSON from Type 0 `submit`.  
10. Fence dest approve on file-ownership (owner ≠ JSON `subject`). Dest **takes** ownership as `dns-adm`.  
11. Add a dest inbound fence that is not **incorrect JSON format** (who submitted, dest Type 0 self-scope, JSON `subject` ≠ `dns-adm`).  
12. Start login-hook `interactive` review **without** first taking inbound file-ownership as `dns-adm`.  
13. Replace the approval question with accept/decline/skip/quit (or add skip / quit / maybe). **Yes** = approve; **no** = reject.  
14. Ask yes/no **before** dest fencing, or hide a fence match behind jargon-only text.  
15. Drop incorrect JSON format from this file-based JSON dest fence table.

**Violating this rule is a critical privilege / stay-honest regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-ACT1 | Actor table present in this file **and** product README |
| AC-ACT2 | `dns-adm` is the only approver; anyone may submit |
| AC-ACT3 | Complete hook snippet present |
| AC-ACT4 | Routed `submit` / `approve` / `reject` / `interactive` are not unknown |
| AC-ACT5 | Help lists those verbs now that they are routed |
| AC-ACT6 | Empty argv is help |
| AC-ACT7 | Stay-honest: rc heal + review loop **Implemented** on 1.9.0; queue-move `chown` on 1.9.1 |
| AC-ACT8 | `approve` / `reject` / `interactive` `chown` to `dns-adm` before move; Type 0 `submit` does not `chown` (ACT-M6) |
| AC-ACT11 | Login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** (ACT-M4) |
| AC-ACT12 | Approval question is one-off yes/no: yes=approve, no=reject; no skip/quit (ACT-M4) |
| AC-ACT13 | Dest review fences first; match is human-facing; question only if clear (ACT-M4 / approval-system) |
| AC-ACT9 | Dest MUST NOT fence on file-ownership; JSON `subject` ≠ Unix owner (ACT-M7) |
| AC-ACT10 | Dest approval fencing conditions closed: dest inbound fence is incorrect JSON format only (ACT-M8) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-dns-approver` | Hook heal / `.bashrc` / `.profile` create |
| `requirement-domain-cloudflare-dns` | Consumes this table; names the machine |
| `requirement-cloudflare-dns-request` | Request JSON types |
| `requirement-three-layer-privilege-model` | Type 0 submit / Type 1 approve; sudoer print/submit role table is §2.1a there |
| `requirement-sudoer-json-file` | Sibling sudoer JSON roles — not this table |
| `requirement-least-privilege-user` | `dns-adm` is Type 2, not LPA |
| `requirement-shell-cli-interface` | Dispatch; help honesty |
| `requirement-shell-cli-zero-arguments` | Empty argv = help |
| `requirement-shell-interactive-vs-noninteractive` | TTY / `--json` fail closed |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-ACTOR-01** | `tests/test_cli.sh` | have | `submit` routed; no file fails closed |
| **TP-CF-ACTOR-02** | `tests/test_cli.sh` | have | `approve` routed |
| **TP-CF-ACTOR-03** | `tests/test_cli.sh` | have | `reject` routed |
| **TP-CF-ACTOR-04** | `tests/test_cli.sh` | have | `interactive` routed; `--json` fail closed |
| **TP-CF-ACTOR-05** | `tests/test_cli.sh` | have | help lists those verbs |
| **TP-CF-ACTOR-06** | `tests/test_cli.sh` | have | empty argv is help (peer TP-CLI-07) |
| **TP-CF-ACTOR-07** | `tests/test_cli.sh` | have | MUST NOT absorb printer / `submit-sudoer-request` / `sudoer-adm` |
| **TP-CF-REQ-09** | `tests/test_cf_request.sh` | have | `cf_req_move` `chown`s to LPU before `mv`; skip in `CF_TEST_LPU` |
| **TP-CF-REQ-11** | `tests/test_cf_request.sh` | have | login-hook `interactive` takes inbound ownership at the beginning |
| **TP-CF-REQ-12** | `tests/test_cf_request.sh` | have | approval question is one-off `prompt_yes_no` (yes=approve, no=reject) |
| **TP-CF-REQ-13** | `tests/test_cf_request.sh` | have | dest fence first; human-facing match; no question on match |
| **TP-CF-REQ-14** | `tests/test_cf_request.sh` | have | user SSOT is JSON `subject`; dest MUST NOT fence on filename token |
| **TP-CF-REQ-15** | `tests/test_cf_request.sh` | have | interactive records original owner; dest-writes `submit_by` if format is clear |
| **TP-CF-ACTOR-08** | `tests/test_cli.sh` | have | ACT-M7 dest MUST NOT fence on file-ownership |
| **TP-CF-ACTOR-09** | `tests/test_cli.sh` | have | ACT-M8 dest inbound fence is incorrect JSON format only |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.9.0 | ACT-M4 interactive records original file-ownership, then dest-writes `submit_by` if format is clear |
| 2026-08-19 | Active 1.8.0 | User SSOT is JSON `subject`, not the filename token (ACT-M8 MUST NOT row) |
| 2026-08-19 | Active 1.7.0 | Approval system: fence first, human-facing match, then yes/no; JSON format fence required |
| 2026-08-19 | Active 1.6.0 | ACT-M4 approval question is one-off yes/no (yes=approve, no=reject); term `approval-question` |
| 2026-08-19 | Active 1.5.0 | ACT-M4 login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-18 | Active 1.4.0 | ACT-M8 dest approval fencing conditions closed: incorrect JSON format only |
| 2026-08-18 | Active 1.3.0 | ACT-M7 dest MUST NOT fence on file-ownership; take it as `dns-adm` |
| 2026-08-18 | Active 1.2.0 | ACT-M6 queue move `chown`s to `dns-adm` first; submit MUST NOT (INC-20260818-003) |
| 2026-08-18 | Active 1.1.0 | submit / approve / reject / interactive Implemented (1.9.0) |
| 2026-08-18 | Active 1.0.3 | CI-M1a sample invocations for submit / approve / reject / interactive |
| 2026-08-18 | Active 1.0.2 | Point at sudoer print/submit role table; do not merge |
| 2026-08-17 | Active 1.0.1 | Approver is `dns-adm`; anyone may submit; no `dns-apr` |
| 2026-08-17 | Active 1.0.0 | Actor table + login hook law; ship unit Gap |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
