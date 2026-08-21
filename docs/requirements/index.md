# Requirements index

**Product:** dns-cli (POSIX `/bin/sh` local self-managed Cloudflare DNS CLI — Type 0/1/2 + LPU `dns-adm` as Type 2 operator **and** Type 1 approver; anyone may submit)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; **B = `dns-cli` hop 1** specialized from **A = `cli-template` hop 0**. Online / Type O / backup / restore **intentionally absent**. LPU **`dns-adm`** Type 1 `setup` **Implemented**; Type 0 JSON sudoer generate/submit is **`type-2-switch`**; `setup` writes **`login-hook-elev`** inbound (1.8.1); submit-vs-setup door (1.8.2); Type 2 default dest is `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` (1.8.0); Type 2 switch **Implemented** (1.8.2). Inbound DNS `submit` / `approve` / `reject` / `interactive` **Implemented** (1.9.0). Queue-move ownership split **Implemented** (1.9.1 / INC-20260818-003). Login-hook `interactive` takes inbound ownership **at the beginning** **Implemented** (1.9.2). Approval question is one-off **yes/no** **Implemented** (1.9.3). Approval system fence-then-question **Implemented** (1.9.4). User SSOT is the JSON field, not the filename token **Implemented** (1.9.6). Dest interactive dest-writes `submit_by` after format check **Implemented** (1.9.7). Dest fence catalog **Implemented** (`requirement-approval-fencing-condition`). Dest-owned sudoer allowlist includes `kind` (law; dest sibling must match — INC-20260819-001).  
**Updated:** 2026-08-21 (Type 0 **test-purpose** `fence-test`; testers listed apart from operational)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack; dest fence catalog REQ + independent Fence REQs; dest Fences ship Type 0 **test-purpose** `fence-test` | class | Active (1.10.0) | `requirement-class-software-dev.md` | 2026-08-21 |
| requirement-actor-role-subject-approver | Actor / role / subject / submitter / approver catalog; Submitter before Approver | architecture | Active (1.1.0) Implemented | `requirement-actor-role-subject-approver.md` | 2026-08-19 |
| requirement-approval-fencing-condition | Dest fence catalog (closed dest refuse list); dest tables still print; Type 0 **test-purpose** `fence-test` | architecture | Active (1.1.0) Implemented | `requirement-approval-fencing-condition.md` | 2026-08-21 |
| requirement-incorrect-json-format | Independent dest Fence: dest-owned JSON allowlist; sudoer `kind` known; Type 0 `submit_app` / `submit_version`; Type 0 `test-json-format`; list tester `fence-test`; interactive fence match → declined | architecture | Active (1.4.0) Implemented | `requirement-incorrect-json-format.md` | 2026-08-21 |
| requirement-bootstrap-chain | Bootstrap origin A = cli-template (hop 0); this product B = dns-cli (hop 1); LPU + JSON sudoer submitter on B | architecture | Active (5.2.0) | `requirement-bootstrap-chain.md` | 2026-08-18 |
| requirement-project-folder | Project layout (`src/dns-cli`), install bins; LPU home + vault pointer | architecture | Active (2.3.0) | `requirement-project-folder.md` | 2026-08-18 |
| requirement-least-privilege-user | LPU `dns-adm` F1–F7; dest Fence points at `requirement-incorrect-json-format` | architecture | Active (1.11.0) Implemented | `requirement-least-privilege-user.md` | 2026-08-19 |
| requirement-three-layer-privilege-model | Type 0/1/2 map + role table + Tables A/B/C; dest Fence points at independent REQ; prevention-set + sudo-command pointers | architecture | Active (1.13.0) Type 1 + two-kind submitter + Type 2 switch Implemented | `requirement-three-layer-privilege-model.md` | 2026-08-20 |
| requirement-privilege-prevention-set | Closed catalog of what this product blocks vs must stay open; Type 2 remains; DNS dest is `dns-adm` | architecture | Active (1.0.0) | `requirement-privilege-prevention-set.md` | 2026-08-20 |
| requirement-sudoer-json-file | Two JSON kinds + three dests (SJ-M4); dest Fence points at independent REQ | architecture | Active (1.9.0) Implemented | `requirement-sudoer-json-file.md` | 2026-08-19 |
| requirement-shell-cli-interface | Shell CLI interface; **dual mention** + **CI-M1a samples** on topic-owners; Type 0 **test-purpose** `test-json-format` / `fence-test` | shell | Active (3.7.0) | `requirement-shell-cli-interface.md` | 2026-08-21 |
| requirement-shell-script-coding | POSIX writing-style specialize-in home; aligned to coding mold; **points** at peers for printers/prefixes/TTY/prompt/temp/sudo bodies | shell | Active (1.1.0) | `requirement-shell-script-coding.md` | 2026-08-20 |
| requirement-shell-sudo-command | Sudo-wrapping function; check before sudo; chmod example (`util_sudo` / `util_chmod`) | shell | Active (1.0.0) | `requirement-shell-sudo-command.md` | 2026-08-20 |
| requirement-shell-prompt | `prompt_*` helper bodies; consume `TTY`; dest review uses one `prompt_yes_no` | shell | Active (1.0.0) Implemented | `requirement-shell-prompt.md` | 2026-08-20 |
| requirement-shell-temp-file-system | Scratch **leaves**: `mktemp`; no `$$` paths; cleanup | shell | Active (1.0.0) | `requirement-shell-temp-file-system.md` | 2026-08-20 |
| requirement-shell-cli-zero-arguments | Empty argv Type N help (local-only; no DNS/vault mutate) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-08-16 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755**; path `util_*` examples | shell | Active (1.7.0) | `requirement-shell-local-self-management.md` | 2026-08-18 |
| requirement-shell-output-requirements | Central `out_*` output SSOT + `out_die_code` + `util_json_escape` example | shell | Active (1.2.0) | `requirement-shell-output-requirements.md` | 2026-08-18 |
| requirement-shell-modular-function-design | Single-file modular prefixes; `util_*` example ownership; sudo/prompt/temp pointers | shell | Active (2.4.0) | `requirement-shell-modular-function-design.md` | 2026-08-20 |
| requirement-shell-idempotency | Re-run safety for install / uninstall / vault / DNS / mode switch | shell | Active (1.5.0) | `requirement-shell-idempotency.md` | 2026-08-17 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm / vault collect / remove-lpu; `prompt_*` consume `TTY`; bodies on prompt REQ | shell | Active (1.4.0) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-20 |
| requirement-shell-cli-storage | Scratch/cache resolve (not vault); storage `util_*` examples | shell | Active (1.3.0) | `requirement-shell-cli-storage.md` | 2026-08-18 |
| requirement-domain-cloudflare-dns | **Domain SSOT** — A-record verbs; Type 0 **test-purpose** `fence-test` / `test-json-format`; dest MUST NOT fence on filename subject token | domain | Active (2.9.0) | `requirement-domain-cloudflare-dns.md` | 2026-08-21 |
| requirement-dns-actor-table | Actor table; dest interactive dest-writes `submit_by` after format check | architecture | Active (1.9.0) Implemented | `requirement-dns-actor-table.md` | 2026-08-19 |
| requirement-dns-approver | Approver `dns-adm`; dest interactive dest-writes `submit_by` | architecture | Active (1.6.0) Implemented | `requirement-dns-approver.md` | 2026-08-19 |
| requirement-cloudflare-dns-mode | Per-subdomain A-record mode (default non-RR; RR multi-A; switch only when ipv4_count ∈ {0,1}; IPv4 only) | domain | Active (1.0.1) | `requirement-cloudflare-dns-mode.md` | 2026-08-18 |
| requirement-cloudflare-dns-request | Four inbound JSON types; dest-written `submit_by` after format check | domain | Active (1.6.0) Implemented | `requirement-cloudflare-dns-request.md` | 2026-08-19 |
| requirement-external-ipv4 | External/public IPv4 lookup, `--ip`, vault-free `ip` display; IPv6 MUST NOT | shell | Active (1.2.0) | `requirement-external-ipv4.md` | 2026-08-18 |
| requirement-application-local-vault | Local vault path; Type-2 dest is `dns-adm` local vaults = global vault from ordinary login; `--vault-dir` specify | shell | Active (2.4.0) | `requirement-application-local-vault.md` | 2026-08-19 |
| requirement-cloudflare-vault | One LPU vault; 1:1 domain↔token; Type-2 dest LPU-home vaults child; zone-slot CRUD; Type 2 switch | domain | Active (2.8.0) Implemented | `requirement-cloudflare-vault.md` | 2026-08-18 |
| requirement-cloudflare-api | Cloudflare HTTPS API (token, envelope, zone GET, DNS A CRUD; no AAAA) | domain | Active (1.2.0) | `requirement-cloudflare-api.md` | 2026-08-17 |

## Intentionally absent (by design)

| Surface | Status on dns-cli |
|---------|------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Sudoers-manager extras (`print-sudoers-install-script`, `remove-project-sudoers`) | **Absent** — generate/submit JSON sudoer are **not** those extras |
| Type 1 elevated deposit / restore-stage | **Absent** |

**Domain SSOT:** `requirement-domain-cloudflare-dns` (exactly one Active `requirement-domain-*`). Local vault **path/specify** is `requirement-application-local-vault`. Cloudflare **schema** is `requirement-cloudflare-vault`. Cloudflare **HTTPS API** is `requirement-cloudflare-api`. **A-record mode** is `requirement-cloudflare-dns-mode`. **DNS request JSON** is `requirement-cloudflare-dns-request`. Public IPv4 is `requirement-external-ipv4`. LPU identity is `requirement-least-privilege-user`. Elev tables are `requirement-three-layer-privilege-model`. None of those is a second `requirement-domain-*`.

**Install mode:** **local-only** (`install` + `uninstall` + `where-is-me`). Not dual-mode.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for dns-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only**.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active `requirement-domain-*` (`requirement-domain-cloudflare-dns`). Do not add a second Active domain catalog.  
8. **Do not reintroduce** backup, restore, sudoers-manager extras, or online install without explicit user order and registry update. `print-sudoers` + `setup` + `generate-sudoer-request` + `submit-sudoer-request` are **authorized** via the LPU / three-layer / sudoer-json rows.  
9. v1/v2 vault/DNS, LPU create, Type 2 default dest, Type 2 switch, and inbound DNS `submit` / `approve` / `reject` / `interactive` on `src/dns-cli` are **Implemented**. Do not re-label those Gap.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
