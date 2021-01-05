# Rendering script for SVG icons

The [opal-render-icons.sh] script provides a `render_batch` function for quickly
rendering any kind of SVG icons to PNG. The rendered files can then be included
in your distribution.

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
for i in raw/*.svg; do scour "$i" > "${i#raw/}"; done
```

## How to use the script

The [opal-render-icons.sh] script has to be "sourced" from your own rendering
script, where you define what will be rendered.

```bash
source opal-render-icons.sh
cFORCE=false  # set this to 'true' to always re-render all items
```

Items will be rendered in batches. Call `render_batch` after defining a batch,
then define the next one, and so on.

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
# cITEMS=(simple-icon) -- use resolutions from cRESOLUTIONS
# cITEMS=(simple-icon@100) -- render at 100x100, with cRESOLUTIONS=(F1)
# cITEMS=(simple-icon@100x200) -- render at 100x200, with cRESOLUTIONS=(F1)
cITEMS=(complex/big-one@211x1020@../qml/images/complex/big
        complex/big-one@5x11@../qml/images/complex/small
        simple/icon@100@../qml/images
)

# the resolutions in which items will be rendered
# This array can either hold a list of resolutions at which the icons of the
# current batch will be rendered, or it can hold a field number.
# Use 'F1' to indicate that items should be rendered at the resolution specified
# in field 1, e.g. 'item-name@RESOLUTION'. (You can just as well use 'F2'...)
cRESOLUTIONS=(F1)

# the target paths where rendered items will be placed
# The values are interpreted the same way as cRESOLUTIONS.
#
# Any occurrence of 'RESX' and 'RESY' will be replaced by the corresponding
# resolution. You can use '../icons/RESXxRESY' to render items to
# sub-directories depending on their resolution.
cTARGETS=(F2)

# finally: render the batch
render_batch
```

You can use the [opal-render-icons-example.sh] script to quickly get you started.
