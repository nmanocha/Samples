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
    id:page1Container
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    //color: "transparent"
    signal next(string message)
    signal previous(string message)

    Image{
        //anchors.fill: parent
        anchors.top: parent.top
        width: parent.width
        //height: parent.height - linksContainer.height
        height: parent.height
        //anchors.bottom: linksContainer.top
        source: app.landingpageBackground
        fillMode: Image.PreserveAspectCrop
        //z:-1
        visible: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: page1_headerBar
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
                visible: false
                onClicked: {
                    console.log("Back button from map page clicked")
                    previous("")
                }
            }

            Text {
                id: page1_titleText
                text: app.info.title
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
            color: "transparent"
            //color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - page1_headerBar.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height
                contentHeight: parent.height + 30

                clip: true

                Item {
                    anchors.fill: parent

                    anchors.topMargin: page1_headerBar.height + 10;

                    Text {
                        id: page1_description
                        text: app.info.snippet
                        textFormat: Text.StyledText
                        horizontalAlignment: Text.AlignHCenter
                        anchors {
                            margins: 10*app.scaleFactor
                            left: parent.left
                            right: parent.right
                        }
                        font {
                            pointSize: app.baseFontSize * 0.9
                        }

                        color: app.textColor
                        wrapMode: Text.Wrap
                        linkColor: app.headerBackgroundColor
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                    }

                    Text {
                        id: page1_networkStatus
                        text:"(" + (AppFramework.network.isOnline?qsTr("Online"):qsTr("Offline")) + ")"
                        textFormat: Text.StyledText
                        horizontalAlignment: Text.AlignHCenter
                        anchors {
                            margins: 10
                            left: parent.left
                            right: parent.right
                            top: page1_description.bottom
                        }
                        font {
                            pointSize: app.baseFontSize * 0.6
                        }
                        color: app.textColor
                        opacity: 0.8
                    }

                    CustomButton{
                        id:page1_button1
                        buttonText: qsTr("New Report")
                        buttonColor: app.buttonColor
                        buttonTextColor: AppFramework.network.isOnline ? "#ffffff" : "#A6A8AB"
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/5
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: page1_networkStatus.bottom
                            topMargin: 40*app.scaleFactor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                skipPressed = false;
                                //console.log("attacmentURL:", app.theFeatureAttachment.url )
                                next("createnew");
                            }
                        }

                        enabled: AppFramework.network.isOnline
                    }

                    GridView {
                        visible: false
                        width: parent.width; height: 240
                        cellWidth: 150; cellHeight: 120
                        clip:true
                        anchors.top: page1_button1.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: ListModel {
                            ListElement {
                                name: "Email Us"
                                icon: "../images/camera_icon.png"
                            }
                            ListElement {
                                name: "Call Us"
                                icon: "../images/camera_icon.png"
                            }
                            ListElement {
                                name: "View Results"
                                icon: "../images/camera_icon.png"
                            }
                            ListElement {
                                name: "Follow Us"
                                icon: "../images/camera_icon.png"
                            }
                        }
                        delegate: Column {
                            Image { source: icon; width:80; height:80; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: name; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                    }
                }
            }
        }

        Rectangle {
            id: linksContainer
            //height: 40 * app.scaleFactor
            height: links.contentHeight + 10*app.scaleFactor
            width: Math.min(400*app.scaleFactor,parent.width)
            color: app.pageBackgroundColor
            visible: links.text > ""
            anchors {
                bottom: parent.bottom
                //left: parent.left
                //right: parent.right
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: links
                text: ""
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 8*app.scaleFactor
                fontSizeMode: Text.HorizontalFit
                maximumLineCount: 1
                //elide: Text.ElideNone
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                color: app.textColor
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }

                Component.onCompleted: {
                    var str = [];
                    if(app.phoneNumber.length>1)
                        str.push("<a href='tel:" + app.phoneNumber +"'>" + app.phoneLabel + "</a>");
                    if(app.websiteUrl.length>1)
                        str.push("<a href='" + app.websiteUrl +"'>" + app.websiteLabel + "</a>");
                    if(app.emailAddress.length>1)
                        str.push("<a href='mailto:" + app.emailAddress +"'>" + app.emailLabel + "</a>");
                    if(app.socialMediaUrl.length>1)
                        str.push("<a href='" + app.socialMediaUrl +"'>" + app.socialMediaLabel + "</a>");

                    //text = str.join(" | ");

                }
            }
        }

    }

}

