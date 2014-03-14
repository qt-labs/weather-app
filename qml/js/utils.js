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

.pragma library
.import QtQml 2.2 as QtQml

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
    return temp + qsTr("°C")
}

function isNegative(val)
{
    return val < 0
}

// OneDayPage utils

function getFromTime(index, dayModel) {
    var fromDate = dayModel.getDayDetails(index, 'from')
    var fromTime = Qt.formatTime(new Date(fromDate), Qt.locale().timeFormat(QtQml.Locale.ShortFormat))
    fromTime = fromTime.replace(/(:00) /, "") // save some space if display like 11:00 am
    return fromTime
}

function getToTime(index, dayModel) {
    var toDate = dayModel.getDayDetails(index, 'to')
    var toTime = Qt.formatTime(new Date(toDate), Qt.locale().timeFormat(QtQml.Locale.ShortFormat))
    toTime = toTime.replace(/(:00) /, "") // save some space if display like 11:00 am
    return toTime
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
    return stringTemp.substring(0, maxLength)
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
    dayModel.addRow(weatherUrl, item.from, item.to, item.temperature, item.windSpeed, windIconUrl, item.rain, item.period)
}

function getItemDate(item)
{
    var fromDateTime = parseDateTime(item.from)
    var toDateTime = parseDateTime(item.to)
    var date = (item.period === "0") ? toDateTime[0] : fromDateTime[0]
    return date
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

function getDay(index, dayModel, isShort)
{
    if (isShort === undefined)
        isShort = false
    var dayDate = new Date(dayModel.date)
    return Qt.locale().dayName(dayDate.getDay(), isShort ? QtQml.Locale.ShortFormat : QtQml.Locale.LongFormat )
}

function getShortDate(date)
{
    var d = new Date(date)
    var formatWithYear = Qt.locale().dateFormat(QtQml.Locale.ShortFormat)
    var formatWithoutYear = formatWithYear.replace(/[y]{1,4}/, "")
    formatWithoutYear = formatWithoutYear.replace(/^\W/, "")
    formatWithoutYear = formatWithoutYear.replace(/\W$/, "")
    return Qt.formatDate(d, formatWithoutYear)
}

function getLongDate(date)
{
    var d = new Date(date)
    return Qt.formatDate(d, Qt.locale().dateFormat(QtQml.Locale.ShortFormat))
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

function getLongestShortDayName()
{
    // Used to get the maximum short day length
    var longestDayName = ""
    for (var day = 0; day < 6; day++) {
        var temp = Qt.locale().dayName(day, QtQml.Locale.ShortFormat)
        if (temp.toString().length > longestDayName.toString().length)
            longestDayName = temp
    }
    return longestDayName
}

function getTodayShortDate()
{
    // Used to get the short date format length
    var currentDate = new Date()
    return getShortDate(currentDate)
}

