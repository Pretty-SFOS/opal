#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021-2024 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-release-module.md
# for documentation.
#
# @@@ keep this line: based on template v0.8.0
#
c__FOR_RELEASE_LIB__="0.8.0"

# Run this script from the module's root directory.
source ../opal/opal-development/opal-release-module.sh
parse_arguments "$@"

# Copy and edit this template file for new Opal modules.
# Module metadata will be read from doc/module.opal.

# Important directories:
#
# .                     - root directory of the module
# ├── build             - (generated) build output directory
# ├── build-doc         - (generated) documentation output directory
# ├── doc               - module metadata and documentation
# ├── Opal              - QML module root
# │   └── MyModule      - public QML files
# │       └── private   - private QML files
# └── src               - C++ source root
#     └── mymodule      - public C++ source and header files
#         └── private   - private C++ files

# Define in cTRANSLATE which files and directories must be scanned for
# translatable string. Note: translations are built from the original sources,
# independent of the files marked for distribution in copy_files.
cTRANSLATE=(Opal)  # options: "Opal" and/or "src"

# Edit the copy_files() function if any additional copy steps are necessary. By
# default, documentation is generated, and QML and C++ sources will be copied. It
# might be necessary to exclude certain files that are not meant for distribution.
# Use BUILD_ROOT, QML_BASE, SRC_BASE, and DOC_BASE (below BUILD_ROOT) to define
# target paths.
#
# Note: put additional strings to be translated in the special file
# "Opal/<YourModule>/private/ExtraTranslations.qml". This is a dummy file that
# will not be included in the tarball but will be used as source for translations.
function copy_files() {
    build_qdoc to="$DOC_BASE"
    [[ -d Opal ]] && { cp -r Opal --target-directory="$QML_BASE"    || return 1; } || true
    [[ -d src  ]] && { cp -r src  --no-target-directory "$SRC_BASE" || return 1; } || true
}

# build the bundle
build_bundle
