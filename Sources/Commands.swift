//
//  Commands.swift
//  jsonutil
//
//  Created by Stephan Lötscher on 03.04.17.
//
//

import Foundation
import Commander

//remove command
let removeCommand = command(
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("removefile", description: "remove map file name. '[remove path]', line separated"),
    Argument("input", description: "input json file path")
) {
    (doPrettyPrint: Bool, removeFilePath: String, filePath: String) in
    
    guard let removeStrings = try? String(contentsOfFile: removeFilePath, encoding: String.Encoding.utf8) else {
        preconditionFailure("Failed to read remove map file")
    }
    
    var patterns = removeStrings.components(separatedBy: .newlines).filter { !$0.isEmpty }
    
    processJsonFile(inputFilePath: filePath, doPrettyPrint: doPrettyPrint) { (json) in
        json = remove(from: json, patterns: patterns)
    }
}

//pretty command
let prettyPrintedCommand = command(
    Argument<String>("input", description: "input json file path")
) {
    filePath in
    
    processJsonFile(inputFilePath: filePath, doPrettyPrint: true) { _ in }
}

//replace command
let replaceCommand = command(
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("replacefile", description: "replace map file name. '[search term]=[replace term]', line separated"),
    Argument("input", description: "input json file path")
) {
    (doPrettyPrint: Bool, replaceMapFilePath: String, filePath: String) in
    
    guard let searchReplaceStrings = try? String(contentsOfFile: replaceMapFilePath, encoding: String.Encoding.utf8) else {
        preconditionFailure("Failed to read replace map file")
    }
    
    var searchReplaceMap = [String: String]()
    searchReplaceStrings.components(separatedBy: .newlines).forEach { (line: String) in
        let sr = line.components(separatedBy: "=")
        if let searchKey = sr.first, sr.count > 1 {
            let searchValue = Array(sr.dropFirst()).joined(separator: "=")
            searchReplaceMap[searchKey] = searchValue
        }
    }
    
    processJsonFile(inputFilePath: filePath, doPrettyPrint: doPrettyPrint) { (json) in
        replaceValue(in: &json, searchReplaceMap: searchReplaceMap)
    }
}

//filter command
let filterCommand = command(
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("filterfile", description: "filter map file name. '[filter path]', line separated"),
    Argument("input", description: "input json file path")
){
    (doPrettyPrint: Bool, filterFilePath: String, filePath: String) in
    
    guard let filterStrings = try? String(contentsOfFile: filterFilePath, encoding: String.Encoding.utf8) else {
        preconditionFailure("Failed to read filter map file")
    }
    
    var patterns = filterStrings.components(separatedBy: .newlines).filter( { !$0.isEmpty })
    
    processJsonFile(inputFilePath: filePath, doPrettyPrint: doPrettyPrint) { (json: inout JSON_OBJ) in
        json = filter(from: json, patterns: patterns)
    }
}

