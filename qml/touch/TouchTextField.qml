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
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import org.qtproject.demo.weather 1.0

TextField {
    id: textfield
    signal clearButtonClicked
    implicitWidth: parent.width
    property bool isEmpty: true
    style: TextFieldStyle {
        background :
            Rectangle {
            radius: 8
            border.width: 1
            border.color: Qt.darker(ApplicationInfo.colors.blue, 1.6)
            color: ApplicationInfo.colors.white
            gradient: Gradient {
                GradientStop { position: 0 ; color: "#ddd"}
                GradientStop { position: 0.05 ; color: "#fff"}
            }

            implicitHeight: 60 * ApplicationInfo.ratio
            opacity: 1
        }
        padding.left : (12 + 50) * ApplicationInfo.ratio
        padding.right: (12 + 50) * ApplicationInfo.ratio
        font.pixelSize: 28 * ApplicationInfo.ratio
        font.family: "Open Sans"
        font.letterSpacing: -0.25 * ApplicationInfo.ratio
        selectedTextColor : ApplicationInfo.colors.lightGray
        selectionColor : ApplicationInfo.colors.darkBlue
        textColor : ApplicationInfo.colors.mediumGray
    }

    Item {
        id: item
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height
        width: parent.height
        Image {
            opacity: 0.9
            anchors.centerIn: item
            height: iconSize
            width: iconSize
            source: ApplicationInfo.getImagePath("magnifier.png")
            property int iconSize: 50 * ApplicationInfo.ratio
        }
    }

    onTextChanged: isEmpty = (text === "")
    inputMethodHints: Qt.ImhNoPredictiveText
    MouseArea {
        z: 2
        opacity: !textfield.isEmpty ? 1 : 0
        Behavior on opacity {NumberAnimation{}}
        anchors.right: parent.right
        anchors.rightMargin: 4 * ApplicationInfo.ratio
        anchors.top: parent.top
        height: parent.height
        width: parent.height
        Image {
            anchors.centerIn: parent
            source: ApplicationInfo.getImagePath("Clear.png")
            property int iconSize: 40 * ApplicationInfo.ratio
            opacity: parent.pressed ? 1 : 0.9
            width: iconSize
            height: iconSize
        }
        onClicked: textfield.clearButtonClicked()
    }
}

