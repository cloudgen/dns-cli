# Product review: dns-cli (login-hook vs sibling sudoer-cli)

**Date:** 2026-09-08  
**Reviewer:** project maintainers  
**Product:** dns-cli `VERSION=1.23.0` (live `/usr/local/bin/dns-cli` may still be 1.22.0 until reinstall)  
**Ship unit:** `src/dns-cli`  
**Scope:** Login-interactive review hook vs sibling `sudoer-cli` (and note `nginx-cli`) after live `sudo su - dns-adm` printed `sudo: a password is required` / `dns-cli: login review hook skipped (sudo -n failed)`  
**Method:** Disk read of sibling law + ship units; live host probe (symlink, F6, `sudo -n -l -U dns-adm`, rc where readable)  
**Baseline:** `./tests/run.sh` PASS=799 FAIL=0 SKIP=1 on 1.22.0 (pre-remediation)

## Summary

The doorbell plant is already sibling-shaped: `/usr/local/bin/dns-cli-hook` → `/usr/local/bin/dns-cli` exists. The live login failure is **not** a missing symlink and **not** an old `.bashrc` path. `dns-adm` has **no** NOPASSWD grant to run that hook as root, so `sudo -n` fails and sudo prints `a password is required`. Sibling `sudoer-cli` avoids that class of failure because **F6 Table A grants the hook** (`sudoer-adm ALL=(root) NOPASSWD: /usr/local/bin/sudoer-cli-hook`) and setup dest-writes a **live** `/etc/sudoers.d` fragment. This product **must not** dest-write `/etc/sudoers.d`; the matching grant is sibling dest `login-hook-elev` → `/etc/sudoers.d/dns-cli-dns-adm`, which is **absent** on this host (`host_fragment_present=false`).

## Strengths

| Area | Notes |
|------|--------|
| Labeled doorbell | Live `/usr/local/bin/dns-cli-hook` matches sudoer-cli `/usr/local/bin/sudoer-cli-hook` |
| Fail-open login | Hook uses `sudo -n`; login continues after skip (HOOK-M1) |
| Grant JSON | `generate-sudoer-request --kind login-hook-elev` emits path `/usr/local/bin/dns-cli-hook` args `interactive` |
| Dest split | Type 2 switch stays `/usr/local/bin/dns-cli`; hook grant is a different dest (correct, must not collapse) |

## Findings

### DNS-CLI-HOOK-01 — Severity: P1 (high)

- **Area:** HOOK / SEC  
- **Status:** open (ship skip next-step fixed 1.23.0; live dest-approve still required)  
- **Location:** live host; `.bashrc` `sudo -n /usr/local/bin/dns-cli-hook interactive`; missing `/etc/sudoers.d/dns-cli-dns-adm`  
- **Description:** `sudo su - dns-adm` sources the hook; `sudo -n` fails because `dns-adm` is not allowed to run sudo (`sudo -n -l -U dns-adm` → not allowed). F6 `/etc/dns-adm/sudoers` is `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` (operators → `dns-adm`), **not** `dns-adm ALL=(root) NOPASSWD: …-hook interactive`. That second grant is sibling dest after approve.  
- **Impact:** Approver login never starts review. sudo’s `a password is required` looks like a hang/password prompt.  
- **Suggestion:** Do **not** copy sudoer-cli F6 (whole-CLI-as-root) into this product. Keep `login-hook-elev` as sibling dest. Heal the skip line: hide sudo’s password stderr (`2>/dev/null`) and print a **next step** (`sudoer-adm` / `sudoer-cli interactive` to approve `login-hook-elev`). Host: approve the queued JSON (or queue via `sudo dns-cli setup` if inbound was skipped).  
- **Cross-ref:** `requirement-login-interactive-hook` HOOK-M1; `requirement-sudoer-json-file` `login-hook-elev`; sibling F6 `ELEV-F6-HOOK`

### DNS-CLI-HOOK-02 — Severity: P2 (medium)

- **Area:** HOOK  
- **Status:** fixed (1.23.0 `lpu_review_old_login_hook` on `interactive` + `setup`)  
- **Location:** `cf_req_interactive` vs sibling `sr_interactive` → `lpu_review_old_login_hook`  
- **Description:** sudoer-cli Type 1 `interactive` (euid 0) **reviews** `sudoer-adm` rc and rewrites an old product-binary `sudo -n` line to `-hook`, even when the invoker is root. dns-cli heal of that home runs on `setup` and when `id -un` is `dns-adm`. `sudo dns-cli interactive` as root does **not** review `/etc/dns-adm/.bashrc`.  
- **Impact:** Old rc on the dedicated account can survive until someone logs in as `dns-adm` (which currently fails `sudo -n`) or re-runs `setup`.  
- **Suggestion:** Add `lpu_review_old_login_hook` (euid 0 only; skip test-mode live home) and call it from `cf_req_interactive`, matching sibling TP-SR-HOOK-06.  
- **Cross-ref:** sibling `requirement-login-interactive-review-hook` §2.0a

### DNS-CLI-HOOK-03 — Severity: P3 (low)

- **Area:** DOC  
- **Status:** wontfix  
- **Location:** live sibling `/etc/sudoer-adm/.bashrc`  
- **Description:** On this host, `sudoer-adm` rc still calls `sudo -n /usr/local/bin/sudoer-cli interactive` (old product-binary), **not** `sudoer-cli-hook`. That still works because sibling F6 grants the **whole** binary as root. dns-cli must not treat “sudoer-cli live rc” as proof that F6 should grant whole `dns-cli` as root.  
- **Impact:** Copying sibling F6 blindly would grant `dns-adm` `setup` / `remove-lpu` as root via the hook symlink.  
- **Suggestion:** Keep verb-bound `interactive` only on `login-hook-elev`. Do not add whole-CLI-as-root to F6.  
- **Cross-ref:** `requirement-sudoer-json-file` (whole-CLI-as-root forbidden on hook grant)

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| `/usr/local/bin/dns-cli-hook` exists | Pass — symlink to `/usr/local/bin/dns-cli` |
| nginx-cli as-login (no sudo) hook | N/A for this dest — dns inbound `chown` needs euid 0; keep `sudo -n` |
| Empty argv stays help | Pass |
| This product dest-writes `/etc/sudoers.d` | Correctly **MUST NOT** |
| Type 2 live grant `/etc/sudoers.d/dns-cli-leolio` | Pass — unrelated dual (`leolio` → `dns-adm`) |

## Priority remediation order

1. Operator-readable hook skip (hide `sudo: a password is required`; name `login-hook-elev` + `sudoer-cli interactive` as next).  
2. Type 1 `interactive` reviews `dns-adm` rc when euid 0 (sibling `lpu_review_old_login_hook`).  
3. Host: dest-approve `login-hook-elev` so `/etc/sudoers.d/dns-cli-dns-adm` exists. Not a ship-unit dest-write.

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-login-interactive-hook.md` | This product hook plant |
| Sibling `sudoer-cli` `requirement-login-interactive-review-hook.md` | Pattern + F6 hook Cmnd |
| `docs/requirements/requirement-sudoer-json-file.md` | `login-hook-elev` body |
| `docs/requirements/requirement-three-layer-privilege-model.md` | ELEV-CF-02 sibling dest |

**Written by:** project maintainers  
**Review status:** Partial — HOOK-02 fixed 1.23.0; HOOK-01 skip text fixed, live grant still host dest-approve; HOOK-03 wontfix
