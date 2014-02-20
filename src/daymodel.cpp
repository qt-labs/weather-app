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
    if (role == FromRole)
        return m_data.at(index.row()).from;
    if (role == WeatherUrlRole)
        return m_data.at(index.row()).weatherUrl;
    if (role == ToRole)
        return m_data.at(index.row()).to;
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
    rn[FromRole]        = "from";
    rn[WeatherUrlRole]  = "weatherUrl";
    rn[ToRole]          = "to";
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

void DayModel::addRow(QString weatherUrl, QString from, QString to, QString temperature, QString windSpeed, QString windUrl, QString rain) {
    QStringList m_images;
    DayModelStructure temp;
    temp.from = from;
    temp.weatherUrl = weatherUrl;
    m_images.append(weatherUrl);
    QString largeWeatherIconUrl = weatherUrl;
    m_images.append(largeWeatherIconUrl.replace("b100", "b200"));
    temp.to = to;
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
    QString baseFilename = url.right(url.length() - url.lastIndexOf("/") - 1);
    QString filename = baseFilename;
    if (isLargeImage)
        filename.prepend("large_");
    filename = QString("%1%2").arg(ApplicationPaths::dowloadedFilesPath()).arg(filename);
    baseFilename = QString("%1%2").arg(ApplicationPaths::dowloadedFilesPath()).arg(baseFilename);;
    QFile file(filename);
    if (file.exists()) {
        return QUrl(QString("image://weatherImages/%1").arg(filename));
    } else {
        QFile standardSize(baseFilename);
        // Some large icons are not available anymore on yr.no
        if (isLargeImage && standardSize.exists())
            return QUrl(QString("image://weatherImages/%1").arg(baseFilename));
        else
            return QUrl(url);
    }
}

QString DayModel::getDayDetails(int index, QString prop) const
{
    if (index == -1)
        index = 0;
    if (index < m_data.count()) {
        DayModelStructure temp = m_data.at(index);
        if (prop == "from")
            return temp.from;
        if (prop == "weatherUrl")
            return temp.weatherUrl;
        if (prop == "to")
            return temp.to;
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
