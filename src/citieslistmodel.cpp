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

#include "citieslistmodel.h"
#include <QDebug>

CitiesListModel::CitiesListModel(QObject *parent) :
    QAbstractListModel(parent), m_isEmpty(true)
{
}

QVariant CitiesListModel::data(const QModelIndex & index, int role) const
{
    Q_ASSERT(index.row() < m_foundCities.count());
    if (role == CountryRole)
        return QString(m_foundCities.at(index.row()).first).replace("_", " ");
    else
        return QVariant("");
}

int CitiesListModel::rowCount(const QModelIndex & /*parent*/) const
{
    return m_foundCities.count();
}

QString CitiesListModel::getCitySourceXml(const int index)
{
    Q_ASSERT(index > -1);
    Q_ASSERT(index < m_foundCities.count());
    CityXmlPair pair = m_foundCities.at(index);
    // In order to use yr.no weather data service, refer to their terms
    // and conditions of use. http://om.yr.no/verdata/free-weather-data/
    return QString("http://www.yr.no%1forecast.xml").arg(pair.second);
}

void CitiesListModel::addCities(QStringList listCities)
{
    clear();
    QList<CityXmlPair> temp;
    if (!listCities.empty()) {
        for (int i = 0; i < listCities.count(); i++)
        {
            QRegExp regExp2;
            regExp2.setPattern("^\"(.*)\",\"(.*)\",\"(.*)\",\"(.*)\"$");
            regExp2.exactMatch(listCities.at(i));
            QString cityName = regExp2.capturedTexts().at(1);
            QString countryName = regExp2.capturedTexts().at(3);
            QString xml = regExp2.capturedTexts().at(2);
            QRegExp regExp3;
            regExp3.setPattern("^/place/.*/.*/.*/$");
            if (countryName.isEmpty() || countryName.contains("Municipality") || !regExp3.exactMatch(xml))
                continue; // We want cities forecast only
            QString name = cityName + " - " + countryName;
            temp.append(qMakePair(name, xml));
        }
    }

    if (!temp.isEmpty()) {
        beginInsertRows(QModelIndex(), 0, temp.count() - 1);
        m_foundCities.append(temp);
        m_isEmpty = false;
    } else {
        beginInsertRows(QModelIndex(), 0, 0);
        m_foundCities.append(qMakePair(tr("no city found"), QString("")));
    }

    endInsertRows();
}

void CitiesListModel::clear()
{
    m_isEmpty = true;
    if (m_foundCities.count() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_foundCities.count() - 1);
        m_foundCities.clear();
        endRemoveRows();
    }
}

QHash<int, QByteArray> CitiesListModel::roleNames() const
{
    QHash<int, QByteArray> rn;
    rn[CountryRole] = "country";
    rn[NameRole] = "name"; // needed to use in delegate that read both roles (country and name)
    return rn;
}

