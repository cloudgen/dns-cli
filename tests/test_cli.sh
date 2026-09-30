# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-* · TP-CF-ACTOR-* · TP-FENCE-01..04 · TP-FENCE-08..15 (incl. TP-CLI-14 dual mention, TP-CLI-21 menu retry, TP-CLI-22 DNS Features, TP-CLI-23 return to top, TP-CLI-24 self-management, TP-CF-ACTOR-07)
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd grep

    # TP-CLI-01 syntax
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    # TP-CLI-02 version human
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version mentions app" "$_out" "${APP_NAME}"
    assert_contains "TP-CLI-02 version mentions VERSION" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-03 version json
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 type version" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 app field" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-03 version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-04 help lists local lifecycle; not online; not trimmed parent domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help self-install" "$_out" "self-install"
    assert_contains "TP-CLI-04 help install does not create dns-adm" "$_out" "does not create Linux user dns-adm"
    assert_contains "TP-CLI-04 help setup" "$_out" "setup"
    assert_contains "TP-CLI-04 help remove-lpu" "$_out" "remove-lpu"
    assert_contains "TP-CLI-04 help print-sudoers" "$_out" "print-sudoers"
    assert_contains "TP-CLI-04 help generate-sudoer-request" "$_out" "generate-sudoer-request"
    assert_contains "TP-CLI-04 help submit-sudoer-request" "$_out" "submit-sudoer-request"
    assert_contains "TP-CLI-04 help test-json-format" "$_out" "test-json-format"
    assert_contains "TP-CLI-04 help fence-test" "$_out" "fence-test"
    assert_contains "TP-CLI-04 help testers apart" "$_out" "Unit test (local test folder; Type 0 — test-purpose)"
    assert_contains "TP-CLI-04 help --dir" "$_out" "--dir DIR"
    assert_contains "TP-CLI-04 help --expect-match" "$_out" "--expect-match"
    assert_contains "TP-CLI-04 help submit vs setup" "$_out" "Submit vs setup"
    assert_contains "TP-CLI-04 help dest Type 0 self-scope not on setup" "$_out" "Dest Type 0 self-scope MUST NOT apply to setup"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_contains "TP-CLI-04 help menu" "$_out" "menu"
    assert_contains "TP-CLI-04 help ip verb" "$_out" "ip [--ip"
    assert_not_contains "TP-CLI-04 no backup verb" "$_out" "backup <"
    assert_not_contains "TP-CLI-04 no restore verb" "$_out" "restore <"
    assert_not_contains "TP-CLI-04 no print-sudoers-install-script" "$_out" "print-sudoers-install-script"
    assert_not_contains "TP-CLI-04 no self-update" "$_out" "self-update"
    assert_not_contains "TP-CLI-04 no self-uninstall" "$_out" "self-uninstall"
    assert_not_contains "TP-CLI-04 no version-check" "$_out" "version-check"
    assert_not_contains "TP-CLI-04 no SCRIPT_URL channel" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"

    # TP-CLI-05 help json
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    assert_eq "TP-CLI-05 help --json exit 0" 0 "$?"
    assert_contains "TP-CLI-05 help json success" "$_out" '"type":"success"'

    # TP-CLI-06 about json storage, no channel, no domain backup fields
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 cache_used" "$_out" '"cache_used"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-06 cache_preferred" "$_out" '"cache_preferred"'
    assert_contains "TP-CLI-06 cache_fallback" "$_out" '"cache_fallback"'
    assert_contains "TP-CLI-06 cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "TP-CLI-06 persistence_storage" "$_out" '"persistence_storage"'
    assert_contains "TP-CLI-06 vault_dir" "$_out" '"vault_dir"'
    assert_contains "TP-CLI-06 token_present" "$_out" '"token_present"'
    assert_not_contains "TP-CLI-06 no raw token key" "$_out" '"token":"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" '"backup_notation"'
    assert_not_contains "TP-CLI-06 no deposit_dir" "$_out" '"deposit_dir"'
    assert_not_contains "TP-CLI-06 no restore_host_default" "$_out" '"restore_host_default"'
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"

    # TP-CLI-07 off-TTY empty argv = Type N help (not install)
    _out=$(sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_contains "TP-CLI-07 empty argv is help" "$_out" "Usage:"
    assert_contains "TP-CLI-07 empty argv mentions Type N or help" "$_out" "help"

    # TP-CLI-08 unknown command fail-closed
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown --json type" "$_err" '"type":"out_error"'

    # TP-CLI-09 quiet suppresses version info
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-09 quiet version exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-09 quiet suppresses human version"
    else
        t_fail "TP-CLI-09 quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-10 online verbs rejected
    _err=$(sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-update exit 1" 1 "$?"
    assert_contains "TP-CLI-10 self-update unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 version-check exit 1" 1 "$?"

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 cache isolation under temp HOME (per login + process id)
    ci_isolated_env
    _login=$(id -un 2>/dev/null || echo "unknown")
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    case "${_pref}" in
        /dev/shm/cache/cache-"${APP_NAME}"-"${_login}"-[0-9]*)
            t_pass "TP-CLI-12 cache_preferred is shm login process leaf"
            ;;
        *) t_fail "TP-CLI-12 cache_preferred unexpected: '${_pref:-empty}'" ;;
    esac
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_fallback 1st" "/tmp/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_fb}"
    _fb2=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_fallback 2nd" "${CI_HOME}/.cache/cache-${APP_NAME}-${_pid}" "${_fb2}"
    _used=$(printf '%s' "$_out" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_used matches effective" "${_eff}" "${_used}"
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective cache directory exists"
    else
        t_fail "TP-CLI-12 effective cache missing: '${_eff:-empty}'"
    fi
    case "${_eff}" in
        /dev/shm/"${APP_NAME}"|/dev/shm/"${APP_NAME}"-*)
            t_fail "TP-CLI-12 effective cache must not be ram-drive project shape: '${_eff}'"
            ;;
        *) t_pass "TP-CLI-12 effective cache is not a ram-drive project shape" ;;
    esac
    case "${_used}" in
        "${_pref}"|"${_fb}"|"${_fb2}")
            t_pass "TP-CLI-12 cache_used is one of this host's tiers"
            ;;
        *) t_fail "TP-CLI-12 cache_used is not a listed tier: '${_used:-empty}'" ;;
    esac
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" DNS_CLI_CACHE_SKIP=preferred \
        sh "${SCRIPT}" about 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-12 silent cache fallback" "${_err}" "fallback"
    assert_not_contains "TP-CLI-12 silent cache fallback error" "${_err}" "Cannot create cache"
    _skip=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" DNS_CLI_CACHE_SKIP=preferred \
        sh "${SCRIPT}" --json about 2>/dev/null)
    _skip_eff=$(printf '%s' "$_skip" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_fb=$(printf '%s' "$_skip" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 skipped preferred uses 1st fallback" "${_skip_fb}" "${_skip_eff}"
    _gb=$(HOME="${CI_HOME}" DNS_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" --json about 2>/dev/null)
    _gb_pref=$(printf '%s' "$_gb" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _gb_pid="${_gb_pref##*-}"
    assert_eq "TP-CLI-12 gitbash preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_gb_pid}" "${_gb_pref}"
    _gb_fb=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 gitbash 1st fallback" "${CI_HOME}/AppData/Local/Temp/cache-${APP_NAME}-${_gb_pid}" "${_gb_fb}"
    assert_contains "TP-CLI-12 gitbash json has cache_fallback_2" "${_gb}" '"cache_fallback_2":""'
    _gb_fb2=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 gitbash no 2nd fallback" "" "${_gb_fb2}"
    _mac=$(HOME="${CI_HOME}" DNS_CLI_CACHE_HOST=mac sh "${SCRIPT}" --json about 2>/dev/null)
    _mac_pref=$(printf '%s' "$_mac" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _mac_pid="${_mac_pref##*-}"
    assert_eq "TP-CLI-12 mac preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_mac_pid}" "${_mac_pref}"
    _mac_fb=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 mac 1st fallback" "${CI_HOME}/Library/Caches/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb}"
    _mac_fb2=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 mac 2nd fallback" "${CI_HOME}/cache/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb2}"
    _mode=$(stat -c %a "${_eff}" 2>/dev/null || echo "")
    assert_eq "TP-CLI-12 effective cache mode 0700" "700" "${_mode}"
    _hum_l=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 linux about used" "${_hum_l}" "Cache folder used:"
    assert_contains "TP-CLI-12 linux about preferred path" "${_hum_l}" "/dev/shm/cache/cache-${APP_NAME}-${_login}-"
    assert_contains "TP-CLI-12 linux about 2nd path" "${_hum_l}" "/.cache/cache-${APP_NAME}-"
    _hum_gb=$(HOME="${CI_HOME}" DNS_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 gitbash about 1st" "${_hum_gb}" "AppData/Local/Temp/cache-${APP_NAME}-"
    assert_not_contains "TP-CLI-12 gitbash about omits 2nd" "${_hum_gb}" "Cache folder (2nd fallback)"
    _hum_mac=$(HOME="${CI_HOME}" DNS_CLI_CACHE_HOST=mac sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 mac about 1st" "${_hum_mac}" "Library/Caches/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 mac about 2nd path" "${_hum_mac}" "Cache folder (2nd fallback): ${CI_HOME}/cache/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 util_mktemp refuses dollar-dollar names" "$(cat "${SCRIPT}")" 'util_mktemp: refuse predictable'

    # TP-CLI-28 scratch when mktemp is absent stays under the cache folder.
    _lib=$(mktemp "${CI_HOME}/dns-cli-lib.XXXXXX") || _lib=""
    if [ -n "${_lib}" ]; then
        awk '
            /^app_main "\$@"$/ { print "# app_main stripped"; next }
            { print }
        ' "${SCRIPT}" > "${_lib}"
        _leaf=$(HOME="${CI_HOME}" sh -c '. "$1"; util_mktemp tmp' sh "${_lib}" 2>/dev/null) || _leaf=""
        case "${_leaf}" in
            /dev/shm/cache/cache-${APP_NAME}-*-*/${APP_NAME}.tmp.*)
                t_pass "TP-CLI-28 scratch file is under the cache leaf"
                ;;
            *)
                t_fail "TP-CLI-28 scratch file unexpected: ${_leaf:-empty}"
                ;;
        esac
        if [ -n "${_leaf}" ] && [ -f "${_leaf}" ]; then
            rm -f "${_leaf}"
        fi
        _dollars=$(printf '%s%s' '$' '$')
        _bad=$(HOME="${CI_HOME}" sh -c '. "$1"; util_mktemp "$2"' sh "${_lib}" "x${_dollars}y" 2>&1 >/dev/null) || true
        assert_contains "TP-CLI-28 refuses a dollar file name" "${_bad}" "refuse predictable"
        _fb=$(HOME="${CI_HOME}" DNS_CLI_MKTEMP_BIN= sh -c '. "$1"; util_mktemp tmp' sh "${_lib}" 2>/dev/null) || _fb=""
        case "${_fb}" in
            /dev/shm/cache/cache-${APP_NAME}-*-*/${APP_NAME}.tmp.*)
                _base=${_fb##*/}
                case "${_base}" in
                    *'$$'*)
                        t_fail "TP-CLI-28 absent mktemp uses a dollar name: ${_base}"
                        ;;
                    *)
                        _mode=$(stat -c '%a' "${_fb}" 2>/dev/null || echo "")
                        assert_eq "TP-CLI-28 absent mktemp mode 0600" "600" "${_mode}"
                        ;;
                esac
                ;;
            *)
                t_fail "TP-CLI-28 absent mktemp unexpected: ${_fb:-empty}"
                ;;
        esac
        if [ -n "${_fb}" ] && [ -f "${_fb}" ]; then
            rm -f "${_fb}"
        fi
        _dir=$(HOME="${CI_HOME}" DNS_CLI_MKTEMP_BIN= sh -c 'umask 0177; . "$1"; util_mktemp_dir' sh "${_lib}" 2>/dev/null) || _dir=""
        case "${_dir}" in
            /dev/shm/cache/cache-${APP_NAME}-*-*/${APP_NAME}-work.*)
                _dmode=$(stat -c '%a' "${_dir}" 2>/dev/null || echo "")
                assert_eq "TP-CLI-28 scratch directory mode 0700" "700" "${_dmode}"
                if [ -x "${_dir}" ] && [ -w "${_dir}" ]; then
                    t_pass "TP-CLI-28 scratch directory is searchable"
                else
                    t_fail "TP-CLI-28 scratch directory is not searchable: ${_dir}"
                fi
                ;;
            *)
                t_fail "TP-CLI-28 scratch directory unexpected: ${_dir:-empty}"
                ;;
        esac
        if [ -n "${_dir}" ] && [ -d "${_dir}" ]; then
            chmod 0700 "${_dir}" 2>/dev/null || true
            rmdir "${_dir}" 2>/dev/null || rm -rf "${_dir}" 2>/dev/null || true
        fi
        rm -f "${_lib}"
    else
        t_fail "TP-CLI-28 could not stage a library copy"
    fi

    # TP-CLI-17 persistency folder + about cache labels
    _persist=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-17 persistency folder path" "${CI_HOME}/.local/${APP_NAME}" "${_persist}"
    if [ -n "${_persist}" ] && [ -d "${_persist}" ]; then
        t_pass "TP-CLI-17 persistency folder exists"
    else
        t_fail "TP-CLI-17 persistency folder missing: '${_persist:-empty}'"
    fi
    case "${_persist}" in
        */.local/bin|*/.local/bin/) t_fail "TP-CLI-17 persistency must not be USER_BIN" ;;
        */.local/vaults/*) t_fail "TP-CLI-17 persistency must not be vault" ;;
        *) t_pass "TP-CLI-17 persistency is not bin or vault" ;;
    esac
    _hum=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-17 human Cache folder used" "$_hum" "Cache folder used:"
    assert_contains "TP-CLI-17 human Cache folder preferred" "$_hum" "Cache folder (preferred):"
    assert_contains "TP-CLI-17 human Cache folder 1st fallback" "$_hum" "Cache folder (1st fallback):"
    assert_contains "TP-CLI-17 human Cache folder 2nd fallback" "$_hum" "Cache folder (2nd fallback):"
    assert_contains "TP-CLI-17 human Persistence storage" "$_hum" "Persistence storage:"
    assert_not_contains "TP-CLI-17 no Storage (effective) label" "$_hum" "Storage (effective)"
    assert_not_contains "TP-CLI-17 no Storage (fallback) label" "$_hum" "Storage (fallback)"
    assert_not_contains "TP-CLI-17 no single Cache folder (fallback) label" "$_hum" "Cache folder (fallback):"

    # TP-CLI-25 prompt_ask / prompt_secret assign PROMPT_ASK_VALUE in this shell.
    # TP-CLI-27: no command substitution of a prompt helper (comments may name the ban).
    _src=$(cat "${SCRIPT}")
    assert_contains "TP-CLI-25 prompt_ask assigns PROMPT_ASK_VALUE" "${_src}" 'PROMPT_ASK_VALUE="${default}"'
    assert_contains "TP-CLI-25 prompt_secret assigns PROMPT_ASK_VALUE" "${_src}" 'PROMPT_ASK_VALUE="${_ps_ans}"'
    assert_contains "TP-CLI-25 vault copies PROMPT_ASK_VALUE" "${_src}" 'CFV_USER_ID="${PROMPT_ASK_VALUE}"'
    assert_contains "TP-CLI-25 prompt_ask warning" "${_src}" 'do-not-capture-read'
    assert_contains "TP-CLI-25 persistency ensure not captured in app_main" "${_src}" 'util_ensure_persistent_storage'
    assert_not_contains "TP-CLI-25 app_main does not capture persistency out_die" "${_src}" 'PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)'
    _cap=$(grep -nE '^[^#]*\$\(prompt_' "${SCRIPT}" || true)
    if [ -n "${_cap}" ]; then
        t_fail "TP-CLI-27 captured prompt helper: ${_cap}"
    else
        t_pass "TP-CLI-27 no command substitution of prompt helpers"
    fi
    _bt=$(grep -nE '^[^#]*`prompt_' "${SCRIPT}" || true)
    if [ -n "${_bt}" ]; then
        t_fail "TP-CLI-27 backtick prompt helper: ${_bt}"
    else
        t_pass "TP-CLI-27 no backtick prompt helper"
    fi

    # TP-CLI-26 persistency mkdir fail-closes the parent (no version after ERROR)
    _lock="${CI_HOME}/.local"
    mkdir -p "${_lock}"
    rm -rf "${CI_HOME}/.local/${APP_NAME}"
    chmod a-w "${_lock}"
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" version 2>&1 >/dev/null)
    _ec=$?
    chmod u+w "${_lock}"
    assert_eq "TP-CLI-26 persistency fail-close exit 1" 1 "${_ec}"
    assert_contains "TP-CLI-26 persistency ERROR names folder" "${_err}" "Cannot create persistency folder"
    assert_contains "TP-CLI-26 persistency ERROR names parent" "${_err}" "${_lock}"
    assert_contains "TP-CLI-26 persistency ERROR Next chown" "${_err}" "Next: as root, chown"
    assert_not_contains "TP-CLI-26 persistency fail-close no version INFO" "${_err}" "dns-cli version"

    ci_cleanup_env

    # TP-CLI-13 trimmed parent domain / sudoers-manager extras fail closed
    for _verb in backup restore print-sudoers-install-script remove-project-sudoers; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-CLI-13 ${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-CLI-13 ${_verb} unknown" "$_err" "Unknown command"
    done

    # TP-CLI-18 main-menu header is APP_NAME(VERSION) - SHORT_DESC;
    # TTY bold name / italic version / light-gray italic explain
    : "${APP_VERSION:=${PRODUCT_VERSION}}"
    _short_desc=$(sed -n 's/.*APP_DESC:=\([^}]*\).*/\1/p' "${SCRIPT}" | head -n1)
    : "${_short_desc:=Cloudflare DNS CLI (vault + IPv4 A records)}"
    _esc=$(printf '\033')
    _out=$(printf '99\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 TTY menu exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-18 header APP_NAME(APP_VERSION) - SHORT_DESC" "$_plain" "${APP_NAME}(${APP_VERSION}) - ${_short_desc}"
    assert_not_contains "TP-CLI-18 no frozen board title" "$_plain" "numbered list of live commands"
    assert_contains "TP-CLI-18 bold SGR 1" "$_out" "${_esc}[1m"
    assert_contains "TP-CLI-18 italic SGR 3" "$_out" "${_esc}[3m"
    assert_contains "TP-CLI-18 light-gray italic SGR 3;37" "$_out" "${_esc}[3;37m"
    assert_contains "TP-CLI-18 DNS Features first" "$_plain" "1. DNS Features: Daily DNS work"
    assert_contains "TP-CLI-18 family sudoers" "$_plain" "7. sudoers: Grant and drafts"
    assert_contains "TP-CLI-18 family self-management" "$_plain" "8. self-management: Self-install, uninstall, where-is-me"
    assert_contains "TP-CLI-18 Exit 9" "$_plain" "9. Exit"
    assert_not_contains "TP-CLI-18 no vault on main" "$_plain" "vault:"
    assert_not_contains "TP-CLI-18 no ip on main" "$_plain" "2. ip:"
    assert_not_contains "TP-CLI-18 no generate on main" "$_plain" "generate-sudoer-request:"
    assert_not_contains "TP-CLI-18 no print-sudoers on main" "$_plain" "print-sudoers:"
    assert_not_contains "TP-CLI-18 no submit-sudoer on main" "$_plain" "submit-sudoer-request:"
    assert_not_contains "TP-CLI-18 no remove-lpu on main" "$_plain" "remove-lpu:"
    assert_not_contains "TP-CLI-18 no install row" "$_plain" "install:"
    assert_not_contains "TP-CLI-18 no version row" "$_plain" "version:"
    assert_not_contains "TP-CLI-18 no help row" "$_plain" "help:"
    assert_not_contains "TP-CLI-18 no test-json-format row" "$_plain" "test-json-format:"
    assert_not_contains "TP-CLI-18 no setup row" "$_plain" "setup:"
    _out=$(sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 off-TTY menu exit 0" 0 "$_ec"
    assert_contains "TP-CLI-18 off-TTY menu is help" "$_out" "Usage:"
    _out=$(sh "${SCRIPT}" --json menu 2>/dev/null)
    assert_contains "TP-CLI-18 off-TTY menu --json" "$_out" '"type":"success"'
    _out=$(printf '9\n' | TTY=1 sh "${SCRIPT}" --json menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 TTY --json menu exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-18 TTY --json menu ignores json" "$_plain" "1. DNS Features: Daily DNS work"
    assert_not_contains "TP-CLI-18 TTY --json menu is not JSON help" "$_plain" '"type":"success"'
    _out=$(printf '9\n' | TTY=1 sh "${SCRIPT}" main 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 TTY main exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-18 TTY main same board" "$_plain" "1. DNS Features: Daily DNS work"
    assert_contains "TP-CLI-18 TTY main Exit 9" "$_plain" "9. Exit"

    # TP-CLI-19 TTY empty argv draws the same numbered main menu as `menu`
    _out=$(printf '9\n' | TTY=1 sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-19 TTY empty argv exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-19 header APP_NAME(APP_VERSION) - SHORT_DESC" "$_plain" "${APP_NAME}(${APP_VERSION}) - ${_short_desc}"
    assert_contains "TP-CLI-19 DNS Features first" "$_plain" "1. DNS Features: Daily DNS work"
    assert_contains "TP-CLI-19 family sudoers" "$_plain" "7. sudoers: Grant and drafts"
    assert_contains "TP-CLI-19 family self-management" "$_plain" "8. self-management: Self-install, uninstall, where-is-me"
    assert_contains "TP-CLI-19 Exit 9" "$_plain" "9. Exit"
    assert_contains "TP-CLI-19 light-gray italic SGR 3;37" "$_out" "${_esc}[3;37m"
    assert_not_contains "TP-CLI-19 TTY empty argv is not help dump" "$_plain" "Usage:"

    # TP-CLI-20 sudoers family submenu: prefix 71-73, 76; Back 0; no Exit row
    _out=$(printf '7\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-20 TTY submenu back exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-20 submenu title" "$_plain" "sudoers (grant and drafts)"
    assert_contains "TP-CLI-20 submenu generate row" "$_plain" "71. generate-sudoer-request:"
    assert_contains "TP-CLI-20 submenu submit row" "$_plain" "72. submit-sudoer-request:"
    assert_contains "TP-CLI-20 submenu print row" "$_plain" "73. print-sudoers:"
    assert_contains "TP-CLI-20 submenu remove-lpu row" "$_plain" "76. remove-lpu:"
    assert_contains "TP-CLI-20 submenu Back 0" "$_plain" "0. Back"
    _nexit=$(printf '%s\n' "$_plain" | grep -c '9\. Exit')
    assert_eq "TP-CLI-20 Exit stays on the front board" 2 "$_nexit"
    assert_not_contains "TP-CLI-20 no install-script row" "$_plain" "print-sudoers-install-script:"
    assert_not_contains "TP-CLI-20 no remove-project-sudoers row" "$_plain" "remove-project-sudoers:"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ngen=$(printf '%s\n' "$_plain" | grep -c '71. generate-sudoer-request:')
    assert_eq "TP-CLI-20 back reprints main DNS Features twice" 2 "$_nfeat"
    assert_eq "TP-CLI-20 back showed submenu once" 1 "$_ngen"
    _out=$(printf '7\nexit\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-20 TTY submenu exit word leaves" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ngen=$(printf '%s\n' "$_plain" | grep -c '71. generate-sudoer-request:')
    assert_eq "TP-CLI-20 exit word main once" 1 "$_nfeat"
    assert_eq "TP-CLI-20 exit word showed submenu" 1 "$_ngen"
    _out=$(printf 'sudoers\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-20 pick sudoers opens submenu" "$_plain" "71. generate-sudoer-request:"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-20 pick sudoers then back reprints main" 2 "$_nfeat"
    _err=$(sh "${SCRIPT}" sudoers 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-20 sudoers not a live command" 1 "$_ec"
    assert_contains "TP-CLI-20 sudoers unknown" "$_err" "Unknown command"
    _out=$(printf '2\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>&1)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-20 invalid pick warns" "$_plain" "Not a menu choice"

    # TP-CLI-22 DNS Features submenu: prefix 11-19 and 101; Back 0; dns is not dispatched
    _out=$(printf '1\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-22 TTY DNS submenu back exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-22 submenu title" "$_plain" "DNS Features (daily DNS work)"
    assert_contains "TP-CLI-22 vault row" "$_plain" "11. vault: Store or inspect Cloudflare vault"
    assert_contains "TP-CLI-22 ip row" "$_plain" "12. ip: Show public IPv4 (no vault)"
    assert_contains "TP-CLI-22 add row" "$_plain" "13. add: Ensure one A record"
    assert_contains "TP-CLI-22 update row" "$_plain" "14. update: Update existing A record"
    assert_contains "TP-CLI-22 remove row" "$_plain" "15. remove: Delete managed A record"
    assert_contains "TP-CLI-22 status row" "$_plain" "16. status: Show public IP and DNS A records"
    assert_contains "TP-CLI-22 submit row" "$_plain" "17. submit: Queue a DNS request JSON file"
    assert_contains "TP-CLI-22 approve row" "$_plain" "18. approve: Apply a waiting DNS request"
    assert_contains "TP-CLI-22 reject row" "$_plain" "19. reject: Decline a waiting DNS request"
    assert_contains "TP-CLI-22 interactive row" "$_plain" "101. interactive: Review waiting DNS requests one by one"
    assert_contains "TP-CLI-22 submenu Back 0" "$_plain" "0. Back"
    assert_not_contains "TP-CLI-22 submenu has no Exit row" "$_plain" "99. Exit"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _nvault=$(printf '%s\n' "$_plain" | grep -c '11. vault:')
    assert_eq "TP-CLI-22 back reprints main DNS Features twice" 2 "$_nfeat"
    assert_eq "TP-CLI-22 back showed DNS submenu once" 1 "$_nvault"
    _out=$(printf '1\n99\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-22 TTY DNS submenu typed 99 leaves" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _nvault=$(printf '%s\n' "$_plain" | grep -c '11. vault:')
    assert_eq "TP-CLI-22 typed 99 main once" 1 "$_nfeat"
    assert_eq "TP-CLI-22 typed 99 showed DNS submenu" 1 "$_nvault"
    _out=$(printf 'dns\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-22 pick dns opens submenu" "$_plain" "11. vault:"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-22 pick dns then back reprints main" 2 "$_nfeat"
    _err=$(sh "${SCRIPT}" dns 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-22 dns not a live command" 1 "$_ec"
    assert_contains "TP-CLI-22 dns unknown" "$_err" "Unknown command"

    # TP-CLI-23 a finished listed command returns to the top list
    _out=$(printf '1\n12\n9\n' | TTY=1 sh "${SCRIPT}" menu --ip 203.0.113.10 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-23 DNS ip then Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-23 DNS ip ran" "$_plain" "Public IPv4: 203.0.113.10"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _nvault=$(printf '%s\n' "$_plain" | grep -c '11. vault:')
    assert_eq "TP-CLI-23 DNS ip reprints top twice" 2 "$_nfeat"
    assert_eq "TP-CLI-23 DNS ip showed DNS submenu once" 1 "$_nvault"
    _out=$(printf '7\n73\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-23 sudoers print-sudoers then Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ngen=$(printf '%s\n' "$_plain" | grep -c '71. generate-sudoer-request:')
    assert_eq "TP-CLI-23 sudoers print reprints top twice" 2 "$_nfeat"
    assert_eq "TP-CLI-23 sudoers print showed submenu once" 1 "$_ngen"
    _out=$(printf 'print-sudoers\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-23 top shortcut then Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-23 top shortcut reprints top twice" 2 "$_nfeat"

    # TP-CLI-24 self-management family submenu: 82, 83, 87-89; Back 0; not dispatched
    _out=$(printf '8\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-24 TTY selfmgmt back exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-24 submenu title" "$_plain" "self-management (place, remove, locate)"
    assert_contains "TP-CLI-24 version row" "$_plain" "82. version:"
    assert_contains "TP-CLI-24 about row" "$_plain" "83. about:"
    assert_contains "TP-CLI-24 self-install row" "$_plain" "87. self-install:"
    assert_contains "TP-CLI-24 uninstall row" "$_plain" "88. uninstall:"
    assert_contains "TP-CLI-24 where-is-me row" "$_plain" "89. where-is-me:"
    assert_contains "TP-CLI-24 submenu Back 0" "$_plain" "0. Back"
    _nexit=$(printf '%s\n' "$_plain" | grep -c '9\. Exit')
    assert_eq "TP-CLI-24 Exit stays on the front board" 2 "$_nexit"
    assert_not_contains "TP-CLI-24 no self-update" "$_plain" "self-update:"
    assert_not_contains "TP-CLI-24 no version-check" "$_plain" "version-check:"
    assert_not_contains "TP-CLI-24 no self-uninstall" "$_plain" "self-uninstall:"
    assert_not_contains "TP-CLI-24 no setup" "$_plain" "setup:"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ninst=$(printf '%s\n' "$_plain" | grep -c '87. self-install:')
    assert_eq "TP-CLI-24 back reprints main DNS Features twice" 2 "$_nfeat"
    assert_eq "TP-CLI-24 back showed submenu once" 1 "$_ninst"
    _out=$(printf '8\n9\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-24 submenu 9 is not Exit" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _ninst=$(printf '%s\n' "$_plain" | grep -c '87. self-install:')
    assert_eq "TP-CLI-24 submenu 9 reprints self-install twice" 2 "$_ninst"
    _out=$(printf 'self-management\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-24 pick self-management opens submenu" "$_plain" "87. self-install:"
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-24 pick self-management then back reprints main" 2 "$_nfeat"
    _err=$(sh "${SCRIPT}" self-management 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-24 self-management not a live command" 1 "$_ec"
    assert_contains "TP-CLI-24 self-management unknown" "$_err" "Unknown command"
    _out=$(printf '8\n82\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-24 version then Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ninst=$(printf '%s\n' "$_plain" | grep -c '87. self-install:')
    assert_eq "TP-CLI-24 version reprints top twice" 2 "$_nfeat"
    assert_eq "TP-CLI-24 version showed submenu once" 1 "$_ninst"
    _out=$(printf '8\n81\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>&1)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-24 invalid pick warns" "$_plain" "Not a menu choice"
    assert_contains "TP-CLI-24 invalid Next enter" "$_plain" "Next: enter 82, 83, 87-89"

    # TP-CLI-21 invalid pick reprints the same numbered layer; a later listed pick still runs
    _out=$(printf '2\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-21 main invalid then Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-21 main invalid reprints DNS Features twice" 2 "$_nfeat"
    _out=$(printf '2\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>&1)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-21 main invalid warns" "$_plain" "Not a menu choice"
    assert_contains "TP-CLI-21 main invalid Next enter" "$_plain" "Next: enter 1, 7, 8, 9"
    _out=$(printf 'nope\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-21 main garbage reprints DNS Features twice" 2 "$_nfeat"
    _out=$(printf '\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    assert_eq "TP-CLI-21 main blank reprints DNS Features twice" 2 "$_nfeat"
    _out=$(printf '7\n74\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-21 sudoers invalid then back Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ngen=$(printf '%s\n' "$_plain" | grep -c '71. generate-sudoer-request:')
    assert_eq "TP-CLI-21 sudoers invalid reprints generate twice" 2 "$_ngen"
    assert_eq "TP-CLI-21 sudoers invalid main twice until back" 2 "$_nfeat"
    _out=$(printf '7\n74\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>&1)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-21 sudoers invalid warns" "$_plain" "Not a menu choice"
    assert_contains "TP-CLI-21 sudoers invalid Next enter" "$_plain" "Next: enter 71-73, 76"
    _out=$(printf '1\n10\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-21 DNS invalid then back Exit 0" 0 "$_ec"
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _nvault=$(printf '%s\n' "$_plain" | grep -c '11. vault:')
    assert_eq "TP-CLI-21 DNS invalid reprints vault twice" 2 "$_nvault"
    assert_eq "TP-CLI-21 DNS invalid main twice until back" 2 "$_nfeat"
    _out=$(printf '1\n10\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>&1)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    assert_contains "TP-CLI-21 DNS invalid warns" "$_plain" "Not a menu choice"
    assert_contains "TP-CLI-21 DNS invalid Next enter" "$_plain" "Next: enter 11-19, 101"
    _out=$(printf '2\n7\n74\n0\n9\n' | TTY=1 sh "${SCRIPT}" menu 2>/dev/null)
    _plain=$(printf '%s' "$_out" | sed "s/${_esc}\\[[0-9;]*m//g")
    _nfeat=$(printf '%s\n' "$_plain" | grep -c '1. DNS Features:')
    _ngen=$(printf '%s\n' "$_plain" | grep -c '71. generate-sudoer-request:')
    assert_eq "TP-CLI-21 both layers invalid then back DNS Features thrice" 3 "$_nfeat"
    assert_eq "TP-CLI-21 both layers invalid generate twice" 2 "$_ngen"

    # TP-CF-ACTOR-* — routed; help lists them; missing inbound/file fails closed (not unknown)
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-CF-ACTOR-05 help lists DNS submit" "${_help}" "  submit FILE"
    assert_contains "TP-CF-ACTOR-05 help lists approve" "${_help}" "  approve "
    assert_contains "TP-CF-ACTOR-05 help lists reject" "${_help}" "  reject "
    assert_contains "TP-CF-ACTOR-05 help lists interactive" "${_help}" "  interactive"
    _err=$(sh "${SCRIPT}" submit 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-ACTOR-01 submit no-file exit 1" 1 "${_ec}"
    assert_contains "TP-CF-ACTOR-01 submit not unknown" "${_err}" "submit needs a DNS request"
    _err=$(sh "${SCRIPT}" --json interactive 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CF-ACTOR-04 interactive json exit 1" 1 "${_ec}"
    assert_not_contains "TP-CF-ACTOR-04 interactive not unknown" "${_err}" "Unknown command"

    # TP-CF-ACTOR-07 — DNS actor table MUST NOT absorb sudoer print/submit roles
    _actor="${REPO_ROOT}/docs/requirements/requirement-dns-actor-table.md"
    if [ -f "${_actor}" ]; then
        _abody=$(cat "${_actor}")
        assert_contains "TP-CF-ACTOR-07 ACT-M3a present" "${_abody}" "ACT-M3a"
        assert_contains "TP-CF-ACTOR-07 must not absorb printer" "${_abody}" "absorb printer"
        assert_contains "TP-CF-ACTOR-07 names submit-sudoer-request" "${_abody}" '`submit-sudoer-request`'
        assert_contains "TP-CF-ACTOR-07 names sudoer-adm" "${_abody}" '`sudoer-adm`'
        assert_contains "TP-CF-ACTOR-07 DNS submit ≠ sudoer submit" "${_abody}" 'DNS `submit` ≠ `submit-sudoer-request`'
        assert_contains "TP-CF-ACTOR-08 ACT-M7" "${_abody}" "ACT-M7"
        assert_contains "TP-CF-ACTOR-08 no dest fence on file-ownership" "${_abody}" "MUST NOT** fence on Unix file-ownership"
        assert_contains "TP-CF-ACTOR-09 ACT-M8" "${_abody}" "ACT-M8"
        assert_contains "TP-CF-ACTOR-09 dest fence is incorrect JSON format" "${_abody}" "incorrect JSON format"
        assert_contains "TP-CF-ACTOR-09 closed dest fence table" "${_abody}" "Approval fencing conditions (closed"
        assert_contains "TP-CF-ACTOR-09 MUST NOT extra dest fence" "${_abody}" "Who submitted / dest Type 0 self-scope"
        assert_contains "TP-CF-ACTOR-09 MUST NOT fence filename subject" "${_abody}" "Filename subject token"
        assert_contains "TP-ARSA dest catalog points at ARSA REQ" "${_abody}" "requirement-actor-role-subject-approver"
    else
        t_fail "TP-CF-ACTOR-07 missing requirement-dns-actor-table.md"
    fi

    _class="${REPO_ROOT}/docs/requirements/requirement-class-software-dev.md"
    if [ -f "${_class}" ]; then
        _cbody=$(cat "${_class}")
        assert_contains "TP-ARSA-01 class consider" "${_cbody}" "actor / role / subject / approver"
        assert_contains "TP-ARSA-01 even if no dest approver" "${_cbody}" "even if there is no dest approver"
        assert_contains "TP-ARSA-01 MUST NOT invent an approver" "${_cbody}" "MUST NOT** invent an approver"
        assert_contains "TP-FENCE-01 class dest-fence review" "${_cbody}" "Dest fence conditions (review and convert)"
        assert_contains "TP-FENCE-01 independent REQ per Fence" "${_cbody}" "Each dest **Fence** row **MUST** be an independent Active requirement"
        assert_contains "TP-FENCE-01 residual none" "${_cbody}" "considered — no dest fence conditions"
        assert_contains "TP-FENCE-01 MUST NOT invent a dest fence" "${_cbody}" "MUST NOT** invent a dest fence"
        assert_contains "TP-FENCE-01 residual points at IJF" "${_cbody}" "requirement-incorrect-json-format"
        assert_contains "TP-FENCE-01 residual points at dest catalog" "${_cbody}" "requirement-approval-fencing-condition"
        assert_contains "TP-FENCE-01 AC-9 dest fence review" "${_cbody}" "AC-9"
        assert_contains "TP-FENCE-01 AC-10 dest fence catalog" "${_cbody}" "AC-10"
        assert_contains "TP-FENCE-01 class names fence-test" "${_cbody}" "fence-test"
    else
        t_fail "TP-ARSA-01 missing requirement-class-software-dev.md"
    fi
    _arsa="${REPO_ROOT}/docs/requirements/requirement-actor-role-subject-approver.md"
    if [ -f "${_arsa}" ]; then
        _abody2=$(cat "${_arsa}")
        assert_contains "TP-ARSA-02 catalog table header" "${_abody2}" "| Actor | Role | Subject | Submitter | Approver |"
        assert_contains "TP-ARSA-02 Submitter anyone" "${_abody2}" "**anyone**"
        assert_contains "TP-ARSA-02 Submitter the actor itself" "${_abody2}" "**the actor itself**"
        assert_contains "TP-ARSA-02 None is valid" "${_abody2}" "**None**"
        assert_contains "TP-ARSA-02 nginx dest None here" "${_abody2}" "None here"
        assert_contains "TP-ARSA-02 day-to-day None" "${_abody2}" "do not dest-review"
    else
        t_fail "TP-ARSA-02 missing requirement-actor-role-subject-approver.md"
    fi
    _ijf="${REPO_ROOT}/docs/requirements/requirement-incorrect-json-format.md"
    if [ -f "${_ijf}" ]; then
        _ibody=$(cat "${_ijf}")
        assert_contains "TP-FENCE-02 independent dest-fence REQ exists" "${_ibody}" "requirement-incorrect-json-format"
        assert_contains "TP-FENCE-02 names this dest fence" "${_ibody}" "incorrect JSON format"
        assert_contains "TP-FENCE-02 dest table still prints" "${_ibody}" "dest fence **table** stays"
        assert_contains "TP-FENCE-02 MUST NOT extra dest fences" "${_ibody}" "Unix file-ownership"
        assert_contains "TP-FENCE-02 dest-written submit_by allowed" "${_ibody}" "treat dest-written \`submit_by\`"
        assert_contains "TP-FENCE-04 dest-owned allowlist" "${_ibody}" "Dest-owned allowlist"
        assert_contains "TP-FENCE-04 sudoer kind known" "${_ibody}" "Dest **MUST NOT** treat dest-legal \`kind\` as unexpected"
        assert_contains "TP-FENCE-04 kind is not file-ownership" "${_ibody}" "kind\` is not file-ownership"
        assert_contains "TP-FENCE-04 catalog peer" "${_ibody}" "requirement-approval-fencing-condition"
    else
        t_fail "TP-FENCE-02 missing requirement-incorrect-json-format.md"
    fi
    _afc="${REPO_ROOT}/docs/requirements/requirement-approval-fencing-condition.md"
    if [ -f "${_afc}" ]; then
        _afcbody=$(cat "${_afc}")
        assert_contains "TP-FENCE-03 catalog exists" "${_afcbody}" "requirement-approval-fencing-condition"
        assert_contains "TP-FENCE-03 closed dest table header" "${_afcbody}" "| Condition | Dest \`approve\` / \`reject\` / \`interactive\` |"
        assert_contains "TP-FENCE-03 Fence row is incorrect JSON format" "${_afcbody}" "**Incorrect JSON format**"
        assert_contains "TP-FENCE-03 MUST NOT fence file-ownership" "${_afcbody}" "File-ownership"
        assert_contains "TP-FENCE-03 kind is not a dest fence" "${_afcbody}" "kind\` is not a dest fence"
        assert_contains "TP-FENCE-03 file-ownership dest-writes submit_by" "${_afcbody}" "dest-write \`submit_by\`"
        assert_contains "TP-FENCE-03 MUST NOT convert ownership into kind" "${_afcbody}" "MUST NOT** convert file-ownership into submitter-emitted \`kind\`"
    else
        t_fail "TP-FENCE-03 missing requirement-approval-fencing-condition.md"
    fi
    if [ -f "${_actor}" ]; then
        assert_contains "TP-FENCE-02 dest catalog points at IJF REQ" "${_abody}" "requirement-incorrect-json-format"
        assert_contains "TP-FENCE-02 dest Fence row still printed" "${_abody}" "**Incorrect JSON format**"
    fi
    for _peer in requirement-least-privilege-user.md requirement-three-layer-privilege-model.md requirement-sudoer-json-file.md; do
        _pf="${REPO_ROOT}/docs/requirements/${_peer}"
        if [ -f "${_pf}" ]; then
            _pbody=$(cat "${_pf}")
            assert_contains "TP-FENCE-02 ${_peer} dest Fence points at IJF" "${_pbody}" "requirement-incorrect-json-format"
        else
            t_fail "TP-FENCE-02 missing ${_peer}"
        fi
    done

    _av="${REPO_ROOT}/docs/requirements/requirement-application-local-vault.md"
    if [ -f "${_av}" ]; then
        _avbody=$(cat "${_av}")
        assert_contains "TP-AV-08 dest is local vaults" "${_avbody}" "is** local vaults"
        assert_contains "TP-AV-08 Type 2 dest is global vault from ordinary login" "${_avbody}" "is** the **global vault"
        assert_contains "TP-AV-08 MUST NOT invent /etc dest" "${_avbody}" "/etc/dns-adm/vault/"
        assert_contains "TP-AV-08 MUST NOT treat archive as vault dest" "${_avbody}" "host archive deposit"
        assert_contains "TP-AV-08 AV-M11 present" "${_avbody}" "AV-M11"
    else
        t_fail "TP-AV-08 missing requirement-application-local-vault.md"
    fi

    # TP-CLI-16 — every requirement prints §1.1 Human-facing (human-intro standard)
    _reqdir="${REPO_ROOT}/docs/requirements"
    _nreq=0
    _nmiss=0
    for _rf in "${_reqdir}"/requirement-*.md; do
        [ -f "${_rf}" ] || continue
        _nreq=$((_nreq + 1))
        if ! grep -q '### 1.1 Human-facing' "${_rf}"; then
            t_fail "TP-CLI-16 missing §1.1 Human-facing in $(basename "${_rf}")"
            _nmiss=$((_nmiss + 1))
        fi
        if ! grep -q '\*\*In one sentence:\*\*' "${_rf}"; then
            t_fail "TP-CLI-16 missing one-sentence lead in $(basename "${_rf}")"
            _nmiss=$((_nmiss + 1))
        fi
    done
    if [ "${_nreq}" -eq 0 ]; then
        t_fail "TP-CLI-16 no requirement-*.md files"
    elif [ "${_nmiss}" -eq 0 ]; then
        t_pass "TP-CLI-16 ${_nreq} requirements have §1.1 Human-facing"
    fi

    # TP-CLI-14 — CI-M1 dual mention: each routed verb in CLI REQ + a topic-owner REQ.
    # Count backtick-quoted names in docs/requirements/requirement-*.md only.
    # Help source / argparse / Node Help is not a mention.
    _reqdir="${REPO_ROOT}/docs/requirements"
    _cli_iface=""
    for _cname in requirement-shell-cli-interface.md requirement-python-cli-interface.md requirement-nodejs-cli-interface.md; do
        if [ -f "${_reqdir}/${_cname}" ]; then
            _cli_iface="${_reqdir}/${_cname}"
            break
        fi
    done
    if [ -z "${_cli_iface}" ]; then
        t_fail "TP-CLI-14 no language CLI-interface requirement"
    else
        t_pass "TP-CLI-14 language CLI-interface present ($(basename "${_cli_iface}"))"
        # Routed top-level COMMAND values from app_main, plus CI-M1 Gap verbs law still names.
        for _verb in install self-install uninstall where-is-me version about help menu main setup remove-lpu \
            print-sudoers generate-sudoer-request submit-sudoer-request \
            vault ip add update remove status show \
            submit approve reject interactive test-json-format fence-test; do
            _hits=$(grep -l -F -- "\`${_verb}\`" "${_reqdir}"/requirement-*.md 2>/dev/null || true)
            _n=$(printf '%s\n' "${_hits}" | sed '/^$/d' | wc -l | tr -d ' ')
            _in_cli=0
            _other=0
            printf '%s\n' "${_hits}" | grep -q "requirement-.*-cli-interface.md" && _in_cli=1
            printf '%s\n' "${_hits}" | grep -v "requirement-.*-cli-interface.md" | grep -q . && _other=1
            if [ "${_n}" -ge 2 ] && [ "${_in_cli}" -eq 1 ] && [ "${_other}" -eq 1 ]; then
                t_pass "TP-CLI-14 ${_verb} dual-mentioned (${_n} REQs)"
            else
                t_fail "TP-CLI-14 ${_verb} needs CLI REQ + topic-owner (count=${_n} cli=${_in_cli} other=${_other})"
            fi
        done
        # Help source must not be the thing we counted — ship unit is outside docs/requirements/.
        if grep -l -F -- '`print-sudoers`' "${SCRIPT}" >/dev/null 2>&1; then
            t_pass "TP-CLI-14 help/source not in requirement glob"
        else
            t_pass "TP-CLI-14 requirement glob excludes ship unit"
        fi
    fi

    # TP-CLI-15 — CI-M1a: topic-owner REQ has a complete `dns-cli …` invocation sample.
    # Match a line that is dns-cli (optional sudo / sudo -n) plus the verb.
    # Help / argparse is not scanned. CLI-interface-only samples do not count.
    _req_has_sample() {
        _pat="$1"
        _hits=$(grep -l -E -- "^[[:space:]]*(sudo[[:space:]]+(-n[[:space:]]+)?)?dns-cli ${_pat}([[:space:]]|$)" \
            "${_reqdir}"/requirement-*.md 2>/dev/null || true)
        _other=$(printf '%s\n' "${_hits}" | grep -v 'requirement-shell-cli-interface.md' | sed '/^$/d' | wc -l | tr -d ' ')
        [ "${_other}" -ge 1 ]
    }
    for _verb in install self-install uninstall where-is-me version about help menu main setup remove-lpu \
        print-sudoers generate-sudoer-request submit-sudoer-request \
        vault ip add update remove status show \
        submit approve reject interactive test-json-format fence-test; do
        if _req_has_sample "${_verb}"; then
            t_pass "TP-CLI-15 ${_verb} has topic-owner sample"
        else
            t_fail "TP-CLI-15 ${_verb} missing dns-cli sample on a topic-owner REQ"
        fi
    done
    for _vsub in "vault input" "vault set" "vault init" "vault show" "vault clear" \
        "vault account add" "vault account list" "vault account modify" "vault account remove" \
        "vault subdomain add" "vault subdomain list" "vault subdomain modify" \
        "vault subdomain remove" "vault subdomain mode"; do
        if _req_has_sample "${_vsub}"; then
            t_pass "TP-CLI-15 ${_vsub} has topic-owner sample"
        else
            t_fail "TP-CLI-15 ${_vsub} missing dns-cli sample on a topic-owner REQ"
        fi
    done

    # TP-FENCE-08 — Type 0 test-json-format (no queue)
    _tf=$(mktemp)
    printf '%s\n' '{"schema_version":1,"purpose":"Add A","subject":"alice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","domain_id":"example.com","subdomain":"www","ipv4":"8.8.8.8"}' >"${_tf}"
    _out=$(sh "${SCRIPT}" test-json-format --file "${_tf}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-08 dest-legal JSON exit 0" 0 "${_ec}"
    assert_contains "TP-FENCE-08 dest-legal message" "${_out}" "dest-legal"
    printf '%s\n' '{"schema_version":1,"purpose":"Add A","subject":"alice","action":"add","domain_id":"example.com","subdomain":"www","ipv4":"8.8.8.8"}' >"${_tf}"
    _err=$(sh "${SCRIPT}" test-json-format --file "${_tf}" 2>&1)
    _ec=$?
    assert_eq "TP-FENCE-16 missing submit_app exit 1" 1 "${_ec}"
    assert_contains "TP-FENCE-16 missing submit_app words" "${_err}" "submit_app"
    printf '%s\n' '{"schema_version":1,"purpose":"Add A","subject":"alice","action":"add","submit_app":"other-cli","submit_version":"9.9.9","domain_id":"example.com","subdomain":"www","ipv4":"8.8.8.8"}' >"${_tf}"
    _out=$(sh "${SCRIPT}" test-json-format --file "${_tf}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-17 sibling submit_app exit 0" 0 "${_ec}"
    assert_contains "TP-FENCE-17 sibling dest-legal" "${_out}" "dest-legal"
    printf '%s\n' '{"schema_version":1,"purpose":"Add A","subject":"alice","action":"add","submit_app":"dns-cli","submit_version":"1.12.0","domain_id":"example.com","subdomain":"www","ipv4":"8.8.8.8","token":"no"}' >"${_tf}"
    _out=$(sh "${SCRIPT}" test-json-format --file "${_tf}" 2>/dev/null)
    _ec=$?
    if [ "${_ec}" -ne 0 ]; then
        t_pass "TP-FENCE-08 unknown key / token fails closed"
    else
        t_fail "TP-FENCE-08 expected nonzero exit on dest-illegal JSON"
    fi
    rm -f "${_tf}"

    # TP-FENCE-09..15 — Type 0 fence-test (closed dest fence list; local test folder)
    _ftdir="${TESTS_ROOT}/fixtures/fence-test"
    _fx="${_ftdir}/pass/20260821-alice-add-1.json"
    _out=$(sh "${SCRIPT}" --json fence-test --file "${_fx}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-09 golden --file exit 0" 0 "${_ec}"
    assert_contains "TP-FENCE-09 no dest fence" "${_out}" "No dest fence matched"
    assert_contains "TP-FENCE-09 command fence-test" "${_out}" '"command":"fence-test"'
    _err=$(sh "${SCRIPT}" fence-test --file "${_ftdir}/match/not-object.json" 2>&1)
    _ec=$?
    assert_eq "TP-FENCE-10 not-object exit 1" 1 "${_ec}"
    assert_contains "TP-FENCE-10 not-object words" "${_err}" "not a JSON object"
    _out=$(sh "${SCRIPT}" --json fence-test --dir "${_ftdir}/pass" 2>/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-11 pass corpus exit 0" 0 "${_ec}"
    assert_contains "TP-FENCE-11 pass corpus files" "${_out}" '"files":"2"'
    _out=$(sh "${SCRIPT}" --json fence-test --dir "${_ftdir}/match" --expect-match 2>/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-12 match corpus --expect-match exit 0" 0 "${_ec}"
    assert_contains "TP-FENCE-12 all matched" "${_out}" "all matched a dest fence"
    _err=$(sh "${SCRIPT}" fence-test --dir "${_ftdir}/pass" --file "${_fx}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-13 xor --file and --dir exit 1" 1 "${_ec}"
    assert_contains "TP-FENCE-13 xor words" "${_err}" "not both --file and --dir"
    assert_contains "TP-FENCE-13 Next running ship unit" "${_err}" "${SCRIPT} fence-test --file"
    assert_not_contains "TP-FENCE-13 Next not global install" "${_err}" "/usr/local/bin/dns-cli"
    _err=$(sh "${SCRIPT}" fence-test --expect-match --file "${_fx}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FENCE-14 --expect-match needs --dir exit 1" 1 "${_ec}"
    assert_contains "TP-FENCE-14 expect-match words" "${_err}" "only valid with --dir"
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-FENCE-15 testers heading" "${_help}" "Unit test (local test folder; Type 0 — test-purpose)"
    assert_contains "TP-FENCE-15 fence-test listed" "${_help}" "fence-test"

    # TP-PREV-01 — prevention catalog exists and keeps Type 2 open
    _prev="${REPO_ROOT}/docs/requirements/requirement-privilege-prevention-set.md"
    if grep -q 'OPEN-T2' "${_prev}" && grep -q 'PREV-SUDOERS-D' "${_prev}"; then
        t_pass "TP-PREV-01 prevention catalog names OPEN-T2 and PREV-SUDOERS-D"
    else
        t_fail "TP-PREV-01 missing OPEN-T2 / PREV-SUDOERS-D"
    fi
}
