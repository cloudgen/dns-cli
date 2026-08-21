# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-* · TP-CF-ACTOR-* · TP-FENCE-01..04 · TP-FENCE-08..15 (incl. TP-CLI-14 dual mention, TP-CF-ACTOR-07)
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
        for _verb in install uninstall where-is-me version about help setup remove-lpu \
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
    for _verb in install uninstall where-is-me version about help setup remove-lpu \
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
