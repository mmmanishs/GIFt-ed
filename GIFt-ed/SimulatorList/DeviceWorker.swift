//
//  DeviceWorker.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/28/20.
//

import Foundation

class DeviceWorker {
    enum Action: String {
        case boot, shutdown, restart, deviceData, copyUdid, resetKeychain, erase, toggleLightDarkMode, appSandboxRootFolder, turnOnLightMode, turnOnDarkMode, delete, unknown
    }
    private let udid: String
    private let action: Action
    private var completionHandler: ((String)->())? = nil
    
    init(udid: String, action: Action) {
        self.udid = udid
        self.action = action
    }

    func execute(completionHandler: ((String)->())? = nil) {
        self.completionHandler = completionHandler
        switch action {
        case .boot:
            boot(completionHandler: completionHandler)
        case .shutdown:
            shutdown(completionHandler: completionHandler)
        case .restart:
            restart(completionHandler: completionHandler)
        case .deviceData:
            openDeviceDataFolder(completionHandler: completionHandler)
        case .copyUdid:
            copyUdid(completionHandler: completionHandler)
        case .erase:
            erase(completionHandler: completionHandler)
        case .resetKeychain:
            resetKeychain(completionHandler: completionHandler)
        case .turnOnLightMode:
            turnOnLightMode(completionHandler: completionHandler)
        case .turnOnDarkMode:
            turnOnDarkMode(completionHandler: completionHandler)
        case .toggleLightDarkMode:
            toggleLightDarkMode(completionHandler: completionHandler)
        case .appSandboxRootFolder:
            openAppSandboxRootFolder()
        case .delete:
            delete(completionHandler: completionHandler)
        default:
            break
        }
    }

    private func openAppSandboxRootFolder() {
        guard let device = cachedSystemInfo?.getDevice(for: udid) else {
            return
        }
        device.appsSandboxRootPath.openFolder()
    }

    private func toggleLightDarkMode(completionHandler: ((String)->())? = nil) {
        guard let device = cachedSystemInfo?.getDevice(for: udid) else {
            return
        }
        device.fetchAppearence { appearence in
            if appearence == .light {
                self.turnOnDarkMode(completionHandler: completionHandler)
            } else if appearence == .dark {
                self.turnOnLightMode(completionHandler: completionHandler)
            }
        }
    }

    private func turnOnLightMode(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl ui \(self.udid) appearance light".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func turnOnDarkMode(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl ui \(self.udid) appearance dark".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func boot(completionHandler: ((String)->())? = nil) {
        _ = "open -a Simulator.app && xcrun simctl boot \(udid)".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func resetKeychain(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl keychain \(udid) reset".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func shutdown(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl shutdown \(udid)".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func restart(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl shutdown \(udid)".runAsCommand { _ in
            _ = "xcrun simctl boot \(self.udid)".runAsCommand {_ in
                completionHandler?(self.udid)
            }
        }
    }

    private func openDeviceDataFolder(completionHandler: ((String)->())? = nil) {
        guard let device = cachedSystemInfo?.getDevice(for: self.udid) else {
            return
        }
        _ = "open \(device.dataPath)".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func copyUdid(completionHandler: ((String)->())? = nil) {
        _ = "echo \(self.udid) | pbcopy".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func delete(completionHandler: ((String)->())? = nil) {
        _ = "xcrun simctl delete \(self.udid)".runAsCommand {_ in
            completionHandler?(self.udid)
        }
    }

    private func erase(completionHandler: ((String)->())? = nil) {
        guard let device = cachedSystemInfo?.getDevice(for: self.udid) else {
            return
        }
        let shouldOpen = device.state == .booted
        _ = "xcrun simctl shutdown \(self.udid)".runAsCommand { process in
            _ = "xcrun simctl erase \(self.udid)".runAsCommand{ process in
                if shouldOpen {
                    self.boot(completionHandler: completionHandler)
                }
            }
        }
    }
}
