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
    private var appName: String {
        deviceAppIdentiferParser.appName
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
            deleteAppWithConfimation()
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

    private func deleteAppWithConfimation() {
        AppInMemoryCaches.refreshCachedSystemInfo()
        DispatchQueue.main.async {
            let vc = ConfirmOperationViewController.viewController(viewModel: .deleteApp(identifier: self.deviceAppIdentiferParser)) {_ in
                if let device = AppInMemoryCaches.cachedSystemInfo?.getDevice(for: self.udid) {
                    let isDeviceBooted = device.state == .booted
                    if isDeviceBooted {
                        _ = "xcrun simctl uninstall \(self.udid) \(self.bundleIdentifier)".runAsCommand()
                    } else {
                        DispatchQueue.main.async { [self] in
                            UserMessagePopup.shared.show(message: "Opening \(device.nameAndRuntime) to delete \(self.appName)")
                        }
                        DispatchQueue.global().async {
                            DeviceWorker(udid: self.udid, action: .boot).execute {_ in
                                _ = "xcrun simctl uninstall \(self.udid) \(self.bundleIdentifier)".runAsCommand { _ in
                                    DispatchQueue.main.async {
                                        if !isDeviceBooted {
                                            UserMessagePopup.shared.show(message: "Shutting down \(device.nameAndRuntime)")
                                        }
                                    }
                                    DeviceWorker(udid: self.udid, action: .shutdown).execute()
                                }
                            }
                        }
                    }
                }
//                _ = "xcrun simctl un install \(self.udid) \(self.bundleIdentifier)".runAsCommand()
            }
            MainPopover.shared.showInPopover(viewController: vc, behavior: .transient)
        }
    }

    private func launchApp() {
        let device = AppInMemoryCaches.cachedSystemInfo?.getDevice(for: udid)
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
        print("open \(deviceAppIdentiferParser.sandboxAppRootPath)".runAsCommand())
    }

    private func sendPushNotification() {

    }
}
