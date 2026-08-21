# Lessons — dns-cli

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-TRIM-01 | Backup / restore / sudoers-manager extras reintroduced as if still product law | bootstrap-chain (absent extras); TP-CLI-04/13. Generate/submit JSON sudoer are **not** extras | open watch |
| L-SUDOER-SUBMIT-01 | File-based JSON sudoer submit missing because hop-1 trim + reviews treated all sudoers emit as folder-backup; DNS inbound specialized instead; three-layer mold stopped at 2.6.0 | Specialize `requirement-sudoer-json-file`; mold 2.9.0 fork dest vs submitter; role tables; TP-SUDOER-JSON-* · TP-PRIV-05..09; **CL-FILE-BASED-JSON-APPROVAL** §6 | open watch |
| L-DUAL-MENTION-01 | Verb lives only on the CLI-interface REQ (or help code counted as mention 2); not portable to Python/Node | **CI-M1** / **`LM-CLI-INTERFACE`** §4.1; **CL-CLI-DUAL-MENTION**; **TP-CLI-14**; sufficient-check Step 3h | open watch |
| L-ROLE-TABLE-01 | Printer / generator / `submit-sudoer-request` / `sudoer-adm` merged into the DNS actor table | sudoer-json §2.0 + three-layer §2.1a; ACT-M3a; **TP-PRIV-09** · **TP-SUDOER-JSON-09** · **TP-CF-ACTOR-07** | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + bound SSH transport; incident 20260810-001 | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage | util_resolve_storage; TP-CLI-12 | open watch |
| L-VAULT-NL-01 | `$(…)` strips trailing newlines so `vault subdomain add` concatenates the last label | `cf_labels_append`; TP-CF-VAULT-08 | open watch |
| L-VAULT-SET-01 | `vault set --zone-id` no-op when a zone was already stored | `cf_vault_apply_set_flags`; TP-CF-VAULT-11 | open watch |
| L-LIVE-PERM-01 | Token `zone:zone:edit` is Zone settings, not DNS; `GET /dns_records` stays 403 `10000` | Dashboard **Zone → DNS → Edit** on the specific zone; do not swap away `#dns_records:edit` | open watch |
| L-MODE-SUBSHELL-01 | `$(cf_vault_live_ipv4_count)` + `out_die_code` fail-open (empty count treated as 0/1) | Live count in current shell; API fail must not switch | open watch |
| L-TOKEN-PUB-01 | Cloudflare / forge token **value** pasted into README, reviews, chat-copied into git | file-leaks **C5**; product-review §2.6; `--token-file` 0600; request JSON has no `token` key | open watch |
| L-LPU-MISSING-01 | Named LPU `dns-adm` treated as live while `id dns-adm` is `no such user` | Probe passwd; stay-honest Gap; `sudo install` ≠ create; no ad-hoc `useradd`; default dest `lpu_missing`; incident **20260818-001** | open watch |
| L-HOOK-QUEUE-01 | Setup called dest Type 0 `add-sudoer-request`; dest `self_scope` emptied inbound. Dest Type 0 self-scope is a **blockage**, not a safety net; dest **approval** does not test who submitted | Setup writes inbound (1.8.1); do not call dest Type 0 submit for `login-hook-elev`; incident **20260818-002** | open watch |
| L-QUEUE-CHOWN-01 | After dropping dest Type 0 self-scope, setup `chown`ed hook JSON to `dns-adm`. Sticky inbound then blocked dest `sudoer-adm` move. JSON username field is not file-ownership; dest MUST NOT fence on Unix owner | Setup/submit MUST NOT `chown`; dest takes file-ownership as its LPU then moves (1.9.1); login-hook `interactive` takes inbound ownership **at the beginning** (1.9.2); terms `file-ownership` · `json-username-field`; incident **20260818-003** | open watch |
| L-KIND-SCHEMA-01 | dns-cli always emits JSON `kind`; dest sudoer-cli 1.8.1 closed allowlist has no `kind`; dest Fence refuses inbound (no yes/no). Submitter emit is not dest schema. Dest Type 0 `add-sudoer-request` is not the repair | Dest format law dest-owns sudoer allowlist including `kind`. Queued-body keys proven **TP-FENCE-05** / **TP-SUDOER-JSON-21**. DNS dest rejects `kind` **TP-FENCE-06**. Live dest accept remains **TP-FENCE-07** skip until sibling dest allowlists `kind`. File-ownership dest-writes `submit_by` after format; not `kind`. Incident **20260819-001** | open watch |
| L-SUDOER-PATH-01 | Sudoer JSON emit copies `$GLOBAL_BIN`; tests redirect that to `.ci-homes/…/gbin`; dest applied it to `/etc/sudoers.d/dns-cli-dns-adm`. Login `sudo -n /usr/local/bin/dns-cli interactive` then fails. Law identity is `/usr/local/bin/dns-cli`, not the install-isolation knob | Pin emit+verify to production identity; stub live dest on CI `GLOBAL_BIN` setup; assert inbound path. Do not rewrite `/etc/sudoers.d` from dns-cli. Incident **20260821-001** | open watch |
| L-LPU-DEST-01 | Unspecified vault/DNS used invoking-user XDG after law set LPU dest | Default dest = `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`; no specify + no LPU → `lpu_missing`; Type 2 switch or `lpu_required` (TP-LPU-03) | dest closed 1.8.0; switch closed 1.8.2 |
| L-FENCE-REQ-01 | Dest **Fence** left as only a table cell | Class §2.9 + catalog REQ `requirement-approval-fencing-condition` + Fence REQ; dest tables **point**; **TP-FENCE-01..07** | open watch |
| L-VAULT-REL-01 | Invent `/etc/…/vault/` as “global vault” or collapse with global backup | Local vaults = account-home class; global vault = LPU dest from ordinary login (AV-M11) | open watch |

**Related-product only (do not re-apply as this origin’s law):** L-DEPOSIT-01, L-SUDOERS-01..05 (OS-tool Cmnds / inbound fidelity on the **dest**), L-OVERWRITE-01 stay on folder-backup. This product **does** own the sudoer-approval-submitter leaf. Type O empty-argv / online-channel lessons stay on products that own those surfaces. This product is hop 1 from cli-template.

**This origin’s kept surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv.
