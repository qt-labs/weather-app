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
