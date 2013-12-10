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

#include <QtCore/QDir>
#include <QtCore/QCoreApplication>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkAccessManager>

#include "daymodel.h"
#include "applicationpaths.h"
#include <QDebug>

DayModel::DayModel()
    : QObject(), m_afternoonindex(0) {
}

QVariant DayModel::data(const QModelIndex &index, int role) const
{
    if (role == DayRole)
        return m_data.at(index.row()).day;
    if (role == WeatherUrlRole)
        return m_data.at(index.row()).weatherUrl;
    if (role == TimeRangeRole)
        return m_data.at(index.row()).timeRange;
    if (role == TemperatureRole)
        return m_data.at(index.row()).temperature;
    if (role == WindSpeedRole)
        return m_data.at(index.row()).windSpeed;
    if (role == WindUrlRole)
        return m_data.at(index.row()).windUrl;
    if (role == RainRole)
        return m_data.at(index.row()).rain;
    return QVariant();
}

QHash<int, QByteArray> DayModel::roleNames() const
{
    QHash<int, QByteArray> rn;
    rn[DayRole]         = "day";
    rn[WeatherUrlRole]  = "weatherUrl";
    rn[TimeRangeRole]   = "timeRange";
    rn[TemperatureRole] = "temperature";
    rn[WindSpeedRole]   = "windSpeed";
    rn[WindUrlRole]     = "windUrl";
    rn[RainRole]        = "rain";
    return rn;
}

void DayModel::clear()
{
    m_date = QString();
    m_afternoonindex = 0;
    m_data.clear();
}

void DayModel::addRow(QString day, QString weatherUrl, QString timeRange, QString temperature, QString windSpeed, QString windUrl, QString rain) {
    QStringList m_images;
    DayModelStructure temp;
    temp.day = day;
    temp.weatherUrl = weatherUrl;
    m_images.append(weatherUrl);
    QString largeWeatherIconUrl = weatherUrl;
    m_images.append(largeWeatherIconUrl.replace("b100", "b200"));
    temp.timeRange = timeRange;
    temp.temperature = temperature;
    temp.windSpeed = windSpeed;
    temp.windUrl = windUrl;
    m_images.append(windUrl);
    temp.rain = rain;
    m_data.append(temp);
    emit addedImages(m_images);
}

QUrl DayModel::getCachedImageFile(const QString url)
{
    bool isLargeImage = url.contains("b200");
    QString filename = url.right(url.length() - url.lastIndexOf("/") - 1);
    if (isLargeImage)
        filename.prepend("large_");
    filename = QString("%1%2").arg(ApplicationPaths::dowloadedFilesPath()).arg(filename);
    QFile file(filename);
    if (file.exists())
        return QUrl(QString("image://weatherImages/%1").arg(filename));
    else
        return QUrl(url);
}

QString DayModel::getDayDetails(int index, QString prop) const
{
    if (index == -1)
        index = 0;
    if (index < m_data.count()) {
        DayModelStructure temp = m_data.at(index);
        if (prop == "day")
            return temp.day;
        if (prop == "weatherUrl")
            return temp.weatherUrl;
        if (prop == "timeRange")
            return temp.timeRange;
        if (prop == "temperature")
            return temp.temperature;
        if (prop == "windSpeed")
            return temp.windSpeed;
        if (prop == "windUrl")
            return temp.windUrl;
        if (prop == "rain")
            return temp.rain;
    }
    return QString();
}
