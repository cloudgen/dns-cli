# =============================================================================
# tests/test_cf_request.sh — DNS inbound JSON submit / approve / reject
# =============================================================================
# Primary REQs: requirement-cloudflare-dns-request, requirement-dns-actor-table
# TP families: TP-CF-REQ-* · TP-CF-ACTOR submit/approve (routed)
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_cf_req_write() {
    _path="$1"
    _body="$2"
    printf '%s\n' "${_body}" >"${_path}"
    chmod 0644 "${_path}"
}

run_test_cf_request() {
    t_header "DNS inbound request JSON (TP-CF-REQ)"

    require_cmd python3 || return 0

    ci_vault_env
    export CF_TEST_LPU=1
    export CF_LPU_ROOT="${CI_HOME}/lpu-root"
    mkdir -p "${CF_LPU_ROOT}" "${CI_HOME}/gbin"
    printf '#!/bin/sh\nexit 0\n' >"${CI_HOME}/gbin/${APP_NAME}"
    chmod 0755 "${CI_HOME}/gbin/${APP_NAME}"
    export GLOBAL_BIN="${CI_HOME}/gbin"
    export SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli"

    _out=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        SUDOER_CLI="${SUDOER_CLI}" \
        sh "${SCRIPT}" --json setup 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ setup trio exit 0" 0 "${_ec}"
    _in="${CF_LPU_ROOT}/var/${APP_NAME}/dns-request"
    _acc="${CF_LPU_ROOT}/var/${APP_NAME}/dns-accepted"
    _dec="${CF_LPU_ROOT}/var/${APP_NAME}/dns-declined"
    assert_file_exists "TP-CF-REQ inbound dir" "${_in}"
    assert_file_exists "TP-CF-REQ accepted dir" "${_acc}"
    assert_file_exists "TP-CF-REQ declined dir" "${_dec}"

    _user=$(id -un)
    _add="${CI_HOME}/add-body.json"
    _cf_req_write "${_add}" "{
  \"schema_version\": 1,
  \"purpose\": \"Point office to this host public IPv4\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\",
  \"ttl\": 300,
  \"proxied\": false
}"

    # Seed specify vault so approve apply can run in stub mode
    _tok="${CI_HOME}/tok"
    printf '%s' "test-token-not-a-secret" >"${_tok}"
    chmod 0600 "${_tok}"
    HOME="${CI_HOME}" CF_VAULT_DIR="${CF_VAULT_DIR}" CF_CURL="${CF_CURL}" \
        sh "${SCRIPT}" --json --vault-dir "${CF_VAULT_DIR}" vault set \
        --zone-id bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
        --account-id aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
        --user-id 10000000000000000000000000000001 \
        --domain example.test \
        --subdomain home \
        --token-file "${_tok}" >/dev/null 2>&1

    _out=$(HOME="${CI_HOME}" \
        CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_add}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-01 submit add exit 0" 0 "${_ec}"
    assert_contains "TP-CF-REQ-01 queued" "${_out}" '"type":"submit"'
    assert_contains "TP-CF-REQ-01 action add" "${_out}" '"action":"add"'
    _rid=$(printf '%s\n' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    assert_file_exists "TP-CF-REQ-01 inbound file" "${_in}/${_rid}"
    assert_contains "TP-CF-REQ-01 basename action" "${_rid}" "-add-"
    assert_contains "TP-CF-REQ-01 basename subject" "${_rid}" "-${_user}-"

    _out=$(HOME="${CI_HOME}" \
        CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        CF_VAULT_DIR="${CF_VAULT_DIR}" CF_CURL="${CF_CURL}" \
        sh "${SCRIPT}" --json --vault-dir "${CF_VAULT_DIR}" approve "${_rid}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-01 approve add exit 0" 0 "${_ec}"
    assert_contains "TP-CF-REQ-01 accepted" "${_out}" '"type":"approve"'
    assert_file_exists "TP-CF-REQ-01 accepted file" "${_acc}/${_rid}"
    assert_file_missing "TP-CF-REQ-01 inbound cleared" "${_in}/${_rid}"

    _mode="${CI_HOME}/mode-body.json"
    _cf_req_write "${_mode}" "{
  \"schema_version\": 1,
  \"purpose\": \"Allow api to hold more than one IPv4\",
  \"subject\": \"${_user}\",
  \"action\": \"mode\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"mode\": \"round-robin\"
}"
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_mode}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-05 submit mode exit 0" 0 "${_ec}"
    _mrid=$(printf '%s\n' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        CF_VAULT_DIR="${CF_VAULT_DIR}" CF_CURL="${CF_CURL}" \
        sh "${SCRIPT}" --json --vault-dir "${CF_VAULT_DIR}" reject "${_mrid}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-05 reject mode exit 0" 0 "${_ec}"
    assert_file_exists "TP-CF-REQ-05 declined file" "${_dec}/${_mrid}"

    _upd="${CI_HOME}/upd-body.json"
    _cf_req_write "${_upd}" "{
  \"schema_version\": 1,
  \"purpose\": \"Replace one api A\",
  \"subject\": \"${_user}\",
  \"action\": \"update\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"from_ipv4\": \"203.0.113.20\",
  \"ipv4\": \"203.0.113.21\"
}"
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_upd}" 2>/dev/null)
    assert_eq "TP-CF-REQ-03 submit update exit 0" 0 "$?"
    assert_contains "TP-CF-REQ-03 action update" "${_out}" '"action":"update"'

    _rm="${CI_HOME}/rm-body.json"
    _cf_req_write "${_rm}" "{
  \"schema_version\": 1,
  \"purpose\": \"Drop office A\",
  \"subject\": \"${_user}\",
  \"action\": \"remove\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\"
}"
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_rm}" 2>/dev/null)
    assert_eq "TP-CF-REQ-04 submit remove exit 0" 0 "$?"

    _bad="${CI_HOME}/bad-action.json"
    _cf_req_write "${_bad}" "{
  \"schema_version\": 1,
  \"purpose\": \"nope\",
  \"subject\": \"${_user}\",
  \"action\": \"status\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_bad}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-06 unknown action exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-06 code" "${_err}" "request_invalid"

    _extra="${CI_HOME}/extra.json"
    _cf_req_write "${_extra}" "{
  \"schema_version\": 1,
  \"purpose\": \"nope\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\",
  \"extra\": true
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_extra}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-06 extra key exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-06 extra code" "${_err}" "request_invalid"

    _tokj="${CI_HOME}/tok.json"
    _cf_req_write "${_tokj}" "{
  \"schema_version\": 1,
  \"purpose\": \"leak\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\",
  \"token\": \"cfut_not_a_real_token\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_tokj}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-07 token body exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-07 token code" "${_err}" "request_invalid"

    _v6="${CI_HOME}/v6.json"
    _cf_req_write "${_v6}" "{
  \"schema_version\": 1,
  \"purpose\": \"v6\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"2001:db8::1\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_v6}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-07 ipv6 exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-07 ipv6 code" "${_err}" "request_invalid"

    _mix="${CI_HOME}/mode-ip.json"
    _cf_req_write "${_mix}" "{
  \"schema_version\": 1,
  \"purpose\": \"bad mix\",
  \"subject\": \"${_user}\",
  \"action\": \"mode\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"mode\": \"round-robin\",
  \"ipv4\": \"203.0.113.10\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_mix}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-08 mode plus ipv4 exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-08 code" "${_err}" "request_invalid"

    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json interactive 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ interactive json exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ interactive json code" "${_err}" "confirm_required"

    _err=$(HOME="${CI_HOME}" env -u DNS_QUEUE_INBOUND CF_TEST_LPU=1 CF_LPU_ROOT="${CI_HOME}/empty-lpu" \
        sh "${SCRIPT}" --json submit "${_add}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ submit missing inbound exit 1" 1 "${_ec}"

    unset CF_TEST_LPU
    unset CF_LPU_ROOT
    unset GLOBAL_BIN
    ci_vault_cleanup
}
