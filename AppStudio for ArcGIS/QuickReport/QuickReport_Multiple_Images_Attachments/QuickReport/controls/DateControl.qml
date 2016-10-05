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

import QtQuick 2.3
import QtQuick.Controls 1.2

import "../images"
import "styles"

Column {
    id: column
    spacing: 3
    anchors {
        left: parent.left
        right: parent.right
    }

    Text {
        text: fieldAlias

        anchors {
            left: parent.left
            right: parent.right
        }
        color: app.textColor
        font{
            italic: true
            pointSize: app.baseFontSize * 0.7
        }
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: 2
    }
    TextField {

        anchors {
            left: parent.left
            right: parent.right
        }

        placeholderText: "this will be a calendar picker"
        //placeholderText: fieldType == "esriFieldTypeInteger" ? "Enter a number" : "Enter some text"
        //text:
        inputMethodHints: fieldType == "esriFieldTypeInteger" ? Qt.ImhFormattedNumbersOnly : Qt.ImhDigitsOnly
    }
    CalendarWindow {

    }
}
