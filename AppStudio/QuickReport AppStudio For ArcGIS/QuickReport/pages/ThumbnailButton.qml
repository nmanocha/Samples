import QtQuick 2.3
import QtQuick.Controls 1.2

//property String source :""
Item {
    id: thumbnailButton
    property int btnIndx

    property string details:""
    property url src: ""
//    width: parent.width * 0.085
//    height: width * 0.65
    anchors.verticalCenter: parent.verticalCenter


    Rectangle{

        id: thumbnailArea
        anchors.fill: parent
        border.color: "transparent"
        border.width: 1

        states: [
            State {
                name: "selected"
                PropertyChanges { target: thumbnailArea; border.color: "blue" }
            },

            State {
                name: "unselected"
                PropertyChanges { target: thumbnailArea; border.color: "transparent" }
            }
        ]



        Image {
            id:img
            anchors.fill: parent
            anchors.margins: 5
            source: thumbnailButton.src
            fillMode: Image.PreserveAspectCrop

            Component.onCompleted:{
                console.log("src: " + thumbnailButton.src);
            }
        }

    }


    // Click operation to load the selected image to ImageObject.
    // Plus show as selected.
    MouseArea{
        anchors.fill: parent
        onClicked:{ imageObject.load(thumbnailButton.src,"*")
            //imageDetails.text = thumbnailButton.details

            rectContainer.currentIndex = thumbnailButton.btnIndx

            console.log("Current index after selection ",rectContainer.currentIndex )

            //thumbnailArea.state = 'selected'
           // thumbnailArea.border.color = "blue"
            //console.log(thumbnailButton.details)
        }
    }
}


