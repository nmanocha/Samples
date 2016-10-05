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
import ArcGIS.AppFramework.Runtime 1.0

import "styles"

Column {
    id: column

    anchors{
        left: parent.left
        right:parent.right
    }
    spacing: 3 * app.scaleFactor

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

    ComboBox {
        id: comboBox
        model: codedNameArray
        anchors{
            left: parent.left
            right:parent.right
        }

        style: EditComboBoxStyle{        }

        enabled: !isSubTypeField

        onCurrentIndexChanged: {
            attributesArray[fieldName] = codedCodeArray[comboBox.currentIndex];
        }
    }

    Component.onCompleted: {
        if ( isSubTypeField ){
            comboBox.currentIndex = pickListIndex;
        }
        else {
            if ( hasPrototype ) {
                console.log(codedCodeArray.indexOf( defaultValue.toString() ), typeof ( codedCodeArray.indexOf( defaultValue.toString() )), codedNameArray.indexOf( codedNameArray[codedCodeArray.indexOf( defaultValue.toString() )]) )
                comboBox.currentIndex = codedNameArray.indexOf( codedNameArray[codedCodeArray.indexOf( defaultValue.toString() )]);
            }
            else {
                comboBox.currentIndex = defaultIndex;
            }
        }
        attributesArray[fieldName] = codedCodeArray[comboBox.currentIndex];
    }
}
