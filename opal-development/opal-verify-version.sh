# This is a template and requires configuration.
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/opal-development/opal-verify-version.md
# for documentation.
#
# @@@ FILE VERSION see verify_version
#

function verify_version() {
    # @@@ shared function version: 1.0.0
    local user_version_var="c__FOR_XXXXX_LIB__"
    local opal_version_var="c__OPAL_XXXXX_VERSION__"

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
