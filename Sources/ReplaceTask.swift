//
//  ReplaceTask.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 14.02.17.
//
//

import Foundation

func replaceValue(in json: inout JSON, searchReplaceMap: [String:String] ) {
    
    for (key, value) in json {
        switch value {
        case var subJson as JSON:
            replaceValue(in: &subJson, searchReplaceMap: searchReplaceMap)
            json[key] = subJson
            
        case var subJson as [JSON]:
            replaceValue(inJsonArray: &subJson, searchReplaceMap: searchReplaceMap)
            json[key] = subJson
        
        case var array as [Any]:
            replaceValue(inArray: &array, searchReplaceMap: searchReplaceMap)
            json[key] = array
            
        default:
            let replaceKey = String(describing: value)
            if let replaceValue = searchReplaceMap[replaceKey] {
                json[key] = replaceValue
            }
        }
    }
}


func replaceValue(inJsonArray jsonArray: inout [JSON], searchReplaceMap: [String:String] ) {
   
    jsonArray = jsonArray.map {
        var json = $0
        replaceValue(in: &json, searchReplaceMap: searchReplaceMap)
        return json
    }
}


func replaceValue(inArray array: inout [Any], searchReplaceMap: [String:String] ) {
    
    array = array.map { (item) in
        return searchReplaceMap[String(describing: item)] ?? item
    }
}
