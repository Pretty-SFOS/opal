<!--
SPDX-FileCopyrightText: 2021-2022 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# How to pass build options to QML

This snippet helps with passing values like the current version number of an app
from `yaml`, `spec`, or `pro` into QML.

Include [opal-cached-defines.pri] in your `harbour-<app>.pro` file after
defining all options you want to pass through. Include `requires_defines.h`
(generated) in all C++ files that require these options. When any values change,
the relevant files will be rebuilt.

1. Prepare YAML
  - only required when passing variables defined in `yaml` (when not using `yaml`,
    you can also define this directly in the `spec` file)
  - make sure `Builder:` is set to `qmake5`
  - include your options in `QMakeOptions:`

```YAML
### in rpm/harbour-myproject.yaml:
Builder: qmake5
QMakeOptions:
    - VERSION=%{version}
    - RELEASE=%{release}
```

2. Prepare PRO
  - add all options to `DEFINES`
  - include `opal-cached-defines.pri` afterwards

```QMake
### in harbour-myproject.pro:
# Note: version number is configured in yaml
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"
include(libs/opal-cached-defines.pri)
```

3. Include `requires_defines.h` in the relevant files
  - if you used the default project file you have to prepare the QML view first
  - the code below is fine as-is for simple projects

```CPP
//// in src/harbour-myproject.cpp:
#include "requires_defines.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-myapp"); // needed for Sailjail
    app->setApplicationName("harbour-myapp");
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", QString(APP_VERSION));
    view->rootContext()->setContextProperty("APP_RELEASE", QString(APP_RELEASE));
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
```

4. Run `qmake` after any change to the definitions, otherwise the process will
   not work. Note: the Sailfish SDK often automatically offers to run `qmake`
   when necessary.
