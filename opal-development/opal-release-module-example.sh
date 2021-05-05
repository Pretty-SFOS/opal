#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-release-module.md
# for documentation.
#
# @@@ keep this line: based on template v0.3.0
#
c__FOR_RELEASE_LIB__="0.3.0"

# Run this script from the module's root directory.
source ../opal/opal-development/opal-release-module.sh
parse_arguments "$@"

# Copy and edit this template file for new Opal modules.
# Module metadata will be read from doc/module.opal.
# Note: modules requiring extra build steps (Qt plugins) are not yet supported.

# which files and directories to translate
cTRANSLATE=(Opal)

# un-comment the following line to initially setup translations
# setup_translations

# Edit the copy_files() function if any additional copy steps are necessary.
# By default, the main Opal directory will be copied with all contents. It might
# be necessary to exclude certain files that are not meant for distribution.
# Use BUILD_ROOT and QML_BASE (below BUILD_ROOT) to define target paths.
function copy_files() {
    cp -r Opal "$QML_BASE/Opal" || return 1
}

# build the bundle
build_bundle

# build documentation
build_doc
