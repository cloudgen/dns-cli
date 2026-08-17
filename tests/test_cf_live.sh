# =============================================================================
# tests/test_cf_live.sh — optional live verify as the invoking user (not cf-adm)
# =============================================================================
# Primary REQ: requirement-domain-cloudflare-dns D-M15 / D-M16
# Default: SKIP unless CF_LIVE=1 and token file is present.
# Never sourced from tests/run.sh.
# =============================================================================

# shellcheck source=helpers.sh
if [ -z "${TESTS_ROOT:-}" ]; then
    TESTS_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    REPO_ROOT=$(CDPATH= cd -- "${TESTS_ROOT}/.." && pwd)
    SCRIPT="${REPO_ROOT}/src/dns-cli"
    # shellcheck source=helpers.sh
    . "${TESTS_ROOT}/helpers.sh"
fi
# shellcheck source=live/common.sh
. "${TESTS_ROOT}/live/common.sh"

run_test_cf_live() {
    t_header "Cloudflare live Type 0 (TP-CF-LIVE)"

    live_load_env || return 0
    if [ "${CF_LIVE:-0}" != "1" ]; then
        t_skip "TP-CF-LIVE-01 CF_LIVE!=1 (offline default)"
        return 0
    fi
    if ! live_need_token; then
        t_skip "TP-CF-LIVE-01 no 0600 token file"
        return 0
    fi
    if [ "$(id -un)" = "cf-adm" ]; then
        t_fail "TP-CF-LIVE-01 must not run as cf-adm"
        return 0
    fi
    t_pass "TP-CF-LIVE-01 invoking user $(id -un) (not cf-adm)"

    if [ -z "${CF_LIVE_ZONE_ID:-}" ] || [ -z "${CF_LIVE_ACCOUNT_ID:-}" ] || [ -z "${CF_LIVE_USER_ID:-}" ]; then
        t_skip "TP-CF-LIVE-02 missing zone/account/user ids (run tests/live/discover.sh)"
        return 0
    fi

    umask 077
    mkdir -p "${LIVE_VAULT}"
    chmod 0700 "${LIVE_VAULT}"

    _out=$(sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" vault account add "${CF_LIVE_DOMAIN}" \
        --user-id "${CF_LIVE_USER_ID}" \
        --zone-id "${CF_LIVE_ZONE_ID}" \
        --account-id "${CF_LIVE_ACCOUNT_ID}" \
        --subdomain "${CF_LIVE_SUBDOMAIN}" \
        --token-file "${CF_LIVE_TOKEN_FILE}" 2>&1)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        case "${_out}" in
            *domain_exists*) t_pass "TP-CF-LIVE-02 slot already present" ;;
            *)
                t_fail "TP-CF-LIVE-02 account add failed"
                return 0
                ;;
        esac
    else
        assert_eq "TP-CF-LIVE-02 account add exit 0" "0" "${_ec}"
        assert_contains "TP-CF-LIVE-02 domain" "${_out}" "\"domain_id\":\"${CF_LIVE_DOMAIN}\""
    fi
    assert_not_contains "TP-CF-LIVE-02 no token in JSON" "${_out}" "$(tr -d '\n\r' <"${CF_LIVE_TOKEN_FILE}")"

    _out=$(sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" --domain "${CF_LIVE_DOMAIN}" \
        --subdomain "${CF_LIVE_SUBDOMAIN}" status --ip 203.0.113.10 2>&1)
    _ec=$?
    assert_eq "TP-CF-LIVE-03 status exit 0" "0" "${_ec}"
    assert_contains "TP-CF-LIVE-03 fqdn" "${_out}" "${CF_LIVE_SUBDOMAIN}.${CF_LIVE_DOMAIN}"

    _out=$(sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" --domain "${CF_LIVE_DOMAIN}" \
        --subdomain "${CF_LIVE_SUBDOMAIN}" add --ip 203.0.113.10 2>&1)
    _ec=$?
    assert_eq "TP-CF-LIVE-04 add probe exit 0" "0" "${_ec}"

    _out=$(sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" --domain "${CF_LIVE_DOMAIN}" \
        --subdomain "${CF_LIVE_SUBDOMAIN}" --ip 203.0.113.10 remove 2>&1)
    _ec=$?
    assert_eq "TP-CF-LIVE-04 remove probe exit 0" "0" "${_ec}"

    _out=$(sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" \
        vault account remove "${CF_LIVE_DOMAIN}" --force 2>&1)
    _ec=$?
    assert_eq "TP-CF-LIVE-05 account remove exit 0" "0" "${_ec}"
    t_info "TP-CF-LIVE-05 revoke the dashboard token by hand"
}

# Allow `sh tests/test_cf_live.sh` standalone
if [ "${0##*/}" = "test_cf_live.sh" ]; then
    PASS=0
    FAIL=0
    SKIP=0
    run_test_cf_live
    printf '\n== live summary ==\n'
    printf 'PASS=%s FAIL=%s SKIP=%s\n' "${PASS}" "${FAIL}" "${SKIP}"
    if [ "${FAIL}" -gt 0 ]; then
        exit 1
    fi
    exit 0
fi
