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

#ifndef DAYMODEL_H
#define DAYMODEL_H

#include <QtCore/QModelIndex>

#include <QtCore/QObject>
#include <QtCore/QStringList>
#include <QtQml/qqml.h>

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
class QNetworkReply;
QT_END_NAMESPACE

class DayModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString date READ getDate WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(int afternoonIndex READ getAfternoonIndex WRITE setAfternoonIndex NOTIFY afternoonIndexChanged)

public:

    struct DayModelStructure {
        QString from;
        QString weatherUrl;
        QString to;
        QString temperature;
        QString windSpeed;
        QString windUrl;
        QString rain;
    };

    enum {
        WeatherUrlRole      = Qt::UserRole + 1,
        FromRole            = Qt::UserRole + 2,
        ToRole              = Qt::UserRole + 3,
        TemperatureRole     = Qt::UserRole + 4,
        WindSpeedRole       = Qt::UserRole + 5,
        WindUrlRole         = Qt::UserRole + 6,
        RainRole            = Qt::UserRole + 7
    };

    DayModel();

    QString getDate() const { return m_date;}
    void setDate(QString date) { m_date = date; }

    int getAfternoonIndex() const { return m_afternoonindex;}
    void setAfternoonIndex(int index) { m_afternoonindex = index; }

    void clear();

    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void addRow(QString weatherUrl, QString from, QString to, QString temperature, QString windSpeed, QString windUrl, QString rain);
    Q_INVOKABLE QString getDayDetails(int index, QString prop) const;
    Q_INVOKABLE int periodCount() const { return m_data.count(); }

    Q_INVOKABLE QUrl getCachedImageFile(const QString url);

Q_SIGNALS:
    void dateChanged();
    void afternoonIndexChanged();
    void addedImages(const QStringList images);

private:
    QString m_date;
    int m_afternoonindex;
    QList<DayModelStructure> m_data;
};

QML_DECLARE_TYPE(DayModel)

#endif // DAYMODEL_H
