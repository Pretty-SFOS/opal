<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Opal documentation using qdoc

The configuration file [opal-qdoc.qdocconf](opal-qdoc.qdocconf) provides defaults for building a
module's documentation using `qdoc`. Use the [opal-qdoc-example.qdocconf](opal-qdoc-example.qdocconf)
template for new modules.

Copy and rename the example file as `opal-<module>.qdocconf` and configure it for
your new module. Follow the instructions in the file.

Documentation will be built automatically when building the project using
[the release script](opal-release-module.md).

You can then add the documentation to QtCreator via Extras → Settings → Help
→ Documentation → Add. Refer to the
[QtCreator manual](https://doc.qt.io/qtcreator/creator-help.html#adding-external-documentation)
for further information.

## How to write documentation

TBD.

- https://doc.qt.io/qt-5/qtwritingstyle-qml.html
- https://wiki.qt.io/Writing_Qt_Documentation
- https://doc.qt.io/qt-5/qdoc-index.html
- https://retifrav.github.io/blog/2017/05/24/documenting-qt-project-with-qdoc/

## Custom macros

TBD.

Refer to the configuration file: [opal-qdoc.qdocconf](opal-qdoc.qdocconf)

## Links regarding doxygen

We are currently using `qdoc`, not `doxygen`, for building documentation.

- using doxygen with QML: https://invent.kde.org/sdk/doxyqml/
