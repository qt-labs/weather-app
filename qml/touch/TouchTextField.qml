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
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import org.qtproject.demo.weather 1.0

TextField {
    id: textfield
    signal clearButtonClicked
    implicitWidth: parent.width
    property bool isEmpty: true
    style: TextFieldStyle {
        renderType: ApplicationInfo.isMobile ? Text.QtRendering : Text.NativeRendering
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

