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
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import org.qtproject.demo.weather 1.0

Slider {
    id: slider
    implicitHeight: ApplicationInfo.sliderHandleHeight + ApplicationInfo.ratio * 25
    style: SliderStyle {
        groove: Rectangle {
            Rectangle {
                id: beforeHandle
                width: control.value * ApplicationInfo.sliderGapWidth + ApplicationInfo.sliderHandleWidth/2
                height: 20 * ApplicationInfo.ratio
                color: ApplicationInfo.colors.blue
                radius: 90
                z: -1
            }
            Rectangle {
                id: afterHandle
                anchors.left: beforeHandle.right
                anchors.right: parent.right
                height: 20 * ApplicationInfo.ratio
                color: ApplicationInfo.colors.darkGray
                radius: 90
                z: -1
            }
        }
        handle: Item {
            width: ApplicationInfo.sliderHandleWidth
            height: ApplicationInfo.sliderHandleHeight
            Image {
                anchors.centerIn: parent
                source: ApplicationInfo.getImagePath(control.pressed ? "Pointer_pressed.png" : "Pointer.png")
                width: ApplicationInfo.sliderHandleWidth + 16 * ApplicationInfo.ratio
                height: ApplicationInfo.sliderHandleHeight + 16 * ApplicationInfo.ratio
            }
        }
    }
}
