<!--
SPDX-FileCopyrightText: 2021-2025 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Create Opal module distribution bundles

Each module has a [release script](https://github.com/Pretty-SFOS/opal-module-template/blob/main/release-module.sh)
called `release-module.sh` that is used to build the release bundle, generate
documentation, and provide access to a module's metadata for scripting.

Read the comments in the release script for customization options. It is usually
not necessary to modify the release script.

The [opal-release-module.sh](opal-release-module.sh) script is a library providing functions for
building and packaging Opal modules. It is used internally by the release script.
