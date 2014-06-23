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
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0
import org.qtproject.demo.weather 1.0

BasicPage {
    id: page2
    title1: ApplicationInfo.currentCityModel.cityNameDisplay
    title2: ApplicationInfo.currentCityModel.countryName
    title3: qsTr("10 Day Forecast")

    property bool cityLoaded: false

    property string sourceLink: ApplicationInfo.currentCityModel.sourceXml.replace(/\/forecast.xml$/, "")

    onCityLoadedChanged: updateStatusBar(ApplicationInfo.currentCityModel.copyright + " <a href=" + sourceLink + "\>(source)")

    pageComponent: Item {
        TouchScrollView {
            id: scrollview
            anchors.fill: parent
            flickableItem.interactive: true
            flickableItem.flickableDirection: Flickable.VerticalFlick
            Item {
                id: item
                width: scrollview.width
                implicitHeight: grid.implicitHeight
                property int rowHeight: ApplicationInfo.constants.rowDelegateHeight + 1
                Repeater {
                    id: repeater
                    model: cityLoaded ? ApplicationInfo.currentCityModel.daysCount() : null
                    Rectangle {
                        color: mouse.pressed ? ApplicationInfo.colors.smokeGray : ApplicationInfo.colors.white
                        width: scrollview.width
                        height: item.rowHeight
                        y: item.rowHeight * index
                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            onClicked: {
                                ApplicationInfo.currentIndexDay = index
                                nextPage()
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 1
                            anchors.bottom: parent.bottom
                            visible: index != (repeater.count - 1)
                            color: ApplicationInfo.colors.paleGray
                        }
                    }
                }
                GridLayout {
                    id: grid
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: ApplicationInfo.hMargin
                    anchors.rightMargin: ApplicationInfo.hMargin
                    flow: GridLayout.LeftToRight
                    rowSpacing: 0
                    columnSpacing: 6 * ApplicationInfo.ratio
                    columns: r1.count && !!r1.itemAt(0) ? r1.itemAt(0).count : 0
                    Repeater {
                        id: r1
                        model: cityLoaded ? ApplicationInfo.currentCityModel.daysCount() : null
                        Repeater {
                            model: LongTermDayItem {id: longday}
                            property int dayIndex: r1.model !== null ? index : 0
                            property int last: dayIndex === r1.count
                            property var dayModel: ApplicationInfo.currentCityModel.getDayModel(dayIndex)
                            property int rowHeight: item.rowHeight
                        }
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
            previousPage()
            updateStatusBar(errorMessage)
        }
        onContentXmlChanged: weathermodel.getLongTermModel(ApplicationInfo.currentCityModel)
    }

    WeatherModel {
        id: weathermodel
        onShowLongTerm: {
            cityLoaded = true
        }
        onError: {
            cityLoaded = false
            lastLoadedCity = ""
            previousPage()
            updateStatusBar(qsTr("Problem loading the data: ") + errorMessage)
        }
    }

    Stack.onStatusChanged: if (Stack.status === Stack.Active)
                               ApplicationInfo.currentCityModel.loadData()
}
