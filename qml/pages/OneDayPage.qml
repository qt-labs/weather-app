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
import org.qtproject.demo.weather 1.0
import "../js/utils.js" as Utils

BasicPage {
    id : page3
    title1: ApplicationInfo.currentCityModel.cityNameDisplay
    title2: ApplicationInfo.currentCityModel.countryName

    property QtObject dayModel: ApplicationInfo.currentCityModel.getDayModel(ApplicationInfo.currentIndexDay)

    onDayModelChanged: if (!!dayModel) {
                           if (ApplicationInfo.currentIndexDay === 0)
                               title3 = qsTr("Today")
                           else if (ApplicationInfo.currentIndexDay === 1)
                               title3 = qsTr("Tomorrow")
                           else
                               title3 = Utils.getDay(0, dayModel) + " " + Utils.getLongDate(dayModel.date)
                       }

    pageComponent: GridLayout {
        id: splitview
        flow: !ApplicationInfo.isPortraitMode ? GridLayout.LeftToRight : GridLayout.TopToBottom
        property bool singleItem: sliderItem.slider.minimumValue === sliderItem.slider.maximumValue
        Separator {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        OneDayZoomItem {
            id: zoom
            slider: sliderItem.slider
            model: page3.dayModel
            singleItem: splitview.singleItem
        }
        Separator {
            Layout.fillHeight: true
            Layout.fillWidth: true
            implicitHeight: 10 * ApplicationInfo.ratio
            implicitWidth: 10 * ApplicationInfo.ratio
            Layout.minimumWidth: 0
            Layout.minimumHeight: 0
            visible: !singleItem
        }
        OneDaySliderItem {
            id: sliderItem
            visible: !singleItem
            model: page3.dayModel
        }
        Separator {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Stack.onStatusChanged: isLocked = !(Stack.status === Stack.Active)

}
