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
        property int sliderItemWidth : (model.periodCount() + 1) * canvasSlider.drawingOffset + ApplicationInfo.sliderHandleWidth
        Layout.alignment: Qt.AlignHCenter

        property int drawingOffset: ApplicationInfo.sliderGapWidth
        property var rangeTemp: Utils.getMaxMinTemp(model)

        implicitWidth: sliderItemWidth
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
            ctx.translate(canvasSlider.drawingOffset + ApplicationInfo.sliderHandleWidth/2, marginsTemperaturesDrawing + weatherIconWidth + 15 * ApplicationInfo.ratio + circleIconWidth/2)
            for (var i = 0; i < count; i++) {
                var temperatureStart = canvasSlider.calibrate(Utils.getTemperature(i, model))
                var temperatureEnd = canvasSlider.calibrate(Utils.getTemperature(i + 1, model))
                ctx.moveTo(i * drawingOffset, -temperatureStart)
                if ( (i+1) < count)
                    ctx.lineTo((i + 1) * drawingOffset, -temperatureEnd)
            }
            ctx.stroke()
            ctx.closePath()
            ctx.restore();
        }
        Repeater {
            id: repeater
            model: root.model.periodCount()
            Column {
                width: canvasSlider.weatherIconWidth
                x: (1 + index) * canvasSlider.drawingOffset - ApplicationInfo.sliderHandleWidth/2 + canvasSlider.weatherIconWidth/2 - canvasSlider.circleIconWidth/2
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
            width : canvasSlider.sliderItemWidth
            TouchSlider {
                id: touchSlider
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: canvasSlider.sliderItemWidth - 2 * canvasSlider.drawingOffset
                minimumValue: 0
                maximumValue: model.periodCount() - 1
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 0
                Layout.preferredWidth: canvasSlider.sliderItemWidth - ApplicationInfo.sliderHandleWidth
                  Repeater {
                    model: root.model.periodCount() + 1
                    TouchLabel {
                        pixelSize: 22
                        Layout.preferredWidth: canvasSlider.drawingOffset
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
