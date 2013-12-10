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

Rectangle {
    id: day
    Layout.preferredHeight: 118 * ApplicationInfo.ratio
    Layout.preferredWidth: scrollview.viewport.width - 5

    signal next
    property bool last
    property var dayModel: ApplicationInfo.currentCityModel.getDayModel(index)

    color: mouse.pressed ? ApplicationInfo.colors.smokeGray : ApplicationInfo.colors.white

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            ApplicationInfo.currentIndexDay = index
            next()
        }
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Separator {}
        TouchLabel {
            id: shortDay
            Layout.preferredWidth: expectedTextWidth("Wed.")
            text: Utils.getDay(0, dayModel).substr(0, 3)
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignBaseline
        }
        TouchLabel {
            Layout.preferredWidth: expectedTextWidth("00.00")
            text: Utils.getShortDate(dayModel.date)
            pixelSize: 20
            letterSpacing: -0.15
            Layout.alignment: Qt.AlignBaseline
        }
        Separator {
            Layout.fillHeight: true
            Layout.fillWidth: true
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: 5
            Layout.minimumWidth: 5
        }
        TouchLabel {
            Layout.preferredWidth: expectedTextWidth(Utils.getMaxTempLenght(ApplicationInfo.currentCityModel))
            property string temp: Utils.getMinTemp(dayModel)
            text: Utils.getTempFormat(temp)
            color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
            Layout.alignment: Qt.AlignBaseline
        }
        Rectangle {
            id: separator2
            Layout.preferredWidth: 1
            Layout.preferredHeight: day.height/5
            color: ApplicationInfo.colors.lightGray
        }
        TouchLabel {
            Layout.preferredWidth: expectedTextWidth(Utils.getMaxTempLenght(ApplicationInfo.currentCityModel))
            property int temp: Utils.getMaxTemp(dayModel)
            text: Utils.getTempFormat(temp)
            horizontalAlignment: Qt.AlignRight
            color: temp < 0 ? ApplicationInfo.colors.blue : ApplicationInfo.colors.doubleDarkGray
            Layout.alignment: Qt.AlignBaseline
        }
        Separator {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: 5
            Layout.minimumWidth: 5
        }
        Image {
            property int windIconSize: 32 * ApplicationInfo.ratio
            source: Utils.getWindUrl(dayModel.afternoonIndex, dayModel)
            Layout.preferredHeight: windIconSize
            Layout.preferredWidth: windIconSize
            onStatusChanged: if (status === Image.Error) updateStatusBar(ApplicationInfo.constants.errorLoadingImage + ": " + source)
        }
        TouchLabel {
            Layout.preferredWidth: expectedTextWidth("10.0")
            text: Utils.getWindSpeed(dayModel.afternoonIndex, dayModel)
            pixelSize: 24
            Layout.alignment: Qt.AlignBaseline
        }
        TouchLabel {
            text: qsTr("m/s")
            pixelSize: 18
            Layout.alignment: Qt.AlignBaseline
        }
        Separator {}
    }
    Rectangle {
        width: parent.width
        height: 1
        visible: !last
        color: ApplicationInfo.colors.paleGray
    }
}
