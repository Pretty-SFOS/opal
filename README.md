<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Opal

Opal is a collection of pretty QML components for SailfishOS, building on top
of Sailfish's Silica components. It provides ready-made components, examples,
snippets, recipes, and resources for building more sailfishy Sailfish apps.

This repository contains documentation and [the wiki](TBD).

If you want to create new applications using Opal, follow the steps below.
Opal is a library for developers. As an end-user you should not have to do anything.


## Using Opal

Please refer to [the wiki](TBD) for snippets, recipes, and other documentation.
You can find a list of contents [here](TBD).

Follow these steps to include Opal modules in your project:

1. Create a directory named `libs` in your project root.
2. Create a directory named `opal-modules` in your main QML directory.
3. Fetch the latest Opal [release bundle](https://github.com/Pretty-SFOS/opal/releases/latest).
4. Extract [opal-use-modules.pri](snippets/opal-use-modules.pri) to `libs`.
5. Include the file in your main `pro` file and select which modules to activate.

        CONFIG += opal-about
        include(libs/opal-use-modules.pri)

6. Fetch the required module bundles and extract the QML sources to `qml/opal-modules`.
7. Extract the ready-made translations to `libs/opal-translations`.
8. Configure your `spec` file to be Harbour-compatible:

        # >> macros
        %define __provides_exclude_from ^%{_datadir}/.*$
        # << macros

9. If Opal everything is setup correctly, you can now use Opal by importing the
   modules. For the About page component you would have to write in QML:

        import Opal.About 1.0

After the initial setup you can easily add additional modules by adding them to
the `CONFIG` variable and then simply extracting QML sources and translations
to the respective directories.

See [this page](snippets/opal-use-modules.md) for more information.

## Modules

You can find [a list of modules](https://github.com/Pretty-SFOS/opal-gallery/blob/master/qml/harbour-opal.qml)
in the Wiki.

You can also browse the [snippets directory](snippets/) or install the
[gallery application](https://github.com/Pretty-SFOS/opal-gallery).


## Development

The wiki can be changed online. To clone its contents, append `.wiki.git` to this
repository's URL.

All modules live in their own repositories.

### Adding snippets

1. Add a new snippet file in the [snippets] diretory
2. Add a Markdown file for documentation with the same name
3. Add an entry in the [list of snippets](TBD)

### Adding new modules

1. Create a new repository named `opal-<...>`
2. Create the same structure as in [`opal-about`](https://github.com/Pretty-SFOS/opal-about) (changing the relevant parts)
3. Write an entry for the new module in
    - the gallery application: [`qml/harbour-opal.qml`](https://github.com/Pretty-SFOS/opal-gallery/blob/master/qml/harbour-opal.qml)
    - the wiki: [list of modules](TBD)
4. Create one or more example pages for the new module in the gallery application
   in the directory [`qml/module-pages`](https://github.com/Pretty-SFOS/opal-gallery/blob/master/qml/module-pages/)

*Note:* use `qsTr("String")` for translating until we find a way to make apps
actually load translations from custom contexts.

> Make sure to use `qsTranslate("Opal.<Module>", "String")` instead of
> `qsTr("String")` for all translations. Otherwise merged translations would
> clutter a user's app translation files.

### Adding plugins

TBD.

Plugins require additional build processes which are not yet properly supported.
They have to be built using the Sailfish IDE, pre-packaged, and then included
in target apps.

Handling should be identical to QML-only modules.

### Adding resources

TBD.

1. Create a new repository named `opal-res-<...>`
2. Create the same structure as in [`opal-res-extra-icons`](TBD) (changing the relevant parts)
3. TBD: showcase in gallery app
4. TBD: add to wiki

## Licenses

All Opal [modules](TBD: wiki link) have their own licensing.
*Please refer to the respective repositories.*

All [snippets](TBD: wiki link) are released in the public domain, *unless*
otherwise specified. *Please refer to the respective snippet files.*

All documentation is released under the terms of the
[GFDL-1.3-or-later](https://spdx.org/licenses/GFDL-1.3-or-later.html).

        Copyright (C)  2021  Mirian Margiani
    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.3
    or any later version published by the Free Software Foundation;
    with the Invariant Sections being [none yet], with the Front-Cover Texts
    being [none yet], and with the Back-Cover Texts being [none yet].
    You should have received a copy of the GNU Free Documentation License
    along with this document.  If not, see <http://www.gnu.org/licenses/>.
