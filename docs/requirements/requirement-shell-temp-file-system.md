**file**: docs/requirements/requirement-shell-temp-file-system.md
**Status**: Active (Version 1.2.0)
**Area**: shell
**Key**: `requirement-shell-temp-file-system`
**id**: RQ-SHELL-TEMP-FILE-SYSTEM
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **scratch file leaves** in dns-cli: unique names, cleanup, and modes.

**Cache root resolve** stays in `requirement-shell-cli-storage` (`util_resolve_storage`, `EFFECTIVE_STORAGE_DIR`, export `TMPDIR`). **Persistency folder** also stays on that REQ (`${HOME}/.local/dns-cli`). This file owns **how** a temp file is created under the cache root.

### 1.1 Human-facing

**In one sentence:** Scratch files are created under the cache folder. When `mktemp` is installed it supplies the name. When it is not, the file is still created there. The cache directory may end in `$$`. A scratch file name must not. A scratch directory is mode `0700`. Cleanup is required.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Convert a private sudoer JSON, or rewrite `.bashrc` | `dns-cli generate-sudoer-request` |
| The other role | Root of the scratch tree (cache folder, not persistency) | `requirement-shell-cli-storage` |
| Not this file | Queued DNS JSON schema | `requirement-cloudflare-dns-request` |

| Includes | Excludes |
|----------|----------|
| `util_mktemp`; missing temp maker; directory mode `0700`; cleanup; cache directory may end in `$$` | Predictable `$$` file names; a directory left at `0600`; leaving vault curl copies behind |

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
| No `$$` scratch **file** names; cache directory may end in `$$`; maker-absent file is mode `0600` under the cache folder; scratch directory is mode `0700` | **TP-CLI-12** · **TP-CLI-28** `tests/test_cli.sh` | Proof |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Split of ownership

| Layer | Owner | Owns |
|-------|-------|------|
| Root | `requirement-shell-cli-storage` | Isolation, priority, create-before-return, `TMPDIR` |
| Leaf | **this requirement** | `util_mktemp` / `util_mktemp_dir`. The cache **directory** may end in `$$`. Scratch **files** must not. Cleanup. The helper bodies are on `requirement-shell-cli-storage` §2.5a |

### 2.2 Unique leaves (mandatory)

1. Scratch files **MUST** be created with `util_mktemp` under the resolved cache folder. When `mktemp` exists and the create succeeds, the name is an `XXXXXX` name. When the temp maker is absent, or every `mktemp` attempt fails, the file is `${APP_NAME}.${suffix}.${token}` under that folder, mode `0600`, and is not a `$$` name.  
2. A scratch directory **MUST** use `util_mktemp_dir`. `mktemp -d` only when that program exists and can create a directory. Otherwise `mkdir` a unique subdirectory of the cache folder. Mode **MUST** be `0700`, and the directory **MUST** be searchable and writable, before any file is written. A directory at `0600` cannot be searched.  
3. **MUST NOT** use predictable names as the only entropy: `/tmp/dns-cli.tmp`, `/tmp/.cache-$$`, `${TMPDIR}/${APP_NAME}.$$`, fixed names under `/tmp`. The cache **directory** from `requirement-shell-cli-storage` **MAY** end in `-$$`. That is the directory, not the file. A missing temp maker **MUST NOT** fall back to a bare `/tmp` dump.  
4. `$$` in `ps -p $$` (current PID query) is **not** a temp path and is allowed.  
5. One helper owns file creation: `util_mktemp` (stdout path; class-B). One helper owns directory creation: `util_mktemp_dir`. `util_mktemp` **MUST** refuse a `$$` name template and **MUST** check that `mktemp` exists before it calls it. Callers **MUST NOT** invent a second leaf policy. Inline `mktemp …XXXXXX` under the vault directory remains for vault rewrites. Install staging uses `util_mktemp`.  
6. If the cache folder cannot hold the leaf → **fail closed** via `out_*` / `out_die_code`. A missing `mktemp` program is not that failure.

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
# Body of util_mktemp / util_mktemp_dir / util_mktemp_bin / util_scratch_token
# / util_dir_mode_0700: requirement-shell-cli-storage §2.5a.
# This file owns cleanup and the ban on $$ file names.
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
| **Helper** | `util_mktemp` and `util_mktemp_dir` **Implemented** (bodies on `requirement-shell-cli-storage` §2.5a). Refuses a `$$` template. Missing `mktemp` writes a mode-`0600` file under the cache folder. A scratch directory is mode `0700`. Install staging uses `util_mktemp`. Vault rewrites still use `mktemp` in the vault dir. `util_scratch_cleanup` — **Gap** |
| **Root** | `TMPDIR=${EFFECTIVE_STORAGE_DIR}` set in `app_main` |
| **Trap** | Per-caller `rm`; process `SCRATCH_FILES` trap **Gap** |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 11 – Temps:** unique names, cleanup, not museum copies.  
- **Principle 1:** no symlink-race predictable paths.  
- **Principle 22:** modes via `chmod`/`install -m` on the path, not sticky script umask.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Check the temp maker. A missing maker still writes under the cache folder. Fail closed only when that folder cannot hold the leaf.  
- **Intentional:** storage = root; this REQ = leaf.  
- **Anti-fragile:** works when `/tmp` is shared; isolation is the root.  
- **Over-protect:** trap plus explicit `rm`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Use `/tmp/${APP_NAME}.tmp` or `$$` as the only entropy for a scratch **file**. The cache **directory** may end in `-$$`. Call `mktemp` when it is not installed. Treat a directory at `0600` as usable.  
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

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
