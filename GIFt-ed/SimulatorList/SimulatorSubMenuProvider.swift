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
        guard let runtimeAndDevics = SystemInfo(allowedTypes: [.iOS]).simulator?.devices else {
            return []
        }
        return runtimeAndDevics.map { nugget in
            let menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
            let subMenu = NSMenu(title: "")
            subMenu.items = nugget.value.map { device in
                let item = NSMenuItem(title: device.name, action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
                item.identifier = .simulatorIdentifier(identifier: "\(device.udid)|\(DeviceWorker.Action.boot.rawValue)")
                item.submenu = getMenu(for: device)
                return item
            }
            menuItem.submenu = subMenu
            return menuItem
        }
    }

    private func getMenu(for device: Simulator.Device) -> NSMenu {
        let menu = NSMenu(title: "")
        menu.items = [
            device.bootMenuItem,
            device.toggleLightDarkMode,
            device.openDeviceDataItem,
            device.copyUdid,
            device.erase,
        ]
        return menu
    }

    static func functionalityResolver(identifier: String) {
        let cleanedIdentifier = identifier.replacingOccurrences(of: "simulators.device.", with: "")
        let identifierBreakups = cleanedIdentifier.components(separatedBy: "|")
        let udid = identifierBreakups[0]
        let actionIdentifier = identifierBreakups[1]
        DeviceWorker(udid: udid, action: DeviceWorker.Action(actionIdentifier: actionIdentifier)).execute()
    }
}

fileprivate extension Simulator.Device {
    var bootMenuItem: NSMenuItem {
        let bootItem = NSMenuItem(title: "Boot", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.boot.rawValue)")
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
    var toggleLightDarkMode: NSMenuItem {
        let bootItem = NSMenuItem(title: "Toggle Light/Dark Mode", action: SimulatorSubMenuProvider.selector, keyEquivalent: "")
        bootItem.identifier = .simulatorIdentifier(identifier: "\(self.udid)|\(DeviceWorker.Action.toggleLightDarkMode.rawValue)")
        return bootItem
    }
}
