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
    property bool isLocked: true
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
