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
import org.qtproject.demo.weather 1.0

Rectangle {
    id: rect
    height: ApplicationInfo.constants.rowDelegateHeight
    width: parent.width
    signal clicked
    signal deleteCity

    property bool isSearchView: false

    color: mouseNext.pressed ? ApplicationInfo.colors.smokeGray : ApplicationInfo.colors.white
    Accessible.role: Accessible.ListItem

    GridLayout {
        id: _grid
        anchors.fill: parent
        flow: Qt.LeftToRight
        rowSpacing: 4 * ApplicationInfo.ratio
        columnSpacing: 0
        columns: 2
        Rectangle {
            Layout.preferredWidth: ApplicationInfo.hMargin
            Layout.fillHeight: true
            opacity: 0
        }
        Loader {
            id: loader
            sourceComponent: isSearchView ? searchViewRow : cityViewRow
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Rectangle {
            id: separator
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.columnSpan: 2
        }
    }
    Rectangle {
        z: 1
        height: 1
        anchors.bottom: parent.bottom
        width: parent.width
        color: ApplicationInfo.colors.paleGray
    }
    MouseArea {
        id: mouseNext
        anchors.left: parent.left
        width: parent.width - 80 * ApplicationInfo.ratio - ApplicationInfo.hMargin
        height: parent.height
        onClicked: rect.clicked()
        Accessible.role: Accessible.Button
        Accessible.name: loader.item.accessibleName
        function accessiblePressAction() {
            rect.clicked()
        }
    }

    property Component searchViewRow: RowLayout {
        spacing: 0
        property string accessibleName: country
        TouchLabel {
            color: ApplicationInfo.colors.mediumGray
            id: countryLabel
            text: country
            pixelSize: 28
            Layout.alignment: Qt.AlignBaseline
            Layout.fillWidth: true
            Layout.maximumWidth: rect.width - 2 * ApplicationInfo.hMargin
            Accessible.ignored: true
        }
        Rectangle {
            Layout.preferredWidth: ApplicationInfo.hMargin
            Layout.fillHeight: true
            opacity: 0
        }
    }

    property Component cityViewRow: RowLayout {
        spacing: 0
        property string accessibleName: city.text + " - " + countryLabel.text
        TouchLabel {
            id: city
            text: name
            font.weight: Font.DemiBold
            Layout.maximumWidth: maximumWidth * 2
            Layout.alignment: Qt.AlignBaseline
            Accessible.ignored: true
        }
        Item {
            implicitWidth: 12 * ApplicationInfo.ratio
            Layout.minimumWidth: implicitWidth
        }
        TouchLabel {
            color: ApplicationInfo.colors.mediumGray
            id: countryLabel
            text: country
            pixelSize: 28
            Layout.alignment: Qt.AlignBaseline | Qt.AlignLeft
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Accessible.ignored: true
        }
        MouseArea {
            id: deleteMouse
            implicitWidth: ApplicationInfo.constants.rowDelegateHeight
            implicitHeight: implicitWidth
            Layout.minimumWidth: implicitWidth
            onClicked: if (!isSearchView) rect.deleteCity()
            Accessible.name: qsTr("Remove %1").arg(city.text)
            Accessible.role: Accessible.Button
            function accessiblePressAction () { if (!isSearchView) rect.deleteCity() }
            Image {
                id: imageRemove
                anchors.centerIn: parent
                source: ApplicationInfo.getImagePath("darkclose.png")
                width: 31 * ApplicationInfo.ratio
                height: 31 * ApplicationInfo.ratio
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 8 * ApplicationInfo.ratio
                color: ApplicationInfo.colors.smokeGray
                opacity: deleteMouse.pressed ? 1 : 0
                z: -1
                radius: 8
            }
        }
    }
}
