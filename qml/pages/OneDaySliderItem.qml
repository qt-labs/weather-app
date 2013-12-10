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
import "../js/utils.js" as Utils
import org.qtproject.demo.weather 1.0

GridLayout {
    id: root
    flow: ApplicationInfo.isPortraitMode ? GridLayout.LeftToRight : GridLayout.TopToBottom

    property alias slider: touchSlider
    property QtObject model

    Separator {
        Layout.fillHeight: true
        Layout.fillWidth: ApplicationInfo.isPortraitMode ? true : false
        Layout.minimumHeight: 10
    }
    Canvas {
        id: canvasSlider
        Layout.alignment: Qt.AlignHCenter

        property int drawingOffset: ApplicationInfo.sliderGapWidth
        property var rangeTemp: Utils.getMaxMinTemp(model)

        implicitWidth: touchSlider.width + 2 * drawingOffset
        implicitHeight: 3.8*drawingOffset

        property int marginsTemperaturesDrawing: calibrate(rangeTemp[1]) +  10 * ApplicationInfo.ratio
        property real circleIconWidth: 20 * ApplicationInfo.ratio
        property real weatherIconWidth: 80 * ApplicationInfo.ratio

        function calibrate(temperature) {
            return 2 * ApplicationInfo.ratio * temperature
        }

        antialiasing: true
        smooth: true
        onPaint: {
            var ctx = getContext('2d')
            var count = model.periodCount()
            ctx.save()
            ctx.beginPath();
            ctx.fillStyle = ApplicationInfo.colors.doubleDarkGray
            ctx.lineWidth = 1
            ctx.translate(touchSlider.x, marginsTemperaturesDrawing + weatherIconWidth + 15 * ApplicationInfo.ratio + circleIconWidth/2)
            ctx.moveTo(drawingOffset/2, 0)
            for (var i = 0; i < count; i++) {
                ctx.moveTo((i + .5 )* drawingOffset, 0)
                var temperatureStart = canvasSlider.calibrate(Utils.getTemperature(i, model))
                var temperatureEnd = canvasSlider.calibrate(Utils.getTemperature(i + 1, model))
                ctx.moveTo((i + 1 )* drawingOffset, -temperatureStart)
                if ( (i+1) < count)
                    ctx.lineTo((i + 2) * drawingOffset, -temperatureEnd)
            }
            ctx.stroke()
            ctx.closePath()
            ctx.restore();
        }
        Repeater {
            id: repeater
            model: root.model.periodCount()
            Column {
                x: (index + 1.5) * ApplicationInfo.sliderGapWidth - canvasSlider.weatherIconWidth/2 - canvasSlider.circleIconWidth/2
                y: -canvasSlider.calibrate(temperature) + canvasSlider.marginsTemperaturesDrawing
                property int temperature: Utils.getTemperature(index, root.model)
                height: parent.height
                id: col
                Image {
                    source: Utils.getWeatherUrl(index, root.model)
                    width: canvasSlider.weatherIconWidth
                    height: width
                    anchors.horizontalCenter: col.horizontalCenter
                }
                Item {
                    height: 15 * ApplicationInfo.ratio
                    width: height
                }
                Image {
                    id: circle
                    source: ApplicationInfo.getImagePath("Circle.png")
                    width: canvasSlider.circleIconWidth
                    height: width
                    anchors.horizontalCenter: col.horizontalCenter
                }
                Item {
                    height: 15 * ApplicationInfo.ratio
                    width: height
                }
                TouchLabel {
                    text: Utils.getTempFormat(temperature)
                    pixelSize: 24
                    color: temperature > 0 ? ApplicationInfo.colors.doubleDarkGray : ApplicationInfo.colors.blue
                    anchors.horizontalCenter: col.horizontalCenter
                }
            }
        }
        ColumnLayout {
            id: column
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            TouchSlider {
                id: touchSlider
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: (model.periodCount() - 1) * canvasSlider.drawingOffset + ApplicationInfo.sliderHandleWidth
                minimumValue: 0
                maximumValue: model.periodCount() - 1
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: model.periodCount() * canvasSlider.drawingOffset + ApplicationInfo.sliderHandleWidth
                spacing: 0
                Repeater {
                    model: root.model.periodCount() + 1
                    TouchLabel {
                        pixelSize: 24
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.alignment: Qt.AlignBaseline
                        text: (!!root.model && index !== root.model.periodCount()) ? Utils.getFromTime(index, root.model) : Utils.getToTime(index-1, root.model)
                    }
                }
            }
        }

    }
    Separator {
        Layout.fillHeight: true
        Layout.fillWidth: ApplicationInfo.isPortraitMode ? true : false
        Layout.minimumHeight: 10
    }
}
