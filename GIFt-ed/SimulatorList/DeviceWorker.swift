//
//  DeviceWorker.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/28/20.
//

import Foundation

class DeviceWorker {
    enum Action: String {
        case boot, deviceData, copyUdid, erase, unknown
        init(actionIdentifier: String) {
            switch actionIdentifier {
            case "boot":
                self = .boot
            case "deviceData":
                self = .deviceData
            case "copyUdid":
                self = .copyUdid
            case "erase":
                self = .erase
            default:
                self = .unknown
            }
        }
    }
    let udid: String
    let action: Action
    init(udid: String, action: Action) {
        self.udid = udid
        self.action = action
    }

    func execute() {
        switch action {
        case .boot:
            boot()
        case .deviceData:
            openDeviceDataFolder()
        case .copyUdid:
            copyUdid()
        case .erase:
            erase()
        default:
            break
        }
    }

    func boot() {
        _ = "open -a Simulator.app && xcrun simctl boot \(udid)".runAsCommand()
    }

    func openDeviceDataFolder() {
        guard let device = SystemInfo(allowedTypes: [.iOS]).getDevice(for: udid) else {
            return
        }
        _ = "open \(device.dataPath)".runAsCommand()
    }

    func copyUdid() {
        _ = "echo \(udid) | pbcopy".runAsCommand()
    }

    func erase() {
        guard let device = SystemInfo(allowedTypes: [.iOS]).getDevice(for: udid) else {
            return
        }
        let shouldOpen = device.state == .booted
        _ = "xcrun simctl shutdown \(udid)".runAsCommand { process in
            _ = "xcrun simctl erase \(self.udid)".runAsCommand{ process in
                if shouldOpen {
                    self.boot()
                }
            }
        }
    }
}
