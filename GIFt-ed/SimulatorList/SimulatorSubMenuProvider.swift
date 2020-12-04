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
            item = NSMenuItem(title: device.name, action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
            item.attributedTitle = device.name.boldAttributedString(size: 14)
        } else {
            item = NSMenuItem(title: device.name, action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        }
        item.identifier = .simulatorIdentifier(identifier: "\(device.udid)|\(DeviceWorker.Action.boot.rawValue)")
        item.submenu = getMenu(for: device)
        return item
    }

    static func getMenu(for device: Simulator.Device) -> NSMenu {
        let menu = NSMenu(title: "")
        if device.state == .shutdown {
            menu.addItem(device.bootMenuItem)
        } else if device.state == .booted {
            menu.addItem(device.shutDownMenuItem)
        }
        menu.addItem(device.toggleLightDarkMode)
        menu.addItem(device.openDeviceDataItem)
        menu.addItem(device.copyUdid)
        menu.addItem(device.erase)

        return menu
    }

    static func functionalityResolver(identifier: String) {
        let cleanedIdentifier = identifier.replacingOccurrences(of: "simulators.device.", with: "")
        let identifierBreakups = cleanedIdentifier.components(separatedBy: "|")
        let udid = identifierBreakups[0]
        let actionIdentifier = identifierBreakups[1]
        DeviceWorker(udid: udid, action: DeviceWorker.Action(rawValue: actionIdentifier) ?? .unknown).execute()
    }
}

fileprivate extension Simulator.Device {
    var bootMenuItem: NSMenuItem {
        let bootItem = NSMenuItem(title: "Boot", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.boot.rawValue)")
        return bootItem
    }

    var shutDownMenuItem: NSMenuItem {
        let bootItem = NSMenuItem(title: "ShutDown", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.shutdown.rawValue)")
        return bootItem
    }

    var openDeviceDataItem: NSMenuItem {
        let bootItem = NSMenuItem(title: "📂 Device Data", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.deviceData.rawValue)")
        return bootItem
    }

    var copyUdid: NSMenuItem {
        let bootItem = NSMenuItem(title: "(copy) \(udid)", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.copyUdid.rawValue)")
        return bootItem
    }

    var erase: NSMenuItem {
        let bootItem = NSMenuItem(title: "Erase Device Data", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.erase.rawValue)")
        return bootItem
    }

    var turnOnLightMode: NSMenuItem {
        let bootItem = NSMenuItem(title: "Light Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnLightMode.rawValue)")
        return bootItem
    }

    var turnOnDarkMode: NSMenuItem {
        let bootItem = NSMenuItem(title: "Dark Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.turnOnDarkMode.rawValue)")
        return bootItem
    }

    var toggleLightDarkMode: NSMenuItem {
        let bootItem = NSMenuItem(title: "Toggle Light/Dark Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.toggleLightDarkMode.rawValue)")
        return bootItem
    }
}

extension String {
    func boldAttributedString(size: CGFloat)-> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: size)])
        return attributedString
    }
}
