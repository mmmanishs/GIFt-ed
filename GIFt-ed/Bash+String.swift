//
//  Bash+String.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/22/20.
//

import Foundation

extension String {
    func runAsCommand(completion: ((Process) -> ())? = nil) -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        task.terminationHandler = completion
        task.waitUntilExit()
        let file = pipe.fileHandleForReading
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            return "--- Error running command - Unable to initialize string from file data ---"
        }
    }
}
