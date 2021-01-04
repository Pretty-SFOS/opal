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

if ! git describe --tags 2>/dev/null >/dev/null; then
    VERSION="v$(date +%F)"
    if git rev-parse --short HEAD --verify 2>/dev/null >/dev/null; then
        VERSION="$VERSION-$(git rev-parse --short HEAD --verify)"
    fi
else
    VERSION="v$(git describe --tags | sed 's/^v//g')"
fi

PACKAGE="$NAME-$VERSION"

lupdate-qt5 "${TRANSLATE[@]}" -ts translations/*.ts || {
    echo "error: failed to update translations"
    exit 3
}

mkdir -p build || { echo "error: failed to create build directory"; exit 1; }
rm -rf "build/$PACKAGE" || { echo "error: failed to clear build root"; exit 1; }
mkdir -p "build/$PACKAGE"/{opal-translations,opal-modules} || { echo "error: failed to prepare build root"; exit 1; }
cp translations/*.ts "build/$PACKAGE/opal-translations" || { echo "error: failed to prepare translations"; exit 1; }

# ------------------------------------------------------------------------------
# Edit the copy_files function if any additional copy steps are necessary.
# By default, the main Opal directory will be copied with all contents. It might
# be necessary to exclude certain files that are not meant for distribution.
function copy_files() {
    cp -r Opal "build/$PACKAGE/opal-modules/Opal" || return 1
}
copy_files || { echo "error: failed to prepare sources"; exit 1; }
# ------------------------------------------------------------------------------

cd build
tar -czvf "$PACKAGE.tar.gz" "$PACKAGE" || {
    echo "error: failed to create package"
    exit 2
}

rm -rf "$PACKAGE"  # build root
