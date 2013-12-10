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

import QtQuick 2.1
import QtQuick.XmlListModel 2.0
import org.qtproject.demo.weather 1.0
import "../js/utils.js" as Utils

Item {
    id: modelitem
    signal error(string errorMessage)
    signal showLongTerm()

    property var loadedCityModel
    property string lastLoadedCity

    function getLongTermModel(model)
    {
        if (model.sourceXml !== lastLoadedCity ||
                standardmodel.xml !== model.contentXml ||
                model.daysCount() === 0) {
            if (!!model) model.clear()
            if (standardmodel.xml !== model.contentXml) {
                standardmodel.xml = model.contentXml
            } else {
                if (!!standardmodel.get(0)) {
                    // no error on last loading
                    model.copyright = standardmodel.get(0).copyright
                    currentCityForecastModel.reload()
                } else {
                    error("The saved xml file cannot be parsed")
                }
            }
            loadedCityModel = model
        } else {
            showLongTerm()
        }
        lastLoadedCity = model.sourceXml
    }

    XmlListModel {
        id: standardmodel
        property var city
        query: "/weatherdata"
        XmlRole { name: "copyright"; query: "credit/link/@text/string()"}
        onStatusChanged : {
            if (status === XmlListModel.Ready && count > 0) {
                var item = get(0)
                loadedCityModel.copyright = item.copyright
                currentCityForecastModel.xml = xml
            } else if ( status === XmlListModel.Error) {
                error(errorString())
            } else if (status === XmlListModel.Ready && count == 0) {
                error(qsTr("Can't parse the xml file"))
            }
        }
    }

    XmlListModel {
        id: currentCityForecastModel
        query: "/weatherdata/forecast/tabular/time"
        XmlRole { name: "from"; query: "@from/string()" }
        XmlRole { name: "to"; query: "@to/string()" }
        XmlRole { name: "period"; query: "@period/string()" }
        XmlRole { name: "symbolcode"; query: "symbol/@var/string()" }
        XmlRole { name: "windType"; query: "windSpeed/@name/string()" }
        XmlRole { name: "windDirectionDeg"; query: "windDirection/@deg/string()" }
        XmlRole { name: "windSpeed"; query: "windSpeed/@mps/string()" }
        XmlRole { name: "temperature"; query: "temperature/@value/string()" }
        XmlRole { name: "rain"; query: "precipitation/@value/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready && count > 0) {
                for (var i=0; i<count; i++) {
                    var item = get(i)
                    var date = Utils.getItemDate(item)
                    var dayModel = loadedCityModel.getDayModel(date)
                    if (dayModel === null) {
                        // add a dayModel to cityModel
                        dayModel = Qt.createQmlObject('import org.qtproject.demo.weather 1.0; DayModel {}', loadedCityModel, "")
                        dayModel.date = date
                        loadedCityModel.addDayModel(dayModel)
                    }
                    if (item.period === "2")
                        dayModel.afternoonIndex = dayModel.periodCount()
                    Utils.updateDayModel(dayModel, item)
                }
                modelitem.showLongTerm()
            } else if ( status === XmlListModel.Error) {
                error(errorString())
            } else if (status === XmlListModel.Ready && count == 0) {
                error(qsTr("Can't parse the xml file"))
            }
        }
    }
}
