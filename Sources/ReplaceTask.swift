//
//  ReplaceTask.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 14.02.17.
//
//

import Foundation

func replaceValue(in json: inout JSON_OBJ, searchReplaceMap: [String:String] ) {
    
    for (key, value) in json {
        switch value {
        case var subJson as JSON_OBJ:
            replaceValue(in: &subJson, searchReplaceMap: searchReplaceMap)
            json[key] = subJson
            
        case var subJson as [JSON_OBJ]:
            replaceValue(inJsonArray: &subJson, searchReplaceMap: searchReplaceMap)
            json[key] = subJson
        
        case var array as [Any]:
            replaceValue(inArray: &array, searchReplaceMap: searchReplaceMap)
            json[key] = array
            
        default:
            let targetValue = String(describing: value)
            for (replaceKey, replaceValue) in searchReplaceMap {
                
                if let range = targetValue.range(of:replaceKey, options: .regularExpression) {
                    let result = targetValue.replacingCharacters(in: range, with: replaceValue)
                    json[key] = result
                    break
                }
            }
        }
    }
}


func replaceValue(inJsonArray jsonArray: inout [JSON_OBJ], searchReplaceMap: [String:String] ) {
   
    jsonArray = jsonArray.map {  (jsonObj) in
        var json = jsonObj
        replaceValue(in: &json, searchReplaceMap: searchReplaceMap)
        return json
    }
}


func replaceValue(inArray array: inout [Any], searchReplaceMap: [String:String] ) {
    
    array = array.map { (item) in
        return searchReplaceMap[String(describing: item)] ?? item
    }
}

func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = NSString(string: text)
        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range) }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
