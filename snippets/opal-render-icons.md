<!--
SPDX-FileCopyrightText: 2021-2023 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Rendering script for SVG icons

The [opal-render-icons.sh](opal-render-icons.sh) script provides a
`render_batch` function for quickly rendering any kind of SVG icons to PNG. The
rendered files can then be included in your distribution.

This is very useful during iterative development, when you have to re-render
graphics many times until they look the right way *on the device*.

It also reduces the distribution RPM's file size significantly. The script
automatically runs `pngcrush` on the rendered icons, reducing file size even
more.

## Cleaning SVG files

You can use the `scour` command to only include clean SVG files in your code
repository. The command reduces file size and removes potentially sensitive or
personal metadata from SVG files.

```bash
# use the 'raw' directory for development but don't commit it to VCS
for i in raw/*.svg; do
    if [[ "$i" -nt "${i#raw/}" ]]; then
        scour "$i" > "${i#raw/}"
    fi
done

# in one line
for i in raw/*.svg; do [[ "$i" -nt "${i#raw/}" ]] && scour "$i" > "${i#raw/}"; done
```

## How to use the script

You can use the [opal-render-icons-example.sh](opal-render-icons-example.sh)
script to quickly get you started.

The [opal-render-icons.sh](opal-render-icons.sh) script has to be "sourced" from
your own rendering script, where you define what will be rendered.

```bash
source opal-render-icons.sh
cFORCE=false  # set this to 'true' to always re-render all items
```

Items will be rendered in batches. Call `render_batch` after defining a batch,
then define the next one, and so on. All config values (except for `cFORCE`)
will be reset after rendering a batch. Call `render_batch keep` to keep them.

```bash
# the current batch's name for logging
cNAME="complex images"

# the list of items in this batch
# Items can be defined as strings of one or multiple fields. Fields are
# separated by '@'. The basic use case is to define only the base name of an
# icon source file. Other fields can contain custom resolutions or custom
# target paths. Do not include suffixes in the name (exclude '.svg').
# Note that all items of a batch must have the same number of fields. Either
# all items are custom or all items share the same properties. (See below.)
#
# Fields are interpreted the same way they would if specified globally.
# See cRESOLUTIONS and cTARGETS for details. Fields can hold multiple values
# separated by a vertical bar ('|').
#
# For example:
# cITEMS=(simple-icon) -- use resolutions from cRESOLUTIONS
# cITEMS=(tiny@1|10+big-) -- render at 1x1 and 10x10, with cRESOLUTIONS=(F1)
# and so on
cITEMS=(complex/big-one@211x1020@../qml/images/complex/big
        complex/big-one@5x11@../qml/images/complex/small
        simple/icon@100@../qml/images
)

# the resolutions in which items will be rendered
# This array can either hold a list of resolutions at which the icons of the
# current batch will be rendered, or it can hold a field number.
# Use 'F1' to indicate that items should be rendered at the resolution specified
# in field 1, e.g. 'item-name@RESOLUTION'. (You can just as well use 'F2'...)
#
# Format: X[xY][+prefix[+suffix]]
# Width (X) and height (Y) can be specified separately, else the rendered image
# is square (width x width). You can optionally define a prefix and/or a suffix.
# These will be added to the final filename.
#
# Suffix/prefix values are needed when rendering multiple resolutions of the
# same icon to the same target location. Files would otherwise be overwritten.
#
# (100x200) -- render at 100x200
# (1x2 1x4 5) -- render at 1x2, 1x4, and 5x5
# (1+small- 2) -- render at 1x1 (prefix: "small-") and 2x2 (no prefix)
# (3x1++-wide) -- render at 3x1 with suffix "-wide"
cRESOLUTIONS=(F1)

# the target paths where rendered items will be placed
# The values are interpreted the same way as cRESOLUTIONS, except .
#
# Any occurrence of 'RESX' and 'RESY' will be replaced by the corresponding
# resolution. You can use '../icons/RESXxRESY' to render items to
# sub-directories depending on their resolution.
cTARGETS=(F2)

# optional: main suffix and prefix to be used before and after any suffix
# defined with resolutions.
cSUFFIX=-main-suffix
cPREFIX=main-prefix-

# finally: render the batch
render_batch
```

## Limitations

The library does not support changing the output file name. In other words, all
output files will have the same name as their source files (plus any
prefix/suffix).

Output files will be named like this:

    <target location/<main prefix><prefix><basename><suffix><main suffix>.png

Each part of this path can be changed, except for `<basename>`. This is
an intentional limitation to make file relations more transparent.
