# =============================================================================
# tests/test_cf_lpu.sh — Type 1 setup / remove-lpu + Type 0 print-sudoers
# =============================================================================
# Primary REQs: requirement-least-privilege-user, requirement-three-layer-privilege-model,
# requirement-sudoer-json-file
# TP families: TP-LPU-* · TP-PRIV-* · TP-SUDOER-JSON-*
# Host useradd is stubbed (CF_TEST_LPU=1). Never mutates real /etc/passwd.
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cf_lpu() {
    t_header "LPU setup / print-sudoers (TP-LPU / TP-PRIV)"

    # TP-PRIV-01 / TP-PRIV-04 — fragment ⊆ Table A; no dest write
    _out=$(sh "${SCRIPT}" print-sudoers 2>/dev/null)
    _ec=$?
    assert_eq "TP-PRIV-01 print-sudoers exit 0" 0 "$_ec"
    assert_contains "TP-PRIV-01 Table A runas dns-adm" "$_out" "ALL=(dns-adm) NOPASSWD:"
    assert_contains "TP-PRIV-01 managed binary" "$_out" "/usr/local/bin/dns-cli"
    assert_contains "TP-PRIV-01 dest comment" "$_out" "/etc/dns-adm/sudoers"
    assert_not_contains "TP-PRIV-04 no ALL=(ALL)" "$_out" "ALL=(ALL)"
    assert_not_contains "TP-PRIV-04 no NOPASSWD: ALL" "$_out" "NOPASSWD: ALL"
    assert_not_contains "TP-PRIV-04 no /bin/sh Cmnd" "$_out" ": /bin/sh"
    assert_not_contains "TP-PRIV-04 no /bin/bash Cmnd" "$_out" ": /bin/bash"
    assert_not_contains "TP-PRIV-04 no useradd" "$_out" "useradd"
    assert_contains "TP-PRIV-01 dest not written (honesty)" "$_out" "did not install"

    # TP-PRIV-02 — trimmed extras stay unknown
    for _verb in print-sudoers-install-script remove-project-sudoers backup restore; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-PRIV-02 ${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-PRIV-02 ${_verb} unknown" "$_err" "Unknown command"
    done

    # TP-PRIV-03 — setup without root and without CF_TEST_LPU fails closed
    _err=$(sh "${SCRIPT}" --json setup 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-PRIV-03 setup no-root exit 1" 1 "$_ec"
    assert_contains "TP-PRIV-03 setup code" "$_err" "lpu_required"
    assert_contains "TP-PRIV-03 setup next sudo" "$_err" "sudo"

    # Isolated stub setup
    ci_vault_env
    export CF_TEST_LPU=1
    export CF_LPU_ROOT="${CI_HOME}/lpu-root"
    mkdir -p "${CF_LPU_ROOT}"
    # Place a fake global binary so F6 dest is allowed without --force
    export GLOBAL_BIN="${CI_HOME}/gbin"
    mkdir -p "${GLOBAL_BIN}"
    printf '#!/bin/sh\nexit 0\n' >"${GLOBAL_BIN}/${APP_NAME}"
    chmod 0755 "${GLOBAL_BIN}/${APP_NAME}"

    _out=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli" \
        sh "${SCRIPT}" --json setup 2>/dev/null)
    _ec=$?
    assert_eq "TP-LPU-01 setup exit 0" 0 "$_ec"
    assert_contains "TP-LPU-01 created" "$_out" '"created":"true"'
    assert_contains "TP-LPU-01 user" "$_out" '"user":"dns-adm"'
    assert_contains "TP-SUDOER-JSON-14 setup skip hook submit" "$_out" '"login_hook_sudoer":"skipped"'
    _home="${CF_LPU_ROOT}/etc/dns-adm"
    _vault="${_home}/.local/vaults/${APP_NAME}"
    _dest="${_home}/sudoers"
    _pw="${CF_LPU_ROOT}/passwd"
    assert_file_exists "TP-LPU-01 home" "${_home}"
    assert_file_exists "TP-LPU-01 vaults parent" "${_home}/.local/vaults"
    assert_file_exists "TP-LPU-01 vault dir" "${_vault}"
    assert_file_exists "TP-LPU-01 sudoers dest" "${_dest}"
    _about=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        env -u CF_VAULT_DIR sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-LPU-01 about default dest" "${_about}" "${_vault}"
    assert_file_exists "TP-LPU-01 stub passwd" "${_pw}"
    assert_contains "TP-LPU-01 passwd row" "$(cat "${_pw}")" "dns-adm:"
    assert_file_exists "TP-LPU-01 heal bashrc" "${_home}/.bashrc"
    assert_contains "TP-LPU-01 heal hook" "$(cat "${_home}/.bashrc")" "# BEGIN dns-cli login hook"
    assert_file_exists "TP-LPU-01 heal profile" "${_home}/.profile"
    _mode=$(stat -c '%a' "${_vault}" 2>/dev/null || stat -f '%OLp' "${_vault}")
    case "${_mode}" in
        700|0700) assert_eq "TP-LPU-01 vault 0700" "0700" "0700" ;;
        *) assert_eq "TP-LPU-01 vault 0700" "0700" "${_mode}" ;;
    esac
    _smode=$(stat -c '%a' "${_dest}" 2>/dev/null || stat -f '%OLp' "${_dest}")
    case "${_smode}" in
        440|0440) assert_eq "TP-LPU-01 sudoers 0440" "0440" "0440" ;;
        *) assert_eq "TP-LPU-01 sudoers 0440" "0440" "${_smode}" ;;
    esac
    assert_contains "TP-LPU-01 dest Table A" "$(cat "${_dest}")" "ALL=(dns-adm) NOPASSWD:"

    _out=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        sh "${SCRIPT}" --json setup 2>/dev/null)
    _ec=$?
    assert_eq "TP-LPU-02 re-setup exit 0" 0 "$_ec"
    assert_contains "TP-LPU-02 healed" "$_out" '"created":"false"'
    _n1=$(grep -c '# BEGIN dns-cli login hook' "${_home}/.bashrc")
    assert_eq "TP-LPU-02 hook once" "1" "${_n1}"

    # TP-LPU-03 — stub LPU exists; invoker is not dns-adm; no specify → lpu_required
    _err=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        env -u CF_VAULT_DIR sh "${SCRIPT}" --json vault show 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LPU-03 default vault other user exit 1" 1 "${_ec}"
    assert_contains "TP-LPU-03 code" "${_err}" "lpu_required"
    assert_contains "TP-LPU-03 next generate" "${_err}" "generate-sudoer-request"
    assert_contains "TP-LPU-03 next submit" "${_err}" "submit-sudoer-request"
    assert_not_contains "TP-LPU-03 not lpu_missing" "${_err}" "lpu_missing"

    _err=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        env -u CF_VAULT_DIR sh "${SCRIPT}" --json status home 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LPU-03 status other user exit 1" 1 "${_ec}"
    assert_contains "TP-LPU-03 status code" "${_err}" "lpu_required"

    _vqa="${CI_HOME}/qa-vault-switch"
    mkdir -p "${_vqa}"
    chmod 0700 "${_vqa}"
    _out=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        sh "${SCRIPT}" --vault-dir "${_vqa}" --json vault show 2>&1)
    assert_not_contains "TP-LPU-03 specify skips switch" "${_out}" "lpu_required"
    assert_not_contains "TP-LPU-03 specify not lpu_missing" "${_out}" "lpu_missing"

    _about=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        env -u CF_VAULT_DIR sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-LPU-03 about no switch exit 0" 0 "${_ec}"
    assert_contains "TP-LPU-03 about default dest" "${_about}" "${_vault}"

    # TP-LPU-04 specify vault still works without a live host dns-adm
    _vdir="${CI_HOME}/qa-vault"
    mkdir -p "${_vdir}"
    _out=$(sh "${SCRIPT}" --vault-dir "${_vdir}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-LPU-04 specify about exit 0" 0 "$_ec"
    assert_contains "TP-LPU-04 vault_dir" "$_out" "${_vdir}"

    # TP-LPU-05 uninstall does not userdel
    mkdir -p "${CI_USER_BIN}"
    sh "${SCRIPT}" install >/dev/null 2>&1 || true
    sh "${SCRIPT}" uninstall --force >/dev/null 2>&1 || true
    assert_file_exists "TP-LPU-05 stub passwd after uninstall" "${_pw}"
    assert_contains "TP-LPU-05 account remains" "$(cat "${_pw}")" "dns-adm:"
    assert_file_exists "TP-LPU-05 home after uninstall" "${_home}"

    # TP-LPU-06 remove-lpu JSON without --force
    _err=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        sh "${SCRIPT}" --json remove-lpu 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LPU-06 no-force exit 1" 1 "$_ec"
    assert_contains "TP-LPU-06 confirm_required" "$_err" "confirm_required"
    assert_file_exists "TP-LPU-06 still present" "${_pw}"

    _out=$(GLOBAL_BIN="${GLOBAL_BIN}" CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        sh "${SCRIPT}" --json remove-lpu --force 2>/dev/null)
    _ec=$?
    assert_eq "TP-LPU-06 force exit 0" 0 "$_ec"
    assert_contains "TP-LPU-06 removed" "$_out" '"status":"removed"'
    if grep -q "^dns-adm:" "${_pw}" 2>/dev/null; then
        t_fail "TP-LPU-06 stub passwd still has dns-adm"
    else
        t_pass "TP-LPU-06 stub passwd cleared"
    fi

    unset CF_TEST_LPU
    unset CF_LPU_ROOT
    unset GLOBAL_BIN
    ci_vault_cleanup

    # --- JSON sudoer generate / submit (TP-SUDOER-JSON / TP-PRIV-05..08) ---
    ci_isolated_env
    unset GLOBAL_BIN
    _user=$(id -un)
    _gen_default="${CI_HOME}/.config/${APP_NAME}/sudoer-request-${_user}.json"

    # TP-PRIV-05 / TP-SUDOER-JSON-08 — independent generate dest
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local 2>&1)
    _ec=$?
    assert_eq "TP-PRIV-05 generate exit 0" 0 "${_ec}"
    assert_file_exists "TP-SUDOER-JSON-08 default dest exists" "${_gen_default}"
    _body=$(cat "${_gen_default}" 2>/dev/null || true)
    assert_contains "TP-SUDOER-JSON-01 path global dns-cli" "${_body}" '"path":"/usr/local/bin/dns-cli"'
    assert_contains "TP-SUDOER-JSON-03 runas dns-adm" "${_body}" '"runas":"dns-adm"'
    assert_contains "TP-SUDOER-JSON-03 service dns-cli" "${_body}" '"service":"dns-cli"'
    assert_contains "TP-SUDOER-JSON-03 empty args" "${_body}" '"args":[]'
    assert_contains "TP-SUDOER-JSON-10 kind type-2-switch" "${_body}" '"kind":"type-2-switch"'
    assert_not_contains "TP-SUDOER-JSON-02 no mkdir" "${_body}" "mkdir"
    assert_not_contains "TP-SUDOER-JSON-02 no /usr/bin/cp" "${_body}" "/usr/bin/cp"
    assert_not_contains "TP-SUDOER-JSON-03 no runas root" "${_body}" '"runas":"root"'
    if [ -r "${_gen_default}" ]; then
        t_pass "TP-SUDOER-JSON-08 dest readable without sudo"
    else
        t_fail "TP-SUDOER-JSON-08 dest readable without sudo"
    fi
    assert_contains "TP-PRIV-05 human next submit" "${_out}" "submit-sudoer-request"

    _gen_exp="${CI_HOME}/grant.json"
    HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local "${_gen_exp}" >/dev/null 2>&1
    assert_file_exists "TP-PRIV-05 explicit dest" "${_gen_exp}"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local /etc/sudoers.d/dns-cli-nope 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-PRIV-05 refuse /etc exit 1" 1 "${_ec}"
    assert_contains "TP-PRIV-05 refuse /etc message" "${_err}" "/etc"

    # TP-PRIV-06 — submit fail-closed when dest CLI missing
    _err=$(HOME="${CI_HOME}" SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-PRIV-06 missing cli exit 1" 1 "${_ec}"
    assert_contains "TP-PRIV-06 missing sudoer-cli" "${_err}" "sudoer-cli not found"

    # TP-PRIV-08 — refuse OS-tool grant
    _bad="${CI_HOME}/bad-grant.json"
    printf '%s\n' '{"schema_version":1,"purpose":"x","username":"u","service":"dns-cli","action":"add","commands":[{"runas":"root","tags":["NOPASSWD"],"path":"/usr/bin/mkdir","args":["-p","/tmp"]}]}' >"${_bad}"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_bad}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-PRIV-08 refuse OS-tool exit 1" 1 "${_ec}"
    assert_contains "TP-PRIV-08 refuse message" "${_err}" "OS-tool"

    # TP-PRIV-07 — submit via stub; no /etc/sudoers.d write
    _stub_dir="${CI_HOME}/stub-sudoer"
    mkdir -p "${_stub_dir}/bin" "${_stub_dir}/sudoer-request"
    cat > "${_stub_dir}/bin/sudoer-cli" <<'STUB'
#!/bin/sh
_file=""
_svc=""
while [ $# -gt 0 ]; do
    case "$1" in
        --json) ;;
        --file) _file="$2"; shift ;;
        --purpose) shift ;;
        --service) _svc="$2"; shift ;;
        add-sudoer-request|update-sudoer-request) ;;
        *) ;;
    esac
    shift
done
[ -n "${_file}" ] && [ -f "${_file}" ] || exit 1
_id="sudoer-20260818-${_svc:-dns-cli}-stub-add-1.json"
_in="${SUDOER_QUEUE_INBOUND:-}"
[ -d "${_in}" ] || _in="${LPU_HOME:-}/sudoer-request"
[ -d "${_in}" ] || exit 1
cp "${_file}" "${_in}/${_id}" || exit 1
printf 'request_id=%s\n' "${_id}"
exit 0
STUB
    chmod 0755 "${_stub_dir}/bin/sudoer-cli"
    _out=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="${_user}" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-request" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local --add 2>&1)
    _ec=$?
    assert_eq "TP-PRIV-07 submit stub exit 0" 0 "${_ec}"
    assert_contains "TP-PRIV-07 request_id" "${_out}" "request_id="
    _njson=$(find "${_stub_dir}/sudoer-request" -type f | wc -l | tr -d ' ')
    assert_eq "TP-PRIV-07 inbound has file" 1 "${_njson}"
    _stub_body=$(cat "${_stub_dir}/sudoer-request/"*.json 2>/dev/null || true)
    assert_contains "TP-PRIV-07 inbound runas dns-adm" "${_stub_body}" '"runas":"dns-adm"'
    assert_contains "TP-PRIV-07 inbound path" "${_stub_body}" '"path":"/usr/local/bin/dns-cli"'
    assert_file_missing "TP-PRIV-07 no /etc/sudoers.d dest" "/etc/sudoers.d/dns-cli-${_user}"
    assert_not_contains "TP-PRIV-07 human no dest write claim" "${_out}" "Wrote /etc/sudoers.d"

    # TP-SUDOER-JSON-11 — generate login-hook-elev fixture
    _hook_dest="${CI_HOME}/.config/${APP_NAME}/sudoer-request-dns-adm-login-hook.json"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local --kind login-hook-elev 2>&1)
    _ec=$?
    assert_eq "TP-SUDOER-JSON-11 generate hook exit 0" 0 "${_ec}"
    assert_file_exists "TP-SUDOER-JSON-11 hook dest exists" "${_hook_dest}"
    _hbody=$(cat "${_hook_dest}" 2>/dev/null || true)
    assert_contains "TP-SUDOER-JSON-11 kind" "${_hbody}" '"kind":"login-hook-elev"'
    assert_contains "TP-SUDOER-JSON-11 username dns-adm" "${_hbody}" '"username":"dns-adm"'
    assert_contains "TP-SUDOER-JSON-11 runas root" "${_hbody}" '"runas":"root"'
    assert_contains "TP-SUDOER-JSON-11 args interactive" "${_hbody}" '"args":["interactive"]'
    assert_contains "TP-SUDOER-JSON-11 path" "${_hbody}" '"path":"/usr/local/bin/dns-cli"'

    # TP-SUDOER-JSON-12 — Type 0 submit refuses hook kind
    _err=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="${_user}" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-request" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_hook_dest}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-SUDOER-JSON-12 submit hook kind exit 1" 1 "${_ec}"
    assert_contains "TP-SUDOER-JSON-12 refuse message" "${_err}" "Type 0 (current login, no sudo, type-2-switch only)"
    assert_contains "TP-SUDOER-JSON-12 next is Type 1 setup" "${_err}" "Type 1 setup"

    # TP-SUDOER-JSON-13 — setup auto-submits hook kind when sibling present
    export CF_TEST_LPU=1
    export CF_LPU_ROOT="${CI_HOME}/lpu-root-hook"
    mkdir -p "${CF_LPU_ROOT}" "${CI_HOME}/gbin"
    if [ ! -x "${CI_HOME}/gbin/${APP_NAME}" ]; then
        printf '#!/bin/sh\nexit 0\n' >"${CI_HOME}/gbin/${APP_NAME}"
        chmod 0755 "${CI_HOME}/gbin/${APP_NAME}"
    fi
    _out=$(HOME="${CI_HOME}" \
        GLOBAL_BIN="${CI_HOME}/gbin" \
        CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="${_user}" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-request" \
        sh "${SCRIPT}" --json setup 2>/dev/null)
    _ec=$?
    assert_eq "TP-SUDOER-JSON-13 setup with sibling exit 0" 0 "${_ec}"
    assert_contains "TP-SUDOER-JSON-13 login_hook submitted" "${_out}" '"login_hook_sudoer":"submitted"'
    _hook_in=$(grep -l 'login-hook-elev' "${_stub_dir}/sudoer-request/"*.json 2>/dev/null | head -n 1)
    if [ -n "${_hook_in}" ]; then
        t_pass "TP-SUDOER-JSON-13 inbound has login-hook-elev"
        assert_contains "TP-SUDOER-JSON-13 inbound runas root" "$(cat "${_hook_in}")" '"runas":"root"'
        assert_contains "TP-SUDOER-JSON-13 inbound interactive" "$(cat "${_hook_in}")" '"interactive"'
    else
        t_fail "TP-SUDOER-JSON-13 inbound has login-hook-elev"
    fi
    assert_file_missing "TP-SUDOER-JSON-13 no /etc/sudoers.d dest" "/etc/sudoers.d/dns-cli-dns-adm"

    # TP-SUDOER-JSON-16 — dest Type 0 self_scope is a blockage; setup still writes inbound
    _block="${CI_HOME}/stub-sudoer-block"
    mkdir -p "${_block}/bin" "${_block}/sudoer-request"
    cat > "${_block}/bin/sudoer-cli" <<'STUB'
#!/bin/sh
for _a in "$@"; do
    case "${_a}" in
        add-sudoer-request|update-sudoer-request)
            printf '%s\n' '{"type":"out_error","message":"self-scope","code":"self_scope"}' >&2
            exit 1
            ;;
    esac
done
exit 0
STUB
    chmod 0755 "${_block}/bin/sudoer-cli"
    export CF_TEST_LPU=1
    export CF_LPU_ROOT="${CI_HOME}/lpu-root-hook-block"
    mkdir -p "${CF_LPU_ROOT}" "${CI_HOME}/gbin"
    if [ ! -x "${CI_HOME}/gbin/${APP_NAME}" ]; then
        printf '#!/bin/sh\nexit 0\n' >"${CI_HOME}/gbin/${APP_NAME}"
        chmod 0755 "${CI_HOME}/gbin/${APP_NAME}"
    fi
    _out=$(HOME="${CI_HOME}" \
        GLOBAL_BIN="${CI_HOME}/gbin" \
        CF_TEST_LPU=1 CF_LPU_ROOT="${CF_LPU_ROOT}" \
        SUDOER_CLI="${_block}/bin/sudoer-cli" \
        SUDOER_ADM_USER="${_user}" \
        SUDOER_QUEUE_INBOUND="${_block}/sudoer-request" \
        sh "${SCRIPT}" --json setup 2>/dev/null)
    _ec=$?
    assert_eq "TP-SUDOER-JSON-16 dest self_scope does not fail setup" 0 "${_ec}"
    assert_contains "TP-SUDOER-JSON-16 login_hook submitted" "${_out}" '"login_hook_sudoer":"submitted"'
    _hook_in=$(grep -l 'login-hook-elev' "${_block}/sudoer-request/"*.json 2>/dev/null | head -n 1)
    if [ -n "${_hook_in}" ]; then
        t_pass "TP-SUDOER-JSON-16 inbound written despite dest Type 0 self_scope"
    else
        t_fail "TP-SUDOER-JSON-16 inbound written despite dest Type 0 self_scope"
    fi

    unset CF_TEST_LPU
    unset CF_LPU_ROOT

    ci_cleanup_env

    # TP-PRIV-09 / TP-SUDOER-JSON-09 — role tables are product law, not merged with DNS actors
    _tl="${REPO_ROOT}/docs/requirements/requirement-three-layer-privilege-model.md"
    _sj="${REPO_ROOT}/docs/requirements/requirement-sudoer-json-file.md"
    if [ -f "${_tl}" ]; then
        _tbody=$(cat "${_tl}")
        assert_contains "TP-PRIV-09 printer role" "${_tbody}" "**Printer**"
        assert_contains "TP-PRIV-09 generator role" "${_tbody}" "**Generator**"
        assert_contains "TP-PRIV-09 submitter role" "${_tbody}" "**Submitter**"
        assert_contains "TP-PRIV-09 print-sudoers named" "${_tbody}" '`print-sudoers`'
        assert_contains "TP-PRIV-09 generate named" "${_tbody}" '`generate-sudoer-request`'
        assert_contains "TP-PRIV-09 submit named" "${_tbody}" '`submit-sudoer-request`'
        assert_contains "TP-PRIV-09 AC-P7 role table" "${_tbody}" "AC-P7"
        assert_contains "TP-PRIV-09 not merge DNS actors" "${_tbody}" "merge those three tables"
    else
        t_fail "TP-PRIV-09 missing requirement-three-layer-privilege-model.md"
    fi
    if [ -f "${_sj}" ]; then
        _sbody=$(cat "${_sj}")
        assert_contains "TP-SUDOER-JSON-09 SJ-M1" "${_sbody}" "SJ-M1"
        assert_contains "TP-SUDOER-JSON-09 printer role" "${_sbody}" "**Printer**"
        assert_contains "TP-SUDOER-JSON-09 generator role" "${_sbody}" "**Generator**"
        assert_contains "TP-SUDOER-JSON-09 submitter role" "${_sbody}" "**Submitter**"
        assert_contains "TP-SUDOER-JSON-09 sibling sudoer-adm" "${_sbody}" '`sudoer-adm`'
        assert_contains "TP-SUDOER-JSON-09 not DNS actor table" "${_sbody}" "be collapsed into the DNS actor table"
        assert_contains "TP-SUDOER-JSON-09 AC-11 role table" "${_sbody}" "AC-11"
        assert_contains "TP-SUDOER-JSON-09 AC-12 print file" "${_sbody}" "AC-12"
        assert_contains "TP-SUDOER-JSON-15 kind type-2-switch" "${_sbody}" "type-2-switch"
        assert_contains "TP-SUDOER-JSON-15 kind login-hook-elev" "${_sbody}" "login-hook-elev"
        assert_contains "TP-SUDOER-JSON-15 hook auto-submitter" "${_sbody}" "Hook auto-submitter"
        assert_contains "TP-SUDOER-JSON-15 SJ-M3 door" "${_sbody}" "SJ-M3"
        assert_contains "TP-SUDOER-JSON-15 dest Type 0 self-scope blockage" "${_sbody}" "blockage"
        assert_contains "TP-SUDOER-JSON-17 SJ-M4 three dests" "${_sbody}" "SJ-M4"
        assert_contains "TP-SUDOER-JSON-17 switch dest" "${_sbody}" "/etc/sudoers.d/dns-cli-<user>"
        assert_contains "TP-SUDOER-JSON-17 hook dest" "${_sbody}" "/etc/sudoers.d/dns-cli-dns-adm"
        assert_contains "TP-SUDOER-JSON-17 F6 dest" "${_sbody}" "/etc/dns-adm/sudoers"
    else
        t_fail "TP-SUDOER-JSON-09 missing requirement-sudoer-json-file.md"
    fi
}
