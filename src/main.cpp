/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <QtCore/QString>
#include <QtCore/QTranslator>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQml/QQmlApplicationEngine>

#if defined(Q_OS_WINRT) && !defined(Q_OS_WINPHONE)
#  include "winrtcharms.h"
#  include <QtGui/QDesktopServices>
#endif // Q_OS_WINRT && !Q_OS_WINPHONE

#include "daymodel.h"
#include "citymodel.h"
#include "cities.h"
#include "applicationinfo.h"
#include "weatherimageprovider.h"

static const struct {
    const char *type;
    int major, minor;
} qmldir_touch [] = {
    { "TouchSlider", 1, 0 },
    { "TouchScrollView", 1, 0 },
    { "TouchLabel", 1, 0 },
    { "TouchTextField", 1, 0 },
    { "ListViewDelegate", 1, 0 },
    { "ListViewDelegateLoading", 1, 0 },
};

static const struct {
    const char *type;
    int major, minor;
} qmldir_models [] = {
    { "WeatherModel", 1, 0 },
};

static const struct {
    const char *type;
    int major, minor;
} qmldir_pages [] = {
    { "CitiesPage", 1, 0 },
    { "LongTermPage", 1, 0 },
    { "OneDayPage", 1, 0 },
};

static QObject *systeminfo_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    WeatherImageProvider *provider = new WeatherImageProvider();
    engine->addImageProvider(QLatin1String("weatherImages"), provider);
    return new ApplicationInfo(provider);
}

int main(int argc, char *argv[])
{
    QGuiApplication  app(argc, argv);
    app.setOrganizationName("Digia");
    app.setApplicationName("QuickForecast");

    QTranslator qtTranslator;
    qtTranslator.load("QuickForecast_" + QLocale::system().name(), ":/translations/");
    app.installTranslator(&qtTranslator);

#if defined(Q_OS_WINRT) && !defined(Q_OS_WINPHONE)
    // WinRT requires that we install a privacy policy link to the Charms bar when the network is
    // used, so create a Charms menu item and connect a slot to handle it
    WinRTSettingsCharm settingsCharm;
    settingsCharm.addItem(QGuiApplication::tr("Privacy Policy"));
    QObject::connect(&settingsCharm, &WinRTSettingsCharm::itemClicked, [](const QString &) {
        QDesktopServices::openUrl(QUrl("http://qt.digia.com/Digia-Legal-Notice--Privacy-Policy/"));
    });
#endif // Q_OS_WINRT && !Q_OS_WINPHONE

#ifndef Q_OS_IOS //QTBUG-34490
    QFontDatabase::addApplicationFont(":/weatherapp/fonts/OpenSans-Bold.ttf");
    QFontDatabase::addApplicationFont(":/weatherapp/fonts/OpenSans-Semibold.ttf");
    int openSansID = QFontDatabase::addApplicationFont(":/weatherapp/fonts/OpenSans-Regular.ttf");
    QStringList loadedFontFamilies = QFontDatabase::applicationFontFamilies(openSansID);
    if (!loadedFontFamilies.empty()) {
        QString fontName = loadedFontFamilies.at(0);
        QGuiApplication::setFont(QFont(fontName));
    } else {
        qWarning("Error: fail to load Open Sans font");
    }
#endif

    const char *uri = "org.qtproject.demo.weather";
    // @uri org.qtproject.demo.weather
    qmlRegisterType<DayModel>(uri, 1, 0, "DayModel");
    qmlRegisterType<CityModel>(uri, 1, 0, "CityModel");
    qmlRegisterType<Cities>(uri, 1, 0, "Cities");
    qmlRegisterType<CitiesListModel>(uri, 1, 0, "CitiesListModel");
    qmlRegisterSingletonType<ApplicationInfo>(uri, 1, 0, "ApplicationInfo", systeminfo_provider);

    for (int i = 0; i < int(sizeof(qmldir_touch)/sizeof(qmldir_touch[0])); i++)
        qmlRegisterType(QUrl(QString("qrc:/weatherapp/qml/touch/%1.qml").arg(qmldir_touch[i].type)), uri, qmldir_touch[i].major, qmldir_touch[i].minor, qmldir_touch[i].type);

    for (int i = 0; i < int(sizeof(qmldir_models)/sizeof(qmldir_models[0])); i++)
        qmlRegisterType(QUrl(QString("qrc:/weatherapp/qml/models/%1.qml").arg(qmldir_models[i].type)), uri, qmldir_models[i].major, qmldir_models[i].minor, qmldir_models[i].type);

    for (int i = 0; i < int(sizeof(qmldir_pages)/sizeof(qmldir_pages[0])); i++)
        qmlRegisterType(QUrl(QString("qrc:/weatherapp/qml/pages/%1.qml").arg(qmldir_pages[i].type)), uri, qmldir_pages[i].major, qmldir_pages[i].minor, qmldir_pages[i].type);

    QQmlApplicationEngine engine(QUrl("qrc:/weatherapp/qml/main.qml"));
    QObject *topLevel = engine.rootObjects().value(0);

    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    window->show();
    return app.exec();
}
