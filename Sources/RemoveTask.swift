//
//  RemoveTask.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 14.02.17.
//
//

import Foundation


func remove(from json: JSON, patterns: [String]) -> JSON {
    let paths = patterns.map { Path(path: $0) }
    
    var resultJson = json
    for path in paths {
        //filter out all items matching the defined path
        //on top level a JSON object as result is expected
        switch remove(from: resultJson, withPath: path) {
        case .map(let result):
            resultJson = result
        default:
            break
        }
    }
    return resultJson
}

fileprivate enum RemoveResult {
    case array([JSON])
    case map(JSON)
    case value(Any)
    case notMatched
}

fileprivate func remove(from json: JSON, withPath: Path) -> RemoveResult {
    //json object with removed result
    var removedJson = json
    var path = withPath
    
    if let pathElement = path.elements.first {
        path.dropFirst()
        switch pathElement {
        //only map patterns are possible on a JSON object
        case .map(pattern: let mapPattern):
            switch mapPattern {
                
            case .equals(key: let key):
                //test for key
                if let jsonValue = json[key] {
                    //value exists
                    let result = dispatch(value: jsonValue, path: path)
                    
                    switch result {
                    //json array
                    case .array(let jsonArray) where !jsonArray.isEmpty:
                        removedJson[key] = jsonArray
                    //empty json array
                    case .array(let jsonArray) where jsonArray.isEmpty:
                        removedJson.removeValue(forKey: key)
                    //json object
                    case .map(let json):
                        removedJson[key] = json
                    //simple value
                    case .value:
                        removedJson.removeValue(forKey: key)
                        
                    default:
                        break
                    }
                }
            }
            
        default:
            print("Warning pattern does not match json structure!")
        }
    }
    
    return .map(removedJson)
}


fileprivate func remove(fromArray jsonArray: [JSON], withPath: Path ) -> RemoveResult {
    //json object with removed result
    var removedJsonArray = [JSON]()
    
    var path = withPath

    if let pathElement = path.elements.first {
        path.dropFirst()
        switch pathElement {
        //only array patterns are possible on a [JSON] object
        case .array(pattern: let arrayPattern):
            switch arrayPattern {
            case .all:
                //add map results only
                for json in jsonArray {
                    let result = dispatch(value: json, path: path)
                    
                    switch result {
                    case .map(let subJson):
                        //only append non empty maps
                        if subJson.count > 0 {
                            removedJsonArray.append(subJson)
                        }
                        
                    case .notMatched:
                        continue
                        
                    default:
                        print("Warning value is not a map!")
                    }
                }
                
            case .contains(key: let key, value: let expectedValue):
                //add map results only
                for json in jsonArray {
                    //add only if there is a key/value that matches the expected key/value
                    if let value = json[key], expectedValue == String(describing: value) {
                        let result = dispatch(value: json, path: path)
                        
                        switch result {
                        case .map(let subJson):
                            //only append non empty maps
                            if subJson.count > 0 {
                                removedJsonArray.append(subJson)
                            }
                            
                        case .notMatched:
                            continue
                            
                        default:
                            print("Warning value is not a map!")
                        }
                    }
                    else {
                        removedJsonArray.append(json)
                    }
                }
            }
            
        default:
            print("Warning pattern does not match json structure!")
        }
    }
    
    return .array(removedJsonArray)
}

fileprivate func dispatch(value: Any, path: Path) -> RemoveResult {
    switch value {
    case let json as JSON:
        return remove(from: json, withPath: path)
        
    case let jsonArray as [JSON]:
        return remove(fromArray: jsonArray, withPath: path)
        
    default:
        return .value(value)
    }
}

