# =============================================================================
# tests/test_local_lifecycle.sh — local self-install / uninstall / where-is-me
# =============================================================================
# Primary REQs: requirement-shell-local-self-management, requirement-shell-idempotency,
# requirement-shell-interactive-vs-noninteractive
# TP family: TP-LC-* · TP-SI-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_local_lifecycle() {
    t_header "Local lifecycle (TP-LC)"

    require_cmd sh

    ci_isolated_env

    # TP-LC-01 / TP-SI-01 self-install copies this script to USER_BIN (no download)
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:1/no-such-${APP_NAME}" sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-LC-01 self-install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-01 self-install success text" "$_out" "successfully installed"
    assert_contains "TP-LC-01 self-install does not create dns-adm" "$_out" "does not create Linux user dns-adm"
    assert_contains "TP-SI-01 copy from local script" "$_out" "Installing from local script"
    assert_contains "TP-SI-01 starting self-install" "$_out" "Starting self-install"
    assert_not_contains "TP-SI-01 no companion download" "$_out" "Companion link:"

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 / TP-SI-05 idempotent reinstall without force
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "$_out" "already installed"
    assert_contains "TP-LC-03 reinstall does not create dns-adm" "$_out" "does not create Linux user dns-adm"

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
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" self-install >/dev/null 2>&1
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    assert_contains "TP-LC-08 about installed true" "$_out" '"installed":"true"'

    # TP-LC-09 / TP-SI-02 local dest mode must be 0700 (this-login only)
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        700|0700) assert_eq "TP-LC-09 local dest mode 0700" "0700" "0700" ;;
        *) assert_eq "TP-LC-09 local dest mode 0700" "0700" "${_mode}" ;;
    esac
    # Owner must be readable+executable (not 0711 execute-without-read)
    if [ -r "${CI_USER_BIN}/${APP_NAME}" ] && [ -x "${CI_USER_BIN}/${APP_NAME}" ]; then
        assert_eq "TP-LC-09 readable+executable" "1" "1"
    else
        assert_eq "TP-LC-09 readable+executable" "1" "0"
    fi

    # TP-LC-10 re-install without --force heals broken mode (0711 trap) to 0700
    chmod 0711 "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || chmod 711 "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-LC-10 heal reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 already installed path" "$_out" "already installed"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        700|0700) assert_eq "TP-LC-10 healed mode 0700" "0700" "0700" ;;
        *) assert_eq "TP-LC-10 healed mode 0700" "0700" "${_mode}" ;;
    esac

    # TP-LC-11 --global dest mode 0755 (redirected GLOBAL_BIN, no host /usr/local/bin)
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" uninstall --force >/dev/null 2>&1 || true
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" self-install --global --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-11 global self-install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-11 binary at GLOBAL_BIN" "${CI_GLOBAL_BIN}/${APP_NAME}"
    _mode=$(stat -c '%a' "${CI_GLOBAL_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_GLOBAL_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-11 global dest mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-11 global dest mode 0755" "0755" "${_mode}" ;;
    esac

    # TP-LC-12 install remains an alias of self-install
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" uninstall --force >/dev/null 2>&1 || true
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" install --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-12 install alias exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-12 alias placed USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-12 alias copies local script" "$_out" "Installing from local script"

    # TP-SI-04 interpreter $0 (stdin pipe) does not download; fail closed
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" uninstall --force >/dev/null 2>&1 || true
    _out=$(cat "${SCRIPT}" | HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh -s -- self-install 2>&1)
    _ec=$?
    assert_eq "TP-SI-04 pipe self-install exit 1" 1 "$_ec"
    assert_contains "TP-SI-04 pipe local-only" "$_out" "local-only"
    assert_file_missing "TP-SI-04 pipe did not place" "${CI_USER_BIN}/${APP_NAME}"

    # TP-SI-08 TTY=1 self-install still copies this file (no download)
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 sh "${SCRIPT}" self-install 2>&1)
    _ec=$?
    assert_eq "TP-SI-08 interactive self-install exit 0" 0 "$_ec"
    assert_file_exists "TP-SI-08 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-SI-08 copy from local script" "$_out" "Installing from local script"

    # cleanup remaining binary
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
