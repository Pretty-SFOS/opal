<!--
SPDX-FileCopyrightText: 2021-2025 Mirian Margiani
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

*Opal is ready for production.* That being said, documentation is still lacking
and the ecosystem still has to grow.

Notably still missing:

- code documentation is only available in QtCreator but should be hosted online
- resources modules (i.e. extra icons etc.) are not yet properly supported


## Contents <a id='opal-list'/>

### Snippets / development tools <a id='snippets'/>

- [cached-defines.pri](snippets/opal-cached-defines.md): A helper and recipe for passing build options from YAML to QML.
- [render-icons.sh](snippets/opal-render-icons.md): A script for rendering and optimizing SVG icons during iterative development.
- [merge-translations.sh](snippets/opal-merge-translations.md): A script for merging Opal translations into your app's `ts` files.

All snippets are released into the public domain, *unless*
otherwise specified. *Please refer to the respective snippet files.*

### Modules <a id='modules'/>

Note that modules generally are licensed under the GNU GPL. However, all Opal
modules have their own licensing. Please refer to the respective repositories for details.

To get an overview of the currently available modules, install the
[gallery app](https://github.com/Pretty-SFOS/opal-gallery) from Jolla's Harbour
store or from [OpenRepos](https://openrepos.net/content/ichthyosaurus/opal-gallery).
You can also browse the repositories here.

#### Stable

- <a id='module-about'/>[Opal.About](https://github.com/Pretty-SFOS/opal-about): A simple and flexible "About" page supporting license info, contributors, donations, etc.
- <a id='module-supportme'/>[Opal.SupportMe](https://github.com/Pretty-SFOS/opal-supportme):  A dialog asking for support that is shown when a user has used your Sailfish app for some time.
- <a id='module-delegates'/>[Opal.Delegates](https://github.com/Pretty-SFOS/opal-delegates): List items that can show multiple lines of text and icons by default.
- <a id='module-dragdrop'/>[Opal.DragDrop](https://github.com/Pretty-SFOS/opal-dragdrop): Enables ordering lists by drag-and-drop with just a few lines of code.
- <a id='module-smartscrollbar'/>[Opal.SmartScrollbar](https://github.com/Pretty-SFOS/opal-smartscrollbar): A Harbour-compatible smart scrollbar for easier access in long lists.
- <a id='module-menuswitch'/>[Opal.MenuSwitch](https://github.com/Pretty-SFOS/opal-menuswitch): A toggle switch for Sailfish menus.
- <a id='module-infocombo'/>[Opal.InfoCombo](https://github.com/Pretty-SFOS/opal-infocombo): A combo box that can show detailed descriptions of all menu items.
- <a id='module-combodata'/>[Opal.ComboData](https://github.com/Pretty-SFOS/opal-combodata): An extension for combo boxes to access the current value instead of the label.
- <a id='module-linkhandler'/>[Opal.LinkHandler](https://github.com/Pretty-SFOS/opal-linkhandler): A link handler to open or copy external links.
- <a id='module-mediaplayer'/>[Opal.MediaPlayer](https://github.com/Pretty-SFOS/opal-mediaplayer): A media player page with support for subtitles.

#### In development

- <a id='module-localstorage'/>[Opal.LocalStorage](https://github.com/Pretty-SFOS/opal-localstorage): A set of tools for handling local databases safely and extensibly in JavaScript and Python.
- <a id='module-propertymacros'/>[Opal.PropertyMacros](https://github.com/Pretty-SFOS/opal-propertymacros): C++ macros that simplify adding properties to Qt objects.
- <a id='module-sfpm'/>[Opal.SortFilterProxyModel](https://github.com/Pretty-SFOS/opal-sfpm): Up-to-date and patched version of [SortFilterProxyModel](https://github.com/oKcerG/SortFilterProxyModel) for old QML 5.6 on Sailfish.
- <a id='module-tabs'/>[Opal.Tabs](https://github.com/Pretty-SFOS/opal-tabs): An easy way to add tab bars to apps.

- <a id='module-tabbar'/>[Opal.TabBar](https://github.com/Pretty-SFOS/opal-tabbar): An app-wide tab bar using icons with optional texts, and improved support for landscape layouts.
  Not yet properly integrated and still lives in [its old repository](https://github.com/ichthyosaurus/sf-docked-tab-bar).
- <a id='module-hints'/>[Opal.Hints](#): Interaction hints helping users discover features.


## Using Opal <a id='using-opal'/>

Follow these steps to include Opal modules in your project:

1. Fetch the module bundles you want to use and extract the `libs` and `qml` folders
   in your project root (next to the `rpm` and `translations` folders of your app).

2. Include the `libs/opal.pri` file in your app's `harbour-my-app.pro` file
   by adding this line:

        include(libs/opal.pri)

3. **You can now use Opal modules**.

    *Usage in QML:* import Opal QML modules in your code using a relative path
    to the module. For example, in a page at `qml/pages/MyPage.qml`:

        import "../modules/Opal/TheModule"

    *Usage in C++:* include headers for Opal C++ modules in your code like this:

        #include <libs/opal/themodule/theheader.h>

4. Configure your `spec` file to be Harbour-compatible (cf. [Harbour FAQ #2.6.0](https://harbour.jolla.com/faq#2.6.0)).

   *Using YAML:* add the following section to `rpm/harbour-my-app.yaml`
   (from which the `spec` file is generated):

        Macros:
        - __provides_exclude_from;^%{_datadir}/.*$

   *Using SPEC:* you can also add this directly at the top of the `rpm/harbour-my-app.spec` file:

        # >> macros
        %define __provides_exclude_from ^%{_datadir}/.*$
        # << macros

5. If you don't use [Opal.About](#module-about), you must manually add proper
   attribution for all Opal modules you used to your “About” page.

   With [Opal.About](#module-about) you can skip this step. It does this
   automatically for you.

6. Merge shipped translations with your local translations.
   If you have Qt's `lconvert` installed, you can simply run these commands:

        $ cd libs
        $ ./opal-merge-translations.sh ../translations

    Otherwise, run it inside an [`sfdk`](https://docs.sailfishos.org/Develop/Apps/#sfdk-command-line-tool) target.

    Run this to list installed targets:

        $ sfdk tools list

    It will print something like this:

        SailfishOS-4.6.0.13              sdk-provided
        ├── SailfishOS-4.6.0.13-aarch64  sdk-provided
        ├── SailfishOS-4.6.0.13-armv7hl  sdk-provided
        └── SailfishOS-4.6.0.13-i486     sdk-provided
        SailfishOS-5.0.0.62              sdk-provided,latest
        ├── SailfishOS-5.0.0.62-aarch64  sdk-provided,latest
        ├── SailfishOS-5.0.0.62-armv7hl  sdk-provided,latest
        └── SailfishOS-5.0.0.62-i486     sdk-provided,latest

    Then select the target you want to use and run the commands below. Replace
    `SailfishOS-5.0.0.62-aarch64` with the target you selected.

        $ cd libs
        $ sfdk engine exec sb2 -t SailfishOS-5.0.0.62-aarch64 ./opal-merge-translations.sh ../translations

    Note: run `sfdk --help` to get more information about the tool.


After the initial setup you can easily add additional modules by simply
extracting the `qml` and `libs` folders from the release bundle.


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

8. You can now import Opal modules in QML via the dot-notation like this:

        import Opal.TheModule 1.0


## Apps using Opal

Please contact us if your app uses Opal so we can include it in this list!

| Project                                                                                                               | Modules
|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------
| [Opal Gallery](https://github.com/Pretty-SFOS/opal-gallery): gallery app showcasing all modules                       | all modules (with examples) and [snippets](#snippets)
| [File Browser](https://github.com/ichthyosaurus/harbour-file-browser): fully-fledged file manager for Sailfish OS     | [Opal.About](#module-about), [Opal.SupportMe](#module-supportme), [Opal.InfoCombo](#module-infocombo), [Opal.ComboData](#module-combodata), [snippets](#snippets)
| [Expenditure](https://github.com/ichthyosaurus/harbour-expenditure): group travel finance helper for splitting bills  | [Opal.About](#module-about), [Opal.SupportMe](#module-supportme), [Opal.Delegates](#module-delegates), [Opal.SmartScrollbar](#module-smartscrollbar), [Opal.ComboData](#module-combodata), [snippets](#snippets)
| [To-do List](https://github.com/ichthyosaurus/harbour-todolist): focused to-do list app                               | [Opal.About](#module-about), <!--[Opal.TabBar](#module-tabbar),--> [snippets](#snippets)
| [Captain's Log](https://github.com/ichthyosaurus/harbour-captains-log): simple diary app                              | [Opal.About](#module-about), [Opal.SupportMe](#module-supportme), [Opal.InfoCombo](#module-infocombo), [Opal.ComboData](#module-combodata), [Opal.LinkHandler](#module-linkhandler), [snippets](#snippets)
| [Parking Chaos](https://github.com/ichthyosaurus/harbour-parkingchaos): "Traffic Jam" game                            | [Opal.About](#module-about), [snippets](#snippets)
| [Laundry List](https://github.com/ichthyosaurus/harbour-laundry): laundry management helper                           | [Opal.About](#module-about), [snippets](#snippets)
| [Minidoro](https://github.com/ichthyosaurus/harbour-minidoro): Pomodoro technique timer for productivity              | [Opal.About](#module-about), [Opal.LinkHandler](#module-linkhandler), [snippets](#snippets)
| [Meteo](https://github.com/ichthyosaurus/harbour-meteoswiss): weather forecasts                                       | [sf-about-page](#module-about)
| [Jammy](https://github.com/ichthyosaurus/harbour-jammy): Jamendo client featuring advanced search                     | [sf-about-page](#module-about)
| [Directory](https://github.com/ichthyosaurus/harbour-directory-ch): search the national phone book                    | [Opal.About](#module-about)
| [Dictionary](https://github.com/ichthyosaurus/harbour-wunderfitz): to be merged upstream into [Wunderfitz](https://github.com/Wunderfitz/harbour-wunderfitz) | [sf-docked-tab-bar](#module-tabbar)
| [Sailtrix](https://gitlab.com/HengYeDev/harbour-sailtrix/): Matrix client                                             | [sf-docked-tab-bar](#module-tabbar)
| [Olive goes shopping](https://github.com/PawelSpoon/harbour-olive-goes-shopping): shopping list app                   | [sf-docked-tab-bar](#module-tabbar)
| [Skruuvi](https://github.com/miikasda/harbour-skruuvi): native reader for Ruuvi sensors                               | [Opal.About](#module-about)
| [Screen Time](https://github.com/miikasda/harbour-screentime): track your screen time usage on Sailfish OS            | [Opal.About](#module-about)
| [Outpost](https://openrepos.net/content/mistermagister/outpost): an unofficial app for InPost                         | [Opal.About](#module-about)
| [SailDiscord](https://github.com/roundedrectangle/SailDiscord): an unofficial client app for Discord                  | [Opal.About](#module-about)
| [Tidal Player](https://github.com/PawelSpoon/harbour-tidalplayer/): Tidal music streaming client \[built with AI\]    | [Opal.Delegates](#module-delegates), [Opal.DragDrop](#module-dragdrop)
| [Tidings](https://github.com/poetaster/tidings): a news feed and podcast aggregator                                   | [Opal.About](#module-about), [Opal.SmartScrollbar](#module-smartscrollbar)
| [SeriesFinale](https://github.com/corecomic/seriesfinale/pull/21): TV series app to keep track of what you're watching| [Opal.About](#module-about), [Opal.Delegates](#module-delegates), [Opal.SmartScrollbar](#module-smartscrollbar), [Opal.LinkHandler](#module-linkhandler), [Opal.MenuSwitch](#module-menuswitch), [snippets](#snippets)
| [Pipes](https://github.com/Arusekk/harbour-pipes/pull/2): a game about connecting pipes                               | [snippets](#snippets)


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

1. Add a new snippet file in the [snippets] directory
2. Add a Markdown file for documentation with the same name
3. Add an entry in the list of snippets above

**Coding conventions:** please use [Shellcheck](https://www.shellcheck.net/) when
writing Bash scripts. Read the documentation on common [Bash pitfalls](https://mywiki.wooledge.org/BashPitfalls)
and avoid them at all costs. Opal snippets are intended to be run on recent versions
of GNU Bash (> 5.0) unless explicitly documented otherwise.


### Adding new modules

1. Copy the [Opal module template](https://github.com/Pretty-SFOS/opal-module-template)
   repository, and initialize a new repository for your module:

        $ git clone https://github.com/Pretty-SFOS/opal-module-template mymodule
        $ cd mymodule
        $ rm -rf .git
        $ git init

2. Run the setup script to configure the new module:

        $ ./setup.sh --help
        $ ./setup.sh mymodule MyModule "Jane Doe" "QML module for SOMETHING in Sailfish apps" "This module provides SOMETHING to DO SOMETHING."

3. Follow the instructions in the `README.md` file.

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
5. Open `qml/harbour-opal-gallery.qml` and set the `develJumpToModule` property
   to your module's name.
6. Create one or more example pages for the new module. The main page must be
   `doc/gallery.qml`. Extra pages can be added as `doc/gallery/*.qml`. See
   the [module metadata file](https://github.com/Pretty-SFOS/opal-about/blob/main/doc/module.opal)
   for details. Edit this example page in the gallery app in
   `qml/module-pages/opal-<mymodule>/gallery.qml`.
7. Last but not least, add an entry in the list of modules in Opal's
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


### Adding resources

TBD.

1. Create a new repository named `opal-res-<...>`
2. Create the same structure as in [`opal-res-extra-icons`](TBD) (changing the relevant parts)
3. TBD: showcase in gallery app
4. TBD: add to wiki


## Anti-AI policy <a id='ai-policy'/>

AI-generated contributions are forbidden and contributors will be banned from
any further contributions.

Please respect the Free Software community and adhere to the licenses. This is a
welcoming place for human creativity and diversity, but AI-generated slop is
going against these values.

Apart from all the ethical, moral, legal, environmental, social, and technical
reasons against AI, I also simply don't have any spare time to review
AI-generated contributions.

This policy applies to Opal, all modules, and all other contents.


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
