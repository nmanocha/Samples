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

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    focus: true

    ListView {
        clip: true
        spacing: 20*app.scaleFactor
        width: 300*app.scaleFactor
        height: parent.height
        //anchors.topMargin: 20*app.scaleFactor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model: theFeatureTypesModel

        header: Text {
            text: pickListCaption
            height: 50*app.scaleFactor
            width: parent.width
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.topMargin: 10*app.scaleFactor
            anchors.bottomMargin: 10*app.scaleFactor
            fontSizeMode: Text.Fit
            font {
                pointSize: app.baseFontSize * 0.9
            }
            color: app.textColor
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        delegate: Component {

            id: issueListViewDelegate

            Rectangle{
                width: 300*app.scaleFactor
                height: 50*app.scaleFactor
                color: app.pageBackgroundColor
                anchors.margins: 10*app.scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
                objectName: value
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height-parent.anchors.margins
                    Image{
                        source: imageUrl
                        height : parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        enabled: status == Image.Error ? false : true
                        visible: enabled
                        onStatusChanged: if (status == Image.Error) source = "../images/item_thumbnail_square.png"
                    }

                    Text {
                        text: label
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        anchors.leftMargin: 20*app.scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10*app.scaleFactor
                        font {
                            pointSize: app.baseFontSize * 0.8
                        }
                        color: app.textColor
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        getProtoTypeAndSubTypeDomains(index);
                    }
                }
            }
        }
    }

    function getProtoTypeAndSubTypeDomains(pickedIndex) {
        console.log("Prototypes length", app.featureTypes.length)
        featureType = app.featureTypes[pickedIndex];

        console.log("!!!", JSON.stringify(featureType.templates[0].prototype, undefined, 2));

        var domains = featureType.domains;

        for ( var j = 0; j < fields.length; j++ ) {

            if ( fields[j].name === theFeatureServiceTable.typeIdField ) {
                theFeatureAttributesModel.setProperty(j, "isSubTypeField", true);

            }
        }
        pickListIndex = pickedIndex;
        backToPreviousPage = false;

        loader.source = "../pages/AttributesPage.qml"

    }
}

