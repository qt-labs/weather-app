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
        QString day;
        QString weatherUrl;
        QString timeRange;
        QString temperature;
        QString windSpeed;
        QString windUrl;
        QString rain;
    };

    enum {
        DayRole             = Qt::UserRole + 1,
        WeatherUrlRole      = Qt::UserRole + 2,
        TimeRangeRole       = Qt::UserRole + 3,
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

    Q_INVOKABLE void addRow(QString day, QString weatherUrl, QString timeRange, QString temperature, QString windSpeed, QString windUrl, QString rain);
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
