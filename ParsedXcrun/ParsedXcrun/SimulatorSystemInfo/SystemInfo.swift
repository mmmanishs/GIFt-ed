//
//  SystemInfo.swift
//  ParsedXcrun
//
//  Created by Manish Singh on 11/21/20.
//

import Foundation


/// When the SystemInfo is first initailzed the information it fetches the latest information, Subsequently call func refersh to fetch the latest data.
struct SystemInfo {
    enum AllowedTypes: String, CustomStringConvertible {
        var description: String {
            return self.rawValue
        }

        case iOS = "iOS"
        case tvOS = "tvOS"
        case watchOS = "watchOS"
    }
    var simulator: Simulator?

    private var allowedTypes: [AllowedTypes]

    init(allowedTypes: [AllowedTypes] = [.iOS, .tvOS, .watchOS]) {
        self.allowedTypes = allowedTypes
        refresh()
    }
    
    var runtimes: [String] {
        guard let simulator = simulator else {
            return []
        }
        return Array(simulator.devices.keys)
    }
    
    var runtimesPretty: [String] {
        guard let simulator = simulator else {
            return []
        }
        return Array(simulator.devices.keys.map {
            Simulator.prettyRuntime(from: $0)
        })
    }
    
    var runtimesPrettyNoSpaces: [String] {
        guard let simulator = simulator else {
            return []
        }
        return Array(simulator.devices.keys.map {
            Simulator.prettyRuntimeNoSpaces(from: $0)
        })
    }
    
    var bootedDevices: [Simulator.Device] {
        guard let simulator = simulator else {
            return []
        }
        return simulator.devices.map {$0.value}.reduce([], +).filter {$0.isAvailable}.filter { $0.state == .booted }
    }

    var topMostBootedDevice: Simulator.Device? {
        return simulator?.devices.map {$0.value}.reduce([], +).filter {$0.isAvailable}.filter { $0.state == .booted }.first
    }
    
    var isAnyBootedSimulatorPresent: Bool {
        return !bootedDevices.isEmpty
    }
    
    var allDevices: [Simulator.Device] {
        guard let simulator = simulator else {
            return []
        }
        return simulator.devices.map {$0.value}.reduce([], +).filter {$0.isAvailable}.sorted(by: >)
    }
    
    mutating func refresh() {
        let str = "xcrun simctl list devices --json".runAsCommand()
        let jsonData = Data(str.utf8)
        var formattedKeyValueDevices = [String: [Simulator.Device]]()
        if let extractedSimulator = try? JSONDecoder().decode(Simulator.self, from: jsonData) {
            for (key, devices) in extractedSimulator.devices where iSRuntimeAllowed(key){
                var updatedDevices = [Simulator.Device]()
                for device in devices {
                    var d = device
                    d.runTime = key
                    updatedDevices.append(d)
                }
                if !updatedDevices.isEmpty {
                    formattedKeyValueDevices[key] = updatedDevices.sorted(by: >)
                }
            }
            self.simulator = Simulator(devices: formattedKeyValueDevices)
        }
    }

    func iSRuntimeAllowed(_ runtime: String) -> Bool {
        for allowedType in allowedTypes {
            if runtime.contains(allowedType.description) { return true }
        }
        return false
    }

    func getDevice(for udid: String) -> Simulator.Device? {
        return allDevices.filter {
            $0.udid == udid
        }.first
    }
}
