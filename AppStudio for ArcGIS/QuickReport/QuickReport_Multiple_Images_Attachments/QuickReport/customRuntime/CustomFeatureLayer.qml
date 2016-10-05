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

import ArcGIS.AppFramework.Runtime 1.0

FeatureLayer {
    featureTable: theFeatureServiceTable.valid ? theFeatureServiceTable : null

    property bool initOnStartPage: false


    onStatusChanged: {
        if (initOnStartPage) {

            console.log("GOOFA initialising featureLayer...")


            if(status == Enums.LayerStatusInitialized) {
                fields = theFeatureServiceTable.editableAttributeFields;

                console.log("---------FIELDS--------")
                console.log(JSON.stringify(fields, undefined, 2))
                console.log("---------END OF FIELDS--------")

                //Checking for Subtype information
                if ( theFeatureServiceTable.typeIdField > ""){
                    console.log("This service has a sub Type::", theFeatureServiceTable.typeIdField);
                    hasSubtypes = true;
                    featureTypes = theFeatureServiceTable.featureTypes;
                    console.log("featureTypes", JSON.stringify(featureTypes, undefined, 2));
                }
                else {
                    console.log("This service DOES NOT have a sub Type::");
                }

                for ( var j = 0; j < fields.length; j++ ) {
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

                    var defaultFieldValue = 0;
                    theFeatureAttributesModel.append({"fieldIndex": j, "fieldName": fields[j].name, "fieldAlias": fields[j].alias, "fieldType": fields[j].fieldTypeString, "fieldValue": "", "defaultNumber": defaultFieldValue, "isSubTypeField": isSubTypeField, "hasSubTypeDomain" : false, "hasDomain": hasDomain, "isRangeDomain": isRangeDomain })
                }

                app.hasAttachment = theFeatureServiceTable.hasAttachments;

                if(theFeatureLayer.renderer.rendererType === Enums.RendererTypeUniqueValue) {

                    var values = theFeatureLayer.renderer.uniqueValues;

                    console.log("values length", values.length);

                    for(var i=0; i< values.length; i++) {
                        var url = "";
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                        }
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                        }

                        //console.log(JSON.stringify(fields[theFeatureServiceTable.typeIdField]["domain"]));
                        //                        console.log(JSON.stringify({"label": values[i].label, "value" : values[i]["value"].toString()}, undefined, 2))
                        theFeatureTypesModel.append({"label": values[i].label, "value" : values[i]["value"].toString(), "description": values[i].description, "imageUrl": url});
                    }
                }
            }

            if(status == Enums.LayerStatusErrored) {
                console.log("Layer create error: ", error)
            }
        }
    }
}
