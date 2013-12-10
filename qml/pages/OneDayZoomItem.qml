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
                text : qsTr("Rain: ") + Utils.getRain(root.slider.value, root.model)
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
