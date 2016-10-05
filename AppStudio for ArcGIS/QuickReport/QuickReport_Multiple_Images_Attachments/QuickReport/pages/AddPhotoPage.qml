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

import "../controls"

Rectangle {
    id: rectContainer
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    state: app.isPortrait ? "" : "landscape"

    signal next(string message)
    signal previous(string message)

    property string fileLocation: "../images/placeholder.png"
    property bool photoReady: false
    property int captureResolution: 800

    property real lat:0
    property real lon:0  

    readonly property int halfScreenWidth: (width * 0.5) * app.scaleFactor

    property int maxbuttonlistItems: app.maximumAttachments



    ExifInfo {
        id: page2_exifInfo
    }

    ImageObject {
        id: imageObject
    }

    function resizeImage(path) {
        console.log("Inside Resize Image: ", path)

        if (!captureResolution) {
            console.log("No image resize:", captureResolution);
            return;
        }

        var fileInfo = AppFramework.fileInfo(path);
        if (!fileInfo.exists) {
            console.error("Image not found:", path);
            return;
        }

        if (!(fileInfo.permissions & FileInfo.WriteUser)) {
            console.log("File is read-only. Setting write permission:", path);
            fileInfo.permissions = fileInfo.permissions | FileInfo.WriteUser;
        }

        if (!imageObject.load(path)) {
            console.error("Unable to load image:", path);
            return;
        }

        if (imageObject.width <= captureResolution) {
            console.log("No resize required:", imageObject.width, "<=", captureResolution);
            return;
        }

        console.log("Rescaling image:", imageObject.width, "x", imageObject.height, "size:", fileInfo.size);

        imageObject.scaleToWidth(captureResolution);

        if (!imageObject.save(path)) {
            console.error("Unable to save image:", path);
            return;
        }

        fileInfo.refresh();
        console.log("Scaled image:", imageObject.width, "x", imageObject.height, "size:", fileInfo.size);
    }


    CameraWindow {
        id: cameraWindow
        title: "Camera"

        onSelect: {

            //------ RESIZE IMAGE -----
            var path = AppFramework.resolvedPath(fileName)
            resizeImage(path)
            //------ RESIZE IMAGE -----

            //fileLocation = "file:///" + fileName
            app.selectedImageFilePath_ORIG = fileName
            app.selectedImageFilePath = "file:///" + fileName

            appModel.append(
                        {path: app.selectedImageFilePath.toString()}
                        )

            appFolder.writeTextFile("Camera_"+new Date().toDateString(), fileName)

            photoReady = true

            page2_exifInfo.url = app.selectedImageFilePath;
            console.log("Camera Exif FileInfo: ", page2_exifInfo.filePath, page2_exifInfo.exists, page2_exifInfo.size);

            debugText.text += "<br>" + page2_exifInfo.filePath + "<br>Exists: " + page2_exifInfo.exists + " | Size: " + page2_exifInfo.size;

            theNewPoint = ArcGISRuntime.createObject("Point");
            theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});

            if(page2_exifInfo.gpsLongitude && page2_exifInfo.gpsLatitude) {
                app.selectedImageHasGeolocation = true
                geoLocationText.text = "Lat: " + (page2_exifInfo.gpsLatitude).toFixed(4) + " Long: " + (page2_exifInfo.gpsLongitude).toFixed(4)
                lat = page2_exifInfo.gpsLatitude
                lon = page2_exifInfo.gpsLongitude

                theNewPoint.x = lon;
                theNewPoint.y = lat;
            } else {
                app.selectedImageHasGeolocation = false;
                theNewPoint.x = 0;
                theNewPoint.y = 0;
            }

            console.log("AddPhotoPage: New Point: ", JSON.stringify(theNewPoint.json));



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
                    appModel.clear()
                }
            }

            Text {
                id: createPage_titleText
                text: qsTr("Add Photo")
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

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: "transparent"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - createPage_headerBar.height

            Flickable {
                id: flickableContent
                width: parent.width
                height: parent.height
                contentHeight:  parent.height + 30
                interactive: cameraWindow.isPortrait
                clip: true
                
                
                
                Rectangle{
                    id:headingRect
                    color: "transparent"
                    width: parent.width
                    height: parent.height /10
                    anchors.topMargin: 15* app.scaleFactor
                    anchors.bottomMargin: 10* app.scaleFactor
                    
                    Text{
                        text: qsTr("Add upto " +  app.maximumAttachments + " photos." + " Images higher <br> than 800 pixels will get resized.")
                        font {
                            pointSize: app.baseFontSize * 0.60
                        }
                        visible: app.maximumAttachments > 1
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                
                Rectangle{
                    id:contentRect
                    anchors.top:headingRect.bottom
                    color: "transparent"
                    width: parent.width
                    height: parent.height /2
                    anchors.topMargin: 10

                    clip:true
                    
                    GridView {
                        id:grid
                        anchors.fill: parent
                        cellWidth: 160* app.scaleFactor; cellHeight: 140* app.scaleFactor
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter:  parent.verticalCenter
                        focus: true
                        model: appModel

                        // highlight: Rectangle { width: 80; height: 80; color: "lightsteelblue" }

                        delegate: Item {
                            width: 160* app.scaleFactor; height: 140* app.scaleFactor


                            Image {
                                id: myIcon
                                y: 20; anchors.horizontalCenter: parent.horizontalCenter
                                source: path
                                width: 140* app.scaleFactor
                                height: 120* app.scaleFactor
                                anchors.left: parent.left
                                 anchors.margins: 15 * app.scaleFactor

                                Rectangle {
                                    id:closeRect
                                    anchors.right: myIcon.right                                    
                                    color: "white"
                                    //opacity: .75
                                    radius: 10 * scaleFactor
                                    border.color: "red"
                                    width: 20 * app.scaleFactor
                                    height: 20 * app.scaleFactor
                                    Text{
                                        anchors.horizontalCenter: parent.horizontalCenter
                                         anchors.verticalCenter:  parent.verticalCenter
                                         color: "black"

                                        text: "X"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked:appModel.remove(index)                                        
                                    }
                                }
                            }


                            Text {
                                anchors { top: myIcon.bottom; horizontalCenter: parent.horizontalCenter }
                               // text: name
                            }
                            //                            MouseArea {
                            //                                anchors.fill: parent
                            //                                onClicked: {
                            //                                    parent.GridView.view.currentIndex = index
                            //                                    mouse.accepted = false
                            //                                }
                            //                            }
                        }
                    }

                    
                }

                Image {
                    id: previewImage
                    fillMode: Image.PreserveAspectFit
                    visible: appModel.count <1
                    source: fileLocation
                    width: 300*app.scaleFactor
                    height: width*0.6



                    anchors {
                        margins: 70*app.scaleFactor
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        anchors.fill: parent
                        border.color: "#ccc"
                        border.width: 1
                        color: "transparent"

                    }


                    Rectangle {
                        width: parent.width
                        height: 30*app.scaleFactor
                        anchors.left: parent.left
                        anchors.top: parent.top
                        visible: app.selectedImageHasGeolocation
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#77000000";}
                            GradientStop { position: 1.0; color: "#22000000";}
                        }


                    }



                }
                
                PictureChooser {
                    id: pictureChooser
                    
                    copyToOutputFolder: true
                    
                    outputFolder {
                        path: "~/ArcGIS/AppStudio/Data"
                    }
                    
                    Component.onCompleted: {
                        outputFolder.makeFolder();
                    }
                    
                    
                    
                    onAccepted: {

                        console.log(pictureUrl)
                        photoReady = true;

                        //------ RESIZE IMAGE -----
                        var path = AppFramework.resolvedPath(pictureUrl)
                        resizeImage(path)
                        //------ RESIZE IMAGE -----

                       var filePath = "file:///" + path

                        appModel.append(
                                    {path: filePath.toString()}
                                    )

                        app.selectedImageFilePath = pictureUrl;
                        //fileLocation = pictureUrl;
                        page2_exifInfo.url = pictureUrl

                        //console.log("Exif FileInfo: ", page2_exifInfo.size, page2_exifInfo.gpsLatitude, page2_exifInfo.gpsLongitude, page2_exifInfo.created, page2_exifInfo.imageTags);

                        if(page2_exifInfo.gpsLongitude && page2_exifInfo.gpsLatitude) {
                            geoLocationText.visible = true
                            geoLocationText.text = "Lat: " + (page2_exifInfo.gpsLatitude).toFixed(4) + " Lon: " + (page2_exifInfo.gpsLongitude).toFixed(4)
                            lat = page2_exifInfo.gpsLatitude
                            lon = page2_exifInfo.gpsLongitude
                            app.selectedImageHasGeolocation = true
                            app.theNewPoint = ArcGISRuntime.createObject("Point");
                            app.theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});
                            app.theNewPoint.setXY(page2_exifInfo.gpsLongitude,page2_exifInfo.gpsLatitude);
                        } else {
                            app.selectedImageHasGeolocation = false;
                        }
                        

                        
                    }
                }
                
                Column {
                    id: buttonsColumn
                    spacing: 5
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentRect.bottom
                        //topMargin: 20*app.scaleFactor
                        margins: 20 * app.scaleFactor
                    }
                    CustomButton{
                        id:page2_button1
                        buttonText: qsTr("Camera")
                        opacity: photoReady? 0.8: 1
                        buttonColor: app.buttonColor
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/6
                        buttonFill:  true
                        visible: appModel.count  < maxbuttonlistItems
                        
                        anchors.horizontalCenter: parent.horizontalCenter
                        
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
                        
                        //enabled: deviceOS != "ios"
                        visible: appModel.count  <  maxbuttonlistItems
                        
                        buttonText: qsTr("Photo Picker")
                        buttonColor: app.buttonColor
                        buttonWidth: 300 * app.scaleFactor
                        opacity: photoReady? 0.8: 1
                        buttonHeight: buttonWidth/6
                        buttonFill:  true
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("total model count before adding next ",appModel.count)
                                console.log("Select photo clicked");
                                pictureChooser.open();
                                
                                //imagePicker.visible = true
                            }
                        }
                    }
                    
                    CustomButton{
                        id: skipButton
                        buttonText: qsTr("SKIP")
                        buttonColor: app.buttonColor
                        buttonFill: false
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/6
                        visible: app.allowPhotoToSkip && appModel.count < 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Skip button clicked");
                                app.hasAttachment = false;
                                skipPressed = true;
                                next("refinelocation")
                            }
                        }
                    }
                    Rectangle {
                        height: 5
                        width: page2_button3.buttonWidth
                        visible: photoReady
                        color: "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
//                    Rectangle {
//                        id: page2_seperator
//                        visible: photoReady
//                        height: 2*app.scaleFactor
//                        width: page2_button3.buttonWidth
//                        color: app.buttonColor
//                        opacity: 0.5
//                        anchors.horizontalCenter: parent.horizontalCenter
//                    }
                    Rectangle {
                        height: 5
                        width: page2_button3.buttonWidth
                        visible: photoReady
                        color: "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    CustomButton{
                        id:page2_button3
                        buttonText: qsTr("Next: %1 LOCATION").arg(app.selectedImageHasGeolocation ? qsTr("REFINE") : qsTr("ADD"))
                        visible: !skipButton.visible
                        buttonColor: app.buttonColor
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/5
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next("refinelocation");
                                console.log("skipped?", skipPressed)
                            }
                        }
                    }
                }
            }
        }

    }

    states:[
        State {
            name: "landscape"

            PropertyChanges {
                target: rectContainer
            }

//            PropertyChanges {
//                target: flickableContent
//                contentHeight: parent.height
//            }



            PropertyChanges {
                target: buttonsColumn
                anchors.margins: 20 * app.scaleFactor
            }
//            AnchorChanges {
//                target: buttonsColumn
//                anchors {
//                    top: undefined
//                    verticalCenter: parent.verticalCenter
//                    left: parent.horizontalCenter
//                }
//            }

//                        AnchorChanges {
//                            target: previewImage
//                            anchors {
//                                top: undefined
//                                verticalCenter: parent.verticalCenter
//                                horizontalCenter: undefined
//                                right: parent.horizontalCenter
//                                //left: parent.left
//                            }
//                        }

            PropertyChanges {
                target: page2_button1
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }

            PropertyChanges {
                target: page2_button2
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }
            PropertyChanges {
                target: skipButton
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }

            PropertyChanges {
                target: page2_button3
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }
        }
    ]

    // Component.onCompleted: console.log(previewImage.width, previewImage.height)

}
