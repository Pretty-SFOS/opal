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

c__OPAL_RELEASE_MODULE_VERSION__="0.8.0"
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

[[ ! -v "$cDEPENDENCIES" ]] && cDEPENDENCIES=()
cDEPENDENCIES+=("$cLUPDATE_BIN" "$cQDOC_BIN" "$cQMAKE_BIN" "$cQHG_BIN" "$cQMLMIN_BIN")

function check_dependencies() {
    [[ ! -v "$cDEPENDENCIES" ]] && cDEPENDENCIES=()
    for dep in "${cDEPENDENCIES[@]}"; do
        if ! which "$dep" 2> /dev/null >&2; then
            printf "error: %s is required\n" "$dep" >&2
            exit 1
        fi
    done
}

function log() {
    IFS=' ' printf -- "%s\n" "$*" >&2
}

function verify_version() {
    # @@@ shared function version: 1.1.0
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
    local patch="${!user_version_var##*.}"

    local opal_major="${!opal_version_var%%.*}"
    local opal_minor="${!opal_version_var#*.}"; opal_minor="${opal_minor%.*}"
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
# If the user changes cDEPENDENCIES later, they can re-run this command.
check_dependencies >/dev/stderr

function read_metadata() {
    [[ "$1" == quiet ]] && local quiet=true
    declare -g -x -A cMETADATA

    if [[ ! -f "$cMETADATA_FILE" ]]; then
        log "error: module metadata file not found at '$cMETADATA_FILE'"
        exit 8
    fi

    function _read_value() {
        grep -qoe "^$1: " "$cMETADATA_FILE" || { log "error: metadata field '$1' not defined"; exit 8; }
        declare -g -x "$2"="$(grep -e "^$1: " "$cMETADATA_FILE" | sed "s/^$1: //")"
        [[ -z "${!2}" ]] && { log "error: metadata field '$1' is empty"; exit 8; }
        [[ "$quiet" != true ]] && echo "$1: ${!2}"
        cMETADATA["$1"]="${!2}"
    }

    _read_value "name" "cNAME"
    _read_value "nameStyled" "cNAME_STYLED"
    _read_value "version" "cVERSION"
    _read_value "description" "cDESCRIPTION"
    _read_value "authors" "cAUTHORS"
    _read_value "maintainers" "cMAINTAINERS"
    _read_value "attribution" "cATTRIBUTION"
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
    -n, --no-minify      - disable QML minification, i.e. keep all QML files as they are
    -h, --help           - show this help and exit
    -V, --version        - show version and license information
"
    }

    function _version() {
        printf "opal-release-module.sh\nCopyright (c) 2018-2023 Mirian Margiani -- CC-BY-SA-4.0\n"
        printf "version %s\n" "$c__OPAL_RELEASE_MODULE_VERSION__"
        read_metadata quiet
        printf "\nFOR MODULE: %s (%s), version %s\n" \
            "${cMETADATA[fullName]}" "${cMETADATA[fullNameStyled]}" "$cVERSION"
    }

    while (( $# > 0 )); do
        case "$1" in
            --help|-h) _show_help; exit 0;;
            --version|-V) _version; exit 0;;
            --bundle|-b) shift && [[ -z "$1" ]] && log "error: OUTNAME is missing" && exit 9
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
            --no-minify|-n)
                declare -g cENABLE_MINIFY=false
            ;;
            -*) printf "unknown option: %s\n" "$1";;
            *) shift; continue;;
        esac
        shift
    done
}

function build_qdoc() { # 1: to=/path/to/output/dir
    # If $1 is to=/path/to/output/dir, the generated help file will be copied
    # to the given directory.

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

    "$cQDOC_BIN" --highlighting -I "$cDOC_DIR" -I "$OPAL_PROJECT_DOCDIR" "$cDOC_DIR/$OPAL_PROJECT.qdocconf" || { log "error: failed to generate docs"; exit 1; }
    cd "$cBUILD_DOC_DIR" || { log "error: failed to enter doc directory"; exit 1; }
    "$cQHG_BIN" "$OPAL_PROJECT.qhp" -c -o "$OPAL_PROJECT.qch" || { log "error: failed to generate Qt help pages"; exit 1; }

    cd "$back_dir"

    if [[ "$1" == "to="* ]]; then
        local copy_to="${1#to=}"
        mkdir -p "$copy_to" || { log "error: failed to prepare output directory"; exit 1; }
        cp "$cBUILD_DOC_DIR/$OPAL_PROJECT.qch" "$copy_to" || { log "error: failed to copy generated docs"; exit 1; }
    fi
}

function build_bundle() {
    local back_dir="$(pwd)"
    read_metadata

    if ! type copy_files &>/dev/null; then
        log "error: copy_files function not defined"
        exit 255
    fi

    local do_translate=true
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

    mkdir -p "$cBUILD_DIR" || { log "error: failed to create base build directory"; exit 1; }
    rm -rf "$build_root" || { log "error: failed to clear build root"; exit 1; }
    mkdir -p "$build_root" || { log "error: failed to create build root"; exit 1; }
    mkdir -p "$meta_base" "$qml_base" "$doc_base" "$src_base" || {
        log "error: failed to prepare build root"
        exit 1
    }

    if [[ "$do_translate" == true ]]; then
        mkdir -p "$tr_base" || {
            log "error: failed to prepare translations directory in build root"
            exit 1
        }
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
        "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -ts "$cTR_DIR/"*.ts || {
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
    printf "%s\n" \
        "//@ This file is part of ${cMETADATA[fullName]}." \
        "//@ https://github.com/Pretty-SFOS/${cMETADATA[fullName]}" \
        "//@ SPDX-FileCopyrightText: $cATTRIBUTION" \
        "//@ SPDX-License-Identifier: $cLICENSE" \
        "" \
        "import \"../../Opal/About\" as A" \
        "A.Attribution {" \
        "    name: \"${cMETADATA[fullNameStyled]} (v${cMETADATA[version]})\"" \
        "    entries: \"$cATTRIBUTION\"" \
        "    licenses: A.License { spdxId: \"$cLICENSE\"}" \
        "    sources: \"https://github.com/Pretty-SFOS/${cMETADATA[fullName]}\"" \
        "    homepage: \"https://github.com/Pretty-SFOS/opal\"" \
        "}" "" > "$qml_base/Opal/Attributions/${cMETADATA[fullNameStyled]//./}Attribution.qml"
    # REUSE-IgnoreEnd

    # Make build paths available for copy_files()
    local BUILD_ROOT="$build_root"
    local QML_BASE="$qml_base"
    local DOC_BASE="$doc_base"
    local SRC_BASE="$src_base"

    # Import distribution files
    if [[ "$do_translate" == true ]]; then
        cp "$cTR_DIR/"*.ts "$tr_base" || { log "error: failed to prepare translations"; exit 1; }
    fi

    copy_files || { log "error: failed to prepare sources"; exit 1; }

    # Remove the extra translations dummy file from the release bundle, as translations
    # are built separately and are merged if needed.
    rm -f "$qml_base/Opal/${cMETADATA[nameStyled]}/private/ExtraTranslations.qml" || true

    # Remove the private directory if it remains empty after the extra translations
    # file has been removed.
    rmdir --ignore-fail-on-non-empty "$qml_base/Opal/${cMETADATA[nameStyled]}/private"

    unset BUILD_ROOT QML_BASE DOC_BASE

    # Strip comments from dist files
    if [[ -z "$cENABLE_MINIFY" || "$cENABLE_MINIFY" == true ]]; then
        shopt -s nullglob extglob
        local temp="$(mktemp)"
        mapfile -d $'\0' -t files_to_strip < <(find "$qml_base" -iregex ".*\.\(qml\|js\)" -type "f" -print0)

        for i in "${files_to_strip[@]}"; do
            keep="$(grep -Ee '^//@' "$i")"
            if [[ "$keep" != "" ]]; then
                printf -- "%s\n" "$keep" > "$temp"
            fi

            if grep -qoe ';' "$i"; then
                log "warning: file '$i' contains at least one semicolon"
                log "         This breaks minification. Make sure there are no semicolons and try again."
                continue
            fi

            "$cQMLMIN_BIN" "$i" | tr ';' '\n' >> "$temp"

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

        cat <<"EOF" > "$qmake_include_file"
# This file is part of Opal.
# SPDX-FileCopyrightText: 2023-2024 Mirian Margiani
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

# Make headers available for inclusion
INCLUDEPATH += $$relative_path($$PWD/opal)

# Search for any project include files and include them now
message(Searching for Opal source modules...)

OPAL_SOURCE_MODULES = $$files($$PWD/opal/*)
for (module, OPAL_SOURCE_MODULES) {
    module_includes = $$files($$module/*.pri)

    for (to_include, module_includes) {
        message(Enabling Opal source module <libs/$$relative_path($$dirname(to_include))>)
        include($$to_include)
    }
}
EOF
    fi

    # Write metadata file
    # REUSE-IgnoreStart
    local metadata_file="$meta_base/module_${cMETADATA[fullName]}.txt"
    printf "%s\n" "# Store this file to keep track of packaged module versions." \
                  "# It is not necessary to ship this in your app's final RPM package." \
                  "# SPDX-FileCopyrightText: $cATTRIBUTION" \
                  "# SPDX-License-Identifier: $cLICENSE" "" \
        > "$metadata_file"
    # REUSE-IgnoreEnd
    printf "%s\n" "# Attribution using Opal.About:" \
                  "#    1. Import \"../modules/Opal/Attributions\" in your “About” page." \
                  "#    2. Attribute this module by adding \"${cMETADATA[fullNameStyled]//./}Attribution {}\"" \
                  "#       to the \"attributions\" list property of the “About” page." \
                  "" \
        >> "$metadata_file"
    printf "%s: %s\n" \
           "module" "${cMETADATA[fullNameStyled]} (${cMETADATA[fullName]})" \
           "version" "$cVERSION${commit:+" (git:$commit)"}" \
           "description" "$cDESCRIPTION" \
           "maintainers" "$cMAINTAINERS" \
           "attribution" "$cATTRIBUTION" \
           "license" "$cLICENSE" \
           "sources" "https://github.com/Pretty-SFOS/${cMETADATA[fullName]}" \
        >> "$metadata_file"

    # Create final package
    cd "$cBUILD_DIR"
    local package="${cMETADATA[fullName]}-$version${commit:+"-$commit"}"
    local bundle_name="${cCUSTOM_BUNDLE_NAME:-"$package"}.tar.gz"
    tar --mode="u+rwX,a+rX" --numeric-owner --owner=0 --group=0 -czvf "$bundle_name" "$build_root_name" || {
        log "error: failed to create package"
        exit 2
    }
    rm -rf "$build_root_name"  # clear build root

    cd "$back_dir"
}
