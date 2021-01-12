<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# TODO

## General

- [x] package translations with modules
- [x] merge module translations with app translations
- [ ] bundle module metadata in module repos
    - [ ] about the module: license, author, etc. (maybe as JSON)
    - [ ] example page(s) to be included in Gallery
    - [ ] module documentation as `qch` file
- [x] split snippets for app developers and for Opal development
- [ ] proper versioning
    - [ ] documentation
    - [ ] Semantic Versioning for all modules, snippets, etc.
- [ ] documentation
    - [ ] use `qdoc` or `doxygen`
        Problem: QtCreator auto-completes documentation comments only in C++
        files. It is tedious to write doc comments manually in QML files.

        About Qt documentation:

        - using doxygen with QML: https://invent.kde.org/sdk/doxyqml/
        - https://wiki.qt.io/Writing_Qt_Documentation
        - https://doc.qt.io/qt-5/qdoc-index.html
        - https://doc.qt.io/qt-5/qtwritingstyle-qml.html
        - https://retifrav.github.io/blog/2017/05/24/documenting-qt-project-with-qdoc/
        - https://doc.qt.io/qtcreator/creator-help.html#adding-external-documentation

## Modules

- Snippets
    - [ ] implement fetching module sources in `opal-use-modules.pri`
    - [ ] remove `opal-fetch-modules.pri` stub
- Gallery
    - [x] general clean up
    - [x] update to use latest About module
    - [x] make 'about this module' page more accessible
    - [x] improve translations
    - [x] update readme
    - [ ] automatically fetch latest modules
    - [ ] move module example pages to module repos
- About
    - [ ] documentation
    - [x] improve loading time; load licenses asynchronously
- TabBar
    - [ ] import to Opal
    - [ ] add example page
    - [ ] try to remove all reliance on internal/undocumented Silica features (`__silica...`)
    - [ ] documentation
- ErrorFeedback
    - [ ] import to Opal
    - [ ] add example page
    - [ ] clean up and unify API
    - [ ] documentation
