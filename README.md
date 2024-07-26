<!--
SPDX-FileCopyrightText: 2021-2023 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Opal

Opal is a collection of pretty QML components for SailfishOS, building on top
of Sailfish's Silica components. It provides ready-made components, examples,
snippets, recipes, and resources for building more sailfishy Sailfish apps.

This repository contains documentation, snippets, and development tools.

If you want to create new applications using Opal, follow the steps below.
Opal is a library for developers. As an end-user you should not have to do anything.


## Project status

*Opal is ready for production.* That being said, Opal is not yet very mature and
the ecosystem still has to grow.

- the [gallery app](https://github.com/Pretty-SFOS/opal-gallery) is ready and stable
- [Opal.About](https://github.com/Pretty-SFOS/opal-about) is usable and fully documented
- all snippets needed for including modules in an app are ready (see below)
- [render-icons.sh](snippets/opal-render-icons.md) is ready and stable

Notably still missing:

- resources modules (i.e. extra icons etc.) are not yet properly supported
- plugins (i.e. modules with parts written in C++) are not yet supported
- code documentation should be hosted online

## Contents <a id='opal-list'/>

You can also browse the [snippets directory](snippets/) or install the
[gallery application](https://github.com/Pretty-SFOS/opal-gallery).

### Snippets / development tools <a id='snippets'/>

- [cached-defines.pri](snippets/opal-cached-defines.md): A helper and recipe for passing build options from YAML to QML.
- [merge-translations.sh](snippets/opal-merge-translations.md): A script for merging Opal translations into your app's `ts` files.
- [render-icons.sh](snippets/opal-render-icons.md): A script for rendering and optimizing SVG icons during iterative development.

All snippets are released into the public domain, *unless*
otherwise specified. *Please refer to the respective snippet files.*

### Modules <a id='modules'/>

All Opal modules have their own licensing. *Please refer to the respective repositories.*

#### Stable

- <a id='module-about'/>[Opal.About](https://github.com/Pretty-SFOS/opal-about): A simple and flexible "About" page supporting license info, contributors, donations, etc.
- <a id='module-supportme'/>[Opal.SupportMe](https://github.com/Pretty-SFOS/opal-supportme):  A dialog asking for support that is shown when a user has used your Sailfish app for some time.
- <a id='module-delegates'/>[Opal.Delegates](https://github.com/Pretty-SFOS/opal-delegates): List items that can show multiple lines of text and icons by default.
- <a id='module-infocombo'/>[Opal.InfoCombo](https://github.com/Pretty-SFOS/opal-infocombo): A combo box that can show detailed descriptions of all menu items.
- <a id='module-combodata'/>[Opal.ComboData](https://github.com/Pretty-SFOS/opal-combodata): An extension for combo boxes to access the current value instead of the label.
- <a id='module-linkhandler'/>[Opal.LinkHandler](https://github.com/Pretty-SFOS/opal-linkhandler): A link handler to open or copy external links.

#### In development

- <a id='module-hints'/>[Opal.Hints](#): Interaction hints helping users discover features.
- <a id='module-tabbar'/>[Opal.TabBar](https://github.com/Pretty-SFOS/opal-tabbar): An app-wide tab bar using icons with optional texts, and improved support for landscape layouts.
  Not yet properly integrated and still lives in [its old repository](https://github.com/ichthyosaurus/sf-docked-tab-bar).

## Using Opal <a id='using-opal'/>

Follow these steps to include Opal modules in your project:

1. Fetch the latest Opal [release bundle](https://github.com/Pretty-SFOS/opal/archive/refs/heads/main.zip).
2. Extract [opal-merge-translations.sh](snippets/opal-merge-translations.sh) to `<project>/libs`.
3. Fetch the module bundles you want to use and extract the `libs` and `qml` folders
   in your project root. (For example, ready-made translations should end up in
   `harbour-my-app/libs/opal-translations/`, while QML files should be in
   `harbour-my-app/qml/modules/Opal/MyModule`.)
4. You can now use the modules. For the About page component you would have to write
   in QML (e.g. at `qml/pages/AboutPage.qml`):

        import "../modules/Opal/About"

   To use default attributions, you would have to import them on the “About” page
   like this:

        import "../modules/Opal/Attributions"

   Note: this is a path relative to the QML file you are working with. The "../"
   in this example assumes that you are, for example, editing the page
   `harbour-my-app/qml/pages/AboutPage.qml`.

5. Configure your `spec` file to be Harbour-compatible (cf. [Harbour FAQ #2.6.0](https://harbour.jolla.com/faq#2.6.0)).
   Add the following section to your `yaml` file (from which the `spec` file is generated). If there already
   is a `Macros:` section, simply add the contents below.

        Macros:
        - __provides_exclude_from;^%{_datadir}/.*$

   *Alternative*: the [Harbour FAQ #2.6.0](https://harbour.jolla.com/faq#2.6.0) recommends adding a line
   directly to the `spec` file. You would have to re-add this line every time after changing the YAML
   file, though. This is due to a bug in the Sailfish SDK.

        # >> macros
        %define __provides_exclude_from ^%{_datadir}/.*$
        # << macros

6. Merge shipped translations with your local translations.
   If you have Qt's `lconvert` installed, you can simply run this code:

        $ cd libs
        $ ./opal-merge-translations ../translations

    Otherwise, run it inside an [`sfdk`](https://docs.sailfishos.org/Develop/Apps/#sfdk-command-line-tool)
    target, so you'll need to run something like the following (replacing `SailfishOS-4.5.0.16EA-aarch64` with one of your targets).

        $ cd libs
        $ sfdk engine exec sb2 -t SailfishOS-4.5.0.16EA-aarch64 \
            ./opal-merge-translations.sh ../translations

    Note: run `sfdk --help` to get more information about the tool.

7. Add docs and translations to `.gitignore`. They have been merged with your
   main translations.

        libs/opal-translations
        libs/opal-docs

8. Add proper attribution where required, e.g. to your “About” page. Opal modules
   provide QML elements that can be used directly in [Opal.About](#module-about).
   Import `../modules/Opal/Attributions`, then add `Opal[MyModule]Attribution {}`
   to the `attributions` list property of the “About” page.

After the initial setup you can easily add additional modules by simply
extracting QML sources, docs, and translations to the respective directories.


### Dot-notation (optional)

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
    app->setOrganizationName("harbour-myapp"); // needed for Sailjail
    app->setApplicationName("harbour-myapp");
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // add module search path so Opal modules can be found
    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());

    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
```

8. Enable the dot-notation for ready-made attribution components by adding this
   line to your main `.pro` file:

        include(libs/opal-enable-attributions.pri)

9. If everything is set up correctly, you can now use Opal by importing the
   modules via the dot-notation. For the “About” page component you would have
   to write in QML:

        import Opal.About 1.0

   *Note:* ready-made attributions in `qml/modules/Opal/Attributions` must be
   imported by path due to technical limitations of Qt's module system. Like this:

        import "../modules/Opal/Attributions"


### Sailfish SDK (Qt Creator)

If auto-completion does not work, try adding `qml/modules` to the IDE's module
search path. Add this line to your project's `.pro` file:

    QML_IMPORT_PATH += qml/modules


## Apps using Opal

Please contact us if your app uses Opal so we can include it in this list!

| Project                                                                                                               | Modules
|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------
| [Opal Gallery](https://github.com/Pretty-SFOS/opal-gallery): gallery app showcasing all modules                       | all modules (with examples) and [snippets](#snippets)
| [File Browser](https://github.com/ichthyosaurus/harbour-file-browser): fully-fledged file manager for Sailfish OS     | [Opal.About](#module-about), [Opal.SupportMe](#module-supportme), [Opal.InfoCombo](#module-infocombo), [Opal.ComboData](#module-combodata), [snippets](#snippets)
| [To-do List](https://github.com/ichthyosaurus/harbour-todolist): focused to-do list app                               | [Opal.About](#module-about), <!--[Opal.TabBar](#module-tabbar),--> [snippets](#snippets)
| [Captain's Log](https://github.com/ichthyosaurus/harbour-captains-log): simple diary app                              | [Opal.About](#module-about), [Opal.InfoCombo](#module-infocombo), [Opal.ComboData](#module-combodata), [Opal.LinkHandler](#module-linkhandler), [snippets](#snippets)
| [Parking Chaos](https://github.com/ichthyosaurus/harbour-parkingchaos): "Traffic Jam" game                            | [Opal.About](#module-about), [snippets](#snippets)
| [Laundry List](https://github.com/ichthyosaurus/harbour-laundry): laundry management helper                           | [Opal.About](#module-about), [snippets](#snippets)
| [Minidoro](https://github.com/ichthyosaurus/harbour-minidoro): Pomodoro technique timer for productivity              | [Opal.About](#module-about), [Opal.LinkHandler](#module-linkhandler), [snippets](#snippets)
| [Meteo](https://github.com/ichthyosaurus/harbour-meteoswiss): weather forecasts                                       | [sf-about-page](#module-about)
| [Jammy](https://github.com/ichthyosaurus/harbour-jammy): Jamendo client featuring advanced search                     | [sf-about-page](#module-about)
| [Directory](https://github.com/ichthyosaurus/harbour-directory-ch): search the national phone book                    | [Opal.About](#module-about)
| [Dictionary](https://github.com/ichthyosaurus/harbour-wunderfitz): to be merged upstream into [Wunderfitz](https://github.com/Wunderfitz/harbour-wunderfitz) | [sf-docked-tab-bar](#module-tabbar)
| [Sailtrix](https://gitlab.com/HengYeDev/harbour-sailtrix/): Matrix client                                             | [sf-docked-tab-bar](#module-tabbar)
| [Olive goes shopping](https://github.com/PawelSpoon/harbour-olive-goes-shopping): shopping list app                 | [sf-docked-tab-bar](#module-tabbar)
| [Skruuvi](https://github.com/miikasda/harbour-skruuvi): native reader for Ruuvi sensors                               | [Opal.About](#module-about)
| [Screen Time](https://github.com/miikasda/harbour-screentime): track your screen time usage on Sailfish OS            | [Opal.About](#module-about)


## Developing Opal <a id='developing-opal'/>

All modules live in their own repositories.

Useful tools for developing Opal can be found in the
[opal-development](opal-development/) directory.

### Licensing

All contributions to Opal must be licensed under Free Software licenses compatible
with the GNU GPL v3. Apart from that, you are free to choose a license of your
liking from the [SPDX license list](https://spdx.org/licenses/) for your new
contents.

**Important:** make sure your contributions are [REUSE](https://reuse.software/)
compliant. This makes it much easier to reuse them in other projects, to write
proper attributions, and to find incompatibilities.

### Translating modules

Some modules provide their own translations that can be used by other apps.

To **use** packaged translations in your project, follow the main documentation for
using Opal modules [here](https://github.com/Pretty-SFOS/opal#using-opal).

You can also **contribute** translations, so that all apps using Opal can
benefit from it. Translations are managed using
[Weblate](https://hosted.weblate.org/projects/opal).

Please prefer Weblate over pull requests (which are still welcome, of course).

### Adding snippets

1. Add a new snippet file in the [snippets] diretory
2. Add a Markdown file for documentation with the same name
3. Add an entry in the list of snippets above

**Coding conventions:** please use [Shellcheck](https://www.shellcheck.net/) when
writing Bash scripts. Read the documentation on common [Bash pitfalls](https://mywiki.wooledge.org/BashPitfalls)
and avoid them at all costs. Opal snippets are intended to be run on recent versions
of GNU Bash (> 5.0) unless explicitly documented otherwise.

### Adding new modules

0. Clone the Opal repository to a folder named `opal`:

        $ cd /path/to/my/dev/stuff/
        $ git clone https://github.com/Pretty-SFOS/opal opal

1. Create a new repository named `opal-<...>` next to the `opal` directory:

        $ cd /path/to/my/dev/stuff/
        $ mkdir opal-mymodule
        $ cd opal-mymodule
        $ git init

2. Create the same structure as in [`opal-infocombo`](https://github.com/Pretty-SFOS/opal-infocombo)
   but remove the `translations` directory. (Translations will be setup for you when you first run `release-module.sh`.)
   Use `grep` to find all files you have to modify:

        $ cd /path/to/my/dev/stuff/opal-mymodule
        $ grep -Ri infocombo

3. Update module metadata in `doc/module.opal`.

Once these basics are setup, you can use the [Opal Gallery](https://github.com/Pretty-SFOS/opal-gallery)
app to test and develop your module.

1. Clone the gallery app next to the `opal` directory:

        $ cd /path/to/my/dev/stuff/
        $ git clone https://github.com/Pretty-SFOS/opal-gallery opal-gallery

2. Register your module in the gallery by adding it to the `cQML_MODULES` array
   in [`fetch-modules.sh`](https://github.com/Pretty-SFOS/opal-gallery/blob/main/fetch-modules.sh#L11).
   Note: remove all other modules from the array, unless you have cloned their repositories.

        # name of your module's directory without the "opal-" prefix
        cQML_MODULES=(mymodule)

3. Run `fetch-modules.sh` to include all registered modules in the gallery app.
4. Open the gallery app project in the Sailfish IDE (QtCreator) and edit your module
   in `qml/modules/Opal/MyModule`.
5. Create one or more example pages for the new module. The main page must be
   `doc/gallery.qml`. Extra pages can be added as `doc/gallery/*.qml`. See
   the [module metadata file](https://github.com/Pretty-SFOS/opal-about/blob/main/doc/module.opal)
   for details. Edit this example page in the gallery app in
   `qml/module-pages/opal-<mymodule>/<MyModule>.qml`.
6. Last but not least, add an entry in the list of modules in Opal's
   [README.md](https://github.com/Pretty-SFOS/opal/blob/main/README.md#modules) file.

**Translations:** Make sure to use `qsTranslate("Opal.<Module>", "string")` instead of
`qsTr("string")` for all translations. Otherwise merged translations would
clutter a user's app translation files.

**Coding conventions:** please follow the [Sailfish coding conventions](https://docs.sailfishos.org/Develop/Apps/Coding_Conventions/)
and the [Qt coding conventions](https://doc.qt.io/qt-5/qml-codingconventions.html) where possible.
Read the documentation on common [pitfalls in Sailfish app development](https://sailfishos.org/develop/docs/silica/sailfish-application-pitfalls.html)
and avoid them unless you have a very good reason.

**Hint:** use the [Silica cheatsheet](https://web.archive.org/web/20230628211624/https://jollacommunity.it/wp-content/uploads/2016/06/component_cheatsheet.png)
and the [Theme cheatsheet](https://web.archive.org/web/20230628212523/https://jollacommunity.it/wp-content/uploads/2016/06/theme_cheatsheet.png).

### Adding plugins

TBD.

Plugins require additional build processes which are not yet properly supported.
They have to be built using the Sailfish IDE, pre-packaged, and then included
in target apps.

Handling should be identical to QML-only modules.

**Coding conventions:** please follow the [Sailfish coding conventions](https://docs.sailfishos.org/Develop/Apps/Coding_Conventions/)
where possible.

### Adding resources

TBD.

1. Create a new repository named `opal-res-<...>`
2. Create the same structure as in [`opal-res-extra-icons`](TBD) (changing the relevant parts)
3. TBD: showcase in gallery app
4. TBD: add to wiki

## Licenses

All Opal modules have their own licensing.
*Please refer to the respective repositories.*

All snippets are released in the public domain, *unless*
otherwise specified. *Please refer to the respective snippet files.*

All documentation is released under the terms of the
[GFDL-1.3-or-later](https://spdx.org/licenses/GFDL-1.3-or-later.html).

        Copyright (C)  Mirian Margiani

    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.3
    or any later version published by the Free Software Foundation;
    with the Invariant Sections being [none yet], with the Front-Cover Texts
    being [none yet], and with the Back-Cover Texts being [none yet].
    You should have received a copy of the GNU Free Documentation License
    along with this document.  If not, see <http://www.gnu.org/licenses/>.
