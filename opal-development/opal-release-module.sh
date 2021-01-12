#!/bin/bash
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2018-2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/master/opal-development/opal-release-module.md
# for documentation.

shopt -s extglob

cLUPDATE_BIN=${cLUPDATE_BIN:-lupdate-qt5}
cTR_DIR=translations

cDEPENDENCIES=("$cLUPDATE_BIN")

function check_dependencies() {
    for dep in "${cDEPENDENCIES[@]}"; do
        if ! which "$dep" 2> /dev/null >&2; then
            printf "error: %s is required\n" "$dep"
            exit 1
        fi
    done
}

# check dependencies immediately after loading the script
# If the user changes cDEPENDENCIES later, they can re-run this command.
check_dependencies

function setup_translations() {
    if [[ -z "$cNAME" ]]; then
        echo "error: no module name provided"
        exit 3
    fi

    local do_translate=true
    if (( "${#cTRANSLATE[@]}" == 0 )); then
        echo "error: no translations defined"
        exit 4
    fi

    mkdir -p "$cTR_DIR" || { echo "error: failed to prepare translations directory"; exit 1; }
    "$cLUPDATE_BIN" "${cTRANSLATE[@]}" -ts "$cTR_DIR/$cNAME.ts"
    exit $?
}

function build_bundle() {
    if [[ -z "$cNAME" ]]; then
        echo "error: no module name provided"
        exit 2
    fi

    if ! type copy_files &>/dev/null; then
        echo "error: copy_files function not defined"
        exit 255
    fi

    local do_translate=true
    if (( "${#cTRANSLATE[@]}" == 0 )); then
        echo "note: no translations defined"
        do_translate=false
    fi

    # Prepare version number from git tag, using current date and current commit
    # as fallback values
    local version
    if ! git describe --tags 2>/dev/null >/dev/null; then
        version="v$(date +%F)"
        if git rev-parse --short HEAD --verify 2>/dev/null >/dev/null; then
            version="$version-$(git rev-parse --short HEAD --verify)"
        fi
    else
        version="v$(git describe --tags | sed 's/^v//g')"
    fi

    # Setup base paths
    local package="$cNAME-$version"
    local build_parent="build"
    local build_root="$build_parent/$package"
    local qml_base="$build_root/qml/opal-modules"
    local tr_base="$build_root/libs/opal-translations/$cNAME"
    # local plugin_base="$build_root/TODO"

    mkdir -p "$build_parent" || { echo "error: failed to create base build directory"; exit 1; }
    rm -rf "$build_root" || { echo "error: failed to clear build root"; exit 1; }
    mkdir -p "$build_root" || { echo "error: failed to create build root"; exit 1; }
    mkdir -p "$qml_base" "$tr_base" || { echo "error: failed to prepare build root"; exit 1; }
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

    # Create final package
    cd "$build_parent"
    tar -czvf "$package.tar.gz" "$package" || {
        echo "error: failed to create package"
        exit 2
    }
    rm -rf "$package"  # clear build root
}
