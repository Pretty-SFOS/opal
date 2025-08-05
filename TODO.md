<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# TODO

## General

- [x] use `qml/modules` instead of `qml/opal-modules` as default modules path
- [x] package translations with modules
- [x] merge module translations with app translations
- [x] bundle module metadata in module repos
    - [x] about the module: license, author, etc. (maybe as JSON)
    - [x] example page(s) to be included in Gallery
    - [x] module documentation as `qch` file (built in `release-module.sh`)
- [x] split snippets for app developers and for Opal development
- [ ] proper versioning
    - [x] ~~documentation~~
    - [x] Semantic Versioning for all modules...
    - [x] ...snippets
    - [ ] ...resources etc.
- [x] documentation
    - [x] properly document the documentation process
    - [x] use `qdoc` or `doxygen`
        Problem: QtCreator auto-completes documentation comments only in C++
        files. It is tedious to write doc comments manually in QML files.

        About Qt documentation:

        - using doxygen with QML: https://invent.kde.org/sdk/doxyqml/
        - https://wiki.qt.io/Writing_Qt_Documentation
        - https://doc.qt.io/qt-5/qdoc-index.html
        - https://doc.qt.io/qt-5/qtwritingstyle-qml.html
        - https://retifrav.github.io/blog/2017/05/24/documenting-qt-project-with-qdoc/
        - https://doc.qt.io/qtcreator/creator-help.html#adding-external-documentation
    - [x] solution: we use `qdoc`, it is not that tedious after all and has good
          integration in QtCreator

## Modules

- Snippets
    - [x] ~~implement fetching module sources in `opal-use-modules.pri`~~
    - [x] remove `opal-fetch-modules.pri` stub
    - [x] implement script to merge translations
    - [x] remove `opal-use-modules.pri`
    - [ ] document `opal-merge-translations.sh`
- Gallery
    - [x] general clean up
    - [x] update to use latest About module
    - [x] make 'about this module' page more accessible
    - [x] improve translations
    - [x] update readme
    - [x] automatically fetch latest modules
    - [x] move module example pages to module repos
- About
    - [x] in-depth, detailed documentation
    - [x] support multiple maintainers, authors
    - [x] ~~differentiate between current maintainers and authors~~
    - [x] add authors/maintainers contrib section automatically
    - [x] basic documentation
    - [x] improve loading time; load licenses asynchronously
    - [x] allow multiple buttons per section
    - [x] default button for translations, next to / below source code
    - [x] default button(s) and translations for donations
        - [x] defaults for different providers?
    - [x] decouple main license and third-party licenses
        - [x] automatically add app name to main license (as component name)
    - [x] automatically include third-party attributions in contributors page
        - [x] make them clickable and open the resp. license
- TabBar
    - [ ] import to Opal
    - [ ] add example page
    - [ ] try to remove all reliance on internal/undocumented Silica features (`__silica...`)
    - [ ] documentation
- ~~ErrorFeedback~~
    - [ ] ~~import to Opal~~
    - [ ] ~~add example page~~
    - [ ] ~~clean up and unify API~~
    - [ ] ~~documentation~~

## Resources

- extra icons
    - [ ] add metadata
    - [ ] add example page
    - [ ] include in gallery app
    - [ ] develop simple and user friendly way to include custom resources
          without having to use QRC files
          - [ ] how to package?
          - [ ] add support in release-module.sh
          - [ ] add documentation
