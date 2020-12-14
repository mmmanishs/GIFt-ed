//
//  AppMenuProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/11/20.
//

import AppKit

class AppMenuProvider {
    private let device: Simulator.Device
    private var selector: Selector
    static var cumulativeTimeForScanningAppSandbox = 0.0
    var installedApps: NSMenuItem?

    init(_ device: Simulator.Device, selector: Selector) {
        self.device = device
        self.selector = selector
    }

    func update() {
        let appItems = SandboxInspector(rootPath: self.device.appsSandboxRootPath).inspect().map { self.getAppMenuItem(for: $0) }
        guard !appItems.isEmpty else {
            installedApps = .menuItem(with: "no installed apps", color: .lightGray)
            return
        }
        let menuItem = NSMenuItem(title: appItems.count > 1 ? "Installed Apps" : "Installed App", action: selector, keyEquivalent: "")
        menuItem.identifier = .simulatorIdentifier(identifier: "installed-apps")
        TimeExecution.start(description: "Starting installed apps \(self.device.appsSandboxRootPath)")
        let menu = NSMenu(title: "")
        menuItem.submenu = menu
        menu.items = appItems
        installedApps = menuItem
        AppMenuProvider.cumulativeTimeForScanningAppSandbox += TimeExecution.stop(description: "Stopping installed apps\(self.device.appsSandboxRootPath)")
    }

    func getAppMenuItem(for sandboxApp: SandboxApp) -> NSMenuItem {
        let menuItem = NSMenuItem(title: sandboxApp.name, action: selector, keyEquivalent: "")
        menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "installed-apps|\(device.udid)|\(sandboxApp.rootPath)|\(sandboxApp.name)|\(sandboxApp.bundleIdentifier)")
        let menu = NSMenu(title: "options")
        menuItem.submenu = menu
        let optionsProvider =  AppMenuOptionsProvider(sandboxApp: sandboxApp, device: device, selector: selector)
        menu.items = [
            optionsProvider.launchApp,
            optionsProvider.openPlist,
            optionsProvider.openSandbox,
            optionsProvider.deleteItem
        ]
        return menuItem
    }
}

class AppMenuOptionsProvider {
    private let sandboxApp: SandboxApp
    private let device: Simulator.Device
    private let selector: Selector

    init(sandboxApp: SandboxApp, device: Simulator.Device, selector: Selector) {
        self.sandboxApp = sandboxApp
        self.device = device
        self.selector = selector
    }

    private var appInfo: String {
        "\(device.udid)|\(sandboxApp.rootPath)|\(sandboxApp.name)|\(sandboxApp.bundleIdentifier)|\(sandboxApp.plistPath)"
    }

    var openPlist: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "Open Info.plist", color: .black)
        item.action = selector
        item.identifier = NSUserInterfaceItemIdentifier(rawValue: "installed-apps|\(appInfo)|\(DeviceAppWorker.Action.openInfoPlist.rawValue)")
        return item
    }

    var openSandbox: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "Open sandbox", color: .black)
        item.action = selector
        item.identifier = NSUserInterfaceItemIdentifier(rawValue: "installed-apps|\(appInfo)|\(DeviceAppWorker.Action.openSandBox.rawValue)")
        return item
    }

    var launchApp: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "Launch", color: .black)
        item.action = selector
        item.identifier = NSUserInterfaceItemIdentifier(rawValue: "installed-apps|\(appInfo)|\(DeviceAppWorker.Action.launch.rawValue)")
        return item
    }

    var deleteItem: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "Delete", color: .red)
        item.action = selector
        item.identifier = NSUserInterfaceItemIdentifier(rawValue: "installed-apps|\(appInfo)|\(DeviceAppWorker.Action.delete.rawValue)")
        return item
    }
}

struct DeviceAppIdentiferParser { /// A parser for identifier
    let udid: String
    let sandboxAppRootPath: String
    let appName: String
    let bundleIdentifier: String
    let plistPath: String
    let action: DeviceAppWorker.Action

    init?(_ identifier: String) {
        let components = identifier.components(separatedBy: "|")
        if components.count != 7 {
            return nil
        }
        if components[0] != "installed-apps" {
            return nil
        }
        udid = components[1]
        sandboxAppRootPath = components[2]
        appName = components[3]
        bundleIdentifier = components[4]
        plistPath = components[5]
        action = DeviceAppWorker.Action(rawValue: components[6]) ?? .unknown
    }
}

extension NSMenuItem {
    static func menuItem(with title: String, color: NSColor = .black) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.attributedTitle = title.attributedString(color: color)
        return menuItem
    }
}
