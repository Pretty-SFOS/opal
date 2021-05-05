#!/bin/bash
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2018-2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-release-module.md
# for documentation.
#
# @@@ FILE VERSION $c__OPAL_RELEASE_MODULE_VERSION__
#

c__OPAL_RELEASE_MODULE_VERSION__="0.2.0"
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

_x="${cOPAL_PREFIX:="opal-"}"
_x="${cOPAL_PREFIX_STYLED:="Opal."}"

[[ ! -v "$cDEPENDENCIES" ]] && cDEPENDENCIES=()
cDEPENDENCIES+=("$cLUPDATE_BIN" "$cQDOC_BIN" "$cQMAKE_BIN" "$cQHG_BIN")

function check_dependencies() {
    [[ ! -v "$cDEPENDENCIES" ]] && cDEPENDENCIES=()
    for dep in "${cDEPENDENCIES[@]}"; do
        if ! which "$dep" 2> /dev/null >&2; then
            printf "error: %s is required\n" "$dep"
            exit 1
        fi
    done
}

function verify_version() {
    # @@@ shared function version: 1.0.0
    local user_version_var="c__FOR_RELEASE_LIB__"
    local opal_version_var="c__OPAL_RELEASE_MODULE_VERSION__"

    if [[ -z "${!user_version_var}" ]]; then
        echo "error: script compatibility cannot be verified"
        echo "       make sure $user_version_var is set"
        exit 1
    fi

    if [[ ! "${!user_version_var}" =~ ^[0-9]+.[0-9]+.[0-9]+ ]]; then
        # SemVer actually allows different forms of suffices...
        printf -- "error: variable $user_version_var='%s' does not contain a valid version number\n" "${!user_version_var}"
        exit 1
    fi

    local major="${!user_version_var%%.*}"
    local minor="${!user_version_var#*.}"; minor="${minor%.*}"
    local patch="${!user_version_var##*.}"

    local opal_major="${!opal_version_var%%.*}"
    local opal_minor="${!opal_version_var#*.}"; opal_minor="${opal_minor%.*}"
    local opal_patch="${!opal_version_var##*.}"

    printf -- "module script: %s, opal library script: %s\n" "${!user_version_var}" "${!opal_version_var}"

    if [[ "$opal_major" == 0 && "$major" == "$opal_major" && "$minor" != "$opal_minor" ]]; then
        echo "warning: unstable API has changed, please check the script"
        echo "         if everything is fine, update $user_version_var"
        exit 1
    fi

    if (( "$opal_major" > "$major" )); then
        echo "error: please update the script for the current major library version ($opal_major vs. $major)"
        exit 1
    fi

    if (( "$opal_major" < "$major" || "$opal_minor" < "$minor" )); then
        echo "warning: the script expects a newer public API ($opal_major.$opal_minor vs. $major.$minor)"
        echo "         please update the library"
        exit 1
    fi
}

# make sure script and library are compatible
verify_version

# check dependencies immediately after loading the script
# If the user changes cDEPENDENCIES later, they can re-run this command.
check_dependencies

function read_metadata() {
    [[ "$1" == quiet ]] && local quiet=true
    declare -g -x -A cMETADATA

    if [[ ! -f "$cMETADATA_FILE" ]]; then
        echo "error: module metadata file not found at '$cMETADATA_FILE'"
        exit 8
    fi

    function _read_value() {
        grep -qoe "^$1: " "$cMETADATA_FILE" || { echo "error: metadata field '$1' not defined"; exit 8; }
        declare -g -x "$2"="$(grep -e "^$1: " "$cMETADATA_FILE" | sed "s/^$1: //")"
        [[ -z "${!2}" ]] && { echo "error: metadata field '$1' is empty"; exit 8; }
        [[ "$quiet" != true ]] && echo "$1: ${!2}"
        cMETADATA["$1"]="${!2}"
    }

    _read_value "name" "cNAME"
    _read_value "nameStyled" "cNAME_STYLED"
    _read_value "version" "cVERSION"
    _read_value "description" "cDESCRIPTION"
    _read_value "author" "cAUTHOR"
    _read_value "mainLicenseSpdx" "cLICENSE"
    _read_value "extraGalleryPages" "cEXTRA_GALLERY_PAGES"

    cMETADATA["fullName"]="$cOPAL_PREFIX$cNAME"
    cMETADATA["fullNameStyled"]="$cOPAL_PREFIX_STYLED$cNAME_STYLED"
}

function parse_arguments() { # @: all shell arguments given to release-module.sh
    function _show_help() {
        echo "\
** $0 **

Create Opal module release bundles.

Usage: $0 [-b OUTNAME] [-h] [-V]

Arguments:
    -b, --bundle OUTNAME - write bundle to \"$cBUILD_DIR/\$OUTNAME.tar.gz\" instead of
                           using an automatically generated name
    -c, --config KEY     - get value of metadata field KEY
    -h, --help           - show this help and exit
    -V, --version        - show version and license information
"
    }

    function _version() {
        printf "opal-release-module.sh\nCopyright (c) 2018-2021 Mirian Margiani -- CC-BY-SA-4.0\n"
        printf "version %s\n" "$c__OPAL_RELEASE_MODULE_VERSION__"
        read_metadata quiet
        printf "\nFOR MODULE: %s (%s), version %s\n" \
            "${cMETADATA[fullName]}" "${cMETADATA[fullNameStyled]}" "$cVERSION"
    }

    while (( $# > 0 )); do
        case "$1" in
            --help|-h) _show_help; exit 0;;
            --version|-V) _version; exit 0;;
            --bundle|-b) shift && [[ -z "$1" ]] && echo "error: OUTNAME is missing" && exit 9
                declare -g -x cCUSTOM_BUNDLE_NAME="$1"
            ;;
            --config|-c)
                shift && read_metadata quiet
                if [[ -n "$1" ]]; then
                    [[ -n "${cMETADATA["$1"]}" ]] && printf "%s\n" "${cMETADATA["$1"]}" || exit 1
                else
                    for i in "${!cMETADATA[@]}"; do
                        printf "%s\n" "$i: ${cMETADATA["$i"]}"
                    done
                fi
                exit 0
            ;;
            -*) printf "unknown option: %s\n" "$1";;
            *) shift; continue;;
        esac
        shift
    done
}

function setup_translations() {
    local back_dir="$(pwd)"
    read_metadata

    local do_translate=true
    if (( "${#cTRANSLATE[@]}" == 0 )); then
        echo "error: no translations defined"
        exit 4
    fi

    mkdir -p "$cTR_DIR" || { echo "error: failed to prepare translations directory"; exit 1; }
    "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -ts "$cTR_DIR/$cNAME.ts"
    success="$?"

    cd "$back_dir"
    exit "$success"
}

function build_bundle() {
    local back_dir="$(pwd)"
    read_metadata

    if ! type copy_files &>/dev/null; then
        echo "error: copy_files function not defined"
        exit 255
    fi

    local do_translate=true
    if (( "${#cTRANSLATE[@]}" == 0 )); then
        echo "note: no translations defined"
        do_translate=false
    fi

    if [[ -z "$cBUILD_DIR" ]]; then
        echo "error: no build directory specified"
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
    local qml_base="$build_root/qml/opal-modules"
    local tr_base="$build_root/libs/opal-translations/${cMETADATA[fullName]}"
    local meta_base="$build_root/libs"
    # local plugin_base="$build_root/TODO"

    mkdir -p "$cBUILD_DIR" || { echo "error: failed to create base build directory"; exit 1; }
    rm -rf "$build_root" || { echo "error: failed to clear build root"; exit 1; }
    mkdir -p "$build_root" || { echo "error: failed to create build root"; exit 1; }
    mkdir -p "$meta_base" "$qml_base" "$tr_base" || { echo "error: failed to prepare build root"; exit 1; }
    # mkdir -p "$plugin_base" || { echo "error: failed to prepare plugin base directory"; exit 1; }

    if [[ "$do_translate" == true ]]; then
        # Update translation catalogs
        "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -ts "$cTR_DIR/"*.ts || {
            echo "error: failed to update translations"; exit 3
        }
    fi

    # Make build paths available for copy_files()
    BUILD_ROOT="$build_root"
    QML_BASE="$qml_base"

    # Import distribution files
    if [[ "$do_translate" == true ]]; then
        cp "$cTR_DIR/"*.ts "$tr_base" || { echo "error: failed to prepare translations"; exit 1; }
    fi
    copy_files || { echo "error: failed to prepare sources"; exit 1; }

    # Write metadata file
    local metadata_file="$meta_base/module_${cMETADATA[fullName]}.txt"
    printf "%s\n" "# Store this file to keep track of packaged module versions." \
                  "# It is not necessary to include this in your app's final RPM package." \
                  "# SPDX-FileCopyrightText: ${cMETADATA[fullNameStyled]} contributors" \
                  "# SPDX-License-Identifier: $cLICENSE" "" \
        > "$metadata_file"
    printf "%s: %s\n" \
           "module" "${cMETADATA[fullNameStyled]} (${cMETADATA[fullName]})" \
           "version" "$cVERSION${commit:+" (git:$commit)"}" \
           "description" "$cDESCRIPTION" \
           "author" "$cAUTHOR" \
           "license" "$cLICENSE" \
           "sources" "https://github.com/Pretty-SFOS/${cMETADATA[fullName]}" \
        >> "$metadata_file"

    # Create final package
    cd "$cBUILD_DIR"
    local package="${cMETADATA[fullName]}-$version${commit:+"-$commit"}"
    local bundle_name="${cCUSTOM_BUNDLE_NAME:-"$package"}.tar.gz"
    tar -czvf "$bundle_name" "$build_root_name" || {
        echo "error: failed to create package"
        exit 2
    }
    rm -rf "$build_root_name"  # clear build root

    cd "$back_dir"
}

function build_doc() {
    local back_dir="$(pwd)"
    read_metadata

    export QT_INSTALL_DOCS="${QT_INSTALL_DOCS:="$("$cQMAKE_BIN" -query QT_INSTALL_DOCS)"}"
    export QT_VERSION="${QT_VERSION:="$("$cQMAKE_BIN" -query QT_VERSION)"}"
    export QT_VER="${QT_VERSION:="$("$cQMAKE_BIN" -query QT_VERSION)"}"

    export OPAL_PROJECT="${OPAL_PROJECT:=${cMETADATA[fullName]}}"
    export OPAL_PROJECT_STYLED="${OPAL_PROJECT_STYLED:=${cMETADATA[fullNameStyled]}}"
    export OPAL_PROJECT_VERSION="${OPAL_PROJECT_VERSION:=$cVERSION}"
    export OPAL_PROJECT_EXAMPLESDIR="${OPAL_PROJECT_EXAMPLESDIR:=$cEXAMPLES_DIR}"
    export OPAL_PROJECT_DOCDIR="${OPAL_PROJECT_DOCDIR:=$cDOC_DIR}"
    export OPAL_DOC_OUTDIR="${OPAL_DOC_OUTDIR:=$cBUILD_DOC_DIR}"

    "$cQDOC_BIN" --highlighting -I "$cDOC_DIR" "$OPAL_PROJECT.qdocconf" || { echo "error: failed to generate docs"; exit 1; }
    cd "$cBUILD_DOC_DIR" || { echo "error: failed to enter doc directory"; exit 1; }
    "$cQHG_BIN" "$OPAL_PROJECT.qhp" -c -o "$OPAL_PROJECT.qch" || { echo "error: failed to generate Qt help pages"; exit 1; }

    cd "$back_dir"
}
