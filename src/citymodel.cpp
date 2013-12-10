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

#include <QtCore/QDateTime>
#include <QtCore/QFile>
#include <QtCore/QIODevice>
#include <QtCore/QRegExp>
#include <QtCore/QStringList>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkAccessManager>

#include "citymodel.h"
#include "applicationpaths.h"
#include <QDebug>

CityModel::CityModel(QObject *parent) :
    QObject(parent), m_timeStamp(0)
{
    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
    connect(this, SIGNAL(ready()), this, SLOT(readXml()));
}

void CityModel::setCopyright(const QString copyright)
{
    if (copyright != m_copyright) {
        m_copyright = copyright;
        emit copyrightChanged();
    }
}

bool CityModel::setSourceXml(const QString xml)
{
    if (xml != m_sourceXml) {
        QRegExp regExp;
        // will reject invalid xml string
        regExp.setPattern("^http://www\\.yr\\.no/place/(([^/]*)/.*/([^/]*))/forecast\\.xml$");
        if (!regExp.exactMatch(xml))
            return false;
        m_sourceXml = xml;

        // get city name, country and filename from sourceXml
        QStringList list = regExp.capturedTexts();
        setCityNameDisplay(list.at(3));
        setCountryName(list.at(2));
        QString tempFileName = regExp.capturedTexts().at(1);
        tempFileName = tempFileName.replace(QString("/"), QString("_"));
        m_filename = QString("%1%2.wa").arg(ApplicationPaths::dowloadedFilesPath()).arg(tempFileName);
        emit sourceXmlChanged();
    }
    return true;
}

void CityModel::setCityNameDisplay(QString name)
{
    int pos = name.indexOf("~");
    if ( pos > 0)
        name.truncate(pos);

    if (name != m_cityNameDisplay) {
        m_cityNameDisplay = name;
        emit cityNameDisplayChanged();
    }
}

QString CityModel::cityNameDisplay() const
{
    QString cityName = m_cityNameDisplay;
    return cityName.replace("_", " ");
}

void CityModel::setCountryName(const QString name)
{
    if (name != m_countryName) {
        m_countryName = name;
        emit countryNameChanged();
    }
}

QString CityModel::countryName() const
{
    QString countryName = m_countryName;
    return countryName.replace("_", " ");
}

void CityModel::setError(const QString errorMessage)
{
    // Always emit error message
    emit error(tr("Network error: ") + errorMessage);
}

QVariant CityModel::data(const QModelIndex & /*index*/, int role) const
{
    if (role == CityNameDisplayRole)
        return m_cityNameDisplay;
    return QVariant();
}

QHash<int, QByteArray> CityModel::roleNames() const
{
    QHash<int, QByteArray> rn;
    rn[CityNameDisplayRole] = "name";
    return rn;
}

void CityModel::clear()
{
    m_copyright = QString();
    m_timeStamp = 0;
    for (int i = 0; i < m_citydata.count(); i++) {
        DayModel *temp = m_citydata.takeAt(i);
        temp->clear();
        temp->deleteLater();
    }
    m_citydata.clear();
}

void CityModel::cleanAll()
{
    clear();
    // Clear eventual cached file
    QFile file(m_filename);
    if (file.exists())
        file.remove();
}

void CityModel::addDayModel(DayModel *newDayModel)
{
    m_citydata.append(newDayModel);
    connect(newDayModel, SIGNAL(addedImages(QStringList)), this, SLOT(addImages(QStringList)));
}

void CityModel::addImages(const QStringList images)
{
    for (int i = 0; i < images.count(); i++)
        downloadImage(images.at(i));
}

DayModel* CityModel::getDayModel(QString date)
{
    for (int i = 0; i < m_citydata.count(); i++) {
        if ( m_citydata.at(i)->getDate() == date )
            return m_citydata.at(i);
    }
    return 0;
}

DayModel* CityModel::getDayModel(int indexDay)
{
    Q_ASSERT(indexDay > -1);
    Q_ASSERT(indexDay < m_citydata.count());
    return m_citydata.at(indexDay);
}

void CityModel::refreshData()
{
    if (sourceXml() == QString()) {
        qWarning("Warning: source xml not set");
        return;
    }
    QNetworkRequest request;
    request.setUrl(QUrl(sourceXml()));
    request.setRawHeader("Accept", "application/xml,*/*");
    manager->get(request);
}

void CityModel::loadData()
{
    Q_ASSERT(!m_filename.isEmpty());
    QFile file(m_filename);
    m_timeStamp = 0;
    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        m_timeStamp = QString(file.readLine().trimmed()).toLongLong();
        file.close();
    }
    if (dataExpired(m_timeStamp))
        refreshData();
    else
        emit ready();
}

bool CityModel::dataExpired(qint64 timeStamp) {
    // 10 minutes caching
    qint64 tenMinutesMSecs = 10 * 60 * 1000;
    qint64 timeElapsed = QDateTime::currentMSecsSinceEpoch() - timeStamp;
    return timeStamp == 0 || timeElapsed > tenMinutesMSecs;
}

void CityModel::replyFinished(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        setError(reply->errorString());
    } else {
        QString requestUrl = reply->request().url().toString();
        if (requestUrl.endsWith(".xml")) {
            QByteArray data = reply->readAll();
            if (!data.isEmpty()) {
                data.prepend("\n");
                data.prepend(QByteArray::number(QDateTime::currentMSecsSinceEpoch(), 'f', 0));
                QFile file(m_filename);
                if (file.open(QIODevice::WriteOnly)) {
                    file.write(data);
                    file.close();
                    emit ready();
                } else {
                    setError(file.errorString());
                }
            } else {
                setError(tr("No data at given url"));
            }
        } else { // download image
            QString filename = getImageFileName(reply->url().toString());
            QByteArray data = reply->readAll();
            if (!data.isEmpty()) {
                QFile file(filename);
                if (!file.exists() && file.open(QIODevice::WriteOnly)) {
                    file.write(data);
                    file.close();
                }
            }
        }
    }
    if (reply) {
        reply->deleteLater();
        reply = 0;
    }
}

void CityModel::downloadImage(const QString imageUrl)
{
    QString filename = getImageFileName(imageUrl);
    QFile file(filename);
    if (!file.exists()) {
        QNetworkRequest request;
        request.setUrl(QUrl(imageUrl));
        manager->get(request);
    }
}

QString CityModel::getImageFileName(const QString url)
{
    bool isLargeImage = url.contains("b200");
    QString filename = url.right(url.length() - url.lastIndexOf("/") - 1);
    if (isLargeImage)
        filename.prepend("large_");
    filename = QString("%1%2").arg(ApplicationPaths::dowloadedFilesPath()).arg(filename);
    return filename;
}

void CityModel::readXml()
{
    QFile file(m_filename);
    QString content;
    if (file.open(QIODevice::ReadOnly)) {
        m_timeStamp = QString(file.readLine().trimmed()).toLongLong();
        m_contentXml = QString(file.readAll());
        emit contentXmlChanged(); // always emit this signal
        file.close();
    } else {
        setError(file.errorString());
    }
}
