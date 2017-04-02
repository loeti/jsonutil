import Commander
import Foundation

public typealias JSON = [String : Any]


func processJsonFile(inputFilePath: String, outputFilePath: String, doPrettyPrint: Bool, action:(inout JSON) -> ()) {
    guard let inputStream = InputStream(fileAtPath: inputFilePath) else {
        preconditionFailure("Invalid input file: \(inputFilePath)")
    }
    inputStream.open()
    defer {
        inputStream.close()
    }
    
    guard let outputStream = OutputStream(toFileAtPath: outputFilePath, append: false) else {
        preconditionFailure("Invalid output file: \(outputFilePath)")
    }
    outputStream.open()
    defer {
        outputStream.close()
    }
    
    guard var json = try? JSONSerialization.jsonObject(with: inputStream, options: [.mutableContainers, .mutableLeaves] ) as! JSON else {
        preconditionFailure("Invalid file content, must be valid json.")
    }
    
    action(&json)
    
    let writeOptions: JSONSerialization.WritingOptions = doPrettyPrint ? [.prettyPrinted] : []
    
    print(String(data: try! JSONSerialization.data(withJSONObject: json, options: writeOptions), encoding: .utf8)!)
    
    guard JSONSerialization.writeJSONObject(json, to: outputStream, options: writeOptions, error: nil) > 0 else {
        preconditionFailure("Failed to write output")
    }
}

let removeCommand = command(
    Option("output", "out.json", flag: "o", description: "output file name"),
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("removefile", description: "remove map file name. '[remove path]', line separated"),
    Argument("input", description: "input json file path")
){ (outputFilePath: String, doPrettyPrint: Bool, removeFilePath: String, filePath: String) in
    
    guard let removeStrings = try? String(contentsOfFile: removeFilePath, encoding: String.Encoding.utf8) else {
        preconditionFailure("Failed to read remove map file")
    }
    
    var patterns = removeStrings.components(separatedBy: .newlines).filter { !$0.isEmpty }
    
    processJsonFile(inputFilePath: filePath, outputFilePath: outputFilePath, doPrettyPrint: doPrettyPrint) { (json) in
        json = remove(from: json, patterns: patterns)
    }
}




let prettyPrintedCommand = command(
    Option("output", "out.json", flag: "o"),
    Argument<String>("input", description: "input json file path")
) {outputFilePath,filePath in
    
    processJsonFile(inputFilePath: filePath, outputFilePath: outputFilePath, doPrettyPrint: true) { _ in }
}


let replaceCommand = command(
    Option("output", "out.json", flag: "o", description: "output file name"),
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("replacefile", description: "replace map file name. '[search term]=[replace term]', line separated"),
    Argument("input", description: "input json file path")
) { (outputFilePath: String, doPrettyPrint: Bool, replaceMapFilePath: String, filePath: String) in
    
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
    
    processJsonFile(inputFilePath: filePath, outputFilePath: outputFilePath, doPrettyPrint: doPrettyPrint) { (json) in
        replaceValue(in: &json, searchReplaceMap: searchReplaceMap)
    }
}


let filterCommand = command(
    Option("output", "out.json", flag: "o", description: "output file name"),
    Flag("prettyPrinted", flag: "p", description: "pretty printed output"),
    Argument("filterfile", description: "filter map file name. '[filter path]', line separated"),
    Argument("input", description: "input json file path")
){ (outputFilePath: String, doPrettyPrint: Bool, filterFilePath: String, filePath: String) in
    
    guard let filterStrings = try? String(contentsOfFile: filterFilePath, encoding: String.Encoding.utf8) else {
        preconditionFailure("Failed to read filter map file")
    }
    
    var patterns = filterStrings.components(separatedBy: .newlines).filter( { !$0.isEmpty })
    
    processJsonFile(inputFilePath: filePath, outputFilePath: outputFilePath, doPrettyPrint: doPrettyPrint) { (json: inout JSON) in
        json = filter(from: json, patterns: patterns)
    }
}




let main = Group { group in
    group.addCommand("remove", removeCommand)
    group.addCommand("pretty", prettyPrintedCommand)
    group.addCommand("replace", replaceCommand)
    group.addCommand("filter", filterCommand)
    
}

main.run()

