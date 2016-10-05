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
import QtMultimedia 5.4
import Qt.labs.folderlistmodel 2.1
import QtQuick.Window 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Dialogs 1.0
import ArcGIS.AppFramework.Runtime 1.0

//Thanks to
//http://doc.qt.digia.com/qtquick-components-symbian-1.1/demos-symbian-musicplayer-qml-filepickerpage-qml.html

Item {

    id: cameraWindow

    property int orientationValue: orientationToString(Screen.orientation)
    property int screenOrientation: Screen.orientation
    readonly property bool isPortrait : screenOrientation == 1 || screenOrientation == 4

    onOrientationValueChanged: {
        loader.destroy();
        loader.sourceComponent = videoComponent;
    }

    width: parent.width
    height: parent.height

    z: 88

    property string title: "Camera"

    visible: false

    signal select(string fileName)

    function orientationToString(o) {
        switch (o) {
        case Qt.PrimaryOrientation:
            return "primary";
        case Qt.PortraitOrientation:
            return "portrait";
        case Qt.LandscapeOrientation:
            return "landscape";
        case Qt.InvertedPortraitOrientation:
            return "inverted portrait";
        case Qt.InvertedLandscapeOrientation:
            return "inverted landscape";
        }
        return "unknown";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: title
                textFormat: Text.StyledText
                anchors.centerIn: parent
                //anchors.left: parent.left
                //anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 10
            }

            ImageButton {
                source: "../images/close.png"
                rotation: -90
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    camera.stop();
                    cameraWindow.visible = false
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            BusyIndicator {
                anchors.centerIn: parent
                visible: !camera.imageCapture.ready
            }

            Camera {
                id: camera


                cameraState: cameraWindow.visible ? Camera.ActiveState : Camera.UnloadedState

                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                captureMode: Camera.CaptureStillImage

                exposure {
                    exposureCompensation: -1.0
                    exposureMode: Camera.ExposurePortrait
                }

                flash.mode: Camera.FlashRedEyeReduction

                imageCapture {

                    resolution: Qt.size(parent.width, parent.height)


                    onImageMetadataAvailable: {
                        console.log("Image Metadata Callback : "+key+" = "+value)
                    }

                    onImageCaptured: {
                        // Show the preview in an Image
                        //photoPreview.visible = true
                        //photoPreview.source = preview
                    }

                    onCapturedImagePathChanged: {
                        console.log("Camera image path changed: ", camera.imageCapture.capturedImagePath);
                        //camera.stop();
                        //videoOutput.destroy();
                        //camera.destroy();
                        select(camera.imageCapture.capturedImagePath);
                        cameraWindow.visible = false;
                    }
                }
            }
            Item {
                anchors.fill: parent
                Loader {
                    id: loader
                    anchors.fill: parent
                    sourceComponent: videoComponent
                }

                Component {
                    id: videoComponent
                    VideoOutput {
                        id: videoOutput
                        source: camera
                        focus : visible // to receive focus and capture key events when visible
                        anchors.fill: parent
                        autoOrientation: true

                        fillMode: VideoOutput.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent;
                            //onClicked: camera.imageCapture.capture();
                            onClicked: camera.imageCapture.captureToLocation(appFolder.filePath("Camera_" + new Date().getTime()))
                        }

                        Component.onCompleted: {
                            console.log("pic Orientation:", orientation, Qt.platform.os)
                        }
                    }
                }
            }

            ImageButton {
                anchors {
                    bottom: parent.bottom
                    margins: 20
                    horizontalCenter: parent.horizontalCenter
                }

                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"


                width: 80 * app.scaleFactor
                height: 80 * app.scaleFactor

                source: "../images/camera_icon.png"

                onClicked: {
                    camera.imageCapture.capture();
                }
            }
        }
    }

    Component.onCompleted: {
        Screen.orientationUpdateMask = Qt.PortraitOrientation | Qt.InvertedLandscapeOrientation | Qt.InvertedPortraitOrientation | Qt.LandscapeOrientation
        console.log("my orientation:", Screen.orientation)
    }
}
