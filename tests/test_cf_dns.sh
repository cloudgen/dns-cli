# =============================================================================
# tests/test_cf_dns.sh — Cloudflare DNS + ipinfo (stubbed curl, no public net)
# =============================================================================
# Primary REQ: requirement-domain-cloudflare-dns.md
# TP family: TP-CF-DNS-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_cf_dns_seed_vault() {
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

_cf_stub_records() {
    printf '%s' "$1" >"${CF_STUB_DIR}/records.json"
}

run_test_cf_dns() {
    t_header "Cloudflare DNS (TP-CF-DNS)"

    require_cmd python3 || return 0

    ci_vault_env
    export CF_STUB_DIR
    CF_STUB_DIR=$(mktemp -d "${HOME}/stub.XXXXXX")
    export CF_CURL="${TESTS_ROOT}/fixtures/cf_curl_stub.sh"
    chmod +x "${CF_CURL}"
    export CF_STUB_ZONE_NAME="example.test"
    export CF_STUB_ACCOUNT_ID="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    export CF_STUB_ZONE_ID="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

    _cf_dns_seed_vault

    # TP-CF-DNS-01 add no-op same IP
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.10","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json add --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-01 add same IP exit 0" "0" "${_ec}"
    assert_contains "TP-CF-DNS-01 status already" "${_out}" '"status":"already"'

    # TP-CF-DNS-02 add-implies-update
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.20","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json add --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-02 add different IP exit 0" "0" "${_ec}"
    assert_contains "TP-CF-DNS-02 status updated" "${_out}" '"status":"updated"'

    # TP-CF-DNS-03 N>1 fail; status --force still fail
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.10","ttl":300,"proxied":false},{"id":"22222222222222222222222222222222","type":"A","name":"home.example.test","content":"203.0.113.11","ttl":300,"proxied":false}]'
    _err=$(sh "${SCRIPT}" --json add --ip 203.0.113.10 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-03 add N>1 exit 1" "1" "${_ec}"
    assert_contains "TP-CF-DNS-03 add code" "${_err}" "dns_multi_record"
    _err=$(sh "${SCRIPT}" --json status --force --ip 203.0.113.10 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-03 status --force exit 1" "1" "${_ec}"
    assert_contains "TP-CF-DNS-03 status --force code" "${_err}" "dns_multi_record"

    # TP-CF-DNS-04 add --force collapse
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.10","ttl":300,"proxied":false},{"id":"22222222222222222222222222222222","type":"A","name":"home.example.test","content":"203.0.113.11","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json add --force --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-04 add --force exit 0" "0" "${_ec}"
    assert_contains "TP-CF-DNS-04 collapsed" "${_out}" '"status":"collapsed"'

    # TP-CF-DNS-05 empty argv does not call stub
    : >"${CF_STUB_DIR}/calls.log"
    sh "${SCRIPT}" >/dev/null 2>&1
    if [ -s "${CF_STUB_DIR}/calls.log" ]; then
        t_fail "TP-CF-DNS-05 empty argv called stub"
    else
        t_pass "TP-CF-DNS-05 empty argv does not network"
    fi

    # TP-CF-DNS-07 status includes real (stubbed) resolver A
    export CF_TEST_RESOLVE_IP="203.0.113.10"
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.10","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json status --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-07 status exit 0" "0" "${_ec}"
    assert_contains "TP-CF-DNS-07 resolved_ip" "${_out}" '"resolved_ip":"203.0.113.10"'
    assert_contains "TP-CF-DNS-07 in_sync" "${_out}" '"in_sync":"true"'
    unset CF_TEST_RESOLVE_IP

    # TP-CF-DNS-06 --ip 127/8 rejected
    _err=$(sh "${SCRIPT}" --json add --ip 127.0.0.1 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-DNS-06 loopback exit 1" "1" "${_ec}"
    assert_contains "TP-CF-DNS-06 loopback code" "${_err}" "ip_lookup_failed"

    # TP-CF-MODE-01 default mode
    _out=$(sh "${SCRIPT}" --json vault subdomain list 2>/dev/null)
    assert_contains "TP-CF-MODE-01 default non-RR" "${_out}" '"mode":"non-round-robin"'

    # TP-CF-MODE-03 switch to RR when count=1
    _cf_stub_records '[{"id":"11111111111111111111111111111111","type":"A","name":"home.example.test","content":"203.0.113.10","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json vault subdomain mode home round-robin 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-03 switch exit 0" "0" "${_ec}"
    assert_contains "TP-CF-MODE-03 mode" "${_out}" '"mode":"round-robin"'

    # TP-CF-MODE-04 RR add second IP
    _out=$(sh "${SCRIPT}" --json add --ip 203.0.113.20 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-04 RR add exit 0" "0" "${_ec}"
    assert_contains "TP-CF-MODE-04 created" "${_out}" '"status":"created"'

    # TP-CF-MODE-08 RR status N=2
    _out=$(sh "${SCRIPT}" --json status --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-08 RR status exit 0" "0" "${_ec}"
    assert_contains "TP-CF-MODE-08 count" "${_out}" '"ipv4_count":"2"'

    # TP-CF-MODE-05 switch locked at N=2
    _err=$(sh "${SCRIPT}" --json vault subdomain mode home non-round-robin 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-05 locked exit 1" "1" "${_ec}"
    assert_contains "TP-CF-MODE-05 code" "${_err}" "dns_mode_locked"

    # TP-CF-MODE-07 IPv6 rejected
    _err=$(sh "${SCRIPT}" --json add --ip 2001:db8::1 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-07 ipv6 exit 1" "1" "${_ec}"
    assert_contains "TP-CF-MODE-07 code" "${_err}" "ip_lookup_failed"

    # TP-CF-MODE-02 second IP while non-RR (new label)
    sh "${SCRIPT}" --json vault subdomain add web >/dev/null 2>&1
    _cf_stub_records '[{"id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","type":"A","name":"web.example.test","content":"203.0.113.30","ttl":300,"proxied":false}]'
    _out=$(sh "${SCRIPT}" --json add --subdomain web --ip 203.0.113.40 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-MODE-02 non-RR different IP exit 0" "0" "${_ec}"
    assert_contains "TP-CF-MODE-02 updates" "${_out}" '"status":"updated"'

    unset CF_CURL CF_STUB_DIR
    ci_vault_cleanup
}
