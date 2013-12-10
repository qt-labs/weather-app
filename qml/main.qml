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
