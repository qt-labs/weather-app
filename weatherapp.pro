cache()

TEMPLATE = app
QT += qml quick gui network xmlpatterns
TARGET = QuickForecast

include(src/src.pri)

APP_FILES = \
    $$PWD/qml/main.qml \
    $$PWD/qml/pages/BasicPage.qml \
    $$PWD/qml/pages/CitiesPage.qml \
    $$PWD/qml/pages/OneDayPage.qml \
    $$PWD/qml/pages/LongTermPage.qml \
    $$PWD/qml/pages/LongTermDayItem.qml \
    $$PWD/qml/pages/OneDayZoomItem.qml \
    $$PWD/qml/pages/OneDaySliderItem.qml \
    $$PWD/qml/pages/Separator.qml \
    $$PWD/qml/models/WeatherModel.qml \
    $$PWD/qml/js/utils.js

# Touch Styled Controls
APP_FILES += \
    $$PWD/qml/touch/TouchLabel.qml \
    $$PWD/qml/touch/TouchScrollView.qml \
    $$PWD/qml/touch/TouchSlider.qml \
    $$PWD/qml/touch/TouchTextField.qml \
    $$PWD/qml/touch/ListViewDelegate.qml \
    $$PWD/qml/touch/images/BackArrow.png \
    $$PWD/qml/touch/images/Pointer.png \
    $$PWD/qml/touch/images/Pointer_pressed.png \
    $$PWD/qml/touch/images/Circle.png \
    $$PWD/qml/touch/images/darkclose.png \
    $$PWD/qml/touch/images/magnifier.png \
    $$PWD/qml/touch/images/Clear.png

# Fonts
APP_FILES += \
    $$PWD/fonts/OpenSans-Bold.ttf \
    $$PWD/fonts/OpenSans-Semibold.ttf \
    $$PWD/fonts/OpenSans-Regular.ttf

OTHER_FILES += $$APP_FILES $$PWD/translations/README

# var, prepend, append
defineReplace(prependAll) {
    for(a,$$1):result += $$2$${a}$$3
    return($$result)
}

# Supported languages
LANGUAGES =

# Available translations
TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/translations/QuickForecast_, .ts)

# Used to embed the qm files in resources
TRANSLATIONS_FILES =

# run LRELEASE to generate the qm files
qtPrepareTool(LRELEASE, lrelease)
for(tsfile, TRANSLATIONS) {
    qmfile = $$shadowed($$tsfile)
    qmfile ~= s,\\.ts$,.qm,
    qmdir = $$dirname(qmfile)
    !exists($$qmdir) {
        mkpath($$qmdir)|error("Aborting.")
    }
    command = $$LRELEASE -removeidentical $$tsfile -qm  $$qmfile
    system($$command)|error("Failed to run: $$command")
    TRANSLATIONS_FILES += $$qmfile
}

# Create the resource file
GENERATED_RESOURCE_FILE = $$OUT_PWD/weatherapp.qrc

RESOURCE_CONTENT = \
    "<RCC>" \
    "<qresource>"

for(resourcefile, APP_FILES) {
    resourcefileabsolutepath = $$absolute_path($$resourcefile)
    relativepath_in = $$relative_path($$resourcefileabsolutepath, $$_PRO_FILE_PWD_)
    relativepath_out = $$relative_path($$resourcefileabsolutepath, $$OUT_PWD)
    RESOURCE_CONTENT += "<file alias=\"weatherapp/$$relativepath_in\">$$relativepath_out</file>"
}

for(translationfile, TRANSLATIONS_FILES) {
    relativepath_out = $$relative_path($$translationfile, $$OUT_PWD)
    RESOURCE_CONTENT += "<file alias=\"$$relativepath_out\">$$relativepath_out</file>"
}

RESOURCE_CONTENT += \
    "</qresource>" \
    "</RCC>"

write_file($$GENERATED_RESOURCE_FILE, RESOURCE_CONTENT)|error("Aborting.")

RESOURCES += $$GENERATED_RESOURCE_FILE

ios {
    FONTS.files = $$PWD/fonts/OpenSans-Bold.ttf $$PWD/fonts/OpenSans-Semibold.ttf $$PWD/fonts/OpenSans-Regular.ttf
    FONTS.path = fonts
    QMAKE_BUNDLE_DATA += FONTS
    QMAKE_INFO_PLIST = ios/iosInfo.plist
}

android: ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

# TRANSLATIONS - Create extra targets for convenience

wd = $$replace(PWD, /, $$QMAKE_DIR_SEP)

# LUPDATE - Make new targets for each and all languages
qtPrepareTool(LUPDATE, lupdate)
LUPDATE += -locations relative -no-ui-lines
TSFILES = $$files($$PWD/translations/QuickForecast_*.ts) $$PWD/translations/QuickForecast_untranslated.ts
for(file, TSFILES) {
    lang = $$replace(file, .*_([^/]*)\\.ts, \\1)
    v = ts-$${lang}.commands
    $$v = cd $$wd && $$LUPDATE $$SOURCES $$APP_FILES -ts $$file
    QMAKE_EXTRA_TARGETS += ts-$$lang
}
ts-all.commands = cd $$PWD && $$LUPDATE $$SOURCES $$APP_FILES -ts $$TSFILES
QMAKE_EXTRA_TARGETS += ts-all

# COMMIT - Make a new target for lconvert and committing the ts files
# lconvert is used to remove the strings location in the ts files
# and thus save space.
qtPrepareTool(LCONVERT, lconvert)
LCONVERT += -locations none
isEqual(QMAKE_DIR_SEP, /) {
    commit-ts.commands = \
        cd $$wd; \
        git add -N translations/*_??.ts && \
        for f in `git diff-files --name-only translations/*_??.ts`; do \
            $$LCONVERT -i \$\$f -o \$\$f; \
        done; \
        git add translations/*_??.ts && git commit
} else {
    commit-ts.commands = \
        cd $$wd && \
        git add -N translations/*_??.ts && \
        for /f usebackq %%f in (`git diff-files --name-only -- translations/*_??.ts`) do \
            $$LCONVERT -i %%f -o %%f $$escape_expand(\\n\\t) \
        cd $$wd && git add translations/*_??.ts && git commit
}
QMAKE_EXTRA_TARGETS += commit-ts

