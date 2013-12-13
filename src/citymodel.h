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

#ifndef CITYMODEL_H
#define CITYMODEL_H

#include <QtCore/QModelIndex>
#include <QtCore/QObject>
#include <QtQml/qqml.h>
#include <QDebug>

#include "daymodel.h"

QT_BEGIN_NAMESPACE
class QNetworkAccessManager;
class QNetworkReply;
QT_END_NAMESPACE

class CityModel : public QObject
{
    Q_OBJECT
    Q_ENUMS(Status)
    Q_PROPERTY(QString copyright READ copyright WRITE setCopyright NOTIFY copyrightChanged)
    Q_PROPERTY(QString cityNameDisplay READ cityNameDisplay NOTIFY cityNameDisplayChanged)
    Q_PROPERTY(QString countryName READ countryName NOTIFY countryNameChanged)
    Q_PROPERTY(QString sourceXml READ sourceXml NOTIFY sourceXmlChanged)
    Q_PROPERTY(QString contentXml READ contentXml NOTIFY contentXmlChanged)

public:
    enum {
        CityNameDisplayRole = Qt::UserRole + 1
    };

    CityModel(QObject *parent = 0);

    void setError(const QString msg);

    QString copyright() const { return m_copyright;}
    void setCopyright(const QString copyright);

    QString cityNameDisplay() const;
    void setCityNameDisplay(QString name);

    QString countryName() const;
    void setCountryName(const QString name);

    QString sourceXml() const { return m_sourceXml; }
    bool setSourceXml(const QString xml);

    QString contentXml() const { return m_contentXml; }

    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE int daysCount() const { return m_citydata.count(); }
    Q_INVOKABLE void loadData();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void addDayModel(DayModel *newDayModel);
    Q_INVOKABLE DayModel* getDayModel(QString dayName);
    Q_INVOKABLE DayModel* getDayModel(int indexDay);

    void cleanAll();

    void downloadImage(const QString imageUrl);

private:
    void refreshData();
    bool dataExpired(qint64 timeStamp);
    QString getImageFileName(const QString url);

private Q_SLOTS:
    void replyFinished(QNetworkReply*);
    void readXml();
    void addImages(const QStringList images);

Q_SIGNALS:
    void copyrightChanged();
    void countryNameChanged();
    void error(const QString errorMessage);
    void sourceXmlChanged();
    void contentXmlChanged();
    void cityNameDisplayChanged();
    void fileNameChanged();
    void ready();

private:
    QString m_copyright;
    QString m_countryName, m_contentXml;
    qreal m_timeStamp;
    QList<DayModel*> m_citydata;
    QNetworkAccessManager *manager;
    QString m_filename;
    QString m_url;
    QString m_sourceXml;
    QString m_cityNameDisplay;
};

QML_DECLARE_TYPE(CityModel)

#endif // CITYMODEL_H
