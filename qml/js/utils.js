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

.pragma library

// LongTermPage utils

function getAfternoonIndex(dayModel)
{
    var index = 0
    var count = intervalCount
    if (count > 1)
        index = count - 1
    return index
}

function getTemp(isMax, dayModel) {
    var temp = getTemperature(0, dayModel)
    var count = dayModel.periodCount()
    for (var i = 0; i < count; i++) {
        var currentTemp = getTemperature(i, dayModel)
        if (isMax)
            temp = Math.max(temp, currentTemp)
        else
            temp = Math.min(temp, currentTemp)
    }
    return temp
}

function getMinTemp(dayModel)
{
   return getTemp(false, dayModel)
}

function getMaxTemp(dayModel)
{
    return getTemp(true, dayModel)
}

function getTempFormat(temp)
{
    return temp + "°C"
}

function isNegative(val)
{
    return val < 0
}

// OneDayPage utils

function getFromTime(index, dayModel) {
    var timerange = dayModel.getDayDetails(index, 'timeRange')
    var pattern_time = /(.*) - .*/
    var time = timerange.replace(pattern_time, "$1")
    return time
}

function getToTime(index, dayModel) {
    var timerange = dayModel.getDayDetails(index, 'timeRange')
    var pattern_time = /.* - (.*)/
    var time = timerange.replace(pattern_time, "$1")
    return time
}

function getMaxMinTemp(dayModel) {
    // at least 1 data per day
    var minTemp = dayModel.getDayDetails(0, 'temperature')
    var maxTemp = dayModel.getDayDetails(0, 'temperature')
    for (var i = 1; i < dayModel.periodCount(); i++)
    {
        var tempTemp = dayModel.getDayDetails(i, 'temperature')
        maxTemp = Math.max(tempTemp, maxTemp)
        minTemp = Math.min(tempTemp, minTemp)
    }

    return [minTemp, maxTemp]
}

function getMaxTempLenght(cityModel) {
    var maxLength = 1
    for (var indexDay = 0; indexDay < cityModel.daysCount(); indexDay++) {
        var day = cityModel.getDayModel(indexDay)
        var range = getMaxMinTemp(day)
        maxLength = Math.max(range[0].toString().length, maxLength)
        maxLength = Math.max(range[1].toString().length, maxLength)
    }
    var stringTemp = "555" // temperatures estimated between -55 and +55
    if (maxLength === 3)
        stringTemp = "-" + stringTemp
    return stringTemp.substring(0, maxLength) + "°C."
}

// WeatherModel utils

function getWindType(windspeed)
{
    var speed = parseFloat(windspeed)
    if (speed <= 0.2)
        return "Calm"   // Calm
    if (speed <= 1.5)
        return "0000"   // Light air
    if (speed <= 3.3)
        return "0025"   // Light breeze
    if (speed <= 5.4)
        return "0050"   // Glentle breeze
    if (speed <= 7.9)
        return "0075"   // Moderate breeze
    if (speed <= 10.7)
        return "0100"   // Fresh breeze
    if (speed <= 13.8)
        return "0125"   // Strong breeze
    if (speed <= 17.1)
        return "0150"   // Near gale
    if (speed <= 18.0)
        return "0175"   // Near gale / Gale
    if (speed <= 20.7)
        return "0200"   // Gale
    if (speed <= 24.4)
        return "0225"   // Strong storm
    if (speed <= 28.4)
        return "0250"   // Whole storm
    if (speed <= 32.6)
        return "0300"   // Storm
    return "0350"       // Hurricane
}

function updateDayModel(dayModel, item)
{
    var windIconUrl = getWindSymbolUrl(item.windSpeed, item.windDirectionDeg)
    var weatherUrl = extractSymbolUrl(item.symbolcode)
    var day = Qt.formatDate(new Date(dayModel.date), "dddd")
    var timeRange = getTimeRange(item)

    dayModel.addRow(day, weatherUrl, timeRange, item.temperature, item.windSpeed, windIconUrl, item.rain, item.period)
}

function getItemDate(item)
{
    var fromDateTime = parseDateTime(item.from)
    var toDateTime = parseDateTime(item.to)
    var date = (item.period === "0") ? toDateTime[0] : fromDateTime[0]
    return date
}

function getTimeRange(item)
{
    var fromDateTime = parseDateTime(item.from)
    var toDateTime = parseDateTime(item.to)
    var timeRange = fromDateTime[1] + " - " + toDateTime[1]
    return timeRange
}

function parseDateTime(dt)
{
    var pattern_date = /(.*)T.*/
    var pattern_time = /.*T([0-9][0-9]:[0-9][0-9]).*/
    var time = dt.replace(pattern_time, "$1")
    var date = dt.replace(pattern_date, "$1")
    return [date, time]
}

function getWindSymbolUrl(windspeed, winddir)
{
    var windtype = getWindType(windspeed)
    if (windtype === "Calm")
        return "http://fil.nrk.no/yr/grafikk/vindpiler/32/vindstille.png"

    var iconurl = "http://fil.nrk.no/yr/grafikk/vindpiler/32/vindpil.TYPE.WINDDIRCODE.png"
    var windcode = Math.round((parseFloat(winddir).toFixed(0)) / 5) * 5
    var codeLenght = windcode.toString().length;
    for (var i = codeLenght; i < 3; i++)
        windcode = "0" + windcode

    if (windcode === 360)
        windcode = "000"

    iconurl = iconurl.replace("TYPE", windtype)
    iconurl = iconurl.replace("WINDDIRCODE", windcode)
    return iconurl
}

function extractSymbolUrl(code)
{
    // In order to use yr.no weather data service, refer to their terms
    // and conditions of use. http://om.yr.no/verdata/free-weather-data/
    var iconUrl = "http://symbol.yr.no/grafikk/sym/b100/__CODE__.png"
    return iconUrl.replace("__CODE__", code)
}

// Global

function getDay(index, dayModel)
{
    var day = dayModel.getDayDetails(index, "day")
    return day
}

function getShortDate(date)
{
    return date.substr(8, 2) + "." + date.substr(5, 2) // dd.MM
}

function getLongDate(date)
{
    return date.substr(8, 2) + "." + date.substr(5, 2) + "." + date.substr(0, 4) // dd.MM.yyyy
}

function getRain(index, dayModel)
{
    return dayModel.getDayDetails(index, "rain")
}

function getTemperature(index, dayModel)
{
    return dayModel.getDayDetails(index, "temperature")
}

function getWindSpeed(index, dayModel)
{
    return dayModel.getDayDetails(index, "windSpeed")
}

function getWindUrl(index, dayModel)
{
    var url = dayModel.getDayDetails(index, "windUrl")
    return dayModel.getCachedImageFile(url)
}

function getWeatherUrl(index, dayModel, size)
{
    var smallUrl = dayModel.getDayDetails(index, "weatherUrl")
    if (size === "large")
        smallUrl = smallUrl.replace("b100", "b200")
    else
        smallUrl = smallUrl
    return dayModel.getCachedImageFile(smallUrl)
}

