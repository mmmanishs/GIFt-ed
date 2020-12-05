//
//  DeviceWorker.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/28/20.
//

import Foundation

class DeviceWorker {
    enum Action: String {
        case boot, shutdown, restart, deviceData, copyUdid, resetKeychain, erase, toggleLightDarkMode, turnOnLightMode, turnOnDarkMode, delete, unknown
    }
    let udid: String
    let action: Action
    
    init(udid: String, action: Action) {
        self.udid = udid
        self.action = action
    }

    func execute() {
        switch self.action {
        case .boot:
            self.boot()
        case .shutdown:
            self.shutdown()
        case .restart:
            self.restart()
        case .deviceData:
            self.openDeviceDataFolder()
        case .copyUdid:
            self.copyUdid()
        case .erase:
            self.erase()
        case .resetKeychain:
            self.resetKeychain()
        case .turnOnLightMode:
            self.turnOnLightMode()
        case .turnOnDarkMode:
            self.turnOnDarkMode()
        case .toggleLightDarkMode:
            self.toggleLightDarkMode()
        case .delete:
            self.delete()
        default:
            break
        }
    }

    private func toggleLightDarkMode() {
        guard let device = cachedSystemInfo?.getDevice(for: udid) else {
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

    private func turnOnLightMode() {
        _ = "xcrun simctl ui \(self.udid) appearance light".runAsCommand()
    }

    private func turnOnDarkMode() {
        _ = "xcrun simctl ui \(self.udid) appearance dark".runAsCommand()
    }

    private func boot() {
        _ = "open -a Simulator.app && xcrun simctl boot \(udid)".runAsCommand()
    }

    private func resetKeychain() {
        _ = "xcrun simctl keychain \(udid) reset".runAsCommand()
    }

    private func shutdown() {
        _ = "xcrun simctl shutdown \(udid)".runAsCommand()
    }

    private func restart() {
        _ = "xcrun simctl shutdown \(udid)".runAsCommand { _ in
            _ = "xcrun simctl boot \(self.udid)".runAsCommand()
        }
    }

    private func openDeviceDataFolder() {
        guard let device = cachedSystemInfo?.getDevice(for: self.udid) else {
            return
        }
        _ = "open \(device.dataPath)".runAsCommand()
    }

    private func copyUdid() {
        _ = "echo \(self.udid) | pbcopy".runAsCommand()
    }

    private func delete() {
        _ = "xcrun simctl delete \(self.udid)".runAsCommand()
    }

    private func erase() {
        guard let device = cachedSystemInfo?.getDevice(for: self.udid) else {
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
