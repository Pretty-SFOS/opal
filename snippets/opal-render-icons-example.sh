#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal/blob/master/snippets/opal-render-icons.md
# for documentation.

# Run this script from the same directory where your icon sources are located,
# e.g. <app>/icon-src.

source ../libs/opal-render-icons.sh
cFORCE=false

cNAME="app icons"
cITEMS=(harbour-myapp)
cRESOLUTIONS=(86 108 128 172)
cTARGETS=(../icons/RESXxRESY)
render_batch

cNAME="status icons"
cITEMS=(status/{icon-todo,icon-ignored,icon-done}@112
        status/{icon-todo,icon-ignored,icon-done}@24++-small
        harbour-myapp@256
)
cRESOLUTIONS=(F1)
cTARGETS=(../qml/images)
render_batch
