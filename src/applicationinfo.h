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
#ifndef APPLICATIONINFO_H
#define APPLICATIONINFO_H

#include <QtCore/QObject>
#include <QtQml/QQmlPropertyMap>

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
class QNetworkReply;
QT_END_NAMESPACE

class WeatherImageProvider;

#include "citymodel.h"
#include "citieslistmodel.h"

class ApplicationInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int applicationWidth READ applicationWidth WRITE setApplicationWidth NOTIFY applicationWidthChanged)
    Q_PROPERTY(bool isMobile READ isMobile CONSTANT)
    Q_PROPERTY(QObject *colors READ colors CONSTANT)
    Q_PROPERTY(QObject *constants READ constants CONSTANT)
    Q_PROPERTY(bool isPortraitMode READ isPortraitMode WRITE setIsPortraitMode NOTIFY portraitModeChanged)
    Q_PROPERTY(int currentIndexDay READ currentIndexDay WRITE setCurrentIndexDay NOTIFY currentIndexDayChanged)
    Q_PROPERTY(CityModel *currentCityModel READ currentCityModel WRITE setCurrentCityModel NOTIFY currentCityModelChanged)
    Q_PROPERTY(CitiesListModel *foundCities READ foundCities NOTIFY foundCitiesChanged)
    Q_PROPERTY(qreal ratio READ ratio CONSTANT)
    Q_PROPERTY(qreal hMargin READ hMargin NOTIFY hMarginChanged)
    Q_PROPERTY(qreal sliderHandleWidth READ sliderHandleWidth CONSTANT)
    Q_PROPERTY(qreal sliderHandleHeight READ sliderHandleHeight CONSTANT)
    Q_PROPERTY(qreal sliderGapWidth READ sliderGapWidth CONSTANT)

public:
    ApplicationInfo(WeatherImageProvider *provider);

    bool isMobile() const { return m_isMobile; }
    QQmlPropertyMap *colors() const { return m_colors; }
    QQmlPropertyMap *constants() const { return m_constants; }

    CityModel *currentCityModel() const { return m_currentCityModel; }
    void setCurrentCityModel(CityModel *model);

    int applicationWidth() const { return m_applicationWidth; }
    void setApplicationWidth(const int newWidth);

    int currentIndexDay() const { return m_currentIndexDay; }
    void setCurrentIndexDay(const int index);

    bool isPortraitMode() const { return m_isPortraitMode; }
    void setIsPortraitMode(const bool newMode);

    CitiesListModel *foundCities() { return m_citiesFound; }

    qreal hMargin() const { return m_hMargin; }
    qreal ratio() const { return m_ratio; }
    qreal sliderHandleHeight()  { return m_sliderHandleHeight; }
    qreal sliderGapWidth()  { return m_sliderGapWidth; }
    qreal sliderHandleWidth()  { return m_sliderHandleWidth; }

    Q_INVOKABLE QString getImagePath(const QString image);
    Q_INVOKABLE void queryCities(const QString input);

protected slots:
    void notifyPortraitMode(Qt::ScreenOrientation);

private slots:
    void replyFinished(QNetworkReply *reply);

protected:
    qreal getSizeWithRatio(const qreal height) { return ratio() * height; }

signals:
    void applicationWidthChanged();
    void portraitModeChanged();
    void hMarginChanged();
    void currentCityModelChanged();
    void currentIndexDayChanged();
    void foundCitiesChanged();
    void waitForCitiesQueryReply(const QString message);
    void errorOnQueryCities(const QString errorMessage);

private:
    int m_applicationWidth;
    QQmlPropertyMap *m_colors;
    QQmlPropertyMap *m_constants;
    CityModel *m_currentCityModel;
    bool m_isPortraitMode;
    int m_currentIndexDay;
    QNetworkAccessManager *manager;
    CitiesListModel *m_citiesFound;
    bool m_isMobile;
    qreal m_ratio;
    qreal m_hMargin;
    qreal m_sliderHandleHeight, m_sliderHandleWidth, m_sliderGapWidth;
    WeatherImageProvider *imageProvider;
};

#endif // APPLICATIONINFO_H
