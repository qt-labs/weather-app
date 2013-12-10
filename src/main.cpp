/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the FOO module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <QtCore/QString>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQml>

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
    { "CitiesModel", 1, 0 },
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
