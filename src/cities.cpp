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

#include <QtCore/QCoreApplication>
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QIODevice>
#include <QtCore/QTextStream>
#include <QtGlobal>

#include "cities.h"
#include "citymodel.h"
#include "applicationpaths.h"
#include <QDebug>

Cities::Cities(QObject *parent) :
    QAbstractListModel(parent)
{
    m_citiesFileName = QString("%1cities.settings").arg(ApplicationPaths::settingsPath());
    readCities();
}

Cities::~Cities()
{
    saveCities();
}

CityModel* Cities::getCityModel(int index)
{
    Q_ASSERT(index > -1);
    Q_ASSERT(index < m_cityMap.count());
    return m_cityMap.at(index).second;
}

void Cities::removeCityModel(int index)
{
    if (index < m_cityMap.count() && index >=0 )
    {
        beginRemoveRows(QModelIndex(), index, index);
        CityModel *modelToDelete = m_cityMap.at(index).second;
        modelToDelete->cleanAll();
        modelToDelete->deleteLater();
        m_cityMap.removeAt(index);
        endRemoveRows();
    }
}

int Cities::addCityModel(CityModel *model)
{
    CityModelPair pair = qMakePair(model->sourceXml(), model);
    int modelIndex = m_cityMap.indexOf(pair);
    if (modelIndex == -1) {
        m_cityMap.prepend(pair);
        connect(model, SIGNAL(contentXmlChanged()), this, SIGNAL(cityModelReady()));
        if (m_cityMap.count() > 15)
            removeCityModel(m_cityMap.count() - 1);
        return 0;
    }
    return modelIndex;
}

void Cities::readCities()
{
    QFile file(m_citiesFileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString sourceXml = in.readLine().trimmed();
        processSourceXml(sourceXml);
    }
    file.close();
}

int Cities::processSourceXml(const QString sourceXml)
{
    // Dont add save town/identical sourceXml twice
    for (int i = 0; i <m_cityMap.count(); i++) {
        if (m_cityMap.at(i).first == sourceXml)
            return i;
    }
    CityModel *model = new CityModel(this);
    if (model->setSourceXml(sourceXml))
        return addCityModel(model);

    model->deleteLater();
    return -1;
}

void Cities::saveCities()
{
    QFile file(m_citiesFileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;
    QTextStream out(&file);
    for (int index = m_cityMap.count()-1; index >= 0; index--)
        out << m_cityMap.at(index).first << endl;
    file.close();
}

QVariant Cities::data(const QModelIndex & index, int role) const
{
    CityModel *model = m_cityMap.at(index.row()).second;
    if (model) {
        switch (role) {
        case CityNameRole:
            return model->cityNameDisplay().replace("_", " ");
        case CountryRole:
            return model->countryName().replace("_", " ");
        }
    }
    return QVariant();
}

int Cities::rowCount(const QModelIndex & /*parent*/) const
{
    return m_cityMap.count();
}

QHash<int, QByteArray> Cities::roleNames() const
{
    QHash<int, QByteArray> rn;
    rn[CityNameRole] = "name";
    rn[CountryRole] = "country";
    return rn;
}
