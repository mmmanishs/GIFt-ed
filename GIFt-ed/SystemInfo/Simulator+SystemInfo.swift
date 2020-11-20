//
//  SystemInfo.swift
//  Sims
//
//  Created by Singh, Manish on 5/2/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

extension Simulator {
    static func getSystemInfo() -> Simulator {
        let jsonString = "cd && xcrun simctl list devices --json".runAsCommand()
        let jsonData = Data(jsonString.utf8)
        if let simulator = try? JSONDecoder().decode(Simulator.self, from: jsonData) {
            return simulator
        } else {
            print("=========Simulator failed to parse (Begin)===========")
            print(jsonString)
        }
        return try! JSONDecoder().decode(Simulator.self, from: jsonData)
    }

    static func getUpdatedDevices() -> [Simulator.Device] {
        let devicesDicts = Simulator.getSystemInfo().devices
        var newdevices = [Device]()

        devicesDicts.forEach { devicesDict in
            let updatedDevices: [Device] = devicesDict.value.map {
                var device: Device = $0
                device._runtime = devicesDict.key
                return device
            }
            newdevices.append(contentsOf: updatedDevices)
        }
        return newdevices.sorted(by: >)
    }
}

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

extension String {
    func runAsBashCommand(completion: ((Process) -> ())? = nil) -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/bash"
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

