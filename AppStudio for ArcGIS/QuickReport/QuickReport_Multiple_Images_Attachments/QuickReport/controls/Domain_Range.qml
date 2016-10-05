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

import ArcGIS.AppFramework.Runtime 1.0
import "../images"
import "styles"

Column {
    id: column

    property string rangeMinLabel
    property string rangeMaxLabel
    property date exampleDate: new Date(272469600000);

    spacing: 3
    anchors {
        left: parent.left
        right: parent.right
    }

    Text {
        text: fieldAlias + " (" + rangeMinLabel + " - " + rangeMaxLabel +")"

        anchors {
            left: parent.left
            right: parent.right
        }
        color: fieldType == Enums.FieldTypeDate ? app.textColor : textField.acceptableInput ? "green" : "red"
        font{
            italic: true
            pointSize: app.baseFontSize * 0.7
        }
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: 2
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

            placeholderText: fieldType == Enums.FieldTypeString ? "Enter some text" : fieldType == Enums.FieldTypeDate ? exampleDate.toLocaleDateString(Qt.locale(), Qt.DefaultLocaleShortDate) : "Enter a number"
            text: defaultValue ? defaultValue : fieldType == Enums.FieldTypeString ? "" : fieldType == Enums.FieldTypeDate ? todaysDate.toLocaleDateString(Qt.LocalDate) : 0
            inputMethodHints: fieldType > 0 && fieldType < 5 ? Qt.ImhDigitsOnly : fieldType == Enums.FieldTypeDate ? Qt.ImhDate : null

            validator:  fieldType == "esriFieldTypeDouble" ? dblValidator : intValidator

            onTextChanged: {
                if ( fieldType != Enums.FieldTypeDate) {
                    console.log("Is the range value for", fieldName, "is acceptable?", acceptableInput);
                    listView.canSubmit = acceptableInput;

                    attributesArray[fieldName] = text;
                }
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

    IntValidator {
        id: intValidator
        
        bottom: rangeArray[0]
        top: rangeArray[1]
    }
    
    DoubleValidator {
        id: dblValidator
        
        bottom: rangeArray[0]
        top: rangeArray[1]
    }
    
    
    CalendarDialog {
        id: calendarPicker

        onVisibleChanged: {
            if (!visible) {
                console.log("///", dateMilliseconds)
                textField.text = selectedDate.toLocaleDateString(Qt.LocalDate);
                attributesArray[fieldName] = dateMilliseconds;
            }
        }
    }

    Component.onCompleted: {
        if ( fieldType == Enums.FieldTypeDate ) {
            var dMin = new Date(rangeArray[0]);
            var dMax = new Date(rangeArray[1]);

            rangeMinLabel = dMin.toLocaleDateString(Qt.LocalDate);
            rangeMaxLabel = dMax.toLocaleDateString(Qt.LocalDate);

            calendarPicker.minDate = dMin;
            calendarPicker.maxDate = dMax;
        }
        else {
            rangeMinLabel = rangeArray[0];
            rangeMaxLabel = rangeArray[1];
        }
    }

}
