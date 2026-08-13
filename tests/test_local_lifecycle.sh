# =============================================================================
# tests/test_local_lifecycle.sh — local install / uninstall / where-is-me
# =============================================================================
# Primary REQs: requirement-shell-local-self-management, requirement-shell-idempotency,
# requirement-shell-interactive-vs-noninteractive
# TP family: TP-LC-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_local_lifecycle() {
    t_header "Local lifecycle (TP-LC)"

    require_cmd sh

    ci_isolated_env

    # TP-LC-01 install places binary under USER_BIN
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-01 install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-01 install success text" "$_out" "Installed"

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 idempotent reinstall without force
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "$_out" "already installed"

    # TP-LC-04 where-is-me
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" where-is-me 2>&1)
    _ec=$?
    assert_eq "TP-LC-04 where-is-me exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 install path" "$_out" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-04 installed yes" "$_out" "yes"

    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json where-is-me 2>/dev/null)
    assert_contains "TP-LC-04 json installed true" "$_out" '"installed":"true"'

    # TP-LC-05 uninstall --json without force fails closed
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json uninstall 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LC-05 uninstall json no-force exit 1" 1 "$_ec"
    assert_file_exists "TP-LC-05 binary remains" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-06 uninstall --force removes
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-06 uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-06 binary removed" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-07 uninstall when absent is success no-op
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-07 uninstall absent exit 0" 0 "$_ec"
    assert_contains "TP-LC-07 nothing to uninstall" "$_out" "not installed"

    # TP-LC-08 about after install shows installed
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install >/dev/null 2>&1
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    assert_contains "TP-LC-08 about installed true" "$_out" '"installed":"true"'

    # TP-LC-09 managed binary mode must be 0755 (shell ship unit multi-user runnable)
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-09 install mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-09 install mode 0755" "0755" "${_mode}" ;;
    esac
    # Must be readable+executable (not 0711 execute-without-read)
    if [ -r "${CI_USER_BIN}/${APP_NAME}" ] && [ -x "${CI_USER_BIN}/${APP_NAME}" ]; then
        assert_eq "TP-LC-09 readable+executable" "1" "1"
    else
        assert_eq "TP-LC-09 readable+executable" "1" "0"
    fi

    # TP-LC-10 re-install without --force heals broken mode (0711 trap)
    chmod 0711 "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || chmod 711 "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-10 heal reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 already installed path" "$_out" "already installed"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-10 healed mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-10 healed mode 0755" "0755" "${_mode}" ;;
    esac

    # cleanup remaining binary
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
