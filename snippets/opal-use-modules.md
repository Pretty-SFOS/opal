<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Use and package Opal modules

Include [opal-use-modules.pri] in your main PRO file and add the modules you want
to use to the `CONFIG` variable.

    include(libs/opal-use-modules.pri)
    CONFIG += opal-about

Make sure to place the above lines *below* your app's `TRANSLATIONS` definition.
Otherwise Opal translations won't be merged with your app's translations.

Copy the required module packages to the path defined in `OPAL_PATH` which must
be below your app's main qml directory. The default is `qml/opal-modules` and
should be fine for all projects.

Copy the required module package's translation files to the path defined in
`OPAL_TR_PATH`. This path should *not* be in any directory that will land in the
final RPM (i.e. *not* below the main QML directory). All Opal translations will
be merged with your normal translations during the build process. The default
is `libs/opal-translations` and should be fine for all projects.

If you change any paths, make sure to specify them relative to your project's
root directory (where the PRO file is located).

Make sure to disable "RPM provides" in the SPEC file by adding the following
in the `# >> macros` section:

    %define __provides_exclude_from ^%{_datadir}/.*$

See [https://harbour.jolla.com/faq#2.6.0] for more information regarding Harbour
rules.

Last but not least, register a new QML import path for Opal modules. This is
necessary to be able to use `import Opal.Module 1.0` lines in your project.
The code below is fine for new projects. `OPAL_IMPORT_PATH` is defined when
including [opal-use-modules.pri](opal-use-modules.pri).

```CPP
//// in src/harbour-myproject.cpp:
int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->engine()->addImportPath(SailfishApp::pathTo(OPAL_IMPORT_PATH).toString());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
```
