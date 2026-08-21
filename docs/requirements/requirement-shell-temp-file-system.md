**file**: docs/requirements/requirement-shell-temp-file-system.md
**Status**: Active (Version 1.0.0)
**Area**: shell
**Key**: `requirement-shell-temp-file-system`
**id**: RQ-SHELL-TEMP-FILE-SYSTEM
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **scratch file leaves** in dns-cli: unique names, cleanup, and modes.

**Root resolve** stays in `requirement-shell-cli-storage` (`util_resolve_storage`, `EFFECTIVE_STORAGE_DIR`, export `TMPDIR`). This file owns **how** a temp file is created under that root.

### 1.1 Human-facing

**In one sentence:** Scratch files are created with mktemp. Predictable `$$` names are forbidden. Cleanup is required.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert a private sudoer JSON, or rewrite `.bashrc` | `dns-cli generate-sudoer-request` |
| The other role | Root of the scratch tree | `requirement-shell-cli-storage` |
| Not this file | Queued DNS JSON schema | `requirement-cloudflare-dns-request` |

| Includes | Excludes |
|----------|----------|
| `mktemp`; cleanup; no `$$` paths | Predictable names; leaving vault curl copies behind |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | ship unit | `mktemp` leaves |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Generate a sudoer JSON | The program writes a private copy under storage, then you review it. | `dns-cli generate-sudoer-request` |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| No `$$` scratch paths; `mktemp` under storage `TMPDIR` | **TP-TEMP-01** `tests/test_cli.sh` | Proof |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Split of ownership

| Layer | Owner | Owns |
|-------|-------|------|
| Root | `requirement-shell-cli-storage` | Isolation, priority, create-before-return, `TMPDIR` |
| Leaf | **this requirement** | `mktemp` names, no predictable `$$` paths, cleanup |

### 2.2 Unique leaves (mandatory)

1. Scratch files **MUST** be created with `mktemp` (or `mktemp -d`) under `${TMPDIR}` after storage resolve (`${TMPDIR}/${APP_NAME}.XXXXXX` shape **or** a subdirectory of that root with `XXXXXX`).  
2. **MUST NOT** use predictable names as the only entropy: `/tmp/dns-cli.tmp`, `/tmp/.cache-$$`, fixed names under `/tmp`.  
3. `$$` in `ps -p $$` (current PID query) is **not** a temp path and is allowed.  
4. One helper **SHOULD** own creation: `util_mktemp` (stdout path; class-B). Callers **MUST NOT** invent a second leaf policy once that helper is shipped.  
5. If `mktemp` fails → **fail closed** via `out_*` / `out_die_code`.

### 2.3 Cleanup

1. Remove the file on the success path after the last read.  
2. Remove on failure paths — register the path and clean in a process `trap` and/or the fatal helper.  
3. Re-runs **MUST NOT** require leftover `$$` files to be absent (idempotent).

### 2.4 Consumers (this product)

| Consumer | Family | Rule |
|----------|--------|------|
| Install stage | install staging | `mktemp` under storage root |
| Vault atomic rewrite | vault | `mktemp` in the vault dir |
| API curl header/body | Cloudflare HTTPS | `mktemp`; remove after |
| Sudoer convert / generate | Type 0 | `mktemp` under storage |
| Login-hook rc rewrite | Type 1 setup | `mktemp` then `mv` |

Domain **JSON schema** stays on dest/request REQs. This REQ does not redefine those samples.

### 2.5 Sufficient samples

```sh
util_mktemp() {
    : "${TMPDIR:=/tmp}"
    : "${APP_NAME:=dns-cli}"
    _um=$(mktemp "${TMPDIR}/${APP_NAME}.XXXXXX") || {
        out_die_code vault_insecure "mktemp failed"
    }
    SCRATCH_FILES="${SCRATCH_FILES-} ${_um}"
    printf '%s' "${_um}"
}

util_scratch_cleanup() {
    for _sf in ${SCRATCH_FILES-}; do
        if [ -n "${_sf}" ]; then
            rm -f "${_sf}"
        fi
    done
    SCRATCH_FILES=""
}
```

```sh
# Convert scratch (correct)
_tf=$(util_mktemp)
printf '%s' "${_body}" >"${_tf}"
rm -f "${_tf}"
```

```sh
# Forbidden
printf '%s' "${_body}" >"${TMPDIR:-/tmp}/dns-enc.$$"
```

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Helper** | Inline `mktemp …XXXXXX` under `${EFFECTIVE_STORAGE_DIR}` / vault dir — **Implemented**. `util_mktemp` / `util_scratch_cleanup` — **Gap** (not yet the only helper) |
| **Root** | `TMPDIR=${EFFECTIVE_STORAGE_DIR}` set in `app_main` |
| **Trap** | Per-caller `rm`; process `SCRATCH_FILES` trap **Gap** |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 11 – Temps:** unique names, cleanup, not museum copies.  
- **Principle 1:** no symlink-race predictable paths.  
- **Principle 22:** modes via `chmod`/`install -m` on the path, not sticky script umask.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** `mktemp` or fail closed.  
- **Intentional:** storage = root; this REQ = leaf.  
- **Anti-fragile:** works when `/tmp` is shared; isolation is the root.  
- **Over-protect:** trap plus explicit `rm`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Use `/tmp/${APP_NAME}.tmp` or `$$` as the only entropy for scratch.  
2. Redefine storage root here.  
3. Leave vault curl temps behind on the success path.  
4. Treat `$$` in `ps -p $$` as a forbidden temp path.

**Violating any of these is a critical regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-storage.md` | Root resolve |
| `docs/requirements/requirement-shell-script-coding.md` | Points here |
| `./src/dns-cli` | Ship unit |

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
