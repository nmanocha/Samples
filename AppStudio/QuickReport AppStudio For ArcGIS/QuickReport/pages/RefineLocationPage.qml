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
import QtPositioning 5.3
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "../controls"

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    signal next(string message)
    signal previous(string message)

    property alias theMap : page3_map
    property string gpsLocationString : ""

    property real xCoord
    property real yCoord

    Point {
        id: myPosition
        property bool valid : false
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    PositionSource {
        id: gpsPositionSource
        active: true

        onActiveChanged: console.log("pos source", active)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 5 * app.scaleFactor
        spacing: 3 * app.scaleFactor

        Rectangle {
            id: createPage_headerBar
            Layout.alignment: Qt.AlignTop
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
                    console.log("Back button from create page clicked");
                    skipPressed = false;
                    previous("");
                }
            }

            Text {
                id: createPage_titleText
                text: qsTr("Add Location")
                textFormat: Text.StyledText
                anchors.centerIn: parent
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }

        Text {
            id: page3_description
            text:qsTr("Move map to refine location")
            textFormat: Text.StyledText
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter

            visible: AppFramework.network.isOnline

            font {
                //pointSize: app.baseFontSize * 0.8
                pointSize: app.baseFontSize * 0.5

            }
            color: app.textColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            fontSizeMode: Text.Fit
        }

        Map {
            id: page3_map
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(280*app.scaleFactor, parent.height/3)

            //visible: AppFramework.network.isOnline

            onVisibleChanged: console.log(status, layerCount)

            wrapAroundEnabled: false
            rotationByPinchingEnabled: false
            magnifierOnPressAndHoldEnabled: false
            mapPanningByMagnifierEnabled: false

            ArcGISTiledMapServiceLayer {
                url: baseMapURL
                onStatusChanged: console.log("status", status, statusString)
            }

            Image {
                source: "../images/esri_pin_red.png"
                width: 20*app.scaleFactor
                height: 40*app.scaleFactor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.verticalCenter
                }
            }

            positionDisplay {
                positionSource: posSource
                //positionSource: PositionSource {
                //                    onPositionChanged: console.log("position", position.coordinate.x, position.coordinate.y)
                //                }
            }

            ZoomButtons {
                id: zoomButtons
                anchors {
                    right: parent.right
                    //verticalCenter: parent.verticalCenter
                    top: parent.top
                    margins: 5
                }
                map: page3_map
                fader.minumumOpacity: 0.5
            }

            onExtentChanged: {
                var pt_wgs = page3_map.extent.center.project(theNewPoint.spatialReference);
                theNewPoint.x = pt_wgs.x;
                theNewPoint.y = pt_wgs.y;

                xCoord = page3_map.extent.center.x
                yCoord = page3_map.extent.center.y
                console.log("Report location after extent changed: ", JSON.stringify(theNewPoint.json));
            }

            onStatusChanged: {
                if(status == Enums.MapStatusReady) {
                    if(!app.selectedImageHasGeolocation) {
                        theNewPoint = ArcGISRuntime.createObject("Point");
                        theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});
                    }
                    console.log("RefineLocation: Map Ready!");
                    console.log("RefineLocation: Photo Exif Point: ", JSON.stringify(theNewPoint.json));

                    if(theNewPoint.x && theNewPoint.y){
                        page3_map.positionDisplay.positionSource.active = false;
                        //photo exif
                        page3_latlongText.text = theNewPoint.toDecimalDegrees(4) + " (Photo)";
                        var pt = theNewPoint.project(page3_map.spatialReference);
                        page3_map.zoomTo(pt);
                    } else {
                        //current device position
                        page3_map.positionDisplay.positionSource.active = true;
                        page3_map.positionDisplay.mode = Enums.AutoPanModeDefault;
                    }
                }
            }
            Component.onCompleted: {

                if(theNewPoint && theNewPoint.valid) {
                    page3_map.positionDisplay.positionSource.active = false;
                }

                if (status != Enums.MapStatusReady ) {
                    if (posSource.active && posSource.valid && !theNewPoint) {
                        theNewPoint = ArcGISRuntime.createObject("Point");
                        theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});
                        theNewPoint.setXY(posSource.position.coordinate.longitude, posSource.position.coordinate.latitude)

                        var pp = theNewPoint.project(theFeatureLayer.spatialReference);
                        console.log("NEW temp Coords", theNewPoint.x, pp.x, theNewPoint.y, pp.y);

                        xCoord = pp.x;
                        yCoord = pp.y;
                    }
                    else {
                        xCoord = 0;
                        yCoord = 0;
                    }
                }
            }
        }


        ColumnLayout {
            id: page3_coordinates

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Text {
                id: page3_Message
                text: qsTr("No Location available.")
                textFormat: Text.StyledText
                visible: !page3_latlongText.visible
                font {
                    pointSize: app.baseFontSize * 0.5                    
                }
                color: app.textColor
                Layout.alignment: Qt.AlignHCenter

            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Text {
                    id: page3_latlongText
                    text: page3_map.extent.center.toDecimalDegrees(5)
                    textFormat: Text.StyledText                    
                    font {
                        pointSize: app.baseFontSize * 0.5                        
                    }
                    color: app.textColor
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }            
        }

        CustomButton{
            id:page3_button1
            buttonText: qsTr("Next: Add Details")
            buttonColor: app.buttonColor            
            buttonTextColor: "#ffffff"
            buttonWidth: 300 * app.scaleFactor
            buttonHeight: buttonWidth/5

            Layout.alignment: Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    next("");
                }
            }
        }
    }
}

