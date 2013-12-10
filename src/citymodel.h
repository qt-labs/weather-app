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
