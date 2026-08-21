# =============================================================================
# tests/test_cf_request.sh — DNS inbound JSON submit / approve / reject
# =============================================================================
# Primary REQs: requirement-cloudflare-dns-request, requirement-dns-actor-table
# TP families: TP-CF-REQ-* · TP-FENCE-06 · TP-CF-ACTOR submit/approve (routed)
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
    assert_contains "TP-CF-REQ-17 queued submit_app" "$(cat "${_in}/${_rid}")" '"submit_app": "dns-cli"'
    assert_contains "TP-CF-REQ-17 queued submit_version" "$(cat "${_in}/${_rid}")" '"submit_version":'

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

    # TP-FENCE-06 — dest-legal sudoer `kind` is not a DNS dest key (IJF-M8)
    _kind_dns="${CI_HOME}/kind-on-dns.json"
    _cf_req_write "${_kind_dns}" "{
  \"schema_version\": 1,
  \"purpose\": \"nope\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\",
  \"kind\": \"login-hook-elev\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_kind_dns}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-06 / TP-CF-REQ-16 DNS dest rejects kind exit 1" 1 "${_ec}"
    assert_contains "TP-FENCE-06 / TP-CF-REQ-16 DNS dest rejects kind code" "${_err}" "request_invalid"
    assert_contains "TP-FENCE-06 / TP-CF-REQ-16 DNS dest unknown-key sentence" "${_err}" "unknown key"
    assert_contains "TP-FENCE-06 / TP-CF-REQ-16 DNS dest no yes/no" "${_err}" "Dest will not ask yes or no"

    _plant="${CI_HOME}/plant-submit-by.json"
    _cf_req_write "${_plant}" "{
  \"schema_version\": 1,
  \"purpose\": \"plant\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\",
  \"submit_by\": \"spoofed\"
}"
    _err=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_plant}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-15 submit must not include submit_by exit 1" 1 "${_ec}"
    assert_contains "TP-CF-REQ-15 submit_by code" "${_err}" "request_invalid"

    _stadd="${CI_HOME}/stamp-add.json"
    _cf_req_write "${_stadd}" "{
  \"schema_version\": 1,
  \"purpose\": \"Stamp original Unix owner after format check\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\"
}"
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_stadd}" 2>/dev/null)
    assert_eq "TP-CF-REQ-15 submit for stamp exit 0" 0 "$?"
    _srid=$(printf '%s\n' "${_out}" | sed -n 's/.*"request_id":"\([^"]*\)".*/\1/p')
    _sfile="${_in}/${_srid}"
    assert_file_exists "TP-CF-REQ-15 inbound for stamp" "${_sfile}"
    assert_not_contains "TP-CF-REQ-15 inbound has no submit_by yet" "$(cat "${_sfile}")" "submit_by"
    _orig=$(stat -c '%U' "${_sfile}" 2>/dev/null || stat -f '%Su' "${_sfile}")
    (
        out_die_code() { echo "die $*"; return 1; }
        eval "$(sed -n '/^cf_req_stamp_submit_by()/,/^}/p' "${SCRIPT}")"
        cf_req_stamp_submit_by "${_sfile}" "${_orig}"
    )
    assert_contains "TP-CF-REQ-15 dest wrote submit_by" "$(cat "${_sfile}")" "\"submit_by\": \"${_orig}\""

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

    # TP-CF-REQ-14 — user SSOT is JSON subject, not the filename token
    _ssot="${CI_HOME}/20260819-otherperson-add-1.json"
    _cf_req_write "${_ssot}" "{
  \"schema_version\": 1,
  \"purpose\": \"User SSOT is JSON subject\",
  \"subject\": \"${_user}\",
  \"action\": \"add\",
  \"domain_id\": \"example.test\",
  \"subdomain\": \"home\",
  \"ipv4\": \"203.0.113.10\"
}"
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        sh "${SCRIPT}" --json submit "${_ssot}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CF-REQ-14 submit filename subject != JSON subject exit 0" 0 "${_ec}"
    assert_contains "TP-CF-REQ-14 keeps caller basename" "${_out}" "20260819-otherperson-add-1.json"
    assert_contains "TP-CF-REQ-14 JSON subject is invoker" "${_out}" "\"subject\":\"${_user}\""
    _out=$(HOME="${CI_HOME}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        DNS_QUEUE_INBOUND="${_in}" \
        CF_VAULT_DIR="${CF_VAULT_DIR}" CF_CURL="${CF_CURL}" \
        sh "${SCRIPT}" --json --vault-dir "${CF_VAULT_DIR}" approve \
        "20260819-otherperson-add-1.json" 2>/dev/null)
    assert_eq "TP-CF-REQ-14 dest approve filename subject != JSON subject exit 0" 0 "$?"
    assert_file_exists "TP-CF-REQ-14 accepted mismatched basename" \
        "${_acc}/20260819-otherperson-add-1.json"

    _move=$(sed -n '/^cf_req_move()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-09 take ownership before mv" "${_move}" "cf_req_take_ownership"
    assert_contains "TP-CF-REQ-09 prior ownership" "${_move}" "prior ownership"
    _own=$(sed -n '/^cf_req_take_ownership()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-09 chown to LPU" "${_own}" "chown"
    assert_contains "TP-CF-REQ-09 skip live chown in test mode" "${_own}" "lpu_test_mode"
    _hook=$(sed -n '/^cf_req_interactive()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-11 interactive takes inbound ownership" "${_hook}" "cf_req_take_inbound_ownership"
    assert_contains "TP-CF-REQ-11 at the beginning" "${_hook}" "at the beginning"
    _tin=$(sed -n '/^cf_req_take_inbound_ownership()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-15 record original file-ownership" "${_tin}" "original file-ownership"
    assert_contains "TP-CF-REQ-15 take then dest_fence" "${_tin}" "cf_req_dest_fence"
    assert_contains "TP-CF-REQ-15 stamp submit_by if clear" "${_tin}" "cf_req_stamp_submit_by"
    _stamp=$(sed -n '/^cf_req_stamp_submit_by()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-15 stamp writes submit_by" "${_stamp}" 'data["submit_by"]'
    assert_contains "TP-CF-REQ-12 one-off prompt_yes_no" "${_hook}" "prompt_yes_no"
    assert_contains "TP-CF-REQ-12 Approve this request" "${_hook}" "Approve this request"
    assert_contains "TP-CF-REQ-17 interactive queued by" "${_hook}" "queued by"
    assert_not_contains "TP-CF-REQ-12 no skip/quit menu" "${_hook}" "skip / quit"
    _fence=$(sed -n '/^cf_req_dest_fence()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-13 dest fence helper" "${_fence}" "incorrect_json_format"
    assert_contains "TP-CF-REQ-13 dest fence JSON object" "${_fence}" "not a JSON object"
    assert_contains "TP-CF-REQ-15 dest_fence allows submit_by" "${_fence}" "submit_by"
    assert_contains "TP-CF-REQ-17 dest_fence allows submit_app" "${_fence}" "submit_app"
    assert_contains "TP-CF-REQ-17 dest_fence allows submit_version" "${_fence}" "submit_version"
    assert_contains "TP-CF-REQ-14 dest fence User SSOT is JSON subject" "${_fence}" "User SSOT is JSON subject"
    assert_not_contains "TP-CF-REQ-14 dest fence MUST NOT use BN_SUBJECT" "${_fence}" "CF_REQ_BN_SUBJECT"
    _subfn=$(sed -n '/^cf_req_submit()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-17 submit stamps identity" "${_subfn}" "cf_req_stamp_submit_identity"
    assert_not_contains "TP-CF-REQ-14 submit MUST NOT use BN_SUBJECT" "${_subfn}" "CF_REQ_BN_SUBJECT"
    _expl=$(sed -n '/^cf_req_explain_fence()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-REQ-13 human-facing explain" "${_expl}" "Waiting file"
    assert_contains "TP-CF-REQ-13 not offered yes or no" "${_expl}" "not offered for yes or no"
    assert_contains "TP-CF-REQ-13 interactive fences first" "${_hook}" "cf_req_dest_fence"
    assert_contains "TP-CF-REQ-13 interactive explains match" "${_hook}" "cf_req_explain_fence"

    _reqf="${REPO_ROOT}/docs/requirements/requirement-cloudflare-dns-request.md"
    if [ -f "${_reqf}" ]; then
        _rbody=$(cat "${_reqf}")
        assert_contains "TP-CF-REQ-10 REQ-M9 dest fence table" "${_rbody}" "Dest approval fencing conditions (closed)"
        assert_contains "TP-CF-REQ-10 dest fence is incorrect JSON format" "${_rbody}" "incorrect JSON format"
        assert_contains "TP-CF-REQ-10 MUST NOT extra dest fence" "${_rbody}" "Who submitted / dest Type 0 self-scope"
        assert_contains "TP-CF-REQ-14 MUST NOT fence filename subject" "${_rbody}" "Filename subject token"
        assert_contains "TP-CF-REQ-15 REQ dest-written submit_by" "${_rbody}" "submit_by"
    else
        t_fail "TP-CF-REQ-10 missing requirement-cloudflare-dns-request.md"
    fi

    unset CF_TEST_LPU
    unset CF_LPU_ROOT
    unset GLOBAL_BIN
    ci_vault_cleanup
}
