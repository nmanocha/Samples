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
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "styles"
import "../images"

Column {
    id: column
    spacing: 3 * app.scaleFactor

    property alias text: aliasText.text
    property date exampleDate: new Date(272469600000);

    Item{

        height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
        }
        Text {
            id: aliasText
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

        Image {
            anchors {
                right: aliasText.right
                top: aliasText.top
                bottom: aliasText.bottom
            }


            visible:  isRequired

            fillMode: Image.PreserveAspectFit
            source: "../images/warning.png"
        }
    }



    Item {

        height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
        }



        TextField {
            id: textField

            property date todaysDate : new Date()

            anchors {
                left: parent.left
                right: parent.right
            }

            style: EditControlStyle{
                rectHeight: Text.paintedHeight + 10 * app.scaleFactor
            }

            placeholderText: fieldType == Enums.FieldTypeString ? qsTr("Enter some text") : fieldType == Enums.FieldTypeDate ? qsTr("Pick a Date") : qsTr("Enter a number")

            text:  fieldType == Enums.FieldTypeDate ? attributesArray[fieldName] > "" ? new Date (attributesArray[fieldName]).toLocaleDateString(Qt.locale(), Qt.DefaultLocaleShortDate) : "" : (attributesArray[fieldName] || "")

            inputMethodHints: fieldType > 0 && fieldType < 5 ? Qt.ImhDigitsOnly : Qt.ImhNone

            enabled: fieldType == Enums.FieldTypeDate ? false : true

            onTextChanged: {
                if (fieldType != Enums.FieldTypeDate)
                    attributesArray[fieldName] = text;
            }

            Component.onCompleted: {
                //listView.onAttributeUpdate(objectName, text)
                if (fieldType != Enums.FieldTypeDate)
                    attributesArray[fieldName] = text;
            }
        }

        Button {
            anchors {
                right: textField.right
                top: textField.top
                bottom: textField.bottom
            }
            width: height

            visible: fieldType == Enums.FieldTypeDate ? true : false
            enabled: visible
            onClicked: {
                calendarPicker.visible = true;
            }

            Image {
                anchors.fill: parent
                anchors.margins: 1
                fillMode: Image.PreserveAspectFit
                source: "../images/calendar.png"
            }

        }



    }

    CalendarDialog {
        id: calendarPicker

        onVisibleChanged: {
            if (!visible) {
                textField.text = selectedDate.toLocaleDateString(Qt.locale(), Qt.DefaultLocaleShortDate);
                attributesArray[fieldName] = dateMilliseconds;
                console.log("///", textField.text, attributesArray[fieldName]);

            }
        }
    }
}
