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

GeodatabaseFeatureServiceTable {
    function fieldArray() {
        var array = [];
        for (var i = 0; i < fields.length; i++) {
            array.push(fields[i]);
        }
        for (var i = 0; i < featureTypes.length; i++) {
            //array.push(featureTypes[i]);
            //array.push(featureTypes[i].domains);
            array.push( { "name": featureTypes[i].domains[0] });
        }
        return array;
    }

    function lookupField(name) {
        return fieldArray().filter(function(e) { return e.name == name; })[0];
    }

}
