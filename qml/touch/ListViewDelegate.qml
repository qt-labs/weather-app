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
import org.qtproject.demo.weather 1.0

Rectangle {
    id: rect
    height: 118 * ApplicationInfo.ratio
    width: parent.width
    signal clicked
    signal deleteCity

    property bool isSearchView: false

    color: mouseNext.pressed ? ApplicationInfo.colors.smokeGray : ApplicationInfo.colors.white

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
    }

    property Component searchViewRow: RowLayout {
        spacing: 0
        TouchLabel {
            color: ApplicationInfo.colors.mediumGray
            id: countryLabel
            text: country
            pixelSize: 28
            Layout.alignment: Qt.AlignBaseline
            Layout.fillWidth: true
            Layout.maximumWidth: rect.width - 2 * ApplicationInfo.hMargin
        }
        Rectangle {
            Layout.preferredWidth: ApplicationInfo.hMargin
            Layout.fillHeight: true
            opacity: 0
        }
    }

    property Component cityViewRow: RowLayout {
        spacing: 0
        TouchLabel {
            id: city
            text: name
            font.weight: Font.DemiBold
            Layout.maximumWidth: maximumWidth * 2
            Layout.alignment: Qt.AlignBaseline
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
        }
        MouseArea {
            id: deleteMouse
            implicitWidth: 110 * ApplicationInfo.ratio
            implicitHeight: 110 * ApplicationInfo.ratio
            Layout.minimumWidth: implicitWidth
            onClicked: if (!isSearchView) rect.deleteCity()
            Image {
                id: imageRemove
                anchors.centerIn: parent
                source: ApplicationInfo.getImagePath("darkclose.png")
                width: 31 * ApplicationInfo.ratio
                height: 31 * ApplicationInfo.ratio
            }
            Rectangle {
                anchors.fill: parent
                color: ApplicationInfo.colors.smokeGray
                opacity: deleteMouse.pressed ? 1 : 0
                z: -1
                radius: 8
            }
        }
    }
}
