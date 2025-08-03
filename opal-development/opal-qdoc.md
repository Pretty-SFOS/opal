<!--
SPDX-FileCopyrightText: 2021 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Opal documentation using qdoc

Documentation for Opal modules is generated automatically when running the
[the release script](opal-release-module.md) `release-module.sh`. You can use the
`-d` option to generate only the documentation instead of the full release bundle.

Module metadata is read from the module file `doc/module.opal`.


## Adding documentation to QtCreator

You can add the documentation to QtCreator via `Extras` → `Settings` → `Help`
→ `Documentation` → `Add` and selecting the generated `qch` file. Refer to the
[QtCreator manual](https://doc.qt.io/qtcreator/creator-help.html#adding-external-documentation)
for further information.

**Note:** to reload documentation in QtCreator after modifying and rebuilding,
simply open the `Documentation` settings dialog and press the `Apply` button
without re-adding the `qch` file.


## Important commands

All commands are documented here: [QDoc commands reference](https://doc.qt.io/archives/qt-5.15/27-qdoc-commands-alphabetical.html)

**Markup:**

    \c Text             print "Text" using code font
                        note: use curly brackets to include spaces: \c {Lorem ipsum}
                        see: https://doc.qt.io/archives/qt-5.15/04-qdoc-commands-textmarkup.html

    \note Paragraph     include a "note" block
                        see: https://doc.qt.io/archives/qt-5.15/11-qdoc-commands-specialcontent.html

    \defaultValue {X}   state the default value of a property
                        note: when using this, always set it as the last line of the documentation block
                              but before the \sa line
                        note: this is an extension provided by Opal

**References:**

    \l Component        link to a QML component in your module
                        note: use curly brackets when linking to a property in another
                              component: \l {MyParentItem::myProperty}
                        see: https://doc.qt.io/archives/qt-5.15/08-qdoc-commands-creatinglinks.html

    \sa Item, Item      add a list of "see also" links, separate items using comma
                        note: when using this, always set it as the last line of the documentation block
                        see: https://doc.qt.io/archives/qt-5.15/08-qdoc-commands-creatinglinks.html

    \a parameter        when documenting functions in a QML or JS file, document its parameters with this
                        see: https://doc.qt.io/archives/qt-5.15/04-qdoc-commands-textmarkup.html#a-command
                             https://doc.qt.io/archives/qt-5.15/13-qdoc-commands-topics.html#qmlmethod-command

**Code:**

    \qml                include a QML code block with syntax highlighting
    \endqml             see: https://doc.qt.io/archives/qt-5.15/06-qdoc-commands-includecodeinline.html

    \code               include a code block without markup
    \endcode


## Documenting QML files

```qml
//@ This file is part of opal-mymodule.
//@ https://github.com/Pretty-SFOS/opal-mymodule
//@ SPDX-FileCopyrightText: 2025 Your Name
//@ SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.6
import Sailfish.Silica 1.0

/*!
    \qmltype MyItem                 the name of your QML item as stated in the qmldir file
                                    (this is usually the file name)
    \inqmlmodule Opal.MyModule      the full name of your Opal module including the "Opal." prefix
    \since version 1.0.0            optional: in which version of your module this was introduced
    \inherits MyParentItem          optional: which item in your Opal module this item inherits
                                    (linking to Silica or Qt components is not possible yet)

    \brief Short one-line description of this component.

    Detailed description of the component, its architecture, considerations, etc.

    \section2 Title

    Text...

    \section2 Example

    \note be kind to others...

    \qml
    import Opal.MyModule 1.0

    MyItem {
        // ...
    }
    \endqml

    \sa MyParentItem, MyOtherItem
*/
MyParentItem {
    id: root

    /*!
      This property defines the vertical alignment of the right side item.

      Allowed values are \l Qt.AlignVCenter, \l Qt.AlignTop,
      and \l Qt.AlignBottom.

      \defaultValue Qt.AlignVCenter

      \sa leftItem, rightItem
    */
    property int rightItemAlignment: Qt.AlignVCenter

    /*!
      This function toggles text wrapping in text labels.

      Provide a \l OptionalLabel as argument to toggle its
      text wrapping mode.

      You can also manually set the \l {OptionalLabel::wrapped}
      property.

      \sa OptionalLabel
    */
    function toggleWrappedText(label) {
        // ...
    }
}
```

## Documenting JS files

### Regular scripts

```js
//@ This file is part of opal-mymodule.
//@ https://github.com/Pretty-SFOS/opal-mymodule
//@ SPDX-FileCopyrightText: 2025 Your Name
//@ SPDX-License-Identifier: GPL-3.0-or-later

.pragma library

/*!
    \qmltype MyScript               the name of your script as stated in the qmldir file
    \inqmlmodule Opal.MyModule      the full name of your Opal module including the "Opal." prefix
    \since version 1.0.0            optional: in which version of your module this was introduced

    \brief Short one-line description of this component.

    \section2 Example

    \qml
    import Opal.MyModule 1.0

    // ...
    \endqml

    \sa MyItem
*/

/*!
  \qmlproperty int Script::MY_FLAG

  A simple flag.

  Use the value command to document how different values behave.

  \value 10 The default value.
  \value 11 Trigger a rainstorm.
  \value [since version 1.1] 12 Trigger sunshine.

  \defaultValue 10
*/
var MY_FLAG = 10

/*!
  \qmlmethod bool MyScript::myFunction(url, title)

  This function takes a link (\a url) and adds a \a title to it.

  Returns a string.

  \sa Qt::openUrlExternally
*/
function myFunction(url, title) {
    return String(url) + title
}
```


### Scripts used as enumerations

Make sure the script is marked as a library (`.pragma library`), then document
it as usual.

However, instead of documenting the constants separately, document them directly
in the main description:

```js
// ...

.pragma library

/*!
    \qmltype MyEnum                 the name of your script as stated in the qmldir file
    \inqmlmodule Opal.MyModule      the full name of your Opal module including the "Opal." prefix
    \since version 1.0.0            optional: in which version of your module this was introduced

    \brief Short one-line description of this component.

    \value SUNSHINE  Let the sun shine.
    \value RAIN      Unleash a thunderstorm.
    \value SNOW      Let it snow to build an igloo.
*/

var SUNSHINE = 1
var RAIN = 2
var SNOW = 3
```


## Import statements

Documented import statements automatically use version `1.0`, e.g.
`import Opal.MyModule 1.0`. You should not use versioning in your modules
(versioning is removed in Qt 6). Instead, include a `\since version X.Y.Z` line
in your documentation to mark a QML file that was introduced later.


## Further information

- https://doc.qt.io/qt-5/qtwritingstyle-qml.html
- https://wiki.qt.io/Writing_Qt_Documentation
- https://doc.qt.io/qt-5/qdoc-index.html
- https://retifrav.github.io/blog/2017/05/24/documenting-qt-project-with-qdoc/


## Outlook

Opal might switch to `doxygen` ([doxyqml](https://invent.kde.org/sdk/doxyqml/))
for building documentation in the future.
