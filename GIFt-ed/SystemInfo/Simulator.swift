// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let simulator = try? newJSONDecoder().decode(Simulator.self, from: jsonData)

import Cocoa

// MARK: - Simulator
struct Simulator: Codable {
    let devicetypes: [Devicetype]
    let runtimes: [Runtime]
    let devices: [String: [Device]]
    let pairs: [String: Pair]

    var bootedDevices: [Simulator.Device] {
        var allDevices = [Device]()
        devices.forEach {
            allDevices.append(contentsOf: $0.value)
        }
        return allDevices.filter{$0.state == .booted }
    }
    
    var shutdownDevices: [Simulator.Device] {
        var allDevices = [Device]()
        devices.forEach {
            allDevices.append(contentsOf: $0.value)
        }
        return allDevices.filter{$0.state == .shutdown }
    }

    var isAnyBootedSimulatorPresent: Bool {
        return !bootedDevices.isEmpty
    }
}

// MARK: - Device
extension Simulator {
    enum AvailabilityError: String, Codable {
        case runtimeProfileNotFound = "runtime profile not found"
    }

    enum DeviceState: String, Codable {
        case booted = "Booted"
        case booting = "Booting"
        case shutdown = "Shutdown"
        case shuttingDown = "Shutting Down"
    }

    // MARK: - Devicetype
    struct Devicetype: Codable {
        let name, bundlePath, identifier: String
    }

    // MARK: - Pair
    struct Pair: Codable {
        let watch, phone: Device
        let state: PairState
    }

    enum PairState: String, Codable {
        case activeDisconnected = "(active, disconnected)"
        case unavailable = "(unavailable)"
    }

    // MARK: - Runtime
    struct Runtime: Codable {
        let version, bundlePath: String
        let isAvailable: Bool
        let name, identifier, buildversion: String
    }
}
