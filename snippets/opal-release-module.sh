#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/master/snippets/opal-release-module.md
# for documentation.

# ------------------------------------------------------------------------------
# Copy and edit this template file for new Opal modules.
# NOTE This script only supports QML-only modules.
NAME=opal-mymodule  # the module's name
TRANSLATE=(Opal)    # which files and directories to translate
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Un-comment the following line to initially setup translations:
# mkdir translations && lupdate-qt5 Opal -ts "translations/$NAME.ts" && exit 0
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Edit the copy_files() function if any additional copy steps are necessary.
# By default, the main Opal directory will be copied with all contents. It might
# be necessary to exclude certain files that are not meant for distribution.
function copy_files() {
    cp -r Opal "$QML_BASE/Opal" || return 1
}
# ------------------------------------------------------------------------------

# Prepare version number from git tag, using current date and current commit
# as fallback values
if ! git describe --tags 2>/dev/null >/dev/null; then
    VERSION="v$(date +%F)"
    if git rev-parse --short HEAD --verify 2>/dev/null >/dev/null; then
        VERSION="$VERSION-$(git rev-parse --short HEAD --verify)"
    fi
else
    VERSION="v$(git describe --tags | sed 's/^v//g')"
fi

# Setup base paths
PACKAGE="$NAME-$VERSION"
BUILD_PARENT="build"
BUILD_ROOT="$BUILD_PARENT/$PACKAGE"
QML_BASE="$BUILD_ROOT/qml/opal-modules"
TR_BASE="$BUILD_ROOT/libs/opal-translations"
# PLUGIN_BASE="$BUILD_ROOT/TODO"

mkdir -p "$BUILD_PARENT" || { echo "error: failed to create base build directory"; exit 1; }
rm -rf "$BUILD_ROOT" || { echo "error: failed to clear build root"; exit 1; }
mkdir -p "$BUILD_ROOT" || { echo "error: failed to create build root"; exit 1; }
mkdir -p "$QML_BASE" "$TR_BASE" || { echo "error: failed to prepare build root"; exit 1; }
# mkdir -p "$PLUGIN_BASE" || { echo "error: failed to prepare plugin base directory"; exit 1; }

# Update translation catalogs
lupdate-qt5 "${TRANSLATE[@]}" -ts translations/*.ts || {
    echo "error: failed to update translations"; exit 3
}

# Import distribution files
cp translations/*.ts "$TR_BASE" || { echo "error: failed to prepare translations"; exit 1; }
copy_files || { echo "error: failed to prepare sources"; exit 1; }

# Create final package
cd "$BUILD_PARENT"
tar -czvf "$PACKAGE.tar.gz" "$PACKAGE" || {
    echo "error: failed to create package"
    exit 2
}
rm -rf "$PACKAGE"  # clear build root
