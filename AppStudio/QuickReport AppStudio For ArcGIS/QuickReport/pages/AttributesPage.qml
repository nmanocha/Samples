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

import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "../controls"
import "../controls/styles"

Item {
    id: attributesPage
    focus: true
    anchors.fill: parent

    ListView {
        id: listView
        clip: true
        spacing: 15* app.scaleFactor
        width: 300*app.scaleFactor
        height: parent.height
        //anchors.topMargin: 20*app.scaleFactor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model: fieldsMassaged

        //onModelChanged: console.log("Line 30", JSON.stringify(model, undefined, 2))

        property bool canSubmit: true

        delegate: Component {Loader {
                id: loader
                property string fieldName :  modelData["name"]
                property string fieldAlias : modelData["alias"]
                property int fieldType: modelData["fieldType"]
                property bool hasSubTypeDomain: featureTypes[pickListIndex].domains[modelData["name"]] ? true : false
                property bool isSubTypeField : modelData["name"] === theFeatureServiceTable.typeIdField ? true : false
                property bool hasPrototype: featureTypes[pickListIndex].templates[0].prototype[modelData["name"]] > "" ? true : false
                property var defaultValue : hasPrototype ? featureTypes[pickListIndex].templates[0].prototype[modelData["name"]] : fieldType == Enums.FieldTypeString ? "" : null
                //property string defaultDate : hasPrototype && fieldType == Enums.FieldTypeDate ? getDateValue() : ""
                property string defaultDate : hasPrototype && fieldType == Enums.FieldTypeDate ? defaultValue : ""
                property int defaultIndex
                property var rangeArray: []
                property var codedNameArray : []
                property var codedCodeArray: []
                property int domainTypeIndex: 0
                property var domainTypeArray
                property var functionArray

                property bool isRequired: false

                anchors.horizontalCenter: parent.horizontalCenter

                width: 300 * app.scaleFactor

                sourceComponent: (function(){
                    attributesArray[fieldName] = defaultValue;

                    domainTypeArray = {
                        0: editControl,
                        1: rangeControl,
                        3: cvdControl,
                        99: subTypeCvdControl
                    }

                    functionArray = {
                        0: getEditControlValues,
                        1: getRangeDomainValues,
                        3: getAtrributeDomainValues,
                        99: getSubTypeAtrributeDomainValues
                    }

                    //Get the SubType Attribute codes
                    if ( isSubTypeField ) {
                        if ( modelData["domain"]) {
                            domainTypeIndex = 3;
                            functionArray[domainTypeIndex](modelData["domain"]);
                        }
                        else {
                            domainTypeIndex = 99;
                            functionArray[domainTypeIndex](featureTypes);
                        }

                        return domainTypeArray[domainTypeIndex];
                    }

                    //console.log("...", fieldName, "has a subtype domain", hasSubTypeDomain)
                    if (hasSubTypeDomain){
                        if (featureTypes[pickListIndex].domains[modelData["name"]]["domainType"] == Enums.DomainTypeInherited) {
                            getFieldDomainDetails( modelData["domain"] );
                            domainTypeIndex =  modelData["domain"]["domainType"];
                        }
                        else {
                            //console.log(JSON.stringify(featureTypes[pickListIndex].domains[modelData["name"]], undefined, 2))

                            domainTypeIndex = featureTypes[pickListIndex].domains[modelData["name"]]["domainType"];
                            getFieldDomainDetails(featureTypes[pickListIndex].domains[modelData["name"]]);

                        }
                        return domainTypeArray[domainTypeIndex];
                    }

                    if ( modelData["domain"] ) {
                        //console.log("...", fieldName, "has a domain")
                        getFieldDomainDetails( modelData["domain"] );
                        domainTypeIndex =  modelData["domain"]["domainType"];
                        return domainTypeArray[domainTypeIndex];
                    }

                    functionArray[domainTypeIndex]();
                    return domainTypeArray[domainTypeIndex];
                })()

                function getFieldDomainDetails(fieldDomain){
                    domainTypeIndex = fieldDomain["domainType"];
                    functionArray[domainTypeIndex](fieldDomain);
                }

                function getEditControlValues(){
                    console.log("This is a text box");
                }

                function getRangeDomainValues(domainObject){
                    rangeArray.push(domainObject["minValue"], domainObject["maxValue"])
                }

                function getAtrributeDomainValues(domainObject){
                    console.log("getAtrributeDomainValues...");
                    console.log(JSON.stringify(domainObject, undefined, 2));

                    var array = domainObject["codedValues"];

                    //This sort function is here to deal with how the QML API is returning the list of attribute domain values
                    array.sort(function(a, b) {
                        if(typeof(a.code) == "string"){
                            return a.code.localeCompare(b.code);
                        }
                        else if (typeof(a.code) === "number"){
                            return parseFloat(a.code) - parseFloat(b.code);
                        }
                    });

                    for ( var i = 0; i < array.length; i++ ) {
                        codedCodeArray.push(array[i]["code"]);
                        codedNameArray.push(array[i]["name"]);
                    }
                }

                function getSubTypeAtrributeDomainValues(typesObject){
                    console.log("getSubTypeAtrributeDomainValues...");

                    for ( var type in typesObject){
                        codedCodeArray.push(typesObject[type]["featureTypeId"]);
                        codedNameArray.push(typesObject[type]["name"]);
                    }
                }

                //                function getDateValue(){
                //                    //var dateMilliseconds = new Date(defaultValue)
                //                    console.log("!@", defaultValue)
                //                    defaultValue = defaultValue //dateMilliseconds.toLocaleDateString(Qt.LocalDate);
                //                }
            }
        }

        header: Component {
            Text {
                text: qsTr("Fill in the fields below")
                height: 50 * app.scaleFactor
                width: parent.width
                textFormat: Text.StyledText
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                fontSizeMode: Text.Fit

                font {
                    pointSize: app.baseFontSize * 0.9
                }
                color: app.textColor
                elide: Text.ElideRight
            }
        }

        footer: Rectangle {
            color: "transparent"
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: page4_button1.height + page4_button2.height + 50*app.scaleFactor

            ColumnLayout {
                id: buttons
                anchors.fill: parent
                spacing: 20*app.scaleFactor
                anchors.topMargin: 20*app.scaleFactor

                CustomButton {
                    id:page4_button1
                    buttonText: qsTr("Submit")
                    buttonColor: app.buttonColor
                    buttonTextColor: AppFramework.network.isOnline ? "#ffffff" : "#A6A8AB"
                    buttonWidth: 300 * app.scaleFactor
                    buttonHeight: buttonWidth/5
                    enabled: listView.canSubmit && AppFramework.network.isOnline

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            next("results")
                        }
                    }
                }
                CustomButton {
                    id:page4_button2
                    buttonText: qsTr("Cancel")
                    buttonColor: "red"
                    buttonWidth: 300 * app.scaleFactor
                    buttonHeight: buttonWidth/6
                    buttonFill: false
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            next("welcome")
                        }
                    }
                }
            }
        }

        function onAttributeUpdate(f_name, f_value){
            console.log("Got: ", f_name, f_value, typeof(f_value));
            for(var i=0; i<theFeatureAttributesModel.count; i++) {
                var item = theFeatureAttributesModel.get(i);
                if(item["fieldName"] == f_name) {
                    item["fieldValue"] = f_value;
                }
            }
        }
    }

    Component {
        id: editControl
        EditControl{}
    }

    Component {
        id: cvdControl
        Domain_CodedValue {}
    }

    Component {
        id: subTypeCvdControl
        SubType_CodedValue {}
    }

    Component {
        id: rangeControl
        Domain_Range {}
    }

    Component {
        id: dateControl
        DateControl {}
    }
}
