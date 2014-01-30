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

    property QtObject slider
    property QtObject model
    property bool singleItem
    property string singleTimeString: "(" + Utils.getFromTime(0, dayModel) + " - " + Utils.getToTime(0, dayModel) + ")"

    Separator {
        Layout.fillHeight: true
        Layout.fillWidth: ApplicationInfo.isPortraitMode ? true : false
    }
    GridLayout {
        id: grid
        rowSpacing: 0
        columnSpacing: 15 * ApplicationInfo.ratio
        columns: 3
        TouchLabel {
            id: longDay
            text : Utils.getDay(root.slider.value, root.model)
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignBaseline
        }
        TouchLabel {
            text: Utils.getLongDate(root.model.date)
            pixelSize: 30
            Layout.alignment: Qt.AlignBaseline | Qt.AlignLeft
            color: ApplicationInfo.colors.darkGray
        }
        TouchLabel {
            text: root.singleItem ? root.singleTimeString : ""
            pixelSize: 20
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignBaseline
            color:  ApplicationInfo.colors.darkGray
        }
        Item {
            Image {
                id: mainIcon
                source: Utils.getWeatherUrl(Math.round(root.slider.value), root.model, "large")
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
            Layout.preferredHeight: 200 * ApplicationInfo.ratio
            Layout.preferredWidth: 200 * ApplicationInfo.ratio
            Layout.alignment: Qt.AlignCenter
        }
        TouchLabel {
            Layout.preferredWidth: expectedTextWidth(Utils.getMaxTempLenght(ApplicationInfo.currentCityModel))
            property int temp: Utils.getTemperature(root.slider.value, root.model)
            text : temp + qsTr("°C")
            color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
            pixelSize: 72
            letterSpacing: -0.5
            Layout.alignment: Qt.AlignLeft
        }
        RowLayout {
            Layout.columnSpan: 3
            TouchLabel {
                id: rainLabel
                text : qsTr("Precipitation: ") + Utils.getRain(root.slider.value, root.model)
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                pixelSize: 30
            }
            TouchLabel {
                text : qsTr("mm")
                pixelSize: 24
                Layout.alignment: Qt.AlignBaseline | Qt.AlignLeft
            }
        }
        RowLayout {
            Layout.columnSpan: 3
            TouchLabel {
                id: windLabel
                text : qsTr("Wind: ") + Utils.getWindSpeed(root.slider.value, root.model) + " "
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                pixelSize: 30
            }
            TouchLabel {
                text : qsTr("m/s")
                pixelSize: 24
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
            }
            Image {
                source: Utils.getWindUrl(root.slider.value, root.model)
                property int windIconSize: 45 * ApplicationInfo.ratio
                Layout.preferredHeight: windIconSize
                Layout.preferredWidth: windIconSize
                onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
                Layout.alignment: Qt.AlignLeft
            }
        }
    }
    Separator {
        Layout.fillHeight: true
        Layout.fillWidth: ApplicationInfo.isPortraitMode ? true : false
    }
}
