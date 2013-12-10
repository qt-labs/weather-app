/****************************************************************************
**
** Copyright (C) 2013 Digia Plc
** All rights reserved.
** For any questions to Digia, please use contact form at http://qt.digia.com
**
** This file is part of the QtQuick Enterprise Controls Demos.
**
** $QT_BEGIN_LICENSE$
** Licensees holding valid Qt Commercial licenses may use this file in
** accordance with the Qt Commercial License Agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.
**
** If you have questions regarding the use of this file, please use
** contact form at http://qt.digia.com
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.1

ListModel {
    ListElement { sourceXml: "http://www.yr.no/place/Norway/Oslo/Oslo/Oslo/forecast.xml"; name: "Oslo"; country: "Norway"}
    ListElement { sourceXml: "http://www.yr.no/place/France/Île-de-France/Paris/forecast.xml"; name: "Paris"; country: "France"}
    ListElement { sourceXml: "http://www.yr.no/place/United_Kingdom/England/London/forecast.xml"; name: "London"; country: "United Kingdom"}
    ListElement { sourceXml: "http://www.yr.no/place/Germany/Berlin/Berlin/forecast.xml"; name: "Berlin"; country: "Germany"}
    ListElement { sourceXml: "http://www.yr.no/place/United_States/California/San_Francisco/forecast.xml"; name: "San Francisco"; country: "United States"}
    ListElement { sourceXml: "http://www.yr.no/place/Italy/Lazio/Rome/forecast.xml"; name: "Rome"; country: "Italia"}
    ListElement { sourceXml: "http://www.yr.no/place/Antarctica/Other/Vostok_Station/forecast.xml"; name: "Vostok Station"; country: "Antarctica"}
    ListElement { sourceXml: "http://www.yr.no/place/Mali/Tombouctou/Timbuktu/forecast.xml"; name: "Timbuktu"; country: "Mali"}
}
