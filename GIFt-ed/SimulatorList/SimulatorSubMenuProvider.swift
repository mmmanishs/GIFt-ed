//
//  SimulatorSubMenuProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/25/20.
//

import AppKit

class SimulatorSubMenuProvider {
    static var selector = #selector(MainMenu.functionalityRouter(_:))
    var simulatorMenu: NSMenu {
        let menu = NSMenu(title: "Simulators")
        menu.items = simulatorMenuItems
        return menu
    }

    private var simulatorMenuItems: [NSMenuItem] {
        guard let runtimeAndDevics = cachedSystemInfo?.simulator?.devices else {
            return []
        }
        return runtimeAndDevics.map { nugget in
            let menuItem: NSMenuItem
            if isAnyBooted(nugget.value) {
                menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
                menuItem.attributedTitle = Simulator.prettyRuntime(from: nugget.key).boldAttributedString(size: 14)
            } else {
                menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
            }
            let subMenu = NSMenu(title: "")
            subMenu.items = nugget.value.map { device in
                return SimulatorSubMenuProvider.menuItem(for: device)
            }
            menuItem.submenu = subMenu
            return menuItem
        }
    }

    func isAnyBooted(_ devices: [Simulator.Device]) -> Bool {
        for device in devices {
            if device.state == .booted { return true }
        }
        return false
    }

    static func menuItem(for deviceID: String) -> NSMenuItem? {
        guard let device = cachedSystemInfo?.getDevice(for: deviceID) else { return nil }
        return SimulatorSubMenuProvider.menuItem(for: device)
    }

    static func menuItem(for device: Simulator.Device) -> NSMenuItem {
        let item: NSMenuItem
        if device.state == .booted {
            item = NSMenuItem(title: device.nameAndRuntime, action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
            item.attributedTitle = device.nameAndRuntime.boldAttributedString(size: 14)
        } else {
            item = NSMenuItem(title: device.nameAndRuntime, action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        }
        item.identifier = .simulatorIdentifier(identifier: "\(device.udid)|\(DeviceWorker.Action.boot.rawValue)")
        item.submenu = getMenu(for: device)
        return item
    }

    static func getMenu(for device: Simulator.Device) -> NSMenu {
        let menu = NSMenu(title: "")
        if device.state == .shutdown {
            menu.addItem(device.bootMenuItem)
        }
        menu.addItem(device.toggleLightDarkMode)
        if device.state == .booted {
            menu.addItem(device.shutDownMenuItem)
        }
        menu.addItem(.dividerLine)
        menu.addItem(device.copyUdid)
        menu.addItem(.dividerLine)
        menu.addItem(device.openDeviceDataItem)
        menu.addItem(.dividerLine)
        menu.addItem(device.resetKeyChain)
        menu.addItem(device.erase)
        menu.addItem(.dividerLine)
        menu.addItem(device.deleteDevice)
        return menu
    }
}

fileprivate extension Simulator.Device {
    var bootMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Boot", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.boot.rawValue)")
        return item
    }

    var shutDownMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "ShutDown", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.shutdown.rawValue)")
        return item
    }

    var openDeviceDataItem: NSMenuItem {
        let item = NSMenuItem(title: "📂 Device Data", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.deviceData.rawValue)")
        return item
    }

    var copyUdid: NSMenuItem {
        let item = NSMenuItem(title: "(copy) \(udid)", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.copyUdid.rawValue)")
        return item
    }

    var resetKeyChain: NSMenuItem {
        let item = NSMenuItem(title: "Reset Keychain", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.resetKeychain.rawValue)")
        return item
    }

    var erase: NSMenuItem {
        let item = NSMenuItem(title: "Erase Device Data", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.erase.rawValue)")
        return item
    }

    var turnOnLightMode: NSMenuItem {
        let item = NSMenuItem(title: "Light Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnLightMode.rawValue)")
        return item
    }

    var turnOnDarkMode: NSMenuItem {
        let item = NSMenuItem(title: "Dark Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnDarkMode.rawValue)")
        return item
    }

    var toggleLightDarkMode: NSMenuItem {
        let item = NSMenuItem(title: "Toggle Light/Dark Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.toggleLightDarkMode.rawValue)")
        return item
    }

    var deleteDevice: NSMenuItem {
        let item = NSMenuItem(title: "Delete (confirmation required)", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        item.attributedTitle = "Delete (confirmation required)".attributedString(color: .red)
        item.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.delete.rawValue)")
        return item
    }
}

extension String {
    func boldAttributedString(size: CGFloat)-> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: size)])
        return attributedString
    }

    func attributedString(color: NSColor)-> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor : color])
        return attributedString
    }

}
