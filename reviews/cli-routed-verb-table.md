# CLI routed-verb table — dns-cli

**Product:** dns-cli  
**Ship unit:** `src/dns-cli`  
**Scan date:** 2026-09-03  
**Mode:** full  
**Copied:** 0 · **Re-checked:** all live tokens  

Inventory from `app_main` dispatcher. Help is not a route.

## Live

| verb | handler | privilege | last modified date | human-readable |
|------|---------|-----------|--------------------|----------------|
| install | `inst_local_install` | you | missing | `install: Install dns-cli (root→global, user→~/.local/bin)` |
| uninstall | `inst_local_uninstall` | you | missing | `uninstall: Remove managed binary (confirm or --force)` |
| where-is-me | `app_where_is_me` | you | missing | `where-is-me: Show running and install paths` |
| version | `app_version` | you | missing | `version: Show local version` |
| about | `app_about` | you | missing | `about: Show diagnostics (Type 0 + vault fields, no token)` |
| help | `app_help` | you | missing | `help: Show this help` |
| menu | `app_default` | you | 2026-09-03 | `menu: Numbered list of live commands` |
| main | `app_default` | you | 2026-09-03 | `main: Alias of menu` |
| setup | `lpu_setup` | change-the-computer | missing | `setup: Create Linux user dns-adm, vault dir, sudoers dest` |
| remove-lpu | `lpu_remove` | change-the-computer | missing | `remove-lpu: Remove Linux user dns-adm` |
| print-sudoers | `lpu_print_sudoers` | you | missing | `print-sudoers: Print the sudoer file (does not install dest)` |
| generate-sudoer-request | `lpu_generate_sudoer_request` | you | missing | `generate-sudoer-request: Write a local JSON grant you can review` |
| submit-sudoer-request | `lpu_submit_sudoer_request` | you | missing | `submit-sudoer-request: Queue a type-2-switch grant as this login` |
| test-json-format | `cf_req_test_json_format` | you | missing | `test-json-format: Per-row dest JSON-format fence (unit test)` |
| fence-test | `cf_req_fence_test` | you | missing | `fence-test: Dest fence list against a local JSON file` |
| vault | `cf_vault_dispatch` | you / dedicated account | missing | `vault: Store or inspect Cloudflare vault` |
| ip | `cf_ip_show` | you | missing | `ip: Show public IPv4 (no vault)` |
| add | `cf_dns_add` | you / dedicated account | missing | `add: Ensure one A record` |
| update | `cf_dns_update` | you / dedicated account | missing | `update: Update existing A record` |
| remove | `cf_dns_remove` | you / dedicated account | missing | `remove: Delete managed A record` |
| status | `cf_dns_status` | you / dedicated account | missing | `status: Show public IP and DNS A records` |
| show | `cf_dns_status` | you / dedicated account | missing | `show: Alias of status` |
| submit | `cf_req_submit` | you | missing | `submit: Queue a DNS request JSON file` |
| approve | `cf_req_approve` | change-the-computer | missing | `approve: Apply a waiting DNS request` |
| reject | `cf_req_reject` | change-the-computer | missing | `reject: Decline a waiting DNS request` |
| interactive | `cf_req_interactive` | change-the-computer | missing | `interactive: Review waiting DNS requests one by one` |

## Not-yet-wired

None. Previous gap `menu`/`main` is now live.

Honesty: dispatcher inventory; dates from handler comment `Last updated:` / `Last reviewed:`; `missing` is not invented. Menu families `DNS Features`, `sudoers`, and `self-management` are **not** live dispatcher tokens (TTY submenu only).
