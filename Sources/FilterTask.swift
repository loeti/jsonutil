//
//  FilterTask.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 14.02.17.
//
//

import Foundation

func filter(from json: JSON_OBJ, patterns: [String]) -> JSON_OBJ {
    //create for every pattern line a path object
    let paths = patterns.map { Path(path: $0) }
    
    //filter out all items matching the defined paths
    //on top level a JSON_OBJ object as result is expected
    switch filter(from: json, withPaths: paths) {
    case .map(let resultJson):
        return resultJson
    default:
        return JSON_OBJ()
    }
}


fileprivate enum FilterResult {
    case array([JSON_OBJ])
    case map(JSON_OBJ)
    case value(Any)
    case notMatched
}


fileprivate func filter(from json: JSON_OBJ, withPaths paths: [Path]) -> FilterResult {
    //group all the paths in common path elements for the first path level
    let pathElements = getFirstPathsElements(paths: paths)
    //if no more path elements are defined, return rest of json object
    guard pathElements.count > 0 else {
        return .map(json)
    }
    //get the paths with first path element removed
    let restOfPaths = dropFirstPathsElements(fromPaths: paths)
    
    //json object with filtered result
    var filteredJson = JSON_OBJ()
    
    for pathElement in pathElements {
        switch pathElement {
        //only map patterns are possible on a JSON_OBJ object
        case .map(pattern: let mapPattern):
            switch mapPattern {
                
            case .equals(key: let key):
                //test for key
                if let jsonValue = json[key] {
                    //value exists
                    let result = dispatch(value: jsonValue, paths: restOfPaths)
                    
                    switch result {
                    //not empty json array
                    case .array(let jsonArray) where !jsonArray.isEmpty:
                        filteredJson[key] = jsonArray
                    //empty json array
                    case .array(let jsonArray) where jsonArray.isEmpty:
                        break
                    //json object
                    case .map(let json):
                        filteredJson[key] = json
                    //simple value
                    case .value(let value):
                        filteredJson[key] = value
                    //a mandatory subjson structure is not found
                    case .notMatched:
                        return .notMatched
                        
                    default:
                        break
                    }
                }
                else if isMandatoryPathElement(pathElement: pathElement, paths: paths) {
                    // abort because mandatory element not matched
                    return .notMatched
                }
            }
            
        default:
            print("Warning pattern does not match json structure!")
        }
    }
    
    return .map(filteredJson)
}


fileprivate func filter(fromArray jsonArray: [JSON_OBJ], withPaths paths: [Path]) -> FilterResult {
    //group all the paths in common path elements for the first path level
    let pathElements = getFirstPathsElements(paths: paths)
    //if no more path elements are defined, return rest of json object
    guard pathElements.count > 0 else {
        return .array(jsonArray)
    }
    //get the paths with first path element removed
    let restOfPaths = dropFirstPathsElements(fromPaths: paths)
    
    //array of json objects with filtered results
    var filteredJson = [JSON_OBJ]()
    
    for pathElement in pathElements {
        switch pathElement {
        //only array patterns are possible on a [JSON_OBJ] object
        case .array(pattern: let arrayPattern):
            switch arrayPattern {
            case .all:
                //add map results only
                var atLeastOneMatch = false
                for json in jsonArray {
                    let result = dispatch(value: json, paths: restOfPaths)
                    
                    switch result {
                    case .map(let subJson):
                        //only append non empty maps
                        if subJson.count > 0 {
                            filteredJson.append(subJson)
                            atLeastOneMatch = true
                        }
                        
                    case .notMatched:
                        continue
                        
                    default:
                        print("Warning value is not a map!")

                    }
                }
                //there must be at least one object if mandatory path element exists
                if !atLeastOneMatch && isMandatoryPathElement(pathElement: pathElement, paths: paths) {
                    // abort because mandatory element not matched                    
                    return .notMatched
                }
                
            case .contains(key: let key, value: let expectedValue):
                //add map results only
                var atLeastOneMatch = false
                for json in jsonArray {
                    //add only if there is a key/value that matches the expected key/value
                    if let value = json[key], expectedValue == String(describing: value) {
                        let result = dispatch(value: json, paths: restOfPaths)
                        
                        switch result {
                        case .map(let subJson):
                            //only append non empty maps
                            if subJson.count > 0 {
                                filteredJson.append(subJson)
                                atLeastOneMatch = true
                            }
                            
                        case .notMatched:
                            continue
                            
                        default:
                            print("Warning value is not a map!")
                        }
                    }
                }
                //there must be at least one object if mandatory path element exists
                if !atLeastOneMatch && isMandatoryPathElement(pathElement: pathElement, paths: paths) {
                    // abort because mandatory element not matched
                    return .notMatched
                }
            }
        
        default:
            print("Warning pattern does not match json structure!")
        }
    }
    
    return .value(filteredJson)
}


fileprivate func dispatch(value: Any, paths: [Path]) -> FilterResult {
    
    switch value {
    case let json as JSON_OBJ:
        return filter(from: json, withPaths: paths)
        
    case let jsonArray as [JSON_OBJ]:
        return filter(fromArray: jsonArray, withPaths: paths)
        
    default:
        return .value(value)
    }
}

