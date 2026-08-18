# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-* · TP-CF-ACTOR-* (incl. TP-CLI-14 dual mention, TP-CF-ACTOR-07)
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
    assert_contains "TP-CLI-04 help install does not create dns-adm" "$_out" "does not create Linux user dns-adm"
    assert_contains "TP-CLI-04 help setup" "$_out" "setup"
    assert_contains "TP-CLI-04 help remove-lpu" "$_out" "remove-lpu"
    assert_contains "TP-CLI-04 help print-sudoers" "$_out" "print-sudoers"
    assert_contains "TP-CLI-04 help generate-sudoer-request" "$_out" "generate-sudoer-request"
    assert_contains "TP-CLI-04 help submit-sudoer-request" "$_out" "submit-sudoer-request"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
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
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-06 vault_dir" "$_out" '"vault_dir"'
    assert_contains "TP-CLI-06 token_present" "$_out" '"token_present"'
    assert_not_contains "TP-CLI-06 no raw token key" "$_out" '"token":"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" '"backup_notation"'
    assert_not_contains "TP-CLI-06 no deposit_dir" "$_out" '"deposit_dir"'
    assert_not_contains "TP-CLI-06 no restore_host_default" "$_out" '"restore_host_default"'
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"

    # TP-CLI-07 empty argv = Type N help (not install)
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

    # TP-CLI-12 storage isolation under temp HOME
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective_storage directory exists"
    else
        t_fail "TP-CLI-12 effective_storage missing: '${_eff:-empty}'"
    fi
    ci_cleanup_env

    # TP-CLI-13 trimmed parent domain / sudoers-manager extras fail closed
    for _verb in backup restore print-sudoers-install-script remove-project-sudoers; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-CLI-13 ${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-CLI-13 ${_verb} unknown" "$_err" "Unknown command"
    done

    # TP-CF-ACTOR-* — unrouted approval verbs fail closed (Gap on 1.4.0)
    _help=$(sh "${SCRIPT}" help 2>/dev/null)
    for _verb in submit approve reject interactive; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-CF-ACTOR-${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-CF-ACTOR-${_verb} unknown" "$_err" "Unknown command"
        if [ "${_verb}" = "submit" ]; then
            assert_not_contains "TP-CF-ACTOR-05 help omits DNS submit" "${_help}" "  submit "
        else
            assert_not_contains "TP-CF-ACTOR-05 help omits ${_verb}" "${_help}" "${_verb}"
        fi
    done

    # TP-CF-ACTOR-07 — DNS actor table MUST NOT absorb sudoer print/submit roles
    _actor="${REPO_ROOT}/docs/requirements/requirement-dns-actor-table.md"
    if [ -f "${_actor}" ]; then
        _abody=$(cat "${_actor}")
        assert_contains "TP-CF-ACTOR-07 ACT-M3a present" "${_abody}" "ACT-M3a"
        assert_contains "TP-CF-ACTOR-07 must not absorb printer" "${_abody}" "absorb printer"
        assert_contains "TP-CF-ACTOR-07 names submit-sudoer-request" "${_abody}" '`submit-sudoer-request`'
        assert_contains "TP-CF-ACTOR-07 names sudoer-adm" "${_abody}" '`sudoer-adm`'
        assert_contains "TP-CF-ACTOR-07 DNS submit ≠ sudoer submit" "${_abody}" 'DNS `submit` ≠ `submit-sudoer-request`'
    else
        t_fail "TP-CF-ACTOR-07 missing requirement-dns-actor-table.md"
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
        for _verb in install uninstall where-is-me version about help setup remove-lpu \
            print-sudoers generate-sudoer-request submit-sudoer-request \
            vault ip add update remove status show \
            submit approve reject interactive; do
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
    for _verb in install uninstall where-is-me version about help setup remove-lpu \
        print-sudoers generate-sudoer-request submit-sudoer-request \
        vault ip add update remove status show \
        submit approve reject interactive; do
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
}
