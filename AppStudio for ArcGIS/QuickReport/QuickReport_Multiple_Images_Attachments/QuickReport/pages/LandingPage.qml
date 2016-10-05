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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "../controls"

Image {
    signal signInClicked()

    source: app.folder.fileUrl(app.info.propertyValue("startBackground", "assets/startBackground.png"))
    fillMode: Image.PreserveAspectCrop

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 * app.scaleFactor

        Image {
            id: appLogoImage
            fillMode: Image.PreserveAspectFit
            source: app.folder.fileUrl(app.info.propertyValue("logoImage", "template/images/esrilogo.png"))
            Layout.preferredWidth: 140* app.scaleFactor
            Layout.preferredHeight: 100 * app.scaleFactor
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(app.logoUrl && app.logoUrl.length > 1) {
                        Qt.openUrlExternally(unescape(app.logoUrl))
                    }
                }
            }
        }

        Text {
            id: titleText

            text: app.info.title
            fontSizeMode: Text.HorizontalFit

            font {
                pointSize: app.baseFontSize * app.titleFontScale
            }
            color: app.titleColor
            horizontalAlignment: Text.AlignHCenter

            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Image {
                id: testimage
                source: app.loginImage
                visible: false
            }

            ImageButton {
                id: signInButton
                anchors.centerIn: parent
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"

                enabled: AppFramework.network.isOnline
                visible: featureServiceInfoComplete

                width: Math.min(testimage.sourceSize.width, 250) * app.scaleFactor
                height: Math.min(testimage.sourceSize.height, 125) * app.scaleFactor

                source: app.folder.fileUrl(app.info.propertyValue("signInImage", "../images/signin.png"))

                onClicked: {
                    signInClicked();
                }
            }
            BusyIndicator {
                id: busyIndicator
                running: !featureServiceInfoComplete && !featureServiceInfoErrored
                visible: running
                anchors.centerIn: parent
            }
        }

        Text {
            id: subtitleText

            text: app.info.snippet
            font {
                pointSize: app.baseFontSize * app.subTitleFontScale
            }
            color: app.subtitleColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.Wrap

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

        }
    }

    AlertBox {
        id: alertBox
        visible: !AppFramework.network.isOnline
        text: qsTr("Network not available. Turn off airplane mode or use wifi to access data.")
        buttonVisible: !visible
    }

    ImageButton {

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10*app.scaleFactor
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        height: 30 * app.scaleFactor
        width: 30 * app.scaleFactor

        source: "../images/info.png"

        visible: app.showDescriptionOnStartup

        onClicked: {
            var html = app.info.description;
            var accessString = qsTr("Access Information:");
            if(app.info.accessInformation) {
                html+= "<br><br><b>" + accessString + "</b><br>" + app.info.accessInformation
            }


            var aboutString = qsTr("About the App:")
            var aboutDescriptionString = qsTr("This app was built using the new AppStudio for ArcGIS. Mapping API provided by Esri.");
            html+= "<br><br><b>" + aboutString + "</b><br>" + aboutDescriptionString;

            html+= "<br><br><b>" + qsTr("Version:") + "</b><br>" + app.info.version;
            aboutModalWindow.description = html
            aboutModalWindow.visible = true
        }
    }

    ModalWindow {
        id: aboutModalWindow
        title: qsTr("About")
    }

    MessageDialog {
        id: aboutDialog
    }
}
