**file**: docs/requirements/requirement-shell-output-requirements.md  
**Status**: Active (Version 1.2.0)  
**Area**: shell  
**Key**: `requirement-shell-output-requirements`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **all CLI output** of dns-cli: human messages, machine JSON, channel split (stdout vs stderr), and mode behavior (normal / quiet / JSON / debug).

This product owns the `out_*` family. Domain messages **MUST** use the same family. **MUST NOT** print API tokens.

### 1.1 Human-facing

**In one sentence:** Everything you **see** from dns-cli goes through `out_*` — humans get lines, machines get one JSON object, and **tokens never print**.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Read status or errors | `[OK]` / `[ERROR]` |
| `--json` | One object on stdout | `{"type":"about",…}` |
| Not this | Cloudflare HTTP bodies as user text | Envelope stays internal |

| Includes | Excludes |
|----------|----------|
| `out_*` only | Raw `echo` of product messages |
| Quiet / JSON / debug modes | Printing the API token |

| Surface | What you open | What for |
|---------|---------------|----------|
| Terminal | Human lines | Default |
| `dns-cli --json about` | Machine | One JSON object |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Script the CLI | Parse one JSON object | `dns-cli --json version` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Sacred core rule

**All user-facing and machine-facing product output MUST go through the centralized output system.**

| Forbidden outside the output module | Prefer |
|-------------------------------------|--------|
| Raw `echo` / bare `printf` for **user messages** | `out_info`, `out_success`, `out_warn`, `out_error`, `out_plain`, … |
| Direct `printf` of JSON from command logic | `out_json` / `out_json_error` |
| Ad-hoc `echo >&2` diagnostics | `out_warn` / `out_error` / `out_debug` |
| Second parallel print helper that bypasses mode guards | Extend `out_text` / wrappers only |

### 2.1.1 Allowed `printf` / `echo` exceptions

| Exception class | Rule |
|-----------------|------|
| **A. Inside output SSOT** | Only `out_text`, `out_json`, and `out_json_error` may `printf` to fd 1/2 for product human or JSON lines |
| **B. Function return-via-stdout** | Helpers may `printf '%s' "$value"` solely for `$(…)` capture (data return, not UI) |
| **C. File I/O (redirected)** | Writing install staging files is file mutation; user-visible status still via `out_*` |
| **D. Tool protocol / computation pipes** | e.g. feeding `tar`/`gzip`/`sha256sum` via pipes; product status still via `out_*` |
| **E. Command-sub fallbacks** | Logic defaults only (`id -un \|\| echo "unknown"`) |

### 2.2 Output function catalog

| Function | Purpose | Typical channel | Quiet | JSON |
|----------|---------|-----------------|-------|------|
| `out_text` | SSOT for human levels | Level-dependent | Filters | Suppress all human levels |
| `out_info` | Informational | stdout | Suppress | Suppress human |
| `out_success` | Success / OK | stdout | Suppress | Suppress human |
| `out_warn` | Warning | stderr | Should still show | Prefer structured status when designed |
| `out_error` | Error | stderr | Always show (human) | Prefer `out_json_error` / `out_die` |
| `out_die` | Fatal + exit 1 (message only; JSON `code` stays `unknown`) | stderr (+ JSON error when JSON) | Always | Emits JSON error then exits |
| `out_die_code` | Fatal + exit 1 with **stable JSON `code`** | stderr (+ JSON error when JSON) | Always | **MUST** wrap `out_json_error MESSAGE CODE` then exit 1 |
| `out_plain` | Plain text, no prefix | stdout | Suppress under quiet | Suppress under JSON |
| `out_msg_n` | Prompt fragment without newline | stdout | Suppress under quiet/json | Never for machines |
| `out_json` | Machine success/status object | stdout | N/A | Only when `JSON=1` |
| `out_json_error` | Machine error object | as designed for fatal path | N/A | Only when `JSON=1` |
| `util_json_escape` | Escape string for JSON fields (class B) | stdout capture | n/a | helper for `out_json*` only |

### 2.2a Example `util_json_escape` (this product)

Class B return-via-stdout. **MUST** be used only by `out_json` / `out_json_error`. Not a product message.

```sh
# Escape \, ", and common controls so JSON cannot be broken by newlines/tabs.
util_json_escape() {
    printf '%s' "${1-}" | awk '
    {
      line = $0
      gsub(/\\/, "\\\\", line)
      gsub(/"/, "\\\"", line)
      gsub(/\t/, "\\t", line)
      gsub(/\r/, "\\r", line)
      if (NR > 1) printf "\\n"
      printf "%s", line
    }'
}
```

### 2.3 Channel contract

| Channel | Allowed content (via `out_*` only) |
|---------|-------------------------------------|
| **stdout (fd 1)** | Human info/success/plain in normal mode; **exactly one** JSON value in JSON mode for success/status |
| **stderr (fd 2)** | Errors, warnings, debug/diagnostics |

Rules:

1. Fatal paths use `out_die` or **`out_die_code`**. Domain and vault stable codes **MUST** use `out_die_code CODE MESSAGE` (live `out_die` cannot set `code`).  
2. JSON mode: no colors, banners, or progress mixed into stdout JSON.  
3. Capture pattern: `dns-cli --json <cmd> 2>err.log`.  
4. **No secrets** on either channel (API tokens, passwords, private keys).  
5. `out_json` **MUST** emit `"type"` first. Use `@key` prefixes for raw JSON numbers, bools, or arrays.

### 2.4 Mode behavior

| Mode | Contract |
|------|----------|
| Normal (TTY) | Prefixed human messages; colors only when TTY and not quiet/json |
| Quiet | Suppress info/success/plain; still show errors (and should show warnings) |
| JSON | Force quiet; structured JSON only on success path; structured errors on failure |
| Debug | Extra diagnostics on stderr; suppressed under JSON purity rules for stdout |

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit (target)** | `src/dns-cli` |
| **Ship unit (live)** | `src/dns-cli` (`out_die_code` Implemented) |
| **Human prefixes** | `[INFO]`, `[OK]`, `[WARN]`, `[ERROR]` (or equivalent consistent set) |
| **Domain messages** | Via `out_*` / `out_die_code`; codes in domain + vault law |
| **Bootstrap role** | Inherited `out_*` from A; this product is hop 1 |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 5 – Single Source of Output**  
- **Principle 14 – Security & Traceability** (stdout vs stderr)  
- **Principle 1 – Caution** (fail loud, never silent corruption of JSON pipes)

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Never hide fatal errors under quiet.  
- **Intentional:** One emitter family.  
- **Anti-fragile:** JSON/human/quiet all work offline.  
- **Over-protect:** Do not “simplify” by scattering echo.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Introduce a second product messaging stack beside `out_*`.  
2. Print user-facing banners with raw `echo` outside allowed exceptions.  
3. Mix human text into JSON stdout success paths.  
4. Log secrets or private key material.  
5. Remove quiet/json contracts for “simplicity.”  
6. Emit domain/vault stable JSON `code` values via `out_die` (message-only) instead of `out_die_code`.  
7. Print Cloudflare API tokens on either channel.

**Violating this rule is a critical output SSOT regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All product messages route through `out_*` |
| AC-2 | JSON mode produces structured success/error without human interleave |
| AC-3 | Quiet still surfaces errors |
| AC-4 | Lifecycle messaging uses the same SSOT |
| AC-5 | `util_json_escape` example is present on this file (§2.2a) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Modes and flags |
| `requirement-shell-interactive-vs-noninteractive` | Prompt vs auto |
| `requirement-domain-cloudflare-dns` | Domain codes + about redaction |
| `requirement-cloudflare-vault` | Token never printed |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Output SSOT for folder-backup |
| 2026-08-13 | Active | Retarget to cli-template; drop domain message law |
| 2026-08-18 | Active 1.2.0 | `util_json_escape` example (§2.2a); AC-5 |
| 2026-08-16 | Active 1.1.0 | `out_die_code`; domain messages; dns-cli; no token |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
