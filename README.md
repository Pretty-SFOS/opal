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


## Project status

> **Opal is not yet ready for production.**

That being said, some modules and snippets are already in a usable state.

- the [gallery app](https://github.com/Pretty-SFOS/opal-gallery) is ready and stable
- [Opal.About](https://github.com/Pretty-SFOS/opal-about) is usable, documented but not yet well tested
- all snippets needed for including modules in an app are ready (cf. "Using Opal")
- [render-icons.sh](snippets/opal-render-icons.md) is ready and stable

Notably still missing:

- [the wiki](TBD) does not yet exist
- resources modules (i.e. extra icons etc.) are not yet properly supported
- plugins (i.e. modules with parts written in C++) are not yet supported
- [Opal.TabBar](https://github.com/Pretty-SFOS/opal-tabbar) is not yet imported and
  still lives in [the old repository](https://github.com/ichthyosaurus/sf-docked-tab-bar)
- code documentation should be hosted online somewhere


## Using Opal

Please refer to [the wiki](TBD) for snippets, recipes, and other documentation.
You can find a list of contents [here](TBD).

Follow these steps to include Opal modules in your project:

1. Fetch the latest Opal [release bundle](https://github.com/Pretty-SFOS/opal/releases/latest).
2. Extract [opal-merge-translations.sh](snippets/opal-merge-translations.sh) to `<project>/libs`.
3. Fetch the module bundles you want to use and extract the `libs` and `qml` folders
   in your project root. (For example, ready-made translations should end up in
   `harbour-my-app/libs/opal-translations/`.)
4. You can now use the modules. For the About page component you would have to write
   in QML (e.g. at `qml/pages/AboutPage.qml`):

        import "../modules/Opal/About"

5. Configure your `spec` file to be Harbour-compatible (cf. [https://harbour.jolla.com/faq#2.6.0]):

        # >> macros
        %define __provides_exclude_from ^%{_datadir}/.*$
        # << macros

6. Merge shipped translations with your local translations by running

        cd libs
        ./opal-merge-translations ../translations

7. Add docs and translations to `.gitignore`. They have been merged with your
   main translations.

        libs/opal-translations
        libs/opal-docs

After the initial setup you can easily add additional modules by simply
extracting QML sources, docs, and translations to the respective directories.


### Dot-notation

Additional steps are required to be able to import modules using the
dot-notation.

7. Register `qml/modules` as QML import path. The code below is fine for
   new projects. This is not necessary for QML-only projects using QML-only
   modules.

```CPP
//// in src/harbour-myproject.cpp:
int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
```

8. If everything is setup correctly, you can now use Opal by importing the
    modules. For the About page component you would have to write in QML:

        import Opal.About 1.0


### Qt Creator

If auto-completion does not work, try adding `qml/modules` to the IDE's module
search path.

    QML_IMPORT_PATH += qml/modules


## Modules

You can find [a list of modules](https://github.com/Pretty-SFOS/opal-gallery/blob/main/qml/harbour-opal.qml)
in the Wiki.

You can also browse the [snippets directory](snippets/) or install the
[gallery application](https://github.com/Pretty-SFOS/opal-gallery).


## Development

The wiki can be changed online. To clone its contents, append `.wiki.git` to this
repository's URL.

All modules live in their own repositories.

Useful tools for developing Opal can be found in the
[opal-development](opal-development/) directory.

### Adding snippets

1. Add a new snippet file in the [snippets] diretory
2. Add a Markdown file for documentation with the same name
3. Add an entry in the [list of snippets](TBD)

### Adding new modules

1. Create a new repository named `opal-<...>`
2. Create the same structure as in [`opal-about`](https://github.com/Pretty-SFOS/opal-about) (changing the relevant parts)
3. Update module metadata in `doc/module.opal`
4. Write an entry in the wiki: [list of modules](TBD)
5. Create one or more example pages for the new module. The main page must be
   `doc/gallery.qml`. Extra pages can be added as `doc/gallery/*.qml`. See
   the [module metadata file](https://github.com/Pretty-SFOS/opal-about/blob/main/doc/module.opal)
   for details.

Make sure to use `qsTranslate("Opal.<Module>", "string")` instead of
`qsTr("string")` for all translations. Otherwise merged translations would
clutter a user's app translation files.

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
