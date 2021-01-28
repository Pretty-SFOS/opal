#!/bin/bash
#
# This file is part of Opal and has been released under the Creative Commons
# Attribution-ShareAlike 4.0 International License.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: 2018-2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/main/snippets/opal-render-icons.md
# for documentation.

shopt -s extglob

cFIELD_INDICATOR="F"
cFILE_SUFFIX="svg"
cRESOLUTION_CHECK='^[0-9]+$'
cDEPENDENCIES=(inkscape pngcrush)

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

function do_render_single() { # 1: input, 2: width, 3: height, 4: output
    # replace '-o' by '-z -e' for inkscape < 1.0
    inkscape -o "$4" -w "$2" -h "$3" "$1" && pngcrush -ow "$4"
}

function split_at_sign() { # 1: string with values separated by @, |, +
    unset OPAL_SPLIT_RES

    if [[ -n "$2" ]]; then
        if [[ "$2" =~ ^[@|+]$ ]]; then
            split="$2"
        else
            printf "error: invalid split character '%s'" "$2"
            exit 255
        fi
    else
        split="@"
    fi

    mapfile -d $'\0' -t OPAL_SPLIT_RES < <(printf "%s" "$@" | sed "s/\\$split/__SIGN_REPLACED__/g;" |\
                                           tr "$split" '\0' | sed "s/__SIGN_REPLACED__/$split/g")
}

function render_batch() { # 1: keep or unset config after rendering?
    # no arguments required, all info has to be set as variables
    keep_config="$1"  # 'keep' or empty

    printf "rendering %s...\n" "$cNAME"
    local use_res use_loc source target

    for item in "${cITEMS[@]}"; do
        split_at_sign "$item" "@"
        item_split=("${OPAL_SPLIT_RES[@]}")
        source="${item_split[0]}.$cFILE_SUFFIX"

        if [[ ! -f "$source" ]]; then
            printf "error: source item '%s' not found\n" "$source"
            continue
        fi

        if [[ "$cRESOLUTIONS" == ${cFIELD_INDICATOR}* ]]; then
            split_at_sign "${item_split[${cRESOLUTIONS#$cFIELD_INDICATOR}]}" "|"  # format: res[|res[|...]]
            use_res=("${OPAL_SPLIT_RES[@]}")
        else
            use_res=("${cRESOLUTIONS[@]}")
        fi

        if [[ "$cTARGETS" == ${cFIELD_INDICATOR}* ]]; then
            split_at_sign "${item_split[${cTARGETS#$cFIELD_INDICATOR}]}" "|"  # format: loc[|loc[|...]]
            use_loc=("${OPAL_SPLIT_RES[@]}")
        else
            use_loc=("${cTARGETS[@]}")
        fi

        for res in "${use_res[@]}"; do
            split_at_sign "$res" "+"  # format: X[xY][+prefix[+suffix]]
            res_split=("${OPAL_SPLIT_RES[@]}")
            local res_x="${res_split[0]}"
            local res_y="${res_split[0]}"

            if [[ "$res" == *x* ]]; then
                res_x="${res%%x*}"
                res_y="${res##*x}"
            fi

            if [[ ! "$res_x" =~ $cRESOLUTION_CHECK ]]; then
                printf "error: x-resolution '$res_x' is not a number\n"
                continue
            fi

            if [[ ! "$res_y" =~ $cRESOLUTION_CHECK ]]; then
                printf "error: y-resolution '$res_y' is not a number\n"
                continue
            fi

            for loc in "${use_loc[@]}"; do
                loc="$(printf "%s" "$loc" | sed "s/RESX/${res_x}/g; s/RESY/${res_y}/g")"

                mkdir -p "$loc" || {
                    printf "error: failed to create target directory '%s'\n" "$loc"
                    continue
                }

                # target = <target location/<main prefix><prefix><basename><suffix><main suffix>.png
                local prefix="${res_split[1]}"
                local suffix="${res_split[2]}"
                target="$(printf "%s" "$loc/$cPREFIX$prefix$(basename "$source")" | sed "s/\.$cFILE_SUFFIX$//I")$suffix$cSUFFIX.png"
                if [[ "$source" -nt "$target" ]] || [[ "$cFORCE" == true ]]; then
                    do_render_single "$source" "$res_x" "$res_y" "$target" || {
                        printf "error: failed to render '%s' at %sx%s\n" "$source" "$res_x" "$res_y"
                        continue
                    }
                else
                    printf "nothing to be done for '%s' at %sx%s\n" "$source" "$res_x" "$res_y"
                    continue
                fi
            done
        done
    done

    if [[ "$keep_config" != "keep" ]]; then
        unset cNAME cITEMS cRESOLUTIONS cTARGETS cSUFFIX cPREFIX
        # cFORCE is always preserved
    fi
}
