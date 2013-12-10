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
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0
import org.qtproject.demo.weather 1.0

BasicPage {
    id: page2
    title1: ApplicationInfo.currentCityModel.cityNameDisplay
    title2: ApplicationInfo.currentCityModel.countryName
    title3: qsTr("10 Days Forecast")

    property bool cityLoaded: false

    onCityLoadedChanged: updateStatusBar(ApplicationInfo.currentCityModel.copyright + " <a href=" + ApplicationInfo.currentCityModel.sourceXml + "\>(source)")

    isLocked: true

    pageComponent: Item {
        TouchScrollView {
            id: scrollview
            anchors.fill: parent
            flickableItem.interactive: true
            flickableItem.flickableDirection: Flickable.VerticalFlick
            ColumnLayout {
                id: layout
                spacing: 0
                Repeater {
                    id: repeat
                    model: cityLoaded ? ApplicationInfo.currentCityModel.daysCount() : null
                    LongTermDayItem {
                        Layout.fillWidth: true
                        last: index === repeat.count
                        onNext: nextPage()
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            opacity: cityLoaded ? 0 : 1
            Behavior on opacity { NumberAnimation{}}
            TouchLabel {
                id: label
                opacity: cityLoaded ? 0 : 1
                Behavior on opacity { NumberAnimation{} }
                anchors.centerIn: parent
                text: qsTr("Loading data...")
                horizontalAlignment: Text.AlignCenter
                verticalAlignment: Text.AlignTop
                pixelSize: 28
                color: ApplicationInfo.colors.mediumGray
                height: label.implicitHeight + 80 * ApplicationInfo.ratio
                BusyIndicator {
                    opacity: 0.8
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    height: implicitHeight * ApplicationInfo.ratio
                    width: implicitWidth * ApplicationInfo.ratio
                }
            }
        }
    }

    Connections {
        id: cityModelConnection
        target: ApplicationInfo.currentCityModel
        onError: {
            cityLoaded = false
            isLocked = false
            previousPage()
            updateStatusBar(errorMessage)
        }
        onContentXmlChanged: weathermodel.getLongTermModel(ApplicationInfo.currentCityModel)
    }

    WeatherModel {
        id: weathermodel
        onShowLongTerm: {
            isLocked = false
            cityLoaded = true
        }
        onError: {
            cityLoaded = false
            lastLoadedCity = ""
            isLocked = false
            previousPage()
            updateStatusBar(qsTr("Problem loading the data: ") + errorMessage)
        }
    }

    Stack.onStatusChanged: if (Stack.status === Stack.Active)
                               ApplicationInfo.currentCityModel.loadData()
}
