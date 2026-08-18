# Review: requirement coverage (sufficient check)

**Date:** 2026-08-18  
**Skill:** `SK-REQUIREMENT-SUFFICIENT-CHECK`  
**Claim:** **C-full-product** (user asked “review coverage of requirements”; domain surface is non-trivial)  
**Ship unit:** `src/dns-cli` **1.4.0**  
**Registry:** 22 Active `requirement-*.md` (index matches disk)  
**Verdict:** **Sufficient with Gaps** (P1/P2 honesty + TTY fixes applied 2026-08-18; inbound/LPU remain Gap)

---

## Claim

- **ID:** C-full-product  
- **Text:** Registered product law is sufficient to own the live dns-cli ship unit, including Type 0 lifecycle, vault/DNS domain surface, and the declared LPU/approval machine (honest Gaps allowed).

---

## SSOT preflight

| Concern | Primary (disk) | Claimant | Verdict |
|---------|----------------|----------|---------|
| identity-runtime | Config `APP_NAME="dns-cli"` | README H1 `dns-cli`; index `dns-cli` | **aligned** |
| version | Config `VERSION="1.4.0"` | README badge 1.4.0 | **aligned** |
| install-channel | `SCRIPT_URL` empty | README local-only; index Absent | **aligned** |
| forge owner | Config `REPO_USER=cloudgen` `REPO_NAME=dns-cli` | README Stars `cloudgen/dns-cli` | **aligned** |
| local identity note | `docs/REPO_IDENTITY.md` version **1.1.0**, visibility **private** | Config/README **1.4.0** / public remote | **C8/C5 conflict** (local note stale) |

**Identity for this coverage run:** Config + README win machine/docs identity. `REPO_IDENTITY.md` is a local note, not product law — **not** Blocked-pending-user for C-full-product. Menu (do not auto-edit): update the note to 1.4.0 / public, or keep as historical.

Some Implementation Notes still say ship **1.2.0** (`requirement-cloudflare-dns-request`, vault header) or **A-record mode Gap** (`requirement-domain-cloudflare-dns` §2.6) while 1.4.0 implements stored mode. That is **stale Gap wording**, not an identity block.

---

## Registered law

- Registry rows: **22**  
- Files on disk: **22** (no orphan / phantom)  
- Domain requirements present: **yes** — `requirement-domain-cloudflare-dns` (exactly one `requirement-domain-*`) plus vault / API / mode / request  
- Intentionally absent (index): online install, self-update, checksum channel, folder-backup, sudoers-manager extras  

---

## Live surfaces (summary)

**Lifecycle (Type 0):** empty argv → help; `install` / `uninstall` / `where-is-me` / `version` / `about` / `help`

**Domain (Type 0):** `vault` (`input`/`set`/`init`/`show`/`clear`; `account`/`zone` add|list|modify|remove; `subdomain` add|list|modify|remove|mode); `ip`; `add`; `update`; `remove`; `status`|`show`

**Flags:** `--quiet`/`-q` `--json` `--debug` `--force` `--global` `--ip` `--subdomain` `--zone-id` `--account-id` `--domain`/`--domain-id` `--user-id` `--ttl` `--proxied` `--token-file` `--vault-dir` `--mode` `--from` `--label`

**Help-only ads:** none. Help **does not** list `submit` / `approve` / `reject` / `interactive` / `setup` / `print-sudoers` / `remove-lpu` (fail closed as unknown — matches ACT-M5).

**Install-mode:** local-only (`install` + `uninstall` + `where-is-me`). `SCRIPT_URL` empty. **OK** for local claim. Local vs `--global` is install *location*, not an online channel.

---

## Ownership matrix

| Live surface | Class | Owner | Status |
|--------------|-------|-------|--------|
| Config `APP_NAME` / `VERSION` / `REPO_*` | identity | class + bootstrap-chain + local-self-management | ok |
| `install` / `uninstall` / `where-is-me` | lifecycle | `requirement-shell-local-self-management` | ok |
| empty argv / `help` | lifecycle | `requirement-shell-cli-zero-arguments` | ok |
| `version` / `about` / flags / dispatch | lifecycle | `requirement-shell-cli-interface` | ok |
| `out_*` / `--json` / `--quiet` | output | `requirement-shell-output-requirements` | ok |
| prefixes `out_`/`inst_`/`app_`/`cf_`/`lpu_` | structure | `requirement-shell-modular-function-design` | ok |
| re-install / uninstall / vault / DNS re-run | lifecycle | `requirement-shell-idempotency` | ok |
| uninstall / vault confirm / TTY | mode | `requirement-shell-interactive-vs-noninteractive` | ok / **Gap** (Step 3d) |
| scratch `EFFECTIVE_STORAGE_DIR` | storage | `requirement-shell-cli-storage` | ok |
| `--vault-dir` / `CF_VAULT_DIR` | vault path | `requirement-application-local-vault` | ok (LPU default dest **Gap**) |
| `vault account`/`zone`/`subdomain` / `input`/`set` | domain | `requirement-cloudflare-vault` | ok (LPU dest **Gap**) |
| `add`/`update`/`remove`/`status`/`show` | domain | `requirement-domain-cloudflare-dns` | ok (Type 2 as `dns-adm` **Gap**) |
| `--mode` / `vault subdomain mode` | domain | `requirement-cloudflare-dns-mode` | ok (notes on domain REQ still say Gap — honesty) |
| `ip` / `--ip` | domain/shell | `requirement-external-ipv4` | ok |
| HTTPS token / envelope / A CRUD | domain | `requirement-cloudflare-api` | ok (pagination **todo** in matrix) |
| inbound JSON types | domain | `requirement-cloudflare-dns-request` | **honest Gap** (law + samples; no routes) |
| `submit`/`approve`/`reject`/`interactive` | workflow | `requirement-dns-actor-table` + three-layer | **honest Gap** (unrouted; not advertised) |
| login-hook heal | approver | `requirement-dns-approver` | ok (heal **Implemented**; `interactive` **Gap**) |
| LPU `dns-adm` F1–F7 | operator | `requirement-least-privilege-user` | **honest Gap** (no `setup`) |
| `setup` / `print-sudoers` / `remove-lpu` | privilege | `requirement-three-layer-privilege-model` | **honest Gap** (not in dispatcher) |
| residual stack / no online | class | `requirement-class-software-dev` | ok |
| hop A=`cli-template` B=`dns-cli` | architecture | `requirement-bootstrap-chain` | ok (notes still say v2 vault **Gap** — stale) |
| project layout `src/dns-cli` | architecture | `requirement-project-folder` | ok |

No **unowned** live dispatcher command.

---

## Artifact filename + content

| Kind | Filename grammar | Sample basename | Content structure | Sample body (per variant) | Paired convert | Status |
|------|------------------|-----------------|-------------------|---------------------------|----------------|--------|
| DNS request JSON | yes (`YYYYMMDD-subject-action-n.json`) | yes (`20260817-alice-add-1.json`) | yes (closed keys + per-type table) | yes (`add`/`update`/`remove`/`mode` in REQ) | n/a (JSON only) | **ok** (ship inbound **Gap**) |
| Vault token file | 0600 file inside vault; never `--token` | path class, not sequenced name | “token file” | n/a (secret — must not sample live token) | n/a | **ok** |
| Login hook / `.profile` | n/a (rc markers) | n/a | complete snippet in actor + approver REQs | yes | n/a | **ok** |
| F6 sudoers dest | dest `/etc/dns-adm/sudoers` | dest path | Table A in three-layer REQ | **Gap-no-sample** (no complete fragment body in LPU/three-layer) | n/a | **Gap-no-sample** (verb also Gap) |

---

## TTY measurement (Step 3d)

- In scope: **yes** (uninstall confirm, vault input, future `remove-lpu`)  
- Measure outside functions: **partial** — `src/dns-cli:104` sets `TTY=1` at boot; `about` still live-probes `[ -t 1 ]`  
- Helpers consume `TTY`: **Gap** — `prompt_yes_no` uses live `[ -t 0 ]` / `[ -t 1 ]` (`src/dns-cli:1068–1070`)  
- Owning REQ (`requirement-shell-interactive-vs-noninteractive` §2.2) names `TTY=1` but does **not** state measure-outside-functions / helpers-must-not-retest  

---

## Named workflow machine (Step 3e)

- In scope: **yes**  
- Named machine: folder = state, JSON = proposal (`requirement-dns-actor-table` + domain + request)  
- Roles: submitter anyone / subject self / approver `dns-adm` / allocator Type 0 `submit` — **yes**  
- Submit-when + not-a-submit: **yes** (§2.3)  
- Verify at submit and approve: **yes** (§2.4)  
- Ship: **honest Gap** (no inbound routes)

---

## TTY approver path (Step 3f)

- In scope: **yes**  
- Authz table: euid 0 or `dns-adm` Type 1 — **yes** (actor + three-layer)  
- Review loop: listed; consume-`TTY`; `--json` fail closed — **yes** in law; **Gap** in ship  
- Hook sample: complete in actor §2.6 + approver §2.4 — **yes**  
- Empty argv stays help: **yes** (ACT-M5; dispatcher)  
- Honesty: heal **Implemented**; `interactive` **Gap** — **yes**

---

## LPU / LPA operator (Step 3g)

- In scope: **yes** (`dns-adm` is Type 2 vault operator **and** Type 1 approver)  
- LPU F1–F7 in `requirement-least-privilege-user`: law **scored** (F4 none; F3/F5/F6 dest named)  
- Ship `setup` / `useradd` / F6 write: **absent** → **SK-CREATE-LEAST-PRIVILEGE-SYSTEM-USER review = Gap** (not Block: law exists)  
- LPA extras: one subject (DNS request JSON); machine named → terminology **Pass**; ship submit/approve **Gap**  
- **SK-CREATE-LEAST-PRIVILEGE-APPROVER-TERMINOLOGY review = Gap** on ship; law present  

---

## Honesty / consistency

- Help ↔ dispatcher: **clean** for live verbs; Gap verbs correctly omitted.  
- False Implemented: **none** found for inbound / LPU / Type 1.  
- **False Gap / stale notes:**  
  - `requirement-domain-cloudflare-dns` §2.6 “A-record mode … **Gap** on ship unit” vs 1.4.0 + TP-CF-MODE have  
  - `requirement-bootstrap-chain` still says v2 vault **Gap**  
  - `requirement-cloudflare-dns-request` notes **1.2.0**; vault header **1.2.0**  
- Interactive notes: `prompt_secret` still labeled Gap while `prompt_secret()` exists at `src/dns-cli:1102` and `vault input` is live — stale Gap.  
- Git-surface: index does not dump harness path inventories.  
- Actor table example names host login `leolio` (versioned REQ) — host DNA, P2.

---

## Verdict

**Sufficient with Gaps**

Law owns every live dispatcher surface and the declared domain/approval/LPU machine. Critical unowned domain surface: **none**. Remaining work is **honest Gap** (LPU create, Type 1 setup/print-sudoers, inbound submit/approve/`interactive`) plus **note honesty** and **TTY helper SSOT**.

Do not treat Active file count (22) as “product done.”

---

## Recommendations

- **P0:** none for missing domain law.  
- **P1:** Align stale Gap/version notes (domain mode, bootstrap v2, 1.2.0 headers) to 1.4.0 disk.  
- **P1:** State in `requirement-shell-interactive-vs-noninteractive` that `[ -t` is measured outside functions and `prompt_*` consume `TTY`; stop live `[ -t` inside `prompt_yes_no`.  
- **P1:** When `setup`/`print-sudoers` is implemented, add a complete F6 fragment sample (Table A) to the owning REQ.  
- **P2:** Refresh `docs/REPO_IDENTITY.md` version/visibility (user menu).  
- **P2:** Replace host login `leolio` in the actor-table example with a portable example login.  
- **P2:** TP-CF-REQ / TP-LPU / TP-PRIV remain todo until those routes exist.

**Follow-up (2026-08-18 apply):** `prompt_*` + vault confirm gates consume `TTY`; interactive REQ 1.3.1; stale 1.2.0 / mode-Gap / v2-Gap / `cf-cli` workspace notes aligned; `REPO_IDENTITY.md` 1.4.0 public; actor-table host login removed. F6 fragment sample was already in `requirement-three-layer-privilege-model` §2.6. Inbound / LPU create / Type 1 `setup` remain honest Gap (not implemented in this pass).
