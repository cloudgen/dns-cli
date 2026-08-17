# Lessons — dns-cli

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-TRIM-01 | Backup / restore / sudoers verbs reintroduced as if still product law | bootstrap-chain (absent domain); TP-CLI-04/13 | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + bound SSH transport; incident 20260810-001 | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage | util_resolve_storage; TP-CLI-12 | open watch |
| L-VAULT-NL-01 | `$(…)` strips trailing newlines so `vault subdomain add` concatenates the last label | `cf_labels_append`; TP-CF-VAULT-08 | open watch |
| L-VAULT-SET-01 | `vault set --zone-id` no-op when a zone was already stored | `cf_vault_apply_set_flags`; TP-CF-VAULT-11 | open watch |
| L-LIVE-PERM-01 | Token `zone:zone:edit` is Zone settings, not DNS; `GET /dns_records` stays 403 `10000` | Dashboard **Zone → DNS → Edit** on the specific zone; do not swap away `#dns_records:edit` | open watch |
| L-MODE-SUBSHELL-01 | `$(cf_vault_live_ipv4_count)` + `out_die_code` fail-open (empty count treated as 0/1) | Live count in current shell; API fail must not switch | open watch |
| L-TOKEN-PUB-01 | Cloudflare / forge token **value** pasted into README, reviews, chat-copied into git | file-leaks **C5**; product-review §2.6; `--token-file` 0600; request JSON has no `token` key | open watch |

**Related-product only (do not re-apply as this origin’s law):** L-DEPOSIT-01, L-SUDOERS-01..05, L-OVERWRITE-01 stay on folder-backup. Type O empty-argv / online-channel lessons stay on products that own those surfaces. This product is hop 1 from cli-template.

**This origin’s kept surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv.
