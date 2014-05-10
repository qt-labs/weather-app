/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
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

#include <QtCore/QFile>
#include <QtCore/qmath.h>
#include <QtCore/QRegExp>
#include <QtCore/QUrl>
#include <QtCore/QUrlQuery>
#include <QtGui/QGuiApplication>
#include <QtGui/QScreen>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>

#include "applicationinfo.h"
#include "weatherimageprovider.h"
#include <QDebug>

ApplicationInfo::ApplicationInfo(WeatherImageProvider *provider)
    : imageProvider(provider)
{

    m_isMobile = false;
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_BLACKBERRY)
    m_isMobile = true;
#endif

    m_colors = new QQmlPropertyMap(this);
    m_colors->insert(QLatin1String("white"), QVariant("#ffffff"));
    m_colors->insert(QLatin1String("smokeGray"), QVariant("#eeeeee"));
    m_colors->insert(QLatin1String("paleGray"), QVariant("#d7d6d5"));
    m_colors->insert(QLatin1String("lightGray"), QVariant("#aeadac"));
    m_colors->insert(QLatin1String("darkGray"), QVariant("#35322f"));
    m_colors->insert(QLatin1String("mediumGray"), QVariant("#5d5b59"));
    m_colors->insert(QLatin1String("doubleDarkGray"), QVariant("#1e1b18"));
    m_colors->insert(QLatin1String("blue"), QVariant("#14aaff"));
    m_colors->insert(QLatin1String("darkBlue"), QVariant("#14148c"));

    m_constants = new QQmlPropertyMap(this);
    m_constants->insert(QLatin1String("isMobile"), QVariant(m_isMobile));
    m_constants->insert(QLatin1String("errorLoadingImage"), QVariant(tr("Error loading image - Host not found or unreachable")));

    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    m_citiesFound = new CitiesListModel(this);

    QRect rect = qApp->primaryScreen()->geometry();
    m_ratio = m_isMobile ? qMin(qMax(rect.width(), rect.height())/1136. , qMin(rect.width(), rect.height())/640.) : 1;
    m_sliderHandleWidth = getSizeWithRatio(70);
    m_sliderHandleHeight = getSizeWithRatio(87);
    m_sliderGapWidth = getSizeWithRatio(100);
    m_isPortraitMode = m_isMobile ? rect.height() > rect.width() : false;
    m_hMargin =  m_isPortraitMode ? 20 * ratio() : 50 * ratio();
    m_applicationWidth = m_isMobile ? rect.width() : 1120;

    m_constants->insert(QLatin1String("rowDelegateHeight"), QVariant(getSizeWithRatio(118)));

    m_currentIndexDay = -1;

    if (m_isMobile)
        connect(qApp->primaryScreen(), SIGNAL(primaryOrientationChanged(Qt::ScreenOrientation)), this, SLOT(notifyPortraitMode(Qt::ScreenOrientation)));

    // Search in English
    // In order to use yr.no weather data service, refer to their terms
    // and conditions of use. http://om.yr.no/verdata/free-weather-data/
    QUrl searchUrl2("http://www.yr.no/_/settspr.aspx");
    QUrlQuery query2;
    query2.addQueryItem("spr", "eng");
    query2.addQueryItem("redir", "/");
    searchUrl2.setQuery(query2);
    manager->get(QNetworkRequest(searchUrl2));
}

void ApplicationInfo::setCurrentCityModel(CityModel *model)
{
    if (model != m_currentCityModel)
    {
        m_currentCityModel = model;
        emit currentCityModelChanged();
    }
}

void ApplicationInfo::setCurrentIndexDay(const int index)
{
    if (index != m_currentIndexDay) {
        m_currentIndexDay = index;
        emit currentIndexDayChanged();
    }
}

void ApplicationInfo::setApplicationWidth(const int newWidth)
{
    if (newWidth != m_applicationWidth) {
        m_applicationWidth = newWidth;
        emit applicationWidthChanged();
    }
}

QString ApplicationInfo::getImagePath(const QString image)
{
    return QString("qrc:/weatherapp/qml/touch/images/%1").arg(image);
}

void ApplicationInfo::notifyPortraitMode(Qt::ScreenOrientation orientation)
{
    switch (orientation) {
    case Qt::LandscapeOrientation:
    case Qt::InvertedLandscapeOrientation:
        setIsPortraitMode(false);
        break;
    case Qt::PortraitOrientation:
    case Qt::InvertedPortraitOrientation:
        setIsPortraitMode(true);
        break;
    default:
        break;
    }
}

void ApplicationInfo::setIsPortraitMode(const bool newMode)
{
    if (m_isPortraitMode != newMode) {
        m_isPortraitMode = newMode;
        m_hMargin = m_isPortraitMode ? 20 * ratio() : 50 * ratio();
        emit portraitModeChanged();
        emit hMarginChanged();
    }
}

void ApplicationInfo::queryCities(const QString input)
{
    if (input.isEmpty())
        return;
    // In order to use yr.no weather data service, refer to their terms
    // and conditions of use. http://om.yr.no/verdata/free-weather-data/
    QUrl searchUrl("http://www.yr.no/_/websvc/jsonforslagsboks.aspx");
    QUrlQuery query;
    query.addQueryItem("s", input);
    searchUrl.setQuery(query);
    manager->get(QNetworkRequest(searchUrl));
    m_citiesFound->clear();
    waitForCitiesQueryReply(tr("Waiting for cities, network may be slow..."));
}

void ApplicationInfo::replyFinished(QNetworkReply *reply)
{
    waitForCitiesQueryReply("");
    if (reply->request().url().query() != "spr=eng&redir=/" ) {
        if (reply->error() != QNetworkReply::NoError) {
            emit(errorOnQueryCities(tr("Network error: %1").arg(reply->errorString())));
            m_citiesFound->addCities();
        } else {
            QString data = reply->readAll();
            QRegExp regExp;
            regExp.setPattern("^\\[\\[.*\\],\\[\\[(.*)\\]\\]\\]$");
            regExp.exactMatch(data);
            QString foundCities = regExp.capturedTexts().at(1);
            QStringList citiesFound = foundCities.split(QRegExp("\\],\\["), QString::SkipEmptyParts);
            m_citiesFound->addCities(citiesFound);
        }
    }
    if (reply) {
        reply->deleteLater();
        reply = 0;
    }
}

