# =============================================================================
# tests/test_cf_ip.sh — public IPv4 display (vault-free QA)
# =============================================================================
# Primary REQ: requirement-external-ipv4.md
# Peer: requirement-domain-cloudflare-dns.md (consumes lookup)
# TP family: TP-CF-IP-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cf_ip() {
    t_header "Public IPv4 display (TP-CF-IP)"

    require_cmd python3 || return 0

    ci_isolated_env
    export CF_STUB_DIR
    CF_STUB_DIR=$(mktemp -d "${HOME}/stub.XXXXXX")
    export CF_CURL="${TESTS_ROOT}/fixtures/cf_curl_stub.sh"
    chmod +x "${CF_CURL}"

    # TP-CF-IP-01 --json ip --ip works without vault (HOME may be /tmp-class)
    _out=$(sh "${SCRIPT}" --json ip --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-IP-01 exit 0" "0" "${_ec}"
    assert_contains "TP-CF-IP-01 command" "${_out}" '"command":"ip"'
    assert_contains "TP-CF-IP-01 public_ip" "${_out}" '"public_ip":"203.0.113.10"'
    assert_contains "TP-CF-IP-01 source override" "${_out}" '"source":"override"'
    if [ -s "${CF_STUB_DIR}/calls.log" ]; then
        t_fail "TP-CF-IP-01 --ip called network stub"
    else
        t_pass "TP-CF-IP-01 --ip does not network"
    fi

    # TP-CF-IP-02 live lookup path hits ipinfo stub only
    : >"${CF_STUB_DIR}/calls.log"
    _out=$(sh "${SCRIPT}" --json ip 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-IP-02 exit 0" "0" "${_ec}"
    assert_contains "TP-CF-IP-02 public_ip" "${_out}" '"public_ip":"203.0.113.10"'
    assert_contains "TP-CF-IP-02 source ipinfo" "${_out}" '"source":"ipinfo"'
    _log=$(cat "${CF_STUB_DIR}/calls.log" 2>/dev/null || true)
    assert_contains "TP-CF-IP-02 called ipinfo" "${_log}" "ipinfo.io"
    assert_not_contains "TP-CF-IP-02 no Cloudflare" "${_log}" "api.cloudflare.com"

    # TP-CF-IP-03 disallowed IPv4
    _err=$(sh "${SCRIPT}" --json ip --ip 127.0.0.1 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-IP-03 loopback exit 1" "1" "${_ec}"
    assert_contains "TP-CF-IP-03 code" "${_err}" "ip_lookup_failed"

    # TP-CF-IP-04 ipinfo HTTP 429
    CF_STUB_IPINFO_CODE=429
    export CF_STUB_IPINFO_CODE
    _err=$(sh "${SCRIPT}" --json ip 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-IP-04 429 exit 1" "1" "${_ec}"
    assert_contains "TP-CF-IP-04 code" "${_err}" "ip_lookup_failed"
    unset CF_STUB_IPINFO_CODE

    unset CF_CURL CF_STUB_DIR
    ci_cleanup_env
}
