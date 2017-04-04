import Commander
import Foundation
import Jay


public typealias JSON_OBJ = [String : Any]

func processJsonFile(inputFilePath: String, doPrettyPrint: Bool, action:(inout JSON_OBJ) -> ()) {
    
    guard let fileContent = try? Data.init(contentsOf: URL.init(fileURLWithPath: inputFilePath)) else {
        preconditionFailure("Invalid input file: \(inputFilePath)")
    }
    
    guard let anyJson = try? Jay().anyJsonFromData(Array(fileContent)), var json = anyJson as? JSON_OBJ else {
        preconditionFailure("Invalid file content, must be valid json.")
    }
    
    action(&json)
    
    let formattingOption:Jay.Formatting = doPrettyPrint ? .prettified : .minified

    do {
        try Jay(formatting: formattingOption).dataFromJson(any: json, output: ConsoleOutputStream())
    }
    catch let error {
        preconditionFailure("Failed to write output " + error.localizedDescription)
    }
}

let commandGroup = Group { group in
    group.addCommand("remove", removeCommand)
    group.addCommand("pretty", prettyPrintedCommand)
    group.addCommand("replace", replaceCommand)
    group.addCommand("filter", filterCommand)
}

commandGroup.run()

