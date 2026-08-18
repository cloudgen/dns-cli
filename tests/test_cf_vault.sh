# =============================================================================
# tests/test_cf_vault.sh — Cloudflare vault (offline)
# =============================================================================
# Primary REQ: requirement-cloudflare-vault.md
# Path/specify REQ: requirement-application-local-vault.md
# TP family: TP-CF-VAULT-* · TP-AV-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_cf_vault_seed() {
    _tok="${HOME}/tok"
    printf '%s' "test-token-not-a-secret" >"${_tok}"
    chmod 0600 "${_tok}"
    sh "${SCRIPT}" --json vault set \
        --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
        --account-id aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
        --user-id 10000000000000000000000000000001 \
        --domain example.test \
        --subdomain home \
        --token-file "${_tok}" >/dev/null 2>&1
}

run_test_cf_vault() {
    t_header "Cloudflare vault (TP-CF-VAULT)"

    require_cmd python3 || return 0

    ci_vault_env

    _cf_vault_seed
    _vdir="${CF_VAULT_DIR}"
    _slot="${_vdir}/accounts/example.test"
    _dm=$(stat -c '%a' "${_vdir}" 2>/dev/null || echo "")
    _jm=$(stat -c '%a' "${_slot}/vault.json" 2>/dev/null || echo "")
    _tm=$(stat -c '%a' "${_slot}/token" 2>/dev/null || echo "")
    assert_eq "TP-CF-VAULT-01 dir 0700" "700" "${_dm}"
    assert_eq "TP-CF-VAULT-01 vault.json 0600" "600" "${_jm}"
    assert_eq "TP-CF-VAULT-01 token 0600" "600" "${_tm}"

    assert_not_contains "TP-CF-VAULT-06 token absent from vault.json" \
        "$(cat "${_slot}/vault.json")" "test-token"

    _out=$(sh "${SCRIPT}" --json vault show 2>/dev/null)
    assert_eq "TP-CF-VAULT-03 show exit 0" "0" "$?"
    assert_not_contains "TP-CF-VAULT-03 no token value" "${_out}" "test-token"
    assert_contains "TP-CF-VAULT-03 token_present" "${_out}" '"token_present":"true"'

    _err=$(sh "${SCRIPT}" --json vault subdomain remove home 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-04 last-label exit non-zero" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-04 last-label code" "${_err}" "subdomain_required"

    _bad="${HOME}/tok0644"
    printf '%s' "x" >"${_bad}"
    chmod 0644 "${_bad}"
    _err=$(sh "${SCRIPT}" --json vault set --token-file "${_bad}" \
        --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
        --account-id aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
        --domain example.test --subdomain home 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-05 token-file 0644 exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-05 token-file code" "${_err}" "vault_insecure"

    _err=$(sh "${SCRIPT}" --json vault input 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-07 input --json exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-07 input --json code" "${_err}" "confirm_required"

    # TP-CF-VAULT-08 subdomain add + list
    _out=$(sh "${SCRIPT}" --json vault subdomain add office 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-08 add exit 0" "0" "${_ec}"
    assert_contains "TP-CF-VAULT-08 add label" "${_out}" '"subdomain":"office"'
    _out=$(sh "${SCRIPT}" --json vault subdomain list 2>/dev/null)
    assert_eq "TP-CF-VAULT-08 list exit 0" "0" "$?"
    assert_contains "TP-CF-VAULT-08 list home" "${_out}" '"label":"home"'
    assert_contains "TP-CF-VAULT-08 list office" "${_out}" '"label":"office"'
    assert_contains "TP-CF-VAULT-08 list mode" "${_out}" '"mode":"non-round-robin"'

    # TP-CF-VAULT-09 remove one then last still protected; clear needs --force
    _out=$(sh "${SCRIPT}" --json vault subdomain remove office 2>/dev/null)
    assert_eq "TP-CF-VAULT-09 remove extra exit 0" "0" "$?"
    _err=$(sh "${SCRIPT}" --json vault clear 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-09 clear no-force exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-09 clear code" "${_err}" "confirm_required"
    assert_file_exists "TP-CF-VAULT-09 vault remains" "${_slot}/vault.json"
    _out=$(sh "${SCRIPT}" --json vault clear --force 2>/dev/null)
    assert_eq "TP-CF-VAULT-09 clear --force exit 0" "0" "$?"
    assert_file_missing "TP-CF-VAULT-09 vault.json gone" "${_slot}/vault.json"
    assert_file_missing "TP-CF-VAULT-09 token gone" "${_slot}/token"
    assert_file_missing "TP-CF-VAULT-09 index gone" "${_vdir}/index.json"

    # re-seed after clear
    _cf_vault_seed

    # TP-CF-VAULT-10 invalid zone_id
    _err=$(sh "${SCRIPT}" --json vault set --zone-id not-hex \
        --account-id aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
        --user-id 10000000000000000000000000000001 \
        --domain example.test --subdomain home \
        --token-file "${HOME}/tok" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-10 bad zone exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-10 code" "${_err}" "vault_invalid"

    # TP-CF-VAULT-11 vault wins over CF_* env; vault set --zone-id rewrites
    _out=$(CF_ZONE_ID=cccccccccccccccccccccccccccccccc \
        sh "${SCRIPT}" --json vault show 2>/dev/null)
    assert_eq "TP-CF-VAULT-11 env show exit 0" "0" "$?"
    assert_contains "TP-CF-VAULT-11 vault wins" "${_out}" '"zone_id":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
    assert_not_contains "TP-CF-VAULT-11 env not applied" "${_out}" '"zone_id":"cccccccccccccccccccccccccccccccc"'
    _out=$(sh "${SCRIPT}" --json vault set --zone-id cccccccccccccccccccccccccccccccc 2>/dev/null)
    assert_eq "TP-CF-VAULT-11 set rewrite exit 0" "0" "$?"
    _out=$(sh "${SCRIPT}" --json vault show 2>/dev/null)
    assert_contains "TP-CF-VAULT-11 set rewrote zone" "${_out}" '"zone_id":"cccccccccccccccccccccccccccccccc"'
    # restore original zone for later cases
    sh "${SCRIPT}" --json vault set --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb >/dev/null 2>&1

    # TP-CF-VAULT-12 --token argv rejected
    _err=$(sh "${SCRIPT}" --json vault set --token leaked 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-12 --token exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-12 unknown" "${_err}" "Unknown command or flag"

    # TP-CF-VAULT-13 XDG is not dest; no specify + no LPU → lpu_missing
    _err=$(CF_TEST_LPU=1 env -u CF_VAULT_DIR -u CF_LPU_ROOT XDG_CONFIG_HOME=/tmp \
        sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-13 xdg /tmp exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-13 code" "${_err}" "lpu_missing"

    # TP-CF-VAULT-14 uninstall does not wipe vault
    mkdir -p "${HOME}/.global-bin"
    export GLOBAL_BIN="${HOME}/.global-bin"
    sh "${SCRIPT}" --json install >/dev/null 2>&1
    sh "${SCRIPT}" --json uninstall --force >/dev/null 2>&1
    assert_file_exists "TP-CF-VAULT-14 vault.json after uninstall" "${_slot}/vault.json"
    assert_file_exists "TP-CF-VAULT-14 token after uninstall" "${_slot}/token"
    unset GLOBAL_BIN

    # TP-CF-VAULT-15 loosened vault.json mode
    chmod 0644 "${_slot}/vault.json"
    _err=$(sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-15 0644 exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-15 code" "${_err}" "vault_insecure"
    chmod 0600 "${_slot}/vault.json"

    # TP-CF-VAULT-16 unknown schema_version
    python3 -c '
import json,sys
p=sys.argv[1]
with open(p, encoding="utf-8") as fh:
    data=json.load(fh)
data["schema_version"]=99
with open(p,"w",encoding="utf-8") as fh:
    json.dump(data, fh)
' "${_slot}/vault.json"
    chmod 0600 "${_slot}/vault.json"
    _err=$(sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-16 schema exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-16 code" "${_err}" "vault_invalid"

    # TP-CF-VAULT-17 invalid host-label on add (restore schema first)
    _cf_vault_seed
    _err=$(sh "${SCRIPT}" --json vault subdomain add "bad/label" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-17 slash label exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-17 code" "${_err}" "vault_invalid"

    # TP-AV-01 --vault-dir specifies an alternate local application vault
    _alt="${HOME}/alt-app-vault"
    mkdir -p "${_alt}"
    chmod 0700 "${_alt}"
    _tok2="${HOME}/tok2"
    printf '%s' "test-token-not-a-secret" >"${_tok2}"
    chmod 0600 "${_tok2}"
    _out=$(sh "${SCRIPT}" --json --vault-dir "${_alt}" vault set \
        --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
        --account-id aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
        --user-id 10000000000000000000000000000001 \
        --domain example.test --subdomain home \
        --token-file "${_tok2}" 2>/dev/null)
    assert_eq "TP-AV-01 set exit 0" "0" "$?"
    assert_contains "TP-AV-01 vault_dir" "${_out}" "\"vault_dir\":\"${_alt}\""
    assert_file_exists "TP-AV-01 vault.json in alt" "${_alt}/accounts/example.test/vault.json"
    _out=$(sh "${SCRIPT}" --json --vault-dir "${_alt}" vault show 2>/dev/null)
    assert_eq "TP-AV-01 show exit 0" "0" "$?"
    assert_contains "TP-AV-01 show dir" "${_out}" "\"vault_dir\":\"${_alt}\""

    # TP-AV-02 CF_VAULT_DIR env (no flag)
    _out=$(CF_VAULT_DIR="${_alt}" sh "${SCRIPT}" --json vault show 2>/dev/null)
    assert_eq "TP-AV-02 env show exit 0" "0" "$?"
    assert_contains "TP-AV-02 env dir" "${_out}" "\"vault_dir\":\"${_alt}\""

    # TP-AV-03 specified /tmp rejected
    _err=$(sh "${SCRIPT}" --json --vault-dir /tmp/cf-vault-bad vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-AV-03 /tmp exit 1" "1" "${_ec}"
    assert_contains "TP-AV-03 code" "${_err}" "vault_insecure"

    # TP-AV-04 relative path rejected
    _err=$(sh "${SCRIPT}" --json --vault-dir relative/vault vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-AV-04 relative exit 1" "1" "${_ec}"
    assert_contains "TP-AV-04 code" "${_err}" "vault_insecure"

    # TP-AV-05 help lists specify flag and env
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_eq "TP-AV-05 help exit 0" "0" "$?"
    assert_contains "TP-AV-05 help --vault-dir" "${_help}" "--vault-dir"
    assert_contains "TP-AV-05 help CF_VAULT_DIR" "${_help}" "CF_VAULT_DIR"

    # TP-AV-06 specified safe path works even when HOME=/tmp
    _out=$(HOME=/tmp sh "${SCRIPT}" --json --vault-dir "${_alt}" vault show 2>/dev/null)
    assert_eq "TP-AV-06 HOME=/tmp + specify exit 0" "0" "$?"
    assert_contains "TP-AV-06 dir" "${_out}" "\"vault_dir\":\"${_alt}\""

    # TP-AV-07 no specify + no LPU → lpu_missing (stub so host dns-adm cannot satisfy dest)
    _err=$(CF_TEST_LPU=1 env -u CF_VAULT_DIR -u CF_LPU_ROOT \
        sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-AV-07 no specify exit 1" "1" "${_ec}"
    assert_contains "TP-AV-07 code" "${_err}" "lpu_missing"

    # --- v2 zone-slot CRUD (TP-CF-VAULT-18..33) ---
    _cf_vault_seed
    _tokb="${HOME}/tok-b"
    printf '%s' "second-token-not-a-secret" >"${_tokb}"
    chmod 0600 "${_tokb}"

    _out=$(sh "${SCRIPT}" --json vault account add other.test \
        --zone-id cccccccccccccccccccccccccccccccc \
        --account-id dddddddddddddddddddddddddddddddd \
        --user-id 20000000000000000000000000000002 \
        --subdomain api \
        --token-file "${_tokb}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-18 add second exit 0" "0" "${_ec}"
    assert_contains "TP-CF-VAULT-18 add domain" "${_out}" '"domain_id":"other.test"'
    assert_contains "TP-CF-VAULT-34 probe label" "${_out}" '"probe_label":"_test_'
    assert_file_exists "TP-CF-VAULT-18 second slot" "${_vdir}/accounts/other.test/token"
    _subs=$(sh "${SCRIPT}" --json --domain other.test vault subdomain list 2>/dev/null)
    assert_not_contains "TP-CF-VAULT-34 probe not stored" "${_subs}" '"label":"_test_'

    _tokc="${HOME}/tok-c"
    printf '%s' "third-token-not-a-secret" >"${_tokc}"
    chmod 0600 "${_tokc}"
    CF_STUB_DNS_POST_HTTP=403
    export CF_STUB_DNS_POST_HTTP
    _err=$(sh "${SCRIPT}" --json vault account add fail.test \
        --zone-id eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee \
        --account-id ffffffffffffffffffffffffffffffff \
        --user-id 40000000000000000000000000000004 \
        --subdomain api \
        --token-file "${_tokc}" 2>&1)
    _ec=$?
    unset CF_STUB_DNS_POST_HTTP
    assert_eq "TP-CF-VAULT-34 bad token exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-34 bad token code" "${_err}" "token_probe_failed"
    assert_file_missing "TP-CF-VAULT-34 no fail slot" "${_vdir}/accounts/fail.test/token"
    _out=$(sh "${SCRIPT}" --json vault account list 2>/dev/null)
    assert_eq "TP-CF-VAULT-28 list exit 0" "0" "$?"
    assert_contains "TP-CF-VAULT-28 example" "${_out}" '"domain_id":"example.test"'
    assert_contains "TP-CF-VAULT-28 other" "${_out}" '"domain_id":"other.test"'
    assert_contains "TP-CF-VAULT-28 user" "${_out}" '"user_id":"20000000000000000000000000000002"'
    assert_not_contains "TP-CF-VAULT-33 list no token" "${_out}" "second-token"
    assert_not_contains "TP-CF-VAULT-33 list no first token" "${_out}" "test-token-not-a-secret"

    python3 -c '
import json,sys
p=sys.argv[1]
with open(p, encoding="utf-8") as fh:
    data=json.load(fh)
data["default_domain_id"]=None
with open(p,"w",encoding="utf-8") as fh:
    json.dump(data, fh)
' "${_vdir}/index.json"
    chmod 0600 "${_vdir}/index.json"
    _err=$(sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-19 omit domain exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-19 code" "${_err}" "domain_required"
    sh "${SCRIPT}" --json vault account default example.test >/dev/null 2>&1

    _err=$(sh "${SCRIPT}" --json vault account add example.test \
        --zone-id eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee \
        --account-id ffffffffffffffffffffffffffffffff \
        --user-id 30000000000000000000000000000003 \
        --subdomain www \
        --token-file "${_tokb}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-20 duplicate exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-20 code" "${_err}" "domain_exists"

    _v1="${HOME}/v1-layout"
    mkdir -p "${_v1}"
    chmod 0700 "${_v1}"
    printf '%s' '{"schema_version":1,"zone_id":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","account_id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","domain":"example.test","subdomains":["home"]}' >"${_v1}/vault.json"
    chmod 0600 "${_v1}/vault.json"
    printf '%s' "test-token-not-a-secret" >"${_v1}/token"
    chmod 0600 "${_v1}/token"
    _err=$(sh "${SCRIPT}" --json --vault-dir "${_v1}" vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-21 v1 layout exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-21 code" "${_err}" "vault_invalid"

    _err=$(sh "${SCRIPT}" --json --domain other.test vault subdomain remove api 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-22 last-per-domain exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-22 code" "${_err}" "subdomain_required"

    _err=$(sh "${SCRIPT}" --json vault account add third.test \
        --zone-id 11111111111111111111111111111111 \
        --account-id 22222222222222222222222222222222 \
        --subdomain www \
        --token-file "${_tokb}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-23 missing user_id exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-23 code" "${_err}" "vault_incomplete"

    _err=$(sh "${SCRIPT}" --json vault account add third.test \
        --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
        --account-id 22222222222222222222222222222222 \
        --user-id 30000000000000000000000000000003 \
        --subdomain www \
        --token-file "${_tokb}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-24 same zone_id exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-24 code" "${_err}" "vault_invalid"

    _err=$(sh "${SCRIPT}" --json vault account add third.test \
        --zone-id 11111111111111111111111111111111 \
        --account-id 22222222222222222222222222222222 \
        --user-id 10000000000000000000000000000001 \
        --subdomain www \
        --token-file "${_tokb}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-25 same user_id exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-25 code" "${_err}" "vault_invalid"

    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain add shop 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-26 add exit 0" "0" "${_ec}"
    assert_contains "TP-CF-VAULT-26 default mode" "${_out}" '"mode":"non-round-robin"'

    python3 -c '
import json,sys
p=sys.argv[1]
with open(p, encoding="utf-8") as fh:
    data=json.load(fh)
data["subdomains"]=["bare"]
with open(p,"w",encoding="utf-8") as fh:
    json.dump(data, fh)
' "${_vdir}/accounts/example.test/vault.json"
    chmod 0600 "${_vdir}/accounts/example.test/vault.json"
    _err=$(sh "${SCRIPT}" --json --domain example.test vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-27 bare string exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-27 code" "${_err}" "vault_invalid"
    sh "${SCRIPT}" --json vault account remove example.test --force >/dev/null 2>&1
    _cf_vault_seed

    _out=$(sh "${SCRIPT}" --json vault account modify example.test \
        --zone-id 33333333333333333333333333333333 2>/dev/null)
    assert_eq "TP-CF-VAULT-29 modify exit 0" "0" "$?"
    _out=$(sh "${SCRIPT}" --json vault account list 2>/dev/null)
    assert_contains "TP-CF-VAULT-29 new zone" "${_out}" '"zone_id":"33333333333333333333333333333333"'

    _out=$(sh "${SCRIPT}" --json vault zone list 2>/dev/null)
    assert_eq "TP-CF-VAULT-31 zone list exit 0" "0" "$?"
    assert_contains "TP-CF-VAULT-31 alias" "${_out}" '"type":"vault_account_list"'

    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain add tmp 2>/dev/null)
    assert_eq "TP-CF-VAULT-32 add tmp exit 0" "0" "$?"
    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain modify tmp --label tmp2 2>/dev/null)
    assert_eq "TP-CF-VAULT-32 rename exit 0" "0" "$?"
    assert_contains "TP-CF-VAULT-32 renamed" "${_out}" '"label":"tmp2"'
    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain list 2>/dev/null)
    assert_contains "TP-CF-VAULT-32 list tmp2" "${_out}" '"label":"tmp2"'
    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain remove tmp2 2>/dev/null)
    assert_eq "TP-CF-VAULT-32 remove exit 0" "0" "$?"
    _out=$(sh "${SCRIPT}" --json --domain example.test vault subdomain list 2>/dev/null)
    assert_not_contains "TP-CF-VAULT-32 gone" "${_out}" '"label":"tmp2"'

    _out=$(sh "${SCRIPT}" --json vault account remove other.test --force 2>/dev/null)
    assert_eq "TP-CF-VAULT-30 remove exit 0" "0" "$?"
    _out=$(sh "${SCRIPT}" --json vault account list 2>/dev/null)
    assert_not_contains "TP-CF-VAULT-30 omitted" "${_out}" '"domain_id":"other.test"'
    assert_contains "TP-CF-VAULT-30 example remains" "${_out}" '"domain_id":"example.test"'

    ci_vault_cleanup

    _err=$(CF_TEST_LPU=1 env -u CF_VAULT_DIR -u CF_LPU_ROOT HOME=/tmp \
        sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-02 HOME=/tmp exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-02 HOME=/tmp code" "${_err}" "lpu_missing"

    _err=$(CF_TEST_LPU=1 env -u CF_VAULT_DIR -u CF_LPU_ROOT -u HOME \
        sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-VAULT-02 env -u HOME exit 1" "1" "${_ec}"
    assert_contains "TP-CF-VAULT-02 env -u HOME code" "${_err}" "lpu_missing"
}
