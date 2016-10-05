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
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "../controls"

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor


    property bool isBusy: false

    signal next(string message)
    signal previous(string message)

    Feature {
        id: featureToEdit2
        geometry: Point {
            x:0
            y:0
            spatialReference: SpatialReference {
                wkid: 4326
            }
        }
    }

    function submitReport(){

        console.log("New point geom: ", JSON.stringify(app.theNewPoint.json));
        //console.log("nakul submit test")

        var featureToEdit = ArcGISRuntime.createObject("GeodatabaseFeature");
        var pt = app.theNewPoint.project(app.theFeatureServiceSpatialReference);
        console.log("Pt geom: ", JSON.stringify(pt.json));

        featureToEdit.geometry = pt;
        console.log("Adding geometry: ", JSON.stringify(featureToEdit.geometry.json));

        for ( var field in attributesArray) {
            if ( attributesArray[field] == "") {
                console.log("!!!test", field , null)
                featureToEdit.setAttributeValue(field, null);
            }
            else {
                console.log("!!test", field , JSON.stringify(attributesArray[field]))

//                var value;

//                for (var f in fields){
//                    if (field === fields[f].name && fields[f].fieldType === 5){
//                        console.log("@@@", Date.parse(attributesArray[field]))
//                        console.log(field, "woo hoo", Date.parse(attributesArray[field]))
//                        attributesArray[field] = Date.parse(attributesArray[field]);
//                        break;
//                    }
//                }

                featureToEdit.setAttributeValue(field, attributesArray[field]);
            }
        }

        app.featureServiceStatusString = "Adding the report ...";

        console.log("Submitting feature: ", JSON.stringify(featureToEdit.json));

        if (AppFramework.network.isOnline) {
            var id = theFeatureServiceTable.addFeature(featureToEdit);
            console.log("Feature ID:", id)

            app.theFeatureToBeInsertedID = id;
            app.featureServiceStatusString = app.reportSubmitMsg;
            app.currentAddedFeatures = theFeatureServiceTable.addedFeatures;
            theFeatureServiceTable.applyFeatureEdits();
        }

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: resultsPage_headerBar
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ImageButton {
                source: "../images/back-left.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log("Back button from create page clicked")
                    previous("")
                }
            }

            Text {
                id: resultsPage_titleText
                text: qsTr("Thank You")
                textFormat: Text.StyledText
                anchors.centerIn: parent
                fontSizeMode: Text.Fit
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                //anchors.leftMargin: 10
            }
        }

        CustomButton{
            id:page2_button3
            buttonText: qsTr("DONE")
            buttonColor: app.buttonColor
            buttonWidth: 300 * app.scaleFactor
            buttonHeight: buttonWidth/5
            opacity: app.theFeatureEditingAllDone ? 1 : 0.5
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: 10*app.scaleFactor
                bottomMargin: 10*app.scaleFactor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    next("home")
                    app.theFeatureEditingAllDone = false;
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color:"transparent"
            Layout.preferredWidth: parent.width
            anchors.topMargin: 10*app.scaleFactor
            anchors.bottomMargin: 10*app.scaleFactor
            anchors.top: resultsPage_headerBar.bottom
            anchors.bottom: page2_button3.top

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height
                contentHeight: parent.height + 30
                clip: true

                Item {
                    anchors.fill: parent

                    Text {
                        id: resultsPage_statusText
                        text: app.featureServiceStatusString
                        textFormat: Text.StyledText
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            pointSize: app.baseFontSize * 0.75
                        }
                        color: app.textColor
                        //maximumLineCount: 8
                        wrapMode: Text.Wrap
                        lineHeight: 1.2
                        elide: Text.ElideRight
                        anchors.margins: 10*app.scaleFactor
                        anchors.topMargin: 20*app.scaleFactor

                        Component.onCompleted: {
                            Qt.inputMethod.hide();
                            //                            if(app.isOnline) {
                            submitReport()
                            if ( theFeatureServiceTable.hasAttachments && skipPressed){
                                app.hasAttachment = true;
                            }
                            //                            } else {
                            //                                saveReport()
                            //                            }
                        }
                    }

                    BusyIndicator {
                        z:11
                        visible: !app.theFeatureEditingAllDone
                        anchors.centerIn: parent
                    }

                    Image {
                        source: app.theFeatureEditingSuccess ? "../images/tick.png" : "../images/sad.png"
                        visible: app.theFeatureEditingAllDone
                        anchors.top: resultsPage_statusText.bottom
                        anchors.bottom: page2_button3.top
                        width: 128*app.scaleFactor
                        height: 128*app.scaleFactor
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }


                }
            }
        }
    }
}
