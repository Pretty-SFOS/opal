#!/bin/bash
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-release-module.md
# for documentation.
#
# @@@ FILE VERSION $c__OPAL_RELEASE_MODULE_VERSION__
#
# Changelog:
# * 1.5.0 (2025-08-08):
#   - include added translations in generated changelog when releasing a module
#   - updated docs on how to attribute Opal modules using Opal.About in shipped
#     module info files
#   - fixed minification to work without special treatment for semicolons in JS
#     files; this is only needed in QML files
#   - updated docs on how to write docs
#   - fixed QML import statement in generated docs to now correctly include the
#     version number
#   - fixed warnings when building docs for QML-only modules
#
# * 1.4.2 (2025-07-31):
#   - update generated docs on how to attribute Opal modules using Opal.About
#
# * 1.4.1 (2024-10-30):
#   - show gitk before asking for the new version number when publishing
#
# * 1.4.0 (2024-10-29):
#   - improve QML minification with better logging and support for for-loops
#     and semicolons in sticky comments
#
# * 1.3.1 (2024-10-13):
#   - improve publication wizard flow: reduce unnecessary prompts, help with changelog, etc.
#   - always drop obsolete translations when building release bundles
#
# * 1.3.0 (2024-10-10):
#   - check for git as required dependency
#   - avoid duplicating .tar.gz suffix for custom release bundles
#   - add --publish-wizard option to (semi-)automate publishing releases
#   - improve help text
#
# * 1.2.1 (2024-09-23):
#   - fix shellcheck warnings
#   - fix version number in the script
#
# * 1.2.0 (2024-09-12):
#   - add --docs option to only generate documentation
#   - include module source url in documentation footer
#   - fix rendering documentation for private types
#
# * 1.1.0 (2024-09-07):
#   - add "defaultValue" qdoc macro to document the default value of QML
#     properties in module docs
#   - fix support for multiple attribution lines in generated Attribution files
#
# * 1.0.0 (2024-07-26):
#   - add "briefDescription" metadata field (requires update to module.opal)
#   - the following files are now being generated and can be removed from modules:
#       - doc/module.qdoc
#       - doc/opal-mymodule.qdocconf
#       - doc/opal-qdoc.qdocconf
#   - do not include C++ and translations directories in bundles if they
#     are empty
#
# * 0.8.0 (2024-06-23):
#   - add preliminary support for C++ modules (no changes needed for QML-only modules)
#
# * 0.7.0 (2023-06-29):
#   - remove the setup_translations() function and automatically setup
#     translations if they are missing instead
#   - automatically remove private/ExtraTranslations.qml from the release
#     bundle if it exists
#   - automatically generate an attribution component that can be used
#     by importing "qml/modules/Opal/Attributions"
#

c__OPAL_RELEASE_MODULE_VERSION__="1.5.0"
# c__FOR_RELEASE_LIB__=version must be set in module release scripts

shopt -s extglob

_x="${cTR_DIR:="translations"}"
_x="${cDOC_DIR:="doc"}"
_x="${cBUILD_DIR:="build"}"
_x="${cBUILD_DOC_DIR:="build-doc"}"
_x="${cEXAMPLES_DIR:="examples"}"
_x="${cMETADATA_FILE:="$cDOC_DIR/module.opal"}"

_x="${cQT_SUFFIX:="-qt5"}"
_x="${cLUPDATE_BIN:="lupdate$cQT_SUFFIX"}"
_x="${cQDOC_BIN:="qdoc$cQT_SUFFIX"}"
_x="${cQMAKE_BIN:="qmake$cQT_SUFFIX"}"
_x="${cQHG_BIN:="qhelpgenerator$cQT_SUFFIX"}"
_x="${cQMLMIN_BIN:="qmlmin"}"  # from libqt5-qtdeclarative-tools without suffix

_x="${cOPAL_PREFIX:="opal-"}"
_x="${cOPAL_PREFIX_STYLED:="Opal."}"

[[ ! -v "$cSCRIPT_DEPENDENCIES" ]] && cSCRIPT_DEPENDENCIES=()
cSCRIPT_DEPENDENCIES+=(git "$cLUPDATE_BIN" "$cQDOC_BIN" "$cQMAKE_BIN" "$cQHG_BIN" "$cQMLMIN_BIN")

function check_dependencies() {
    # shellcheck disable=SC2128
    [[ ! -v "$cSCRIPT_DEPENDENCIES" ]] && cSCRIPT_DEPENDENCIES=()
    for dep in "${cSCRIPT_DEPENDENCIES[@]}"; do
        if ! which "$dep" 2> /dev/null >&2; then
            printf -- "error: %s is required\n" "$dep" >&2
            exit 1
        fi
    done
}

function log() {
    IFS=' ' printf -- "%s\n" "$*" >&2
}

function verify_version() {
    # @@@ shared function version: 1.1.1
    local user_version_var="c__FOR_RELEASE_LIB__"
    local opal_version_var="c__OPAL_RELEASE_MODULE_VERSION__"

    if [[ -z "${!user_version_var}" ]]; then
        log "error: script compatibility cannot be verified"
        log "       make sure $user_version_var is set"
        exit 1
    fi

    if [[ ! "${!user_version_var}" =~ ^[0-9]+.[0-9]+.[0-9]+$ ]] && [[ ! "${!user_version_var}" =~ ^[0-9]+.[0-9]+.[0-9]+[-+] ]]; then
        # we don't verify pre-release versions and build metadata (i.e. everything after "-" or "+")
        log "error: variable $user_version_var='${!user_version_var}' does not contain a valid version number"
        exit 1
    fi

    local major="${!user_version_var%%.*}"
    local minor="${!user_version_var#*.}"; minor="${minor%.*}"
    # shellcheck disable=SC2034
    local patch="${!user_version_var##*.}"

    local opal_major="${!opal_version_var%%.*}"
    local opal_minor="${!opal_version_var#*.}"; opal_minor="${opal_minor%.*}"
    # shellcheck disable=SC2034
    local opal_patch="${!opal_version_var##*.}"

    if [[ "$opal_major" == 0 && "$major" == "$opal_major" && "$minor" != "$opal_minor" ]]; then
        log "module script: ${!user_version_var}, opal library script: ${!opal_version_var}"
        log "warning: unstable API has changed, please check the script"
        log "         if everything is fine, update $user_version_var"
        exit 1
    fi

    if (( "$opal_major" > "$major" )); then
        log "module script: ${!user_version_var}, opal library script: ${!opal_version_var}"
        log "error: please update the script for the current major library version ($opal_major vs. $major)"
        exit 1
    fi

    if (( "$opal_major" < "$major" || "$opal_minor" < "$minor" )); then
        log "module script: ${!user_version_var}, opal library script: ${!opal_version_var}"
        log "warning: the script expects a newer public API ($opal_major.$opal_minor vs. $major.$minor)"
        log "         please update the library"
        exit 1
    fi
}

# make sure script and library are compatible
verify_version >/dev/stderr

# check dependencies immediately after loading the script
# If the user changes cSCRIPT_DEPENDENCIES later, they can re-run this command.
check_dependencies >/dev/stderr

function read_metadata() {
    [[ "$1" == quiet ]] && local quiet=true
    declare -g -x -A cMETADATA

    if [[ ! -f "$cMETADATA_FILE" ]]; then
        log "error: module metadata file not found at '$cMETADATA_FILE'"
        exit 8
    fi

    function _read_value() { # 1: field key, 2: variable name, 3: fallback
        # Read the metadata field defined in $1 and save it as a variable
        # with the name defined in $2. The value is also saved to the cMETADATA
        # map with key $1. Falling back to $3 if the key is not defined.
        if grep -qoe "^$1: " "$cMETADATA_FILE"; then
            declare -g -x "$2"="$(grep -e "^$1: " "$cMETADATA_FILE" | sed "s/^$1: //")"
        else
            if [[ -n "$3" ]]; then
                log "note: metadata field '$1' is not defined, using '$3'"
                declare -g -x "$2"="$3"
            else
                log "error: metadata field '$1' not defined"
                exit 8
            fi
        fi

        [[ -z "${!2}" ]] && { log "error: metadata field '$1' is empty"; exit 8; }
        [[ "$quiet" != true ]] && echo "$1: ${!2}"
        cMETADATA["$1"]="${!2}"
    }

    # _read_value assigns the variable defined in $2 so any "variable is not defined"
    # checks (SC2154) regarding metadata fields are false positives.
    _read_value "name" "cNAME"
    _read_value "nameStyled" "cNAME_STYLED"
    _read_value "version" "cVERSION"
    _read_value "briefDescription" "cBRIEF_DESCRIPTION"
    _read_value "description" "cDESCRIPTION"
    _read_value "authors" "cAUTHORS"
    _read_value "maintainers" "cMAINTAINERS"
    _read_value "attribution" "cATTRIBUTION"
    _read_value "mainLicenseSpdx" "cLICENSE"
    _read_value "extraGalleryPages" "cEXTRA_GALLERY_PAGES" "none"
    _read_value "dependencies" "cDEPENDENCIES" "none"

    # shellcheck disable=SC2034,SC2154
    mapfile -t cMAINTAINERS_ARRAY <<<"$(tr ':' '\n' <<<"$cMAINTAINERS")"
    # shellcheck disable=SC2034,SC2154
    mapfile -t cAUTHORS_ARRAY <<<"$(tr ':' '\n' <<<"$cAUTHORS")"
    # shellcheck disable=SC2034,SC2154
    mapfile -t cATTRIBUTIONS_ARRAY <<<"$(tr ':' '\n' <<<"$cATTRIBUTION")"

    # shellcheck disable=SC2154
    if [[ "$cEXTRA_GALLERY_PAGES" != "none" ]]; then
        # shellcheck disable=SC2034,SC2154
        mapfile -t cEXTRA_GALLERY_PAGES_ARRAY <<<"$(tr ':' '\n' <<<"$cEXTRA_GALLERY_PAGES")"
    else
        # shellcheck disable=SC2034
        declare -g -a cEXTRA_GALLERY_PAGES_ARRAY=()
    fi

    # shellcheck disable=SC2154
    if [[ "$cDEPENDENCIES" != "none" ]]; then
        # shellcheck disable=SC2034,SC2154
        mapfile -t cDEPENDENCIES_ARRAY <<<"$(tr ':' '\n' <<<"$cDEPENDENCIES")"
    else
        # shellcheck disable=SC2034
        declare -g -a cDEPENDENCIES_ARRAY=()
    fi

    # shellcheck disable=SC2154
    cMETADATA["fullName"]="$cOPAL_PREFIX$cNAME"
    # shellcheck disable=SC2154
    cMETADATA["fullNameStyled"]="$cOPAL_PREFIX_STYLED$cNAME_STYLED"
}

function parse_arguments() { # @: all shell arguments given to release-module.sh
    function _show_help() {
        echo "\
** Opal Release Script **

Manage Opal module release bundles.

This script can build release bundles, provide machine readable access to module
configuration, and aid with publishing a new release.

Usage:
    $0 -h -V                        - print help or version info
    $0 [-b OUTNAME] [-n] [-d]       - build release bundles and documentation
    $0 -c KEY                       - access module configuration
    $0 -p                           - publish a new release

Arguments:
    Build release bundles and documentation:
        -b, --bundle OUTNAME - write bundle to \"$cBUILD_DIR/\$OUTNAME.tar.gz\" instead of
                               using an automatically generated name
        -n, --no-minify      - disable QML minification, i.e. keep all QML files as they are
        -d, --docs           - only generate docs

    Manage configuration:
        -c, --config KEY     - get value of metadata field KEY

    Publish new releases:
        -p, --publish-wizard - run the publication wizard for publishing a new release

    General options:
        -h, --help           - show this help and exit
        -V, --version        - show version and license information
"
    }

    function _version() {
        printf -- "opal-release-module.sh\nCopyright (c) 2018-2023 Mirian Margiani -- CC-BY-SA-4.0\n"
        printf -- "version %s\n" "$c__OPAL_RELEASE_MODULE_VERSION__"
        read_metadata quiet

        # shellcheck disable=SC2154
        printf -- "\nFOR MODULE: %s (%s), version %s\n" "${cMETADATA[fullName]}" "${cMETADATA[fullNameStyled]}" "$cVERSION"
    }

    while (( $# > 0 )); do
        case "$1" in
            --help|-h) _show_help; exit 0;;
            --version|-V) _version; exit 0;;
            --bundle|-b) shift && [[ -z "$1" ]] && log "error: OUTNAME is missing" && exit 9
                declare -g -x cCUSTOM_BUNDLE_NAME="${1%.tar.gz}"
            ;;
            --docs|-d)
                build_qdoc ""
                exit $?
            ;;
            --config|-c)
                shift && read_metadata quiet
                if [[ -n "$1" ]]; then
                    [[ -n "${cMETADATA["$1"]}" ]] && printf -- "%s\n" "${cMETADATA["$1"]}" || exit 1
                else
                    for i in "${!cMETADATA[@]}"; do
                        printf -- "%s\n" "$i: ${cMETADATA["$i"]}"
                    done
                fi
                exit 0
            ;;
            --no-minify|-n)
                declare -g cENABLE_MINIFY=false
            ;;
            --publish-wizard|-p)
                run_publish_wizard
                exit $?
            ;;
            -*) printf -- "unknown option: %s\n" "$1";;
            *) shift; continue;;
        esac
        shift
    done
}

function run_publish_wizard() {
    # shellcheck disable=SC2155
    local back_dir="$(pwd)"
    read_metadata

    # Setup basics
    function white() {
        white_n "$@" && echo
    }

    function white_n() {
        echo -ne "\e[1m"
        printf -- "%s " "$@" | sed 's/ $//g'
        echo -ne "\e[0m"
    }

    function checklist_task() { # 1: message
        read -r -n 1 -s -p "$1 --> "
        white ok
    }

    function yesno_task() { # 1: question
        while true; do
            read -r -n 1 -s -p "$1 (y/n)> "

            if [[ "$REPLY" =~ ^n|N$ ]]; then
                white "aborted"
                return 3
            elif [[ "$REPLY" =~ ^y|Y$ ]]; then
                white "ok"
                return 0
            else
                echo
            fi
        done
    }

    function have_cmd() {  # 1: command name
        command -v "$1" > /dev/null 2>&1
    }

    # Configuration
    local do_translate=
    if [[ -d translations ]]; then
        # we cannot check the contents of cTRANSLATE because it is set after
        # arguments have been parsed, i.e. after this function has been called
        do_translate=true
    fi

    # Find tools
    local have_gh=      && have_cmd gh        && have_gh=true
    local have_reuse    && have_cmd reuse     && have_reuse=true
    local have_gitk=    && have_cmd gitk      && have_gitk=true
    local have_kate=    && have_cmd kate      && have_kate=true
    local have_xclip=   && have_cmd xclip     && have_xclip=true
    local have_wl_copy= && have_cmd wl-copy   && have_wl_copy=true

    # Commit all changes
    if [[ -n "$(git status --porcelain=v1)" ]]; then
        git gui &
        checklist_task "There are uncommitted changes. Ensure they are safe."
    fi

    # Merge weblate PRs and check open PRs
    if [[ -n "$have_gh" ]]; then
        if [[ -n "$do_translate" ]]; then
            if yesno_task "[AUTO] Merge open Weblate pull requests and pull?"; then
                gh pr merge -m "$(gh pr list --author "weblate" --json number -q ".[].number" | cat)" && git pull
            else
                echo "Merging weblate PRs skipped"
            fi
        fi

        if yesno_task "[AUTO] Check for open/pending pull requests?"; then
            gh pr list
        else
            echo "Running 'gh pr list' skipped."
        fi

        if yesno_task "[AUTO] Run 'git fetch --all'"; then
            git fetch --all
        else
            echo "Running 'git fetch --all' skipped."
        fi
    fi

    if [[ -n "$do_translate" ]]; then
        # Update translations
        checklist_task "Ensure translations are ready to be updated."
        "$0" -b _wizard_temp || {
            echo "warning: build script returned with a non-zero exit status ($?)"
        }

        # Commit translations
        if [[ -n "$(git status --porcelain=v1 -- translations)" ]]; then
            if yesno_task "[AUTO] Commit updated translations?"; then
                git add translations && git commit -m "Update translations"
            else
                echo "Committing updated translations skipped."
            fi
        fi
    fi

    # Run reuse lint
    if [[ -n "$have_reuse" ]]; then
        if ! reuse lint; then
            checklist_task "Fix 'reuse' compliance."
        fi
    fi

    # Update version number
    if [[ -n "$have_gitk" ]]; then
        gitk 2>/dev/null >/dev/null &
    fi

    printf -- "%s\n" "Current version: $cVERSION"
    white_n "New version: " && local new_version=

    if read -r -e -i "$cVERSION" && [[ -n "$REPLY" ]]; then
        new_version="$REPLY"
        sed -Ei "s/^version: $cVERSION$/version: $new_version/" doc/module.opal
    else
        echo "Failed to read new version number."
        exit 1
    fi

    # Update changelog
    # shellcheck disable=SC2155
    local changelog_template="## $new_version ($(date +%F))"
    local last_tag=
    local log_range=
    local updated_translations=

    if [[ -n "$do_translate" ]]; then
        if last_tag="$(git describe --tags --abbrev=0 --match="v*")"; then
            log_range="$last_tag..HEAD"
        else
            log_range="HEAD"
        fi

        updated_translations="$(
            git log --show-notes-by-default "$log_range" -- translations |\
                grep 'Added translation using Weblate' |\
                sort -u |\
                grep -oe '(.*)' |\
                sed 's/^(//; s/)$//' |\
                perl -p0e 's/\n/, /g; s/, $//; s/^/- Added translations: /g';
            echo;
            git log --show-notes-by-default "$log_range" -- translations |\
                grep 'Translated using Weblate' |\
                sort -u |\
                grep -oe '(.*)' |\
                sed 's/^(//; s/)$//' |\
                perl -p0e 's/\n/, /g; s/, $//; s/^/- Updated translations: /g';
        )" || {
            updated_translations=
        }
    fi

    if [[ -n "$have_wl_copy" ]]; then
        printf -- "%s\n" "$changelog_template" "" "$updated_translations" | wl-copy
    elif [[ -n "$have_xclip" ]]; then
        printf -- "%s\n" "$changelog_template" "" "$updated_translations" | xclip -selection c
    else
        echo "Change log template:"
        printf -- "%s\n" "$changelog_template" "" "$updated_translations"
    fi

    if [[ -n "$have_kate" ]]; then
        kate CHANGELOG.md 2>/dev/null >/dev/null &
    else
        echo "Change log file: CHANGELOG.md"
    fi

    if [[ -n "$have_wl_copy" || -n "$have_xclip" ]]; then
        checklist_task "Update the change log (template copied)."
    else
        checklist_task "Update the change log (template above)."
    fi

    # Load latest changelog
    local latest_changes=
    # shellcheck disable=2002
    latest_changes="$(cat CHANGELOG.md | awk -v pattern="^## $new_version \\\\(" '$0 ~ pattern {flag=1;print;next}/^## [0-9]+\./{flag=0}flag')"

    if (( ${#cDEPENDENCIES_ARRAY[@]} > 0 )); then
        latest_changes+="$(cat <<-EOF


			**Module dependencies:**

			This module depends on the following other Opal modules. Please
			download and install them as well to use this module:

			$(for i in "${cDEPENDENCIES_ARRAY[@]}"; do
                i="${i#opal-}"
                printf -- "- [opal-%s](https://github.com/Pretty-SFOS/opal-%s/releases/latest)\n" "$i" "$i"
            done)
		EOF
        )"
    fi

    echo
    printf -- "%s\n" "$latest_changes"

    if ! yesno_task "Is this the correct change log for the new version $new_version?"; then
        echo "Could not extract the new change log. Creating a release automatically is not possible."
        echo "Please check the logs and the change log for issues."
        exit 1
    fi

    # Commit release
    if yesno_task "[AUTO] Create release commit with changelog and version change?"; then
        git add doc/module.opal && \
            git add CHANGELOG.md && \
                git commit -m "Release version v$new_version"
    else
        echo "Release commit skipped."
    fi

    # Tag release
    if yesno_task "[AUTO] Tag the new release v$new_version?"; then
        git tag "v$new_version"
    else
        echo "Tagging skipped."
    fi

    # Push changes
    if yesno_task "[AUTO] Push new commits?"; then
        git push && git push --tags
    else
        echo "Pushing skipped. Automatically creating a release may not work until the new tag is pushed."
    fi

    # Build release bundle and publish to Github
    white "Ensure the working directory is ready for building the release bundle."
    if [[ -n "$have_gh" ]]; then
        checklist_task "The release will now be published to Github automatically."
    else
        checklist_task "The release must be published manually."
    fi

    local bundle="build/${cMETADATA[fullName]}-v$new_version.tar.gz"

    if "$0" -b "$(basename "$bundle")"; then
        if [[ -n "$have_gh" ]]; then
            gh release create "v$new_version" "$bundle" --notes "$latest_changes" || {
                echo "Failed to create a new release on Github."
            }
        else
            checklist_task "Publish the release online."
        fi
    else
        echo "warning: build script returned with a non-zero exit status ($?)"
    fi

    echo "Done."
}

function build_qdoc() { # 1: to=/path/to/output/dir
    # If $1 is to=/path/to/output/dir, the generated help file will be copied
    # to the given directory.

    # shellcheck disable=SC2155
    local back_dir="$(pwd)"
    read_metadata

    local source_dirs=(.)
    for i in Opal src; do
        [[ ! -d "$i" ]] && continue
        source_dirs+=("$(realpath "$i" --relative-to="$cBUILD_DOC_DIR")")
    done

    local have_cpp=false
    if [[ -d src ]]; then
        have_cpp=true
    fi

    export QT_INSTALL_DOCS="${QT_INSTALL_DOCS:="$("$cQMAKE_BIN" -query QT_INSTALL_DOCS)"}"
    export QT_VERSION="${QT_VERSION:="$("$cQMAKE_BIN" -query QT_VERSION)"}"
    export QT_VER="${QT_VERSION:="$("$cQMAKE_BIN" -query QT_VERSION)"}"

    export OPAL_PROJECT="${OPAL_PROJECT:=${cMETADATA[fullName]}}"
    export OPAL_PROJECT_STYLED="${OPAL_PROJECT_STYLED:=${cMETADATA[fullNameStyled]}}"
    export OPAL_PROJECT_VERSION="${OPAL_PROJECT_VERSION:=$cVERSION}"
    export OPAL_PROJECT_EXAMPLESDIR="${OPAL_PROJECT_EXAMPLESDIR:=$cEXAMPLES_DIR}"
    export OPAL_PROJECT_DOCDIR="${OPAL_PROJECT_DOCDIR:=$cDOC_DIR}"
    export OPAL_DOC_OUTDIR="${OPAL_DOC_OUTDIR:=$cBUILD_DOC_DIR}"

    local cTEMP_DOC_DIR
    cTEMP_DOC_DIR="$(mktemp -d -p . -t build-doc-tmp.XXXX)" || {
        log "error: failed to prepare temporary documentation directory"
        exit 1
    }

    mkdir -p "$cBUILD_DOC_DIR" || {
        log "error: failed to prepare documentation output directory"
        exit 1
    }

    if [[ ! -f "$cDOC_DIR/module.qdoc" ]]; then
        cat <<EOF > "$cTEMP_DOC_DIR/module.qdoc"
// This file is generated from settings defined in doc/module.opal.

/*!
    \\qmlmodule $OPAL_PROJECT_STYLED 1.0
    \\title $OPAL_PROJECT_STYLED
    \\brief ${cMETADATA["briefDescription"]}

    ${cMETADATA["description"]}

    \\section1 QML Types

    The $OPAL_PROJECT_STYLED module provides the following QML types:
*/

/*!
    \\qmlmodule $OPAL_PROJECT_STYLED.private 1.0
    \\title $OPAL_PROJECT_STYLED.private
    \\brief This module provides private types of $OPAL_PROJECT_STYLED.
    \\relates $OPAL_PROJECT_STYLED

    These types belong to the private API of $OPAL_PROJECT_STYLED and should
    not be used directly. They can change even in minor versions. You have
    been warned.
*/
EOF
    fi

    local general_qdocconf="$cDOC_DIR/opal-qdoc.qdocconf"

    if [[ ! -f "$general_qdocconf" ]]; then
        general_qdocconf="$cTEMP_DOC_DIR/opal-qdoc.qdocconf"

        # REUSE-IgnoreStart
        cat <<"EOF" > "$general_qdocconf"
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2021-2025 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-qdoc.md
# for documentation.
#
# @@@ FILE VERSION 0.3.0
#

# project definition
# description has to be set by the module
project = $OPAL_PROJECT_STYLED
version = $OPAL_PROJECT_VERSION

# TODO: document custom macros
macro.opalrootlink = "https://github.com/Pretty-SFOS/opal/blob/main/\1"
macro.opsnip = "\\l {\\opalrootlink {snippets/opal-\1.md}} {opal-\1}"
macro.opdev = "\\l {\\opalrootlink {opal-development/opal-\1.md}} {opal-\1}"
macro.opmod = "\\l {https://github.com/Pretty-SFOS/opal-\1} {Opal.\1}"

macro.todo = "\n\n\\b {Todo:} \1"
macro.required = "\n\n\\b {Important:} this property is required and must be " \
                 "specified when using this component."
macro.defaultValue = "\n\nThe default value of this property is “\\c {\1}”."

# include some Qt defaults
# -- macros for QDoc commands
include($QT_INSTALL_DOCS/global/macros.qdocconf)
# -- needed by C++ projects
include($QT_INSTALL_DOCS/global/qt-cpp-defines.qdocconf)
# -- compatibility macros
include($QT_INSTALL_DOCS/global/compat.qdocconf)
# -- configuration common among QDoc projects
include($QT_INSTALL_DOCS/global/fileextensions.qdocconf)
# -- offline HTML template for documentation shipped to Qt Creator
include($QT_INSTALL_DOCS/global/qt-html-templates-offline.qdocconf)

# assign custom HTML footer to replace Qt's default copyright notice
HTML.footer = "<div align='center'><hr/>" \
              "<p><small><a href='https://github.com/Pretty-SFOS/$OPAL_PROJECT'>$OPAL_PROJECT_STYLED</a> $OPAL_PROJECT_VERSION<br>\n" \
              "This document may be used under the terms of the " \
              "<a href='https://spdx.org/licenses/GFDL-1.3-or-later.html'>" \
              "GNU Free Documentation License version 1.3</a> " \
              "as published by the Free Software Foundation.</small></p>" \
              "<p/></div>"

# Qt help system configuration
qhp.projects = Opal

# output file name below $OPAL_DOC_OUTDIR
qhp.Opal.file                = $OPAL_PROJECT.qhp
qhp.Opal.namespace           = $OPAL_PROJECT_STYLED.100
qhp.Opal.virtualFolder       = $OPAL_PROJECT
qhp.Opal.indexTitle          = $OPAL_PROJECT_STYLED
qhp.Opal.indexRoot           =

# additional subprojects can be defined by using the '+=' operator
# the default subproject is a listing of all QML types the module offers
qhp.Opal.subprojects         = qmltypes

qhp.Opal.subprojects.qmltypes.title = QML Types
qhp.Opal.subprojects.qmltypes.indexTitle = $OPAL_PROJECT_STYLED QML Types
qhp.Opal.subprojects.qmltypes.selectors = qmltype
qhp.Opal.subprojects.qmltypes.sortPages = true

# The outputdir variable specifies the directory where QDoc will put the
# generated documentation.
outputdir   = ../$OPAL_DOC_OUTDIR

# The headerdirs variable specifies the directories containing the header files
# associated with the .cpp source files used in the documentation.
# Header directories must be specified by the module.
# headerdirs  = Opal

# The sourcedirs variable specifies the directories containing the .cpp or .qdoc
# files used in the documentation. Additional dirs can be specified.
sourcedirs  += ../$OPAL_PROJECT_DOCDIR

# This enables parsing of JavaScript files by default.
# Cf. https://lists.qt-project.org/pipermail/development/2014-April/016658.html
#
# Note that each JS file needs a \qmlmodule topic command, and each function
# must be documented using the \qmlmethod command.
sources.fileextensions += "*.js"

# The exampledirs variable specifies the directories containing
# the source code of the example files. Additional dirs can be specified.
exampledirs += ../$OPAL_PROJECT_EXAMPLESDIR

# The imagedirs variable specifies the directories containing the images used in
# the documentation. Additional dirs can be specified.
imagedirs   += ../$OPAL_PROJECT_DOCDIR/images
EOF
        # REUSE-IgnoreEnd
    fi

    local project_qdocconf="$cDOC_DIR/$OPAL_PROJECT.qdocconf"

    if [[ ! -f "$project_qdocconf" ]]; then
        project_qdocconf="$cTEMP_DOC_DIR/$OPAL_PROJECT.qdocconf"

        cat <<-EOF > "$project_qdocconf"
			# This file is generated from settings defined in doc/module.opal.
			include(opal-qdoc.qdocconf)
			description = ${cMETADATA["description"]}
			headerdirs += ${source_dirs[*]}
			sourcedirs += ${source_dirs[*]}

			$([[ "$have_cpp" == false ]] && echo 'moduleheader = ')
		EOF
    fi

    "$cQDOC_BIN" --highlighting -I "$cTEMP_DOC_DIR" -I "$cDOC_DIR" -I "$OPAL_PROJECT_DOCDIR" "$project_qdocconf" || {
        log "error: failed to generate docs"
        exit 1
    }

    cd "$cBUILD_DOC_DIR" || {
        log "error: failed to enter doc directory"
        exit 1
    }

    "$cQHG_BIN" "$OPAL_PROJECT.qhp" -c -o "$OPAL_PROJECT.qch" || {
        log "error: failed to generate Qt help pages"
        exit 1
    }

    cd "$back_dir" || {
        log "error: failed to return to $back_dir"
        exit 1
    }

    if [[ "$1" == "to="* ]]; then
        local copy_to="${1#to=}"

        mkdir -p "$copy_to" || {
            log "error: failed to prepare documentation output directory"
            exit 1
        }

        cp "$cBUILD_DOC_DIR/$OPAL_PROJECT.qch" "$copy_to" || {
            log "error: failed to copy generated docs"
            exit 1
        }
    fi

    rm -r "$cTEMP_DOC_DIR"
}

function build_bundle() {
    # shellcheck disable=SC2155
    local back_dir="$(pwd)"
    read_metadata

    if ! type copy_files &>/dev/null; then
        log "error: copy_files function not defined"
        exit 255
    fi

    local do_translate=true
    # shellcheck disable=SC2154
    if (( "${#cTRANSLATE[@]}" == 0 )); then
        log "note: no translations defined"
        do_translate=false
    fi

    if [[ -z "$cBUILD_DIR" ]]; then
        log "error: no build directory specified"
        exit 4
    fi

    # # Prepare version number from git tag, using current date and current commit
    # # as fallback values
    # local version
    # if ! git describe --tags 2>/dev/null >/dev/null; then
    #     version="v$(date +%F)"
    #     if git rev-parse --short HEAD --verify 2>/dev/null >/dev/null; then
    #         version="$version-$(git rev-parse --short HEAD --verify)"
    #     fi
    # else
    #     version="v$(git describe --tags | sed 's/^v//g')"
    # fi

    local version="$cVERSION"
    local commit=""
    if git rev-parse --short HEAD --verify 2>/dev/null >/dev/null; then
        commit="$(git rev-parse --short HEAD --verify)"
    fi

    # Setup base paths
    local build_root_name="${cMETADATA[fullName]}"
    local build_root="$cBUILD_DIR/$build_root_name"
    local qml_base="$build_root/qml/modules"
    local meta_base="$build_root/libs"
    local src_base="$build_root/libs/opal/${cMETADATA[name]}"
    local tr_base="$build_root/libs/opal-translations/${cMETADATA[fullName]}"
    local doc_base="$build_root/libs/opal-docs"
    local readme_base="$build_root/readme"

    mkdir -p "$cBUILD_DIR" || { log "error: failed to create base build directory"; exit 1; }
    rm -rf "$build_root" || { log "error: failed to clear build root"; exit 1; }
    mkdir -p "$build_root" || { log "error: failed to create build root"; exit 1; }
    mkdir -p "$meta_base" "$qml_base" "$doc_base" "$src_base" "$readme_base" || {
        log "error: failed to prepare build root"
        exit 1
    }

    # REUSE-IgnoreStart
    # shellcheck disable=2154
    cat <<-EOF > "$doc_base/.gitignore"
		# This file is part of Opal.
		# SPDX-FileCopyrightText: 2023-$(date +%Y) Mirian Margiani
		# SPDX-License-Identifier: CC0-1.0
		opal-*.qch
	EOF
    # REUSE-IgnoreEnd

    if [[ "$do_translate" == true ]]; then
        mkdir -p "$tr_base" || {
            log "error: failed to prepare translations directory in build root"
            exit 1
        }

        # copy the translations helper script:
        # As opal-release-module.sh is sourced in the current module's
        # release-module.sh script, we have to use a relative path here.
        # TODO find a better way to do this without hardcoded paths
        cp ../opal/snippets/opal-merge-translations.sh -t "$meta_base" || {
            # It's not a big problem if this fails for some reason. Users can
            # always manually download the script if necessary.
            log "warning: failed to import the opal-merge-translations.sh snippet"
        }

        # REUSE-IgnoreStart
        # shellcheck disable=2154
        cat <<-EOF > "$tr_base/.gitignore"
			# This file is part of Opal.
			# SPDX-FileCopyrightText: 2023-$(date +%Y) Mirian Margiani
			# SPDX-License-Identifier: CC0-1.0
			${cMETADATA["fullName"]}-*.ts
		EOF
        # REUSE-IgnoreEnd
    fi

    # NOTE: translations are built from the *original* sources and not from the
    # files prepared in copy_files!
    if [[ "$do_translate" == true ]]; then
        if [[ ! -d "$cTR_DIR" ]]; then
            mkdir -p "$cTR_DIR" || {
                log "error: failed to setup translations directory in $cTR_DIR"
                exit 1
            }
        fi

        if [[ ! -f "$cTR_DIR/${cMETADATA[fullName]}.ts" ]]; then
            # Setup initial translation catalog
            "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -locations absolute -ts "$cTR_DIR/${cMETADATA[fullName]}.ts" || {
                log "error: failed to create initial translations"
                exit 3
            }
        fi

        # Update translation catalogs
        "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -noobsolete -locations absolute -ts "$cTR_DIR/"*.ts || {
            log "error: failed to update translations"
            exit 3
        }
    fi

    # Generate attribution component
    # This is done *before* copy_files is called so that Opal.About can copy the
    # generated attribution to its own directory. If someone only uses Opal.About,
    # they shouldn't have to import the attributions module on their “About” page.
    mkdir -p "$qml_base/Opal/Attributions" || {
        log "error: failed to prepare attributions directory at $qml_base/Opal/Attributions"
    }

    # REUSE-IgnoreStart
    # shellcheck disable=2154
    cat <<-EOF > "$qml_base/Opal/Attributions/${cMETADATA[fullNameStyled]//./}Attribution.qml"
		//@ This file is part of ${cMETADATA[fullName]}.
		//@ https://github.com/Pretty-SFOS/${cMETADATA[fullName]}
		//@ SPDX-License-Identifier: $cLICENSE
		$(printf -- '//@ SPDX-FileCopyrightText: %s\n' "${cATTRIBUTIONS_ARRAY[@]}")

		import QtQuick 2.0
		import "../../Opal/About" as A

		A.Attribution {
		    name: "${cMETADATA[fullNameStyled]} (v${cMETADATA[version]})"
		    entries: [$(printf -- '"%s", ' "${cATTRIBUTIONS_ARRAY[@]}" | sed 's/, $//')]
		    licenses: A.License { spdxId: "$cLICENSE" }
		    sources: "https://github.com/Pretty-SFOS/${cMETADATA[fullName]}"
		    homepage: "https://github.com/Pretty-SFOS/opal"
		}
	EOF
    # REUSE-IgnoreEnd

    # Make build paths available for copy_files()
    # shellcheck disable=SC2034
    local BUILD_ROOT="$build_root"
    # shellcheck disable=SC2034
    local QML_BASE="$qml_base"
    # shellcheck disable=SC2034
    local DOC_BASE="$doc_base"
    # shellcheck disable=SC2034
    local SRC_BASE="$src_base"

    # Import distribution files
    if [[ "$do_translate" == true ]]; then
        cp "$cTR_DIR/"*.ts "$tr_base" || { log "error: failed to prepare translations"; exit 1; }
        rm "$tr_base/${cMETADATA["fullName"]}.ts" 2>/dev/null || true
    fi

    copy_files || { log "error: failed to prepare sources"; exit 1; }

    # Remove the extra translations dummy file from the release bundle, as translations
    # are built separately and are merged if needed.
    rm -f "$qml_base/Opal/${cMETADATA[nameStyled]}/private/ExtraTranslations.qml" || true

    # Remove the private directory if it remains empty after the extra translations
    # file has been removed.
    rmdir --ignore-fail-on-non-empty "$qml_base/Opal/${cMETADATA[nameStyled]}/private"

    unset BUILD_ROOT QML_BASE DOC_BASE SRC_BASE

    # Strip comments from dist files
    local minify_failed=()
    if [[ -z "$cENABLE_MINIFY" || "$cENABLE_MINIFY" == true ]]; then
        shopt -s nullglob extglob
        # shellcheck disable=SC2155
        local temp="$(mktemp)"
        mapfile -d $'\0' -t files_to_strip < <(find "$qml_base" -iregex ".*\.\(qml\|js\)" -type "f" -print0)

        for i in "${files_to_strip[@]}"; do
            keep="$(grep -Ee '^\s*//@' "$i")"
            if [[ "$keep" != "" ]]; then
                printf -- "%s\n" "$keep" > "$temp"
            fi

            if [[ "$i" == *.qml ]]; then
                if sed '/^\s*\/\/@/d' "$i" |\
                    perl -p0e 's/for\s*\(\s*([^;)]*?)\s*;\s*([^;)]*?)\s*;\s*([^;)]*?)\)/#FORLOOP#/g' |\
                        grep -qoe ';';
                then
                    log "warning: file '$i' contains at least one stray semicolon"
                    log "         This breaks minification. Make sure there are no semicolons and try again."
                    log "         Semicolons are only allowed in for-loops, and in comment lines starting with '//@'."
                    minify_failed+=("$i")
                    continue
                fi

                "$cQMLMIN_BIN" "$i" |\
                    perl -p0e 's/for\s*\(\s*([^;)]*?)\s*;\s*([^;)]*?)\s*;\s*([^;)]*?)\)/for(\1#OPAL#SEMICOLON#\2#OPAL#SEMICOLON#\3)/g' |\
                        tr ';' '\n' |\
                        sed 's/#OPAL#SEMICOLON#/;/g' \
                    >> "$temp"
            elif [[ "$i" == *.js ]]; then
                "$cQMLMIN_BIN" "$i" >> "$temp"
            else
                log "warning: only QML and JS files can be minified"
                cp "$i" "$temp"
            fi

            # REUSE-IgnoreStart
            if ! grep -qPoe '(SPDX-License-Identifier:|SPDX-FileCopyrightText:)' "$temp"; then
                log "warning: no copyright info in '$i' after stripping comments"
                log "         make sure to start all required lines with '//@' (instead of '//' or '/*')"
            fi
            # REUSE-IgnoreEnd

            mv "$temp" "$i"
        done

        rm -f "$temp"
        shopt -u nullglob extglob
    fi

    # Write qmake include file if there are C++ sources
    rmdir --parents --ignore-fail-on-non-empty "$src_base"
    mkdir -p "$meta_base"

    if [[ -d "$src_base" ]]; then
        local qmake_include_file="$meta_base/opal-include.pri"

        cat <<EOF > "$qmake_include_file"
# This file is part of Opal.
# SPDX-FileCopyrightText: 2023-$(date +%Y) Mirian Margiani
# SPDX-License-Identifier: CC-BY-SA-4.0
#
# Include this file in your main .pro file to enable
# Opal modules that use or provide C++ sources and/or headers.
#
# Add this line to your main .pro file:
#       include(libs/opal-include.pri)
#
# You can then use Opal headers by including them in your
# C++ files like this:
#       #include <libs/opal/mymodule/myheader.h>
#
# NOTE: this is a generic helper file used by all Opal source
# modules. You can safely overwrite it when updating a module.
#

# Enable autocompletion for Opal modules in QtCreator
QML_IMPORT_PATH += qml/modules

# Make headers available for inclusion
INCLUDEPATH += \$\$relative_path(\$\$PWD/opal)

# Search for any project include files and include them now
message(Searching for Opal source modules...)

OPAL_SOURCE_MODULES = \$\$files(\$\$PWD/opal/*)
for (module, OPAL_SOURCE_MODULES) {
    module_includes = \$\$files(\$\$module/*.pri)

    for (to_include, module_includes) {
        message(Enabling Opal source module <libs/\$\$relative_path(\$\$dirname(to_include))>)
        include(\$\$to_include)
    }
}
EOF
    fi

    # Write metadata file
    # REUSE-IgnoreStart
    local metadata_file="$meta_base/module_${cMETADATA[fullName]}.txt"
    # shellcheck disable=SC2154
    cat <<-EOF > "$metadata_file"
		# Store this file to keep track of packaged module versions.
		# It is not necessary to ship this in your app's final RPM package.
		# SPDX-License-Identifier: $cLICENSE
		$(printf -- '# SPDX-FileCopyrightText: %s\n' "${cATTRIBUTIONS_ARRAY[@]}")

		# Attribution using Opal.About:
		#   Opal attributions are automatically added to the About page.
		#   Make sure to use the latest version of Opal.About:
		#   https://github.com/Pretty-SFOS/opal-about/releases/latest
		#
		# Manual attribution:
		#   Mention at least name, license, and the attribution text
		#   on the About page of your app. Use the information below.

		module: ${cMETADATA[fullNameStyled]} (${cMETADATA[fullName]})
		version: $cVERSION${commit:+" (git:$commit)"}
		description: $cDESCRIPTION
		maintainers: $cMAINTAINERS
		attribution: $cATTRIBUTION
		license: $cLICENSE
		sources: https://github.com/Pretty-SFOS/${cMETADATA[fullName]}
	EOF
    # REUSE-IgnoreEnd

    # Write README files
    cp "$back_dir/README.md" "$back_dir/CHANGELOG.md" -t "$readme_base"
    cp "$back_dir/LICENSES/$cLICENSE.txt" "$readme_base/LICENSE.txt"

    if (( ${#cEXTRA_GALLERY_PAGES_ARRAY[@]} > 0 )); then
        mkdir -p "$readme_base/example"
        cp "$back_dir/doc/gallery.qml" "$readme_base/example/main.qml"

        for i in "${cEXTRA_GALLERY_PAGES_ARRAY[@]}"; do
            cp "$back_dir/doc/gallery/$i" -t "$readme_base/example"
        done
    elif [[ -f "$back_dir/doc/gallery.qml" ]]; then
        cp "$back_dir/doc/gallery.qml" "$readme_base/example.qml"
    fi

    if (( ${#cDEPENDENCIES_ARRAY[@]} > 0 )); then
        cat <<-EOF > "$readme_base/DEPENDENCIES.md"
			# Module dependencies

			This module depends on the following other Opal modules. Please
			download and install them as well to use this module:

			$(for i in "${cDEPENDENCIES_ARRAY[@]}"; do
                i="${i#opal-}"
                printf -- "- [opal-%s](https://github.com/Pretty-SFOS/opal-%s/releases/latest)\n" "$i" "$i"
            done)
		EOF
    fi

    # Create final package
    cd "$cBUILD_DIR" || {
        log "error: failed to enter build directory '$cBUILD_DIR'"
        exit 2
    }
    local package="${cMETADATA[fullName]}-$version${commit:+"-$commit"}"
    local bundle_name="${cCUSTOM_BUNDLE_NAME:-"$package"}.tar.gz"
    tar --mode="u+rwX,a+rX" --numeric-owner --owner=0 --group=0 -czvf "$bundle_name" "$build_root_name" || {
        log "error: failed to create package"
        exit 2
    }
    rm -rf "$build_root_name"  # clear build root

    cd "$back_dir" || {
        log "error: failed to return to base directory '$back_dir'"
        exit 2
    }

    # Log warnings
    if (( ${#minify_failed[@]} > 0 )); then
        log
        log "warning: minification failed for the following files:"
        log
        printf -- "- %s\n" "${minify_failed[@]}"
        log
        log "Make sure those files do not contain any semicolons outside of"
        log "for-loops and sticky comments (\"//@\"), then try again."
        log "Minification is important to keep the bundle size as small as possible."
    fi
}
