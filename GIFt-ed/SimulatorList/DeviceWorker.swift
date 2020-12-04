//
//  DeviceWorker.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/28/20.
//

import Foundation

class DeviceWorker {
    enum Action: String {
        case boot, shutdown, deviceData, copyUdid, erase, toggleLightDarkMode, turnOnLightMode, turnOnDarkMode, unknown
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
        case .shutdown:
            shutdown()
        case .deviceData:
            openDeviceDataFolder()
        case .copyUdid:
            copyUdid()
        case .erase:
            erase()
        case .turnOnLightMode:
            turnOnLightMode()
        case .turnOnDarkMode:
            turnOnDarkMode()
        case .toggleLightDarkMode:
            toggleLightDarkMode()
        default:
            break
        }
    }

    func toggleLightDarkMode() {
        guard let device = SystemInfo(allowedTypes: [.iOS]).getDevice(for: udid) else {
            return
        }
        device.fetchAppearence { appearence in
            if appearence == .light {
                self.turnOnDarkMode()
            } else if appearence == .dark {
                self.turnOnLightMode()
            }
        }
    }

    func turnOnLightMode() {
        DispatchQueue.global().async {
            _ = "xcrun simctl ui \(self.udid) appearance light".runAsCommand()
        }
    }

    func turnOnDarkMode() {
        DispatchQueue.global().async {
            _ = "xcrun simctl ui \(self.udid) appearance dark".runAsCommand()
        }
    }

    func boot() {
        DispatchQueue.global().async {
            _ = "open -a Simulator.app && xcrun simctl boot \(self.udid)".runAsCommand()
        }
    }

    func shutdown() {
        DispatchQueue.global().async {
            _ = "xcrun simctl shutdown \(self.udid)".runAsCommand()
        }
    }

    func openDeviceDataFolder() {
        DispatchQueue.global().async {
            guard let device = SystemInfo(allowedTypes: [.iOS]).getDevice(for: self.udid) else {
                return
            }
            _ = "open \(device.dataPath)".runAsCommand()
        }
    }

    func copyUdid() {
        DispatchQueue.global().async {
            _ = "echo \(self.udid) | pbcopy".runAsCommand()
        }
    }

    func erase() {
        DispatchQueue.global().async {
            guard let device = SystemInfo(allowedTypes: [.iOS]).getDevice(for: self.udid) else {
                return
            }
            let shouldOpen = device.state == .booted
            _ = "xcrun simctl shutdown \(self.udid)".runAsCommand { process in
                _ = "xcrun simctl erase \(self.udid)".runAsCommand{ process in
                    if shouldOpen {
                        self.boot()
                    }
                }
            }
        }
    }
}
