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
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    signal next(string message)
    signal previous(string message)

    property string fileLocation: "../images/placeholder.png"

    ImagePicker {
        id: imagePicker
        title: "Select Photo"

        onSelect: {
            fileLocation = fileName
        }
    }

    CameraWindow {
        id: cameraWindow
        title: "Camera"

        onSelect: {
            fileLocation = fileName
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: createPage_headerBar
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
                id: createPage_titleText
                text: "Add Photo"
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
                //anchors.leftMargin: 10
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            //color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - createPage_headerBar.height

            Image {
                id: previewImage
                //source: "../images/placeholder.png"
                source: fileLocation
                width: 300*app.scaleFactor
                height: width
                anchors.margins: 20*app.scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            CustomButton{
                id:page2_button1
                buttonText: qsTr("TAKE A PHOTO")
                buttonColor: app.buttonColor
                buttonWidth: 300 * app.scaleFactor
                buttonHeight: buttonWidth/5
                anchors {
                    left: parent.left
                    right: parent.right
                    top: previewImage.bottom
                    topMargin: 20*app.scaleFactor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Camera clicked");
                        cameraWindow.visible = true
                    }
                }
            }

            CustomButton{
                id:page2_button2
                buttonText: qsTr("SELECT PHOTO")
                buttonColor: app.buttonColor
                buttonWidth: 300 * app.scaleFactor
                buttonHeight: buttonWidth/5
                anchors {
                    left: parent.left
                    right: parent.right
                    top: page2_button1.bottom
                    topMargin: 20*app.scaleFactor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Select photo clicked");
                        imagePicker.visible = true
                    }
                }
            }
        }
    }
}
