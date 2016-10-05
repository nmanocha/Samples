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
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "./styles"

Dialog {

    title: busy ? qsTr("Signing In") : qsTr("Sign In")

    onVisibleChanged: {
        if (!app.featureServiceInfoComplete){
            alertBox.actionRequest = alertBox.actionMode[1];
            alertBox.visible = true;
        }
    }

    property alias usernameLabel: usernameText.text
    property alias username: usernameField.text
    property alias passwordLabel: passwordText.text
    property alias password: passwordField.text
    property bool busy: false
    property string message : ""
    property alias acceptLabel : acceptButton.text
    property alias rejectLabel : rejectButton.text

    //property Settings settings
    property string settingsGroup: "Portal"
    property alias bannerImage: image.source
    property alias bannerColor: banner.color

    contentItem: Rectangle {
        implicitWidth: app.width
        implicitHeight: Math.min(300 * AppFramework.displayScaleFactor, Screen.desktopAvailableHeight * 0.95)

        color: "white"

        Rectangle {
            id: banner

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: titleText.paintedHeight + 20
            color: "#0079C1"

            Image {
                id: image

                anchors.fill: parent

                height: titleText.paintedHeight + 20
                fillMode: Image.PreserveAspectCrop
                visible: source > ""
            }

            Text {
                id: titleText

                anchors {
                    fill: parent
                    leftMargin: 10
                }
                text: qsTr("Sign In")
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                font {
                    pointSize: 14
                    bold: true
                }
            }
        }

        FocusScope {
            id: inputArea

            anchors {
                top: banner.bottom
                topMargin: 30
                left: parent.left
                leftMargin: 20
                right: parent.right
                rightMargin: 20
                bottom: parent.bottom
                bottomMargin: 20
            }

            ColumnLayout {
                anchors {
                    fill: parent
                }

                spacing: 5

                Text {
                    id: usernameText

                    Layout.fillWidth: true

                    text: qsTr("Username")
                    horizontalAlignment: Text.AlignLeft
                    font {
                        pointSize: 14
                        bold: true
                    }
                }

                TextField {
                    id: usernameField

                    Layout.fillWidth: true

                    placeholderText: usernameLabel
                    font {
                        pointSize: 16
                    }

                    style: EditControlStyle{
                        rectHeight: Text.paintedHeight + 10 * app.scaleFactor
                        renderType: Text.QtRendering

                    }

                    activeFocusOnTab: true
                    focus: true
                    inputMethodHints: Qt.ImhNoAutoUppercase + Qt.ImhNoPredictiveText + Qt.ImhSensitiveData

                    onAccepted: {
                        acceptButton.tryClick();
                    }
                }

                Text {
                    id: passwordText

                    Layout.fillWidth: true

                    text: qsTr("Password")
                    horizontalAlignment: Text.AlignLeft
                    font: usernameText.font
                }

                TextField {
                    id: passwordField

                    Layout.fillWidth: true

                    echoMode: TextInput.Password
                    placeholderText: passwordLabel
                    font: usernameField.font
                    style: usernameField.style
                    activeFocusOnTab: true

                    onAccepted: {
                        acceptButton.tryClick();
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Text {
                    id: messageText

                    Layout.fillWidth: true

                    text: message
                    wrapMode: Text.Wrap

                    color: "red"
                    font {
                        pointSize: 14
                        italic: true
                        bold: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        id: acceptButton

                        text: busy ? qsTr("Signing in") : qsTr("Sign in")
                        isDefault: true
                        enabled: !busy && username.trim().length > 0 && password.trim().length > 0
                        onClicked: {
                            tryClick();
                        }

                        function tryClick() {
                            if (!enabled) {
                                return;
                            }

                            busy = true;
                            message = "";

                            app.userName = username.trim();
                            app.password = password.trim();

                            serviceInfoTask.fetchFeatureServiceInfo();
                        }

                        style: ButtonStyle {
                            padding {
                                left: 10 * AppFramework.displayScaleFactor
                                right: 10 * AppFramework.displayScaleFactor
                            }

                            label: Text {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: control.enabled ? (control.isDefault ? "white" : "dimgray") : "gray"
                                text: control.text
                                font {
                                    pointSize: 14
                                    //capitalization: Font.AllUppercase
                                }
                            }

                            background: Rectangle {
                                color: (control.hovered | control.pressed) ? (control.isDefault ? "#e36b00" : "darkgray") : (control.isDefault ? "#e98d32" : "lightgray")
                                border {
                                    color: control.activeFocus ? (control.isDefault ? "#e36b00" : "darkgray") : "transparent"
                                    width: control.activeFocus ? 2 : 1
                                }
                                radius: 4
                                //implicitWidth: 150
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 1
                    }

                    Button {
                        id: rejectButton

                        text: qsTr("Cancel")
                        enabled: !busy
                        onClicked: {
                            close();
                            rejected();
                            alertBox.visible = true;
                            alertBox.buttonText = qsTr("Sign in");
                            alertBox.actionRequest = alertBox.actionMode[1];
                        }
                        style: acceptButton.style
                    }
                }
            }
        }

        BusyIndicator {
            id: busyIndicator
            running: busy
            anchors.centerIn: parent
        }
    }
}
