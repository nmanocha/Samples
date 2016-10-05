/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.3

ComboBoxStyle {
    property int fontSize: 11 * app.scaleFactor

    renderType: Text.QtRendering

    background: Rectangle {
        color: "white"
        height: labelText.height * 1.1
        radius: 4
        border.color: "darkgrey"
        Image {
            id: imageArrow
            source: "../../images/blackArrow.png"
            rotation: 180
            visible: enabled
            width: height

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 3 * app.scaleFactor
            }
            fillMode: Image.PreserveAspectFit
        }
    }

    label: Text {
        id: labelText
        verticalAlignment: Text.AlignVCenter
        //horizontalAlignment: Text.AlignHCenter
        width: parent.width - parent.height - 3
        font.pointSize: app.baseFontSize * 0.6
        color: enabled ? "Black" : "grey"
        text: control.currentText
        elide: Text.ElideRight
    }
    //selectedTextColor: app.fontColor
    selectionColor: app.buttonColor
}
