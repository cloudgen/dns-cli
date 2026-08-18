**file**: docs/requirements/requirement-application-local-vault.md  
**Status**: Active (Version 2.1.0)  
**Area**: shell  
**Key**: `requirement-application-local-vault`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for **where** dns-cli’s **local application vault** lives and **how the operator specifies** it.

`requirement-cloudflare-vault.md` **consumes** this path for multi-account schema, per-domain-id token files, and `vault` verbs. LPU home vs affected-folder ownership lives in `requirement-least-privilege-user`. This file is **not** a second domain catalog and **not** SSH identity.

---

## 2. Core Rules / Requirements (Mandatory)

**AV-M1.** Default vault directory **MUST** be the LPU F5 path: **`/etc/dns-adm/vault/`** (or `${SYSTEM_USER_HOME}/vault/` when `dns-adm` home fell back — see LPU law). **MUST NOT** default to the invoking user’s XDG tree.

**AV-M2.** Operator **MAY specify** a different vault:
- Flag `--vault-dir PATH` (absolute)
- Env `CF_VAULT_DIR` (absolute)  
Precedence: **`--vault-dir` > `CF_VAULT_DIR` > default**.

Specify is the **QA / test / live-operator** path: Type 0 as the invoking user (`id -un`); **MUST NOT** require `dns-adm` to exist.

**AV-M3.** Specified path **MUST** be absolute. Relative → `vault_insecure`.

**AV-M4.** Specified or default path under `/tmp` or `/dev/shm` → `vault_insecure`. Default resolve when `dns-adm` does not exist and **no** specify → `lpu_missing`. A **specified** safe absolute path **MAY** be used even when `HOME` is `/tmp` or the LPU is absent. `HOME` unset/empty/`/tmp` with **no** specify **MUST NOT** fall back to `/tmp/.config`.

**AV-M5.** Vault **MUST NOT** be scratch (`EFFECTIVE_STORAGE_DIR`) or an SSH profile vault (`~/.ssh-*`).

**AV-M6.** When created, vault dir **MUST** be `0700`. Default tree owner **MUST** be `dns-adm:dns-adm`. Specified QA dirs **MUST** be `0700` for the invoking user.

**AV-M7.** `uninstall` **MUST NOT** delete the vault (default or specified). `remove-lpu` may remove the default tree only via `userdel -r` (LPU F7).

**AV-M8.** Help **MUST** list `--vault-dir` and `CF_VAULT_DIR` and state that the default is the `dns-adm` vault.

**AV-M9.** Production **MUST** use **one** default dest. Specify **MUST NOT** be “a vault per host login” or “a vault per Cloudflare user.” Multiple Cloudflare zones live **inside** that one dest (`requirement-cloudflare-vault` §2.0).

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | dns-cli |
| **Ship unit** | `src/dns-cli` — default path still XDG (v1). **Gap:** default `/etc/dns-adm/vault/` |
| **Default (law)** | `/etc/dns-adm/vault/` |
| **Flag** | `--vault-dir` → `CF_OPT_VAULT_DIR` |
| **Env** | `CF_VAULT_DIR` |
| **Resolver (target)** | `cf_vault_specified_root` / `cf_vault_dir` / `cf_vault_dir_probe` |
| **Schema / verbs** | `requirement-cloudflare-vault` |
| **LPU owner** | `requirement-least-privilege-user` |
| **Proof** | **TP-AV-01..06** have (specify). **TP-AV-07** todo (default is LPU path; no specify + no LPU → `lpu_missing`) |

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
2. Reuse `~/.ssh-*` as the app vault.  
3. Accept a relative `--vault-dir`.  
4. Delete the vault on uninstall.  
5. Register this file as `requirement-domain-*`.  
6. Duplicate the default path as a second SSOT in project-folder (pointer only).  
7. Default the production vault back to the invoking user’s `~/.config/dns-cli/` while `dns-adm` is product law.  
8. Treat `--vault-dir` as one vault per OS user or per Cloudflare user-id.

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
| AC-AV7 | No specify and no `dns-adm` → `lpu_missing` (when implemented) |

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
| **TP-AV-07** | `tests/test_cf_vault.sh` | todo | no specify + no LPU → `lpu_missing` |

**Map:** `reviews/test-plan.md`  
**Matrix:** `reviews/requirement-test-matrix.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 2.1.0 | One production dest; specify is not per-user vaults |
| 2026-08-17 | Active 2.0.0 | Default dest = `/etc/dns-adm/vault/`; XDG no longer default |
| 2026-08-17 | Active 1.0.0 | Path + specify SSOT; `--vault-dir` / `CF_VAULT_DIR` |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
