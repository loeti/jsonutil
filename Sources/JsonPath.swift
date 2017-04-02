//
//  JsonPath.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 16.02.17.
//
//

import Foundation

enum MapPattern {
    case equals(key: String)
}

enum ArrayPattern {
    case all
    case contains(key: String, value: String)
}

enum PathElement: Hashable, CustomStringConvertible, CustomDebugStringConvertible{
    
    case map(pattern: MapPattern)
    case array(pattern: ArrayPattern)
    
    public var description: String {
        get {
            switch self {
            case .map(pattern: let pattern):
                switch pattern {
                case .equals(key: let key):
                    return "map equals \(key)"                }
                
            case .array(pattern: let pattern):
                switch pattern {
                case .all:
                    return "array all"
                    
                case .contains(key: let key, value: let value):
                    return "array contains \(key) \(value)"
                }
            }
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var hashValue: Int {
        get {
            return description.hashValue
        }
    }
    
    static func ==(lhs: PathElement, rhs: PathElement) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct Path {
    
    private static func extractPathElements(pathDef: String) -> ([PathElement], Bool) {
        let isMandatory = pathDef.hasPrefix("&&")
        let path = isMandatory ? String(pathDef.characters.dropFirst(2)) : pathDef

        let elements: [PathElement] = path.components(separatedBy: "/").map( { (elementDef) in
            if elementDef.hasPrefix("[") && elementDef.hasSuffix("]") {
                //is array definition
                let pattern = String(elementDef.characters.dropFirst().dropLast())
                
                if pattern.contains("=") {
                    //match contains (key = value) pattern
                    let query = pattern.components(separatedBy: "=")
                    let key = query[0]
                    let value = query[1]
                    return .array(pattern: .contains(key: key, value: value))
                }
                else if pattern == "*" {
                    //match all pattern
                    return .array(pattern: .all)
                }
                else {
                    return .array(pattern: .all)
                }
            }
            else {
                // is map definition
                return .map(pattern: .equals(key: elementDef))
            }
        } )
        return (elements, isMandatory)
    }
    
    
    
    private let _elements: [PathElement]
    
    var elements: [PathElement] {
        if index < _elements.endIndex {
            return Array(_elements.suffix(from: index))
        }
        return []
    }
    let isMandatory: Bool
    
    private var index: Array<PathElement>.Index
    
    init(path: String) {
        let (elements, isMandatory) = Path.extractPathElements(pathDef: path)
        
        self._elements = elements
        self.isMandatory = isMandatory
        self.index = elements.startIndex
    }
    
    mutating func dropFirst() {
        index = index.advanced(by: 1)
    }
}

/// Splits the paths in path elements and return the first path elements,
/// equal elements are combined.
/// - Parameter paths: paths to get the first elements
/// - Returns: Array of different first path elements
func getFirstPathsElements(paths: [Path]) -> [PathElement] {
    var elements = Set<PathElement>()
    for path in paths {
        if let firstElement = path.elements.first {
            elements.insert(firstElement)
        }
    }
    return Array(elements)
}

func isMandatoryPathElement(pathElement: PathElement, paths: [Path]) -> Bool {
    let mandatorypaths = paths.filter{ $0.isMandatory }
    return mandatorypaths.flatMap {
        $0.elements.first
        }
        .map{
            $0 == pathElement
        }
        .reduce(false){
            $0.0 || $0.1
    }
}

func dropFirstPathsElements(fromPaths paths: [Path]) -> [Path] {
    var restOfPath = [Path]()
    for var path in paths {
        path.dropFirst()
        restOfPath.append(path)
    }
    return restOfPath
}
