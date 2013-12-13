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
import QtQuick.Layouts 1.0
import org.qtproject.demo.weather 1.0

BasicPage {
    id: page1
    title1: qsTr("Cities")

    signal cityDeleted(string city)
    property int selected:  -1

    Binding {
        target: page1
        property: "pageComponent"
        value: listViewComponent
        when: hasNoSearchText
    }
    Binding {
        target: page1
        property: "pageComponent"
        value: searchViewComponent
        when: !hasNoSearchText
    }

    onSearchTextChanged : ApplicationInfo.queryCities(searchText)

    property Component searchViewComponent: TouchScrollView {
        flickableItem.interactive: true
        flickableItem.flickableDirection: Flickable.VerticalFlick
        ListView {
            interactive: true
            flickableDirection: Flickable.VerticalFlick
            model: ApplicationInfo.foundCities
            delegate: ListViewDelegate {
                isSearchView: true
                onClicked: validateSearchIndex(index)
            }
        }
    }
    property Component listViewComponent: TouchScrollView {
        flickableItem.interactive: true
        flickableItem.flickableDirection: Flickable.VerticalFlick
        ListView {
            id: listview
            model: availableCities
            interactive: true
            flickableDirection: Flickable.VerticalFlick
            delegate: ListViewDelegate {
                onClicked: page1.processCity(index)
                onDeleteCity: availableCities.removeCityModel(index)
            }
            currentIndex: page1.selected
            TouchLabel {
                z: 1
                anchors.centerIn: parent
                visible: listview.count === 0
                text: "No Cities"
                color: ApplicationInfo.colors.lightGray
            }
        }
    }

    Connections {
        target: ApplicationInfo
        onWaitForCitiesQueryReply: if (ApplicationInfo.isMobile) updateStatusBar(message)
        onErrorOnQueryCities: updateStatusBar(errorMessage)
    }

    onSearchBoxReturn: validateSearchIndex(0)
    onClearSearchBox: {
        searchText = ""
        blueRect.forceActiveFocus() // attempt to clear focus in TextField
        Qt.inputMethod.hide()
    }
    function validateSearchIndex(index) {

        if (!ApplicationInfo.foundCities.isEmpty) {
            // get sourcexml at index
            var foundIndex = availableCities.processSourceXml(ApplicationInfo.foundCities.getCitySourceXml(index))
            if (foundIndex > -1)
                processCity(foundIndex)
        }
        clearSearchBox()
    }
    function processCity(index)
    {
        if (!isLocked) {
            page1.selected = index
            ApplicationInfo.currentCityModel = availableCities.getCityModel(index)
            nextPage()
        }
    }

    Cities { id: availableCities }

    Connections {
        target: Qt.application
        onStateChanged: if (ApplicationInfo.constants.isMobile && Qt.application.state === Qt.ApplicationSuspended) availableCities.saveCities()
    }

    Stack.onStatusChanged: {
        isLocked = !(Stack.status === Stack.Active)
        if (Stack.status === Stack.Activating)
            updateStatusBar("")
    }
}
