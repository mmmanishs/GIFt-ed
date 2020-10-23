//
//  SimulatorVideoRecordController.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/17/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class SimulatorVideoRecordController {
    private var xcrun_executable: String {
        return Bundle.main.path(forResource: "xcrun", ofType: nil)!
    }
    private var process: Process?

    func startRecording(videoPath: String) {
        DispatchQueue.global().async {
            let command = "\(self.xcrun_executable) simctl io booted recordVideo -f \"\(videoPath)\""
            let process = Process()
            self.process = process
            let pipe = Pipe()
            process.launchPath = "/bin/bash"
            process.arguments = ["-c", command]
            process.standardOutput = pipe

            if !process.isRunning {
                process.launch()
            }

            let outputHandle = pipe.fileHandleForReading
            outputHandle.readInBackgroundAndNotify()
            process.waitUntilExit()
        }
    }

    func stopRecording() {
        DispatchQueue.global().async {
            self.process?.interrupt()
        }
    }
}
