//
//  SimulatorMenuOptionsProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/11/20.
//

import AppKit

class SimulatorMenuOptionsProvider {
    private let udid: String
    private var selector: Selector
    init(_ udid: String, selector: Selector) {
        self.udid = udid
        self.selector = selector
    }
    var bootMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Boot", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.boot.rawValue)")
        return item
    }

    var shutDownMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "ShutDown", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.shutdown.rawValue)")
        return item
    }

    var restartMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Restart", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.restart.rawValue)")
        return item
    }

    var openDeviceDataItem: NSMenuItem {
        let item = NSMenuItem(title: "📂 Device Data", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.deviceData.rawValue)")
        return item
    }

    var copyUdid: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "(copy) \(udid)", size: 10)
        item.action = selector
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.copyUdid.rawValue)")
        return item
    }

    var resetKeyChain: NSMenuItem {
        let item = NSMenuItem(title: "Reset Keychain", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.resetKeychain.rawValue)")
        return item
    }

    var erase: NSMenuItem {
        let item = NSMenuItem(title: "Erase Device Data", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.erase.rawValue)")
        return item
    }

    var turnOnLightMode: NSMenuItem {
        let item = NSMenuItem(title: "Light Mode", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnLightMode.rawValue)")
        return item
    }

    var turnOnDarkMode: NSMenuItem {
        let item = NSMenuItem(title: "Dark Mode", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnDarkMode.rawValue)")
        return item
    }

    var toggleLightDarkMode: NSMenuItem {
        let item = NSMenuItem(title: "Toggle Light/Dark Mode", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.toggleLightDarkMode.rawValue)")
        return item
    }

    var appSandboxRootFolder: NSMenuItem {
        let item = NSMenuItem(title: "📂 Apps Sandbox", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.appSandboxRootFolder.rawValue)")
        return item
    }

    var openURLWindow: NSMenuItem {
        let item = NSMenuItem(title: "Open URL", action: selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.openURL.rawValue)")
        return item
    }

    var deleteDevice: NSMenuItem {
        let item = NSMenuItem(title: "Delete (confirmation required)", action: selector, keyEquivalent: "")
        item.attributedTitle = "Delete (confirmation required)".attributedString(color: .red)
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.delete.rawValue)")
        return item
    }
}
