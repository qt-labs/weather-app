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
        XmlRole { name: "windDirectionName"; query: "windDirection/@name/string()" }
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
