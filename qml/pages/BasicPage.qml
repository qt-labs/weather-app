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
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import org.qtproject.demo.weather 1.0

Item {
    id: page
    signal updateStatusBar(string message)
    signal nextPage
    signal previousPage
    signal clearSearchBox

    property Component pageComponent
    property bool isLocked: Stack.status !== Stack.Active
    property string title1
    property string title2
    property string title3

    property alias searchText: searchField.text
    property alias hasNoSearchText: searchField.isEmpty
    signal searchBoxReturn
    property string statusBarMessageDefault

    property alias blueRect: blueRect

    Binding {
        target: ApplicationInfo
        property: "isPortraitMode"
        value: page.height > page.width
        when: !ApplicationInfo.isMobile
    }

    Binding {
        target: ApplicationInfo
        property: "applicationWidth"
        value: page.width
    }

    Rectangle {
        id: blueRect
        z: 2 // so flickable doesn't draw on top
        anchors.top: parent.top
        height: 80 * ApplicationInfo.ratio
        width: parent.width
        color: page.Stack.index !== 0 && mouseBack.pressed ?
                   Qt.lighter(ApplicationInfo.colors.blue, 1.2) : ApplicationInfo.colors.blue
        Rectangle {
            color: Qt.lighter(parent.color, 1.2)
            height: 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            width: parent.width
        }
        Rectangle {
            z: 2 // so flickable doesn't draw on top
            height: 1
            width: parent.width
            color: Qt.darker(ApplicationInfo.colors.blue, 1.6)
            anchors.bottom: parent.bottom
        }

        RowLayout {
            id: titleRow
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter
            Separator {}
            Image {
                source: ApplicationInfo.getImagePath("BackArrow.png")
                Layout.preferredWidth: 22 * ApplicationInfo.ratio
                Layout.preferredHeight: 35 * ApplicationInfo.ratio
                visible: page.Stack.index > 0
            }
            Rectangle {
                opacity: 0
                Layout.preferredWidth: 20 * ApplicationInfo.ratio
                Layout.fillHeight: true
                visible: page.Stack.index > 0
            }
            TouchLabel {
                id: t1
                text: title1 + " "
                color: ApplicationInfo.colors.white
                pixelSize: 30
                font.weight: Font.Bold
                Layout.maximumWidth: ApplicationInfo.applicationWidth - t3.implicitWidth - 2 * ApplicationInfo.hMargin - 5 * ApplicationInfo.ratio - 42 * ApplicationInfo.ratio
                Layout.alignment: Qt.AlignBaseline
            }
            TouchLabel {
                text: "- " + title2
                color: ApplicationInfo.colors.white
                visible: title2 !== ""
                pixelSize: 22
                letterSpacing: -0.15
                Layout.alignment: Qt.AlignBaseline
                Layout.maximumWidth: freeSpace > implicitWidth ? freeSpace : 0
                property real freeSpace: ApplicationInfo.applicationWidth - t1.width - t3.implicitWidth - 2 * ApplicationInfo.hMargin - 5 * ApplicationInfo.ratio - 42 * ApplicationInfo.ratio
            }
            Item {
                Layout.fillWidth: true
                height: 0
            }
            TouchLabel {
                id: t3
                text: title3
                color: ApplicationInfo.colors.white
                visible: title3 !== ""
                pixelSize: 22
                letterSpacing: -0.15
                Layout.alignment: Qt.AlignBaseline
            }
            Separator {}
        }
        Rectangle {
            width: parent.width
            height: 5
            anchors.top: parent.bottom
            gradient: Gradient {
                GradientStop {position: 0 ; color: "#40000000"}
                GradientStop {position: 1 ; color: "#00000000"}
            }
        }
        MouseArea {
            id: mouseBack
            anchors.fill: parent
            onClicked: if (!isLocked) page.previousPage()
        }
    }

    TouchTextField {
        id: searchField
        z: 2
        visible: page.Stack.index === 0 ? 1 : 0
        anchors.right: blueRect.right
        anchors.top: blueRect.top
        anchors.bottom: blueRect.bottom
        width: ApplicationInfo.isPortraitMode ?
                   parent.width - t1.implicitWidth - ApplicationInfo.ratio * 50 :
                   parent.width/2.5
        anchors.leftMargin: blueRect.width/2
        anchors.rightMargin: 20 * ApplicationInfo.ratio
        anchors.margins: 12 * ApplicationInfo.ratio

        placeholderText: qsTr("Find City")
        Layout.fillWidth: true
        Keys.onReturnPressed: page.searchBoxReturn()
        Keys.onEnterPressed: page.searchBoxReturn()
        onClearButtonClicked: page.clearSearchBox()
    }

    Loader {
        sourceComponent: pageComponent
        anchors.top: blueRect.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        Rectangle {
            z: -1
            anchors.fill: parent
            color: ApplicationInfo.colors.white
        }
    }
}
