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
    Q_PROPERTY(QObject *colors READ colors CONSTANT)
    Q_PROPERTY(QObject *constants READ constants CONSTANT)
    Q_PROPERTY(bool isPortraitMode READ isPortraitMode WRITE setIsPortraitMode NOTIFY portraitModeChanged)
    Q_PROPERTY(int currentIndexDay READ currentIndexDay WRITE setCurrentIndexDay NOTIFY currentIndexDayChanged)
    Q_PROPERTY(CityModel *currentCityModel READ currentCityModel WRITE setCurrentCityModel NOTIFY currentCityModelChanged)
    Q_PROPERTY(CitiesListModel *foundCities READ foundCities NOTIFY foundCitiesChanged)
    Q_PROPERTY(qreal ratio READ ratio NOTIFY ratioChanged)
    Q_PROPERTY(qreal hMargin READ hMargin NOTIFY hMarginChanged)
    Q_PROPERTY(qreal sliderHandleWidth READ sliderHandleWidth NOTIFY ratioChanged)
    Q_PROPERTY(qreal sliderHandleHeight READ sliderHandleHeight NOTIFY ratioChanged)
    Q_PROPERTY(qreal sliderGapWidth READ sliderGapWidth NOTIFY ratioChanged)

public:
    ApplicationInfo(WeatherImageProvider *provider);

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
    void notifyPortraitMode();

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
    void ratioChanged();
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
