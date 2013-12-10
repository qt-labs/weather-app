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

OTHER_FILES += $$APP_FILES

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
