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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import QtPositioning 5.3


import "controls"
import "customRuntime"
import "pages"

App {
    id: app
    width: 320
    height: 450

    property int scaleFactor : AppFramework.displayScaleFactor
    property int baseFontSize: app.info.propertyValue("baseFontSize", 20)
    property double titleFontScale: app.info.propertyValue("titleFontScale", 1.9)
    property double subTitleFontScale: app.info.propertyValue("subTitleFontScale", 0.7)

    property bool isSmallScreen: false
    property bool isPortrait: app.height > app.width //false

    onIsPortraitChanged: console.log ("isPortrait", isPortrait)
    property bool featureServiceInfoComplete : false
    property bool featureServiceInfoErrored : false

    property bool isOnline: AppFramework.network.isOnline

    onIsOnlineChanged: {
        if (isOnline && featureServiceInfoErrored){
            serviceInfoTask.fetchFeatureServiceInfo()
            featureServiceInfoErrored = false
        }
    }


    property string deviceOS: Qt.platform.os

    /* *********** CONFIG ********************* */
    property string arcGISLicenseString: app.info.propertyValue("ArcGISLicenseString","");
    //property string landingpageBackground : app.info.propertyValue("startBackground","assets/background.png");
    property string landingpageBackground : app.folder.fileUrl(app.info.propertyValue("startBackground","../images/background2.jpg"));
    property string logoImage :  app.folder.fileUrl(app.info.propertyValue("logoImage","../images/esrilogo.png"));
    property string logoUrl : app.info.propertyValue("logoUrl","http://www.esri.com");
    property bool showDescriptionOnStartup : app.info.propertyValue("showDescriptionOnStartup",false);
    property bool startShowLogo : app.info.propertyValue("startShowLogo",true);
    property string loginImage : app.info.propertyValue("startButton","../images/signin.png");
    property string pickListCaption: app.info.propertyValue("pickListCaption", "Pick a type");

    //colors
    property color headerBackgroundColor: app.info.propertyValue("headerBackgroundColor","#165F8C");
    property color headerTextColor: app.info.propertyValue("headerTextColor","#FFF");
    property color pageBackgroundColor: app.info.propertyValue("pageBackgroundColor","#EBEBEB");
    property color buttonColor: app.info.propertyValue("buttonColor","orange");
    property string textColor : app.info.propertyValue("textColor","white");
    property color titleColor: app.info.propertyValue("titleColor","black");
    property color subtitleColor: app.info.propertyValue("subtitleColor","#51010a");

    //layers
    property string featureServiceURL : app.info.propertyValue("featureServiceURL","");
    property string featureLayerId : app.info.propertyValue("featureLayerId","");
    property string featureLayerName : app.info.propertyValue("featureLayerName","");
    property string featureLayerURL: featureServiceURL + "/" + featureLayerId;
    property string baseMapURL : app.info.propertyValue("baseMapServiceURL","");
    property bool allowPhotoToSkip : app.info.propertyValue("allowPhotoToSkip",true);

    //feedback
    property string websiteUrl : app.info.propertyValue("websiteUrl","www.arcgis.com");
    property string websiteLabel: app.info.propertyValue("websiteLabel", "Go to website");
    property string phoneNumber : app.info.propertyValue("phoneNumber","");
    property string phoneLabel: app.info.propertyValue("phoneLabel", "Call us");
    property string emailAddress : app.info.propertyValue("emailAddress","");
    property string emailLabel: app.info.propertyValue("emailLabel", "Email us");
    property string socialMediaUrl : app.info.propertyValue("socialMediaUrl","");
    property string socialMediaLabel : app.info.propertyValue("socialMediaLabel","Follow us");

    //Attributes
    property var attributesArray

    //Security
    property string userName: app.info.propertyValue("username","")
    property string password: app.info.propertyValue("password","")
    property string signInType: app.info.propertyValue("signInType", "none")

    /* *********** DOMAINS AND SUBTYPES ********************* */

    property variant domainValueArray: []
    property variant domainCodeArray: []

    property variant subTypeCodeArray: []
    property variant subTypeValueArray: []

    property variant domainRangeArray: []
    property variant delegateTypeArray:[]

    property var protoTypesArray: []
    property var protoTypesCodeArray: []

    property variant networkDomainsInfo

    property bool hasSubtypes: false
    property bool hasSubTypeDomain: false

    property var featureTypes
    property var featureType

    property var selectedFeatureType
    property var fields
    property var fieldsMassaged:[]

    property int pickListIndex: 0

    //-------------------- Setup for the App ----------------------

    property string selectedImageFilePath: ""
    property string selectedImageFilePath_ORIG: ""
    property bool selectedImageHasGeolocation: false
    property var currentAddedFeatures : []

    property string featureServiceStatusString: "Working on it ..."
    property bool hasAttachment: false

    property var theFeatureToBeInsertedID: null
    property var theFeatureSucessfullyInsertedID: null
    property bool theFeatureEditingAllDone: false
    property bool theFeatureEditingSuccess: false
    property int theFeatureServiceWKID: -1
    property SpatialReference theFeatureServiceSpatialReference

    property string reportSubmitMsg: qsTr("Submitting the report")
    property string reportSuccessMsg: qsTr("New report was added.")
    property string errorMsg: qsTr("Sorry there was an error!")
    property string photoSizeMsg: qsTr("Photo size is:")
    property string photoAddMsg: qsTr("Adding photo to report:")
    property string photoSuccessMsg: qsTr("Photo added successfully.")
    property string photoFailureMsg: qsTr("Sorry could not add photo!")
    property string doneMsg: qsTr("Click Done to continue.")

    property bool skipPressed: false

    property Point theNewPoint

    property int maximumAttachments: 5

    property int totalAttachments:0

    property var pendingAttachments:[]

    property var newId

    property alias appModel:fileListModel


    ListModel{
        id: fileListModel

//        ListElement {
//            // name: "Jim Williams"
//            path: "file:///C:/Users/naku5998/Pictures/Qtcreator.jpg"
//        }
//        ListElement {
//            // name: "John Brown"
//            path: "file:///C:/Users/naku5998/Pictures/security.jpg"
//        }
//        ListElement {
//            // name: "Bill Smyth"
//            path: "file:///C:/Users/naku5998/Pictures/geodesic.jpg"
//        }
//        ListElement {
//            //name: "Sam Wise"
//            path: "file:///C:/Users/naku5998/Pictures/WM_error.jpg"
//        }

//        ListElement {
//            //name: "Sam Wise"
//            path: "file:///C:/Users/naku5998/Pictures/WM_error.jpg"
//        }
    }


    PositionSource {
        id: posSource
        updateInterval: 1000
        active: true
        onPositionChanged: console.log("position", position.coordinate.longitude, position.coordinate.latitude)
    }

    Graphic {
        id: selectedGraphic
        geometry: Point {
            x: 0
            y: 0
            spatialReference: SpatialReference {
                wkid: 102100
            }
        }
    }
    property alias selectedGraphic: selectedGraphic

    Component.onCompleted: {
        ArcGISRuntime.license.setLicense(arcGISLicenseString);
        ArcGISRuntime.identityManager.ignoreSslErrors = true;

        attributesArray = {};
    }

    Connections {
        target: AppFramework.network
        onIsOnlineChanged: {
            isOnline = AppFramework.network.isOnline
        }
    }

//    GeodatabaseAttachment {
//        id: featureAttachment
//    }

   // property alias theFeatureAttachment: featureAttachment


    UserCredentials {
        id: userCredentials
        userName: app.userName
        password: app.password

        onError: console.log("Error in userCredentials:", error)
    }


    GeodatabaseFeatureServiceTable2 {
        id: theFeatureServiceTable

        url: app.featureLayerURL

        onApplyFeatureEditsStatusChanged: {
            if (applyFeatureEditsStatus === Enums.ApplyEditsStatusCompleted) {
                console.log("Apply Feature Edits Complete", skipPressed);
                app.featureServiceStatusString += "<br>" + reportSuccessMsg

                newId = lookupObjectId(app.theFeatureToBeInsertedID);
                console.log("Old and New: ", app.theFeatureToBeInsertedID, newId)
                app.theFeatureSucessfullyInsertedID = newId;

                console.log("now looking for attachment...", skipPressed)

                // Single attachment.
                //addAttachments(newId);

                // Multiple attachments.
                addMultipleAttachments(newId)

                skipPressed = false;

            }
            else if (applyFeatureEditsStatus === Enums.ApplyEditsStatusErrored) {
                console.log("applyFeatureEditsErrors: " + applyFeatureEditsErrors.length);
                app.featureServiceStatusString = errorMsg
                app.theFeatureEditingAllDone = true
                app.theFeatureEditingSuccess = false
            }
        }

        function addMultipleAttachments(newId){


            console.log("Model count",appModel.count)

            for(var j = 0; j < appModel.count; j++)
            {
                app.selectedImageFilePath_ORIG = appModel.get(j).path.replace("file:///","");
                app.selectedImageFilePath = appModel.get(j).path

                pendingAttachments.push({url:app.selectedImageFilePath,featureId: newId})
            }

            addAttachments();
        }

        function addAttachments(){

            var currentAttachmentInfo = pendingAttachments.pop();
            var fileUrl = currentAttachmentInfo.url;
           // var newId = currentAttachmentInfo.featureId;
            if ( app.hasAttachment && !skipPressed ) {



                app.featureServiceStatusString += "<br><br>" + photoAddMsg + newId;
                //console.log("************", app.featureServiceStatusString);
                console.log("Attaching file: ", fileUrl);

                var content_type = "application/octet-stream";
                if(app.selectedImageFilePath.toLowerCase().indexOf(".jpg") > -1 || app.selectedImageFilePath.toLowerCase().indexOf(".jpeg") > -1) {
                    content_type = "image/jpeg"
                }
                if(app.selectedImageFilePath.toLowerCase().indexOf(".png") > -1) {
                    content_type = "image/png"
                }
                if(app.selectedImageFilePath.toLowerCase().indexOf(".gif") > -1) {
                    content_type = "image/gif"
                }

                if(app.selectedImageFilePath.toLowerCase().indexOf(".mpeg") > -1) {
                    content_type = "video/mpeg"
                }
                if(app.selectedImageFilePath.toLowerCase().indexOf(".mov") > -1) {
                    content_type = "video/quicktime"
                }


//                console.log("Content-type: ", content_type, app.selectedImageFilePath);

//                if (app.theFeatureAttachment.loadFromFile(app.selectedImageFilePath, content_type)) {
//                    app.featureServiceStatusString += "<br> " + photoSizeMsg + Math.round(app.theFeatureAttachment.size/1024) + " KB" ;
//                    console.log("AddPhotoPage:: added the gdbAttachment", app.theFeatureAttachment.size);
//                    app.theFeatureServiceTable.addAttachment(app.theFeatureSucessfullyInsertedID, app.theFeatureAttachment);
//                }

                console.log("Content-type: ", content_type, fileUrl);

                var featureAttachment = ArcGISRuntime.createObject("GeodatabaseAttachment");

                if (featureAttachment.loadFromFile(fileUrl, content_type)) {
                    app.featureServiceStatusString += "<br> " + photoSizeMsg + Math.round(featureAttachment.size/1024) + " KB" ;
                    console.log("AddPhotoPage:: added the gdbAttachment", featureAttachment.size);
                    app.theFeatureServiceTable.addAttachment(app.theFeatureSucessfullyInsertedID, featureAttachment);

                }
            }
            else {
                app.featureServiceStatusString += "<br>" + doneMsg;
                console.log("should just be done...")
                app.theFeatureEditingAllDone = true;
                app.theFeatureEditingSuccess = true;
            }
        }

        onApplyAttachmentEditsStatusChanged: {
            if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusCompleted) {

                if(pendingAttachments.length > 0) {
                    console.log("Adding another attachment ....")
                    addAttachments()
                } else {
                    console.log("Apply Attachment Edits Complete");

                    app.featureServiceStatusString += "<br>" + photoSuccessMsg
                    app.theFeatureEditingAllDone = true
                    app.theFeatureEditingSuccess = true                   
                    appModel.clear()
                }

            }
            else if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusErrored) {
                console.log("applyAttachmentEditsErrors: " + applyAttachmentEditsErrors.length);
                app.featureServiceStatusString = "<br>" + photoFailureMsg

                if(pendingAttachments.length > 0) {
                    console.log("Adding another attachment ....")
                    addAttachments()
                } else{


                    //console.log("applyAttachmentEditsErrors: " + applyAttachmentEditsErrors.length);
                   // app.featureServiceStatusString = "<br>" + photoFailureMsg
                    app.theFeatureEditingAllDone = true
                    app.theFeatureEditingSuccess = false

                    appModel.clear()
                }
            }
        }

        onAddAttachmentStatusChanged: {
            if (addAttachmentStatus === Enums.AttachmentEditStatusCompleted)
                applyAttachmentEdits();
        }

    }

    property alias theFeatureServiceTable: theFeatureServiceTable

    Point {
        id: pointGeometry
        x: 200
        y: 200
    }

    ServerDialog {
        id: serverDialog

//        Connections {
//            target: acceptButton
//            onClicked:{
//                app.userName = username.trim();
//                app.password = password.trim();

//                serviceInfoTask.fetchFeatureServiceInfo();
//            }
//        }

    }

    ServiceInfoTask {
        id: serviceInfoTask
        url: featureServiceURL

        credentials: userCredentials

        onFeatureServiceInfoStatusChanged: {
            if(featureServiceInfoStatus == Enums.FeatureServiceInfoStatusCompleted) {
                console.log("connected to the feature service...", featureServiceInfo.spatialReference.wkid)
                //                app.theFeatureServiceWKID = featureServiceInfo.spatialReference.wkid;
                //                app.theFeatureServiceSpatialReference = featureServiceInfo.spatialReference;

                featureServiceInfoComplete = true;

                alertBox.visible = false
                serverDialog.close()

                app.theFeatureLayer.initialize();
            }
            else if ( featureServiceInfoStatus == Enums.FeatureServiceInfoStatusErrored ) {
                console.log("error message", serviceInfoTask.featureServiceInfoError.code, serviceInfoTask.featureServiceInfoError.message, serviceInfoTask.featureServiceInfoError.details);
                if (serviceInfoTask.featureServiceInfoStatus === Enums.FeatureServiceInfoStatusErrored){
                    featureServiceInfoErrored = true;
                    //console.log("error message", serviceInfoTask.featureServiceInfoError.message);
                    alertBox.text = serviceInfoTask.featureServiceInfoError.message //+ ", " + serviceInfoTask.featureServiceInfoError.code;

                    if (serviceInfoTask.featureServiceInfoError.message === "Unable to generate token.") {
                        alertBox.text = qsTr("The app was unable to generate a token. The app will have to quit.");
                        alertBox.actionRequest = alertBox.actionMode[0];
                        alertBox.buttonText = qsTr("OK");
                        alertBox.visible = true;
                    }
                    else {
                        if ( !isOnline ) {
                            alertBox.text = qsTr("Data not available. Turn off airplane mode or check data connection and retry.");
                            alertBox.actionRequest = alertBox.actionMode[1];
                            alertBox.buttonText = qsTr("WAITING...");
                            alertBox.visible = true;
                        }
                        else {
                            alertBox.buttonText = qsTr("Sign in");
                            alertBox.visible = true;
                        }
                    }

                    switch (serviceInfoTask.featureServiceInfoError.code) {
                    case 200:
                        alertBox.visible = false
                        serverDialog.open();
                        break;
                    case 401:
                    case 400:
                    case 403:
                        if (serverDialog.visible) {
                            alertBox.visible = false
                            serverDialog.message = "Username or password invalid";
                            serverDialog.busy = false;
                        }
                        else {
                            alertBox.visible = false
                            serverDialog.open();
                        }
                        break;
                    }
                }
            }
        }

        Component.onCompleted: {
            fetchFeatureServiceInfo();
        }
    }


    FeatureLayer {
        id: theFeatureLayer
        featureTable: theFeatureServiceTable.valid ? theFeatureServiceTable : null
        onStatusChanged: {
            console.log("thefeaturelayer", status)
            if(status == Enums.LayerStatusInitialized) {
                console.log("Feature layer complete");
                console.log("sr:", spatialReference.wkid);
                console.log("Editable: ", theFeatureServiceTable.isEditable, " | Has attachments: ", theFeatureServiceTable.hasAttachments);
                console.log("fields", theFeatureServiceTable.editableAttributeFields);

                fields = theFeatureServiceTable.editableAttributeFields;

                for (var f in fields) {
                    fieldsMassaged.push(fields[f]);
                }

                //                console.log(JSON.stringify(fields, undefined, 2))

                app.theFeatureServiceWKID = spatialReference.wkid;
                app.theFeatureServiceSpatialReference = spatialReference;

                //Checking for Subtype information

                if ( theFeatureServiceTable.typeIdField > ""){
                    console.log("This service has a sub Type::", theFeatureServiceTable.typeIdField);
                    hasSubtypes = true;
                    featureTypes = theFeatureServiceTable.featureTypes;
                }
                else {
                    console.log("This service DOES NOT have a sub Type::");
                }

                for ( var j = 0; j < fields.length; j++ ) {

                  console.log(fields[j].nullable)
                    var hasDomain = false;
                    var isRangeDomain = false;
                    if ( fields[j].domain !== null){
                        hasDomain = true;
                        if (fields[j].domain.objectType === "RangeDomain" ) {
                            isRangeDomain = true
                        }
                    }

                    var isSubTypeField = false;
                    if ( fields[j].name === theFeatureServiceTable.typeIdField ){
                        isSubTypeField = true;
                    }

                    //                    theFeatureAttributesModel.append({"fieldName": fields[j].name, "fieldAlias": fields[j].alias, "fieldType": fields[j].fieldTypeString, "fieldValue": "", "domainName":"", "domainType":""})
                    var defaultFieldValue = 0;
                    theFeatureAttributesModel.append({"fieldIndex": j, "fieldName": fields[j].name, "fieldAlias": fields[j].alias, "fieldType": fields[j].fieldTypeString, "fieldValue": "", "defaultNumber": defaultFieldValue, "isSubTypeField": isSubTypeField, "hasSubTypeDomain" : false, "hasDomain": hasDomain, "isRangeDomain": isRangeDomain, "isRequired": true })
                }

                app.hasAttachment = theFeatureServiceTable.hasAttachments;

                //read and set the types model
                //console.log("Renderer type: ", theFeatureLayer.renderer.rendererType);

                var rendererJson = theFeatureLayer.renderer.json;

                if(theFeatureLayer.renderer.rendererType === Enums.RendererTypeUniqueValue) {
                    //theFeatureTypesModel.clear();

                    var values = theFeatureLayer.renderer.uniqueValues;
                    //console.log("values json::", JSON.stringify(values, undefined, 2));

                    for(var i=0; i< values.length; i++) {
                        var url = "";
                        //if (values[i].type === 8){
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                            //console.log("image url::", url);
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                            ////console.log(AppFramework.resolvedPath(url));
                        }
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                            //                                console.log("image url::", url);
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                            ////console.log(AppFramework.resolvedPath(url));
                        }
                        //}

                        //console.log("Image URL: ", url);

                        //theFeatureTypesModel.append({"label": values[i].label, "value" : values[i].value, "description": values[i].description, "imageUrl": values[i].symbol.symbolImage(pointGeometry, "transparent").url})

                        theFeatureTypesModel.append({"label": values[i].label, "value" : values[i]["value"].toString(), "description": values[i].description, "imageUrl": url});
                        protoTypesArray.push(values[i].label);
                    }
                }

                //console.log("Feature service display field: ", theFeatureServiceTable.displayField);

                //console.log(app.emailAddress, app.phoneNumber, app.websiteUrl, app.socialMediaUrl);

                //console.log("Folder path: ", appFolder.path);

                //console.log("Types count: ", theFeatureTypesModel.count, " | Attributes count: ", theFeatureAttributesModel.count);

                //console.log("Featurelayer spatial ref: ", JSON.stringify(theFeatureLayer.fullExtent.json), theFeatureLayer.fullExtent.spatialReference.wkid);
            }

            if(status == Enums.LayerStatusErrored) {
                console.log("QuickReportApp:: Layer create error: ", error, error.message, error.details)
            }
        }
    }

    property alias theFeatureLayer: theFeatureLayer

    ListModel {
        id: theFeatureTypesModel
    }

    ListModel {
        id: theFeatureAttributesModel
    }

    VisualItemModel  {
        id: theFeatureAttributesVisualModel
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: appFolder
    }
    //--------------------------------

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: landingPage

        function showWelcomePage() {
            stackView.clear()
            push(welcomePage)
        }

        function showMapPage() {
            push(mapPage)
        }
        function showAddPhotoPage() {
            push(addPhotoPage)
        }
        function showRefineLocationPage(){
            push(refineLocationPage)
        }
        function showAddDetailsPage(){
            push(addDetailsPage)
        }
        function showResultsPage() {
            push(resultsPage)
        }
    }

    //--------------------------------

    Component {
        id: landingPage

        LandingPage {
            onSignInClicked: {
                app.isSmallScreen = (parent.width || parent.height) < 400*app.scaleFactor
                //                app.isPortait = parent.height > parent.width

                //console.log("##StartPage:: DisplayScaleFactor: ", scaleFactor, " isSmallScreen: ", isSmallScreen, " isPortarit: ", isPortait);

                stackView.push(welcomePage);
            }

            Component.onCompleted: {
                //console.log("Calling initialize on feature layer: " + featureLayerURL)
            }
        }
    }

    //--------------------------------------------------------------------------
    Component {
        id: welcomePage

        WelcomePage {

            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                switch(message) {
                case "viewmap": stackView.showMapPage(); break;
                case "createnew": if(app.hasAttachment) {
                        stackView.showAddPhotoPage();
                        break;
                    } else {
                        stackView.showRefineLocationPage();
                        break;
                    }
                case "details" : stackView.showAddDetailsPage();break
                }
            }

            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: mapPage
        MapPage {
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: addPhotoPage
        AddPhotoPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showRefineLocationPage();
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: refineLocationPage
        RefineLocationPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showAddDetailsPage();
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: addDetailsPage
        AddDetailsPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);

                if(message == "welcome") {
                    stackView.showWelcomePage()
                } else {
                    stackView.showResultsPage()
                }
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: resultsPage
        ResultsPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showWelcomePage()
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }

    //--------------------------------------------------------------------------
    AlertBox {
        id: alertBox
    }
}
