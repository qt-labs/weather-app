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

ApplicationWindow {
    id: root
    height: 700
    width: 1200
    title: qsTr("Quick Forecast")

    property string statusBarMessage

    property Component citiesPage: CitiesPage {
        onUpdateStatusBar: statusBarMessage = message
        onNextPage: if (!isLocked) {
                        isLocked = true
                        pageView.push(longTermPage)
                        clearSearchBox()
                    }
    }
    property Component longTermPage: LongTermPage {
        onUpdateStatusBar: statusBarMessage = message
        onNextPage: if (!isLocked) {
                        isLocked = true
                        pageView.push(oneDayPage)
                    }
        onPreviousPage: {
            ApplicationInfo.currentIndexDay = -1
            pageView.pop()
        }
    }
    property Component oneDayPage: OneDayPage {
        onUpdateStatusBar: statusBarMessage = message
        onPreviousPage: if (!isLocked) {
                            isLocked = true
                            pageView.pop()
                        }
    }

    StackView {
        id: pageView
        anchors.fill: parent
        focus: true
        Keys.onReleased: {
            if ((event.key === Qt.Key_Back ||
                  (event.key === Qt.Key_Left && (event.modifiers & Qt.AltModifier))) &&
                    pageView.depth > 1) {
                event.accepted = true
                if (!currentItem.isLocked)
                    currentItem.previousPage()
            }
        }

        initialItem: citiesPage
        delegate: StackViewDelegate {
            pushTransition: StackViewTransition {
                function transitionFinished(properties)
                {
                    properties.exitItem.opacity = 1
                }
                PropertyAnimation {
                    target: enterItem
                    property: "x"
                    from: target.width
                    to: 0
                    duration: 500
                    easing.type: Easing.OutSine
                }
                PropertyAnimation {
                    target: exitItem
                    property: "x"
                    from: 0
                    to: -target.width
                    duration: 500
                    easing.type: Easing.OutSine
                }
            }
            popTransition: StackViewTransition {
                function transitionFinished(properties)
                {
                    properties.exitItem.opacity = 1
                }
                PropertyAnimation {
                    target: enterItem
                    property: "x"
                    from: -target.width
                    to: 0
                    duration: 500
                    easing.type: Easing.OutSine
                }
                PropertyAnimation {
                    target: exitItem
                    property: "x"
                    from: 0
                    to: target.width
                    duration: 500
                    easing.type: Easing.OutSine

                }
            }
            property Component replaceTransition: pushTransition
        }
    }

    statusBar: StatusBar {
        width: parent.width
        opacity: label.text !== "" ? 1 : 0
        height: label.text !== "" ? 65 * ApplicationInfo.ratio : 0

        Behavior on height { NumberAnimation {easing.type: Easing.OutSine}}
        Behavior on opacity { NumberAnimation {}}

        style: StatusBarStyle {
            padding { left: 0; right: 0 ; top: 0 ; bottom: 0}
            property Component background: Rectangle {
                implicitHeight: 65 * ApplicationInfo.ratio
                implicitWidth: root.width
                color: ApplicationInfo.colors.smokeGray
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.darker(parent.color, 1.5)
                }
                Rectangle {
                    y: 1
                    width: parent.width
                    height: 1
                    color: "white"
                }
            }
        }
        TouchLabel {
            id: label
            y: 32 * ApplicationInfo.ratio - height/2
            width: parent.width // The text will only wrap if an explicit width has been set
            text: statusBarMessage
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
            wrapMode: Text.Wrap
            pixelSize: 18
            letterSpacing: -0.15
            color: ApplicationInfo.colors.mediumGray
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
