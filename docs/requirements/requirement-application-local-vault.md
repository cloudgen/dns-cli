**file**: docs/requirements/requirement-application-local-vault.md  
**Status**: Active (Version 2.4.0)  
**Area**: shell  
**Key**: `requirement-application-local-vault`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for **where** dns-cli’s **local application vault** lives and **how the operator specifies** it. Every dest on this file is **local vaults** of the account that owns the tree. The Type 2 dest is `dns-adm`’s local vaults; from an ordinary login that dest is the **global vault** (out-of-account store).

`requirement-cloudflare-vault.md` **consumes** this path for multi-account schema, per-domain-id token files, and `vault` verbs. LPU home vs affected-folder ownership lives in `requirement-least-privilege-user`. This file is **not** a second domain catalog, **not** SSH identity, **not** the operator GitHub API plane, and **not** a host archive deposit.

**Two dest families (do not collapse):**

| Family | Path | Who | When |
|--------|------|-----|------|
| **Type 2 production default** | `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` (`SYSTEM_USER_HOME` = F3 of `dns-adm`) | `dns-adm` | Day-to-day Cloudflare vault I/O with no `--vault-dir` |
| **Type 0 specify / QA** | Absolute `--vault-dir` / `CF_VAULT_DIR`. **MAY** be `${HOME}/.local/vaults/dns-cli/` (invoking-user child under that login’s local vaults root) | Invoking login | Tests, live-operator QA; LPU need not exist |

### 1.1 Human-facing

**In one sentence:** Production tokens live under **`dns-adm`’s** local vaults; from your login that folder is the **global vault** (outside your account) — `--vault-dir` is **your** local vaults for tests.

| Box | Meaning | Example |
|-----|---------|---------|
| You (ordinary login) | `dns-adm` dest is your **global vault** | keep a token off your account |
| Dedicated account | Their **local vaults** (same folder) | `dns-adm` home → `.local/vaults/dns-cli/` |
| Not this file | What keys live inside; host archives | `requirement-cloudflare-vault` |

| Includes | Excludes |
|----------|----------|
| Default dest vs `--vault-dir` | SSH keys / GitHub API vault |
| Who may use the default dest | Zone CRUD field table |

| Surface | What you open | What for |
|---------|---------------|----------|
| Default vault dir | Directory 0700 | Production tokens |
| `--vault-dir PATH` | Flag | QA without `dns-adm` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Keep a token off your own account | Store it under `dns-adm` — that dest is your global vault | (operate as `dns-adm`) `dns-cli vault set …` |
| Check a test vault as yourself | Your local vaults; do not need `dns-adm` | `dns-cli --vault-dir "$PWD/.vault" about` |

The path **family** is `{{HOME}}/.local/vaults/{{APP_NAME}}/`. Type 2 uses **dns-adm’s** home. Type 0 specify uses the **invoking user’s** home. **MUST NOT** hardcode `/etc/dns-adm/vault/`. **MUST NOT** default Type 2 dest to the invoking user’s `~/.local/vaults/`.

---

## 2. Core Rules / Requirements (Mandatory)

**AV-M1.** Default vault directory **MUST** be the LPU F5 app child: **`${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`**, where `SYSTEM_USER_HOME` is the F3 home of `dns-adm` (prefer `/etc/dns-adm`; fallback `/home/dns-adm`; explicit `--home` wins — see LPU law). **MUST NOT** default to the invoking user’s XDG tree. **MUST NOT** hardcode `/etc/dns-adm/vault/`.

**AV-M2.** Operator **MAY specify** a different vault:
- Flag `--vault-dir PATH` (absolute)
- Env `CF_VAULT_DIR` (absolute)  
Precedence: **`--vault-dir` > `CF_VAULT_DIR` > default**.

Specify is the **QA / test / live-operator** path: Type 0 as the invoking user (`id -un`); **MUST NOT** require `dns-adm` to exist.

**AV-M3.** Specified path **MUST** be absolute. Relative → `vault_insecure`.

**AV-M4.** Specified or default path under `/tmp` or `/dev/shm` → `vault_insecure`. Default resolve when `dns-adm` does not exist and **no** specify → `lpu_missing`. A **specified** safe absolute path **MAY** be used even when `HOME` is `/tmp` or the LPU is absent. `HOME` unset/empty/`/tmp` with **no** specify **MUST NOT** fall back to `/tmp/.config`.

**AV-M5.** Vault **MUST NOT** be scratch (`EFFECTIVE_STORAGE_DIR`), an SSH profile vault (`~/.local/vaults/ssh/…` or legacy `~/.ssh-*`), or the GitHub API plane (`~/.local/vaults/github/`). Cloudflare tokens **MUST NOT** live beside SSH keys or GitHub PATs.

**AV-M6.** When created, vault dir **MUST** be `0700`. Default tree owner **MUST** be `dns-adm:dns-adm`. Specified QA dirs **MUST** be `0700` for the invoking user.

**AV-M7.** `uninstall` **MUST NOT** delete the vault (default or specified). `remove-lpu` may remove the default tree only via `userdel -r` (LPU F7).

**AV-M8.** Help **MUST** list `--vault-dir` and `CF_VAULT_DIR` and state that the default is the `dns-adm` vault.

**AV-M9.** Production **MUST** use **one** Type 2 default dest. Specify **MUST NOT** be “a vault per host login” or “a vault per Cloudflare user.” Multiple Cloudflare zones live **inside** that one dest (`requirement-cloudflare-vault` §2.0). A Type 0 specify at the invoking user’s `~/.local/vaults/dns-cli/` is **one QA dest**, not a second production dest.

**AV-M10.** Type 2 dest **MUST** be `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` (`0700`). Setup **MUST** `mkdir` `${SYSTEM_USER_HOME}/.local/vaults/` and the `dns-cli` child. **MUST NOT** hardcode `/etc/dns-adm/vault/`. **MUST NOT** default production I/O to the invoking user’s `~/.local/vaults/dns-cli/` or `~/.config/dns-cli/`.

**AV-M11.** Every dest on this file **is** local vaults of the account that owns the tree. From an ordinary login, the Type 2 dest **is** the **global vault**: store a token or key **outside that login’s account** by submitting it to `dns-adm` and writing under `dns-adm`’s vault. From `dns-adm` the same folder remains local vaults. **MUST NOT** invent a second dest under `/etc/dns-adm/vault/` so the two names look like two folders. **MUST NOT** treat a host archive deposit as the vault dest.

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | dns-cli |
| **Ship unit** | `src/dns-cli` **1.8.0** — default dest = LPU-home vaults child; no specify + no LPU → `lpu_missing` |
| **Default (law)** | Type 2: `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` |
| **Filled example (preferred F3)** | `/etc/dns-adm/.local/vaults/dns-cli/` — Implementation Notes only; not core-rule hardcode |
| **Type 0 specify example** | Invoking-user `${HOME}/.local/vaults/dns-cli/` (QA only; never production default) |
| **Flag** | `--vault-dir` → `CF_OPT_VAULT_DIR` |
| **Env** | `CF_VAULT_DIR` |
| **Resolver (target)** | `cf_vault_specified_root` / `cf_vault_dir` / `cf_vault_dir_probe` |
| **Schema / verbs** | `requirement-cloudflare-vault` |
| **LPU owner** | `requirement-least-privilege-user` |
| **Proof** | **TP-AV-01..07** have (specify + `lpu_missing`) |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: No vault under `/tmp`.  
- **CIAO Principle 2 – Intentional**: One declared root; specify is explicit.  
- **CIAO Principle 3 – Anti-fragile**: Tests isolate via `--vault-dir` without creating `dns-adm`.  
- **CIAO Principle 10 – Least privilege**: Production default is the LPU tree.  
- **CIAO Principle 17 – Defensive storage**: HOME/XDG not assumed when specified.  
- **CIAO Principle 21 – Dual policies**: Portable MUST; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed on insecure specify.  
- **Intentional:** Cloudflare schema does not own the path SSOT; LPU owns default dest.  
- **Anti-fragile:** Alternate vault dirs for QA.  
- **Over-protect:** Uninstall never wipes secrets; default is not the invoking user’s XDG.

---

## 4. Protection Rule (Sacred)

1. Store tokens under scratch or `/tmp`.  
2. Reuse `~/.ssh-*`, `~/.local/vaults/ssh/`, or `~/.local/vaults/github/` as the Cloudflare vault.  
3. Accept a relative `--vault-dir`.  
4. Delete the vault on uninstall.  
5. Register this file as `requirement-domain-*`.  
6. Duplicate the default path as a second SSOT in project-folder (pointer only).  
7. Default the production vault back to the invoking user’s `~/.config/dns-cli/` while `dns-adm` is product law.  
8. Treat `--vault-dir` as one vault per OS user or per Cloudflare user-id.  
9. Hardcode `/etc/dns-adm/vault/` as Type 2 dest, or default Type 2 dest to the invoking user’s `~/.local/vaults/`.  
10. Default production I/O to the invoking user’s `~/.local/vaults/dns-cli/` or `~/.config/dns-cli/` while `dns-adm` is product law.  
11. Invent a second dest so “global vault” is not `dns-adm`’s local vaults, or treat a host archive deposit as the vault dest.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-AV1 | `--vault-dir` absolute safe path: `vault set`/`show` use that dir |
| AC-AV2 | `CF_VAULT_DIR` without flag uses that dir |
| AC-AV3 | `--vault-dir /tmp/…` → `vault_insecure` |
| AC-AV4 | Relative `--vault-dir` → `vault_insecure` |
| AC-AV5 | Help lists `--vault-dir` and `CF_VAULT_DIR` |
| AC-AV6 | `--vault-dir` safe absolute works when `HOME=/tmp` |
| AC-AV7 | No specify and no `dns-adm` → `lpu_missing` |
| AC-AV8 | Type 2 dest named as `dns-adm` local vaults and as global vault from an ordinary login |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-cloudflare-vault` | Schema, token files, `vault` verbs — consumes this path |
| `requirement-least-privilege-user` | Default dest is F5 |
| `requirement-shell-cli-storage` | Scratch ≠ vault |
| `requirement-project-folder` | Pointer only |
| `requirement-shell-local-self-management` | Uninstall does not wipe vault |
| `requirement-shell-cli-interface` | `--vault-dir` flag |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-AV-01** | `tests/test_cf_vault.sh` | have | `--vault-dir` specify |
| **TP-AV-02** | `tests/test_cf_vault.sh` | have | `CF_VAULT_DIR` env |
| **TP-AV-03** | `tests/test_cf_vault.sh` | have | `/tmp` rejected |
| **TP-AV-04** | `tests/test_cf_vault.sh` | have | relative rejected |
| **TP-AV-05** | `tests/test_cf_vault.sh` | have | help lists flag + env |
| **TP-AV-06** | `tests/test_cf_vault.sh` | have | specified path wins when `HOME=/tmp` |
| **TP-AV-07** | `tests/test_cf_vault.sh` | have | no specify + no LPU → `lpu_missing` |
| **TP-AV-08** | `tests/test_cli.sh` | have | dest is local vaults; Type 2 dest is global vault from ordinary login |

**Map:** `reviews/test-plan.md`  
**Matrix:** `reviews/requirement-test-matrix.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 2.4.0 | Local vaults class; Type 2 dest is `dns-adm` local vaults = global vault from ordinary login |
| 2026-08-18 | Active 2.3.0 | Type-2 dest = `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`; no hardcode `/etc/dns-adm/vault/`; TP-AV-07 have |
| 2026-08-18 | Active 2.2.0 | Type-2 dest stays off local-vaults-root; Type-0 specify MAY use `~/.local/vaults/dns-cli/`; fence GitHub/SSH planes |
| 2026-08-17 | Active 2.1.0 | One production dest; specify is not per-user vaults |
| 2026-08-17 | Active 2.0.0 | Default dest = `/etc/dns-adm/vault/`; XDG no longer default |
| 2026-08-17 | Active 1.0.0 | Path + specify SSOT; `--vault-dir` / `CF_VAULT_DIR` |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
