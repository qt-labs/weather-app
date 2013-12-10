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

