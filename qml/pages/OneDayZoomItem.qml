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

GridLayout {
    id: root
    flow: ApplicationInfo.isPortraitMode ? GridLayout.LeftToRight : GridLayout.TopToBottom

    property real adjustementNeeded: 1
    property QtObject slider
    property QtObject model
    property bool singleItem

    function singleTimeString(ind) {
        //: The given time interval for the forecast displayed, i.e. (8AM - 2PM)
        return qsTr("(%1 - %2)").arg(Utils.getFromTime(ind, dayModel)).arg(Utils.getToTime(ind, dayModel))
    }

    readonly property int sliderValue: Math.round(root.slider.value)

    Separator {}
    GridLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        id: grid
        rowSpacing: 0
        columnSpacing: 15 * ApplicationInfo.ratio
        columns: 2
        TouchLabel {
            id: longDay
            text : Utils.getDay(root.sliderValue, root.model)
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignBaseline
            font.capitalization: Font.Capitalize
            Accessible.name: longDay.text + " " + dateLabel.text + " " + timeLabel.text
        }
        TouchLabel {
            id: dateLabel
            text: Utils.getLongDate(root.model.date)
            pixelSize: 30
            Layout.alignment: Qt.AlignBaseline | Qt.AlignLeft
            color: ApplicationInfo.colors.darkGray
            Accessible.ignored: true
        }
        TouchLabel {
            id: timeLabel
            text: root.singleTimeString(root.sliderValue)
            pixelSize: 20
            Layout.alignment: Qt.AlignBaseline
            horizontalAlignment: Text.AlignLeft
            color:  ApplicationInfo.colors.darkGray
            Layout.columnSpan: 2
            Accessible.ignored: true
        }
        Item {
            Image {
                id: mainIcon
                source: Utils.getWeatherUrl(root.sliderValue, root.model, "large")
                onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                onSourceChanged: anim.running = true
                anchors.verticalCenterOffset: offset
                property real offset: 0
                ParallelAnimation {
                    id: anim
                    alwaysRunToEnd: true
                    NumberAnimation {
                        target: mainIcon
                        property: "offset"
                        from: -30
                        to: 0
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: mainIcon
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                    }
                }
            }

            Layout.rowSpan: 1
            Layout.preferredHeight: adjustementNeeded * 160 * ApplicationInfo.ratio
            Layout.preferredWidth: adjustementNeeded * 160 * ApplicationInfo.ratio
            Layout.alignment: Qt.AlignCenter
        }
        TouchLabel {
            id: tempLabel
            property int temp: Utils.getTemperature(root.sliderValue, root.model)
            text : Utils.getTempFormat(temp)
            color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
            pixelSize: adjustementNeeded * 72
            letterSpacing: -0.5
            Layout.alignment: Qt.AlignLeft
            function getLongestTempWidth() {
                var itemsInDay = root.model.periodCount()
                var longestTempWidth = 0
                for (var indexInDay = 0; indexInDay < itemsInDay; indexInDay++) {
                    var tempTemperature = Utils.getTemperature(indexInDay, root.model)
                    longestTempWidth = Math.max(longestTempWidth, tempLabel.expectedTextWidth(Utils.getTempFormat(tempTemperature)))
                }
                return longestTempWidth
            }
            Component.onCompleted: Layout.preferredWidth = getLongestTempWidth() + 4 * ApplicationInfo.ratio
            Accessible.name: text
            Accessible.description: qsTr("Temperature for this part of the day")
        }
        RowLayout {
            Layout.columnSpan: 2
            TouchLabel {
                id: rainLabel
                text : qsTr("Precipitation: ") + Utils.getRain(root.sliderValue, root.model)
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                pixelSize: 30
                Accessible.name: text + " " + rainUnit.text
            }
            TouchLabel {
                //: The rain level unit, millimeters or inches
                id: rainUnit
                text: Utils.isMetricSystem() ? qsTr("mm") : qsTr("in")
                pixelSize: 24
                Layout.alignment: Qt.AlignBaseline | Qt.AlignLeft
                Accessible.ignored: true
            }
        }
        RowLayout {
            Layout.columnSpan: 2
            TouchLabel {
                id: windLabel
                text : qsTr("Wind: ") + Utils.getWindSpeed(root.sliderValue, root.model)
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                pixelSize: 30
                Accessible.name: text + " " + windUnit.text
            }
            TouchLabel {
                //: The wind speed unit, meters per second or miles per hour
                id: windUnit
                text: Utils.isMetricSystem() ? qsTr("m/s") : qsTr("mph")
                pixelSize: 24
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                Accessible.ignored: true
            }
            Image {
                source: Utils.getWindUrl(root.sliderValue, root.model)
                property int windIconSize: 45 * ApplicationInfo.ratio
                Layout.preferredHeight: windIconSize
                Layout.preferredWidth: windIconSize
                onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
                Layout.alignment: Qt.AlignLeft
            }
        }
    }
    Separator {}
}
