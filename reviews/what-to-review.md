# What to review — dns-cli

**Living checklist** (review plan). Product: **dns-cli** Cloudflare DNS CLI (Type 0/1/2 + LPU `dns-adm` in law).  
**Class:** software-development · **B = hop 1** from **A = cli-template** · **local-only** install channel.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-09-08  
**Ship unit VERSION:** 1.22.0  
**Suite baseline:** see `reviews/test-plan.md` (full `./tests/run.sh`; **TP-CLI-18** · **TP-CLI-20** have)

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + vault + domain DNS + LPU/three-layer |
| P2 | Confirm ship unit `src/dns-cli` | `APP_NAME` / `VERSION` hard-assign (**1.22.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers-install-script |
| P8 | Dual mention (CI-M1) | **TP-CLI-14** / **CL-CLI-DUAL-MENTION** — every routed verb in ≥2 REQs; help code ≠ mention 2 |
| P9 | Role tables stay split | three-layer §2.1a + sudoer-json §2.0 vs DNS actor table; **TP-PRIV-09** · **TP-SUDOER-JSON-09** · **TP-CF-ACTOR-07** |
| P7 | Public token leak (file-leaks **C5**) | No `cfut_…` / Bearer secret / `ghp_…` in README, CHANGELOG, SECURITY, `reviews/**`, requirements; request JSON samples have no `token` key |
| P10 | Dest-owned schema / `kind` (INC-20260819-001) | Queued sudoer body ⊆ dest allowlist (**TP-FENCE-05** / **TP-SUDOER-JSON-21**). Dest-legal `kind` is known on sudoer dest, not a dest Fence, not file-ownership. DNS dest rejects `kind` (**TP-FENCE-06** / **TP-CF-REQ-16**). Live dest 1.8.1 still refuses `kind` (**TP-FENCE-07** skip). Do not dest Type 0 re-submit `login-hook-elev`. |
| P11 | JSON re-encode / inbound fidelity | Queued inbound body is the grant (not emit-only `"kind"` grep; not stub `cp` as dest accept). Two-kind split: Type 0 `type-2-switch` only; `login-hook-elev` is Type 1 setup. **TP-SUDOER-JSON-10..15** · **21**. |
| P12 | Operator-readable dest Fence | Dest format fail names the field / unknown key and says dest will not ask yes/no, plus a next step. Dest next-step **MUST NOT** send `login-hook-elev` through dest Type 0 `add-sudoer-request`. **TP-FENCE-06**. |
| P13 | Type 1 elevation fail-closed | `setup` / `remove-lpu` without root/sudo fail closed (**TP-PRIV-03**). Do not treat “no sudo in CI” as interactive Type 1 coverage. |
| P14 | Sudoer command identity (INC-20260821-001) | Queued `commands[].path` is `/usr/local/bin/dns-cli` even when tests set `GLOBAL_BIN` to a CI gbin. Live dest `/etc/sudoers.d/dns-cli-dns-adm` is not a test path. Do not rewrite `/etc/sudoers.d` from this product. |
| P15 | Type 0 **test-purpose** `fence-test` (FC-M6) | Local test folder; `--file` xor `--dir`; no sudo except wrap chmod/chown of that folder; no queue. Help lists testers apart from operational. **TP-FENCE-09..15**. Per-row `test-json-format` remains. |
| P16 | F5 trio directory owner (INC-20260823-001) | `/var/dns-cli/dns-request` · `dns-accepted` · `dns-declined` are **`dns-adm:dns-adm`** (inbound `3773`, archives `0700`). F4 symlink present ≠ listable. Do not `chown -R` inbound files. Do not cite **003** to skip directory `chown`. |
| P17 | Keep-latest duplicate inbound | Dest `interactive` (login hook included) keeps the latest inbound file per dest (`domain_id`+`subdomain`); older duplicates superseded → declined (no dest-write, no extra yes/no). Not a dest Fence. **TP-CF-REQ-19**. |
| P18 | YAML review display | Dest `interactive` (login hook included) shows a clear waiting body as YAML, not a JSON object dump. Inbound file stays JSON. **TP-CF-REQ-20**. |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | A = cli-template hop 0; this product B = dns-cli hop 1 |
| Project folder | `requirement-project-folder.md` | `src/`, bins; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Commands, flags, dispatch; **CI-M1** every verb in ≥2 REQs; family `sudoers` not dispatched |
| LPU | `requirement-least-privilege-user.md` | `dns-adm` F1–F7; `setup` Implemented; F5 dest `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`; Type 2 switch Implemented |
| Three-layer | `requirement-three-layer-privilege-model.md` | Tables A/B/C + **§2.1a role table**; print sudoer file / generate+submit Implemented; Type 2 switch Implemented |
| JSON sudoer file | `requirement-sudoer-json-file.md` | **§2.0 role table** (printer / submitter / `sudoer-adm`); generate dest + submit; `runas=dns-adm` |
| Empty argv | `requirement-shell-cli-zero-arguments.md` | Off-TTY empty argv = help; TTY empty argv = main menu |
| Default interaction | `requirement-shell-cli-default-interaction.md` | Daily DNS list + family **sudoers** submenu; Exit **99**; Back **8** / Exit **9**; `sudoers` not a command |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | `cf_` domain prefix |
| Application local vault | `requirement-application-local-vault.md` | default `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`; `--vault-dir` / `CF_VAULT_DIR` |
| Cloudflare vault | `requirement-cloudflare-vault.md` | zone-slot `account`/`zone` add/list/modify/remove; v2 + default dest + Type 2 switch Implemented |
| Cloudflare API | `requirement-cloudflare-api.md` | Bearer, envelope, zone GET, DNS A CRUD; no AAAA |
| A-record mode | `requirement-cloudflare-dns-mode.md` | default non-RR; RR multi-A; switch only at ipv4_count 0/1 |
| DNS request JSON | `requirement-cloudflare-dns-request.md` | four types + examples; inbound `submit` / `approve` / `reject` / `interactive` Implemented (1.9.0–1.9.7) |
| External IPv4 | `requirement-external-ipv4.md` | ipinfo lookup + vault-free `ip`; IPv6 MUST NOT |
| Domain DNS | `requirement-domain-cloudflare-dns.md` | consumes mode; `ip`, add/update/status |
| Actor table | `requirement-dns-actor-table.md` | DNS inbound only; anyone submits; `dns-adm` approves; dest-writes `submit_by`; **not** sudoer print/submit roles |
| Approver | `requirement-dns-approver.md` | identity `dns-adm`; dest review loop on actor table |
| Login-interactive hook | `requirement-login-interactive-hook.md` | `/usr/local/bin/${APP_NAME}-hook` soft link; heal of `dns-adm` rewrites old hook |
| Dest fence catalog | `requirement-approval-fencing-condition.md` | Closed dest refuse list; dest tables still print |
| Dest fence | `requirement-incorrect-json-format.md` | Independent dest Fence; dest-owned allowlist; sudoer `kind` known |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Cache folder + persistency folder; isolation |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, `print-sudoers-install-script` / `remove-project-sudoers` (those remain on sibling **folder-backup**). **Do** review JSON sudoer generate/submit — this product **is** a sudoer-approval-submitter.
