//
//  DeviceAppWorker.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/11/20.
//

import Foundation

class DeviceAppWorker {
    let deviceAppIdentiferParser: DeviceAppIdentiferParser
    enum Action: String {
        case delete
        case sendPushNotification
        case locationPermissions
        case launch
        case openSandBox
        case openInfoPlist
        case unknown
    }

    init(_ deviceAppIdentiferParser: DeviceAppIdentiferParser) {
        self.deviceAppIdentiferParser = deviceAppIdentiferParser
    }

    private var udid: String {
        deviceAppIdentiferParser.udid
    }
    private var bundleIdentifier: String {
        deviceAppIdentiferParser.bundleIdentifier
    }
    private var plistPath: String {
        deviceAppIdentiferParser.plistPath
    }

    func execute() {
        switch deviceAppIdentiferParser.action {
        case .delete:
            deleteApp()
        case .openInfoPlist:
            openInfoPlist()
        case .openSandBox:
            openSandbox()
        case .sendPushNotification:
            sendPushNotification()
        case .launch:
            launchApp()
        default:
            break
        }
    }

    private func deleteApp() {
        _ = "xcrun simctl uninstall \(udid) \(bundleIdentifier)".runAsCommand()
    }

    private func launchApp() {
        let device = cachedSystemInfo?.getDevice(for: udid)
        if device?.state != .booted {
            DeviceWorker(udid: udid, action: .boot).execute {_ in
                _ = "xcrun simctl launch \(self.udid) \(self.bundleIdentifier)".runAsCommand()
            }
        } else {
            _ = "xcrun simctl launch \(udid) \(bundleIdentifier)".runAsCommand()
        }
    }

    private func openInfoPlist() {
        _ = "open -a Xcode \(plistPath)".runAsCommand()
    }

    private func openSandbox() {
        _ = "open \(deviceAppIdentiferParser.sandboxAppRootPath)".runAsCommand()
    }

    private func sendPushNotification() {

    }
}
