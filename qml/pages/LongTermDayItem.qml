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
import QtQuick.Layouts 1.0
import "../js/utils.js" as Utils
import org.qtproject.demo.weather 1.0
import QtQml.Models 2.1

ObjectModel {
    TouchLabel {
        id: shortDay
        property bool useShortFormat: true
        text: Utils.getDay(0, dayModel, useShortFormat)
        font.weight: Font.DemiBold
        Layout.alignment: Qt.AlignBaseline
        font.capitalization: Font.Capitalize

        Accessible.ignored: true

        Rectangle {
            color: mouse.pressed ? ApplicationInfo.colors.smokeGray : ApplicationInfo.colors.white
            width: parent.parent.width + 2* ApplicationInfo.hMargin
            height: rowHeight
            y: -parent.y + separator1.y
            z: -1
            x: -ApplicationInfo.hMargin
            Accessible.role: Accessible.Button
            Accessible.name: qsTr("%1 %2 - temperature low: %3, high: %4, wind: %5 %6").arg(Utils.getDay(0, dayModel)).arg(Utils.getShortDate(dayModel.date)).arg(lowTemp.text).arg(highTemp.text).arg(windSpeed.text).arg(Utils.expandAbbreviation("m/s"))
            Accessible.description: qsTr("press for details")
            Accessible.onPressAction: {
                ApplicationInfo.currentIndexDay = index
                nextPage()
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: {
                    parent.Accessible.pressAction()
                }
            }
            Rectangle {
                width: parent.width
                height: 1
                anchors.top: parent.top
                visible: index > 0
                color: ApplicationInfo.colors.paleGray
            }
        }
    }
    TouchLabel {
        text: Utils.getShortDate(dayModel.date)
        pixelSize: 20
        letterSpacing: -0.15
        Layout.alignment: Qt.AlignBaseline
        Accessible.ignored: true
    }
    Separator {
        id: separator1
        implicitWidth: 5
        implicitHeight: 5
        Layout.preferredHeight: rowHeight // sets the row height
        Layout.fillHeight: false
        Layout.minimumHeight: 5
        Layout.minimumWidth: 5
    }
    Image {
        source: Utils.getWeatherUrl(dayModel.afternoonIndex, dayModel)
        property int weatherIconSize: 80 * ApplicationInfo.ratio
        Layout.preferredHeight: weatherIconSize
        Layout.preferredWidth: weatherIconSize
        onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
    }
    Separator {
        implicitWidth: 5
        implicitHeight: 5
        Layout.fillHeight: false
        Layout.minimumHeight: 5
        Layout.minimumWidth: 5
    }
    TouchLabel {
        id: lowTemp
        property string temp: Utils.getMinTemp(dayModel)
        text: Utils.getTempFormat(temp)
        color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
        Layout.alignment: Qt.AlignBaseline
        Accessible.ignored: true
    }
    Rectangle {
        id: separator2
        Layout.preferredWidth: 1
        Layout.preferredHeight: rowHeight / 5
        color: ApplicationInfo.colors.lightGray
    }
    TouchLabel {
        id: highTemp
        property int temp: Utils.getMaxTemp(dayModel)
        text: Utils.getTempFormat(temp)
        horizontalAlignment: Qt.AlignRight
        color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
        Layout.alignment: Qt.AlignBaseline
        Accessible.ignored: true
    }
    Separator {
        implicitWidth: 5
        implicitHeight: 5
        Layout.minimumHeight: 5
        Layout.minimumWidth: 5
        visible: !isNarrow
    }
    Image {
        property int windIconSize: 32 * ApplicationInfo.ratio
        source: Utils.getWindUrl(dayModel.afternoonIndex, dayModel)
        Layout.preferredHeight: windIconSize
        Layout.preferredWidth: windIconSize
        onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
        visible: !isNarrow
    }
    TouchLabel {
        id: windSpeed
        text: Utils.getWindSpeed(dayModel.afternoonIndex, dayModel)
        pixelSize: 24
        Layout.alignment: Qt.AlignBaseline
        visible: !isNarrow
        Accessible.ignored: true
    }
    TouchLabel {
        id: windSpeedUnit
        //: The wind speed unit, meters per second or miles per hour
        text: Utils.isMetricSystem() ? qsTr("m/s") : qsTr("mph")
        pixelSize: 18
        Layout.alignment: Qt.AlignBaseline
        visible: !isNarrow
        Accessible.ignored: true
    }
}
