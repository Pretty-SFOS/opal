<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Verify script and library version compatibility

The [opal-verify-version.sh] script is a shared function for verifying that a
(template) script is compatible with the available Opal library script it builds
on. The function can be copied to new library scripts.

Two variables are considered:

    # Name of the variable that has to be provided by a user's script
    # e.g. c__FOR_RELEASE_LIB__. This specifys version compatibility, e.g '1.0.0'.
    local user_version_var="c__FOR_RELEASE_LIB__"

    # Name of the library's version variable.
    local opal_version_var="c__OPAL_RELEASE_MODULE_VERSION__"
