#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021 Mirian Margiani
#
# Include this file in your main PRO file and add the modules you want to use to
# the CONFIG variable. Include the file after defining translations.
#
# Make sure to disable "RPM provides" in the spec file by adding the following
# in the "# >> macros" section:
#       %define __provides_exclude_from ^%{_datadir}/.*$
#
# And add the import path in C++:
#       view->engine()->addImportPath(SailfishApp::pathTo(OPAL_IMPORT_PATH).toString());
#
# See https://github.com/Pretty-SFOS/opal/blob/main/snippets/opal-use-modules.md
# for up-to-date documentation.
#

# Copy module packages to OPAL_PATH. The path must be below your app's main QML
# directory. Specify the path relative to your project root.
OPAL_PATH = qml/opal-modules

# Copy module translations to OPAL_TR_PATH. All Opal translations will be merged
# with your normal translations during the build process. Specify the path
# relative to your project root.
OPAL_TR_PATH = libs/opal-translations

# ------------------------------------------------------------------------------
# Available modules - no configuration required

# To be used for setting the import path in main(...).
DEFINES += OPAL_IMPORT_PATH=\\\"$$OPAL_PATH\\\"

# activate with: CONFIG += opal-about
opal-about {
    OPAL_TRANSLATIONS += $$files($$absolute_path($$OPAL_TR_PATH, $$_PRO_FILE_PWD_)/opal-about/opal-about-*.ts)
    DISTFILES += $$files($$absolute_path($$OPAL_PATH, $$_PRO_FILE_PWD_)/Opal/About, true)
}

# activate with: CONFIG += opal-tabbar
opal-tabbar {
    OPAL_TRANSLATIONS += $$files($$absolute_path($$OPAL_TR_PATH, $$_PRO_FILE_PWD_)/opal-tabbar/opal-tabbar-*.ts)
    DISTFILES += $$files($$absolute_path($$OPAL_PATH, $$_PRO_FILE_PWD_)/Opal/TabBar, true)
}

# ------------------------------------------------------------------------------
# Translation building - no configuration required

# Append OPAL_PATH to QtCreator's module search path. This only affects the IDE.
QML_IMPORT_PATH += $$OPAL_PATH

# Prepare merging module translations with regular app translations.
qtPrepareTool(LCONVERT, lconvert)
merge_opal_tr.commands += echo -n;

# Loop over app translations and search for matching module translations.
# This expects translation files to be named foobar-LANG.ts (with '-' as
# separator). This will fail if your app uses a different separator or language
# codes contain a dash character. Please rename your files in this case, as
# changing the separator here will be overwritten when updating Opal.
for (op_file, TRANSLATIONS) {
    op_base = $$basename(op_file)
    op_suff = $$section(op_base, '-', -1, -1)

    contains(OPAL_TRANSLATIONS, .*$$op_suff) {
        op_add = $$find(OPAL_TRANSLATIONS, .*$$op_suff)
        message(merging translations: $$absolute_path($$op_file, $$_PRO_FILE_PWD_) \
                                      $$absolute_path($$op_add, $$_PRO_FILE_PWD_))
        merge_opal_tr.commands += $$LCONVERT -i \
            $$absolute_path($$op_file, $$_PRO_FILE_PWD_) \
            $$absolute_path($$op_add, $$_PRO_FILE_PWD_) \
            -o $$absolute_path($$op_file, $$_PRO_FILE_PWD_) ;
    }
}

first.depends = $(first) merge_opal_tr
export(first.depends)
export(merge_opal_tr.commands)
QMAKE_EXTRA_TARGETS += first merge_opal_tr
